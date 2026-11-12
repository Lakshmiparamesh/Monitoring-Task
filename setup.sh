#!/bin/bash
set -e

echo "=== Installing Prometheus, Node Exporter, and Grafana on Ubuntu ==="

# Update system
sudo apt-get update -y

# --- Prometheus ---
echo "Installing Prometheus v2.47.2..."
wget -q https://github.com/prometheus/prometheus/releases/download/v2.47.2/prometheus-2.47.2.linux-amd64.tar.gz
tar xzf prometheus-2.47.2.linux-amd64.tar.gz
sudo cp prometheus-2.47.2.linux-amd64/prometheus /usr/local/bin/
sudo cp prometheus-2.47.2.linux-amd64/promtool /usr/local/bin/
sudo mkdir -p /opt/prometheus/data
sudo cp prometheus.yml /opt/prometheus/prometheus.yml
sudo chown -R ubuntu:ubuntu /opt/prometheus
rm -rf prometheus-2.47.2.linux-amd64*

# Create Prometheus systemd service
sudo cp prometheus.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus
echo "Prometheus installed and running on port 9090"

# --- Node Exporter ---
echo "Installing Node Exporter v1.7.0..."
wget -q https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar xzf node_exporter-1.7.0.linux-amd64.tar.gz
sudo cp node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/
rm -rf node_exporter-1.7.0.linux-amd64*

# Create Node Exporter systemd service
sudo cp node_exporter.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
echo "Node Exporter installed and running on port 9100"

# --- Grafana ---
echo "Installing Grafana v10.2.2..."
sudo apt-get install -y adduser libfontconfig1 musl
wget -q https://dl.grafana.com/oss/release/grafana_10.2.2_amd64.deb
sudo dpkg -i grafana_10.2.2_amd64.deb
rm grafana_10.2.2_amd64.deb

sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
echo "Grafana installed and running on port 3000"

# --- Add Prometheus as Grafana data source ---
echo "Adding Prometheus data source to Grafana..."
sleep 5
curl -s -X POST "http://admin:admin@localhost:3000/api/datasources" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Prometheus",
    "type": "prometheus",
    "url": "http://localhost:9090",
    "access": "proxy",
    "isDefault": true
  }'

echo ""
echo "=== Setup Complete ==="
echo "Prometheus: http://<EC2_PUBLIC_IP>:9090"
echo "Grafana:    http://<EC2_PUBLIC_IP>:3000 (admin/admin)"
echo "Node Exporter metrics: http://<EC2_PUBLIC_IP>:9100/metrics"
