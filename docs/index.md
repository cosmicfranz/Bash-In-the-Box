# Bash-In-the-Box documentation


## Introduction

Bash-In-the-Box is a framework for Bash >= 5 aimed at *simplifying* code creation and organization.

In order to obtain such simplicity, this framework has been thought with a few requirements in mind:

* zero step, **drop-in installation**; it must work *out of the box*
* **unobtrusiveness**, that is, shallow learning curve, no imposition on coding style, no gobbledygook syntax (or, at least, not worse than plain Bash syntax), gradual introduction of features
* **usefulness and modularity**: include only code that is really needed
* the code has to be **pure Bash**, as much as possible, thus reducing dependencies on external software
* at the same time, good coding practices and readability must be encouraged

That said, let’s see what I have done so far to achieve these goals:

* a script can access this library by simply copying its content into a subdirectory and importing it with a call to `source`;
* the framework is organized in *libraries*, which are designed to be small and as easy as possible, so that...
* ... the developer can find and use just the functionalities of interest;
* currently Bash-In-the-Box relies only on Bash and (loosely) on GNU coreutils; though I have not yet tried, I think that it could be easily adapted to work with BusyBox
* looking at the documentation and inside the code, the developer can find out which coding style is suggested (but, again, not imposed)


## How to use Bash-In-the-Box

First and foremost, a rapid look at BItBox package reveals this directory structure:

```
Bash-In-the-Box
├── bitbox
├── docs
├── run_tests.sh
└── tests
```

The relevant directory here is `bitbox`, which contains the actual code.

This directory alone can be copied into the location that contains the calling script; at this point it can be enabled by inserting the following line into the calling script:

    source ${PWD}/bitbox/main.lib.sh

If a system-wide installation is desired, `BIB_HOME` environment variable must be defined and assigned the path to `Bash-In-the-Box`.

In this case, the calling script will contain this line:

    source ${BIB_HOME}/bitbox/main.lib.sh


### To install or *not* to install?

Once again, BItBox can work without requiring any preparation. The choice is up to the user.

Indeed, such choice depends on the use case: if a script is to be run in a small system, `bitbox` directory — or even parts of it — can be bundled with it. Conversely, if wider access to the various BItBox functionalities is needed, the whole package can be installed.

Optionally `run_tests.sh` script can be copied to or linked in `/usr/local/bin` if running unit tests is needed.

Anyway, a simple Makefile is provided to do all of these operations without hassles, neither for the user, nor for the packager.
