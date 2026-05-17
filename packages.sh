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

        local filename
        local tar_args

        # manager = .tar
        # everything else = .tar.xz

        if [ "$pkg" = "manager" ]; then
            filename="${pkg}.tar"
            tar_args="-xf"
        else
            filename="${pkg}.tar.xz"
            tar_args="-xJf"
        fi

        if curl -L --fail "$SERVER_URL/$filename" -o "$TEMP_DIR/$filename"; then

            # Security check
            if tar -tf "$TEMP_DIR/$filename" | grep -qE '^(/|\.{2}/)'; then
                echo "Unsafe archive detected!"
                rm -f "$TEMP_DIR/$filename"
                return 1
            fi

            # Remove old files
            if [ -f "$INSTALLED_DIR/${pkg}.list" ]; then

                while read -r file; do

                    case "$file" in
                        ../*|/*)
                            echo "Skipping unsafe path: $file"
                            ;;
                        *)
                            rm -rf "$PREFIX/$file" &>/dev/null
                            ;;
                    esac

                done < "$INSTALLED_DIR/${pkg}.list"

            fi

            # Save file list
            tar -tf "$TEMP_DIR/$filename" > "$INSTALLED_DIR/${pkg}.list"

            # Extract
            if tar $tar_args "$TEMP_DIR/$filename" -C "$PREFIX/"; then

                echo "$target_ver" > "$INSTALLED_DIR/$pkg"
                echo "$pkg updated to $target_ver"

            else

                echo "Extraction failed for $pkg"

            fi

        else

            echo "Error: Failed to download $pkg"

        fi

        rm -f "$TEMP_DIR/$filename"

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
