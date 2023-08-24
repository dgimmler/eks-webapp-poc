# Overview

Sample project to demonstrate a simple React webapp deployed on Kubernetes running
on EKS. This projects includes terraform code for deploying the supporting
infrastructure. The terraform infrastructure includes a CI/CD pipeline built on
AWS Codepipeline to deploy the webapp.

Below is a summary of the components:

1. React app for displaying user information
2. Docker container for running the application
3. Kubernetes manifests for running and load-balancing container
4. Terraform code for defining supporting AWS infrastructure
5. CI/CD pipelines for deploying and validating infrastructure and react app

## Deploy

### 0. Prereqs

The following tools need to be install on your machine:

- Docker
- kubectl
- eksctl
- helm
- aws cli
- node
- npm
- create-react-app
- terraform

### 1. Deploy Terraform

1. Set terrform/environments/<envname>.variables.tfvaars file with environment config
2. Deploy the terraform code locally once:

```bash
cd terraform
terraform init
# optional to view planned infra
terraform plan -var-file environments/<envname>.variables.tfvars
terraform apply -var-file environments/<envname>.variables.tfvars -auto-approve
```

**NOTE:** It can take upwards of 20 minutes to finish deploying the VPC and the
EKS cluster

### 2. Build app

Init react app build by installing dependencies and running build script:

```bash
cd app
npm install
npm run build # should create new build folder
```

### 3. Build and push image to ECR

1. Build image with react app from project root

```bash
# from project root
docker build -t display-users .
```

2. Login to ECR repo:

The cmd below should also be output from the terraform apply

```bash
$repoUri="<repo uri>"
region="us-west-2"
aws ecr get-login-password \
    --region $region | docker login \
        --username AWS \
        --password-stdin $repoUri
```

3. Tag and push the local image

```bash
$repoUri="<repo uri>"
docker tag display-users:latest ${repoUri}:latest
docker push ${repoUri}:latest
```

### 4. Deploy kubernetes manifests

1. Create namespace

```bash
cd manifests
kubectl apply -f 01-namespace.yaml
```

2. Create secret for ECR credentials

Kubernetes needs to be able to authentiate to ECR to pull our image, so we need
to provide the credentils as a secret. We do this via CLI as this contains sensitive
data we don't want to capture in github.

```bash
repoUri="<repoUri>"
email="<aws account email>"
region="<aws region>"
namespace="display-users"

pw=$(aws ecr get-login-password --region $region)

kubectl create secret docker-registry ecr \
  --docker-server=$repoUri \
  --docker-username=AWS \
  --docker-password=$pw \
  --docker-email=$email \
  --namespace=$namespace
```

3. Validate secret

```bash
kubectl get secret -n $namespace # should return secret
```

4. Install the load balancer controller

This is needed to create the Ingress Classes and expose our application with an ALB

```bash
region="us-west-2"
clusterName="<cluster name>"
vpcId="<vpc ID>" # should be output from terraform apply

# Add the eks-charts repository if not there already
# it just shows "already exists" if it does, so run it either way
helm repo add eks https://aws.github.io/eks-charts

# Update your local repo to make sure that you have the most recent charts.
helm repo update

# install the controller
# note this is for us-east-1. If you are using a different region, you'll need
#  to update the region below and find the correct image repository
# images listed here: https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$clusterName \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=$region \
  --set vpcId=$vpcId \
  --set image.repository=602401143452.dkr.ecr.us-west-2.amazonaws.com/amazon/aws-load-balancer-controller

# validate deploy (cmds should show result)
kubectl -n kube-system get deployment aws-load-balancer-controller
kubectl -n kube-system get svc aws-load-balancer-webhook-service

# NOTE: give the deployment a few min to spin up the pods
# you can track the status with the below command
kubectl get pods -n kube-system
```

4. Configure the manifests

- Edit the manifests/02-serviceaccount.yaml file to use the role arn (should be output from terraform apply)
- Edit the manifests/03-deployment.yaml file on the image line to use the ECR URI.

5. Deploy the remaining manifests

```bash
# from project root
kubectl apply -f manifests/
```

### 5. Prepare and run pipeline

1. Grant pipeline role permissions to the cluster

In order for the pipeline to be able to deploy updates to the
cluster, we need to grant it access by addingit to the system:masters
group.

```bash
clusterName=""
region="us-west-2"
# role arn should be output from terraform apply
role_arn="<codepipeline execution role arn>"

# create iam identity mapping
eksctl create iamidentitymapping \
  --cluster $clusterName \
    --region=$region \
    --arn $role_arn \
    --username codepipeline \
    --group system:masters \
    --no-duplicate-arns

# validate
eksctl get iamidentitymapping \
  --cluster $clusterName \
  --region=$region

kubectl describe configmap -n kube-system aws-auth
```

2. Run the pipeline

Nothing else really needs to be done for the pipeline beyond triggering it.
The pipeline is triggered by any push or merge into the 'main' branch. Simply
commit and push to main, and the pipeline should run.

## TODOs

Below are further iterations that would follow on a production build:

1. Lock down KMS policies a little more
2. Create a pipeline for the Terraform code:

```
Stage 1: Validate
  - Action: Run tflint
  - Aciton: Run checkov
Stage 2: Plan
  - Action: Run terraform plan
Stage 3: Approval
  - Action: Manual approval/validation of TF plan
Stage 4: Apply
  - Action: Run terraform apply
```

3. Add exceptions process for checks, possibly additional validation stages
4. Add Staging/mulitple environements
5. Add cluster autoscaling: EKS cluster nodes currently need to be scaled manually
6. Use gitlab for CI/CD instead
7. Add a Gitops tool like ArgoCD to handle the actually rollouts of the application. Main would be a protected branch. AFTER the pipeline succeeds in lower environments, merge changes into release or main branch. This triggers an application "sync" in argocd
8. Move terraform modules to their own repo or folder within a repo. Add semantic versioning.
9. EKS cluster and app would probably be in different repos
10. Application needs better error handling. Both code and unit tests only cover happy paths.

## Helpers

```bash
# run local container
docker run -d --name display-users -p 8000:3000 display-users

# if container already exists:
docker run -p 8000:3000 -td display-users

# rollout updated image
kubectl rollout restart deployment/display-users-deployment -n display-users
```
