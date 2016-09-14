$directory = Split-Path -Parent $MyInvocation.MyCommand.Path


# Create CI resources (IAM, S3, Policies)
& "$directory/EnvironmentSetup/ci_setup/setup_travisagent_resources.sh"


# Create EC2 SSH key-pair
aws ec2 create-key-pair --key-name speakr.keypair --output text > $directory/ec2_keypair.pem
aws s3 cp ec2_keypair.pem s3://speakr-keypairs
Write-Host "EC2 KeyPair saved to s3"


# Create Route53 Hosted Zone
aws route53 create-hosted-zone --name speakr.rocks --caller-reference speakr.rocks_01 > $directory/hosted_zone_info.json
$HostedZoneId = (Get-Content "$directory/hosted_zone_info.json" -Raw) | ConvertFrom-Json


# Create database (MySQL RDS)
"Username: dbadmin`n" > $directory/db_password.txt
& "$directory/EnvironmentSetup/database_setup/rds_setup.ps1" >> $directory/db_password.txt
aws s3 cp db_password.txt s3://speakr-keypairs

Write-Host "DB Password saved to s3"


# Boot up services stacks
& "$directory/aws_setup_all_stacks.ps1"


# Final Instructions to user:
Write-Host "Please manually copy AWS Key and AWS Secret for TravisCI to your TravisCI environment"