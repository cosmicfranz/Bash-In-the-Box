## Bash-In-the-Box (BItBox)
## Copyright © 2023 Francesco Napoleoni
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
# * Provides logging to files, syslog and standard error.
# *
# * The interface is loosely based on other logging libraries. Messages are
# * logged using a single function — bib.log() —, which supports six priority
# * levels (from lowest to highest):
# * 1. debug (d)
# * 2. info (i)
# * 3. notice (n)
# * 4. warning (w)
# * 5. error (e, err)
# * 6. critical (c, crit)
# *
# * Each one is inspired by and can be mapped to the corresponding syslog
# * level.
# *
# * Log messages can be sent to one or more output channels. Every output
# * channel can be independently enabled, by means of specific flags in the
# * base configuration:
# * * log.channel.file
# * * log.channel.stderr
# * * log.channel.syslog
# *
# * The logger can be configured through the following parameters:
# * * ENABLE (default TRUE)
# * * DIR (default <SCRIPT_BASEDIR>)
# * * FILENAME (default <SCRIPT_NAME>.log)
# * * THRESHOLD (default NOTICE)
# * * DATE_FORMAT (default “%c”)
# * * CMD_LOGGER (default “logger”)
# *
# * The corresponding keys of the base configuration are:
# * * log.enable
# * * log.dir
# * * log.filename
# * * log.threshold
# * * log.date_format
# * * log.cmd.logger
# */


########################################


###############
## CONSTANTS ##
###############

#/**
# * Priority levels.
# */
readonly BIB_LOG_DEBUG=1
readonly BIB_LOG_D=${BIB_LOG_DEBUG}
readonly BIB_LOG_INFO=2
readonly BIB_LOG_I=${BIB_LOG_INFO}
readonly BIB_LOG_NOTICE=3
readonly BIB_LOG_N=${BIB_LOG_NOTICE}
readonly BIB_LOG_WARNING=4
readonly BIB_LOG_W=${BIB_LOG_WARNING}
readonly BIB_LOG_ERROR=5
readonly BIB_LOG_ERR=${BIB_LOG_ERROR}
readonly BIB_LOG_E=${BIB_LOG_ERR}
readonly BIB_LOG_CRITICAL=6
readonly BIB_LOG_CRIT=${BIB_LOG_CRITICAL}
readonly BIB_LOG_C=${BIB_LOG_CRITICAL}


#/**
# * Syslog priority level mappings.
# */
readonly -a _BIB_LOG_SYSLOG_LEVEL=(
    [${BIB_LOG_DEBUG}]="debug"
    [${BIB_LOG_INFO}]="info"
    [${BIB_LOG_NOTICE}]="notice"
    [${BIB_LOG_WARNING}]="warning"
    [${BIB_LOG_ERROR}]="err"
    [${BIB_LOG_CRITICAL}]="crit"
)


## I/O STREAMS

#/**
# * Reserved file descriptor for logging to file.
# *
# * Default value: 5
# */
readonly _BIB_LOG_FD=5


## EXIT CODES

#/**
# * One or more channels unavailable.
# *
# * Default value: 12
# */
readonly BIB_E_LOG_CHANNEL=12


########################################


###############
## VARIABLES ##
###############

#/**
# * Toggles the state of the logger.
# *
# * If set to FALSE, no messages are sent at all.
# *
# * This flag can also be set in the base configuration, using “log”,
# * which accepts 0 or 1.
# *
# * Type: boolean
# * Default value: TRUE
# */
declare -gi BIB_LOG_ENABLED=${BIB_TRUE}


#/**
# * Enables debug mode of the logger.
# *
# * This flag can be set in the base configuration, using “log.debug”.
# *
# * Type: boolean
# * Default value: FALSE
# */
declare -gi _BIB_LOG_DEBUG_MODE=${BIB_CONFIG["log.debug"]:-${BIB_FALSE}}


#/**
# * Log output channels.
# *
# * Supported channels are:
# * file
# * stderr
# * syslog
# *
# * Each channel is represented as a key with a boolean value. Such value is by
# * default FALSE (i.e. channel disabled), and can be set using the
# * corresponding “log.channel.<CHANNEL>” in the base configuration.
# *
# * If “file” is set to TRUE (through “log.channel.file”), log messages are
# * sent to a text file, found in <DIR>/<FILENAME>.log.
# *
# * “stderr” enables logging to standard error.
# *
# * Can be set in the base configuration using “log.channel.stderr”.
# *
# * “syslog” enables logging to syslog, using “logger” external command.
# *
# * Can be set in the base configuration using “log.channel.syslog”.
# */
declare -Ag _BIB_LOG_CHANNELS=(
    ["file"]=${BIB_CONFIG["log.channel.file"]:-${BIB_FALSE}}
    ["stderr"]=${BIB_CONFIG["log.channel.stderr"]:-${BIB_FALSE}}
    ["syslog"]=${BIB_CONFIG["log.channel.syslog"]:-${BIB_FALSE}}
)


