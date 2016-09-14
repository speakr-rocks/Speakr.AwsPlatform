Import-Module AWSPowerShell

(Get-EC2SecurityGroup -Region eu-west-1) | ? {$_.Tag.Key -eq "SecurityGroupIdentifier" -and $_.Tag.Value -eq "ec2-to-db-speakr-rocks"} | Select GroupName