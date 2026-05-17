#!/bin/bash

USER="TestAccount769"
REPO="TestEmu64"
TAG="assets"

SERVER_URL="https://github.com/$USER/$REPO/releases/download/$TAG"

ROOT_DIR="$PREFIX/glibc/opt/testemu"
INSTALLED_DIR="$ROOT_DIR/installed"
TEMP_DIR="$ROOT_DIR/temp"

mkdir -p "$INSTALLED_DIR" "$TEMP_DIR"

declare -A packages=(
    [core]="1.0"
    [engine]="1.0"
    [graphics]="1.0"
    [dx-bridge]="1.0"
    [applications]="1.0"
    [manager]="1.0"
)

sync_package() {

    local pkg=$1
    local target_ver=${packages[$pkg]}
    local local_ver=0

    [ -f "$INSTALLED_DIR/$pkg" ] && local_ver=$(cat "$INSTALLED_DIR/$pkg")

    if [ "$target_ver" != "$local_ver" ]; then

        echo "Updating: $pkg..."

        mkdir -p "$TEMP_DIR"

        local archive
        local workdir="$TEMP_DIR/$pkg"

        if [ "$pkg" = "manager" ]; then
            archive="${pkg}.tar"
        else
            archive="${pkg}.tar.xz"
        fi

        rm -rf "$workdir"
        mkdir -p "$workdir"

        if curl -L --fail "$SERVER_URL/$archive" -o "$TEMP_DIR/$archive"; then

            if [ "$pkg" = "manager" ]; then
                tar -xf "$TEMP_DIR/$archive" -C "$workdir"
            else
                tar -xJf "$TEMP_DIR/$archive" -C "$workdir"
            fi

            if find "$workdir" -type f | grep -qE '\.\./|^/'; then
                echo "Unsafe archive detected!"
                rm -rf "$workdir"
                rm -f "$TEMP_DIR/$archive"
                return 1
            fi

            remove_list="$INSTALLED_DIR/${pkg}.list"

            if [ -f "$remove_list" ]; then
                while read -r file; do
                    case "$file" in
                        ../*|/*)
                            ;;
                        *)
                            rm -rf "$PREFIX/$file" &>/dev/null
                            ;;
                    esac
                done < "$remove_list"
            fi

            find "$workdir" -type f | sed "s|^$workdir/||" > "$remove_list"

            if [ -d "$workdir/glibc" ]; then
                cp -rf "$workdir/glibc"/* "$PREFIX/"
            else
                cp -rf "$workdir"/* "$PREFIX/"
            fi

            echo "$target_ver" > "$INSTALLED_DIR/$pkg"
            echo "$pkg updated to $target_ver"

            rm -rf "$workdir"
            rm -f "$TEMP_DIR/$archive"

        else

            echo "Error: Failed to download $pkg"

        fi

    else

        echo "$pkg is up to date"

    fi
}

case $1 in

    "sync-all")

        for pkg in "${!packages[@]}"; do
            sync_package "$pkg"
        done

        ;;

    *)

        if [[ -n "${packages[$1]}" ]]; then
            sync_package "$1"
        else
            echo "Usage: ./packages.sh [sync-all|package_name]"
            echo "Available: ${!packages[@]}"
        fi

        ;;

esac