#/**
# * The path to the log file directory.
# *
# * Type: string
# * Default value: <SCRIPT_BASEDIR>
# */
declare -g BIB_LOG_DIR="${BIB_CONFIG["log.dir"]:-${BIB_SCRIPT_BASEDIR}}"


#/**
# * Log file name.
# *
# * Type: string
# * Default value: <SCRIPT_NAME>.log
# */
declare -g BIB_LOG_FILENAME="${BIB_SCRIPT_NAME}.log"


#/**
# * Sets the minimum priority level for messages to be sent.
# *
# * Can be used to limit the verbosity of the logs.
# *
# * Note that this variable is declared as “integer”, and is set with the
# * constants defined above (DEBUG, INFO...).
# *
# * If set in the base configuration through “log.threshold” key, string values
# * are accepted:
# * * debug (d)
# * * info (i)
# * * notice (n)
# * * warning (w)
# * * error (e, err)
# * * critical (c, crit)
# *
# * Type: integer
# * Default value: NOTICE
# */
declare -gi BIB_LOG_THRESHOLD=${BIB_LOG_NOTICE}


#/**
# * Date format, expressed in strftime format.
# *
# * Can be set in the base configuration using “log.date_format”.
# *
# * Type: string
# * Default value: “%c” (locale’s date and time)
# */
declare -g BIB_LOG_DATE_FORMAT='%c'


#/**
# * Filename and path of “logger” command.
# *
# * Can be set in the base configuration using “log.cmd.logger”.
# *
# * Type: string
# * Default value: “logger”
# */
declare -g BIB_LOG_CMD_LOGGER="logger"


########################################


###############
## FUNCTIONS ##
###############

#/**
# * Initializes log threshold.
# *
# * Syntax: _bib.log.initialize_threshold THRESHOLD
# *
# * @param THRESHOLD (string)
# */
function _bib.log.initialize_threshold() {
    local _threshold="${1}"
    local -i _t

    if (( _BIB_DEBUG ))
    then
        BIB_LOG_THRESHOLD=${BIB_LOG_DEBUG}
    else
        _t=$(_bib.log.level "${_threshold}")
        (( _t )) && BIB_LOG_THRESHOLD=${_t}
    fi
}


#/**
# * Tries to initialize chosen log file.
# *
# * Syntax: _bib.log.initialize_file
# */
function _bib.log.initialize_file() {
    [[ -n "${BIB_CONFIG["log.filename"]}" ]] && \
        ! bib.contains "/" "${BIB_CONFIG["log.filename"]}" && \
        BIB_LOG_FILENAME="${BIB_CONFIG["log.filename"]}"

    >> "${BIB_LOG_DIR}/${BIB_LOG_FILENAME}" && \
    [[ -w "${BIB_LOG_DIR}/${BIB_LOG_FILENAME}" ]] || _BIB_LOG_CHANNELS["file"]=${BIB_FALSE}
}


#/**
# * Returns the integer value of the corresponding priority level.
# *
# * Syntax: _bib.log.level LEVEL
# *
# * @param LEVEL
# * @return the integer value of the corresponding priority level
# */
function _bib.log.level() {
    local _level="${1}"
    local -n _level_var
    local -i _level_value=0

    case "${_level^^}" in
        "C" | \
        "CRIT" | \
        "CRITICAL" | \
        "D" | \
        "DEBUG" | \
        "E" | \
        "ERR" | \
        "ERROR" | \
        "I" | \
        "INFO" | \
        "N" | \
        "NOTICE" | \
        "W" | \
        "WARNING" )
            _level_var=BIB_LOG_${_level^^}
            _level_value=${_level_var}
        ;;
    esac

    printf ${_level_value}
}


#/**
# * Sends a log message (along with its metadata) to a file.
# *
# * Syntax: _bib.log.to_file PRIORITY LABEL MESSAGE
# *
# * @param LABEL
# * @param MESSAGE
# * @param PRIORITY
# */
function _bib.log.to_file() {
    local _date
    local _priority="${1}"
    local _label="${2}"
    local _message="${3}"
    local -i _status=${BIB_E_OK}

    exec 5>> "${BIB_LOG_DIR}/${BIB_LOG_FILENAME}"
    _status=${?}

    printf -v _date "%(${BIB_LOG_DATE_FORMAT})T" -1

    bib.print    \
              -n \
              -d ${_BIB_LOG_FD} \
              "%s - [%s] %s: %s\n" \
              "${_date}" \
              "${_BIB_LOG_SYSLOG_LEVEL["${_priority}"]}" \
              "${_label}" \
              "${_message}"

    exec 5>&-

    return ${_status}
}


