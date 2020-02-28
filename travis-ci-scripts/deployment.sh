#!/bin/bash

set +ex

#@--- install and authenticate kubect to the cluster ---@#
setup_kubectl() {
    echo "++++++++++++ install kubectl ++++++++++++"
    curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

    # Make downloaded binary executable
    chmod +x ./kubectl

    # Add binary to path
    sudo mv ./kubectl /usr/local/bin/kubectl

    # Check the version 
    kubectl version --client

    # Install digital ocean cli tool
    sudo snap install doctl
    sudo snap connect doctl:kube-config

    # Authenticate kubectl to the cluster
    # TODO -> This can be conditional for different braches
    mkdir /home/travis/.kube
    if [[ $TRAVIS_BRANCH == "ACT-609" ]]; then
        # The cluster name can be conditionaly changed
        doctl -t $SERVICE_ACCESS_TOKEN kubernetes cluster kubeconfig save $CLUSTER_NAME
        doctl auth init -t $SERVICE_ACCESS_TOKEN
        kubectl create namespace $APPLICATION_ENV || echo "++++++ Namespace Exists ++++++"
        kubectl create namespace ingress-nginx
    fi

    # fetch cluster nodes
    kubectl config current-context
    kubectl get nodes

    echo "+++ Kubectl installed and configured to the cluster +++++"
}

deploy_app() {
    echo "-------- deploy application -------------"
    sudo apt-get install gettext -y

    # if [[ "${TRAVIS_BRANCH}" == "ACT-609" ]]; then
    echo "------- generate deployfiles --------------"
    envsubst < ./deployment_files/deployment > deployment.yaml
    envsubst < ./deployment_files/service > service.yaml
    envsubst < ./deployment_files/autoscaler > autoscaler.yaml
    envsubst < ./deployment_files/ingress-config > ingress-config.yaml

    # fi

    echo "+++++++  make deployments with kubectl +++++++"
    kubectl create clusterrolebinding serviceaccounts-cluster-admin --clusterrole=cluster-admin --group=system:serviceaccounts
    kubectl apply -f deployment_files/man.yaml  
    kubectl apply -f deployment_files/ingress-service.yaml   
    
    kubectl apply -f deployment.yaml  
    kubectl apply -f service.yaml
    kubectl apply -f autoscaler.yaml 
    
    kubectl apply -f ingress-config.yaml   
    echo "--------- deployment made !! ----------------"

    # Check on deployment
    kubectl get pods --all-namespaces

    #@--- Show services created ---@#
    kubectl get services --all-namespaces
}


#@--- Main Function ---@#
main() {
    #@--- Run the setup function ---@#
    setup_kubectl

    #@--- Run deployment functio ---@#
    deploy_app
}

#@--- Run the main function ---@#
main
