
# Benchmark Client image created by Packer
data "aws_ami" "benchmark_client_image" {
    most_recent = true
    owners      = ["${var.ami_owner}"]

    filter {
        name   = "name"
        values = ["${var.client_ami_name}"]
    }
}

# Aerospike Server image created by Packer
data "aws_ami" "aerospike_server_image" {
    most_recent = true
    owners      = ["${var.ami_owner}"]

    filter {
        name   = "name"
        values = ["${var.server_ami_name}"]
    }
}

resource "aws_instance" "benchmark_client" {
    count                  = "${var.client_instance_count}"
    instance_type          = "${var.client_instance_type}"
    ami                    = "${data.aws_ami.benchmark_client_image.id}"
    vpc_security_group_ids = ["${aws_security_group.client_sg.id}"]
    subnet_id              = "${element(aws_subnet.public.*.id, count.index)}"
    key_name               = "${var.key_name}"

    tags = {
        Name = "${var.project_name} Client"
        Project = "${var.project_name}"
        InventoryGroup = "client_instance"
    }
}

resource "aws_instance" "aerospike_server" {
    count                       = "${var.aerospike_instance_count}"
    instance_type               = "${var.aerospike_instance_type}"
    ami                         = "${data.aws_ami.aerospike_server_image.id}"
    vpc_security_group_ids      = ["${aws_security_group.server_sg.id}"]
    subnet_id                   = "${element(aws_subnet.public.*.id, count.index)}"
    key_name                    = "${var.key_name}"

    tags = {
        Name = "${var.project_name} Server"
        Project = "${var.project_name}"
        InventoryGroup = "server_instance"
    }
}
