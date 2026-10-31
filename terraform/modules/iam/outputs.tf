output "alb_security_group_id" {
  value = aws_security_group.alb_sg.id
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs_sg.id
}

output "rds_security_group_id" {
  value = aws_security_group.rds_sg.id
}

output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
}

output "ec2_instance_profile_arn" {
  value = aws_iam_instance_profile.ec2_instance_profile.arn
}