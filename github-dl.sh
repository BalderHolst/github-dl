#!/usr/bin/env bash

# Set the config directory
CONFIG_DIR="$HOME/.nix-config"

info () {
    echo -e "\u001b[34;1m$@\u001b[0m"
}

usage () {
    echo "$0 <username> <token> <output-dir>"
}

USER="$1"
TOKEN="$2"
OUT="$3"

if [ "$USER" = "" ]; then
    usage
    echo -e "\nUsername not proveded."
    exit 1
fi

if [ "$OUT" = "" ]; then
    usage
    echo -e "\nToken not proveded."
    exit 1
fi

if [ "$OUT" = "" ]; then
    usage
    echo -e "\nOutput directory not proveded."
    exit 1
fi

mkdir -p "$OUT"

REPOS=$(curl "https://api.github.com/search/repositories?q=user:$USER" \
    --header "Authorization: Token $TOKEN" \
    --header "X-GitHub-Api-Version: 2022-11-28" \
    | jq '.items[].ssh_url' -r)

backup () {
    url="$1"
    name="$(echo "$url" | awk -F\/ '{print $NF}' | rev | cut -c 5- | rev)"
    location="$OUT/$name"

    [[ -d "$location" ]] || {
        info "Cloning repo: $url"
        git clone "$url" "$location"
        return
    }

    [[ -d "$location/.git" ]] && {
        info "Pulling repo: $url"
        git -C "$location" pull
        return
    }

    echo "Can not clone into $location. Non-git directory is in the way."

}

for url in $REPOS
do
    backup "$url"
done
