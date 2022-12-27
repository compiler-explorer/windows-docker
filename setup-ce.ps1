
git clone https://github.com/compiler-explorer/compiler-explorer /compilerexplorer
cd /compilerexplorer

git checkout main
git pull

npm i
npm run webpack
npm run ts-compile

xcopy "c:\compilerexplorer\out\webpack\static" "c:\compilerexplorer\out\dist\static"

node -r esm out/dist/app.js --version --dist
