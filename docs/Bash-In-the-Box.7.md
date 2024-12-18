# Bash-In-the-Box

# NAME

* Bash-In-the-Box
* BItBox (Bitbox or bitbox)
* BItB
* BIB (bib)


# DESCRIPTION

Bash-In-the-Box is a framework for Bash >= 5 aimed at simplifying code creation and organization.

## How to use Bash-In-the-Box

A rapid look at BItBox package reveals this directory structure:

    Bash-In-the-Box
    ├── bitbox
    ├── docs
    ├── run_tests.sh
    └── tests

The relevant directory here is `bitbox`, which contains the actual code.

This directory alone can be copied into the location that contains the calling script; at this point it can be enabled by inserting the following line into the calling script:

    source ${PWD}/bitbox/main.lib.sh -


# ENVIRONMENT

The only relevant environment variable is `BIB_HOME`, which can be (optionally) set to the path where the package resides. For example, if BItBox has been unpacked into `/usr/local/Bash-In-the-Box`, to enable system-wide access to it, the following command has to be issued:

    export BIB_HOME=/usr/local/Bash-In-the-Box

A script wanting to use BItBox should contain this line:

    source ${BIB_HOME}/bitbox/main.lib.sh -

If BItBox is embedded into the script directory, `BIB_HOME` can be left unset.


# CONVENTIONS

BItBox is organized in libraries (or modules), each named `<module_name>.lib.sh`. A library provides related variables, constants and functions, collectively called *members*.

Constants and configuration variables are written upper-case (for example `BIB_TRUE`) while variables and functions are written lower-case.


### Member naming

In order to avoid naming clashes, every member uses an appropriate naming scheme that guarantees its uniqueness. This scheme is somewhat similar to the one adopted in C language libraries.

So, for example, in `filedir` library we find the following definition:

    declare -gi BIB_CFG_CONTINUE_ON_ERROR=${BIB_FALSE}

Reading this line we see that

* this is a global variable (declared with `declare -g`)
* it is a configuration variable (it is written upper-case)
* it is public (lacks a starting "_" in the name, more on this later)

At a closer look, the (fully qualified) name shows the following scheme:

1. the first word before the underscore is always the package name, in this case `BIB`
2. immediately following is the name of the module, in this case `FILEDIR`
3. the rest of the name is the name of the variable itself.

The typical separator used for variables and constants is "_" (underscore), while "." (dot) is used for functions.

The first two parts of the fully qualified name (the package name and the module/submodule parts) constitute the namespace.


### Member visibility

This is another concept borrowed from object oriented languages, in order to better organize the code.

It is worth remembering that Bash does not know anything about this concept, so there is no way to really enforce a level of visibility of a member.

Visibility level is shown by marking a member name with zero, one or two starting underscores.

So we can have:

**public** members
:   they have a global or script-level scope; their name contains no starting underscores (ex. `BIB_TRUE`)

**private** members
:   their typical scope is script-level or function-level; their name contains exactly one starting underscore (ex. _bib.redirect()); they must not be used outside their scope

**reserved** members
:   their typical scope is function-level or (rarely) script-level; their name contains two starting underscores; they should be never declared as such unless really needed, and used only at the deepest levels of code. A name reference to a reserved variable must not be passed to a function.


# RUN-TIME CONFIGURATION

The behavior of the various components of BItBox can be influenced by setting appropriate global variables, called configuration variables.

BItBox provides a handy feature for initializing configuration variables in a single step. An associative array, called base configuration can be filled with relevant elements and passed to BItBox this way:

    source ${BIB_HOME}/bitbox/main.lib.sh CONFIGURATION

where CONFIGURATION is the name reference to the associative array.

Every library exposes its own configuration variables and related keys of the base configuration.
