declare -A conf=(
    ["interactive"]=1
    ["name"]="cfg_lib_test"
    ["longname"]="“cfg” library test"
    ["unittest.verbose"]=0
    ["style"]=0
    ["cfg.continue_on_error"]=1
)

source ${BIB_HOME}/bitbox/main.lib.sh conf
bib.include cfg
bib.include array
bib.include unittest.unittest

bib_unittest_tests=(
    ["from_file_1"]=1
    ["from_file_2"]=1
    ["from_file_3"]=1
    ["from_file_4"]=1
    ["from_file_5"]=0
)

temp_dir=/tmp
test_dir=${temp_dir}/cfg_test


function setup() {
    mkdir ${test_dir}

    # empty file
    touch ${test_dir}/conf01.conf

    # file containing no mappings
    echo "# comment" > ${test_dir}/conf02.conf

    # file containing valid mappings, comments and empty lines
    cat > ${test_dir}/conf03.conf << EOF
boh=ciao
mah =miao  perepè
   mah.2  = arimiao
# comment

x=
y=   
EOF


    # file containing valid and invalid mappings, comments and empty lines
    cat > ${test_dir}/conf04.conf << EOF
boh=ciao
=abc
   = abc

mah =miao
mah.2  = arimiao
# comment

bleah
/sb=3


x=
y=   
EOF


    # file containing valid mappings and variable references
    cat > ${test_dir}/conf05.conf << EOF
boh=ciao
mah =miao
mah.2  = %(boh) arimiao
# comment

bleah=%(mah.2)%(boh)
sb=%3
EOF
}

function teardown() {
    rm -rf ${test_dir}
}

function test_from_file_1() {
    local -i _status=${BIB_E_OK}
    local -A _cfg

    bib.cfg.from_file -f "${test_dir}/conf01.conf" -n _cfg
    bib.unittest.assert \
        -m "Test read empty file - exit status" \
        ok ${?} \
        || _status=${BIB_E_TESTFAIL}

    bib.unittest.assert \
        -m "Test read empty file - check status array" \
        eq 0 \
        ${#BIB_CFG_STATUS[@]} \
        || _status=${BIB_E_TESTFAIL}

    return ${_status}
}

function test_from_file_2() {
    local -i _status=${BIB_E_OK}
    local -A _cfg

    bib.cfg.from_file -f "${test_dir}/conf02.conf" -n _cfg
    bib.unittest.assert \
        -m "Test read file containing no mappings - exit status" \
        ok ${?} \
        || _status=${BIB_E_TESTFAIL}

    bib.unittest.assert \
        -m "Test read file containing no mappings - check status array" \
        eq 0 \
        ${#BIB_CFG_STATUS[@]} \
        || _status=${BIB_E_TESTFAIL}

    return ${_status}
}

function test_from_file_3() {
    local -i _status=${BIB_E_OK}
    local -A _cfg
    local -A _expected_cfg=(
        ["boh"]="ciao"
        ["mah"]="miao  perepè"
        ["mah.2"]="arimiao"
        ["x"]=
        ["y"]=
    )

    bib.cfg.from_file -f "${test_dir}/conf03.conf" -n _cfg
    bib.unittest.assert \
        -m "Test read file containing valid mappings, comments and empty lines - exit status" \
        ok ${?} \
        || _status=${BIB_E_TESTFAIL}

    bib.unittest.assert \
        -m "Test read file containing valid mappings, comments and empty lines - check status array" \
        eq 0 \
        ${#BIB_CFG_STATUS[@]} \
        || _status=${BIB_E_TESTFAIL}

#     declare -p _cfg
#     declare -p _expected_cfg

    bib.array.equal _cfg _expected_cfg
    bib.unittest.assert \
        -m "Test read file containing valid mappings, comments and empty lines - check result" \
        ok ${?} \
        || _status=${BIB_E_TESTFAIL}

    return ${_status}
}

function test_from_file_4() {
    local -i _status=${BIB_E_OK}
    local -A _cfg
    local -A _expected_cfg=(
        ["boh"]="ciao"
        ["mah"]="miao"
        ["mah.2"]="arimiao"
        ["x"]=
        ["y"]=
    )

    bib.cfg.from_file -f "${test_dir}/conf04.conf" -n _cfg
    bib.unittest.assert \
        -m "Test read file containing valid and invalid mappings, comments and empty lines - exit status" \
        nok ${?} \
        || _status=${BIB_E_TESTFAIL}

    bib.unittest.assert \
        -m "Test read file containing valid and invalid mappings, comments and empty lines - check status array" \
        eq 4 \
        ${#BIB_CFG_STATUS[@]} \
        || _status=${BIB_E_TESTFAIL}

#     declare -p _cfg
#     declare -p _expected_cfg

    bib.array.equal _cfg _expected_cfg
    bib.unittest.assert \
        -m "Test read file containing valid and invalid mappings, comments and empty lines - check result" \
        ok ${?} \
        || _status=${BIB_E_TESTFAIL}

    return ${_status}
}

function test_from_file_5() {
    local -i _status=${BIB_E_OK}
    local -A _cfg
    local -A _expected_cfg=(
        ["boh"]="ciao"
        ["mah"]="miao"
        ["mah.2"]="ciao arimiao"
        ["bleah"]="ciao arimiaociao"
        ["sb"]="%3"
    )

    bib.cfg.from_file -f "${test_dir}/conf05.conf" _cfg
    bib.unittest.assert \
        -m "Test read file containing valid mappings and variable references - exit status" \
        ok ${?} \
        || _status=${BIB_E_TESTFAIL}

    bib.unittest.assert \
        -m "Test read file containing valid mappings and variable references - check status array" \
        eq 0 \
        ${#BIB_CFG_STATUS[@]} \
        || _status=${BIB_E_TESTFAIL}

    declare -p _cfg
    declare -p _expected_cfg

    bib.array.equal _cfg _expected_cfg
    bib.unittest.assert \
        -m "Test read file containing valid mappings and variable references - check result" \
        ok ${?} \
        || _status=${BIB_E_TESTFAIL}

    return ${_status}
}
