# shubh-github-test
test tekton pipelines with opensource deployment.


## Bonfire deployment
Page to refer for bonfire deployment [this](https://inscope.corp.redhat.com/docs/default/Component/consoledot-pages/creating-a-new-app/using-ee/bonfire/) 

For this we need user to have access to Quay.io, oc command line and access to [ephemeral cluster](https://console-openshift-console.apps.crc-eph.r9lp.p1.openshiftapps.com/dashboards)

Also obtain Quay.io credentials and paste it in your .env file with this format
```shell
export ACG_CONFIG="test-config.json"
export QUAY_TOKEN="Quay-login-token"
export QUAY_USER="quay-username"
export IMAGE_DEV="quay-dev-repo-namespace"
```
Once populated, run this command
```shell
source .env && ./build_deploy.sh
```
This will build and deploy your image to specified quay.io repository.
Once deployed we can proceed with further steps

- Run this command to setup bonfire
    ```shell
    python -m venv .bonfire_venv && 
    source .bonfire_venv/bin/activate &&
    pip install crc-bonfire 
    ```
    This will install and start a bonfire venv

- Test using this command
    ```shell
    bonfire namespace list
    ```

Before next step login to oc by copying login token from [here](https://oauth-openshift.apps.crc-eph.r9lp.p1.openshiftapps.com/oauth/token/request)
Once you have login token follow the next steps

- Reserve bonfire namespace using this command
    ```shell
    BONFIRE_NAMESPACE="$(bonfire namespace reserve)"
    ```
- This should happen by default but run this to just double check
    ```shell
    oc project $BONFIRE_NAMESPACE
    ```
- Run this command to start oc with provided clowdapp deploy config
    ```shell
    oc process -p ENV_NAME=env-$BONFIRE_NAMESPACE -p REPLICAS=1 -p IMAGE=$IMAGE_DEV -p IMAGE_TAG=$(git rev-parse --short=7 HEAD) -f deploy/clowdapp.yaml | oc apply -f -
    ```
- If successful, you'll see a message like `clowdapp.cloud.redhat.com/test-shubh-github-deploy created`.

- Once done remove namespace using this command
    ```shell
    bonfire namespace release $BONFIRE_NAMESPACE
    ```

