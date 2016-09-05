Param(
    [Parameter(mandatory=$true)]
    [string]
    $appName,

    [Parameter()]
    [string]
    $region = "eu-west-1"
)

function _deleteStack()
{
    $stack = Get-CFNStack -StackName ("speakr-{0}" -f $appName) -Region $region | Where-Object {$_.StackName -eq ("speakr-{0}" -f $appName)}
    if($stack -ne $null)
    {
        Write-Host "Deleting CloudFormation existing stack"
        Remove-CFNStack $stack.StackName -Region $region -Force
    }
}

function _deleteCodeDeployPrimitives()
{
    $applications = Get-CDApplicationList -Region $region | Where-Object {$_.StartsWith(("speakr-{0}" -f $appName))}
    foreach($application in $applications)
    {
        $deploymentGroups = Get-CDDeploymentGroupList -ApplicationName $application -Region $region 
        foreach($deploymentGroup in $deploymentGroups.DeploymentGroups)
        {
            Write-Host ("Deleting Deployment Group " + $deploymentGroup)
            Remove-CDDeploymentGroup -ApplicationName $application -Region $region -DeploymentGroupName $deploymentGroup -Force 
        }

        Write-Host ("Deleting CodeDeploy Application " + $application)
        Remove-CDApplication -ApplicationName  $application -Region $region -Force
    }
}

_deleteCodeDeployPrimitives
_deleteStack