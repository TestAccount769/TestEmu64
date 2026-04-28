#!/bin/bash

C_CYAN='\033[0;36m'; C_NEON='\033[1;32m'; C_PURP='\033[0;35m'
C_GOLD='\033[1;33m'; C_RED='\033[0;31m'; C_BOLD='\033[1m'; NC='\033[0m'

print_slow() {
    local text="$1"
    for (( i=0; i<${#text}; i++ )); do echo -ne "${text:$i:1}"; sleep 0.005; done
    echo ""
}

clear
echo -e "${C_PURP}┌────────────────────────────────────────────────────────┐${NC}"
echo -e "${C_CYAN}${C_BOLD}          TESTEMU64 // SYSTEM DEPLOYMENT PROTOCOL        ${NC}"
echo -e "${C_PURP}└────────────────────────────────────────────────────────┘${NC}"

termux-setup-storage >/dev/null 2>&1
while [ ! -d "$HOME/storage/shared" ]; do
    echo -ne "${C_RED}\r[!] WAITING FOR STORAGE PERMISSION...${NC}"
    sleep 2
done
echo -e "\n${C_NEON}[+] ACCESS GRANTED.${NC}"

install_group() {
    local group_name="$1"
    shift
    echo -e "\n${C_PURP}>> INITIALIZING: $group_name${NC}"
    for pkg in "$@"; do
        echo -ne "${C_CYAN}Installing ${C_BOLD}$pkg${NC}... "
        pkg install -y "$pkg" >/dev/null 2>&1 && echo -e "${C_NEON}DONE${NC}" || echo -e "${C_RED}FAILED${NC}"
    done
}

echo -e "${C_CYAN}[*] SYNCHRONIZING SYSTEM SOURCES...${NC}"
apt-get update -y >/dev/null 2>&1

install_group "Repositories" x11-repo root-repo glibc-repo

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
xorg-xrandr libx11 libxext libxrender termux-x11-nightly

install_group "Extra Utilities" \
hashdeep tsu dos2unix inetutils net-tools dialog termux-am

[ -d "$PREFIX/glibc" ] && rm -rf "$PREFIX/glibc"

PM_DIR="$PREFIX/glibc/opt/package-manager"
mkdir -p "$PM_DIR/installed"

PROJECT_ID="76144938"
TOKEN="glpat-nybXy782yrn2GFJQrwU8iW86MQp1Oml2NnI3Cw.01.1216l75cr"

echo -e "\n${C_CYAN}[SYSTEM] CONNECTING TO GITLAB INFRASTRUCTURE...${NC}"

wget_gitlab() {
    local path="$1"
    local out="$2"
    wget -q --header="PRIVATE-TOKEN: $TOKEN" \
    "https://gitlab.com/api/v4/projects/${PROJECT_ID}/repository/files/${path}/raw?ref=main" \
    -O "$out"
}

if [ -n "$PROJECT_ID" ] && [ -n "$TOKEN" ] && wget_gitlab "package-manager" "$PM_DIR/package-manager"; then
    if [ -s "$PM_DIR/package-manager" ]; then
        chmod +x "$PM_DIR/package-manager"
        . "$PM_DIR/package-manager"
        sync-all >/dev/null 2>&1
        sync-package wine-ge-custom-8-25 >/dev/null 2>&1
    else
        echo -e "${C_RED}[!] EMPTY PACKAGE MANAGER.${NC}"
        exit 1
    fi
else
    echo -e "${C_RED}[!] GITLAB CONNECTION FAILED.${NC}"
    exit 1
fi

echo -e "\n${C_GOLD}========================================================${NC}"
print_slow "${C_BOLD}${C_PURP}BASE READY. APPLYING OVERRIDE...${NC}"
echo -e "${C_GOLD}========================================================${NC}"

if [ -n "$GITHUB_TOKEN" ]; then
    OVERRIDE_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/main/testemu-override.sh"
    curl -H "Authorization: token $GITHUB_TOKEN" -L "$OVERRIDE_URL" -o "$HOME/testemu-override.sh"

    if [ -s "$HOME/testemu-override.sh" ]; then
        chmod +x "$HOME/testemu-override.sh"
        bash "$HOME/testemu-override.sh"
    else
        echo -e "${C_RED}[!] OVERRIDE SCRIPT NOT FOUND.${NC}"
    fi
else
    echo -e "${C_RED}[!] WARNING: GITHUB_TOKEN NOT SET.${NC}"
fi

echo -e "\n${C_NEON}${C_BOLD}>>> DEPLOYMENT SUCCESSFUL. <<<${NC}\n"
