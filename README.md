# Bash completion for [fabric](http://fabfile.org)


## Features

This script provides completion for `fab` tasks and long options.

All available tasks are cached in special file to speed up the response. Cache file with tasks updates on every `fabfile` modification.

Long options (like `--help`, `--version` etc.) are cached only when completion is used at first time.


## Installation

Download and add to your `.bashrc` file:

    source /path/to/file/fabric-completion.bash


## Settings

There are two params:

* Use cache files for fab tasks or not.

    Enabled on default. To disable add to your `.bashrc`:

        export FAB_COMPLETION_CACHE_TASKS=false

* File name where tasks cache will be stored (in current directory).

    Default value is `.fab_tasks~`. To change it add to your `.bashrc`:

        export FAB_COMPLETION_CACHED_TASKS_FILENAME="<cache-file-name>"
