# gradio-load-balancing
Proof of concept for implementing load balancing for a Gradio app

## Description

This proof of concept demonstrates how a [Gradio](https://www.gradio.app/) app
can use multiple GPUs in a [Lambda
Cloud](https://lambdalabs.com/service/gpu-cloud) on-demand instance.

By following the instructions below, you'll have an 8x H100 or 8x A100
running 8 Gradio apps. Each app will:

- Use a single GPU.
- Listen on a localhost port, TCP/{7860..7867}.

  💡 **Note:** You can set the `GRADIO_SERVER_NAME` environment variable to `0.0.0.0`
  to make the apps network-accessible. This can be useful for load balancing between
  multiple instances. Make sure to configure appropriate firewall rules!

- Serve the [FLUX.1
  [schnell]](https://huggingface.co/black-forest-labs/FLUX.1-schnell)
  prompt-to-image model.
- Log to a file named `log_{0..7}.txt`, the number representing the GPU the
  app is using.

[Nginx](https://nginx.org/en/), acting as a [load
balancer](https://docs.nginx.com/nginx/admin-guide/load-balancer/http-load-balancer/)
(reverse proxy), will balance requests to the server between the 8 apps.

## Usage

1. Launch an 8x H100 or 8x A100 instance from the Cloud dashboard or using the
   Cloud API.

1. Clone this repo to your home directory and change into the directory:

   ```bash
   git clone https://github.com/cbrownstein-lambda/gradio-load-balancing.git "$HOME/gradio-load-balancing" && \
   cd "$HOME/gradio-load-balancing"
   ```

1. Run the `launch_gradio.sh` script:

   ```bash
   bash launch_gradio.sh
   ```

1. Start Nginx:

   ```bash
   sudo docker run -d --rm --name nginx-load-balancer --network=host \
        -v "$PWD/nginx.conf":/etc/nginx/nginx.conf:ro nginx
   ```

1. Configure the
   [Firewall](https://docs.lambdalabs.com/on-demand-cloud/firewall) to allow
   TCP traffic to port 80.

   ⚠️ **WARNING:** This proof of concept requires no authentication. Anyone
   with your instance's IP address will be able to access the server (but not
   log into your instance). ⚠️

1. Access the server at http://INSTANCE-IP-ADDRESS.

   Replace **INSTANCE-IP-ADDRESS** with your instance's IP address, which you
   can get from the Cloud dashboard or using the Cloud API.
