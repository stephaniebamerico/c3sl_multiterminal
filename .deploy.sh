#!/bin/bash

# This script uploads an includes a .deb package in our debian repository.
# The distribution is chosen based on the gitlab-ci stage we are on.

apt-get update && apt-get install -y dput ssh

eval $(ssh-agent -s)
ssh-add <(echo "$PRIV_KEY")

echo "Deploy job name: $CI_JOB_NAME"

if [ "$CI_JOB_NAME" = "deploy_for_testing" ]; then
    dput -u -f --config=dput.cf repo build/*.changes
elif [ "$CI_JOB_NAME" = "deploy_for_stable" ]; then
    CHANGELOG="package/debian/changelog"
    LINE=$(head -n 1 $CHANGELOG)
    PACKAGE=$(echo $LINE | cut -d' ' -f1)
    VERSION=$(echo $LINE | cut -d' ' -f2 | grep -o -E '[0-9]*\.[0-9]*\.[0-9]*')

    REPREPRO_CMD="reprepro -Vb /home/repository/www/le6 copysrc stable testing $PACKAGE $VERSION"
    ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa repository@repo.c3sl.ufpr.br "$REPREPRO_CMD"
fi  
