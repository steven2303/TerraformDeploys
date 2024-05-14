output "instance_ip" {
  value = aws_instance.locust.public_ip
  description = "Public IP address of the Locust EC2 instance"
}

output "private_key" {
  value     = tls_private_key.example.private_key_pem
  sensitive = true  // Marca esto como sensible para evitar que se muestre en la salida por defecto
}