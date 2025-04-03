#!/bin/bash

BONFIRE_NAMESPACE=""
check_mark=$(echo -e "\xE2\x9C\x94")
curr_date=$(date +"%D %T")

# Utility functions
on_exit() {
  echo
  echo "Releasing bonfire namespace before exiting"
  bonfire namespace release $BONFIRE_NAMESPACE
}

# This script will deploy autoreg code into ephimeral env. Make sure .defaults.sh file is updated with the expected values
# and this script is being run inside virtual env after installing bonfire inside it.

echo "
#################################################################################
#################################################################################

              ╭━━━╮╱╱╱╱╱╭╮╱╱╱╱╱╱╱╱╱╱╱╱╱╱╭╮╱╱╱╱╱╱╱╱╱╱╱╱╱╭╮
              ╰╮╭╮┃╱╱╱╱╱┃┃╱╱╱╱╱╱╱╱╱╱╱╱╱╱┃┃╱╱╱╱╱╱╱╱╱╱╱╱╱┃┃
              ╱┃┃┃┣━━┳━━┫┃╭━━┳╮╱╭╮╭━━┳━━┫╰━┳┳╮╭┳━━┳━┳━━┫┃
              ╱┃┃┃┃┃━┫╭╮┃┃┃╭╮┃┃╱┃┃┃┃━┫╭╮┃╭╮┣┫╰╯┃┃━┫╭┫╭╮┃┃
              ╭╯╰╯┃┃━┫╰╯┃╰┫╰╯┃╰━╯┃┃┃━┫╰╯┃┃┃┃┃┃┃┃┃━┫┃┃╭╮┃╰╮
              ╰━━━┻━━┫╭━┻━┻━━┻━╮╭╯╰━━┫╭━┻╯╰┻┻┻┻┻━━┻╯╰╯╰┻━╯
              ╱╱╱╱╱╱╱┃┃╱╱╱╱╱╱╭━╯┃╱╱╱╱┃┃
              ╱╱╱╱╱╱╱╰╯╱╱╱╱╱╱╰━━╯╱╱╱╱╰╯

#################################################################################
#################################################################################
"

echo "$curr_date INFO: Starting service to deploy to ephimeral"

# check if script is running in venv else bail out early
echo "$curr_date INFO: Checking if running in a virtual env or not"
if [[ "$VIRTUAL_ENV" == "" ]]
then
  echo "$curr_date ERROR: Run this command inside venv with bonfire installed in it"
  exit 1
fi
echo "$curr_date INFO: Running virtual env $check_mark"

# check if script is running in venv else bail out early
echo "$curr_date INFO: Checking if Openshift cli is installed or not"
if ! command -v oc &> /dev/null
then
    echo "$curr_date ERROR: oc not found.Please install and retry"
    exit 1
fi
echo "$curr_date INFO: Openshift cli $check_mark"

# check if bonfire is installed in venv or not
is_av=$(python -c 'import importlib.util; print(1 if importlib.util.find_spec("bonfire") else 0)')
if [ $is_av == 0 ]; then
  echo "$curr_date ERROR: Bonfire is not installed. Please install and retry"
  exit 1
fi
echo "$curr_date INFO: Bonfire $check_mark"

# export all the variables from defaults.sh into this shell terminal
echo "$curr_date INFO: Loading all the env vars from .env file"
source "$(pwd)/.env"

# oc login
echo "$curr_date INFO: Trying out oc login"
oc login --token="$OC_LOGIN_TOKEN" --server=https://api.crc-eph.r9lp.p1.openshiftapps.com:6443 > /dev/null
if [ $? -eq 1 ]; then
  echo "$curr_date ERROR: Failed oc login. Recheck token and try again"
  exit 1
fi
echo "$curr_date INFO: oc login $check_mark"

# reserve a bonfire namespace and store it into a variable
BONFIRE_NAMESPACE="$(bonfire namespace reserve)"
echo "$curr_date INFO: Bonfire namespace reserved with name $BONFIRE_NAMESPACE"

# change oc project to BONFIRE_NAMESPACE
oc project $BONFIRE_NAMESPACE > /dev/null
echo "$curr_date INFO: Changed oc project to $BONFIRE_NAMESPACE $check_mark"

echo "$curr_date INFO: Printing out the configuration, check it before proceeding"
oc process -p ENV_NAME=env-$BONFIRE_NAMESPACE -p REPLICAS=1 -p IMAGE=$IMAGE_DEV -p IMAGE_TAG=$(git rev-parse --short=7 HEAD) -f deploy/clowdapp.yaml

# take user input of y/n
read -p "Is this config correct? [y/n] " -n 1 -r
if ! [[ $REPLY =~ ^[Yy]$ ]]; then
  on_exit
  exit 1
fi

# now deploy to bonfire project
echo 
echo "$curr_date INFO: Deploying project to oc cluster"
oc process -p ENV_NAME=env-$BONFIRE_NAMESPACE -p REPLICAS=1 -p IMAGE=$IMAGE_DEV -p IMAGE_TAG=$(git rev-parse --short=7 HEAD) -f deploy/clowdapp.yaml | oc apply -f - > /dev/null
if [ $? -eq 1 ]; then
      echo "$curr_date ERROR: Deployment to ephimeral failed. Program will exit now"
      on_exit
      exit 1
fi
echo "$curr_date INFO: Project deployed successfully."

OPEN_LOC="https://console-openshift-console.apps.crc-eph.r9lp.p1.openshiftapps.com/k8s/ns/$BONFIRE_NAMESPACE/core~v1~Pod"
case "$(uname -s)" in
    Linux*)     xdg-open "$OPEN_LOC" &>/dev/null ;;
    Darwin*)    open "$OPEN_LOC" &>/dev/null ;;     # For Mac
    CYGWIN*|MINGW*|MSYS*) start "$OPEN_LOC" &>/dev/null ;; # For Windows
    *)          echo "Unsupported operating system" ;;
esac

trap on_exit SIGINT SIGTERM SIGTSTP
read -p "$curr_date INFO: Press any key to exit with releasing namespace" -n 1 -r
on_exit
