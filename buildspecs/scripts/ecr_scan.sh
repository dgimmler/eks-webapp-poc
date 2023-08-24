#!/bin/bash

set -ex

working_dir=$(pwd)
app_repo="$working_dir/app"
image_tag="staging"

FAILED=false

wait_scan_status () {
    repo_name=$1
    tag=$2

    stat="IN_PROGRESS"
    i=0
    while [ "$stat" != "COMPLETE" ]; do
        i=$(( $i+1 ))
        sleep 5;
        stat=$(aws ecr describe-image-scan-findings --repository-name $repo_name --image-id imageTag=$tag | jq -r '.imageScanStatus.status');

        set +x
        echo "Waiting for ${repo_name}:${tag} scan to complete..."
        set -x

        if [ "$i" == "12" ]; then
            # timeout = 60 seconds
            set +x
            echo "Wait timed out"
            set -x

            exit 1
        fi
    done
}

get_scan_result () {
    repo_name=$1
    tag=$2

    result=$(aws ecr describe-image-scan-findings --repository-name $repo_name --image-id imageTag=$tag | jq -r '.imageScanFindings.findingSeverityCounts')
    critical=$(echo $result | jq -r '.CRITICAL')
    high=$(echo $result | jq -r '.HIGH')

    image_failed=false

    if [ "$critical" != null ]; then
        FAILED=true
        imaged_failed=true
    else
        critical=0
    fi

    if [ $high != null ]; then
        FAILED=true
        image_failed=true
    else
        high=0
    fi

    set +x
    echo -e "\nFound $critical critical and $high high vulnerabilities in image $tag on $repo_name repository\n"
    echo ""
    echo -e "Results summary (empty means no issues found)\n":
    echo -e $result
    echo ""
    aws ecr describe-image-scan-findings --repository-name $repo_name --image-id imageTag=$tag | jq -r '.imageScanStatus.status'
    echo ""
    set -x
}

main () {
    wait_scan_status $ECR_REPO_NAME $image_tag
    get_scan_result $ECR_REPO_NAME $image_tag

    if [ "$FAILED" = true ] ; then
        set +x
        echo -e "The images has high or critical vulnerabilities. See results above for details."
        echo "Scan failed"
        set -x

        exit 1
    fi
}

main