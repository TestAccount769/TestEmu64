#!/bin/bash

C_CYAN='\033[0;36m'; C_NEON='\033[1;32m'; C_PURP='\033[0;35m'
C_GOLD='\033[1;33m'; C_RED='\033[0;31m'; C_BOLD='\033[1m'; NC='\033[0m'

export GITHUB_TOKEN="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"

clear
echo -e "${C_PURP}┌────────────────────────────────────────────────────────┐${NC}"
echo -e "${C_CYAN}${C_BOLD}     UPDATING D3D // TESTEMU64 ULTIMATE STACK      ${NC}"
echo -e "${C_PURP}└────────────────────────────────────────────────────────┘${NC}"

if [ -f "$PREFIX/glibc/bin/packages.sh" ]; then
    . "$PREFIX/glibc/bin/packages.sh"
    sync_package engine >/dev/null 2>&1
fi

GLIBC_LIB="$PREFIX/glibc/lib"
DXVK_DIR="$PREFIX/glibc/dxvk"

mkdir -p "$GLIBC_LIB/turnip_steven_ci"
mkdir -p "$GLIBC_LIB/turnip_v26_2_0_r2"
mkdir -p "$GLIBC_LIB/turnip_kimchi_r7"
mkdir -p "$GLIBC_LIB/turnip_weab_chan"
mkdir -p "$GLIBC_LIB/turnip_hooke-speed"
mkdir -p "$GLIBC_LIB/turnip_stock"

mkdir -p "$DXVK_DIR/gplasync_2.7.1/x64" "$DXVK_DIR/gplasync_2.7.1/x32"
mkdir -p "$DXVK_DIR/gproton_2.7/x64" "$DXVK_DIR/gproton_2.7/x32"
mkdir -p "$DXVK_DIR/native_2.7.1/x64" "$DXVK_DIR/native_2.7.1/x32"
mkdir -p "$DXVK_DIR/async_2.0/x64" "$DXVK_DIR/async_2.0/x32"
mkdir -p "$DXVK_DIR/d8vk_1.0/x64" "$DXVK_DIR/d8vk_1.0/x32"

TMP_DIR="/tmp/emu_deploy"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

deploy_turnip() {
    local url=$1; local folder=$2; local internal_so=$3
    if [[ "$url" == *.zip ]]; then
        wget -q "$url" -O t.zip && unzip -q t.zip
    else
        wget -q "$url" -O t.tar.xz && tar -xf t.tar.xz
    fi
    if [ -f "$internal_so" ]; then
        cp -f "$internal_so" "$GLIBC_LIB/${folder}/libvulkan_freedreno.so"
    elif [ -f "libvulkan_freedreno.so" ]; then
        cp -f libvulkan_freedreno.so "$GLIBC_LIB/${folder}/libvulkan_freedreno.so"
    fi
    rm -rf *
}

deploy_turnip "https://github.com" "turnip_steven_ci" "libvulkan_freedreno.so"
deploy_turnip "https://github.com" "turnip_v26_2_0_r2" "libvulkan_freedreno.so"
deploy_turnip "https://github.com" "turnip_kimchi_r7" "vulkan.ad07xx.so"
deploy_turnip "https://github.com" "turnip_weab_chan" "libvulkan_freedreno.so"
deploy_turnip "https://github.com" "turnip_hooke-speed" "vulkan.ad07xx.so"
deploy_turnip "https://github.com" "turnip_stock" "libvulkan_freedreno.so"

deploy_dxvk() {
    local url=$1; local out_folder=$2; local arch_folder=$3
    wget -q "$url" -O d.tar.gz && tar -xf d.tar.gz
    cp -f ${arch_folder}/x64/*.dll "$DXVK_DIR/${out_folder}/x64/"
    cp -f ${arch_folder}/x86/*.dll "$DXVK_DIR/${out_folder}/x32/"
    rm -rf *
}

deploy_dxvk "https://github.com" "gplasync_2.7.1" "dxvk-2.7.1"
deploy_dxvk "https://github.com" "gproton_2.7" "dxvk-2.7"
deploy_dxvk "https://github.com" "native_2.7.1" "dxvk-2.6"
deploy_dxvk "https://github.com" "async_2.0" "dxvk-2.3"
deploy_dxvk "https://github.com" "d8vk_1.0" "d8vk"

BASE_URL="https://githubusercontent.com"

curl -L -H "Authorization: token $GITHUB_TOKEN" -o /tmp/core.tar "$BASE_URL/core.tar"
curl -L -H "Authorization: token $GITHUB_TOKEN" -o /tmp/conf.tar "$BASE_URL/conf.tar"
curl -L -H "Authorization: token $GITHUB_TOKEN" -o /tmp/drivers.tar "$BASE_URL/drivers.tar"
curl -L -H "Authorization: token $GITHUB_TOKEN" -o /tmp/booster.7z "$BASE_URL/booster.7z"
curl -L -H "Authorization: token $GITHUB_TOKEN" -o /tmp/optimization-script.zip "https://github.com"

mkdir -p $PREFIX/glibc/opt/core $PREFIX/glibc/opt/conf $PREFIX/glibc/opt/drivers $PREFIX/glibc/opt/bat-files $PREFIX/glibc/opt/scripts

tar -xf /tmp/core.tar -C $PREFIX/glibc/opt/core
tar -xf /tmp/conf.tar -C $PREFIX/glibc/opt/conf
tar -xf /tmp/drivers.tar -C $PREFIX/glibc/opt/drivers
7z x /tmp/booster.7z -o$PREFIX/glibc/opt/bat-files -y > /dev/null
unzip -q /tmp/optimization-script.zip -d $PREFIX/glibc/opt/scripts

rm -rf /tmp/core.tar /tmp/conf.tar /tmp/drivers.tar /tmp/booster.7z /tmp/optimization-script.zip "$TMP_DIR"

chmod +x "$PREFIX/glibc/opt/scripts/testemu64"
chmod +x "$PREFIX/glibc/opt/scripts/testemu-optimizer.sh"
ln -sf $PREFIX/glibc/opt/scripts/testemu64 $PREFIX/bin/testemu64

echo -e "\n${C_NEON}${C_BOLD}>>> To start type - testemu64. <<<${NC}\n"
