#####################
### Guard library ###
#####################
guard_source_max_once() {
    local file_name="$(basename "${BASH_SOURCE[0]}")"
    local guard_var="guard_${file_name%.*}" # file_name wo file extension

    [[ "${!guard_var}" ]] && return 1
    [[ "$guard_var" =~ ^[_a-zA-Z][_a-zA-Z0-9]*$ ]] \
        || { echo "Invalid guard: '$guard_var'"; exit 1; }
    declare -gr "$guard_var=true"
}

guard_source_max_once || return 0

##############################
### Library initialization ###
##############################
init_lib()
{
    # Unset as only called once and most likely overwritten when sourcing libs
    unset -f init_lib

    if ! [[ -d "$LIB_PATH" ]]
    then
        echo "LIB_PATH is not defined to a directory for the sourced script."
        echo "LIB_PATH: '$LIB_PATH'"
        exit 1
    fi

    ### Source libraries ###
    #
    # Always start with 'lib_core.bash'
    source "$LIB_PATH/lib_core.bash" || exit 1
    source_lib "$LIB_PATH/lib_handle_input.bash"
}

init_lib

#####################
### Library start ###
#####################

###
# List of functions for usage outside of lib
#
# - find_kernel()
# - find_os()
# - unhandled_return_code()
###


register_help_text 'find_kernel' \
"find_kernel

Finds which kernel that is used. Native linux or
Windows Subsystem for Linux (WSL).

Output variables:
* found_kernel:
    - 'native' if native Linux
    - 'wsl' if Windows Subsystem for Linux (WSL)"

register_function_flags 'find_kernel'

find_kernel()
{
    _handle_args 'find_kernel' "$@"

    found_kernel='native'
    uname -r | grep -qEi "microsoft|wsl" && found_kernel='wsl'
}

register_help_text 'find_os' \
"find_os

Finds which operating system that is used.

Output variables:
* found_os:
    Example:
    - 'debian' if Debian
    - 'ubuntu' if Ubuntu"

register_function_flags 'find_os'

find_os()
{
    _handle_args 'find_os' "$@"

    if ! [[ -f /etc/os-release ]]
    then
        echo "Found no OS information."
        exit 1
    fi

    # $ID stores information e.g. ubuntu/debian/
    . /etc/os-release

    found_os="$ID"
}

register_help_text 'unhandled_return_code' \
"unhandled_return_code

Outputs error about unhandled '\$return_code'

Example:
    case \"\$return_code\" in
        0) ;;
        1) ;;
        *)
            unhandled_return_code
            ;;
    esac
"

register_function_flags 'unhandled_return_code'

unhandled_return_code()
{
    echo_error "Unhandled return code. Check return code: '$return_code'"
    return 0
}
