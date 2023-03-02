resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "rds-group"
  subnet_ids = [aws_subnet.private_subnet[0].id, aws_subnet.private_subnet[1].id]
}

resource "aws_db_instance" "database" {
  allocated_storage    = 100
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "challenge-rds"
  username             = "myuser"
  password             = "mypassword"
  parameter_group_name = "default.mysql5.7"
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  subnet_group_name    = aws_db_subnet_group.db_subnet_group.name 
}

resource "aws_db_instance" "read_replica" {
  allocated_storage    = 100
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "challenge-rds-read-replica"
  username             = "myuser"
  password             = "mypassword"
  parameter_group_name = "default.mysql5.7"
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  subnet_group_name    = aws_db_subnet_group.db_subnet_group.name 
  source_db_instance_identifier = aws_db_instance.database.id
}
