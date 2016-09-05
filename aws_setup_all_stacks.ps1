$directory = Split-Path -Parent $MyInvocation.MyCommand.Path

$components = "$directory/Components"

Get-ChildItem "$components" -Directory | 
Foreach-Object {
    & "$components/$_/EnvironmentSetup.ps1" "$_"
}