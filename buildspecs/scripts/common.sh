#!/bin/bash

set -e

docker_login () {
    # log into specified ecr repo
    ecr_repo=$1

    echo -e "\nlogging into repo $ecr_repo...\n"

    aws ecr get-login-password \
        --region $AWS_REGION | docker login \
            --username AWS \
            --password-stdin $ecr_repo
}