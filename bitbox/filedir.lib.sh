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
# * Contains various functions for file and directory handling.
# */


########################################


###############
## CONSTANTS ##
###############

#/**
# * List of known units of information.
# */
readonly -a _BIB_FILEDIR_UNITS=(
    "B"
    "KiB"
    "MiB"
    "GiB"
    "TiB"
    "PiB"
    "EiB"
    "ZiB"
    "YiB"
)


#/**
# * Sizes of binary multiple-byte units.
# */
readonly -A _BIB_FILEDIR_UNITS_SIZES=(
    ["B"]=1
    ["KiB"]=1024
    ["MiB"]=1048576
    ["GiB"]=1073741824
    ["TiB"]=1099511627776
    ["PiB"]=1125899906842624
    ["EiB"]=1152921504606846976
    ["ZiB"]=1180591620717411303424
    ["YiB"]=1208925819614629174706176
)


########################################


###############
## VARIABLES ##
###############

#/**
# * Toggles “bc” command support.
# *
# * Type: boolean
# * Default value: BIB_FALSE
# */
declare -i _BIB_FILEDIR_ENABLE_BC=${BIB_FALSE}


#/**
# * Filename and path of “bc” command.
# *
# * Type: string
# * Default value: "bc -l"
# */
declare -g BIB_FILEDIR_BC_CMD="bc -l"


########################################


###############
## FUNCTIONS ##
###############

#/**
# * Returns the size (in bytes) of a path.
# *
# * This function is a wrapper of the “du” command, and the size returned
# * is the actual disk usage.
# *
# * Possible exit codes:
# * * BIB_E_OK
# * * BIB_E_NEXISTS if the path does not exists
# * * BIB_E_ACCESS if access to the path is denied
# *
# * Sintassi: bib.filedir.size PATH
# *
# * @param PATH may be a path to a file or to a directory
# * @return the size (in bytes) of a path
# */
function bib.filedir.size() {
    local _path="${1}"
    local _result

    [[ -e "${_path}" ]] || return ${BIB_E_NEXISTS}

    _result=( $(du -sb "${_path}") ) || return ${BIB_E_ACCESS}

    printf ${_result}
    return ${BIB_E_OK}
}


#/**
# * Creates the directory requested.
# *
# * If necessary, parent directories are created too.
# *
# * If the path already exists, the function will return E_NPERM without
# * touching the filesystem.
# *
# * This function is a wrapper of “mkdir” from GNU Coreutils.
# *
# * Syntax: bib.filedir.create_dir PATH
# *
# * @param PATH can be absolute or relative
# */
function bib.filedir.create_dir() {
    local _path="${1}"

    [[ ! -e "${_path}" ]] || return ${BIB_E_NPERM}

    mkdir --parent "${_path}"

    return ${BIB_E_OK}
}


#/**
# * Returns a formatted string of the size (expressed in bytes) in input.
# *
# * The format of the string is
# *
# *     n[.mm...] <unit>
# *
# * and is dependent on current locale.
# *
# * If SIZE is less then 1 KiB (1024 bytes), the resulting string is
# *
# *     <SIZE> B
# *
# * that is, just the number given as input, followed by “B” (bytes).
# *
# * In case of SIZE greater than 1 KiB, the value will be scaled and
# * approximated, and an appropriate unit will be appended, as in the
# * following examples:
# *
# *     1.50 KiB
# *
# * for SIZE = 1536
# *
# *     1023.99 MiB
# *
# * for SIZE = 1048575
# * and so on.
# *
# * It is possible to change the precision by using option “-p”.
# *
# * Arbitrary big numbers are supported, being yobibyte (YiB) the largest
# * unit available.
# *
# * For the sake of efficiency, calculations are done with internal Bash
# * commands for values up to 2^55 -1. Over this threshold, “bc” external
# * command is used.
# *
# * Syntax: bib.filedir.format_size [-p PRECISION] SIZE
# *
# * Options:
# *
# * -p PRECISION (default: 2): the number of digits after decimal point
# *
# * @param SIZE
# * @return a formatted string corresponding to the given size and current
# *         locale
# */
function bib.filedir.format_size() {
    (( ${#} >= 1 )) || return ${BIB_E_ARG}

    local _size
    local _unit="${_BIB_FILEDIR_UNITS[0]}"
    local _temp
    local -i _precision=2
    local -i _number_is_big
    local -i _i

    if [[ "${1}" == "-p" ]]
    then
        (( ${#} == 3 )) || return ${BIB_E_ARG}

        _precision=${2}
        shift 2
    fi

    _size="${1}"
    _number_is_big=$(${BIB_FILEDIR_BC_CMD} <<< "${_size} >= 2^55")

    for ((_i = 0; _i < ${#_BIB_FILEDIR_UNITS[@]}; _i++))
    do
        (( _i < ${#_BIB_FILEDIR_UNITS[@]} - 1 )) \
            && _temp="${_BIB_FILEDIR_UNITS[$(( _i + 1 ))]}"

        if (( ! _number_is_big ))
        then
            (( _size >= ${_BIB_FILEDIR_UNITS_SIZES["${_temp}"]} )) \
                && continue
            (( _i == 0 )) && break

            printf -v _size \
                   "%.${_precision}f" \
                    "$((10 ** ${_precision} \
                    * _size \
                    / 2 ** (_i * 10)))e-${_precision}"
        else
            (( (_i < ${#_BIB_FILEDIR_UNITS[@]} - 1) && \
                $(${BIB_FILEDIR_BC_CMD} <<< "${_size} \
                    >= ${_BIB_FILEDIR_UNITS_SIZES["${_temp}"]}") )) && \
                        continue
            _size="$(${BIB_FILEDIR_BC_CMD} <<< "scale=0; \
            10^${_precision} * ${_size} \
            / 2^(${_i} * 10)")e-${_precision}"
        fi

        _unit="${_BIB_FILEDIR_UNITS[${_i}]}"
        break
    done

    if [[ "${_unit}" == "${_BIB_FILEDIR_UNITS[0]}" ]]
    then
        printf "%d %s" "${_size}" "${_unit}"
    else
        printf "%.${_precision}f %s" "${_size}" "${_unit}"
    fi
}


########################################


[[ -v BIB_CONFIG["filedir.enable_bc"] ]] && _BIB_FILEDIR_ENABLE_BC=$(( BIB_CONFIG["filedir.enable_bc"] || BIB_FALSE ))

# Ensures that no spurious status code is returned
return ${BIB_E_OK}
