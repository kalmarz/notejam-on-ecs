#!/bin/bash

set -e

source_path="$1" 
repository_url="$2"
tag="${3:-latest}" # checks if 3rd argument exists, if not, use "latest"

# splits string using '.' and picks 4th item: the aws region
region="$(echo "$repository_url" | cut -d. -f4)"

# splits string using '/' and picks 2nd item: the image name
image_name="$(echo "$repository_url" | cut -d/ -f2)" 

# builds the image
(cd "$source_path" && docker image build -t "$image_name" .) 

# login to ecr
$(aws ecr get-login --no-include-email --region "$region") 

# tag image
docker image tag "$image_name" "$repository_url":"$tag"

# push image
docker image push "$repository_url":"$tag"