#/**
# * Sends a log message (along with its metadata) to standard error stream.
# *
# * Syntax: _bib.log.to_stderr PRIORITY LABEL MESSAGE
# *
# * @param LABEL
# * @param MESSAGE
# * @param PRIORITY
# */
function _bib.log.to_stderr() {
    local _date
    local _priority="${1}"
    local _label="${2}"
    local _message="${3}"
    local -i _status=${BIB_E_OK}

    printf -v _date "%(${BIB_LOG_DATE_FORMAT})T" -1

    bib.print    \
              -n \
              -e \
              "%s - [%s] %s: %s\n" \
              "${_date}" \
              "${_BIB_LOG_SYSLOG_LEVEL["${_priority}"]}" \
              "${_label}" \
              "${_message}"

    return ${_status}
}


#/**
# * Sends a log message (along with its metadata) to syslog.
# *
# * This operation is carried out through “logger” external command.
# *
# * Syntax: _bib.log.to_syslog PRIORITY LABEL MESSAGE
# *
# * @param LABEL
# * @param MESSAGE
# * @param PRIORITY
# */
function _bib.log.to_syslog() {
    local _priority="${1}"
    local _label="${2}"
    local _message="${3}"
    local _debug_options
    local -i _status=${BIB_E_OK}

    (( _BIB_DEBUG )) && _debug_options="--no-act --stderr"
    ${BIB_LOG_CMD_LOGGER} \
        ${_debug_options} \
        --tag "${_label}" \
        --priority "${_BIB_LOG_SYSLOG_LEVEL["${_priority}"]}" \
        -- \
        "${_message}"

    _status=${?}

    return ${_status}
}


#/**
# * Sends a log message to enabled channels.
# *
# * Syntax: bib.log [-c CHANNEL[,CHANNEL...]] [-f] PRIORITY MESSAGE
# *
# * Options:
# * -c [-c CHANNEL[,CHANNEL...]] :
# *    can be used to specify a comma-separated list of output channels that
# *    will override the predefined setting
# * -f : includes the name of the calling function. If omitted, the name of the
# *      function will be included only in messages with “debug” priority
# *
# * @param PRIORITY the priority level of the message
# * @param MESSAGE the text of the message
# */
function bib.log() {
    (( ${#} > 1 )) || return ${BIB_E_ARG}

    local _label="${BIB_SCRIPT_NAME}[$$]"
    local -i _priority
    local _message
    local _channel
    local -A _channels_filter=(
        ["file"]=${BIB_FALSE}
        ["stderr"]=${BIB_FALSE}
        ["syslog"]=${BIB_FALSE}
    )
    local -i _print_function_name=${BIB_FALSE}
    local -i _status=${BIB_E_OK}

    local OLDIFS="${IFS}"
    local OPTION
    local OPTIND
    while getopts "c:f" OPTION
    do
        case "${OPTION}" in
            "c" )
                local _c
                IFS=","
                for _c in ${OPTARG}
                do
                    [[ -v _channels_filter["${_c}"] ]] && _channels_filter["${_c}"]=${BIB_TRUE}
                done
                IFS="${OLDIFS}"
                unset _c OLDIFS
            ;;

            "f" )
                _print_function_name=${BIB_TRUE}
            ;;
        esac
    done

    shift $((${OPTIND} - 1))

    _priority=$(_bib.log.level "${1}")
    (( _priority )) || return ${BIB_E_VALUE}
    if (( ! _BIB_DEBUG ))
    then
        (( _priority >= BIB_LOG_THRESHOLD )) || return ${BIB_E_OK}
    fi
    shift
    _message="${@}"

    (( _print_function_name || _priority == BIB_LOG_DEBUG )) && _label+=" ${FUNCNAME[1]}()"

    (( _BIB_DEBUG )) && _BIB_LOG_CHANNELS=(
        ["file"]=${BIB_FALSE}
        ["stderr"]=${BIB_TRUE}
        ["syslog"]=${BIB_FALSE}
    )

    (( _BIB_LOG_DEBUG_MODE )) && _BIB_LOG_CHANNELS=(
        ["file"]=${BIB_TRUE}
        ["stderr"]=${BIB_TRUE}
        ["syslog"]=${BIB_TRUE}
    )
    for _channel in ${!_BIB_LOG_CHANNELS[@]}
    do
        (( ${_BIB_LOG_CHANNELS["${_channel}"]} && ${_channels_filter["${_channel}"]} )) || continue
        _bib.log.to_${_channel} ${_priority} "${_label}" "${_message}" || _status=${BIB_E_LOG_CHANNEL}
    done

    return ${_status}
}


########################################


[[ -v BIB_CONFIG["log.enable"] && ${BIB_CONFIG["log.enable"]} == ${BIB_FALSE} ]] && BIB_LOG_ENABLED=${BIB_FALSE}

[[ -v BIB_CONFIG["log.threshold"] ]] && _bib.log.initialize_threshold "${BIB_CONFIG["log.threshold"]}"

[[ -d "${BIB_CONFIG["log.dir"]}" ]] && BIB_LOG_DIR="${BIB_CONFIG["log.dir"]}"

(( _BIB_LOG_CHANNELS["file"] || _BIB_LOG_DEBUG_MODE )) && _bib.log.initialize_file
