$directory = Split-Path -Parent $MyInvocation.MyCommand.Path

# Create CI resources (IAM, S3, Policies)
& "$directory/EnvironmentSetup/CI_Setup/setup_travisagent_resources.sh"

# Create EC2 SSH key-pair
aws ec2 create-key-pair --key-name speakr.keypair > $directory/ec2_keypair.txt
aws s3 cp ec2_keypair.txt s3://speakr-keypairs
Write-Host "EC2 KeyPair saved to s3"

# Create Route53 Hosted Zone
aws route53 create-hosted-zone --name speakr.rocks --caller-reference speakr.rocks_01 > $directory/hosted_zone_info.json
$HostedZoneId = (Get-Content "$directory/hosted_zone_info.json" -Raw) | ConvertFrom-Json

# Boot up services stacks
& "$directory/aws_setup_all_stacks.ps1"

Write-Host "Please manually copy AWS Key and AWS Secret for TravisCI to your TravisCI environment"