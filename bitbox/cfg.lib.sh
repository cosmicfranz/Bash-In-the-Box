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
# * Script configuration manager.
# *
# * Provides a global associative array containing settings loaded from a file.
# *
# * A configuration file contains a list of key = value pairs each representing
# * a specific setting.
# *
# * Keys and values can be expressed in a quite free form; however they are
# * subject to the limits imposed by Bash on associative arrays.
# *
# * A key is a non-empty string before the first “=” (equal) character on a
# * line, and can contain any combination of alphanumeric characters, “.”
# * (dots) and "_" (underlines). No spaces are allowed inside a key. Space
# * characters before and after a key are ignored.
# *
# * A value is an arbitrary string (empty strings are allowed) that appears
# * after the first “=” on a line. Multi-line values are not allowed. Spaces
# * immediately following “=” are ignored. Trailing spaces are ignored as well.
# *
# * Empty lines or lines starting with a “#” are also accepted. The latter can
# * be used as comments.
# *
# * A value can contain variables, that is, references to previously defined
# * keys, using the following syntax:
# *     %(<KEY>)
# *
# * For example, if a file contains the lines
# *
# *     os = Linux
# *     distro = Fedora
# *     product_name = %(distro) %(os)
# *
# * the last line will expand to “Fedora Linux”.
# *
# * The code that implements this feature is still quite rough, but should work
# * for simple uses.
# *
# * This library itself can be configured through the base configuration array.
# * Available keys are:
# * * cfg.continue_on_error (boolean; default: FALSE): if set to TRUE, does not
# *   stop parsing when encounters an error (but still logs it)
# * * cfg.dir (string; default: <base dir>): the directory that contains the
# *   configuration file; if not set, will default to the base directory of the
# *   calling script
# * * cfg.file (string; default: <script name>.conf): the name of the
# *   configuration file
# * * cfg.replace_vars (boolean; default: TRUE): if set to FALSE, prevents
# *   expansion of variables
# *
# * Note that these keys are used only for the initial configuration: depending
# * on the needs, the calling script can change the appropriate variables
# * exposed by this library. This means, for example, that a script can load
# * multiple configuration files, each in its own array.
# */


########################################


###############
## CONSTANTS ##
###############

## EXIT CODES

#/**
# * Syntax error.
# *
# * Default value: 24
# */
readonly BIB_E_CFG_SYNTAX=24


#/**
# * Invalid line.
# *
# * Default value: 25
# */
readonly BIB_E_CFG_LINE=25


#/**
# * Invalid key.
# *
# * Default value: 26
# */
readonly BIB_E_CFG_KEY=26


########################################


###############
## VARIABLES ##
###############

#/**
# * The directory of the configuration file.
# *
# * Default value: SCRIPT_BASEDIR
# */
declare -g BIB_CFG_DIR="${BIB_SCRIPT_BASEDIR}"


#/**
# * The name of the configuration file.
# *
# * Default value: <BIB_SCRIPT_NAME>.conf
# */
declare -g BIB_CFG_FILE="${BIB_SCRIPT_NAME}.conf"


#/**
# * If set to TRUE, completes parsing even if errors are found.
# *
# * The default behavior in case of parsing errors is to bail out without
# * modifying input array.
# *
# * By setting this flag TRUE, this behavior is inhibited, and the lines
# * containing errors are simply ignored.
# *
# * Regardless of the setting of this flag, errors are logged into
# * BIB_CFG_STATE, and bib.conf.from_file() will still return BIB_E_CFG_SYNTAX.
# *
# * Default value: FALSE
# */
declare -gi BIB_CFG_CONTINUE_ON_ERROR=${BIB_FALSE}


#/**
# * Toggles the execution of the variables replacement algorithm.
# *
# * Default value: TRUE
# */
declare -gi BIB_CFG_ENABLE_VAR_REPLACEMENT=${BIB_TRUE}


#/**
# * Log of the results.
# *
# * Default value: <unset>
# */
declare -gA BIB_CFG_STATUS


########################################


###############
## FUNCTIONS ##
###############

#/**
# * Finds and replaces all the references to variables.
# *
# * For now, the underlying algorithm is rather simple and is not guaranteed to
# * work reliably in all cases. Its computational complexity is O(n^2).
# *
# * Syntax: _bib.replace_variables MAP
# *
# * @param MAP the array to parse
# */
function _bib.cfg.replace_variables() {
#     (( BIB_CFG_ENABLE_VAR_REPLACEMENT )) || return ${BIB_E_OK}

    local -n _map="${1}"
    local _key
    local _k
    local _value

    for _key in ${!_map[@]}
    do
        for _k in ${!_map[@]}
        do
            _value="${_map[${_k}]}"
            _map[${_key}]="${_map[${_key}]//%(${_k})/${_value}}"
        done
    done
}


