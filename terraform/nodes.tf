data "hcloud_ssh_key" "main" {
  name = var.ssh_key_name
}

locals {
  cloud_init = <<-EOT
  #cloud-config
  ssh_pwauth: false
  write_files:
  - path: /etc/ssh/sshd_config.d/10-port.conf
    content: |
      Port ${var.ssh_port}
  EOT
}

resource "hcloud_server" "kube_master" {
  name   = "kube-master0"
  labels = var.labels

  server_type = var.master_server_type
  image       = "ubuntu-20.04"
  user_data   = local.cloud_init
  location    = data.hcloud_location.location1.name
  ssh_keys    = [data.hcloud_ssh_key.main.id]
}

resource "hcloud_server" "kube_worker" {
  count = var.workers_count

  name   = "kube-worker${count.index}"
  labels = var.labels

  server_type = var.worker_server_type
  image       = "ubuntu-20.04"
  user_data   = local.cloud_init
  location    = data.hcloud_location.location1.name
  ssh_keys    = [data.hcloud_ssh_key.main.id]
}
