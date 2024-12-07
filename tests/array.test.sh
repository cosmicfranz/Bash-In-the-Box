declare -A conf=(
    ["interactive"]=1
    ["unittest.verbose"]=0
    ["style"]=0
)

source ${BIB_HOME}/bitbox/main.lib.sh conf

bib.include unittest.unittest
bib.include array


bib_unittest_tests=(
    ["contains"]=1
    ["copy"]=1
    ["equal"]=1
    ["equal_not_equal"]=1
    ["exists"]=1
    ["merge"]=1
    ["filter"]=1
)

declare -a test_array_1=(
    "Athos"
    "Porthos"
    "Aramis"
    "D’Artagnan"
)

declare -A test_array_2=(
    ["foo"]="Athos"
    ["bar"]="Porthos"
    ["baz"]="Aramis"
)

declare -a test_array_3=(
    "Athos"
    "Porthos"
    "Aramis"
    "D’Artagnan"
)

declare -a test_array_4=(
    "Athos"
    "Porthos"
    "Aramis"
)

declare -A test_array_5=(
    ["foo"]="Athos"
    ["bar"]="Porthos"
    ["baz"]="Aramis"
)

declare -a test_array_6=(
    "Chip"
    "Dale"
)

declare -A test_array_7=(
    ["foo"]="Luciano Pavarotti"
    ["bar"]="Plácido Domingo"
    ["beer"]="José Carreras"
)

declare -a test_array_8
declare -a test_array_9=()

declare -A test_array_10=(
    ["foo"]="Luciano Pavarotti"
    ["bar"]="Plácido Domingo"
)

declare -A test_array_11=(
    ["bar"]="Plácido Domingo"
    ["beer"]="José Carreras"
)

declare -A test_array_12=(
    ["beer"]="José Carreras"
)

declare -a test_array_13=(
    "Luciano Pavarotti"
    "Plácido Domingo"
    "José Carreras"
)


function test_contains() {
    local -i _status=${BIB_E_OK}
    local _value
    local -A _expected=(
        ["D’Artagnan"]=${BIB_E_OK}
        ["Richelieu"]=${BIB_E_NOK}
    )

    for _value in "${!_expected[@]}"
    do
        local _predicate="ok"
        (( _expected["${_value}"] == BIB_E_NOK )) && _predicate="nok"
        bib.array.contains test_array_1 "${_value}"
        bib.unittest.assert \
            -m "Test value “${_value}”" \
            "${_predicate}" ${?} \
            || _status=${BIB_E_TESTFAIL}
    done

    return ${_status}
}


function test_copy() {
    local -i _status=${BIB_E_OK}
    local -a _array_copy_1
    local -A _array_copy_2

    bib.array.copy test_array_1 _array_copy_1
    [[ "${test_array_1[@]}" == "${_array_copy_1[@]}" ]]
    bib.unittest.assert \
        -m "Test copy array 1" \
        ok ${?} \
        || _status=${BIB_E_TESTFAIL}

    bib.array.copy test_array_2 _array_copy_2
    [[ "${!test_array_2[@]}" == "${!_array_copy_2[@]}" \
        && "${test_array_2[@]}" == "${_array_copy_2[@]}" ]]
    bib.unittest.assert \
        -m "Test copy array 2" \
        ok ${?} \
        || _status=${BIB_E_TESTFAIL}

    return ${_status}
}


function test_equal() {
    local -i _status=${BIB_E_OK}

    bib.array.equal test_array_1 test_array_3 # expected to be equal
    bib.unittest.assert \
    -m "Test two equal arrays. a1 = a2" \
    ok ${?} \
    || _status=${BIB_E_TESTFAIL}

    bib.array.equal test_array_3 test_array_1 # expected to be equal
    bib.unittest.assert \
    -m "Test symmetry: a2 = a1" \
    ok ${?} \
    || _status=${BIB_E_TESTFAIL}

    bib.array.equal test_array_1 test_array_1 # expected to be equal
    bib.unittest.assert \
    -m "Test reflexivity: a1 = a1" \
    ok ${?} \
    || _status=${BIB_E_TESTFAIL}

    bib.array.equal test_array_2 test_array_5 # expected to be equal
    bib.unittest.assert \
    -m "Test two equal associative arrays. a3 = a4" \
    ok ${?} \
    || _status=${BIB_E_TESTFAIL}

    bib.array.equal test_array_5 test_array_2 # expected to be equal
    bib.unittest.assert \
    -m "Test symmetry: a4 = a3" \
    ok ${?} \
    || _status=${BIB_E_TESTFAIL}

    bib.array.equal test_array_3 test_array_3 # expected to be equal
    bib.unittest.assert \
    -m "Test reflexivity: a3 = a3" \
    ok ${?} \
    || _status=${BIB_E_TESTFAIL}

    bib.array.equal test_array_8 test_array_9 # expected to be equal
    bib.unittest.assert \
    -m "Test two empty arrays: a5 = a6" \
    ok ${?} \
    || _status=${BIB_E_TESTFAIL}

    bib.array.equal test_array_9 test_array_8 # expected to be equal
    bib.unittest.assert \
    -m "Test reflexivity: a6 = a5" \
    ok ${?} \
    || _status=${BIB_E_TESTFAIL}

    return ${_status}
}


