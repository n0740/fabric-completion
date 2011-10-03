#!/bin/bash
# 
# Bash completion support for Fabric (http://fabfile.org/)
#
# Thanks to:
# - Adam Vandenberg, https://github.com/ricobl/dotfiles/blob/master/bin/fab_bash_completion
# - Enrico Batista da Luz, https://github.com/adamv/dotfiles/blob/master/completion_scripts/fab_completion.bash
#


export FAB_COMPLETION_CACHE_TASKS=1
export FAB_COMPLETION_CACHED_TASKS_FILENAME=".fab_tasks~"


#
# Return time of last file modification as seconds since Epoch
# TODO: check on Linux
#
function __fab_file_mtime() {
    local file=$1
    case `uname` in
        Darwin|FreeBSD)
            echo `stat -f '%m' $file`
            ;;
        *)
            echo `stat -c '%Y' $file`
            ;;
    esac
}


#
# Get time of last fab cache file modification as seconds since Epoch
#
function __fab_chache_mtime() {
    __fab_file_mtime $FAB_COMPLETION_CACHED_TASKS_FILENAME
}


#
# Get time of last fabfile file/module modification as seconds since Epoch
#
function __fab_fabfile_mtime() {
    local f="fabfile"
    if [[ -e "$f.py" ]]; then
        __fab_file_mtime "$f.py"
    else
        # Suppose that it's a fabfile dir
        find $f/*.py -exec __fab_file_mtime {} + | sort -n -r | head -1
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
        --*)
            if [[ -z "${__FAB_COMPLETION_LONG_OPT}" ]]; then
                export __FAB_COMPLETION_LONG_OPT=$(
                    fab --help | egrep -o "\-\-[A-Za-z_\-]+\=?" | sort -u)
            fi
            opts="${__FAB_COMPLETION_LONG_OPT}"
            ;;

        -*)
            if [[ -z "${__FAB_COMPLETION_SHORT_OPT}" ]]; then
                export __FAB_COMPLETION_SHORT_OPT=$(
                    fab --help | egrep -o "^ +\-[A-Za-z_\]" | sort -u)
            fi
            opts="${__FAB_COMPLETION_SHORT_OPT}"
            ;;

        *)
            # If "fabfile.py" or "fabfile" dir with "__init__.py" file exists
            local f="fabfile"
            if [[ -e "$f.py" || (-d "$f" && -e "$f/__init__.py") ]]; then
                # Build a list of the available tasks
                if [[ $FAB_COMPLETION_CACHE_TASKS -eq 1 ]]; then
                    # If use cache
                    if [[ ! -s ${FAB_COMPLETION_CACHED_TASKS_FILENAME} ||
                          $(__fab_fabfile_mtime) -gt $(__fab_chache_mtime) ]]; then
                        fab --shortlist > ${FAB_COMPLETION_CACHED_TASKS_FILENAME}
                    fi
                    opts=$(cat ${FAB_COMPLETION_CACHED_TASKS_FILENAME})
                else
                    # Without cache
                    opts=$(fab --shortlist)
                fi
            fi
            ;;
    esac

    # Set possible completions
    COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
}
complete -o default -o nospace -F __fab_completion fab
