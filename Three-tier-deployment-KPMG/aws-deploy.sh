#!/bin/bash
source ./config.file
# Create a wait function to let the stack complete before proceeding to next step


function wait_stack () {
	
        echo  "### Waiting for create-stack command to complete"

        CREATE_STACK_STATUS=$(aws cloudformation describe-stacks --stack-name  $1 --query 'Stacks[0].StackStatus' --output text --profile ${profileName})
        while [[ $CREATE_STACK_STATUS == "REVIEW_IN_PROGRESS" ]] || [[ $CREATE_STACK_STATUS == "CREATE_IN_PROGRESS" ]] || [[ $CREATE_STACK_STATUS == "ROLLBACK_IN_PROGRESS" ]] || [[ $CREATE_STACK_STATUS == "UPDATE_IN_PROGRESS" ]] || [[ $CREATE_STACK_STATUS == "UPDATE_ROLLBACK_IN_PROGRESS" ]] || [[ $CREATE_STACK_STATUS == "UPDATE_COMPLETE_CLEANUP_IN_PROGRESS" ]]
        do
            # Wait 10 seconds and then check stack status again
            sleep 10
            CREATE_STACK_STATUS=$(aws cloudformation describe-stacks --stack-name  $1 --query 'Stacks[0].StackStatus' --output text --profile ${profileName})
            echo "***"
        done
       	if [[ $CREATE_STACK_STATUS == "CREATE_COMPLETE" ]]
       	then
       		echo  "### Stack $1 creation completed succesfully"
       	else
       		echo  "### There was a problem during Stack $1 creation, please check the cloudformation logs on AWS console"
       	fi

}

# Create stack for VPC along with public and private subnet

aws cloudformation create-stack --template-body file://multi-tier.yaml --stack-name ${vpcstack}

wait_stack ${vpcstack}

# Fetch value of subnets from stack output to be used in the script below

publicsubnet1=$(aws cloudformation describe-stacks --stack-name ${vpcstack} --query "Stacks[0].Outputs[?OutputKey=='oTier1Subnet1'].OutputValue" --output text --region $region )

publicsubnet2=$(aws cloudformation describe-stacks --stack-name ${vpcstack} --query "Stacks[0].Outputs[?OutputKey=='oTier1Subnet2'].OutputValue" --output text --region $region )

privatesubnet1=$(aws cloudformation describe-stacks --stack-name ${vpcstack} --query "Stacks[0].Outputs[?OutputKey=='oTier2Subnet1'].OutputValue" --output text --region $region )

privatesubnet2=$(aws cloudformation describe-stacks --stack-name ${vpcstack} --query "Stacks[0].Outputs[?OutputKey=='oTier2Subnet2'].OutputValue" --output text --region $region )

# Create stack for EC2 to be deployed in public subnets

aws cloudformation create-stack --template-body file://ec2.yaml \
        --stack-name ${ec2stack} \
        --parameters \
			ParameterKey=Subnets,ParameterValue=\"${privatesubnet1},${privatesubnet2}\" \

wait_stack ${ec2stack} 


# Create a subnet group default for RDS deployment

aws rds create-db-subnet-group \
    --db-subnet-group-name default \
    --db-subnet-group-description " DB subnet group" \
    --subnet-ids '[${privatesubnet1},${privatesubnet2}]'
# Create serverless RDS to be deployed in default subnet group which has private subnets

aws cloudformation create-stack --template-body file://create-rds-secretmanager.json \
        --stack-name ${rdsstack} 
        
wait_stack ${rdsstack} 

# create a load balancer for EC2

aws elb create-load-balancer --load-balancer-name ${lbname} --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80" \
		--subnets ${privatesubnet1},${privatesubnet2} --security-groups ${sg}
	
# extract instance ID of the EC2 created	
instanceid=`aws autoscaling describe-auto-scaling-instances myASG| grep "InstanceId"| cut -d ":" -f2|sed 's/[^A-Za-z0-9_.;]//g'`

#add ec2 to load balancer
aws elb register-instances-with-load-balancer --load-balancer-name ${lbname} --instances ${instanceid}