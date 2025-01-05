output "vm_ip" {
  description = "IP address of the VM"
  value       = yandex_compute_instance.mysql_1.network_interface.0.nat_ip_address
}

