Param(
    [Parameter()]
    [string]
    $region = "eu-west-1",

    [Parameter()]
    [string]
    $route53DnsName = "db.speakr.rocks."
)

Import-Module AWSPowerShell

function Generate-RandomPassword ($length = 15)
{
    $punc = 46..46
    $digits = 48..57
    $letters = 65..90 + 97..122

    # Thanks to
    # https://blogs.technet.com/b/heyscriptingguy/archive/2012/01/07/use-pow
    $password = get-random -count $length `
        -input ($punc + $digits + $letters) |
            % -begin { $aa = $null } `
            -process {$aa += [char]$_} `
            -end {$aa}

    return $password
}

function _LaunchCloudFormationStack
{
    Write-Host "Creating CloudFormation Stack for RDS - DB Speakr.Rocks"

    $templatePath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, "./cloudformation.template"))
    $templateBody = [System.IO.File]::ReadAllText($templatePath)

    $databasePassword = Generate-RandomPassword 15

    $MasterUserPassword = New-Object -TypeName Amazon.CloudFormation.Model.Parameter
    $MasterUserPassword.ParameterKey = "MasterUserPassword" 
    $MasterUserPassword.ParameterValue = $databasePassword

    $param2 = New-Object -TypeName Amazon.CloudFormation.Model.Parameter
    $param2.ParameterKey = "Route53DNSName" 
    $param2.ParameterValue = $route53DnsName

    $cloudformationParameters = $MasterUserPassword, $param2

    $deploymentGroupId = New-CFNStack -StackName "db-speakr-rocks" -Capability "CAPABILITY_IAM" -Parameter $cloudformationParameters -TemplateBody $templateBody -Region $region


    _GiveUserFeedbackOnStackCreation $deploymentGroupId

    $returnPassword = ("Password: " + $databasePassword)
    return $returnPassword
}

function _GiveUserFeedbackOnStackCreation([string]$stackId)
{
    $stack = Get-CFNStack -StackName $stackId -Region $region

    while ($stack.StackStatus.Value.toLower().EndsWith('in_progress'))
    {
        $stack = Get-CFNStack -StackName $stackId -Region $region
        "Waiting for CloudFormation Stack to be created"
        Start-Sleep -Seconds 10
    }

    if ($stack.StackStatus -ne "CREATE_COMPLETE") 
    {
        "CloudFormation Stack was not successfully created, view the stack events for further information on the failure"
        Exit
    }

    $serviceRoleARN = ""
    $appServerDNS = ""

    ForEach($output in $stack.Outputs)
    {
        if($output.OutputKey -eq "CodeDeployTrustRoleARN")
        {
            $serviceRoleARN = $output.OutputValue
        }
        elseif($output.OutputKey -eq "WebServerInstanceDNS")
        {
            $appServerDNS = $output.OutputValue        
        }
        elseif($output.OutputKey -eq "DomainName")
        {
            $domainName = $output.OutputValue        
        }
    }
}

_LaunchCloudFormationStack