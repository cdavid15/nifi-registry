#!/bin/bash
set -e

## lets use the same default location NiFi Registery uses
FLOW_STORAGE_DIRECTORY="flow_storage"

echo "Preparing the Git Flow Provider Repository"

## Set the Git User details
if [[ -n "$GIT_CONFIG_USER_NAME" ]]; then
  git config --global user.name "$GIT_CONFIG_USER_NAME"
  git config --global user.email "$GIT_CONFIG_USER_EMAIL"
fi

## If envrinoment variable GIT_REMOTE_REPOSITORY is defined prepare a remote git repo
if [[ -n "$GIT_REMOTE_REPOSITORY" ]]; then

  echo "Remote repository configuration detected"
  echo "Git Repository: $GIT_REMOTE_REPOSITORY"

  ## Let's not worry about the internal certificates
  git config --global http.sslVerify false

  ## Store the credentials for the initial checkout
  git config --global credential.$GIT_REMOTE_REPOSITORY.username $GIT_REMOTE_ACCESS_USER
  git config --global credential.$GIT_REMOTE_REPOSITORY.helper "!f() { echo \"password=$GIT_REMOTE_ACCESS_TOKEN\"; }; f"

  ## If the GIT_REMOTE_BRANCH environment variable is not supplied default to master branch
  if [[ -z "$GIT_REMOTE_BRANCH" ]]; then
    GIT_REMOTE_BRANCH="master";
    echo "Environment variable GIT_REMOTE_BRANCH was not provided. Default value will be used"
  fi
  echo "Branch: $GIT_REMOTE_BRANCH"

  ## If the GIT_REMOTE_TO_PUSH environment variable is not supplied default to 'origin'
  if [[ -z "$GIT_REMOTE_TO_PUSH" ]]; then
    GIT_REMOTE_TO_PUSH="origin";
    echo "Environment variable GIT_REMOTE_TO_PUSH was not provided. Default value will be used"
  fi
  echo "Origin: $GIT_REMOTE_TO_PUSH"

  ## Ensure the FLOW_STORAGE_DIRECTORY directory doesn't exist
  if [[ ! -d $FLOW_STORAGE_DIRECTORY  ]]; then
    git clone -o $GIT_REMOTE_TO_PUSH -b $GIT_REMOTE_BRANCH $GIT_REMOTE_REPOSITORY $FLOW_STORAGE_DIRECTORY
    echo "Remote Repository cloned and ready for use"
  else
    echo "Flow Storage directory ($FLOW_STORAGE_DIRECTORY) already exists. Remote repository will not be cloned"
  fi

else
  echo "Local repository configuration detected"
  ## Initial a local only git repo
  git init $FLOW_STORAGE_DIRECTORY
  echo "Local Repository ready for use"
fi

## Dynamically configure GitFlowPersistenceProvider and replace the default providers.xml
/usr/local/bin/dockerize -template ../templates/providers.xml.gotemplate:./conf/providers.xml

## Execute the original NiFi Registry entrypoint script
. ../scripts/start.sh
