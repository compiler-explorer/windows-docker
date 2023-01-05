
git clone https://github.com/compiler-explorer/compiler-explorer /compilerexplorer
cd /compilerexplorer

git checkout mg/pe32ts
git pull

npm i
npm run webpack
npm run ts-compile

xcopy "c:\compilerexplorer\out\webpack\static" "c:\compilerexplorer\out\dist\static"

Remove-Item -Path "c:\compilerexplorer\out\webpack" -Recurse
Remove-Item -Path "c:\compilerexplorer\node_modules" -Recurse

setx NODE_ENV production

npm i --no-audit --ignore-scripts --production

Remove-Item -Path "node_modules/.cache" -Recurse
Remove-Item -Path "node_modules/monaco-editor" -Recurse
Remove-Item -Path "node_modules" -Include "*.ts" -Recurse

node -r esm out/dist/app.js --version --dist
