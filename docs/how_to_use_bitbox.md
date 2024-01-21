# Bash-In-the-Box documentation


> [!NOTE]
> The creation of a comprehensive documentation is underway. For now, I suggest to look at the code, which is thoroughly documented, or use the man pages linked below.

<details>
<summary>Documentation index</summary>

## Documentation

* [A non-trivial example](example-1.md)
* [The main library, or how to use BItBox](how_to_use_bitbox.md)
* [Bash-In-the-Box man page](Bash-In-the-Box.7.md)
</details>


## The `main` library, or how to use Bash-In-the-BItBox

A rapid look at BItBox package reveals this directory structure:

    Bash-In-the-Box/
    ├── bitbox/
    │   └── unittest/
    ├── docs/
    ├── sh/
    └── tests/

The most important directory is `bitbox`, which contains the actual code of the library.

This directory alone can be copied into the location that contains the calling script; at this point it can be enabled by inserting the following line into the calling script:

    source ${PWD}/bitbox/main.lib.sh -

Note the dash (“-”) at the end: it is a dummy argument that must be passed if the script starts with this line. If omitted, any arguments passed to the script are inherited by `source`, which is undesirable.

When not passing a base configuration, it is always safe and advisable to use the dash.


## Environment

The only environment variable used by BItBox is `BIB_HOME`, which can be (optionally) set to the path where the package resides. For example, if BItBox has been unpacked into `/usr/local/Bash-In-the-Box`, to enable system-wide access to it, the following command has to be issued:

    export BIB_HOME=/usr/local/Bash-In-the-Box

A script wanting to use BItBox should contain this line:

    source ${BIB_HOME}/bitbox/main.lib.sh -

If BItBox is embedded into the script directory, `BIB_HOME` can be left unset.


## Conventions

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
:   their typical scope is script-level or function-level; their name contains exactly one starting underscore (ex. `_bib.redirect()`); they must not be used outside their scope

**reserved** members
:   their typical scope is function-level or (rarely) script-level; their name contains two starting underscores; they should be never declared as such unless really needed, and used only at the deepest levels of code. A name reference to a reserved variable must not be passed to a function.


## Run-time base configuration

The behavior of the various components of BItBox can be influenced by setting appropriate global variables, called *base configuration variables*.

BItBox provides a handy feature for initializing configuration variables in a single step. An associative array, called base configuration can be filled with relevant elements and passed to BItBox this way:

    source ${BIB_HOME}/bitbox/main.lib.sh CONFIGURATION

where CONFIGURATION is the name reference to the associative array.

Currently `main` library exposes a number of base configuration variables, as shown in table.

| Key | Variable | Type | Description |
| --- | -------- | ---- | ----------- |
| `name` | `BIB_SCRIPT_NAME` | *string* | The name of the calling script |
| `longname` | `BIB_SCRIPT_LONGNAME` | *string* | The readable, longer name of the calling script |
| `version` | `BIB_SCRIPT_VERSION` | *string* | The version string of the calling script |
| `interactive` | `BIB_INTERACTIVE` | *boolean (0 or 1)* | Can be used to control output messages from the script, as well as other forms of user interaction |
| `style` | *none* | *boolean (0 or 1)* | If set to 1 (true) enables text style and color |
| `basedir` | `BIB_SCRIPT_BASEDIR` | *string* | the directory containing the calling script |
| `runtimedir` | `BIB_SCRIPT_RUNTIMEDIR` | *string* | the directory containing runtime data |
| `statedir` | `BIB_SCRIPT_STATEDIR` | *string* | the directory containing state related data |
| `debug` | *none* | *boolean (0 or 1)* | If set to 1 (true) enables debug mode |
| `redirect` | `BIB_REDIRECT` | *boolean (0 or 1)* | If set to 1 (true) redirects stdout and stderr for finer output control (currently untested) |

Other libraries may expose their own configuration variables and related keys of the base configuration.


<hr>

[Back to main page](index.md)
