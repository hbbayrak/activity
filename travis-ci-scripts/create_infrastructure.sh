#!/bin/bash

set +ex

#@--- Function to setup the cluster ---@#
set_up_cluster() {
    if [[ $TRAVIS_BRANCH == "ACT-609" ]]; then
        #@--- Initialize terraform ---@#
        terraform init -backend-config "bucket=$BACKEND_BUCKET" -backend-config "key=$STATE_FILE" -backend-config "access_key=$SPACES_ACCESS_KEY" -backend-config "secret_key=$SPACES_SECRET_KEY"

        #@--- Run terraform command to plan infrastructure ---@#
        terraform plan -lock=false  -var "cluster_name=${CLUSTER_NAME}" -var "cluster_region=${CLUSTER_REGION}" -var "kubernetes_version=${K8S_VERSION}" -var "node_type=${NODE_TYPE}" -var "max_node_number=${MAX_NODE_NUM}" -var "min_node_number=${MIN_NODE_NUM}" -var "digital_ocean_token=${SERVICE_ACCESS_TOKEN}" 
        
        #@--- Apply the changes ---@#
        terraform apply -lock=false -auto-approve -var "cluster_name=$CLUSTER_NAME" -var "cluster_region=$CLUSTER_REGION" -var "kubernetes_version=$K8S_VERSION" -var "node_type=$NODE_TYPE" -var "max_node_number=$MAX_NODE_NUM" -var "min_node_number=$MIN_NODE_NUM" -var "digital_ocean_token=$SERVICE_ACCESS_TOKEN" || echo "Resources exist"

        # terraform destroy -lock=false -auto-approve -var "cluster_name=$CLUSTER_NAME" -var "cluster_region=$CLUSTER_REGION" -var "kubernetes_version=$K8S_VERSION" -var "node_type=$NODE_TYPE" -var "max_node_number=$MAX_NODE_NUM" -var "min_node_number=$MIN_NODE_NUM" -var "digital_ocean_token=$SERVICE_ACCESS_TOKEN" || echo "Resources 404"
    fi
}

#@--- Main function ---@#
main() {
    cd infrastructure

    #@--- Run the set up cluster function ---@#
    set_up_cluster
}

#@--- Run the main function ---@#
main