function test_exists() {
    local -i _status=${BIB_E_OK}

    bib.array.exists test_array_7 "foo" # expected to exist
    bib.unittest.assert \
    -m "Test if “foo” exists" \
    ok ${?} \
    || _status=${BIB_E_TESTFAIL}

    bib.array.exists test_array_7 "burp" # expected to not exist
    bib.unittest.assert \
    -m "Test if “burp” exists" \
    nok ${?} \
    || _status=${BIB_E_TESTFAIL}

    return ${_status}
}


function test_merge() {
    local -a _result_1
    local -a _result_2
    local -a _result_3
    local -A _result_4
    local -a _expected_1=(
        "Athos"
        "Porthos"
        "Aramis"
        "D’Artagnan"
        "Chip"
        "Dale"
    )
    local -a _expected_2=(
        "Chip"
        "Dale"
        "Luciano Pavarotti"
        "Plácido Domingo"
        "José Carreras"
    )
    local -n _expected_3="test_array_3"
    local -A _expected_4=(
        ["foo"]="Luciano Pavarotti"
        ["bar"]="Plácido Domingo"
        ["baz"]="Aramis"
        ["beer"]="José Carreras"
    )

    local -i _status=${BIB_E_OK}

    bib.array.merge _result_1 test_array_1 test_array_6

    bib.array.equal _expected_1 _result_1
    bib.unittest.assert \
    -m "Test merge two non-empty arrays with numeric indexes" \
    ok ${?} \
    || _status=${BIB_E_TESTFAIL}

    bib.array.merge _result_2 test_array_6 test_array_13

    bib.array.equal _expected_2 _result_2
    bib.unittest.assert \
    -m "Test merge two non-empty indexed arrays containing spaces inside values" \
    ok ${?} \
    || _status=${BIB_E_TESTFAIL}

    bib.array.merge _result_3 test_array_1 test_array_9
    bib.array.equal _expected_3 _result_3
    bib.unittest.assert \
    -m "Test merge array 1 with numeric indexes - array 2 empty" \
    ok ${?} \
    || _status=${BIB_E_TESTFAIL}

    bib.array.merge _result_4 test_array_5 test_array_7
    bib.array.equal _expected_4 _result_4
    bib.unittest.assert \
    -m "Test merge two non-empty associative arrays" \
    ok ${?} \
    || _status=${BIB_E_TESTFAIL}

    return ${_status}
}


function test_equal_not_equal() {
    local -i _status=${BIB_E_OK}

    bib.array.equal test_array_1 test_array_2 # expected to be different
    bib.unittest.assert \
    -m "Test two different arrays: a1 != a2" \
    nok ${?} \
    || _status=${BIB_E_TESTFAIL}

    bib.array.equal test_array_2 test_array_1 # expected to be different
    bib.unittest.assert \
    -m "Test Test symmetry: a2 != a1" \
    nok ${?} \
    || _status=${BIB_E_TESTFAIL}

    bib.array.equal test_array_3 test_array_4 # expected to be different
    bib.unittest.assert \
    -m "Test two different arrays: a3 != a4" \
    nok ${?} \
    || _status=${BIB_E_TESTFAIL}

    bib.array.equal test_array_4 test_array_3 # expected to be different
    bib.unittest.assert \
    -m "Test Test symmetry: a4 != a3" \
    nok ${?} \
    || _status=${BIB_E_TESTFAIL}

    bib.array.equal test_array_3 test_array_8 # expected to be different
    bib.unittest.assert \
    -m "Test with empty array: a3 != a5" \
    nok ${?} \
    || _status=${BIB_E_TESTFAIL}

    bib.array.equal test_array_8 test_array_3 # expected to be different
    bib.unittest.assert \
    -m "Test Test symmetry: a5 != a3" \
    nok ${?} \
    || _status=${BIB_E_TESTFAIL}

    return ${_status}
}


function test_filter() {
    local -i _status=${BIB_E_OK}
    local -a _filter_1=(
        "beer"
    )

    local -a _filter_2=(
        "Luciano Pavarotti"
    )

    local -A _array_filtered_1
    local -A _array_filtered_2

    bib.array.filter -f _filter_1 \
        test_array_7 \
        _array_filtered_1
    bib.array.equal _array_filtered_1 test_array_10
    bib.unittest.assert \
        -m "Test filter on array 1" \
        ok ${?} \
        || _status=${BIB_E_TESTFAIL}

    bib.array.filter -v -f _filter_2 \
        test_array_7 \
        _array_filtered_2
    bib.array.equal _array_filtered_2 test_array_11
    bib.unittest.assert \
        -m "Test filter on array 2" \
        ok ${?} \
        || _status=${BIB_E_TESTFAIL}

    bib.array.filter -r -f _filter_1 \
        test_array_7 \
        _array_filtered_1
    bib.array.equal _array_filtered_1 test_array_12
    bib.unittest.assert \
        -m "Test reverse filter on array 1" \
        ok ${?} \
        || _status=${BIB_E_TESTFAIL}

    return ${_status}
}
