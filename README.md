Aerospike AWS Benchmark
================================================================================

This project consists of automation to build out an Aerospike cluster on AWS
for the purposes of benchmarking a workload on EC2 instances. The toolchain is
Packer, Terraform, and Ansible.

This is based on Aerospike Server Enterprise so a feature key file (`features.conf`)
us required. 

* Packer - builds AMIs for Aerospike Server and Aerospike Java Client (benchmark tool)
* Terraform - provisions AWS resources setup for quick testing
* Ansible - configures (and re-configures) the instances


Quick Start
--------------------------------------------------------------------------------

### Build Images

Use `packer build` from the `packer/` directory to build the AMIs for a specific
version of Aerospike and Java Client (optional as existing images are public):

```
cd packer
packer build -var 'server_version=4.8.0.8' -var 'client_version=4.4.10' benchmark-images.json
```


### Provision Instances

Use `terraform apply` in the `terraform/` directory to deploy the instances
using variables defined in a `.tfvars` file:

```
cd terraform
terraform apply -var-file=clusters/benchmark-2AZ-amzn2.tfvars -var='key_name=micahcarrick'
```

### Configure Instances

Run `generate-certs.sh` in the `ansible/` directory to generate TLS certificates
into the `files/` directory.

```
cd ansible
./generate-certs.sh
```

Copy your `features.conf` file to the `ansible/files/` directory:

```
cp /path/to/features.conf files/
```

SSH into server instance and tail logs:

```
ssh ec2-user@[aerospike instance PUBLIC IP]
journalctl -u aerospike -f
```

From the `ansible/` directory, run `ansible-playbook` to configure the Aerospike
server node(s):

```
ansible-playbook -i inventory/aws_ec2.yml aerospike-server.yml -u ec2-user
```

From the `ansible/` directory, run `ansible-playbook` to configure the Benchmark
client node(s):

```
ansible-playbook -i inventory/aws_ec2.yml benchmark-client.yml -u ec2-user
```

SSH into client instance and run benchmarks from the 
`aerospike-client-java/benchmarks` directory:

```
ssh ec2-user@[client instance PUBLIC IP]
cd aerospike-client-java/benchmarks

java -jar target/aerospike-benchmarks-*-jar-with-dependencies.jar \
-h [client instance PRIVATE IP]:3000 -n test \
[your benchmark parameters]
```

Benchmarking TLS
--------------------------------------------------------------------------------

Edit `ansible/aerospike-server.yml` to enable TLS:

* `service_tls: true`
* `fabric_tls: true`
* `heartbeat_tls: true`

If not using mutual TLS:

* `tls_authenticate_client: false`

From the `ansible/` directory, re-run `ansible-playbook` to update the
configuration on each of the Aerospike server node(s):

```
ansible-playbook -i inventory/aws_ec2.yml aerospike-server.yml
```

SSH into client instance and run benchmarks from the 
`aerospike-client-java/benchmarks` directory:

```
ssh ec2-user@[client instance PUBLIC IP]
cd aerospike-client-java/benchmarks
```

For standard TLS:

```
java -Djavax.net.ssl.trustStore=aerospike.ca.jks \
-jar target/aerospike-benchmarks-*-jar-with-dependencies.jar \
-h [client instance PRIVATE IP]:aerospike.server:3000 -tls -n test \
[your benchmark parameters]
```

For mutual TLS:

```
java -Djavax.net.ssl.trustStore=aerospike.ca.jks \
-Djavax.net.ssl.keyStore=aerospike.client.jks \
-Djavax.net.ssl.keyStorePassword=changeit \
-jar target/aerospike-benchmarks-*-jar-with-dependencies.jar \
-h [client instance PRIVATE IP]:aerospike.server:3000 -tls -n test \
[your benchmark parameters]
```


Additional Tips
--------------------------------------------------------------------------------

Terraform adds an `InstanceGroup` tag to all instances which is what Ansible
uses for the dynamic inventory. To verify what those instances should be use
`ec2 describe-instances`:

```
aws ec2 describe-instances --region=us-west-2 --filter "Name=tag:Project,Values=Aerospike Benchmark" "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].{Instance:InstanceId,IP:PublicIpAddress,Project:Tags[?Key=='Project']|[0].Value,InventoryGroup:Tags[?Key=='InventoryGroup']|[0].Value}" --output table
```

To verify Ansible sees that inventory as expected, use `ansible-inventory`:

```
ansible-inventory -i inventory/aws_ec2.yml --graph
```

To see all the host variables that could be used in the configuration template,
use `-m setup` (specify `ec2-user` since this is outside of the playbook):

```
ansible -i inventory/aws_ec2.yml server_instance -m setup -u ec2-user
```

Tasks are tagged as wither "config" or "certs". When updating the configuration
template use `--tags` and `--check` to only run the config tasks and do a dry
run to review how the template is rendered:

```
ansible-playbook -i inventory/aws_ec2.yml aerospike-server.yml --tags "config" --check
```