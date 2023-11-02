## Bash-In-The-Box (BitBox)
## Copyright © 2023 Francesco Napoleoni
##
## This file is part of “Bash-In-The-Box”.
##
## “Bash-In-The-Box” is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by the
## Free Software Foundation, either version 3 of the License, or (at your
## option) any later version.
##
## “Bash-In-The-Box” is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
## or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
## more details.
##
## You should have received a copy of the GNU General Public License along with
## “Bash-In-The-Box”. If not, see <https://www.gnu.org/licenses/>.


########################################


#/**
# * Implements ANSI/VT100 style and color management.
# */


########################################


###############
## CONSTANTS ##
###############

#/**
# * Color codes.
# */
readonly -A _BIB_COLORS=(
    ["BLK"]=0   # black
    ["RED"]=1   # red
    ["GRN"]=2   # green
    ["ORN"]=3   # orange
    ["BLU"]=4   # blue
    ["PUR"]=5   # purple
    ["CYN"]=6   # cyan
    ["LGY"]=7   # light gray
    ["DEF"]=9   # default
    ["DGY"]=60  # dark gray
    ["LRD"]=61  # light red
    ["LGN"]=62  # light green
    ["YLW"]=63  # yellow
    ["LBL"]=64  # light blue
    ["LPU"]=65  # light purple
    ["LCY"]=66  # light cyan
    ["WHI"]=67  # white
)


#/**
# * Font style codes.
# */
readonly -A _BIB_FONT_STYLES=(
    ["NONE"]=0
    ["BOLD_ON"]=1
    ["DIM_ON"]=2
    ["ITALIC_ON"]=3
    ["UNDERLINE_ON"]=4
    ["BLINK_ON"]=5
    ["REVERSE_ON"]=7
    ["HIDE_ON"]=8
    ["STRIKE_ON"]=9
    ["BOLD_OFF"]=21
    ["DIM_OFF"]=22
    ["ITALIC_OFF"]=23
    ["UNDERLINE_OFF"]=24
    ["BLINK_OFF"]=25
    ["REVERSE_OFF"]=27
    ["HIDE_OFF"]=28
    ["STRIKE_OFF"]=29
)


#/**
# * Style modifiers allowed in input strings.
# */
readonly -A _BIB_MODIFIERS=(
    ["*"]="BOLD"
    ["@"]="DIM"
    ["/"]="ITALIC"
    ["_"]="UNDERLINE"
    ["#"]="BLINK"
    ["$"]="REVERSE"
    ["^"]="HIDE"
    ["-"]="STRIKE"
    ["&"]="COLOR"
)


########################################


###############
## VARIABLES ##
###############


########################################


###############
## FUNCTIONS ##
###############

#/**
# * Converts style modifiers into escape sequences.
# *
# * Syntax: bib.style STRING
# */
function bib.style() {
    local _string="${1}"
    local -i _i=0
    local _char
    local _modifier
    local __style
    local __color
    local _result
    local _style_format='\\e[%dm'
    local -i _style_code
    local -A _state=(
        ["STYLE"]=${BIB_FALSE}
        ["ESCAPE"]=${BIB_FALSE}
        ["BOLD"]=${BIB_FALSE}
        ["DIM"]=${BIB_FALSE}
        ["ITALIC"]=${BIB_FALSE}
        ["UNDERLINE"]=${BIB_FALSE}
        ["BLINK"]=${BIB_FALSE}
        ["REVERSE"]=${BIB_FALSE}
        ["HIDE"]=${BIB_FALSE}
        ["STRIKE"]=${BIB_FALSE}
        ["COLOR"]=${BIB_FALSE}
    )

    while (( _i < ${#_string} ))
    do
        _char="${_string:${_i}:1}"

        [[ "${_char}" == "\\" ]] && _state["ESCAPE"]=$(bib.not ${_state["ESCAPE"]})

        for _modifier in "${!_BIB_MODIFIERS[@]}"
        do
            if [[ "${_char}" == "${_modifier}" ]]
            then
                __style="${_BIB_MODIFIERS["${_char}"]}"
                _state["${__style}"]=$(bib.not ${_state["${__style}"]})

                if (( _state["COLOR"] ))
                then
                    __color="${_string:_i:4}"
                    _style_code=30
                    [[ -v _BIB_COLORS["${__color:1}"] ]] && _style_code+=${_BIB_COLORS["${__color:1}"]}
                    _state["COLOR"]=$(bib.not ${_state["COLOR"]})
                    _i+=3
#                     continue 2
                elif (( _state["${__style}"] ))
                then
                    _style_code=${_BIB_FONT_STYLES["${__style}_ON"]}
                else
                    _style_code=${_BIB_FONT_STYLES["${__style}_OFF"]}
                fi

                _state["STYLE"]=${BIB_TRUE}
                _result+="$(printf "${_style_format}" ${_style_code})"

                (( _i++ ))
                continue 2
            fi
        done

        _result+="${_char}"
        (( _i++ ))
    done

    (( _state["STYLE"] )) && _result+="$(printf "${_style_format}" ${_BIB_FONT_STYLES["NONE"]})"
    echo "${_result}"
}
