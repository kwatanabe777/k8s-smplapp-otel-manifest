# kubernetes manifests for php-fpm containers deployment.
                                                                    by kwatanabe
                                                                    last updated:2024-07-11 19:47.
## deploy manifests by environments

- for local development
  ```bash
  helmfile apply -e local-dev
  ```
  mount local development directory to container.  
  directory from:
  `/develop_k3d/k8s-smplapp-otel/webapp`

- for local test
  ```bash
  helmfile apply -e local
  ```
  application on container image.


- for test environment
  ```bash
  helmfile apply -e local
  ```
  deploy 3 replicas .

## values
each environment values are defined in `env/values-*.yaml` files.

## charts
phpfpm charts deployment pods is included 4 containers default.  
- phpfpm
  php application container.
- nginx
  application front nginx container.
- fluentbit
  log collector container.
  transfer application logs to loki.
- helper-tools
  helper tools(delete application logs) container.


