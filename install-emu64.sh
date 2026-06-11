#!/bin/bash

C_CYAN='\033[0;36m'
C_NEON='\033[1;32m'
C_PURP='\033[0;35m'
C_GOLD='\033[1;33m'
C_RED='\033[0;31m'
C_BOLD='\033[1m'
NC='\033[0m'

print_status() {
    echo -e "\n${C_CYAN}${C_BOLD}>>> $1 <<<${NC}\n"
}

install_group() {
    local group_name="$1"
    shift

    print_status "$group_name"

    for pkgname in "$@"; do
        echo -ne "${C_GOLD}[*] $pkgname... ${NC}"

        if $PKG install -y "$pkgname" >/dev/null 2>&1; then
            echo -e "${C_NEON}DONE${NC}"
        else
            echo -e "${C_RED}FAILED${NC}"
        fi
    done
}

download_file() {
    local url="$1"
    local output="$2"

    curl -fsSL \
        --retry 5 \
        --retry-delay 2 \
        --connect-timeout 15 \
        "$url" -o "$output"
}

IS_TERMUX=0

if [ -d "/data/data/com.termux/files/usr" ]; then
    IS_TERMUX=1
    PREFIX="/data/data/com.termux/files/usr"
    PKG="pkg"
else
    PREFIX="$HOME/testemu64"
    PKG="apt"
fi

clear

if [ "$IS_TERMUX" -eq 1 ]; then
    print_status "REQUESTING STORAGE ACCESS"

    termux-setup-storage >/dev/null 2>&1

    while [ ! -d "$HOME/storage/shared" ]; do
        echo -ne "${C_RED}\r[!] WAITING FOR STORAGE PERMISSION...${NC}"
        sleep 2
    done

    echo -e "\n${C_NEON}[+] ACCESS GRANTED.${NC}"
fi

print_status "UPDATING PACKAGE DATABASE"

if ! $PKG update -y >/dev/null 2>&1; then
    echo -e "${C_RED}[!] PACKAGE DATABASE UPDATE FAILED.${NC}"
    exit 1
fi

print_status "CHECKING INTERNET"

if ! ping -c 1 github.com >/dev/null 2>&1; then
    echo -e "${C_RED}[!] NO INTERNET CONNECTION.${NC}"
    exit 1
fi

if [ "$IS_TERMUX" -eq 1 ]; then
    print_status "ENABLING REPOSITORIES"

    if ! pkg install -y x11-repo root-repo glibc-repo >/dev/null 2>&1; then
        echo -e "${C_RED}[!] FAILED TO ENABLE REPOSITORIES.${NC}"
        exit 1
    fi
fi

install_group "Core Tools" \
bash which file coreutils findutils grep sed gawk util-linux procps less tree \
curl wget aria2 git openssh rsync zip unzip p7zip tar gzip bzip2 xz-utils

install_group "Development Stack" \
clang make cmake ninja pkg-config binutils lld autoconf automake libtool m4 \
patchelf gdb strace

install_group "Libraries" \
openssl ca-certificates libcurl libnghttp2 zlib libpng libjpeg-turbo libtiff \
libwebp sqlite libffi libxml2 libxslt readline ncurses ncurses-utils

install_group "Multimedia & Graphics" \
pulseaudio alsa-lib alsa-utils openal-soft mesa mesa-demos xwayland \
xorg-xrandr libx11 libxext libxrender

if [ "$IS_TERMUX" -eq 1 ]; then
    echo -ne "${C_GOLD}[*] termux-x11... ${NC}"

    if pkg install -y termux-x11-nightly >/dev/null 2>&1; then
        echo -e "${C_NEON}DONE${NC}"
    elif pkg install -y termux-x11 >/dev/null 2>&1; then
        echo -e "${C_NEON}DONE${NC}"
    else
        echo -e "${C_RED}FAILED${NC}"
    fi
fi

install_group "Extra Utilities" \
hashdeep tsu dos2unix inetutils net-tools dialog termux-am

print_status "PREPARING ENVIRONMENT"

if [ -d "$PREFIX/glibc" ]; then
    rm -rf "$PREFIX/glibc.backup"
    mv "$PREFIX/glibc" "$PREFIX/glibc.backup"
fi

PM_DIR="$PREFIX/glibc/opt/testemu"
BIN_DIR="$PREFIX/glibc/glibc/bin"

mkdir -p \
"$PM_DIR/installed" \
"$PM_DIR/temp" \
"$BIN_DIR"

PM_URL="https://raw.githubusercontent.com/TestAccount769/TestEmu64/main/packages.sh"

print_status "DOWNLOADING PACKAGE MANAGER"

if ! download_file "$PM_URL" "$BIN_DIR/packages.sh"; then
    echo -e "${C_RED}[!] FAILED TO DOWNLOAD PACKAGE MANAGER.${NC}"

    if [ -d "$PREFIX/glibc.backup" ]; then
        mv "$PREFIX/glibc.backup" "$PREFIX/glibc"
    fi

    exit 1
fi

chmod +x "$BIN_DIR/packages.sh"

print_status "SYNCING PACKAGES"

if ! bash "$BIN_DIR/packages.sh" sync-all; then
    echo -e "${C_RED}[!] PACKAGE SYNC FAILED.${NC}"

    rm -rf "$PREFIX/glibc"

    if [ -d "$PREFIX/glibc.backup" ]; then
        mv "$PREFIX/glibc.backup" "$PREFIX/glibc"
    fi

    exit 1
fi

rm -rf "$PREFIX/glibc.backup"

echo -e "\n${C_NEON}${C_BOLD}>>> DEPLOYMENT SUCCESSFUL. <<<${NC}\n"
