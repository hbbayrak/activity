#!/bin/bash

# TODO -> || 
# Setting to allow error to be shown but not stop the script for now
set +ex

#@--- Function to authenticate to docker hub ---@#
docker_hub_auth() {
    # Login to docker hub
    docker login -p=$DOCKER_HUB_PASSWD -u=$DOCKER_HUB_USERNM

}

#@--- Build docker image  and push---@#
build_and_push_image() {
    #TODO  -> conditional to choose branch

    #@--- Build image for deployment ---@#
    echo "++++++++ Start building image +++++++++"
    if [[ $TRAVIS_BRANCH == "ACT-609" ]]; then
        #@--- Set all the required variables ---@#
        touch .env.deploy

        echo export ACTIVITY_CE_DB_NAME=${ACTIVITY_CE_DB_NAME_DEV} >> .env.deploy
        echo export ACTIVITY_CE_DB_USER=${ACTIVITY_CE_DB_USER_DEV} >> .env.deploy
        echo export ACTIVITY_CE_DB_PASSWORD=${ACTIVITY_CE_DB_PASSWORD_DEV} >> .env.deploy
        echo export ACTIVITY_CE_DB_HOST=${ACTIVITY_CE_DB_HOST_DEV} >> .env.deploy
        echo export SECRET_KEY=${SECRET_KEY} >> .env.deploy
        echo export DEBUG=${DEBUG} >> .env.deploy
        echo export DJANGO_ALLOWED_HOSTS=${DJANGO_ALLOWED_HOSTS} >> .env.deploy
        echo export DB_ENGINE=${DB_ENGINE} >> .env.deploy
        echo export ACTIVITY_CE_DB_PORT=${ACTIVITY_CE_DB_PORT} >> .env.deploy

        # env >> .env.deploy
        docker build -t $DOCKER_HUB_USERNM/activity:$APPLICATION_ENV-$TRAVIS_COMMIT -f docker-deploy/Dockerfile .  

        echo "-------- Building Image Done! ----------"
    fi
    
    echo "++++++++++ Check existing images +++++++++"
    docker images ls

    echo "++++++++++++ Push Image built -------"
    docker push $DOCKER_HUB_USERNM/activity:$APPLICATION_ENV-$TRAVIS_COMMIT      

    #@--- Logout from docker ---@#
    docker logout                                                                                                                                          ─╯
}


#@--- main function ---@#
main() {
    #@--- Run the auth fucntion ---@#
    docker_hub_auth

    #@--- Run the build function ---@#
    build_and_push_image

}

#@--- Run the main function ---@#
main
