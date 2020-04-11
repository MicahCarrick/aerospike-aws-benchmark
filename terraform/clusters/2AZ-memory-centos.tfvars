# Deploy infrastructure for a 2-node cluster (1 node in each AZ).

aerospike_instance_count = 2
aerospike_instance_type = "m5.xlarge"

client_instance_count = 4
client_instance_type = "m5.large"

ami_owner = "696609415687"
client_ami_name = "aerospike-benchmark-client-*-centos7-*"
server_ami_name = "aerospike-benchmark-server-*-centos7-*"