# Monitoring Task — Execution Output

## 1. EC2 Instance Setup

- **Instance Type:** t2.micro
- **AMI:** Ubuntu 22.04 LTS
- **Region:** ap-south-1 (Mumbai)
- **Public IP:** 3.110.196.46
- **Security Group Ports:** 22, 80, 3000, 8080, 9090, 9100

---

## 2. Prometheus Installation

### Download and Install (v2.47.2)
```bash
wget https://github.com/prometheus/prometheus/releases/download/v2.47.2/prometheus-2.47.2.linux-amd64.tar.gz
tar xzf prometheus-2.47.2.linux-amd64.tar.gz
sudo cp prometheus-2.47.2.linux-amd64/prometheus /usr/local/bin/
sudo cp prometheus-2.47.2.linux-amd64/promtool /usr/local/bin/
sudo mkdir -p /opt/prometheus/data
```

### Configuration (prometheus.yml)
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: [localhost:9090]

  - job_name: node
    static_configs:
      - targets: [localhost:9100]

  - job_name: docker
    static_configs:
      - targets: [localhost:9323]
```

### Systemd Service
```bash
sudo cp prometheus.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus
```

### Verification
```bash
$ systemctl is-active prometheus
active
```

### Screenshot — Prometheus Dashboard
![Prometheus Dashboard](screenshots/prometheus-dashboard.jpg)

### Screenshot — Prometheus Targets (node: UP, prometheus: UP)
![Prometheus Targets](screenshots/prometheus-targets.jpg)

### Screenshot — Prometheus CPU Graph
![Prometheus CPU Graph](screenshots/prometheus-cpu-graph.jpg)

---

## 3. Node Exporter Installation

### Download and Install (v1.7.0)
```bash
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar xzf node_exporter-1.7.0.linux-amd64.tar.gz
sudo cp node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/
```

### Systemd Service
```bash
sudo cp node_exporter.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
```

### Verification
```bash
$ systemctl is-active node_exporter
active
```

Node Exporter collects system metrics:
- CPU usage and load averages
- Memory (total, available, used)
- Disk I/O and filesystem usage
- Network interface statistics

---

## 4. Grafana Installation

### Download and Install (v10.2.2)
```bash
sudo apt-get install -y adduser libfontconfig1 musl
wget https://dl.grafana.com/oss/release/grafana_10.2.2_amd64.deb
sudo dpkg -i grafana_10.2.2_amd64.deb
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
```

### Verification
```bash
$ systemctl is-active grafana-server
active
```

### Screenshot — Grafana Home
![Grafana Home](screenshots/grafana-home.jpg)

---

## 5. Connect Prometheus to Grafana

### Add Data Source
1. Login to Grafana at `http://3.110.196.46:3000` (admin/admin)
2. Navigate to Connections → Data Sources
3. Click "Add new data source" → Select "Prometheus"
4. Set URL to `http://localhost:9090`
5. Click "Save & Test" → Success

Or via API:
```bash
curl -X POST "http://admin:admin@localhost:3000/api/datasources" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Prometheus",
    "type": "prometheus",
    "url": "http://localhost:9090",
    "access": "proxy",
    "isDefault": true
  }'
```

### Screenshot — Prometheus Data Source in Grafana
![Grafana Datasource](screenshots/grafana-datasource.jpg)

---

## 6. Create Monitoring Dashboard

### Dashboard: EC2 Node Monitoring
Created a custom dashboard with 4 panels:

| Panel | Type | Metric |
|-------|------|--------|
| CPU Usage | Timeseries | `100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)` |
| Memory Usage | Timeseries | `(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100` |
| Disk Usage | Gauge | `100 - ((node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100)` |
| Network Traffic | Timeseries | `rate(node_network_receive_bytes_total{device="eth0"}[5m])` |

### Screenshot — Grafana Monitoring Dashboard
![Grafana Dashboard](screenshots/grafana-monitoring-dashboard.jpg)

---

## 7. Service Status Summary

```bash
$ systemctl is-active prometheus node_exporter grafana-server
active
active
active
```

| Service | Port | Status |
|---------|------|--------|
| Prometheus | 9090 | Active |
| Node Exporter | 9100 | Active |
| Grafana | 3000 | Active |

---

## 8. Access URLs

| Service | URL |
|---------|-----|
| Prometheus | http://3.110.196.46:9090 |
| Prometheus Targets | http://3.110.196.46:9090/targets |
| Grafana | http://3.110.196.46:3000 |
| Grafana Dashboard | http://3.110.196.46:3000/d/node-monitor/ec2-node-monitoring |
