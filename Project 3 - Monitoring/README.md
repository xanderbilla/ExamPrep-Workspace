# Monitoring with Grafana, Loki and Prometheus

### Installation and Setup
#### 1. Prometheus Server
- Create a `prometheus-config.yml` file and copy the following configration. Don't forget to replace `<NDOEJS_SERVER_ADDRESS>` with actual value.
```yml
global:
  scrape_interval: 4s

scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: ["<NDOEJS_SERVER_ADDRESS>"]
```
- Start the Prometheus Server using docker compose
```yml
version: "3"

services:
  prom-server:
    image: prom/prometheus
    ports:
      - 3200:3200
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
```
Great, The prometheus server is now up and running at PORT 3200

#### 2. Setup Grafana
```bash
docker run -d -p 3000:3000 --name=grafana grafana/grafana-oss
```
![grafana](https://grafana.com/static/img/grafana/showcase_visualize.jpg)

### 3. Setup Loki Server
```bash
docker run -d --name=loki -p 3100:3100 grafana/loki
```