#!/bin/bash

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"

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

    local pkg="$1"
    local target_ver="${packages[$pkg]}"
    local local_ver=0

    [ -f "$INSTALLED_DIR/$pkg" ] && local_ver=$(cat "$INSTALLED_DIR/$pkg")

    if [ "$target_ver" != "$local_ver" ]; then

        echo "Updating: $pkg..."

        mkdir -p "$TEMP_DIR"

        local archive="${pkg}.tar"
        local workdir="$TEMP_DIR/$pkg"

        rm -rf "$workdir"
        mkdir -p "$workdir"

        if curl -L --fail "$SERVER_URL/$archive" -o "$TEMP_DIR/$archive"; then

            tar -xf "$TEMP_DIR/$archive" -C "$workdir"

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

            if [ -d "$workdir/glibc" ]; then

                find "$workdir/glibc" -type f | \
                sed "s|^$workdir/glibc/||" > "$remove_list"

                cp -rf "$workdir/glibc"/. "$PREFIX/"

            else

                find "$workdir" -type f | \
                sed "s|^$workdir/||" > "$remove_list"

                cp -rf "$workdir"/. "$PREFIX/"

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

curl -fsSL "https://raw.githubusercontent.com/TestAccount769/TestEmu64/main/testemu-override.sh" | bash