#/**
# * Fills an associative array with the mappings read from a file.
# *
# * Syntax: bib.cfg.from_file [-n] [-f FILE] CONFIGURATION
# *
# * Options:
# * -f FILE : reads the configuration from user specified file; FILE is the
# *           path to the configuration file
# *
# * -n : disables variables replacement
# *
# * @param CONFIGURATION an associative array to fill
# *
# * Exit codes:
# * * E_OK on successful operation
# * * E_CFG_SYNTAX if errors are detected in the configuration file
# * * BIB_E_NEXISTS if the configuration file was not found
# * * BIB_E_ACCESS if the configuration file was not readable
# */
function bib.cfg.from_file() {
    local _cfg_file="${BIB_CFG_DIR}/${BIB_CFG_FILE}"

    local -n __configuration
    local -A _temp
    local -i _disable_var_replacement=${BIB_FALSE}
    local _line
    local _key
    local _value
    local -i _line_number=0
    local -i _result
    local -i _status=${BIB_E_OK}

    local OPTION OPTIND
    while getopts ":f:n" OPTION
    do
        case "${OPTION}" in
            "f" )
                _cfg_file="${OPTARG}"
            ;;

            "n" )
                _disable_var_replacement=${BIB_TRUE}
            ;;
        esac
    done

    shift $(( OPTIND - 1 ))

    __configuration="${1}"
    BIB_CFG_STATUS=()

    [[ -f "${_cfg_file}" ]] || return ${BIB_E_NEXISTS}
    [[ -r "${_cfg_file}" ]] || return ${BIB_E_ACCESS}

    while read -r _line
    do
        let _line_number++
        _status=${BIB_E_OK}

        # Empty line or comment
        [[ -z "${_line}" || "${_line:0:1}" == "#" ]] && continue

        # Is “=” character found in current line?
        _result=$(expr index "${_line}" "=")
        if ! (( ${_result} > 1 ))
        then
            _status=${BIB_E_CFG_LINE}
        elif ! [[ "${_line}" =~ ^[[:space:]]*[A-Za-z0-9._]+[[:space:]]*= ]]
        then
            _status=${BIB_E_CFG_KEY}
        fi

        if (( ${_status} != ${BIB_E_OK} ))
        then
            BIB_CFG_STATUS[${_line_number}]=${_status}
            continue
        fi

        _key=$(bib.shrink ${_line%=*})

        [[ "${_line#*=}" =~ [[:space:]]*(.*)$ ]]
        _value="${BASH_REMATCH[1]}"

        _temp["${_key}"]="${_value}"
    done < "${_cfg_file}"

    if (( ${#BIB_CFG_STATUS[@]} > 0 ))
    then
        _status=${BIB_E_CFG_SYNTAX}
        (( BIB_CFG_CONTINUE_ON_ERROR )) || return ${_status}
    fi

    (( BIB_CFG_ENABLE_VAR_REPLACEMENT && ! _disable_var_replacement )) && _bib.cfg.replace_variables _temp

    for _key in ${!_temp[@]}
    do
        __configuration["${_key}"]="${_temp["${_key}"]}"
    done


    return ${_status}
}


########################################


[[ -d "${BIB_CONFIG["cfg.dir"]}" ]] && BIB_CFG_DIR="${BIB_CONFIG["cfg.dir"]}"

[[ -n "${BIB_CONFIG["cfg.file"]}" ]] && \
    ! bib.contains "/" "${BIB_CONFIG["cfg.file"]}" && \
    BIB_CFG_FILE="${BIB_CONFIG["cfg.file"]}"

[[ -v BIB_CONFIG["cfg.replace_vars"] ]] && BIB_CFG_ENABLE_VAR_REPLACEMENT=$(( BIB_CONFIG["cfg.replace_vars"] || BIB_FALSE ))

[[ -v BIB_CONFIG["cfg.continue_on_error"] ]] && BIB_CFG_CONTINUE_ON_ERROR=$(( BIB_CONFIG["cfg.continue_on_error"] || BIB_FALSE ))

# Ensures that no spurious status code is returned
return ${BIB_E_OK}
