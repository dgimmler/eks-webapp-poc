#!/bin/bash

set -ex

working_dir=$(pwd)
app_repo="$working_dir/app"
image_tag="staging"

source "$working_dir/buildspecs/scripts/common.sh"

deploy_image() {
    repo_uri=$1
    tag=$2

    docker pull ${repo_uri}:$tag
    docker tag ${repo_uri}:$tag ${repo_uri}:latest

    docker push ${repo_uri}:latest
}

rollout_update() {
    aws eks update-kubeconfig \
        --region $AWS_REGION \
        --name $CLUSTER_NAME

    # kubectl apply -f manifests/
    kubectl rollout restart deployment/display-users-deployment -n display-users
}

main () {
    docker_login $ECR_REPO_URI
    deploy_image $ECR_REPO_URI $image_tag

    rollout_update
}

main