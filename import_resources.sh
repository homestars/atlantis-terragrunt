#!/bin/bash
resources_file=resources.yaml
if [ -f "$resources_file" ];
then
  state_list="$(terragrunt state list)"
  if [ $? -eq 1 ]; then state_list=''; fi
  while IFS= read -r line
  do
    resource_name="$(echo $line | cut -d':' -f 1)"
    resource_id="$(echo $line | cut -d':' -f 2-)"
    if [[ "$state_list" =~ .*"$resource_name".* ]];  then
      echo "Skip importing as state of $resource_name already exists"
    else
      terragrunt import $resource_name $resource_id
      if [ $? -eq 0 ]; then echo "$resource_name is imported"; else echo "$resource_name is not imported" ; fi
    fi
  done < resources.yaml
else
  echo "No resources to import"
fi
