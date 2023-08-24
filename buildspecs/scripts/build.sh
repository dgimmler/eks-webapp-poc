#!/bin/bash

set -ex

working_dir=$(pwd)
app_repo="$working_dir/app"
image_tag="staging"

source "$working_dir/buildspecs/scripts/common.sh"

push_image() {
    ecr_repo=$1
    image_name=$2
    tag=$3

    echo -e "\npushing image ${image_name}:latest to repo $ecr_repo as ${ecr_repo}:${image_name}\n"

    # login, tag and push
    docker tag ${image_name}:latest ${ecr_repo}:${image_name}
    docker push ${ecr_repo}:${image_name}
}

build_app_image () {
    tag=$1

    cd $app_repo

    npm run build
    docker build --build-arg "ACCOUNT_ID=$ACCOUNT_ID" -t $tag .

    cd $working_dir
}

main () {
    docker_login $ECR_REPO_URI
    build_app_image $image_tag
    push_image $ECR_REPO_URI "staging" $image_tag

    cd $working_dir
}

main