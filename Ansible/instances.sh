aws ssm describe-instance-information \
    --output json \
    --query "InstanceInformationList[*].InstanceId" | \
jq -r '.[]' | \
xargs -I {} aws ec2 describe-instances \
    --instance-ids {} \
    --query "Reservations[*].Instances[*].{
        InstanceId:InstanceId,
        Name:Tags[?Key=='Name'].Value|[0],
        Service:Tags[?Key=='Service'].Value|[0],
        Type:Tags[?Key=='Type'].Value|[0],
        Environment:Tags[?Key=='Environment'].Value|[0],
        IP:PrivateIpAddress
    }" \
    --output json 2>/dev/null | \
jq -s 'flatten | sort_by(.IP) | [.[] | { Name, InstanceId, IP, Service, Type, Environment }]' > instances.json
