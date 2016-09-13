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

function _CreateCloudformation
{
    $databasePassword = Generate-RandomPassword 15


    $templatePath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, "./cloudformation.template"))
    $templateBody = [System.IO.File]::ReadAllText($templatePath)


    $MasterUserPassword = New-Object -TypeName Amazon.CloudFormation.Model.Parameter
    $MasterUserPassword.ParameterKey = "MasterUserPassword" 
    $MasterUserPassword.ParameterValue = $databasePassword


    New-CFNStack -StackName "db-speakr-rocks" -Capability "CAPABILITY_IAM" -Parameter $MasterUserPassword -TemplateBody $templateBody -Region "eu-west-1" 

    return $databasePassword
}

_CreateCloudFormation