terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.74.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "yandex" {
# Конфигурация провайдера Yandex Cloud
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}

# Создание VPC
resource "yandex_vpc_network" "vpc-net" {
  name = "vpc-network" 
} 

# Создание подсети
resource "yandex_vpc_subnet" "vpc-subnet-a" {
  name           = "subnet-1"
  description    = "subnet-1"
  v4_cidr_blocks = ["10.1.1.0/24"]
  zone           = "${var.yc_zone}"
  network_id     = "${yandex_vpc_network.vpc-net.id}"
}
# Создание VM
resource "yandex_compute_instance" "mysql_1" {
  name = "mysql-1"
  hostname = "mysql-1"
  allow_stopping_for_update = true
  platform_id = "standard-v3"
  zone = "ru-central1-a"

  resources {
    cores = 2
    core_fraction = 20
    memory = 4
  }

  scheduling_policy {
  preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = "fd83r8l1erja63002a2h" 
      size = "20"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.vpc-subnet-a.id
    ip_address         = "10.1.1.10"
    nat = true
  }

  metadata = {
    ssh-keys = "vlad:${file(var.ssh_public_key_path)}"
    user-data = <<-EOF
      #cloud-config
      packages:
        - docker.io
      groups:
        - docker
      users:
        - name: vlad
          sudo: ["ALL=(ALL) NOPASSWD:ALL"]
          groups: ["docker", "sudo"]
          shell: /bin/bash
          ssh-authorized-keys:
            - ${file(var.ssh_public_key_path)}
      runcmd:
        - systemctl enable docker
        - systemctl start docker
        - usermod -aG docker vlad
      EOF
  }
}


