# Bash-In-the-Box

*October 2023*

## Introduction

A framework for Bash >= 5 aimed at *simplifying* code creation and organization. Indeed, *simplicity* is the keyword, but let me explain better.

In order to obtain such simplicity, this framework has been thought with a few requirements in mind:

* zero step, **drop-in installation**; it must work *out of the box*
* **unobtrusiveness**, that is, shallow learning curve, no imposition on coding style, no gobbledygook syntax (or, at least, not worse than plain Bash syntax), gradual introduction of features
* **usefulness and modularity**: include only code that is really needed
* the code has to be **pure Bash**, as much as possible, thus reducing dependencies on external software
* at the same time, good coding practices and readability must be encouraged

Quite ambitious goals, huh? Well, first of all, let’s say that I’m no Bash guru, just a user who does much scripting for his own needs, and would like to avoid code repetitions and maintainability woes. Moreover, in order to unleash many interesting but obscure Bash features, I seek clearer syntax and ease of use.

That said, let’s see what I have done so far to achieve these goals:

* a script can access this library by simply copying its content into a subdirectory and importing it with a call to `source`;
* the framework is organized in *libraries*, which are designed to be small and as easy as possible, so that...
* ... the developer can find and use just the functionalities of interest;
* currently Bash-In-the-Box relies only on Bash and (loosely) on GNU coreutils; though I have not tried, I think that it could be easily adapted to work with BusyBox
* looking at the documentation and inside the code, the developer can find out which coding style is suggested (but, again, not imposed)

## Quickstart

A plain “Hello world” script could be written like this:

    source ${PWD}/bitbox/main.lib.sh
    bib.print "Hello world!\n"

The first line imports the “main” library, giving access to some basic functions, one of them being `bib.print()`, used on the second line. It is a wrapper of `printf` Bash builtin, extending a bit its functionality while retaining pretty much the same syntax.

This script expects Bash-In-the-Box to be found in a subdirectory called `bitbox`.

Of course `echo` or `printf` could still be used to print text to screen, but using `bib.print()` is recommended for scripts that interact with the user (*interactive* from now on). Let’s see why.

The following example prints two strings, the first to the standard output, the other to the standard error:

    source ${PWD}/bitbox/main.lib.sh
    bib.print "Hello world!\n"
    bib.print -e "This goes to standard error\n"

OK, this may not make you jump on your chair. But enter the **configuration**:

    declare -A conf=(
        ["style"]=1
    )
    source ${PWD}/bitbox/main.lib.sh conf
    bib.print -e "*Hello world*, with some /style/\n"

What’s happening here? An associative array is initialized with a *key-value* pair, the `style` flag, which enables colored text as well as font styles (bold, italic...).

The name of the array is passed to the `source` builtin, and the magic happens. The output of `bib.print()` now looks similar to this:

> **Hello world**, with some *style*

printed on the standard error.

To obtain the same effect using plain Bash, the script would look like this:

    printf "\033[1mHello world\033[21m, with some \033[3mstyle\033[23m\n" >&2

Compared to the last line of the previous code, it is much less readable, and requires remembering escape codes that modify the font style; moreover we have to fiddle with output redirection.

## Features

* functions for text processing and formatting
* file and directory manipulation
* logging to files, syslog, console
* unit testing
* functions for array manipulation
* configuration through files
* basic DB operations (currently support only for SQLite)

## Limitations

* For now it is Bash specific
* developed and tested only on Linux
* not caring of POSIX compliance

## Installation

As said before, Bash-In-the-Box does not require installation: the entire library can be copied into the directory containing the calling script.

However it can be used as a system-wide library, by just copying it into some directory and setting the `BIB_HOME` environment variable to its path.
