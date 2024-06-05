dotnet publish . --configuration Release -o Artifacts --self-contained false
Get-ChildItem -Path ./Artifacts/ -Force | Compress-Archive -DestinationPath .\functionApp.zip -Force
rm -rf ./Artifacts/