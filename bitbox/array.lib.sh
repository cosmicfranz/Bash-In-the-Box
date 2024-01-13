## Bash-In-the-Box (BItBox)
## Copyright © 2024 Francesco Napoleoni
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
# * Tools for array manipulation.
# */


########################################


###############
## CONSTANTS ##
###############


####################

## CONSTANTS INITIALIZED AT RUNTIME


########################################


###############
## VARIABLES ##
###############


########################################


###############
## FUNCTIONS ##
###############

#/**
# * Checks if an element is present in an array.
# *
# * Returns BIB_E_OK if the element is found at least once, BIB_E_NOK otherwise.
# *
# * This function is implemented as pure Bash code and makes use of wildcards.
# *
# * Syntax: bib.array.contains HAYSTACK NEEDLE
# *
# * @param HAYSTACK the array to test
# * @param NEEDLE the element to find
# * @return BIB_E_OK if at least one occurrence of NEEDLE is found, BIB_E_NOK
# *         otherwise. BIB_E_ARG is returned if wrong number of arguments is
# *         given.
# */
function bib.array.contains() {
    local -n _haystack="${1}"
    local _needle="${2}"

    [[ " ${_haystack[*]} " == *" ${_needle} "* ]]
}


#/**
# * Duplicates an array.
# *
# * This function is just syntactic sugar for bib.array.filter().
# *
# * Syntax: bib.array.copy SOURCE DESTINATION
# *
# * @param SOURCE the name of the array to be copied
# * @param DESTINATION the name of the resulting array. Any previous contents
# *                    will be cleared
# */
function bib.array.copy() {
    (( ${#} == 2 )) || return ${BIB_E_ARG}

    bib.array.filter ${1} ${2}
}


#/**
# * Tests two arrays for equality.
# *
# * Two arrays are intended equal if and only if all the following conditions
# * are true:
# * * they have the same cardinality (the same number of elements)
# * * for each key-value pair (k1, v1) in the first array, there must be one
# *   and only one pair (k2, v2) in the second array such that k1 = k2 and
# *   v1 = v2
# *
# * Syntax: bib.array.equal ARRAY1 ARRAY2
# *
# * @param ARRAY1
# * @param ARRAY2
# *
# * Exit codes:
# * * BIB_E_OK if the two arrays are equal
# * * BIB_E_NOK otherwise
# * * BIB_E_ARG if the number of passed arguments is not 2
# */
function bib.array.equal() {
    (( ${#} == 2 )) || return ${BIB_E_ARG}
    [[ "${1}" == "${2}" ]] && return ${BIB_E_OK}

    local -i _status=${BIB_E_OK}
    local -n _array1="${1}"
    local -n _array2="${2}"
    local _key

    if (( ${#_array1[@]} == ${#_array2[@]} ))
    then
        for _key in ${!_array1[@]}
        do
            if [[ "${_array1["${_key}"]}" != "${_array2["${_key}"]}" ]]
            then
                _status=${BIB_E_NOK}
                break
            fi
        done
    else
        _status=${BIB_E_NOK}
    fi

    return ${_status}
}


#/**
# * Checks if a key or index is defined in an array.
# *
# * Returns BIB_E_OK if the key or index is set, BIB_E_NOK otherwise.
# *
# * Syntax: bib.array.exists ARRAY KEY_OR_INDEX
# *
# * @param ARRAY the array to test
# * @param KEY_OR_INDEX the key to find
# * @return BIB_E_OK if KEY_OR_INDEX is set, BIB_E_NOK otherwise
# */
function bib.array.exists() {
    local -n _array="${1}"
    local _key_or_index="${2}"

    [[ -v _array["${_key_or_index}"] ]]
}


#/**
# * Copies all or part of the content of an array into another.
# *
# * If no filter is specified, source array will be entirely copied on the
# * destination one; on the other hand, if a “filter” array is specified, its
# * matching contents will not be copied on the destination array.
# *
# * The filter can be reversed (option “-r”), i.e. elements in the source array
# * will be copied only if they match those in the filter array.
# *
# * Note that neither source nor filter array are modified during operations.
# *
# * There are two ways to filter an array: by key (or index), or by value. The
# * first is the default mode: the filter array must contain the keys (or
# * indexes) to be filtered from the source array.
# *
# * The second mode, triggered by “-v”, allows values to be specified in the
# * filter array. All occurrences of these values will be searched in the
# * source array and marked for filtering.
# *
# * The complexity of this function is O(n) in the worst case, because the
# * number of iterations is equal to the number of the elements of the source
# * array plus the number of the elements of the filter array. Likewise, memory
# * consumption is linear for copy operation as well as filtering.
# *
# * Syntax: bib.array.filter [OPTIONS] SOURCE DESTINATION
# *
# * Options:
# *
# * -f FILTER : a nameref of a filter array
# * -r : reverse the filter: only elements that match will be copied
# * -v : the filter contains values, rather than keys (or indexes)
# *
# * @param SOURCE the name of the array to be copied or filtered
# * @param DESTINATION the name of the resulting array. Any previous contents
# *                    will be cleared
# */
function bib.array.filter() {
    (( ${#} >= 2 )) || return ${BIB_E_ARG}

    local -n _source
    local -n _destination
    local -n _filter_array
    local -A _filter
    local -i _filter_is_set=${BIB_FALSE}
    local -i _filter_reverse=${BIB_FALSE}
    local -i _filter_on_value=${BIB_FALSE}
    local _key
    local _value

    local OPTION OPTIND
    while getopts ":f:rv" OPTION
    do
        case "${OPTION}" in
            "f" )
                _filter_array=${OPTARG}
                _filter_is_set=${BIB_TRUE}
            ;;

            "r" )
                _filter_reverse=${BIB_TRUE}
            ;;

            "v" )
                _filter_on_value=${BIB_TRUE}
            ;;
        esac
    done

    shift $((OPTIND - 1))

    _source="${1}"
    _destination="${2}"

    _destination=()

    if (( _filter_is_set ))
    then
        if (( _filter_on_value ))
        then
            for _value in "${_filter_array[@]}"
            do
                for _key in "${!_source[@]}"
                do
                    [[ "${_source["${_key}"]}" == "${_value}" ]] && _filter["${_key}"]=0
                done
            done
        else
            for _key in "${_filter_array[@]}"
            do
                [[ -v _source["${_key}"] ]] && _filter["${_key}"]=0
            done
        fi
    fi

    for _key in ${!_source[@]}
    do
        if (( _filter_is_set ))
        then
            [[ ! -v _filter["${_key}"] ]] && _filter["${_key}"]=1
            (( _filter_reverse ^ _filter["${_key}"] )) || continue
        fi

        _destination["${_key}"]="${_source["${_key}"]}"
    done

    return ${MST_E_OK}
}


########################################


