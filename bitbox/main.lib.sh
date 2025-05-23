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
# * Enables the use of BItBox.
# *
# * This package is the only one that needs to be imported via “source” builtin.
# */


########################################


###############
## CONSTANTS ##
###############

#/**
# * BItBox short name.
# */
readonly BIB_NAME="BItBox"


#/**
# * BItBox long name.
# */
readonly BIB_LONGNAME="Bash-In-the-Box"


#/**
# * BItBox version number.
# */
readonly BIB_VERSION="0"


#/**
# * BItBox release “major” number.
# */
readonly BIB_REL_MAJOR="2"


#/**
# * BItBox release “minor” number.
# *
# * The intended use case for this number is when an important bug fix or a
# * backport occurs after a stable release. Can be zero or empty otherwise.
# */
readonly BIB_REL_MINOR=""


#/**
# * BItBox release “type”.
# *
# * Allowed values:
# * * <empty string> : stable release
# * * “dev” : development release
# * * “alpha[0-9]+” : when a new API or any big change is introduced
# * * “beta[0-9]+” : when a new feature is (almost) complete and stable
# * * “rc[0-9]+” : release candidate. API is stable, only bugfix are allowed
# */
readonly BIB_REL_TYPE="alpha1"


#/**
# * BItBox release date, formatted as YYYYMMDD.
# */
readonly BIB_REL_DATE="20250503"


## BOOLEAN CONSTANTS

#/**
# * “True” value.
# *
# * Default value: 1
# */
readonly BIB_TRUE=1


#/**
# * “False” value.
# *
# * Default value: 0
# */
readonly BIB_FALSE=0


## EXIT CODES
## Here are defined some useful constants for the most common exit codes
## returned by scripts and functions.
##
## The following codes are allotted:
## * 0 - 31 : reserved
## * 32 - 124: free for use in custom scripts
## * 125- 255 : reserved
##
## It is important to note that exit codes alone do not carry enough information
## about the state of the execution, and should be accompanied by printed
## messages or sensible logging whenever possible.

#/**
# * Printable strings matching numeric codes.
# */
readonly -a BIB_E_CODES=(
    [0]="OK"
    [1]="NOK"
    [2]="USAGE"
    [3]="NPERM"
    [4]="ARG"
    [5]="TYPE"
    [6]="VALUE"
    [7]="STATE"
    [8]="NEXISTS"
    [9]="ACCESS"
    [12]="LOG_CHANNEL"
    [16]="ASSERTION"
    [17]="TESTFAIL"
    [18]="TESTSKIP"
    [24]="CFG_SYNTAX"
    [25]="CFG_LINE"
    [26]="CFG_KEY"
)


#/**
# * Represents “successful execution” state.
# *
# * Default value: 0
# */
readonly BIB_E_OK=0


#/**
# * Represents generic “unsuccessful execution” state.
# *
# * Note that this code does not necessarily indicates an “error”; it may
# * signal the user that a requested operation has not produced expected or
# * good results.
# *
# * Default value: 1
# */
readonly BIB_E_NOK=1


#/**
# * Represents incorrect usage of a function or pipeline.
# *
# * Default value: 2
# */
readonly BIB_E_USAGE=2


#/**
# * Operation not permitted.
# *
# * Something prevented the code to complete the requested operation.
# *
# * Default value: 3
# */
readonly BIB_E_NPERM=3


#/**
# * Wrong or insufficient arguments.
# *
# * This code can be returned by a script or a function when called with an
# * unexpected number or type of arguments.
# *
# * Default value: 4
# */
readonly BIB_E_ARG=4


#/**
# * Data type error.
# *
# * Typically returned when an object contains uninitialized or inconsistent
# * data. More details about objects are found in the documentation.
# *
# * Default value: 5
# */
readonly BIB_E_TYPE=5


#/**
# * Wrong value.
# *
# * Can be returned when a function argument or an object contains a value not
# * allowed.
# *
# * Default value: 6
# */
readonly BIB_E_VALUE=6


#/**
# * State error.
# *
# * Returned by a function that has been called at a wrong time. This can happen
# * when such function is part of a specific API and expects that an object has
# * been correctly initialized before.
# *
# * Default value: 7
# */
readonly BIB_E_STATE=7


#/**
# * Path not found.
# *
# * Returned when a path in the filesystem does not exists or is inaccessible.
# *
# * Default value: 8
# */
readonly BIB_E_NEXISTS=8


