#!/bin/bash
arg=${1}
printf "\n"
printf "############################################################################################################# \n"
printf "01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101\n"
printf "######## ######## ##    ##  ######   #######  ########  ######## ##        #######  ##      ##     #######    \n"
printf "   ##    ##       ###   ## ##    ## ##     ## ##     ## ##       ##       ##     ## ##  ##  ##    ##     ##   \n"
printf "   ##    ##       ####  ## ##       ##     ## ##     ## ##       ##       ##     ## ##  ##  ##           ##   \n"
printf "   ##    ######   ## ## ##  ######  ##     ## ########  ######   ##       ##     ## ##  ##  ##     #######    \n"
printf "   ##    ##       ##  ####       ## ##     ## ##   ##   ##       ##       ##     ## ##  ##  ##    ##          \n"
printf "   ##    ##       ##   ### ##    ## ##     ## ##    ##  ##       ##       ##     ## ##  ##  ##    ##          \n"
printf "   ##    ######## ##    ##  ######   #######  ##     ## ##       ########  #######   ###  ###     #########   \n"
printf "############################################################################################################# \n"




help() {
    printf "\n%s\n" "Usage: ./project.sh <command>"
    echo "Commands:"
    echo "  preq  - Validate the prerequisite libraries install"
    echo "  build - Build the project"
    echo "  test  - Run tests"
    echo "  clean - Clean the project"
    echo "  tfb   - Start tensorflow board"
    echo "  tfbk  - Stop tensorflow board"
    echo "  help  - Print this help"

    printf "\n\n"
}
default(){
    echo "Action argument length is ZERO. So, executing default action: Clean, Build"
    clean
    build
    preq
}
preq() {
    python3 -m pip install --user --upgrade pip
    pip install -r requirements.txt

    python3 scripts/learn/L0_prerequisite.py 
}
code_coverage() {
    # ref: https://github.com/marketplace/actions/github-action-for-pylint
    pylint --confidence=HIGH --exit-zero -v -E -s y -f json -j 4 scripts/ tests/
    # pylint --confidence=HIGH --exit-zero -v -E -s y -j 4 scripts/ tests/
}
clean() {
    find . -type f -name .DS_Store -exec rm -r {} \+
    find . -type d -name __pycache__ -exec rm -r {} \+
    find . -type d -name *.egg-info -exec rm -r {} \+
    find . -type d -name dist -exec rm -r {} \+
    find . -type d -name build -exec rm -r {} \+
}
build() {
    python3 -q setup.py clean
    python3 -q setup.py install

    dependency
    compile   
}
dependency() {
    pip3 install -r requirements.txt
}
compile() {
    python3 -m compileall .
}
tests() {
    python3 -m unittest tests/utils/FileExtenTests.py 
    python3 -m unittest tests/algorithms/ConvolutionalNeuralNetworksTests.py
}
tfboard() {
    tensorboard --logdir=logs &
    sleep 5
    open -a 'Google Chrome' 'http://localhost:6006/'
}

# -n string - True if the string length is non-zero.
if [[ -n $arg ]] ; then
    arg_len=${#arg} 
    # uppercase the argument
    arg=$(echo ${arg} | tr [a-z] [A-Z] | xargs)

    echo "Python version: {`python3 -V`}"
    echo "PIP version: {`pip3 -V`}"
    echo "Action: ${arg} and length is NOT ZERO: ${arg_len}"
    
    case $arg in
        PREQ)
            preq
            ;;
        BUILD)
            build
            ;;
        TEST)
            tests
            ;;
        CLEAN)
            clean
            ;;
        TFB)
            tfboard
            ;;
        TFBK)
            pids=`ps aux | grep tensorboard | awk '{print $2}'`
            serviceIds=(${pids})
            idsCount=(${#serviceIds[@]} - 1)
            printf "\n%s\n" "tensorboard service ids count: ${idsCount} "
            for (( i=0; i< $idsCount; i++ ));
            do
            :
                serviceId=${serviceIds[$i]}
                printf "\n%s\n" "ServiceId[$i]: ${serviceId} killed! "
                if [ ! -z "$serviceId" ]; then
                    kill -9 ${serviceId} &
                fi
            done
            sleep 5

            ;;
        HELP)
            help
            ;;
        *)
            help # default
            ;;
    esac
else
    echo "Action argument length is ZERO. So, executing default action: Clean, Build"
    help # default
fi  # end of if