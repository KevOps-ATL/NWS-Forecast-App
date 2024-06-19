# subnets/outputs.tf

output "priv1_id" {
  value = aws_subnet.priv1.id
}

output "priv2_id" {
  value = aws_subnet.priv2.id
}

output "pub_id" {
  value = aws_subnet.public.id
}