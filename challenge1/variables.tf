variable "public_subnet_cidrs" {
  description = "The list of CIDR Blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zone" {
  description = "The list of azs for high availability"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  
}

variable "private_subnet_cidrs" {
  description = "The list of CIDR Blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}