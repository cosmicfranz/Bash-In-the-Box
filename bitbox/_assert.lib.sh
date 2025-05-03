## Bash-In-the-Box (BItBox)
## Copyright © 2025 Francesco Napoleoni
##
## This file is part of “Bash-In-the-Box”.
##
## “Bash-In-the-Box” is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by the
## Free Software Foundation, either version 3 of the License, or (at your
## option) any later version.
##
## “Bash-In-the-Box” is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
## or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
## more details.
##
## You should have received a copy of the GNU General Public License along with
## “Bash-In-the-Box”. If not, see <https://www.gnu.org/licenses/>.


########################################


#/**
# * Provides an API for assertions.
# */


########################################


###############
## CONSTANTS ##
###############

#/**
# * List of allowed predicates.
# *
# * Zero value means that a predicate is allowed but not enabled.
# */
readonly -A BIB_ASSERT_PREDICATES=(
    ["eq"]=1
    ["neq"]=1
    ["true"]=1
    ["false"]=1
    ["ok"]=1
    ["nok"]=1
    ["null"]=1
    ["nnull"]=1
    ["set"]=1
    ["nset"]=1
)

#/**
# * List of expected results of each predicate.
# */
readonly -A BIB_ASSERT_PREDICATES_EXPECTED=(
    ["true"]="BIB_E_OK"
    ["false"]="BIB_E_NOK"
    ["ok"]="BIB_E_OK"
    ["nok"]="BIB_E_NOK"
    ["null"]="BIB_E_OK"
    ["nnull"]="BIB_E_NOK"
    ["set"]="BIB_E_OK"
    ["nset"]="BIB_E_NOK"
)


## EXIT CODES

#/**
# * Assertion failed exit code.
# *
# * Default value: 16
# */
readonly BIB_E_ASSERTION=16


########################################


###############
## VARIABLES ##
###############

#/**
# * Toggles assertions.
# *
# * Type: boolean
# * Default value: BIB_FALSE
# */
declare -g BIB_ASSERT_ENABLE=${BIB_FALSE}


## VARIABILI DERIVANTI DALLA CONFIGURAZIONE

#/**
# * Contro.
# */
# readonly BIB_COMANDO_NICE_ESEGUIBILE="${mst_conf["comando.nice.eseguibile"]:-$(which nice)}"


########################################


###############
## FUNCTIONS ##
###############

#/**
# * Tests two strings for equality.
# *
# * Returns BIB_E_OK if the two strings in input are equal.
# *
# * Syntax: __bib.assert.eq STRING1 STRING2
# *
# * @param STRING1
# * @param STRING2
# * @return BIB_E_OK if the two strings in input are equal
# */
function __bib.assert.eq() {
    [[ "${1}" == "${2}" ]]
}


#/**
# * Tests two strings for inequality.
# *
# * Returns BIB_E_OK if the two strings in input are different.
# *
# * Syntax: __bib.assert.neq STRING1 STRING2
# *
# * @param STRING1
# * @param STRING2
# * @return BIB_E_OK if the two strings in input are different
# */
function __bib.assert.neq() {
    [[ "${1}" != "${2}" ]]
}


#/**
# * Tests whether argument is “true”.
# *
# * Returns BIB_E_OK if the argument evaluates as “true”, as per Bash
# * construct (( )).
# *
# * Syntax: __bib.assert.true ARGUMENT
# *
# * @param ARGUMENT (integer)
# * @return BIB_E_OK if the argument evaluates as “true”
# */
function __bib.assert.true() {
    local -i _argument=${1}

    (( ${_argument} ))
}


#/**
# * Tests whether argument is “false”.
# *
# * Returns BIB_E_OK if the argument evaluates as “false”, as per Bash
# * construct (( )).
# *
# * Syntax: __bib.assert.false ARGUMENT
# *
# * @param ARGUMENT (integer)
# * @return BIB_E_OK if the argument evaluates as “false”
# */
function __bib.assert.false() {
    local -i _argument=${1}

    (( ! ${_argument} ))
}


#/**
# * Tests whether argument is OK (equals to 0).
# *
# * Useful to test successful exit from a command.
# *
# * Syntax: __bib.assert.ok ARGUMENT
# *
# * @param ARGUMENT (integer)
# * @return BIB_E_OK if the argument is OK
# */
function __bib.assert.ok() {
    local -i _argument=${1}

    (( ${_argument} == ${BIB_E_OK} ))
}


