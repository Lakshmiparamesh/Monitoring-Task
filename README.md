# Monitoring Task — Prometheus & Grafana on AWS EC2

Install Prometheus and Grafana on a Linux EC2 machine, connect Prometheus to Grafana, and create a dashboard to view system metrics.

## Tech Stack

| Component | Version | Port |
|-----------|---------|------|
| AWS EC2 | Ubuntu 22.04 LTS (t2.micro) | — |
| Prometheus | v2.47.2 | 9090 |
| Node Exporter | v1.7.0 | 9100 |
| Grafana | v10.2.2 | 3000 |

## Architecture

```
┌─────────────────────────────────────────────────┐
│                AWS EC2 (Ubuntu 22.04)            │
│                                                   │
│  ┌──────────────┐    scrape     ┌──────────────┐ │
│  │  Prometheus   │◄────────────│ Node Exporter │ │
│  │  :9090        │              │  :9100        │ │
│  └──────┬───────┘              └──────────────┘ │
│         │ data source                             │
│         ▼                                         │
│  ┌──────────────┐                                │
│  │   Grafana     │                                │
│  │   :3000       │                                │
│  └──────────────┘                                │
└─────────────────────────────────────────────────┘
         │
         ▼
    Browser (Dashboard)
```

## Project Structure

```
Monitoring-Task/
├── prometheus.yml              # Prometheus scrape configuration
├── prometheus.service          # Prometheus systemd service file
├── node_exporter.service       # Node Exporter systemd service file
├── setup.sh                    # Automated setup script
├── screenshots/                # Execution screenshots
├── EXECUTION-OUTPUT.md         # Detailed execution output
└── README.md                   # This file
```

## Setup Instructions

### 1. Launch EC2 Instance
- AMI: Ubuntu 22.04 LTS
- Instance Type: t2.micro
- Security Group: Open ports 22 (SSH), 9090 (Prometheus), 9100 (Node Exporter), 3000 (Grafana)

### 2. Run Setup Script
```bash
chmod +x setup.sh
./setup.sh
```

Or install manually — see [EXECUTION-OUTPUT.md](EXECUTION-OUTPUT.md) for step-by-step commands.

### 3. Access Services
| Service | URL |
|---------|-----|
| Prometheus | `http://<EC2_IP>:9090` |
| Node Exporter | `http://<EC2_IP>:9100/metrics` |
| Grafana | `http://<EC2_IP>:3000` (admin/admin) |

### 4. Connect Prometheus to Grafana
1. Login to Grafana (admin/admin)
2. Go to Connections → Data Sources → Add data source
3. Select Prometheus
4. URL: `http://localhost:9090`
5. Click "Save & Test"

### 5. Create Dashboard
Import or create a dashboard with panels for:
- CPU Usage
- Memory Usage
- Disk Usage
- Network Traffic

## Screenshots

See [EXECUTION-OUTPUT.md](EXECUTION-OUTPUT.md) for all screenshots.
