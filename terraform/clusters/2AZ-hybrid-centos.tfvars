# Deploy infrastructure for a 2-node cluster (1 node in each AZ) intended to be
# used for a hybrid memory Aerospike cluster (has local SSDs).

aerospike_instance_count = 2
aerospike_instance_type = "m5d.12xlarge"

client_instance_count = 6
client_instance_type = "m5.xlarge"

ami_owner = "696609415687"
client_ami_name = "aerospike-benchmark-client-*-centos7-*"
server_ami_name = "aerospike-benchmark-server-*-centos7-*"