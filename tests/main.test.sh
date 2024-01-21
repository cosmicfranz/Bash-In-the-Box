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


bib_unittest_tests=(
    ["basename"]=1
    ["contains"]=1
    ["dirname"]=1
    ["normalize"]=1
    ["print"]=1
    ["relative"]=1
    ["shopt"]=1
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


function test_normalize() {
    local -i _status=${BIB_E_OK}
    local -A _expected=(
        ["aa/bb/cc.txt"]="aa/bb/cc.txt"
        ["/aa/bb/cc.txt"]="/aa/bb/cc.txt"
        ["//aa/bb/cc.txt"]="/aa/bb/cc.txt"
        ["/aa/bb////cc.txt"]="/aa/bb/cc.txt"
        ["/aa/bb"]="/aa/bb"
        ["////aa//bb/"]="/aa/bb/"
        ["//aa////bb//"]="/aa/bb/"
        ["aa/bb///"]="aa/bb/"
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
                "$(bib.normalize "${_path}")" \
            || _status=${BIB_E_TESTFAIL}
    done

    return ${_status}
}


function test_print() {
    local -a _vari=(
        "Francesco"
        'come stai?'
    )

    local _risultato=$(bib.print -d 1 -v _vari "Ciao %s, %s %s\n" "Spero bene.")

    bib.unittest.assert eq "${_risultato}" "Ciao Francesco, come stai? Spero bene."
}


function test_relative() {
    local -i _status=${BIB_E_OK}
    local -A _expected=(
        ["aa/bb/cc.txt"]="aa/bb/cc.txt"
        ["/aa/bb/cc.txt"]="aa/bb/cc.txt"
        ["//aa/bb/cc.txt"]="aa/bb/cc.txt"
        ["/aa/bb////cc.txt"]="aa/bb////cc.txt"
        ["/aa/bb"]="aa/bb"
        ["////aa//bb/"]="aa//bb/"
        ["//aa////bb//"]="aa////bb//"
        ["aa/bb///"]="aa/bb///"
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
                "$(bib.relative "${_path}")" \
            || _status=${BIB_E_TESTFAIL}
    done

    return ${_status}
}


function test_shopt() {
    local -i _status=${BIB_E_OK}
    local _shopt_option
    local _shopt_initial_state


    # Valid option: extglob
    _shopt_option=( $(shopt extglob) )
    _shopt_initial_state="${_shopt_option[1]}"
    shopt -u extglob

    for (( _i=1; _i<=2; _i++ ))
    do
        bib.shopt -s extglob

        bib.unittest.assert \
            -m "Test set valid option (#${_i}) - exit status" \
            ok ${?} \
            || _status=${BIB_E_TESTFAIL}

        _shopt_option=( $(shopt extglob) )

        bib.unittest.assert \
            -m "Check option (#${_i}) - exit status" \
            ok "${?}" \
            || _status=${BIB_E_TESTFAIL}

        bib.unittest.assert \
            -m "Test set valid option (#${_i})" \
            eq  "on" \
                "${_shopt_option[1]}" \
            || _status=${BIB_E_TESTFAIL}
    done

    # Invalid option: invalidoption
    bib.shopt -s invalidoption &> /dev/null

    bib.unittest.assert \
        -m "Test set invalid option - exit status" \
        nok ${?} \
        || _status=${BIB_E_TESTFAIL}

    _shopt_option=( $(shopt invalidoption 2> /dev/null ) )

    bib.unittest.assert \
        -m "Test set invalid option" \
        null "${_shopt_option[1]}" \
        || _status=${BIB_E_TESTFAIL}


    # unset extglob
    for (( _i=1; _i<=2; _i++ ))
    do
        bib.shopt -u extglob

        bib.unittest.assert \
            -m "Test unset option (#${_i}) - exit status" \
            ok ${?} \
            || _status=${BIB_E_TESTFAIL}

        _shopt_option=( $(bib.shopt extglob) )

        bib.unittest.assert \
            -m "Check option (#${_i}) - exit status" \
            nok "${?}" \
            || _status=${BIB_E_TESTFAIL}

        bib.unittest.assert \
            -m "Test unset option (#${_i})" \
            eq  "off" \
                "${_shopt_option[1]}" \
            || _status=${BIB_E_TESTFAIL}
    done

    bib.shopt -r extglob
    _shopt_option=( $(bib.shopt extglob) )

    bib.unittest.assert \
        -m "Test reset option" \
        eq  "off" \
            "${_shopt_option[1]}" \
        || _status=${BIB_E_TESTFAIL}

    return ${_status}
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