#/**
# * Access denied.
# *
# * If a path is reachable but not readable, writable or executable.
# *
# * Default value: 9
# */
readonly BIB_E_ACCESS=9


## CONSOLE I/O STREAMS
## The following constants contain the alternative file descriptors for
## standard output and standard error.

#/**
# * Alternative file descriptor for standard output.
# *
# * Default value: 3
# */
# readonly BIB_STDOUT_ALT=3


#/**
# * Alternative file descriptor for standard error.
# *
# * Default value: 4
# */
# readonly BIB_STDERR_ALT=4


####################

## CONSTANTS INITIALIZED AT RUNTIME

#/**
# * The initial configuration of BItBox.
# *
# * This is a named reference to an associative array passed as argument during
# * the import of this library.
# *
# * The associative array can contain as many items as desired; all of them are
# * optional.
# * 
# * Any item, or property, is a typical key-value pair. Keys may be arbitrary,
# * non-empty strings, but BItBox uses and encourages a naming format that makes
# * use of namespaces. The format is
# *   ns[.ns...].name
# * that is, the name of the property should be preceded by one or more nested
# * namespaces, separated by dots. This naming scheme prevents conflicts between
# * properties belonging to different libraries but with the same name.
# *
# * Values are arbitrary strings or numbers, only following Bash rules.
# *
# * Some properties are already used by BItBox. In particular, “main” library
# * recognizes the following:
# * * “name” (string): the short name of the script
# * * “longname” (string): the readable, printable name of the script, if
# *                        applicable
# * * “basedir” (string): the path to the directory containing the script
# * * “runtimedir” (string): the path to the runtime data directory
# * * “statedir” (string): the path to the state directory
# * * “interactive” (boolean): must be set to 1 (true) if the script is expected
# *                            to interact with the user
# * * “style” (boolean): if set to 1 (true) enables colors and styles for output
# *                      messages. Works only if interactive mode is also
# *                      enabled
# * * “no_cleanup_on_exit” (boolean): if set to 1 (true) inhibits trapping of
# *                                   EXIT pseudo-signal, effectively
# *                                   preventing any cleanup code to be
# *                                   executed. Note that this is mostly a bad
# *                                   idea, so this property should be set only
# *                                   when really needed.
# *
# * The above keys belong to a top, unnamed namespace. This is only true for
# * “main” library. Other libraries may define their own names, all preceded by
# * their namespace, usually the name of the library itself. So, for example,
# * the fully qualified identifier for a key named “dir” in “log” library will
# * be “log.dir”. Please refer to the appropriate documentation.
# */
declare -A BIB_CONFIG
if [[ -n "${1}" && "${1}" != "-" ]]
then
    unset BIB_CONFIG
    declare -n BIB_CONFIG="${1}"
fi


#/**
# * The short name of the calling script.
# *
# * Set as the value of “name” from the initial configuration array, if defined.
# *
# * Default value: the filename of the calling script
# */
declare BIB_SCRIPT_NAME

#/**
# * The long, readable and printable name of the calling script.
# *
# * Set as the value of “longname” from the initial configuration array, if
# * defined.
# *
# * Default value: the same as BIB_SCRIPT_NAME
# */
declare BIB_SCRIPT_LONGNAME


#/**
# * The path of the directory containing the calling script.
# *
# * Set as the value of “basedir” from the initial configuration array, if
# * defined.
# *
# * Default value: the directory containing the filename of the calling script
# */
declare BIB_SCRIPT_BASEDIR


#/**
# * The path of the directory containing runtime data.
# *
# * Set as the value of “runtimedir” from the initial configuration array, if
# * defined.
# *
# * Default value: the same as BIB_SCRIPT_BASEDIR
# */
declare BIB_SCRIPT_RUNTIMEDIR


#/**
# * The path of the directory containing state-related data.
# *
# * Set as the value of “statedir” from the initial configuration array, if
# * defined.
# *
# * Default value: the same as BIB_SCRIPT_BASEDIR
# */
declare BIB_SCRIPT_STATEDIR


#/**
# * The version string of the calling script.
# *
# * Set as the value of “version” from the initial configuration array, if
# * defined.
# *
# * Default value: <null>
# */
readonly BIB_SCRIPT_VERSION="${BIB_CONFIG["version"]}"


########################################


###############
## VARIABLES ##
###############

