$directory = Split-Path -Parent $MyInvocation.MyCommand.Path

# Create database (MySQL RDS)
& "$directory/EnvironmentSetup/database_setup/rds_setup.ps1" > $databasePassword

Write-Host "Please manually copy the following password to your TravisCI Environment: Database password: " $databasePassword