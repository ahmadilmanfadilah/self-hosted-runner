#!/bin/bash
RETRIEVE_TOKEN() {
    echo "Fetching new registration token..." >&2
    RESPONSE=$(curl -s -X POST \
        -H "Authorization: Bearer ${GH_PAT}" \
        -H "Accept: application/vnd.github+json" \
        "https://api.github.com/repos/${OWNER}/${REPO}/actions/runners/registration-token")

    TOKEN=$(echo "${RESPONSE}" | jq -r '.token')

    if [ -z "${TOKEN}" ] || [ "${TOKEN}" = "null" ]; then
        echo "Failed to obtain registration token from GitHub API." >&2
        echo "Response was: ${RESPONSE}" >&2
        exit 1
    fi

    echo "${TOKEN}"
}

REG_TOKEN="$(RETRIEVE_TOKEN)"
echo "Got registration token, configuring runner..."
./actions-runner/config.sh --url "https://github.com/${OWNER}/${REPO}" --token "${REG_TOKEN}" --unattended --replace

cleanup() {
    echo "Removing runner..."
    REMOVE_TOKEN="$(RETRIEVE_TOKEN)"
    ./actions-runner/config.sh remove --token "${REMOVE_TOKEN}"
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./actions-runner/run.sh & wait $!
