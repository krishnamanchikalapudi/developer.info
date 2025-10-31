#!/bin/bash
arg=${1}
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`
set -euo pipefail

# below information available in the JFrog CLI config 'jf config show'
# export JF_URL="https://psazuse.jfrog.io/"
# export JF_XRAY_URL="https://psazuse.jfrog.io/xray/"
# export JF_ARTIFACTORY_URL="https://psazuse.jfrog.io/artifactory/"
# export JFROG_CLI_SERVER_ID="psazuse"
# export JF_ACCESS_TOKEN=

export JF_GIT_PROVIDER=
export JF_GIT_OWNER=
export JF_GIT_TOKEN=

JF_GIT_REPO="https://gitlab.com/krishnamanchikalapudi/spring-petclinic"
GIT_BRANCH="main"


frogbot-install(){
    curl -fLg "https://releases.jfrog.io/artifactory/frogbot/v2/[RELEASE]/getFrogbot.sh" | sh
}
frogbot-run(){
    printf "\n ----------------------------------------------------------------  "
    printf "\n ----------------  MINIKUBE: Install  ----------------  "
    printf "\n ----------------------------------------------------------------  \n"

    # Check if FrogBot is installed
    if ! test -f frogbot &> /dev/null; then
        echo "FrogBot is not installed. Installing FrogBot..."
        frogbot-install
    else
        echo "FrogBot is already installed."
        chmod +x ./frogbot*
    fi

    mkdir -p .frogbot
cat > .frogbot/frogbot-config.yml <<EOF
- params:
    git:
    repoName: "${JF_GIT_REPO}"
    branches:
        - "${GIT_BRANCH}"
EOF
    echo "✅ Created .frogbot/frogbot-config.yml"

    # Get the latest Frogbot release tag from GitHub
    LATEST_VERSION=$(curl -s https://api.github.com/repos/jfrog/frogbot/releases/latest | grep tag_name | cut -d '"' -f 4)

    if [[ -z "$LATEST_VERSION" ]]; then
        echo "❌ Failed to fetch latest Frogbot version."
        exit 1
    fi

    VERSION_NUMBER=${LATEST_VERSION#v}
    echo "✅ Latest Frogbot version: $VERSION_NUMBER"

    # Download and run Frogbot
    curl -fLg "https://releases.jfrog.io/artifactory/frogbot/v2/${VERSION_NUMBER}/getFrogbot.sh" | sh

    # Run the scan
    ./frogbot scan-repository


}

# Check for 1 argument
if [ $# -ne 1 ]; then
  echo "Error: This script requires exactly 1 arguments."
  echo "    frogbot.sh <install | info | install | tail > "
fi
# -z option with $1, if the first argument is NULL. Set to default
if  [[ -z "$1" ]] ; then # check for null
    echo "User action is NULL, setting to default INSTALL"
    arg='RUN'
fi

# -n string - True if the string length is non-zero.
if [[ -n $arg ]] ; then
    arg_len=${#arg}
    echo "Current Directory: ${current_dir} and update YAML FILE PATH: ${YAML_FILE}"
    # uppercase the argument
    arg=$(echo ${arg} | tr [a-z] [A-Z] | xargs)
    echo "User Action: ${arg}, and arg length: ${arg_len}"
    
    if [[ "INSTALL" == "${arg}" ]] ; then   # Download & install 
        frogbot-install
    elif [[ ("DEL" == "${arg}") || ( "DELETE" == "${arg}") || ("STOP" == "${arg}") || ( "RM" == "${arg}") ]] ; then   # delete 
        webui-delete
    elif [[ "RUN" == "${arg}" ]] ; then   # Info 
        frogbot-run
    else
        echo "Error: Invalid argument. Use 'install', 'info', 'delete' or 'test'."
        exit 1
    fi
fi
printf "\n ----------------------------------------------------------------  "
printf "\n***** [END] TS: $(date +"%Y-%m-%d %H:%M:%S") \n\n"