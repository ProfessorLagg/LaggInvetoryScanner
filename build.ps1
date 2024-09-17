$WoWDir = "C:\Games\WotLK-Whitemane-enUS"

$AddOnDir = Join-Path -Path $WoWDir -ChildPath "Interface\AddOns\LaggInvetoryScanner"

if(-not [System.IO.Directory]::Exists($AddOnDir)){
    [System.IO.Directory]::CreateDirectory($AddOnDir) | Out-Null
}

$srcDir = Join-Path -Path $PSScriptRoot -ChildPath "AddOn"

&robocopy "$srcDir" "$AddOnDir" /mir
# \WTF\Account\PROFESSORLAGG\SavedVariables