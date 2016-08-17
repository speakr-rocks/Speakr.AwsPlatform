aws iam create-user --user-name Travis-CI
aws iam attach-user-policy --policy-arn arn:aws:iam::aws:policy/AWSCodeDeployDeployerAccess --user-name Travis-CI

aws s3 mb s3://speakr-travisbuilds
aws s3api put-bucket-policy --bucket speakr-travisbuilds --policy file://EnvironmentSetup/CI_Setup/s3-speakr-travisbuilds_permissions.json