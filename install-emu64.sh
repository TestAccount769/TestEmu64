```bash
#!/bin/bash

```bash
#!/bin/bash

C_CYAN='\033[0;36m'; C_NEON='\033[1;32m'; C_PURP='\033[0;35m'
C_GOLD='\033[1;33m'; C_RED='\033[0;31m'; C_BOLD='\033[1m'; NC='\033[0m'

print_slow() {
    local text="$1"
    for (( i=0; i<${#text}; i++ )); do echo -ne "${text:$i:1}"; sleep 0.005; done
    echo ""
}

IS_TERMUX=0
if [ -d "/data/data/com.termux/files/usr" ]; then
    IS_TERMUX=1
    PREFIX="/data/data/com.termux/files/usr"
else
    PREFIX="$HOME/testemu64"
fi

clear
echo -e "${C_PURP}┌────────────────────────────────────────────────────────┐${NC}"
echo -e "${C_CYAN}${C_BOLD}          TESTEMU64 // SYSTEM DEPLOYMENT PROTOCOL        ${NC}"
echo -e "${C_PURP}└────────────────────────────────────────────────────────┘${NC}"

if [ "$IS_TERMUX" -eq 1 ]; then
    termux-setup-storage >/dev/null 2>&1
    while [ ! -d "$HOME/storage/shared" ]; do
        echo -ne "${C_RED}\r[!] WAITING FOR STORAGE PERMISSION...${NC}"
        sleep 2
    done
    echo -e "\n${C_NEON}[+] ACCESS GRANTED.${NC}"
else
    echo -e "${C_NEON}[+] PC MODE DETECTED - SKIPPING STORAGE PERMISSION${NC}"
fi

PKG="pkg"
[ "$IS_TERMUX" -ne 1 ] && PKG="apt"

install_group() {
    local group_name="$1"
    shift
    echo -e "\n${C_PURP}>> INITIALIZING: $group_name${NC}"
    for pkg in "$@"; do
        echo -ne "${C_CYAN}Installing ${C_BOLD}$pkg${NC}... "
        $PKG install -y "$pkg" >/dev/null 2>&1 && echo -e "${C_NEON}DONE${NC}" || echo -e "${C_RED}FAILED${NC}"
    done
}

echo -e "${C_CYAN}[*] SYNCHRONIZING SYSTEM SOURCES...${NC}"
$PKG update -y >/dev/null 2>&1

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
PM_DIR="$PREFIX/glibc/opt/testemu"
BIN_DIR="$PREFIX/glibc/bin"
mkdir -p "$PM_DIR/installed" "$PM_DIR/temp" "$BIN_DIR"

echo -e "\n${C_CYAN}[SYSTEM] DEPLOYING INDEPENDENT PACKAGE MANAGER...${NC}"

PM_URL="[https://raw.githubusercontent.com/TestAccount769/TestEmu64/main/packages.sh](https://raw.githubusercontent.com/TestAccount769/TestEmu64/main/packages.sh)"

if curl -L "$PM_URL" -o "$BIN_DIR/packages.sh"; then
    chmod +x "$BIN_DIR/packages.sh"
    echo -e "${C_NEON}[+] PACKAGE MANAGER DEPLOYED.${NC}"
    echo -e "${C_CYAN}[SYSTEM] FETCHING CORE ASSETS (PATCH 1.0)...${NC}"
    bash "$BIN_DIR/packages.sh" sync-all
else
    echo -e "${C_RED}[!] FAILED TO DOWNLOAD PACKAGE MANAGER.${NC}"
    exit 1
fi

echo -e "\n${C_GOLD}========================================================${NC}"
print_slow "${C_BOLD}${C_PURP}SYSTEM READY. EXECUTING FINAL OVERRIDE...${NC}"
echo -e "${C_GOLD}========================================================${NC}"

OVERRIDE_URL="https://raw```.githubusercontent.com/TestAccount769/TestEmu64/main/testemu-override.sh"
curl -L "$OVERRIDE_URL" -o "$HOME/testemu-override.sh"

if [ -s "$HOME/testemu-override.sh" ]; then
    chmod +x "$HOME/testemu-override.sh"
    bash "$HOME/testemu-override.sh"
else
    echo -e "${C_RED}[!] OVERRIDE SCRIPT NOT FOUND.${NC}"
fi

echo -e "\n${C_NEON}${C_BOLD}>>> DEPLOYMENT SUCCESSFUL. <<<${NC}\n"

```
