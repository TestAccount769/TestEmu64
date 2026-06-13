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
[core]="2.0"
[engine]="2.0"
[graphics]="2.0"
[dx-bridge]="2.0"
[applications]="2.0"
[manager]="2.0"
)

remove_package() {
if [ -f "$INSTALLED_DIR/${1}.list" ]; then
while read -r file; do
rm -rf "$PREFIX/$file" 2>/dev/null
done < "$INSTALLED_DIR/${1}.list"
fi

```
rm -f "$INSTALLED_DIR/$1"
rm -f "$INSTALLED_DIR/${1}.list"
```

}

sync_package() {
local pkg="$1"
local version="${packages[$pkg]}"
local local_version=0

```
[ -f "$INSTALLED_DIR/$pkg" ] && local_version=$(cat "$INSTALLED_DIR/$pkg")

if [ "$version" != "$local_version" ]; then

    echo "Updating $pkg"

    rm -rf "$TEMP_DIR/$pkg"
    mkdir -p "$TEMP_DIR/$pkg"

    if curl -L --fail "$SERVER_URL/$pkg.tar" -o "$TEMP_DIR/$pkg.tar"; then

        tar -xf "$TEMP_DIR/$pkg.tar" -C "$TEMP_DIR/$pkg"

        remove_package "$pkg"

        find "$TEMP_DIR/$pkg" -type f | sed "s|^$TEMP_DIR/$pkg/||" > "$INSTALLED_DIR/${pkg}.list"

        cp -rf "$TEMP_DIR/$pkg/glibc" "$PREFIX"

        echo "$version" > "$INSTALLED_DIR/$pkg"

        rm -f "$TEMP_DIR/$pkg.tar"
        rm -rf "$TEMP_DIR/$pkg"

        echo "$pkg updated"

    else

        echo "Failed $pkg"

    fi
else
    echo "$pkg is up to date"
fi
```

}

case "$1" in

sync-all)

for pkg in "${!packages[@]}"; do
sync_package "$pkg"
done

;;

*)

if [[ -n "${packages[$1]}" ]]; then
sync_package "$1"
else
echo "Usage: $0 sync-all|package"
echo "Packages: ${!packages[@]}"
fi

;;

esac

echo "Applying overrides..."
curl -fsSL "https://raw.githubusercontent.com/TestAccount769/TestEmu64/main/testemu-override.sh" | bash
echo "Done"
