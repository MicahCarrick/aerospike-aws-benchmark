output "aerospike_nodes" {
    value = {
        for instance in aws_instance.aerospike_server:
        instance.availability_zone => "${instance.public_ip} (${instance.private_ip})"
    }
}

# Output the SSH command used to login to each EC2 instance
output "client_nodes" {
    value = {
        for instance in aws_instance.benchmark_client:
        instance.availability_zone => "${instance.public_ip} (${instance.private_ip})"
    }
}
