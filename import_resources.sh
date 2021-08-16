#!/bin/bash
resources_file=resources.yaml
if [ -f "$resources_file" ];
then
  state_list=$(terragrunt state list)
  if [ $? -eq 1 ]; then state_list=''; fi
  while IFS= read -r line
  do
    resource_name="$(echo $line | cut -d':' -f 1)"
    resource_id="$(echo $line | cut -d':' -f 2)"
    if echo $state_list | grep -q $resource_name;  then
      echo "Skip importing $resource_name as the state already exists"
    else
      terragrunt import $resource_name $resource_id
      echo "$resource_name is imported"
    fi
  done < resources.yaml
else
  echo "No resources to import"
fi
