## Bash-In-the-Box (BItBox)
## Copyright © 2024 Francesco Napoleoni
##
## This file is part of “Bash-In-the-Box”.
##
## “Bash-In-the-Box” is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## “Bash-In-the-Box” is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with “Bash-In-the-Box”.  If not, see <https://www.gnu.org/licenses/>.


########################################


#/**
# * Provides an API for unit testing.
# */

bib.include _assert


########################################


###############
## CONSTANTS ##
###############

## EXIT STATUSES

#/**
# * Test failed.
# *
# * Default value: 17
# */
readonly BIB_E_TESTFAIL=17


#/**
# * Test skipped.
# *
# * Default value: 18
# */
readonly BIB_E_TESTSKIP=18


########################################


###############
## VARIABLES ##
###############

#/**
# * Verbose mode flag.
# *
# * Default value: BIB_FALSE
# */
declare -gi BIB_UNITTEST_VERBOSE=${BIB_FALSE}


#/**
# * List of tests.
# *
# * This is implemented as an associative array, whose keys are the name of
# * the tests, while the values are boolean flags (0 or 1), used to enable (1)
# * or skip (0) the execution of each test.
# */
declare -gA bib_unittest_tests


#/**
# * Tests order.
# *
# * It should contain the ordered list of the test names.
# */
declare -ga bib_unittest_tests_order


#/**
# * Contains the name of the currently running test.
# */
declare bib_unittest_current_test


#/**
# * Results of the tests.
# *
# *
# *
# *
# *
# */
declare -g bib_unittest_last_result


#/**
# * Results of the tests.
# *
# *
# *
# *
# *
# */
declare -gA bib_unittest_results


########################################


###############
## FUNCTIONS ##
###############

#/**
# * NO-OP STUB
# */
function setup() { : ; }


#/**
# * NO-OP STUB
# */
function teardown() { : ; }


function bib.unittest.run() {
    local _args=${@:-${!bib_unittest_tests[@]}}
    local -a _tests=()
    local _test
    local -i _i
    local -i _status=${BIB_E_OK}

    (( ${#bib_unittest_tests_order} )) || bib_unittest_tests_order=( ${!bib_unittest_tests[@]} )

    for ((_i=0; _i<${#bib_unittest_tests_order[@]}; _i++))
    do
        [[ ${_args} =~ ${bib_unittest_tests_order[${_i}]} ]] && _tests+=( "${bib_unittest_tests_order[${_i}]}" )
    done

    for _test in ${_tests[@]}
    do
        bib_unittest_current_test="${_test}"

        printf "%s: " "${_test}"
        (( BIB_UNITTEST_VERBOSE )) && printf "\n"
        if (( ! bib_unittest_tests["${_test}"] ))
        then
            printf "S\n"
            bib_unittest_results["${_test}"]="S"
            continue
        fi

        test_${_test} || _status=${BIB_E_NOK}

        printf "\n"

        bib_unittest_current_test=""
    done

    return ${_status}
}


function bib.unittest.stats() {
    local _test
    local _failed

    bib.print "Results:\n"
    for _test in ${!bib_unittest_results[@]}
    do
        bib.print "${_test}: "
        if [[ "${bib_unittest_results["${_test}"]}" == "S" ]]
        then
            bib.print "SKIPPED\n"
            continue
        fi

        _failed="${bib_unittest_results["${_test}"]//./}"
        local _values=(
            ${#bib_unittest_results["${_test}"]}
            ${#_failed}
        )

        bib.print -v _values "%d assertions, %d failed\n"
    done
}


#/**
# * Tests arguments against a predicate.
# *
# * This is the main function of this simple unit testing framework. It works
# * by leveraging the assertion API
# * If the condition is met, BIB_E_OK is returned, BIB_E_ASSERTION
# *
# * otherwise. In the latter case this function causes the script to exit.
# * This behaviour can be inhibited using option “-n”.
# *
# * Depending on the case, trapping EXIT pseudosignal may be needed.
# *
# * Syntax: bib.unittest.assert [PREDICATE [ARGUMENT ...]]
# *
# * Options:
# *
# * -n : prevents the script from exiting in case of failed assertion
# *
# * @param PREDICATE the name of the condition that is to be checked
# * @param ARGUMENT one or more values to be checked against a condition
# * @return BIB_E_OK if assertion is successful, BIB_E_TESTFAIL otherwise
# */
function bib.unittest.assert() {
    local -i _status=${BIB_E_TESTFAIL}
    local -i _status_extglob=${BIB_E_NOK}
    local _message
    local _predicate
    local _result="F"
    local -i _verbose=${BIB_UNITTEST_VERBOSE}

    local OPTION
    local OPTIND
    while getopts "m:v" OPTION
    do
        case "${OPTION}" in
            "m" )
                _message="${OPTARG}"
            ;;

            "v" )
                _verbose=${BIB_TRUE}
            ;;
        esac
    done

    shift $((${OPTIND} - 1))

    _predicate="${1}"
    shift

    [[ ${_verbose} == ${BIB_TRUE} && -n "${_message}" ]] && bib.print -n "${_message}\n"

    shopt extglob &> /dev/null && _status_extglob=${BIB_E_OK}
    bib.ok ${_status_extglob} || shopt -s extglob

    if bib.assert -n "${_predicate}" "${@}"
    then
        _result="."
        _status=${BIB_E_OK}
    fi

    if (( _verbose ))
    then
        bib.print -n "\n"

        if ! bib.ok ${_status}
        then
            local -a _values
            [[ "${_predicate}" == ?(n)"eq" ]] && _values=( "${1}" "${2}" ) || _values=( "${BIB_ASSERT_PREDICATES_EXPECTED["${_predicate}"]}" "${1}" )
            bib.ok ${_status_extglob} && shopt -u extglob
            bib.print -n -v _values "Test failed: expected: “%s”, got “%s”\n"
        else
            bib.print -n "OK\n"
        fi
    else
        printf "%s" "${_result}"
    fi
    bib_unittest_results["${bib_unittest_current_test}"]+="${_result}"
    return ${_status}
}


########################################


BIB_ASSERT_ENABLE=${BIB_TRUE}

(( BIB_CONFIG["unittest.verbose"] )) && BIB_UNITTEST_VERBOSE=${BIB_TRUE}
