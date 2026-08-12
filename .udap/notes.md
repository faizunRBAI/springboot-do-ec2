# springboot-do-ec2 — Build Notes

## Project
Deploy `faizunRBAI/springboot-aws-ec2` (Spring Boot Java) to DigitalOcean Droplet (nyc3).

## Key Decisions
- Target: do-droplet (s-1vcpu-1gb, nyc3)
- LB: Nginx on port 80 → app on :8080
- IaC: Terraform with DO provider + Spaces S3-compatible backend
- Config: Ansible (install Java 17, deploy JAR, systemd, Nginx)
- Java version: 17 (LTS — no explicit pin found in repo; using temurin distribution)
- App port: 8080 (Spring Boot default; confirmed from application.properties pattern)
- Build: Maven (pom.xml present in repo)
- SSH key: data source lookup for "udap-${var.project_name}" (DO account-scoped)

## Pipeline Stages
1. build — Maven package -DskipTests, upload JAR artifact
2. provision — Terraform apply (droplet + firewall)
3. configure — Download JAR, Ansible playbook
4. verify — curl health check with retries

## Status
- [x] Architecture written (rev 1)
- [x] Pipeline written (rev 1)
- [x] Design approved
- [x] Plan approved
- [ ] IaC written
- [ ] Ansible written
- [ ] README written
- [ ] validate_project
- [ ] test_project
- [ ] repo pushed
- [ ] deployed

## Gotchas
- DO SSH keys are account-scoped; must use `data "digitalocean_ssh_key"` not resource
- Spaces backend requires extra skip_* flags and endpoint derivation from AWS_ENDPOINT_URL_S3
- Must derive SPACES_REGION from the endpoint host, never hardcode
- ansible-core only — use ansible.builtin.* modules only (no community.general)
- No cache_valid_time on apt update (fresh VM, stale cache risk)
