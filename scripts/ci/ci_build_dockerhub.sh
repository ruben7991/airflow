#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

# This is hook build used by DockerHub. We are also using it
# on Travis CI to potentially rebuild (and refresh layers that
# are not cached) Docker images that are used to run CI jobs
export FORCE_ANSWER_TO_QUESTIONS="yes"
export PULL_BASE_IMAGES="true"

# In case of CRON jobs on Travis we run builds without cache
if [[ "${TRAVIS_EVENT_TYPE:=}" == "cron" ]]; then
    echo
    echo "Disabling cache for CRON jobs"
    echo
    export DOCKER_CACHE="no-cache"
    export PULL_BASE_IMAGES="true"
fi

if [[ -z ${DOCKER_TAG:=} ]]; then
   echo
   echo "Error! Missing DOCKER_TAG environment variable"
   echo "Please specify DOCKER_TAG variable following the pattern BRANCH-pythonX.Y[-ci]"
   echo
   exit 1
fi

[[ ${DOCKER_TAG:=} =~ ${DEFAULT_BRANCH}-python([0-9.]*) ]] && export PYTHON_VERSION=${BASH_REMATCH[1]}

if [[ -z ${PYTHON_VERSION:=} ]]; then
    echo
    echo "Error! Wrong DOCKER_TAG"
    echo "The tag '${DOCKER_TAG}' should follow the pattern ${DEFAULT_BRANCH}-pythonX.Y[-ci]"
    echo
    exit 1
fi

echo "Detected PYTHON_VERSION=${PYTHON_VERSION}"
echo

# shellcheck source=scripts/ci/_script_init.sh
. "$( dirname "${BASH_SOURCE[0]}" )/_script_init.sh"

prepare_build
rm -rf "${BUILD_CACHE_DIR}"

if [[ ${DOCKER_TAG} == *-ci ]]; then
    rebuild_ci_image_if_needed
    push_ci_image
fi
