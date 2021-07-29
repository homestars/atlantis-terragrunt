#!/bin/bash
resources_file=resources.yaml
if [ -f "$resources_file" ];
then
  while IFS= read -r line
  do
    resource_name="$(echo $line | cut -d':' -f 1)"
    resource_id="$(echo $line | cut -d':' -f 2)"
    terraform import $resource_name $resource_id
  done < resources.yaml
else
  echo "No resources to import"
fi
