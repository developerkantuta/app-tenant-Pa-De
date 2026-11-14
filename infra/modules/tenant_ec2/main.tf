# 1. Crear el Rol para la EC2
resource "aws_iam_role" "ec2_tenant_role" {
  name = "rol-ec2-tenant-${var.tenant_id}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" } }]
  })
}

# 2. Dar permisos de administrador de EC2 al Rol (para que pueda crear/borrar instancias)
resource "aws_iam_role_policy_attachment" "ec2_tenant_policy" {
  role       = aws_iam_role.ec2_tenant_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess" # En producción usar un permiso más restrictivo
}

# 3. Crear el Instance Profile (el "contenedor" del rol)
resource "aws_iam_instance_profile" "ec2_tenant_profile" {
  name = "profile-ec2-tenant-${var.tenant_id}"
  role = aws_iam_role.ec2_tenant_role.name
}

resource "aws_security_group" "tenant_sg" {
  name        = "sg_${var.tenant_id}"
  description = "Security Group para el tenant de ${var.tenant_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name   = "sg-${var.tenant_id}"
    Tenant = var.tenant_id
  }
}

resource "aws_instance" "tenant_vm" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.tenant_sg.id]
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.ec2_tenant_profile.name
  
  # Añadimos esta línea para que lea el script de inicio automáticamente
  user_data = file("${path.module}/user-data.sh")

  tags = {
    Name   = "vm-${var.tenant_id}"
    Tenant = var.tenant_id
  }
}