#/**
# * Contains the path to the home directory of BItBox.
# *
# * It is usually set as an environment variable.
# *
# * Default value: SCRIPT_BASEDIR
# */
: ${BIB_HOME:="${BIB_SCRIPT_BASEDIR}"}


#/**
# * Toggles interactive mode.
# *
# * Interactive mode is helpful for scripts that print messages on screen or
# * expect input from the user during execution. When set to BIB_TRUE, enables
# * messages on screen by functions like bib.print(), but its use can be
# * extended as desired.
# *
# * A script could be also made to work both in interactive and non-interactive
# * mode, maybe using a command line option. This allows to run the script in
# * different ways, depending on the needs: a background service, a command
# * with “auto” and “manual” modes, or “verbose” and “quiet” mode...
# *
# * Since some parts of BItBox honor this flag, its use is encouraged anytime
# * a script needs some type of interaction with the user.
# *
# * If debug mode is set, interactive mode is automatically enabled, and the value
# * of this variable is reset to default.
# *
# * Default value: BIB_TRUE
# */
declare -i BIB_INTERACTIVE=${BIB_TRUE}


#/**
# * Toggles “silent” mode.
# *
# * When set to BIB_TRUE, all messages to standard output or standard error are
# * suppressed.
# *
# * This setting is quite strict, in that it prevents even error messages to be
# * printed on screen, therefore its use should be planned carefully in order
# * to avoid losing important information from the script.
# *
# * Note that this flag mostly controls functions like bib.print(), bib.error()
# * and bib.warn(), but does not prevent output from other commands run from
# * the script. It is up to the developer to control the amount of screen
# * output of the script.
# *
# * If debug mode is set, silent mode is automatically disabled, and the value
# * of this variable is reset to default.
# *
# * Default value: BIB_FALSE
# */
declare -i BIB_SILENT=${BIB_FALSE}


#/**
# * Toggles debug mode.
# *
# * Debug mode allows the user or the developer to see all the messages from
# * the script printed on screen.
# *
# * Debug mode can be enabled using “debug” flag in the base configuration.
# *
# * This flag is honored by “log” library: if set to BIB_TRUE, all messages
# * down to DEBUG level are shown, unless specific configuration is given in
# * order to change this behavior. Please read “log” documentation for details.
# *
# * If enabled, it overrides both BIB_INTERACTIVE and BIB_SILENT settings,
# * effectively resetting them to their defaults.
# *
# * Default value: FALSE
# */
declare -i BIB_DEBUG=${BIB_CONFIG["debug"]:-${BIB_FALSE}}


#/**
# * Toggles redirections.
# *
# * When set to TRUE, standard output and standard error streams are diverted
# * in the following way: first of all, they are “saved” in.
# *
# * Default value: FALSE
# */
# declare -i BIB_REDIRECT=${BIB_FALSE}


#/**
# * Used by bib.shopt() to track the initial option values.
# */
declare -A _BIB_SHOPT_STATE


#/**
# * Current file descriptor of the standard input.
# *
# * Default value: 0
# */
declare -i BIB_STDIN=0


#/**
# * Current file descriptor of the standard output.
# *
# * Default value: 1
# */
declare -i BIB_STDOUT=1


#/**
# * Current file descriptor of the standard error.
# *
# * Default value: 2
# */
declare -i BIB_STDERR=2


#/**
# * A map of loaded libraries.
# *
# * This is a private property, exclusively used to keep track of modules
# * loaded with bib.include(). As with all private members, IT MUST NOT
# * BE MODIFIED BY CODE OUTSIDE.
# */
declare -A _BIB_LIBS=(
    ["main"]="main.lib.sh"
)


#/**
# * A list of cleanup functions, to be called by _bib.cleanup().
# *
# * Note that it is declared as an associative array, just to avoid duplicate
# * elements. For such purpose, only keys are used, while values are ignored.
# *
# * Entries are added by means of bib.add_cleanup_handler().
# */
declare -A _BIB_CLEANUP_HANDLERS


########################################


###############
## FUNCTIONS ##
###############

