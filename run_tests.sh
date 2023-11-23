#!/bin/bash


declare -a tests=(
    "main"
    "style"
    "filedir"
    "array"
    "cfg"
)

declare -A tests_enabled=(
    ["main"]=1
    ["style"]=1
    ["filedir"]=1
    ["array"]=1
    ["cfg"]=1
)

declare -A tests_results

declare -A conf=(
    ["interactive"]=1
    ["name"]="bitbox_test"
    ["longname"]="Bash-In-the-Box test suite"
    ["unittest.verbose"]=0
    ["style"]=1
    ["version"]="0.1"
)

source ${BIB_HOME}/bitbox/main.lib.sh conf
bib.include unittest.unittest

declare test_path="tests"
declare -i status=${BIB_E_OK}


########################################


###############
## FUNCTIONS ##
###############

function run_test() {
    local _test_name
    local _test_path
    local _test_code
    local -i __status=${BIB_E_OK}

    _test_name="${1}"

    _test_path+="${test_path}/${_test_name}.test.sh"

    [[ -f "${_test_path}" ]] || return ${BIB_E_NEXISTS}

    _test_code="declare -i status=\${BIB_E_OK}

$(<"${_test_path}")


########################################


setup
bib.unittest.run \"\${@}\" || status=\${BIB_E_TESTFAIL}
teardown
bib.print -n '\n'
bib.unittest.stats

exit \${status}
"
    (/bin/bash -c "${_test_code}") || __status=${BIB_E_TESTFAIL}

    return ${__status}
}


########################################


# trap 'echo "Ciao!"' ERR

for test in ${tests[@]}
do
    if (( tests_enabled["${test}"] ))
    then
        bib.print "Testing “${test}”\n"

        run_test "${test}"
        case ${?} in
            ${BIB_E_NEXISTS} )
                bib.print "&RED*Test “${test}” not found in path*\n"
                status=${BIB_E_NOK}
            ;;

            ${BIB_E_TESTFAIL} )
                bib.print "&YLW*Test “${test}” failed*\n"
                status=${BIB_E_NOK}
            ;;

            ${BIB_E_OK} )
                bib.print "&GRN*Test “${test}” OK*\n"
            ;;
        esac

    else
        bib.print "*Test “${test}” skipped*\n"
    fi
done

exit ${status}
