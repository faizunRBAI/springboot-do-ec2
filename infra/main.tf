# Lookup the platform-managed SSH key (account-scoped on DO)
data "digitalocean_ssh_key" "main" {
  name = "udap-${var.project_name}"
}

# Droplet
resource "digitalocean_droplet" "app" {
  name   = "${var.project_name}-droplet"
  region = var.region
  size   = var.droplet_size
  image  = "ubuntu-22-04-x64"

  ssh_keys = [data.digitalocean_ssh_key.main.fingerprint]

  tags = [
    "${var.project_name}-app",
    "ManagedBy:udap",
    "Project:${var.project_name}"
  ]
}

# Firewall — allow HTTP (80) and SSH (22) inbound only
resource "digitalocean_firewall" "app" {
  name = "${var.project_name}-fw"

  droplet_ids = [digitalocean_droplet.app.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
