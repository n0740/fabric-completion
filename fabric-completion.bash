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


function __fab_completion() {
    # Return if
    # - fab command doesn't exists
    # - fabfile.py or fabfile dir with __init__.py doesn't exists
    local f="fabfile"
    [[ -e `which fab` && (-e "$f.py" || (-d "$f" && -e "$f/__init__.py")) ]] || return 0

    # Variables to hold the current word and possible matches
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local opts

    # Generate possible matches and store them in variable "opts"
    case "${cur}" in
        --*)
            if [[ -z "${__FAB_COMPLETION_LONG_OPT}" ]]; then
                export __FAB_COMPLETION_LONG_OPT="
                    --help --version --list --shortlist --list-format=
                    --display= --reject-unknown-hosts --disable-known-hosts
                    --user= --password= --hosts= --roles= --exclude-hosts=
                    --no_agent --no-keys --fabfile= --warn-only --shell=
                    --config= --hide= --show= --no-pty --abort-on-prompts
                    --keepalive="
            fi
            opts="${__FAB_COMPLETION_LONG_OPT}"
            ;;

        -*)
            if [[ -z "${__FAB_COMPLETION_SHORT_OPT}" ]]; then
                export __FAB_COMPLETION_SHORT_OPT="
                    -h -V -l -F -d -r -D -u -p -H -R -x -i -a -k -f -w -s -c"
            fi
            opts="${__FAB_COMPLETION_SHORT_OPT}"
            ;;

        *)
            # Build a list of the available tasks
            if [[ $FAB_COMPLETION_CACHE_TASKS -eq 1 ]]; then
                # If use cache
                if [[ ! -s ${FAB_COMPLETION_CACHED_TASKS_FILENAME} ]]; then
                    # File.mtime(cache_file) >= File.mtime(rakefile)
                    fab --shortlist > ${FAB_COMPLETION_CACHED_TASKS_FILENAME}
                fi
                opts=$(cat ${FAB_COMPLETION_CACHED_TASKS_FILENAME})
            else
                # Without cache
                opts=$(fab --shortlist)
            fi
            ;;
    esac

    # Set possible completions
    COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
}
complete -o default -o nospace -F __fab_completion fab
