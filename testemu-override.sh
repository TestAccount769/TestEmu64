#!/bin/bash

C_CYAN='\033[0;36m'
C_NEON='\033[1;32m'
C_PURP='\033[0;35m'
C_GOLD='\033[1;33m'
C_RED='\033[0;31m'
C_BOLD='\033[1m'
NC='\033[0m'

GLIBC_LIB="$PREFIX/glibc/lib"
DXVK_DIR="$PREFIX/glibc/dxvk"
TMP_DIR="/tmp/emu_deploy"
RELEASE_URL="https://github.com/TestAccount769/TestEmu64/releases/download/drova-files"

mkdir -p "$TMP_DIR"
mkdir -p "$GLIBC_LIB"/turnip_{steven_ci,v26_2_0_r2,kimchi_r7,weab_chan,hooke-speed,stock}
mkdir -p "$DXVK_DIR"/{gplasync_2.7.1,gproton_2.7,native_2.7.1,async_2.0,d8vk_1.0}/{x64,x32}
mkdir -p "$PREFIX/glibc/opt"/{core,conf,drivers,bat-files,scripts}

deploy_turnip() {
    local url="$1"
    local folder="$2"
    local internal_so="$3"
    rm -rf "$TMP_DIR"/*
    
    echo -e "${C_CYAN}Downloading Turnip: $folder...${NC}"
    if ! wget -q "$url" -O "$TMP_DIR/pkg"; then
        echo -e "${C_RED}Error downloading driver: $folder${NC}"
        return 1
    fi

    if file "$TMP_DIR/pkg" | grep -qi "zip"; then
        unzip -q "$TMP_DIR/pkg" -d "$TMP_DIR"
    else
        tar -xf "$TMP_DIR/pkg" -C "$TMP_DIR"
    fi
    
    if [ -f "$TMP_DIR/$internal_so" ]; then
        cp -f "$TMP_DIR/$internal_so" "$GLIBC_LIB/$folder/libvulkan_freedreno.so"
    elif [ -f "$TMP_DIR/libvulkan_freedreno.so" ]; then
        cp -f "$TMP_DIR/libvulkan_freedreno.so" "$GLIBC_LIB/$folder/libvulkan_freedreno.so"
    fi
}

deploy_dxvk() {
    local url="$1"
    local out_folder="$2"
    local arch_folder="$3"
    rm -rf "$TMP_DIR"/*
    
    echo -e "${C_CYAN}Downloading DXVK: $out_folder...${NC}"
    if ! wget -q "$url" -O "$TMP_DIR/dxvk.tar"; then
        echo -e "${C_RED}Error downloading DXVK: $out_folder${NC}"
        return 1
    fi

    tar -xf "$TMP_DIR/dxvk.tar" -C "$TMP_DIR"
    cp -rf "$TMP_DIR/$arch_folder"/x64/*.dll "$DXVK_DIR/$out_folder/x64/" 2>/dev/null
    cp -rf "$TMP_DIR/$arch_folder"/x32/*.dll "$DXVK_DIR/$out_folder/x32/" 2>/dev/null
    cp -rf "$TMP_DIR/$arch_folder"/x86/*.dll "$DXVK_DIR/$out_folder/x32/" 2>/dev/null
}

deploy_turnip "$RELEASE_URL/turnip1.tar" "turnip_steven_ci" "libvulkan_freedreno.so"
deploy_turnip "$RELEASE_URL/turnip2.tar" "turnip_v26_2_0_r2" "libvulkan_freedreno.so"
deploy_turnip "$RELEASE_URL/turnip3.tar" "turnip_kimchi_r7" "vulkan.ad07xx.so"
deploy_turnip "$RELEASE_URL/turnip4.tar" "turnip_weab_chan" "libvulkan_freedreno.so"
deploy_turnip "$RELEASE_URL/turnip5.tar" "turnip_hooke-speed" "vulkan.ad07xx.so"
deploy_turnip "$RELEASE_URL/turnip6.tar" "turnip_stock" "libvulkan_freedreno.so"

deploy_dxvk "$RELEASE_URL/dxvk1.tar" "gplasync_2.7.1" "dxvk-2.7.1"
deploy_dxvk "$RELEASE_URL/dxvk2.tar" "gproton_2.7" "dxvk-2.7"
deploy_dxvk "$RELEASE_URL/dxvk3.tar" "native_2.7.1" "dxvk-2.6"
deploy_dxvk "$RELEASE_URL/dxvk4.tar" "async_2.0" "dxvk-2.3"
deploy_dxvk "$RELEASE_URL/dxvk5.tar" "d8vk_1.0" "d8vk"

echo -e "${C_PURP}Downloading main emulator components...${NC}"

wget -q --show-progress "$RELEASE_URL/core.tar" -O /tmp/core.tar || exit 1
wget -q --show-progress "$RELEASE_URL/conf.tar" -O /tmp/conf.tar || exit 1
wget -q --show-progress "$RELEASE_URL/drivers.tar" -O /tmp/drivers.tar || exit 1
wget -q --show-progress "$RELEASE_URL/booster.7z" -O /tmp/booster.7z || exit 1
wget -q --show-progress "$RELEASE_URL/optimization-script.zip" -O /tmp/optimization-script.zip || exit 1

echo -e "${C_GOLD}Extracting and optimizing components...${NC}"
tar -xf /tmp/core.tar -C "$PREFIX/glibc/opt/core" 2>/dev/null
tar -xf /tmp/conf.tar -C "$PREFIX/glibc/opt/conf" 2>/dev/null
tar -xf /tmp/drivers.tar -C "$PREFIX/glibc/opt/drivers" 2>/dev/null
7z x /tmp/booster.7z -o"$PREFIX/glibc/opt/bat-files" -y >/dev/null 2>&1
unzip -q /tmp/optimization-script.zip -d "$PREFIX/glibc/opt/scripts"

rm -rf /tmp/core.tar /tmp/conf.tar /tmp/drivers.tar /tmp/booster.7z /tmp/optimization-script.zip "$TMP_DIR"

chmod +x "$PREFIX/glibc/opt/scripts/testemu64" "$PREFIX/glibc/opt/scripts/testemu-optimizer.sh" 2>/dev/null
ln -sf "$PREFIX/glibc/opt/scripts/testemu64" "$PREFIX/bin/testemu64"

echo -e "${C_NEON}\n>>> Deployment completed successfully! To start type: testemu64 <<<\n${NC}"
