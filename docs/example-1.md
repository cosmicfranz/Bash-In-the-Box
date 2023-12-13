# Bash-In-the-Box documentation


> [!NOTE]
> The creation of a comprehensive documentation is underway. For now, I suggest to look at the code, which is thoroughly documented, or use the man pages linked below.

<details>
<summary>Documentation index</summary>

## Documentation

* [A non-trivial example](example-1.md)
* [Bash-In-the-Box man page](Bash-In-the-Box.7.md)
</details>


## A non-trivial example

Say that we want to mirror a remote site for use in our LAN.

We already have our command written as follows:
```bash
rsync -auvz --hard-links fr2.rpmfind.net::linux/rpmfusion/free/fedora/updates/39/x86_64 /var/www/rpmfusion/free/fedora/updates/39/x86_64
```
that we run manually as needed or as a scheduled cron job.

This command indeed does its job, but is a bit inflexible, since it exactly downloads a specific remote directory but does not care about its contents nor it knows about sibling directories with similar contents for different version or architectures.

OK, a couple of simple variables could solve the problem:
```bash
version=39; path=rpmfusion/free/fedora/updates/${version}/x86_64; rsync -auvz --hard-links fr2.rpmfind.net::linux/${path} /var/www/${path}
```

This is much better, in that the `rsync` command is now (almost) independent from the specific path.

But, you see, this has become a simple script, that we could save into a file, called (duh!) `update_mirror`:
```bash
#!/bin/bash

version=39
path=rpmfusion/free/fedora/updates/${version}/x86_64

rsync -auvz --hard-links fr2.rpmfind.net::linux/${path} /var/www/${path}
```

We could even refine it to accept a parameter from command line to select the version to download.


### So what? Do we need your framework to run this?

Certainly no, if you are happy to fiddle with long command lines and don’t have to manage many mirror.

But if you need to turn a script like this into something more powerful, Bash-In-the-Box can be a very handy toolkit to manage things like user interaction, logging, redirecting input and output, and more.

That said, let’s see how our script can be improved to become a powerful, reusable and maintainable tool.

First of all, we realize that `rsync` is a very complex software with many options that affect its behavior, so we could wrap it into a function in order to simplify its interface and make it accept parameters.
```bash
#!/bin/bash

function download_with_rsync() {
    local _source
    local _destination
    local _rsync_options="--archive --delete --hard-links"
    local _rsync_debug_options

    # this function accepts an optional “-v” option to enable verbose mode
    if [[ "${1}" == "-v" ]]
    then
        _rsync_debug_options="--verbose --progress"
        shift
    fi

    _source="${1}"
    _destination="${2}"

    rsync \
        ${_rsync_debug_options} \
        ${_rsync_options} \
        "${_source}" \
        "${_destination}"
}


####################


version=39
path=rpmfusion/free/fedora/updates/${version}/x86_64

download_with_rsync fr2.rpmfind.net::linux/${path} /var/www/${path}
```

So far so good, but what if we could avoid hard-coding the path and other metadata related to the repository we want to mirror?

Bash-In-the-Box offers support for *configuration files*, which can be imported in a script as associative arrays. This allows us to write all the repository metadata outside the script. Here’s how:
```
# file: rpmfusion_free.conf
# RPMFusion Free repository for Linux Fedora 39 (x86_64)

version = 39
arch = x86_64
site = fr2.rpmfind.net::linux
path = rpmfusion/free/fedora/updates/%(version)/%(arch)
destination = /var/www
```

Then we edit the script to look like this:
```bash
#!/bin/bash

# The following line enables Bash-In-the-Box.
# In this example we assume that the library is installed and BIB_HOME
# environment variable is set accordingly.
source ${BIB_HOME}/bitbox/main.lib.sh -

# Now that BItB is enabled, library modules can be called with bib.include()
# instead of “source” Bash builtin.
# The following line imports the configuration file manager.
bib.include cfg

# The script accepts the name of a configuration file, without extension.
declare config="${1}"

# This array will be filled with configuration keys.
declare -A repo_conf


####################


function download_with_rsync() {
    local _source
    local _destination
    local _rsync_options="--archive --delete --hard-links"
    local _rsync_debug_options

    # this function accepts an optional “-v” option to enable verbose mode
    if [[ "${1}" == "-v" ]]
    then
        _rsync_debug_options="--verbose --progress"
        shift
    fi

    _source="${1}"
    _destination="${2}"

    rsync \
        ${_rsync_debug_options} \
        ${_rsync_options} \
        "${_source}" \
        "${_destination}"
}


####################


# BIB_CFG_FILE variable is defined in “cfg” module.
BIB_CFG_FILE="${config}.conf"

# Calling the following function will populate “repo_conf” array defined above.
bib.cfg.from_file repo_conf

download_with_rsync \
    ${repo_conf["site"]}/${repo_conf["path"]} \
    ${repo_conf["destination"]}/${repo_conf["path"]}
```

This version of the script is a bit more elegant, because it can be called with the following, more concise and easy to remember command line:
```bash
$ ./update_mirror rpmfusion_free
```

Note that there is still much room for improvements, and that’s where BItBox can help.


<hr>

[Back to main page](index.md)
