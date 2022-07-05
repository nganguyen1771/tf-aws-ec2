output "public_ip" {
  description = "Public IP of instance (or EIP)"
  value       = module.ec2_instance.public_ip
}
