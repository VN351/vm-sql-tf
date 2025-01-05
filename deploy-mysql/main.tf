terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.15.0"
    }
  }
}

provider "docker" {
  host = "ssh://vlad@89.169.151.239"
}

resource "random_password" "mysql_root_password" {
  length  = 16
  special = true
}

resource "random_password" "mysql_password" {
  length  = 16
  special = true
}

resource "docker_image" "mysql" {
  name = "mysql:8"
  keep_locally = false
}

resource "docker_container" "mysql" {
  name  = "mysql-nv"
  image = docker_image.mysql.latest
  restart = "always"

  ports {
    internal = 3306
    external = 3306
    ip       = "127.0.0.1"
  }

  env = [
    "MYSQL_ROOT_PASSWORD=${random_password.mysql_root_password.result}",
    "MYSQL_DATABASE=wordpress",
    "MYSQL_USER=wordpress",
    "MYSQL_PASSWORD=${random_password.mysql_password.result}",
    "MYSQL_ROOT_HOST=%"
  ]
}

output "mysql_root_password" {
  description = "Пароль для root пользователя MySQL"
  value       = random_password.mysql_root_password.result
  sensitive   = true
}

output "mysql_password" {
  description = "Пароль для пользователя wordpress"
  value       = random_password.mysql_password.result
  sensitive   = true
}
