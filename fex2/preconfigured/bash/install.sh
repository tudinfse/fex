#!/usr/bin/env bash

# == Manage fex2 dependencies ==

fex2::install::load_dependencies() {
    local my_dir="$(dirname "${BASH_SOURCE[0]}")"
    [ "${FEX2_UTIL_LOADED:-false}" = true ] || source $my_dir/util.sh
    FEX2_INSTALL_LOADED=true
}
fex2::install::load_dependencies


# == Helper functions ==

#######################################
# Ask user a yes or no question.
# Arguments:
#   question, question for user to be answered
# Returns:
#   true if user answers with yes otherwise false
#######################################
fex2::install::ask() {
    local question="$1" ; fex2::util::check_argument "$question"

    while true; do
        local yn="Y"
        if fex2::util::can_ask_user ; then
            read -p "$question [Yn]?" yn
        fi
        case $yn in
            [Yy]* ) true; return;;
            [Nn]* ) false; return;;
            * ) echo "Please answer 'y' or 'n'.";;
        esac
    done
}

#######################################
# Download a tar archive from URL and unpack it.
# Arguments:
#   url, source of the archive
#   unpack_path, path to unpack archive to
#   strip (Optionally), skips the uppermost directory of the archive.
#######################################
fex2::install::download_and_untar() {
    local url="$1" ; fex2::util::check_argument "$url"
    local unpack_path="$2" ; fex2::util::check_argument "$unpack_path"
    local strip=${3:-0} ;

    if [ -d "$unpack_path" ] && [ ! -z "$(ls -A "$unpack_path")" ]; then
        echo "The directory $unpack_path already exist."
        if fex2::install::ask "Do you wish to reinstall $unpack_path"; then
            rm -rf "$unpack_path"
        else
            echo "Skip";
            return;
        fi
    fi

    wget --progress=bar:force:noscroll -N -O tmp.tar ${url}
    mkdir -p ${unpack_path}
    tar xf tmp.tar -C ${unpack_path} --strip-components=${strip}
    rm tmp.tar
}

#######################################
# Clone a git repo from URL to a directory.
# Arguments:
#   url, source of the git repo
#   path, path to got clone destination
#   checkout (Optionally)
#######################################
fex2::install::clone_git_repo() {
    local url="$1" ; fex2::util::check_argument "$url"
    local path="$2" ; fex2::util::check_argument "$path"
    local checkout=$3

    if [ -d "$path" ] && [ ! -z "$(ls -A "$path")" ]; then
        echo "The directory $path already exist."
        if fex2::install::ask "Do you wish to reinstall $path"; then
            rm -rf "$path"
        else
            echo "Skip";
            return;
        fi
    fi

    if [ ! -z "$checkout" ]; then
        set +e
        git clone "$url" "$path"
        set -e
        pushd "$path"
        git checkout "$checkout"
        popd
    else
        set +e
        git clone --depth 1 "$url" "$path"
        set -e
    fi
}

#######################################
# Installs a dependency if wished by user.
# Arguments:
#   name, the name of the dependency
#   install_script, script to install the dependency
#######################################
fex2::install::install_dependency() {
    local name="$1" ; fex2::util::check_argument "$name"
    local install_script="$2" ; fex2::util::check_argument "$install_script"

    if fex2::install::ask "Do you wish to install $name"; then
        eval "$install_script"
    else
        echo "Skip";
    fi
}