#/**
# * Adds a function name to the cleanup handlers list.
# *
# * Syntax: bib.add_cleanup_handler FUNCTION_NAME
# *
# * @param FUNCTION_NAME
# */
function bib.add_cleanup_handler() {
    (( ${#} == 1 )) || return ${BIB_E_ARG}

    _BIB_CLEANUP_HANDLERS["${1}"]=
}


#/**
# * NO-OP STUB
# */
function bib.assert() { : ; }


#/**
# * Returns the last part of a path.
# *
# * It is a pure Bash alternative to “basename” from Coreutils, of which
# * implements the basic feature of stripping the directory part from a path.
# *
# * Trailing path separators will be removed.
# *
# * Syntax: bib.basename PATH
# *
# * @param PATH
# * @return the last part of a path
# */
function bib.basename() {
    (( ${#} == 1 )) || return ${BIB_E_ARG}

    local _path="${1}"

    if bib.is_root "${_path}"
    then
        printf "/"
    else
        _path="${_path%%+(/)}"
        printf "${_path##*/}"
    fi

    return ${BIB_E_OK}
}


#/**
# * Executes cleanup code just before the end of the execution.
# *
# * It is automatically called when EXIT pseudo-signal is trapped, unless
# * “no_cleanup_on_exit” property is set to 1 in the base configuration.
# *
# * Syntax: _bib.cleanup
# */
function _bib.cleanup() {
    local _handler
    for _handler in "${!_BIB_CLEANUP_HANDLERS[@]}"
    do
        declare -F "${_handler}" &> /dev/null
        bib.ok ${?} && ${_handler}
    done

    return ${BIB_E_OK}
}


#/**
# * Checks whether a substring is found in a string.
# *
# * Returns BIB_E_OK if the substring is found, BIB_E_NOK otherwise.
# *
# * This function is implemented as pure Bash code and makes use of wildcards.
# *
# * Syntax: bib.contains NEEDLE HAYSTACK
# *
# * Exit codes:
# * * BIB_E_OK if at least one occurrence of NEEDLE is found
# * * BIB_E_NOK if no occurrences of NEEDLE are found
# * * BIB_E_ARG if called with wrong number of arguments
# *
# * @param NEEDLE the substring to look for. Empty string is “not found”
# * @param HAYSTACK the string to test
# */
function bib.contains() {
    (( ${#} == 2 )) || return ${BIB_E_ARG}
    local _needle="${1}"
    local _haystack="${2}"

    [[ -n "${_needle}" && "${_haystack}" == *"${_needle}"* ]]
}


#/**
# * Returns the path to a file or a directory.
# *
# * It is a pure Bash alternative to “dirname” from Coreutils.
# *
# * Trailing path separators will be removed.
# *
# * Syntax: bib.dirname PATH
# *
# * @param PATH
# * @return the path to a file or a directory
# */
function bib.dirname() {
    (( ${#} == 1 )) || return ${BIB_E_ARG}

    local _path="${1}"
    local _dirname
    local -i _path_is_absolute=${BIB_FALSE}
    local _basename
    local -i _basename_length

    bib.is_absolute "${_path}" && _path_is_absolute=${BIB_TRUE}

    if bib.is_root "${_path}"
    then
        _dirname="/"
    else
        _path="${_path##+(/)}"
        _path="${_path%%+(/)}"
        _basename=$(bib.basename "${_path}")
        _basename_length=${#_basename}

        _dirname="${_path:0: $(( -${_basename_length} ))}"
    fi

    if [[ "${_dirname}" != "/" ]]
    then
        _dirname="${_dirname%%+(/)}"
        (( _path_is_absolute )) && _dirname="/${_dirname}"
    fi

    printf "${_dirname}"

    return ${BIB_E_OK}
}


#/**
# * Prints an error message to standard error.
# *
# * Intended use is to send messages about something critical that happened
# * during the execution, potentially compromising the rest of it, and that
# * requires user intervention.
# *
# * Syntax: bib.error MESSAGE
# *
# * @param MESSAGE a brief description of what happened
# */
function bib.error() {
    local _message="${1}"

    [[ ${BIB_SILENT} == ${BIB_FALSE} && -n "${_message}" ]] && bib.print -e "&RED*%s*&DEF\n" "${_message}"

    return ${BIB_E_OK}
}


#/**
# * Imports a library into the script.
# *
# * It is a wrapper of “source” builtin that prevents multiple imports of the
# * same code. It is meant to replace “source” and “.” whenever possible.
# *
# * Syntax: bib.include LIB_NAME
# *
# * LIB_NAME is the name of the library itself (not the file name).
# *
# * If the plain name is passed, a file named <LIB_NAME>.lib.sh in
# * BIB_HOME/bitbox path will be searched.
# *
# * If name is preceded by a period (.<LIB_NAME>), the matching file name is
# * expected to be in BIB_SCRIPT_BASEDIR.
# *
# * Like other languages, libraries can be organized in packages, which are
# * implemented as directories. include() supports [.]PACKAGE.LIB_NAME with
# * unlimited levels of nesting.
# *
# * Another way of including a library is to specify the absolute path, that
# * is, a plain UNIX path starting with “/”; however the use of this style is
# * discouraged, and should be used only if really needed.
# *
# * Exit codes:
# * * BIB_E_OK when a library is successfully loaded
# * * BIB_E_NEXISTS if the file that contains the requested library does not
# *                 exist or is not accessible
# * * BIB_E_ARG if called without arguments
# *
# * @param LIB_NAME the name of the library, without extension
# */
function bib.include() {
    local _lib_name="${1}"
    local _lib_filename="${_lib_name}"
    local _lib_path="${BIB_HOME}/${BIB_NAME,,}"

    [[ -z "${_lib_name}" ]] && return ${BIB_E_ARG}

    if [[ "${_lib_name:0:1}" == "/" ]]
    then
        _lib_path=$(bib.dirname "${_lib_filename}")
    else
        if [[ "${_lib_name:0:1}" == "." ]]
        then
            _lib_filename=${_lib_filename:1}
            _lib_path="${BIB_SCRIPT_BASEDIR}"
        fi

        if bib.contains "." "${_lib_filename}"
        then
            _lib_filename="${_lib_filename//.//}"
            _lib_path+="/$(bib.dirname "${_lib_filename}")"
        fi
    fi

    _lib_filename=$(bib.basename "${_lib_filename}")

    _lib_filename="${_lib_filename}.lib.sh"

    [[ -f "${_lib_path}/${_lib_filename}" ]] || return ${BIB_E_NEXISTS}

    if [[ -z "${_BIB_LIBS["${_lib_name}"]}" ]]
    then
        source ${_lib_path}/${_lib_filename}

        _BIB_LIBS["${_lib_name}"]="${_lib_path}/${_lib_filename}"
    fi

    return ${BIB_E_OK}
}


#/**
# * Checks if a given path starts with a slash.
# *
# * Syntax: bib.is_absolute PATH
# *
# * Exit codes:
# * * BIB_E_OK if given path starts with a slash
# */
function bib.is_absolute() {
    [[ "${1:0:1}" == "/" ]]
}


#/**
# * Checks if path is root.
# *
# * Syntax: bib.is_root PATH
# *
# * Exit codes:
# * * BIB_E_OK if path is root
# */
function bib.is_root() {
    [[ "${1}" =~ ^[/]+$ ]]
}


#/**
# * NO-OP STUB
# */
function bib.log() { : ; }


#/**
# * Collapses any redundant slashes in a path.
# *
# * Examples:
# * * //usr/local///bin -> /usr/local/bin
# * * home// -> home/
# * * /// -> /
# *
# * Syntax: bib.normalize PATH
# *
# * @return the same path as the input, with each level separated by a single
# *         slash
# */
function bib.normalize() {
    local _path="${1}"

    if bib.is_root "${_path}"
    then
        printf "/"
        return
    fi

    printf "${_path//+(\/)//}"
}


#/**
# * Logical negation of the input value.
# *
# * Useful to work with boolean constants BIB_TRUE and BIB_FALSE.
# *
# * Syntax: bib.not BOOLEAN_VALUE
# *
# * @return BIB_FALSE if BOOLEAN_VALUE is “true” (that is, evaluates to
# *         non-zero value), BIB_TRUE otherwise.
# */
function bib.not() {
    local -i _boolean_value=${1}
    printf "$(( ~ _boolean_value & 1 ))"
}


#/**
# * Returns BIB_E_OK if the argument is 0.
# *
# * Useful to test a variable containing the exit code from a command.
# *
# * Syntax: bib.ok STATUS
# *
# * Exit codes:
# * * BIB_E_OK if input argument equals to BIB_E_OK (i.e. “0”)
# */
function bib.ok() {
    (( ${1} == ${BIB_E_OK} ))
}


#/**
# * Prints a formatted string.
# *
# * By default, the string is sent to standard output, but can be sent to any
# * other stream (or, more precisely, file descriptor) via “-d” option. As a
# * shorthand, “-e” can be used to send to standard error.
# *
# * This function is a wrapper of “printf” builtin, therefore supports
# * formatted strings; custom style is also supported (see “style” flag).
# *
# * Like printf, string format followed by values is supported; alternatively
# * values can be passed as an array instead of parameters.
# *
# * Such array is created in advance and its name is passed to bib.print() as
# * the argument of “-v” option.
# *
# * Note that using “-v” and values after the format string at the same time is
# * supported; however the array is expanded first, while other values follow.
# *
# * BIB_INTERACTIVE flag is honored: when it is set to BIB_TRUE, a message sent
# * to standard output is discarded.
# *
# * If BIB_SILENT flag is set to BIB_TRUE, also messages sent to standard error
# * are not printed.
# *
# * Syntax: bib.print [OPTIONS] FORMAT [VALUE ...]
# *
# * Options:
# *
# * -d FD : sends to file descriptor number FD, according to Bash numbering
# *         (1: standard output; 2: standard error...)
# * -e : sends to standard error (same as “-d 2”)
# * -n : suppress style interpreting
# * -v VARIABLES : a name reference to an array containing the values that
# *                correspond to placeholders in a format string
# *
# * @param FORMAT the string format
# * @param VALUE will replace the corresponding placeholder in the format
# *              string
# */
function bib.print() {
    # Silently return if the calling script is in silent mode
    (( BIB_SILENT )) && return ${BIB_E_OK}
    local _format
    local -i _fd=${BIB_STDOUT}
    local -i _no_style=${BIB_FALSE}
    local -n _variables

    local OPTION
    local OPTIND
    while getopts "d:env:" OPTION
    do
        case "${OPTION}" in
            "d" )
                (( OPTARG > 0 )) && _fd=${OPTARG}
            ;;

            "e" )
                _fd=${BIB_STDERR}
            ;;

            "n" )
                _no_style=${BIB_TRUE}
            ;;

            "v" )
                _variables=${OPTARG}
            ;;
        esac
    done

    shift $((${OPTIND} - 1))

    # If in “non interactive” mode, suppress message to stdout
    (( BIB_INTERACTIVE || _fd != BIB_STDOUT  )) || return ${BIB_E_OK}

    _format="${1}"
    (( ! _no_style )) && _format="$(bib.style "${1}")"
    shift

    printf "${_format}" "${_variables[@]}" "${@}" >&${_fd}
}


#/**
# * Redirects standard output and standard error streams.
# */
# function _bib.redirect() {
#     eval "exec ${BIB_STDOUT}>&1 ${BIB_STDERR}>&2 1>&- 2>&-"
#     BIB_REDIRECT=${BIB_TRUE}
#     BIB_STDOUT=${BIB_STDOUT_ALT}
#     BIB_STDERR=${BIB_STDERR_ALT}
# }


#/**
# * Turns an absolute path into a relative one by stripping leading slashes.
# *
# * If the path does not start with slash(es), it is returned unchanged.
# *
# * Syntax: bib.relative PATH
# *
# * @param PATH can be absolute or relative
# * @return same as PATH, with any leading slashes removed
# */
function bib.relative() {
    local _path="${1}"

    if bib.is_root "${_path}"
    then
        printf "/"
        return
    fi

    if ! bib.is_absolute "${_path}"
    then
        printf ${_path}
    else
        printf "${_path/+(\/)/}"
    fi
}


#/**
# * Checks if the current script is being executed as root.
# *
# * Syntax: bib.root
# *
# * Exit codes:
# * * BIB_E_OK if the current effective user is “root”
# */
function bib.root() {
    (( EUID == 0 ))
}


#/**
# * A wrapper of “shopt” builtin that preserves the initial state.
# *
# * Bash-In-the-Box does not make any assumptions on shell options (apart from
# * “extglob”); whenever an option needs to be changed, it must be possible to
# * revert it to its previous value as soon as the code that uses it is
# * executed.
# *
# * This function behaves pretty much like “shopt”: it can set or unset an
# * option, but can also reset it to the value it had before the
# * first invocation.
# *
# * Syntax: bib.shopt [-r|-s|-u] OPTION
# *
# * Options:
# *
# * -r : resets the option to the initial value
# * -s : turns the option on (same beavhior of builtin)
# * -u : turns the option off (same beavhior of builtin)
# *
# * @param OPTION see shopt documentation
# *
# * Exit codes:
# * * BIB_E_OK when a valid option is set, unset or reset. When called with no
# *            options, it means that the option is set (same as builtin shopt)
# * * BIB_E_NOK if an invalid option is used. When called with no options it
# *             means that the option is unset (same as builtin shopt)
# */
function bib.shopt() {
    local -i _status=${BIB_E_OK}
    local _option_name
    local -a _shopt_state
    local _shopt_option=""

    local OPTION
    local OPTIND
    while getopts ":rsu" OPTION
    do
        case "${OPTION}" in
            "r" | "s" | "u" )
                _shopt_option="-${OPTION}"
            ;;
        esac
    done

    shift $((${OPTIND} - 1))

    _option_name="${1}"
    [[ -n "${_option_name}" ]] || return ${BIB_E_ARG}

    _shopt_state=( $(shopt "${_option_name}") )
    _status=${?}

    [[ ! ${_status} && -z "${_shopt_state[1]}" ]] && return ${_status}

    case "${_shopt_option}" in
        "-r" )
            [[ ! -v _BIB_SHOPT_STATE["${_option_name}"] ]] && return ${BIB_E_OK}
            _shopt_option="-u"
            (( _BIB_SHOPT_STATE["${_option_name}"] )) && _shopt_option="-s"
            unset _BIB_SHOPT_STATE["${_option_name}"]
        ;;

        "-s" )
            if [[ "${_shopt_state[1]}" == "off" ]]
            then
                [[ ! -v _BIB_SHOPT_STATE["${_option_name}"] ]] && _BIB_SHOPT_STATE["${_option_name}"]=${BIB_FALSE}
            fi
        ;;

        "-u" )
            if [[ "${_shopt_state[1]}" == "on" ]]
            then
                [[ ! -v _BIB_SHOPT_STATE["${_option_name}"] ]] && _BIB_SHOPT_STATE["${_option_name}"]=${BIB_TRUE}
            fi
        ;;
    esac

    shopt ${_shopt_option} "${_option_name}"
    _status=${?}

    return ${_status}
}


#/**
# * Reduces the presence of space characters in a string.
# *
# * More specifically, spaces at the beginning and at the end are removed,
# * while spaces between words collapse to one.
# *
# * For example the string
# *   "   ab    cd e  f     "
# *    ^^^  ^^^^  ^ ^^ ^^^^^
# * is transformed like this:
# *   "ab cd e f"
# *      ^  ^ ^
# *
# * NOTE: this function makes use of “echo -n”, which is not POSIX compliant.
# *
# * Syntax: bib.shrink TEXT
# *
# * @param TEXT
# * @return the “shrunk” string
# */
function bib.shrink() {
    echo -n ${*}
}


#/**
# * NO-OP STUB
# */
function bib.style() {
    echo "${@}"
}


#/**
# * Returns a string containing the name and the version of the script.
# *
# * Its actual output depends on the value of the following variables:
# * * BIB_SCRIPT_NAME (returned only if BIB_SCRIPT_LONGNAME is not set)
# * * BIB_SCRIPT_LONGNAME
# * * BIB_SCRIPT_VERSION (if set, its value is appended to the returned string
# *
# * Syntax: bib.title
# *
# * @return a string containing the name and the version of the script
# */
function bib.title() {
    local _string="${BIB_SCRIPT_NAME}"
    [[ -n "${BIB_SCRIPT_LONGNAME}" ]] && _string="${BIB_SCRIPT_LONGNAME}"
    [[ -n "${BIB_SCRIPT_VERSION}" ]] && _string+=" ${BIB_SCRIPT_VERSION}"

    printf "${_string}"
}


#/**
# * Returns the current date, formatted as YYYYMMDD.
# *
# * Syntax: bib.today
# *
# * @return the current date, formatted as YYYYMMDD
# */
function bib.today() {
    printf "%(%Y%m%d)T"
}


#/**
# * Returns the version string of BItBox.
# *
# * Syntax: bib.version [OPTIONS]
# *
# * Options:
# *
# *   -c : requests the complete string, formatted as
# *        "<VERSION>.<REL_MAJOR>[.<REL_MINOR>][-<REL_TYPE>] (<REL_DATE>)"
# *   -r : like “-c”, but without the date
# *
# * If no options are specified, "<VERSION>.<REL_MAJOR>[.<REL_MINOR>]" is returned.
# *
# * @return the version string of BItBox. See documentation for details
# */
function bib.version() {
    local _version="${BIB_VERSION}.${BIB_REL_MAJOR}"
    [[ -n "${BIB_REL_MINOR}" && "${BIB_REL_MINOR}" != "0" ]] && _version+=".${BIB_REL_MINOR}"
    local _format="%s%s"
    [[ -n "${BIB_REL_TYPE}" ]] && _format="%s-%s"
    local _return_string="${_version}"

    local _OPZIONE
    local OPTIND
    while getopts ":cr" _OPZIONE
    do
        case "${_OPZIONE}" in
            "c" )
                _format+=" (%s)"
                printf -v _return_string \
                       "${_format}" \
                       "${_version}" \
                       "${BIB_REL_TYPE}" \
                       "${BIB_REL_DATE}"
            ;;

            "r" )
                printf -v _return_string \
                       "${_format}" \
                       "${_version}" \
                       "${BIB_REL_TYPE}"
            ;;
        esac
    done

    printf "${_return_string}"
}


#/**
# * Prints a warning message to standard error.
# *
# * Intended use is to send messages about something noteworthy that happened
# * during the execution. It may be anything that does not compromise the rest
# * of execution itself, but that the user should be informed about.
# *
# * Syntax: bib.warn MESSAGE
# *
# * @param MESSAGE a brief description of what happened
# */
function bib.warn() {
    local _message="${1}"

    [[ ${BIB_SILENT} == ${BIB_FALSE} && -n "${_message}" ]] && bib.print -e "&YLW*%s*&DEF\n" "${_message}"

    return ${BIB_E_OK}
}


########################################


## Some initializations
BIB_SCRIPT_NAME="$(bib.basename ${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]})"
[[ -n "${BIB_CONFIG["name"]}" ]] && BIB_SCRIPT_NAME="${BIB_CONFIG["name"]}"
readonly BIB_SCRIPT_NAME

BIB_SCRIPT_LONGNAME="${BIB_SCRIPT_NAME}"
[[ -n "${BIB_CONFIG["longname"]}" ]] && BIB_SCRIPT_LONGNAME="${BIB_CONFIG["longname"]}"
readonly BIB_SCRIPT_LONGNAME

BIB_SCRIPT_BASEDIR=$(realpath $(bib.dirname ${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}))
[[ -n "${BIB_CONFIG["basedir"]}" ]] && BIB_SCRIPT_BASEDIR="${BIB_CONFIG["basedir"]}"
readonly BIB_SCRIPT_BASEDIR

BIB_SCRIPT_RUNTIMEDIR="${BIB_SCRIPT_BASEDIR}"
[[ -n "${BIB_CONFIG["runtimedir"]}" ]] && BIB_SCRIPT_RUNTIMEDIR="${BIB_CONFIG["runtimedir"]}"
readonly BIB_SCRIPT_RUNTIMEDIR

BIB_SCRIPT_STATEDIR="${BIB_SCRIPT_BASEDIR}"
[[ -n "${BIB_CONFIG["statedir"]}" ]] && BIB_SCRIPT_STATEDIR="${BIB_CONFIG["statedir"]}"
readonly BIB_SCRIPT_STATEDIR


## Shell options
shopt -s extglob


## Base configuration
# [[ -v BIB_CONFIG["interactive"] ]] && BIB_INTERACTIVE=$(( BIB_CONFIG["interactive"] || BIB_FALSE ))

if (( ! BIB_DEBUG ))
then
    [[ -v BIB_CONFIG["silent"] ]] && BIB_SILENT=${BIB_CONFIG["silent"]}
    if (( ! BIB_SILENT ))
    then
        [[ -v BIB_CONFIG["interactive"] ]] && BIB_INTERACTIVE=${BIB_CONFIG["interactive"]}
        [[ -v BIB_CONFIG["style"] ]] && bib.include _style
    else
        BIB_INTERACTIVE=${BIB_FALSE}
    fi

    (( BIB_CONFIG["assert"] )) && bib.include _assert
else
    bib.include _assert
    bib.include _style

    bib.warn "DEBUG MODE ENABLED"
fi

# (( BIB_CONFIG["redirect"] )) && _bib.redirect

(( BIB_CONFIG["no_cleanup_on_exit"] )) || trap "_bib.cleanup" EXIT

# Ensures that no spurious status code is returned
return ${BIB_E_OK}
