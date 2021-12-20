#!/bin/bash

# IBM Cloud API Key to access Conteiners API
API_KEY=$1
# Use openshift versions, set to true if openshift should be used. Otherwise leave blank
OPENSHIFT="true"

AUTHORIZATION="Basic Yng6Yng=" # Bluemix Authorization to get refreshtoken
SUFFIX="" # Suffix to add to the version
CLUSTER_TYPE="kubernetes"

# If openshift is not empty set suffix and cluster type
if [ "$OPENSHIFT" == "true" ]; then
    SUFFIX="_openshift"
    CLUSTER_TYPE="openshift"
fi

# Fetch access token to use IKS API
TOKEN=$(
    echo $(
        curl -i -s -k -X POST \
            --header "Content-Type: application/x-www-form-urlencoded" \
            --header "Authorization: $AUTHORIZATION" \
            --data-urlencode "apikey=$API_KEY" \
            --data-urlencode "grant_type=urn:ibm:params:oauth:grant-type:apikey" \
            "https://iam.cloud.ibm.com/identity/token"
    )
)

# IAM Access Token
ACCESS_TOKEN=$(echo $TOKEN | sed -e s/.*access_token\":\"//g | sed -e s/\".*//g)
VERSION_DATA=$(
    curl -s -X GET \
        https://containers.cloud.ibm.com/global/v1/versions \
        -H "Authorization: Bearer $ACCESS_TOKEN" | jq -r ".$CLUSTER_TYPE"
)

VERSIONS_COUNT=$(echo $VERSION_DATA | jq '. | length') # Count of keys
VERSIONS_LENGTH=$((VERSIONS_COUNT - 1))                 # Count based with 0
DEFAULT_VERSION=""

# For each version
for i in $(seq 0 $VERSIONS_LENGTH)
do
    # If the version is default
    IS_DEFAULT=$(echo $VERSION_DATA | jq -r ".[$i].default")
    if [ "$IS_DEFAULT" == "true" ]; then
        MAJOR=$(echo $VERSION_DATA | jq -r ".[$i].major")
        MINOR=$(echo $VERSION_DATA | jq -r ".[$i].minor")
        PATCH="$(echo $VERSION_DATA | jq -r ".[$i].patch")"
        # Create string
        DEFAULT_VERSION="$MAJOR.$MINOR.$PATCH$SUFFIX"
    fi
done

# Return data
jq -n --arg default_version "$DEFAULT_VERSION" '{default_version: $default_version}'