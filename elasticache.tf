resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = "${substr(var.environment, 0, 3)}"
  replication_group_description = "Redis cache cluster"
  number_cache_clusters         = 2
  node_type                     = "cache.m4.large"
  engine                        = "redis"
  port                          = 6379
  security_group_ids            = ["${aws_security_group.main.id}"]
  subnet_group_name             = "${aws_elasticache_subnet_group.elasticache.id}"
  automatic_failover_enabled    = true

  tags = {
    Name        = "${var.project}-${var.environment}"
    Environment = "${var.environment}"
  }
}

resource "aws_elasticache_subnet_group" "elasticache" {
  name       = "${var.project}-${var.environment}-redis"
  subnet_ids = "${aws_subnet.private.*.id}"
}

resource "aws_security_group" "main" {
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"
    self      = true
  }

  tags = {
    Name        = "${var.project}-${var.environment}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
    VPC         = "${aws_vpc.main.id}"
  }
}