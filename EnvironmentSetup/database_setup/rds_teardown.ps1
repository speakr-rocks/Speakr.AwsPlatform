Param(
    [Parameter()]
    [string]
    $appName = "db-speakr-rocks",

    [Parameter()]
    [string]
    $region = "eu-west-1"
)

function _deleteStack()
{
    $stack = Get-CFNStack -StackName $appName -Region $region | Where-Object {$_.StackName -eq $appName}
    if($stack -ne $null)
    {
        Write-Host "Deleting CloudFormation existing stack"
        Remove-CFNStack $stack.StackName -Region $region -Force
    }
}

_deleteStack