
New-SmbMapping -GlobalMapping -LocalPath 'Z:' -RemotePath '\\172.30.0.29\winshared'

$DEPLOY_DIR = "/compilerexplorer"
$BUILD_NUMBER = $env:BUILD_NUMBER
$CE_ENV = $env:CE_ENV
$CE_USER = "ce"

Set-DefaultAWSRegion -Region us-east-1

function update_code {
    Write-Host "Current environment $CE_ENV"
    Invoke-WebRequest -Uri "https://s3.amazonaws.com/compiler-explorer/version/$CE_ENV" -OutFile "/tmp/s3key.txt"

    $S3_KEY = Get-Content -Path "/tmp/s3key.txt"

    # should not be needed, but just in case we copy pasted the file
    $S3_KEY = $S3_KEY -replace ".tar.xz","zip"

    get_released_code -URL "https://s3.amazonaws.com/compiler-explorer/$S3_KEY"
}

function get_released_code {
    param (
        $URL
    )

    Write-Host "Download build from: $URL"
    Invoke-WebRequest -Uri $URL -OutFile "/tmp/build.zip"

    Write-Host "Unzipping"
    New-Item -Path "./" -Name "compilerexplorer" -ItemType "directory" -Force
    Expand-Archive -Path "/tmp/build.zip" -DestinationPath $DEPLOY_DIR
}

update_code

# todo: this should be configured into the build
Write-Host "Installing properties files"
Copy-Item -Path "compiler-explorer.local.properties" -Destination "$DEPLOY_DIR/etc/config/compiler-explorer.local.properties"
Copy-Item -Path "c++.win32.properties" -Destination "$DEPLOY_DIR/etc/config/c++.win32.properties"
Copy-Item -Path "pascal.win32.properties" -Destination "$DEPLOY_DIR/etc/config/pascal.win32.properties"

function DenyAccessByCE {
    param (
        $Path
    )

    $ACL = Get-ACL -Path $Path
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("ce", "FullControl", "Deny")
    $ACL.AddAccessRule($AccessRule)
    $ACL | Set-Acl -Path $Path
}

function GeneratePassword {
    $pass = -join ((1..15) | %{get-random -minimum 33 -maximum 127 | %{[char]$_}}) + -join ((1..2) | %{get-random -minimum 33 -maximum 48 | %{[char]$_}}) -replace "c","" -replace "e", "" -replace "C","" -replace "E", "";
    $securePassword = ConvertTo-SecureString $pass -AsPlainText -Force;
    return $securePassword;
}

function RecreateUser {
    Param(
        $securePassword
    )

    $exists = (Get-LocalUser $CE_USER -ErrorAction Ignore) -as [bool];
    if ($exists) {
        Remove-LocalUser $CE_USER;
    }

    New-LocalUser -User $CE_USER -Password $securePassword -PasswordNeverExpires -FullName "CE" -Description "Special user for running Compiler Explorer";
    Add-LocalGroupMember -Group "Users" -Member $CE_USER;
}

function GetConf {
    Param(
        $Name
    )

    return (Get-SSMParameterValue -Name $Name).Parameters.Value;
}

function GetLogHost {
    return GetConf -Name "/compiler-explorer/logDestHost";
}

function GetLogPort {
    return GetConf -Name "/compiler-explorer/logDestPort";
}

function CreateCredAndRun {
    $pass = GeneratePassword;
    RecreateUser $pass;
    $credential = New-Object System.Management.Automation.PSCredential($CE_USER,$pass);
    # DenyAccessByCE -Path "C:\Program Files\Grafana Agent\agent-config.yaml"

    $nodeargs = ("--max_old_space_size=6000","-r","esm","--","app.js","--dist","--logHost",(GetLogHost),"--logPort",(GetLogPort),"--env","ecs","--env","win32","--language","c++,pascal")
    Write-Host "Starting node with args " $nodeargs

    $psi = New-object System.Diagnostics.ProcessStartInfo 
    $psi.CreateNoWindow = $true 
    $psi.UseShellExecute = $false 
    $psi.UserName = $credential.UserName
    $psi.Password = $credential.Password
    $psi.RedirectStandardOutput = $true 
    $psi.RedirectStandardError = $true
    $psi.WorkingDirectory = Get-Location
    $psi.FileName = "node.exe"
    $psi.Arguments = $nodeargs
    $psi.EnvironmentVariables["NODE_ENV"] = "production"
    $psi.EnvironmentVariables["PATH"] = "$env:PATH;Z:/compilers/mingw-8.1.0/mingw64/bin"

    Write-Host "Created ProcessStartInfo thing"
    
    $process = New-Object System.Diagnostics.Process 
    $process.StartInfo = $psi 
    
    Write-Host "Going to start the process"
    
    [void]$process.Start()
    $output = $process.StandardOutput.ReadToEnd() 
    $err = $process.StandardError.ReadToEnd() 
    Write-Host "Waiting"
    $process.WaitForExit() 
    Write-Host "Done waiting, output:"
    Write-Host $output
    Write-Host "err:"
    Write-Host $err
    Write-Host "The End"
}

Set-Location -Path $DEPLOY_DIR

CreateCredAndRun
