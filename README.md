# Three Tier Deployment on AWS
## _Deployment of EC2 with RDS in private subnet served by a load balancer_


# online-challenge

The 3 tier template code comprises of below scripts:-

###### a. config file "Config.file" where parameters are defined like name of the stacks (DB specific parrameters,CIDR blocks,Instance specific parameters can also be put in here)
###### b. ec2.yaml file to launch EC2 instances in private subnet 
###### c. create-rds-secret-manager file to create RDS in private subnet with credentials being managed by secret manager
###### d. aws-deploy.sh file which when called through an EC2 instance ( having aws cli installed ) runs the above three stacks in order and create an Ec2 instance with a RDS in 3 tier architecture

### Shortcoming:

###### 1- The ELB was created using AWS CLI when the same could have been through CFT
###### 2- An EC2 acting as bastion server needs creation in public subnet which is missing
###### 3- Security groups should be created in CFT as of now I have added one as parameter in config file

