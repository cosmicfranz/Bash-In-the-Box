#!/bin/bash


declare -a tests=(
    "main"
    "style"
    "filedir"
)

declare -A tests_enabled=(
    ["main"]=1
    ["style"]=1
    ["filedir"]=1
)

declare -A tests_results

declare -A conf=(
    ["interactive"]=1
    ["name"]="bitbox_test"
    ["longname"]="Bash-In-the-Box test suite"
    ["unittest.verbose"]=0
    ["style"]=0
    ["version"]="0.1"
)

source ${BIB_HOME}/bitbox/main.lib.sh conf

declare -i status=${BIB_E_OK}


########################################


# trap 'echo "Ciao!"' ERR

for test in ${tests[@]}
do
    if (( tests_enabled["${test}"] ))
    then
        bib.print "\nTesting “${test}”\n"
        (tests/"${test}".test.sh) || status=${BIB_E_NOK}
    else
        bib.print "\nTest “${test}” skipped\n"
    fi
done

exit ${status}
