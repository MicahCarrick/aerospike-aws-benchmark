# Deploy infrastructure for a 3-node cluster (1 node in each AZ).

aerospike_instance_count = 3
aerospike_instance_type = "m5.8xlarge" # use 'm5d' for storage-engine=device
client_instance_count = 1
client_instance_type = "t3.large"