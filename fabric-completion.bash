#!/bin/bash
#
# Bash completion support for Fabric (http://fabfile.org/)
#
# Thanks to:
# - Adam Vandenberg,
#   https://github.com/ricobl/dotfiles/blob/master/bin/fab_bash_completion
#
# - Enrico Batista da Luz,
#   https://github.com/adamv/dotfiles/blob/master/completion_scripts/fab_completion.bash
#


# If set to 1 completion will use cache for tasks, otherwise
# command "fab --shortlist" will be excecuted every time
export FAB_COMPLETION_CACHE_TASKS=1
export FAB_COMPLETION_CACHE_TASKS=true

# File name where task cache will be stored in current dir
export FAB_COMPLETION_CACHED_TASKS_FILENAME=".fab_tasks~"


# Set command to get time of last file modification as seconds since Epoch
case `uname` in
    Darwin|FreeBSD)
        __FAB_COMPLETION_MTIME_COMMAND="stat -f '%m'"
        ;;
    *)
        __FAB_COMPLETION_MTIME_COMMAND="stat -c '%Y'"
        ;;
esac


#
# Get time of last fab cache file modification as seconds since Epoch
#
function __fab_chache_mtime() {
    ${__FAB_COMPLETION_MTIME_COMMAND} \
        $FAB_COMPLETION_CACHED_TASKS_FILENAME | xargs -n 1 expr
}


#
# Get time of last fabfile file/module modification as seconds since Epoch
#
function __fab_fabfile_mtime() {
    local f="fabfile"
    if [[ -e "$f.py" ]]; then
        ${__FAB_COMPLETION_MTIME_COMMAND} "$f.py" | xargs -n 1 expr
    else
        # Suppose that it's a fabfile dir
        find $f/*.py -exec ${__FAB_COMPLETION_MTIME_COMMAND} {} + \
            | xargs -n 1 expr | sort -n -r | head -1
    fi
}


#
# Completion for "fab" command
#
function __fab_completion() {
    # Return if "fab" command doesn't exists
    [[ -e `which fab` ]] || return 0

    # Variables to hold the current word and possible matches
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local opts=()

    # Generate possible matches and store them in variable "opts"
    case "${cur}" in
        -*)
            if [[ -z "${__FAB_COMPLETION_LONG_OPT}" ]]; then
                export __FAB_COMPLETION_LONG_OPT=$(
                    fab --help | egrep -o "\-\-[A-Za-z_\-]+\=?" | sort -u)
            fi
            opts="${__FAB_COMPLETION_LONG_OPT}"
            ;;

        # Completion for short options is not nessary.
        # It's left here just for history.
        # -*)
        #     if [[ -z "${__FAB_COMPLETION_SHORT_OPT}" ]]; then
        #         export __FAB_COMPLETION_SHORT_OPT=$(
        #             fab --help | egrep -o "^ +\-[A-Za-z_\]" | sort -u)
        #     fi
        #     opts="${__FAB_COMPLETION_SHORT_OPT}"
        #     ;;

        *)
            # If "fabfile.py" or "fabfile" dir with "__init__.py" file exists
            local f="fabfile"
            if [[ -e "$f.py" || (-d "$f" && -e "$f/__init__.py") ]]; then
                # Build a list of the available tasks
                if $FAB_COMPLETION_CACHE_TASKS; then
                    # If use cache
                    if [[ ! -s ${FAB_COMPLETION_CACHED_TASKS_FILENAME} ||
                          $(__fab_fabfile_mtime) -gt $(__fab_chache_mtime) ]]; then
                        fab --shortlist > ${FAB_COMPLETION_CACHED_TASKS_FILENAME} \
                            2> /dev/null
                    fi
                    opts=$(cat ${FAB_COMPLETION_CACHED_TASKS_FILENAME})
                else
                    # Without cache
                    opts=$(fab --shortlist 2> /dev/null)
                fi
            fi
            ;;
    esac

    # Set possible completions
    COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
}
complete -o default -o nospace -F __fab_completion fab
