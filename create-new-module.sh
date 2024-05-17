#!/bin/bash

# Check if module name is provided
if [ -z "$1" ]
then
    echo "No module name provided. Usage: ./script.sh <module_name>"
    exit 1
fi

# Define the module name
module_name=$1

# Define the template and output file paths
template_path="./.github/workflows/avm.template.workflow.yml"
output_path="./.github/workflows/avm.${module_name}.yml"

# Copy the template to the new file
cp $template_path $output_path

# Replace the necessary parts in the new file
escaped_module_name=$(echo $module_name | sed 's/\./\\./g')
sed -i '' "s/avm\\.res\\.app\\.job/avm\\.$escaped_module_name/g" $output_path
sed -i '' "s/avm\\/res\\/app\\/job/avm\\/"$(echo $module_name | tr '.' '/' | sed 's/\//\\\//g')"/g" $output_path

