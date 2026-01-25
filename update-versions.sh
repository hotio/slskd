#!/bin/bash
set -exuo pipefail

url=$(curl -fsSL --header "Authorization: Bearer ${GITHUB_TOKEN}" "https://api.github.com/repos/slskd/slskd/actions/runs?branch=master&exclude_pull_requests=true" | jq -re '[.workflow_runs[] | select(.name == "CI") | select(.conclusion == "success") | .artifacts_url][0]')
json_artifacts=$(jq -re '.artifacts[]' <<< "$(curl -fsSL "${url}?per_page=100")")
version=$(jq -re '. | select(.name | contains("linux-musl-x64")) | .name' <<< "${json_artifacts}" | sed -e 's/slskd-//' -e 's/-.*//')
version_url_amd64=$(jq -re '. | select(.name | contains("linux-musl-x64")) | .archive_download_url' <<< "${json_artifacts}")
version_url_arm64=$(jq -re '. | select(.name | contains("linux-musl-arm64")) | .archive_download_url' <<< "${json_artifacts}")

json=$(cat meta.json)
jq --sort-keys \
    --arg version "${version//v/}" \
    --arg version_url_amd64 "${version_url_amd64}" \
    --arg version_url_arm64 "${version_url_arm64}" \
    '.version = $version | .version_url_amd64 = $version_url_amd64 | .version_url_arm64 = $version_url_arm64' <<< "${json}" | tee meta.json
