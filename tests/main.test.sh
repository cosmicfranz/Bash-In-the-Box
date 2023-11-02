#!/bin/bash

declare -A conf=(
    ["interactive"]=1
    ["name"]="main_lib_test"
    ["longname"]="“main” library test"
    ["unittest.verbose"]=0
    ["style"]=0
    ["version"]="1.2.3"
)

source ${BIB_HOME}/bitbox/main.lib.sh conf

bib.include unittest.unittest


declare -i status=${BIB_E_OK}

bib_unittest_tests=(
    ["basename"]=1
    ["contains"]=1
    ["dirname"]=1
    ["print"]=1
    ["shrink"]=1
    ["title"]=1
    ["today"]=1
    ["version"]=1
)


function test_basename() {
    local -i _status=${BIB_E_OK}
    local -A _expected=(
        ["aa/bb/cc.txt"]="cc.txt"
        ["/aa/bb/cc.txt"]="cc.txt"
        ["//aa/bb/cc.txt"]="cc.txt"
        ["/aa/bb////cc.txt"]="cc.txt"
        ["/aa/bb"]="bb"
        ["/aa/bb/"]="bb"
        ["/aa/bb//"]="bb"
        ["/aa/bb///"]="bb"
        ["/"]="/"
        ["//"]="/"
        ["///"]="/"
    )
    local _path

    for _path in "${!_expected[@]}"
    do
        bib.unittest.assert \
            -m "Test “${_path}”" \
            eq  "${_expected["${_path}"]}" \
                "$(bib.basename "${_path}")" \
            || _status=${BIB_E_TESTFAIL}
    done

    return ${_status}
}

function test_contains() {
    local -i _status=${BIB_E_OK}
    local _substring
    local -A _expected=(
        ["a"]=${BIB_E_OK}
        ["ciao"]=${BIB_E_OK}
        [" "]=${BIB_E_OK}
        ["90"]=${BIB_E_OK}
        ["Ciao"]=${BIB_E_NOK}
        ["£*"]=${BIB_E_NOK}
        ["1 2"]=${BIB_E_NOK}
    )

    for _substring in "${!_expected[@]}"
    do
        bib.contains \
            "${_substring}" \
            "ciao Francesco, ciao. 1234567890"
        bib.unittest.assert \
            -m "Test substring “${_substring}”" \
            eq  ${_expected["${_substring}"]} \
                ${?} \
            || _status=${BIB_E_TESTFAIL}
    done

    bib.contains "" "ciao Francesco, ciao. 1234567890"
    bib.unittest.assert \
        -m "Test empty string" \
        nok ${?} \
        || _status=${BIB_E_TESTFAIL}

    # No arguments given
    bib.contains
    bib.unittest.assert \
        -m "Test no arguments given" \
        eq  ${BIB_E_ARG} \
            ${?} \
        || _status=${BIB_E_TESTFAIL}

    # One argument given
    bib.contains "a"
    bib.unittest.assert \
        -m "Test one argument given" \
        eq  ${BIB_E_ARG} \
            ${?} \
        || _status=${BIB_E_TESTFAIL}

    # Three arguments given
    bib.contains "a" "b" "c"
    bib.unittest.assert \
        -m "Test three arguments given" \
        eq  ${BIB_E_ARG} \
        ${?} \
    || _status=${BIB_E_TESTFAIL}

    return ${_status}
}


function test_dirname() {
    local -i _status=${BIB_E_OK}
    local -A _expected=(
        ["aa/bb/cc.txt"]="aa/bb"
        ["/aa/bb/cc.txt"]="/aa/bb"
        ["//aa/bb/cc.txt"]="/aa/bb"
        ["/aa/bb////cc.txt"]="/aa/bb"
        ["/aa/bb"]="/aa"
        ["////aa/bb/"]="/aa"
        ["/aa/bb//"]="/aa"
        ["/aa/bb///"]="/aa"
        ["/"]="/"
        ["//"]="/"
        ["///"]="/"
    )
    local _path

    for _path in "${!_expected[@]}"
    do
        bib.unittest.assert \
            -m "Test “${_path}”" \
            eq  "${_expected["${_path}"]}" \
                "$(bib.dirname "${_path}")" \
            || _status=${BIB_E_TESTFAIL}
    done

    return ${_status}
}


function test_print() {
    local -a _vari=(
        "Francesco"
        'come stai?'
    )

    local _risultato=$(bib.print -v _vari "Ciao %s, %s %s\n" "Spero bene.")

    bib.unittest.assert eq "${_risultato}" "Ciao Francesco, come stai? Spero bene."
}

function test_shrink() {
    bib.unittest.assert eq "$(bib.shrink " a    43  hrr     ")" "a 43 hrr"
}

function test_title() {
    bib.unittest.assert eq "$(bib.title)" "“main” library test 1.2.3"
#     bib.unittest.assert eq "$(bib.title)" "main_lib_test 1.2.3"
#    bib.unittest.assert eq "$(bib.title)" "main_lib_test"
}

function test_today() {
    bib.unittest.assert ok $([[ "$(bib.today)" =~ ^[0-9]{8}$ ]])
}

function test_version() {
    local -A _assertions=(
        ['bib.version']='^[0-9]+[.][0-9]+'
        ['bib.version -c']='[(][0-9]{8}[)]$'
        ['bib.version -r']='[-]?[a-z0-9]*$'
    )
    local _cmd
    local -i _status=${BIB_E_OK}

    for _cmd in "${!_assertions[@]}"
    do
        [[ "$(eval ${_cmd})" =~ ${_assertions["${_cmd}"]} ]]
        bib.unittest.assert ok ${?} || _status=${BIB_E_TESTFAIL}
    done

    return ${_status}
}


########################################


bib.unittest.run ${@} || status=${BIB_E_NOK}
bib.print -n "\n"
bib.unittest.stats

exit ${status}
