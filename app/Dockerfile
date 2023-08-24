# NOTE
# for the sake of simplicity I'm using a base image. For a
# production implementation, we would want to build an image
# from scratch, especially to have more control over managing
# vulnerabilities

# FROM node:20-alpine
# work-around to avoid docker rate-limits. This is a clone of the node:20-alpin
# image pushed to our ECR repo
ARG ACCOUNT_ID
FROM ${ACCOUNT_ID}.dkr.ecr.us-west-2.amazonaws.com/eks-webapp-poc:base

RUN apk update && apk upgrade && apk add \
    bash
RUN npm install -g \
    serve

WORKDIR /app

ADD ./build /app

EXPOSE 3000

CMD [ "serve", "-s", "." ]