# Bash completion for [Fabric](http://fabfile.org)


## Features

Script provides completion for `fab` tasks and long options.

All available tasks are cached in special file to speed up the response. Cache file with tasks updates on every `fabfile` modification.

Long options (like `--help`, `--version` etc.) are cached only when completion is used at first time.


## Installation

Download and add to your `.bashrc` file:

```bash
source /path/to/file/fabric-completion.bash
```

Add `.fab_tasks~` (see below) to your `.gitignore`.


## Settings

There are two params:

* Use cache files for `fab` tasks or not.

    Enabled by default.

    To disable add add the following line to your `.bashrc`:

    ```bash
    export FAB_COMPLETION_CACHE_TASKS=false
    ```

* File name where tasks cache will be stored (in current directory).

    Default value is `.fab_tasks~`.

    To change the name, add the following line to your `.bashrc`:

    ```bash
    export FAB_COMPLETION_CACHED_TASKS_FILENAME="<cache-file-name>"
    ```
