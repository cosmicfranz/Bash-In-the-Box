#!/bin/bash

declare -A conf=(
    ["filedir.enable_bc"]=1
    ["interactive"]=1
    ["name"]="filedir_lib_test"
    ["longname"]="“filedir” library test"
    ["unittest.verbose"]=0
    ["style"]=0
    ["version"]="1.2.3"
)

source ${BIB_HOME}/bitbox/main.lib.sh conf
bib.include filedir
bib.include unittest.unittest


declare -i status=${BIB_E_OK}

bib_unittest_tests=(
    ["create_dir"]=1
    ["format_size"]=1
    ["size"]=1
)

temp_dir=/tmp
test_dir=${temp_dir}/filedir_test
declare -A testfiles_sizes=(
    ['testfile.1']=2532
    ['testfile.2']=10485760
)


function setup() {
    mkdir ${test_dir}

    dd if=/dev/zero of=${test_dir}/testfile.1 bs=${testfiles_sizes["testfile.1"]} count=1
    dd if=/dev/zero of=${test_dir}/testfile.2 bs=1 count=0 seek=${testfiles_sizes["testfile.2"]}
}

function teardown() {
    rm -rf ${test_dir}
}

function test_create_dir() {
    local -i _status=${BIB_E_OK}
    local _dir_name="testdir"

    bib.filedir.create_dir "${test_dir}/${_dir_name}"

    bib.unittest.assert \
        -m "Test create directory “${test_dir}/${_dir_name}”" \
        ok ${?} \
        || _status=${BIB_E_TESTFAIL}

    bib.filedir.create_dir "${test_dir}/${_dir_name}"

    bib.unittest.assert \
        -m "Test try to recreate directory “${test_dir}/${_dir_name}”" \
        eq ${BIB_E_NPERM} \
        ${?} \
        || _status=${BIB_E_TESTFAIL}

    rm -rf "${test_dir}/${_dir_name}"

    return ${_status}
}

function test_format_size() {
    local -i _status=${BIB_E_OK}
    local _size_in_bytes
    local -i _precision
    local -A _expected_p2=(
        ["1"]="1 B"
        ["1024"]="1.00 KiB"
        ["1572864"]="1.50 MiB"
        ["1073741823"]="1023.99 MiB"
        ["1073741824"]="1.00 GiB"
        ["72057594037927935"]="63.99 PiB"
        ["72057594037927936"]="64.00 PiB"
        ["1152921504606846975"]="1023.99 PiB"
        ["1152921504606846976"]="1.00 EiB"
    )
    local -A _expected_p3=(
        ["1"]="1 B"
        ["1024"]="1.000 KiB"
        ["1572864"]="1.500 MiB"
        ["1073741823"]="1023.999 MiB"
        ["1073741824"]="1.000 GiB"
        ["72057594037927935"]="63.999 PiB"
        ["72057594037927936"]="64.000 PiB"
        ["1152921504606846975"]="1023.999 PiB"
        ["1152921504606846976"]="1.000 EiB"
    )
    local -A _expected_p4=(
        ["1"]="1 B"
        ["1024"]="1.0000 KiB"
        ["1572864"]="1.5000 MiB"
        ["1073741823"]="1023.9999 MiB"
        ["1073741824"]="1.0000 GiB"
        ["72057594037927935"]="63.9999 PiB"
        ["72057594037927936"]="64.0000 PiB"
        ["1152921504606846975"]="1023.9999 PiB"
        ["1152921504606846976"]="1.0000 EiB"
    )
    local -A _expected_p6=(
        ["1"]="1 B"
        ["1024"]="1.000000 KiB"
        ["1572864"]="1.500000 MiB"
        ["1073741823"]="1023.999999 MiB"
        ["1073741824"]="1.000000 GiB"
        ["72057594037927935"]="63.999999 PiB"
        ["72057594037927936"]="64.000000 PiB"
        ["1152921504606846975"]="1023.999999 PiB"
        ["1152921504606846976"]="1.000000 EiB"
    )

    for _precision in 2 3 4 6
    do
        local -n _expected="_expected_p${_precision}"
        for _size_in_bytes in "${!_expected[@]}"
        do
            bib.unittest.assert \
                eq  "${_expected["${_size_in_bytes}"]}" \
                    "$(LANG=C bib.filedir.format_size -p ${_precision} "${_size_in_bytes}")" \
                || _status=${BIB_E_TESTFAIL}
        done
        unset _expected
    done

    return ${_status}
}

function test_size() {
    local _filename
    local -i _status=${BIB_E_OK}

    for _filename in "${!testfiles_sizes[@]}"
    do
        bib.unittest.assert \
            eq  ${testfiles_sizes["${_filename}"]} \
                $(bib.filedir.size "${test_dir}/${_filename}") \
            || _status=${BIB_E_TESTFAIL}
    done

    return ${_status}
}


########################################


setup
bib.unittest.run "${@}" || status=${BIB_E_NOK}
teardown
bib.print -n "\n"
bib.unittest.stats

exit ${status}
