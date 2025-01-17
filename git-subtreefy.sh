#!/usr/bin/env bash
# Usage:
# $ cd repo
# $ git-subtreefy.sh [subtree|subrepo]

function git_remote_by_url() {
    for name in `git remote`; do
        if [ "$1" == "`git remote get-url $name`" ]; then
            printf $name
            return 0
        fi
    done
    return 1
}

function git_remote_get_or_add() {
    git_remote_by_url $1 || { git remote add $2 $1; printf $2; }
}

function submodule_init_all() {
    git submodule sync --recursive
    git submodule update --recursive --init --depth=1
}

function submodule_deinit_all() {
    git submodule deinit --all
}

function submodule_list_all() {
    git submodule foreach --recursive --quiet 'echo $name $displaypath `git remote get-url origin` $sha1'
}

function submodule_dehydrate() {
    submodule_init_all
    local modules=`submodule_list_all`
    submodule_deinit_all

    echo "$modules" | while read modname modpath modurl modhash; do
        local remote
        if [ "$1" != "subrepo" ]; then
            remote=`git_remote_get_or_add $modurl $modname`
        fi
        git rm -rf $modpath
        git commit -m "Remove submodule $modname"
        if [ "$1" == "subrepo" ]; then
            git subrepo clone $modurl $modpath -b $modhash
        else
            git subtree add --prefix=$modpath $remote $modhash
        fi
    done

    git rm -f .gitmodules
    git commit -m "Remove .submodules"

}

[ -f ".gitmodules" ] || {
    echo "No submodules found"
    exit 1
}

submodule_dehydrate $1