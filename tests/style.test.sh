declare -A conf=(
    ["interactive"]=1
    ["style"]=1
    ["unittest.verbose"]=0
)

source ${BIB_HOME}/bitbox/main.lib.sh conf

bib.include unittest.unittest


bib_unittest_tests=(
    ["style"]=1
)


function test_style() {
    local -a _strings=(
        "Nel mezzo del cammin di nostra vita"
        "/Nel mezzo/ del cammin di nostra vita"
        "/Nel -mezzo/ del- *cammin* di _*nostra*_ vita"
        "&GRN/Nel -mezzo/ del- &LRD*cammin* di _*nostra*_&DEF vita"
    )
    local -a _expected=(
        "Nel mezzo del cammin di nostra vita"
        '\e[3mNel mezzo\e[23m del cammin di nostra vita\e[0m'
        '\e[3mNel \e[9mmezzo\e[23m del\e[29m \e[1mcammin\e[21m di \e[4m\e[1mnostra\e[21m\e[24m vita\e[0m'
        '\e[32m\e[3mNel \e[9mmezzo\e[23m del\e[29m \e[91m\e[1mcammin\e[21m di \e[4m\e[1mnostra\e[21m\e[24m\e[39m vita\e[0m'
    )
    local -i _i
    local _string
    local _status=${BIB_E_OK}

    for ((_i=0; _i<${#_strings[@]}; _i++))
    do
        (( BIB_UNITTEST_VERBOSE )) && time bib.print -n "${_strings[${_i}]}\n"
        (( BIB_UNITTEST_VERBOSE )) && time bib.print "${_strings[${_i}]}\n"
        _string="$(bib.style "${_strings[${_i}]}")"
        bib.unittest.assert -m "Test string $(( _i + 1 ))" eq "${_expected[${_i}]}" "${_string}" || _status=${BIB_E_TESTFAIL}
    done

    return ${_status}
}
