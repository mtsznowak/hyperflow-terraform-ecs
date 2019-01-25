# HyperFlow deployment on Amazon ECS

This project contains infrustructure configuration files for deployment of HyperFlow and workflows on Amazon ECS/EC2 + Docker with autoscaling. The project structure is as follows:
 
- grafana/ - description of the monitoring services
- infrastructure/ - contains definition of the master ec2 instance, ecs clusters and more:

   - main.tf - definition of master ec2 instances, cluster lunch configuration for new instances and cluster name
   - alarms.tf - alarm definitions
   - autoscaling_policy.tf - auto scaling policy for aws instance and auto scaling policy for services
   - security_group.tf - definition of security groups for iam instances
   - tasks_and_services.tf - definition of task for master and worker container, definition of 2 services one to manage master task and one form managing worker tasks
   - variables_const.tf - definitions of variables that usually will be not changed by user
   - variables.tf - definitions of variables that should be changed by user according to their needs
   - iam.tf - [Iam roles, profiles, policy](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/IAM_policies.html), IAM role specifies the permissions.
   - output.tf - return dns address to master node
   - task-hyperflow-master.json and task-hyperflow-worker.json contain templates of task definitions. Based on those definitions, ECS will start new containers with appropriate environment variables.
- runner/ decription of uploads files to S3 bucket and the ec2 instance that runs the workflow

# User Variables
The most important variables from the user perspective are defined in the infrastructure/variables.tf file

- ecs_cluster_name - name of cluster that will be created
- launch_config_instance_type - ([EC2 instance types](https://aws.amazon.com/ec2/instance-types/)) to be used, e.g. t2.micro, t2.small, etc. 
- asg_min - minimum number of instances of EC2 in auto scaling group
- asg_max - maximum number of instances of EC2 in auto scaling group
- asg_desired - desired number of instances of EC2 after initialization of cluster

The master machine is outside the auto scaling group, so it is possible to set asg_min=0
 
- ecs_ami_id - id of dedicated and optimized ami for lunching container instances, [every region have different ami id](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html). It is also possible to create and use own ami.

|Region            | AMI ID      |
|------------------|-------------|
|us-east-2         |ami-1b90a67e |   
|us-east-1         |ami-cb17d8b6 |
|us-west-2         |ami-05b5277d |
|us-west-1         |ami-9cbbaffc |
|eu-west-3         |ami-914afcec |
|eu-west-2         |ami-a48d6bc3 |
|eu-west-1         |ami-bfb5fec6 |
|eu-central-1      |ami-ac055447 |
|ap-northeast-2    |ami-ba74d8d4 |
|ap-northeast-1    |ami-5add893c |
|ap-southeast-2    |ami-4cc5072e |
|ap-southeast-1    |ami-acbcefd0 |
|ca-central-1      |ami-a535b2c1 |
|ap-south-1        |ami-2149114e |
|sa-east-1         |ami-d3bce9bf |

 
- key_pair_name - name of key used to connect to ec2 instance with ssh, it is optional
- ACCESS_KEY - access key used by executor to communicate with S3
- SECRET_ACCESS_KEY - secret access key used by executor to communicate with S3
- ec2_instance_scaling_adjustment - numbers of ec2 instances that should be added or removed with corresponding alarm
- worker_scaling_adjustment - numbers of workers that should be added or removed with corresponding alarm
- hyperflow_master_container - master container containing rabbitmq
- hyperflow_worker_container - worker container containing selected version on executor

# Step by step instruction: deployment and running Montage workflow on Amazon ECS

1. Prepare an ECS user with the following roles:
    * AmazonEC2FullAccess 
    * AmazonS3FullAccess 
    * AmazonECS_FullAccess
    * IAMFullAccess

    It is also posible to use an Administrator IAM user.  

2. Setup the monitoring service machine (Grafana and InfluxDB)
```
cd grafana
terraform init
terraform apply
```

3. Prepare Montage data 
  
Download data example to be procesed: https://s3.amazonaws.com/hyperflowdataexample/data_examples.zip

```
wget https://s3.amazonaws.com/hyperflowdataexample/data_examples.zip
unzip -a data_examples.zip
```

4. Create the infrastructure

```
cd infrastructure
terraform init
terraform apply -var ‘ACCESS_KEY=XXXXXXXXXXXXXXXXX’ -var ‘SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx’
```

Optional variables:
- `-var 'influx_url=http://<influx_url>:8086/hyperflow_tests'` - provide this variable to use different instance of Grafana and InfluxDB
- `-var 'feature_download=ENABLED'` - (additional feature) executor will not remove downloaded files after finishing task. Executor will check if file was already downloaded to reduce download time.

5. Run the workflow 

```
cd runner
terraform init
terraform apply -var 'ACCESS_KEY=XXXXXXXXXXXXXXXX' -var 'SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' -var 'JOB_DIRECTORY=/PATH/TO/THE/JOB/FILES' -var 'BUCKET_NAME=terraform-3344'
```

`JOB_DIRECTORY` should be a path to the direcory containing the description and input files of the workflow. The directory is expected to contain `workdir/` (with `dag.json`) and `input/` subdirectories, which will be uploaded to the new S3 bucket with the given name - `BUCKET_NAME`. 

Optional variables:
- `-var 'METRIC_COLLECTOR=http:/<influx_db>:8086/hyperflow_tests'` - provide this variable to use different instance of Grafana and InfluxDB
- `-var 'AMQP_URL='amqp://<rabbit_mq>:5672'` - specify to use different AMQP node
- `-var 'CONTAINER=container_name'` - (additional feature) can be passed to use separate container for the task execution


6. Destroy the infrastructure

   run `terraform destroy` in `grafana/`, `infrastructure/` and `runner/`.
