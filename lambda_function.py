
import boto3
from collections import defaultdict
from prettytable import PrettyTable

#Connect to EC2

ec2 = boto3.resource('ec2',region_name='us-east-1')

def lambda_handler(event, context):  
        running_instances = ec2.instances.filter(
    Filters=[{
        'Name': 'instance-type',
        'Values': ['m5.large']
        },
        {
        'Name': 'vpc-id',
        'Values': ['<default-vpc-id>']
        }]
    )

L=[]
M=[]
ec2info = defaultdict()
for instance in running_instances:
    for tag in instance.tags:
        if 'Name'in tag['Key']:
            name = tag['Value']
    # Add instance info to a dictionary         
    ec2info[instance.id] = {
        'Name': name,
        'Type': instance.instance_id
        }
    L.append(name)
    M.append(instance.instance_id)

# Format output in table from

table = PrettyTable(['Name Tag', 'Instance ID'])
for i in range(len(L)):
  table.add_row([L[i], M[i]])
print(table)