#/**
# * Tests whether argument is NOT OK (non 0).
# *
# * Useful to test unsuccessful exit from a command.
# *
# * Syntax: __bib.assert.nok ARGUMENT
# *
# * @param ARGUMENT (integer)
# * @return BIB_E_OK if the argument is NOT OK
# */
function __bib.assert.nok() {
    local -i _argument=${1}

    (( ${_argument} != ${BIB_E_OK} ))
}


#/**
# * Tests whether argument is “null”.
# *
# * Returns BIB_E_OK if the argument evaluates as “null”, as per Bash
# * construct [[ -z ]].
# *
# * Syntax: __bib.assert.null ARGUMENT
# *
# * @param ARGUMENT
# * @return BIB_E_OK if the argument evaluates as “null”
# */
function __bib.assert.null() {
    [[ -z "${1}" ]]
}


#/**
# * Tests whether argument is “not null”.
# *
# * Returns BIB_E_OK if the argument evaluates as “not nullo”, as per Bash
# * construct [[ -n ]].
# *
# * Syntax: __bib.assert.nnull ARGUMENT
# *
# * @param ARGUMENT
# * @return BIB_E_OK if the argument evaluates as “not null”
# */
function __bib.assert.nnull() {
    [[ -n "${1}" ]]
}


#/**
# * Checks whether a variable is set.
# *
# * The input argument is checked with Bash construct [[ -v ]].
# *
# * It is worth noting that Bash considers a variable “set” the moment it
# * has been assigned a value. This means that the following statement
# *
# *     declare <VARIABILE>
# *
# * fails to meet the condition imposed by this predicate.
# *
# * Conversely, the following statement (note the “=” sign)
# *
# *     declare <VARIABILE>=
# *
# * assigns <VARIABLE> a null value, thus causing this predicate return
# * BIB_E_OK.
# *
# * If variable is an array, it is considered “set” if and only if it
# * contains at least one element.
# *
# * Syntax: __bib.assert.set VARIABLE
# *
# * @param VARIABLE
# * @return BIB_E_OK if variable is “set” (has been assigned a value)
# */
function __bib.assert.set() {
    [[ -v "${1}" ]]
}


#/**
# * Checks whether a variable is not set.
# *
# * Syntax: __bib.assert.nset ARGUMENT
# *
# * @param ARGUMENT
# * @return BIB_E_OK if variable is “not set”
# */
function __bib.assert.nset() {
    [[ ! -v "${1}" ]]
}


#/**
# * Asserts that a certain condition is met.
# *
# * A condition is tested by means of a predicate that takes zero or more
# * arguments.
# *
# * If the condition is met, BIB_E_OK is returned, BIB_E_ASSERTION
# *
# * otherwise. In the latter case this function causes the script to exit.
# * This behaviour can be inhibited using option “-n”.
# *
# * Depending on the case, trapping EXIT pseudosignal may be needed.
# *
# * Syntax: bib.assert [-n] [PREDICATE [ARGUMENT ...]]
# *
# * Options:
# *
# * -n : prevents the script from exiting in case of failed assertion
# *
# * @param PREDICATE the name of the condition that is to be checked
# * @param ARGUMENT one or more values to be checked against a condition
# * @return BIB_E_OK if assertion is successful, BIB_E_ASSERTION otherwise
# */
function bib.assert() {
    (( ${BIB_ASSERT_ENABLE} == ${BIB_TRUE} )) || return ${BIB_E_OK}

    local -i _state=${BIB_E_ASSERTION}
    local -i _exit_on_fail=1
    local _predicate

    if [[ "${1}" == "-n" ]]
    then
        _exit_on_fail=0
        shift
    fi

    _predicate="${1}"

    if (( ${BIB_ASSERT_PREDICATES["${_predicate}"]} ))
    then
        shift 1
        __bib.assert.${_predicate} "${@}" \
            && _state=${BIB_E_OK}
    fi

    (( ${_exit_on_fail} && _state != ${BIB_E_OK} )) && exit ${_state}
    return ${_state}
}


########################################


[[ -v BIB_CONFIG["assert.enable"] ]] && BIB_ASSERT_ENABLE=$(( BIB_CONFIG["assert.enable"] || BIB_FALSE ))

# Ensures that no spurious status code is returned
return ${BIB_E_OK}
