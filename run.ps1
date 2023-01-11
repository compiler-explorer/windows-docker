

New-SmbMapping -LocalPath 'Z:' -RemotePath '\\172.30.0.29\winshared'

$env:PATH = "$env:PATH;Z:/compilers/mingw-8.1.0/mingw64/bin"
$env:NODE_ENV = "production"

$DEPLOY_DIR = "/compilerexplorer"
$BUILD_NUMBER = $env:BUILD_NUMBER
$CE_ENV = $env:CE_ENV

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

Write-Host "Starting..."

Set-Location -Path $DEPLOY_DIR

# todo: language limit should be configured into the build
node --max_old_space_size=6000 -r esm -- app.js --dist --env ecs --env win32 --language "c++,pascal"
