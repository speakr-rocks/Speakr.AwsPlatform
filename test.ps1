$directory = Split-Path -Parent $MyInvocation.MyCommand.Path

# Create database (MySQL RDS)
"Username: dbadmin`n" > $directory/db_password.txt
& "$directory/EnvironmentSetup/database_setup/rds_setup.ps1" >> $directory/db_password.txt
aws s3 cp db_password.txt s3://speakr-keypairs
Write-Host "DB Password saved to s3"