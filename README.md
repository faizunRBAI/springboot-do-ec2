# springboot-do-ec2

A **Spring Boot** application deployed to a **DigitalOcean Droplet** (Ubuntu 22.04, `nyc3`) via Terraform + Ansible, fronted by Nginx on port 80.

---

## Architecture

```
Internet → DO Firewall → Nginx (:80) → Spring Boot (:8080)
                              Droplet (s-1vcpu-1gb, nyc3)
```

- **IaC**: Terraform provisions the Droplet and DO Firewall
- **Config**: Ansible installs Java 17, deploys the JAR as a systemd service, and configures Nginx as a reverse proxy
- **CI/CD**: GitHub Actions (build → provision → configure → verify)

---

## CI/CD Pipeline

| Stage | What it does |
|-------|-------------|
| `build` | `mvn package -DskipTests`, uploads JAR artifact |
| `provision` | Terraform: creates Droplet + Firewall |
| `configure` | Downloads JAR, runs Ansible playbook on Droplet |
| `verify` | Health-checks `http://<droplet-ip>/` with retries |

---

## Local Development

### Prerequisites
- Java 17
- Maven 3.8+

### Run locally

```bash
mvn spring-boot:run
# App available at http://localhost:8080
```

### Build JAR

```bash
mvn package -DskipTests
java -jar target/*.jar
```

---

## Configuration

| Variable | Required | Secret | Description |
|----------|----------|--------|-------------|
| `DO_TOKEN` | Yes | ✅ | DigitalOcean API token |
| `SSH_PRIVATE_KEY` | Yes | ✅ | SSH private key for Ansible |
| `SSH_PUBLIC_KEY` | Yes | ✅ | SSH public key registered with DO |
| `SSH_USER` | Yes | ✅ | SSH login user (`root` for Ubuntu droplets) |
| `TF_STATE_BUCKET` | Yes | ✅ | Platform-managed Spaces bucket for Terraform state |
| `SPACES_ACCESS_KEY` | Yes | ✅ | DO Spaces access key |
| `SPACES_SECRET_KEY` | Yes | ✅ | DO Spaces secret key |
| `SPACES_ENDPOINT` | Yes | ✅ | DO Spaces endpoint URL |
| `PROJECT_NAME` | Yes | ✅ | Platform-injected project name |

All secrets are managed by the UDAP platform and injected into the pipeline automatically.

---

## Operations

### Check service status (on Droplet)

```bash
systemctl status springboot
journalctl -u springboot -f
```

### Restart app

```bash
systemctl restart springboot
```

### Check Nginx

```bash
systemctl status nginx
nginx -t
```

### Redeploy

Push to `main` branch — the pipeline triggers automatically.

---

## Infrastructure

- **Cloud**: DigitalOcean `nyc3`
- **Droplet**: Ubuntu 22.04 LTS, `s-1vcpu-1gb`
- **Firewall**: Ports 22 (SSH) and 80 (HTTP) inbound
- **Terraform state**: DigitalOcean Spaces (S3-compatible)

> **Public URL**: `http://<droplet-ip>/` (set after first deploy)
