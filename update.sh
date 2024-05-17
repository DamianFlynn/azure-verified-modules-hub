#!/bin/bash
rm -rf bicep-registry-modules
git clone https://github.com/Azure/bicep-registry-modules.git

# Copy the .github folder from the bicep-registry-modules repo to the current repo
src="bicep-registry-modules/.github/"
dest=".github/"

rsync -av --exclude='avm.res*' --exclude='avm.ptn*' "$src" "$dest"

# Copy the .vscode folder from the bicep-registry-modules repo to the current repo
src="bicep-registry-modules/.vscode/"
dest=".vscode/"

rsync -av "$src" "$dest"

# Copy the .vscode folder from the bicep-registry-modules repo to the current repo
src="bicep-registry-modules/avm/utilities"
dest="avm"
mkdir -p "$dest"
rsync -av  "$src" "$dest"
mkdir -p avm/res
mkdir -p avm/ptn

rm -rf bicep-registry-modules

