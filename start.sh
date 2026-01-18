#!/bin/bash
RETRIEVE_TOKEN() {
    echo "Fetching new registration token..."
    RESPONSE=$(curl -s -X POST \
        -H "Authorization: token ${GH_PAT}" \
        -H "Accept: application/vnd.github+json" \
        "https://api.github.com/repos/${OWNER}/${REPO}/actions/runners/registration-token")
    echo $(echo $RESPONSE | jq -r '.token')
}

REG_TOKEN=$(RETRIEVE_TOKEN)
./actions-runner/config.sh --url https://github.com/${OWNER}/${REPO} --token ${REG_TOKEN} --unattended --replace

cleanup() {
    echo "Removing runner..."
    REMOVE_TOKEN=$(RETRIEVE_TOKEN)
    ./actions-runner/config.sh remove --token ${REMOVE_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./actions-runner/run.sh & wait $!