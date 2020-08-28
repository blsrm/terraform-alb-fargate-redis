output "alb_hostname" {
  value = "${aws_alb.main.dns_name}"
}

output "redis_endpoint" {
  value = "${aws_elasticache_replication_group.redis.primary_endpoint_address}"
}