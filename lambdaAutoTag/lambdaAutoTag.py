import boto3

def lambda_handler(event, context):

    #-------------------- Debug ---------------------------
    #print( 'Hello  {}'.format(event))
    #print( 'User Name- {}'.format(event['detail']['userIdentity']['principalId']))
    #print( 'Instance ID- {}'.format(event['detail']['responseElements']['instancesSet']['items'][0]['instanceId']))
    
    # Variables
    instanceId = event['detail']['responseElements']['instancesSet']['items'][0]['instanceId']
    userNameSTring = event['detail']['userIdentity']['principalId'] 
    
    # Checks if the user is an okta user
    if ":" in userNameSTring:
        userName  = userNameSTring.split(":")[1]
    else:
        userName  = event['detail']['userIdentity']['userName']  
        
    
    print( 'Instance Id - ' , instanceId)
    print( 'User Name - ' , userName)
    
    
    tagKey = 'owner'
    tagValue = userName
    
    # ---------------------- Body  ---------------------- 
    
    # EC2 tagging
    client = boto3.client('ec2')
    response = client.create_tags(
        Resources=[
            instanceId
        ],
        Tags=[
            {
                'Key': tagKey,
                'Value': tagValue
            },
        ]
    )
    
    # Volume tagging
    ec2 = boto3.resource('ec2')
    instance = ec2.Instance(instanceId)
    volumes = instance.volumes.all()
    for volume in volumes:
        volID = volume.id
        print("volume - " , volID)
        volume = ec2.Volume(volID)
        tag = volume.create_tags(
            Tags=[
                {
                'Key': tagKey,
                'Value': tagValue
                },
            ]
        )

    print(response)