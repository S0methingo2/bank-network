output "bastion_dns" {
  value = module.bastion.public_dns
}

output "bastion_private-ip" {
  value = module.bastion.private_ip
}