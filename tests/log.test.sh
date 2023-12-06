declare -A conf=(
    ["debug"]=1
    ["log.debug"]=1
    ["interactive"]=1
    ["name"]="log_lib_test"
    ["longname"]="“log” library test"
    ["unittest.verbose"]=0
    ["style"]=0
    ["log.dir"]="/tmp/bitbox-test"
)

mkdir /tmp/bitbox-test

source ${BIB_HOME}/bitbox/main.lib.sh conf
bib.include log
bib.include unittest.unittest

bib_unittest_tests=(
    ["log_to_file"]=1
    ["log_to_stderr"]=1
    ["log_to_syslog"]=1
)


function teardown() {
    rm -f "${BIB_LOG_DIR}/${BIB_LOG_FILENAME}"
    rm -rf /tmp/bitbox-test
}

function test_log_to_file() {
    local _message
    local _regexp='- \[[a-z]+\] .*\[[0-9]+\] ?.*\(?\)?:'
    local -i _status=${BIB_E_OK}

    bib.log -c file d "Test log message to file"
    bib.unittest.assert \
        -m "Test log message to file “${BIB_LOG_DIR}/${BIB_LOG_FILENAME}” - check exit status" \
        ok ${?} \
        || _status=${BIB_E_TESTFAIL}

    _message="$(< ${BIB_LOG_DIR}/${BIB_LOG_FILENAME})"

#     bib.print "${_message}\n"
    [[ "${_message}" =~ ${_regexp} ]]
    bib.unittest.assert \
        -m "Test log message to file “${BIB_LOG_DIR}/${BIB_LOG_FILENAME}” - check log string" \
        ok ${?} \
        || _status=${BIB_E_TESTFAIL}

    return ${_status}
}

function test_log_to_stderr() {
    local _message
    local _regexp='- \[[a-z]+\] .*\[[0-9]+\] ?.*\(?\)?:'
    local -i _status=${BIB_E_OK}

    _message=$(bib.log -c stderr w "Test log message to stderr" 2>&1)
    bib.unittest.assert \
        -m "Test log message to stderr - check exit status" \
        ok ${?} \
        || _status=${BIB_E_TESTFAIL}

#     bib.print "${_message}\n"
    [[ "${_message}" =~ ${_regexp} ]]
    bib.unittest.assert \
        -m "Test log message to stderr - check log string" \
        ok ${?} \
        || _status=${BIB_E_TESTFAIL}

    return ${_status}
}

function test_log_to_syslog() {
    local _message
    local _regexp='.*\[[0-9]+\] ?.*\(?\)?:'
    local -i _status=${BIB_E_OK}

    _message=$(bib.log -c syslog e "Test log message to syslog" 2>&1)
    bib.unittest.assert \
        -m "Test log message to syslog - check exit status" \
        ok ${?} \
        || _status=${BIB_E_TESTFAIL}

#     bib.print "${_message}\n"
    [[ "${_message}" =~ ${_regexp} ]]
    bib.unittest.assert \
        -m "Test log message to syslog - check log string" \
        ok ${?} \
        || _status=${BIB_E_TESTFAIL}

    return ${_status}
}
