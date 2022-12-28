


New-SmbMapping -GlobalMapping -LocalPath 'Z:' -RemotePath '\\172.30.0.29\winshared'

setx PATH "%PATH%;Z:/compilers/mingw-8.1.0/mingw64/bin"

setx NODE_ENV production

node --max_old_space_size=6000 -r esm -- out/dist/app.js --dev --dist
