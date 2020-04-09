
resource "aws_vpc" "main" {
    cidr_block            = "${var.vpc_cidr}"
    enable_dns_hostnames  = true

    tags = {
        Name = "${var.project_name} VPC"
        Project = "${var.project_name}"
    }
}

resource "aws_internet_gateway" "main" {
    vpc_id = "${aws_vpc.main.id}"

    tags = {
        Name = "${var.project_name} Gateway"
        Project = "${var.project_name}"
    }
}

resource "aws_default_route_table" "default" {
    default_route_table_id = "${aws_vpc.main.default_route_table_id}"

    # No routes in default route table

    tags = {
        Name = "${var.project_name} Default Route Table"
        Project = "${var.project_name}"
    }
}

# Public subnet
resource "aws_subnet" "public" {
    count                   = "${length(var.availability_zones)}"
    vpc_id                  = "${aws_vpc.main.id}"
    cidr_block              = "${var.public_subnet_cidr[count.index]}"
    availability_zone       = "${var.availability_zones[count.index]}"
    map_public_ip_on_launch = true

    tags = {
        Name = "${var.project_name} Public Subnet"
        Project = "${var.project_name}"
    }
}

resource "aws_route_table" "public" {
    vpc_id = "${aws_vpc.main.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.main.id}"
    }

    tags = {
        Name = "${var.project_name} Public Route Table"
        Project = "${var.project_name}"
    }
}

resource "aws_route_table_association" "public" {
    count          = "${length(aws_subnet.public)}"
    subnet_id      = "${aws_subnet.public[count.index].id}"
    route_table_id = "${aws_route_table.public.id}"
}

resource "aws_security_group" "client_sg" {
    name              = "client_sg"
    description       = "SG for Client instances"
    vpc_id            = "${aws_vpc.main.id}"

    # allow outgoing ICMP "pings"
    egress {
        from_port   = 8
        to_port     = 0
        protocol    = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # allow outgoing HTTP connections
    egress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # allow outgoing HTTPS connections
    egress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # allow outgoing service connections to public subnet
    egress {
        from_port   = 3000
        to_port     = 3000
        protocol    = "tcp"
        cidr_blocks = "${var.public_subnet_cidr}"
    }

    # allow outgoing service connections to public subnet
    # (TLS)
    egress {
        from_port   = 4000
        to_port     = 4000
        protocol    = "tcp"
        cidr_blocks = "${var.public_subnet_cidr}"
    }

    # allow incoming SSH connections from CIDR defined in vars (default all)
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = "${var.ssh_ingress_cidrs}"
    }

    tags = {
        Name = "${var.project_name} Client SG"
        Project = "${var.project_name}"
    }

    depends_on = ["aws_vpc.main"]
}

resource "aws_security_group" "server_sg" {
    name              = "server_sg"
    description       = "SG for Aerospiker Server instances"
    vpc_id            = "${aws_vpc.main.id}"

    # allow outgoing ICMP "pings"
    egress {
        from_port   = 8
        to_port     = 0
        protocol    = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # allow outgoing HTTP connections
    egress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # allow outgoing HTTPS connections
    egress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # allow incoming SSH connections from CIDR defined in vars (default all)
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = "${var.ssh_ingress_cidrs}"
    }

    # allow incoming service, farbic, heartbeat connections from public subnet
    ingress {
        from_port   = 3000
        to_port     = 3002
        protocol    = "tcp"
        cidr_blocks = "${var.public_subnet_cidr}"
    }

    # allow outgoing farbic, heartbeat connections from public subnet
    egress {
        from_port   = 3001
        to_port     = 3002
        protocol    = "tcp"
        cidr_blocks = "${var.public_subnet_cidr}"
    }

    # allow incoming service, farbic, heartbeat connections to public subnet
    # (TLS ports)
    ingress {
        from_port   = 4000
        to_port     = 4002
        protocol    = "tcp"
        cidr_blocks = "${var.public_subnet_cidr}"
    }

    # allow outgoing farbic, heartbeat connections to public subnet
    egress {
        from_port   = 4001
        to_port     = 4002
        protocol    = "tcp"
        cidr_blocks = "${var.public_subnet_cidr}"
    }

    tags = {
        Name = "${var.project_name} Server SG"
        Project = "${var.project_name}"
    }

    depends_on = ["aws_subnet.public"]
}
