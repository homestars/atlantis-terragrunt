#!/bin/bash
resources_file=resources.yaml
if [ -f "$resources_file" ];
then
  while IFS= read -r line
  do
    resource_name="$(echo $line | cut -d':' -f 1)"
    resource_id="$(echo $line | cut -d':' -f 2)"
    if [[ -z $(terragrunt state list $resource_name) ]];  then
      terragrunt import $resource_name $resource_id
    else
      echo "Skip importing $resource_name as the state already exists"
    fi
  done < resources.yaml
else
  echo "No resources to import"
fi
