output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = module.vpc.igw_id
}

output "subnet_ids" {
  description = "Map of subnet names to subnet IDs"
  value       = module.vpc.subnet_ids
}

output "nat_gateway_ids" {
  description = "Map of public subnet names to NAT Gateway IDs"
  value       = module.vpc.nat_gateway_ids
}
