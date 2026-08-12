variable "project_name" {
  description = "Project name used as a prefix for all cloud resources"
  type        = string
}

variable "region" {
  description = "DigitalOcean region slug"
  type        = string
  default     = "nyc3"
}

variable "droplet_size" {
  description = "DigitalOcean Droplet size slug"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "ssh_public_key" {
  description = "SSH public key content (injected by the platform)"
  type        = string
  sensitive   = true
}

variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}
