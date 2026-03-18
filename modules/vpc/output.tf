output "vpc_id" {
    value  = aws_vpc.my_vpc.id
}

output "public_subnet_map" {
    value = {
        for k, v in aws_aws_subnet.my_public_subnet :
        k => v.id
    }
}

output "private_subnet_map" {
    value = {
        for k, v in aws_aws_subnet.my_private_subnet :
        k => v.id
    }
}

output "public_subnet_ids" {
    value = [
        for v in aws_aws_subnet.my_public_subnet :
        v.id
    ]
}

output "private_subnet_ids" {
    value = [
        for v in aws_aws_subnet.my_private_subnet :
        v.id    
    ]
}

output "security_group_ids" {
  value = [aws_security_group.sg.id]
}