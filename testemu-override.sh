
#!/bin/bash

C_CYAN='\033[0;36m'; C_NEON='\033[1;32m'; C_PURP='\033[0;35m'
C_GOLD='\033[1;33m'; C_RED='\033[0;31m'; C_BOLD='\033[1m'; NC='\033[0m'

export GITHUB_TOKEN="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"
ASSETS_URL="[https://github.com/TestAccount769/TestEmu64/releases/download/assets](https://github.com/TestAccount769/TestEmu64/releases/download/assets)"

clear
echo -e "${C_PURP}┌────────────────────────────────────────────────────────┐${NC}"
echo -e "${C_CYAN}${C_BOLD}     UPDATING D3D // TESTEMU64 ULTIMATE STACK      ${NC}"
echo -e "${C_PURP}└────────────────────────────────────────────────────────┘${NC}"

if [ -f "$PREFIX/glibc/bin/packages.sh" ]; then
    bash "$PREFIX/glibc/bin/packages.sh" engine >/dev/null 2>&1
fi

WINE_CHOICE=$(dialog --clear \
--title "WINE SELECTOR" \
--menu "Choose Wine runtime:" 15 60 4 \
1 "WoW64 Wine (Proton-style modern)" \
2 "GE-Proton Wine (recommended gaming)" \
3 "Vanilla Wine (stable base)" \
4 "Box86 + Box64 runtime (fallback)" \
3>&1 1>&2 2>&3)

case $WINE_CHOICE in
    1) W_URL="[https://github.com](https://github.com)" ;;
    2) W_URL="[https://github.com](https://github.com)" ;;
    3) W_URL="[https://winehq.org](https://winehq.org)" ;;
    4) W_URL="" ;;
esac

if [ -n "$W_URL" ]; then
    wget -q "$W_URL" -O w.tar.xz
    rm -rf "$PREFIX/glibc/wine-selected"
    mkdir -p "$PREFIX/glibc/wine-selected"
    tar -xf w.tar.xz -C "$PREFIX/glibc/wine-selected" --strip-components=1
    rm w.tar.xz
else
    echo -e "${C_NEON}[INFO] Box86/Box64 runtime selected${NC}"
fi

M_DIR="$PREFIX/glibc/opt/libs/mesa"
mkdir -p "$M_DIR"

deploy_turnip() {
    local url=$1; local name=$2
    wget -q "$url" -O t.zip && unzip -q t.zip -d t_tmp
    cd t_tmp && 7z a -t7z -mx=9 "${name}.7z" * > /dev/null
    cp "${name}.7z" "$M_DIR/" && cd .. && rm -rf t_tmp t.zip
}

deploy_turnip "[https://github.com](https://github.com)" "turnip-steven-ci"
deploy_turnip "[https://github.com](https://github.com)" "turnip-v26.2.0-r2"
deploy_turnip "[https://github.com](https://github.com)" "turnip-kimchi-r7"
deploy_turnip "[https://github.com](https://github.com)" "turnip-weab-chan"
deploy_turnip "[https://github.com](https://github.com)" "turnip-hooke-speed"

D_DIR="$PREFIX/glibc/opt/libs/d3d"
mkdir -p "$D_DIR"

deploy_dxvk() {
    local url=$1; local name=$2; local folder=$3
    wget -q "$url" -O d.tar.gz && tar -xf d.tar.gz
    mkdir -p d_tmp/system32 d_tmp/syswow64
    cp ${folder}/x64/*.dll d_tmp/system32/
    cp ${folder}/x86/*.dll d_tmp/syswow64/
    cd d_tmp && 7z a -t7z -mx=9 "${name}.7z" sys* > /dev/null
    cp "${name}.7z" "$D_DIR/" && cd .. && rm -rf d_tmp d.tar.gz "$folder"
}

<EOF | sed 's/$/\r/'> "$D3D_PATH/${name}.bat"
@echo off
set installname=%deploy_dxvk "[https://github.com](https://github.com)" "dxvk-gplall" "dxvk-2.7.1"
deploy_dxvk "https~n0
set startname="d3d is not installed"
call d3d.bat
set installname=d8vk
call d3d.://github.com" "dxvk-gproton" "dxvk-2.7"
deploy_dxvk "[https://github.com](https://github.com)" "dxvk-native" "dxvk-2.7.1"
deploy_dxvk "[https://github.com](https://github.com)" "dxvk-async" "dxvk-async-bat
set installname=vkd3d
set startname=%~n0
call d3d.bat
EOF
done

MESA_PATH="$PREFIX/glibc/opt/prefix/mesa"
mkdir -p "$MESA_PATH"

tr_vers=("turnip-steven-ci" "turnip2.0"
deploy_dxvk "[https://github.com](https://github.com)" "d8vk" "d8vk-v1.0"

D3D_-v26.2.0-r2" "turnip-kimchi-r7" "turnip-weab-chan" "turnip-hookPATH="$PREFIX/glibc/opt/prefix/d3d"
mkdir -p "$D3D_PATH"
dx_vers=("dxvk-gple-speed")
for tname in "${tr_vers[@]}"; do
cat <<EOF | sed 's/$/\r/'> "$MESA_PATH/${tname}.bat"
@echo off
set installname=%~n0
set startname=%~n0
echo Installing %installname%...
titleall" "dxvk-gproton" "dxvk-native" "dxvk-async" "d8vk")
for name in "${dx_vers[@]}"; do
cat <<EOF | sed 's/$/\r/'> "$D3D_PATH/${name}.bat"
@echo off
set installname=% Installing %installname%...
Z:\\usr\\glibc\\opt\\apps\\7z.exe x Z:\\usr\\glibc\\opt\\libs\\mesa\\~n0
set startname="d3d is not installed"
call d3d.bat
set installname=d8vk
call d3d.%installname%.7z -oZ:\\usr\\glibc -y >NUL 2>&1
cd /d "C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Install" >NUL 2>&1
for /d %%a in (2.*) do (
    ren "C:\\ProgramData\\Microsoftbat
set installname=vkd3d
set startname=%~n0
call d3d.bat
EOF
done

MESA_PATH="$PREFIX/glibc/opt/prefix/mesa"
mkdir -p "$MESA_PATH"
tr_vers=("turnip-steven-ci" "turnip\\Windows\\Start Menu\\Install\\%%a" "2.%startname%" >NUL 2>&1
)
cd /d Z:\\usr\\glibc-v26.2.0-r2" "turnip-kimchi-r7" "turnip-weab-chan" "turnip-hooke-speed")
for tname in "${tr_vers[@]}"; do
cat <<EOF | sed 's/$/\r/'> "$MESA_PATH/${tname}.bat"
@echo off
set installname=%~n0
set startname=%~n0
echo Installing %installname%...
Z\\opt\\prefix\\mesa
EOF
done

DXVK_LNK_DIR="$PREFIX/glibc/opt/prefix/start/Install/d3d is not installed"
TURNIP_LNK_DIR="$PREFIX/glibc/opt/prefix/start/Install/mesa is not installed"
mkdir -p "$DXVK_LNK_DIR" "$TURNIP_LNK_DIR"

GITHUB_RAW="[https://raw.githubusercontent.com/TestAccount769/](https://raw.githubusercontent.com/TestAccount769/):\\usr\\glibc\\opt\\apps\\7z.exe x Z:\\usr\\glibc\\opt\\libs\\mesa\\%installname%.7z -oTestEmu64/main"
ASSETS_URL="[https://github.com/TestAccount769/TestEmu64/releases/download/Z](https://github.com/TestAccount769/TestEmu64/releases/download/Z):\\usr\\glibc -y >NUL 2>&1
cd /d "C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Install" >Nassets"

curl -L "$ASSETS_URL/dxvk.tar" -o /tmp/dxvk.tar
curl -L "$ASSETS_URL/UL 2>&1
for /d %%a in (2.*) do (
    ren "C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Install\\%%a" "2.%startname%" >NUL 2>&1
)
cd /d Z:\\usr\\glibc\\opt\\prefix\\mesa
EOF
done

DXVK_LNK_DIR="$PREFIX/glibc/opt/prefix/start/Install/d3d is not installed"
TURNIP_LNK_DIR="$PREFIX/glibc/opt/prefix/start/Install/mesa is not installed"
mkdir -p "$DXVK_LNK_DIR" "$turnip.tar" -o /tmp/turnip.tar
tar -xf /tmp/dxvk.tar -C "$DXVK_LNK_DIR"
tar -xf /tmp/turnip.tar -C "$TURNIP_LNK_DIR"

curl -L "$ASSETS_URL/core.tar" -o /tmp/core.tar
curl -L "$ASSETS_URL/conf.tar" -o /tmp/conf.tar
curl -L "$ASSETS_URL/drivers.tar" -o /tmp/drivers.tar
curl -L "$ASSETS_URL/booster.7z" -o /tmpTURNIP_LNK_DIR"

curl -L -H "Authorization: token $GITHUB_TOKEN" -o /tmp/dxvk.tar "$/booster.7z
curl -L "[https://github.com/TestAccount769/wine-flow/releases/download/drova-filesASSETS_URL/dxvk.tar](https://github.com/TestAccount769/wine-flow/releases/download/drova-filesASSETS_URL/dxvk.tar)"
curl -L -H "Authorization: token $GITHUB_TOKEN" -o /tmp/turnip.tar "$/optimization-script.zip" -o /tmp/optimization-script.zip

mkdir -p $PREFIX/glibc/opt/core $PREFIX/glibc/opt/conf $PREFIX/glibc/opt/drivers $PREFIX/glibc/opt/bat-files $PREFIX/glibc/opt/scripts

tar -xf /tmp/core.tar -C $PREFIX/glibc/opt/core
tar -xf /tmp/conf.tar -C $PREFIX/glibc/opt/conf
tar -xf /tmp/drivers.tar -C $PREFIX/glibc/opt/drivers
7z x /tmp/booster.7z -ASSETS_URL/turnip.tar"
tar -xf /tmp/dxvk.tar -C "$DXVK_LNK_DIR"
tar -xf /tmp/turnip.tar -C "$TURNIP_LNK_DIR"

curl -L -H "Authorization: token $GITHUB_TOKEN" -o /tmp/core.tar "$ASSETS_URL/core.tar"
curl -L -H "Authorization: token $GITHUB_TOKEN" -o /tmp/conf.tar "$ASSETS_URL/conf.tar"
curl -L -H "Authorization: token $GITHUB_TOKEN" -o /tmp/drivers.tar "$o$PREFIX/glibc/opt/bat-files -y > /dev/null
unzip -q /tmp/optimization-script.zip -d $PREFIXASSETS_URL/drivers.tar"
curl -L -H "Authorization: token $GITHUB_TOKEN" -o /tmp/booster.7z "$AS/glibc/opt/scripts

rm -f /tmp/dxvk.tar /tmp/turnip.tar /tmp/core.tar /tmp/conf.SETS_URL/booster.7z"
curl -L -H "Authorization: token $GITHUB_TOKEN" -o /tmp/optimization-script.zip "$AStar /tmp/drivers.tar /tmp/booster.7z /tmp/optimization-script.zip

chmod +x "$PREFIX/glibc/opt/scripts/testemu64"
chmod +x "$PREFIX/glibc/opt/scripts/testemu-optimizer.sh"
ln -sf $PREFIX/glibc/opt/scripts/testemu64 $PREFIX/bin/testemu64

echo -e "\n${C_NEON}${C_BOLD}>>> To start type - testemu64. <<<${NC}\n"
```SETS_URL/optimization-script.zip"

mkdir -p $PREFIX/glibc/opt/core $PREFIX/glibc/opt/conf $PREFIX/glibc/opt/drivers $PREFIX/glibc/opt/bat-files $PREFIX/glibc/opt/scripts

tar -xf /tmp/core.tar -C $PREFIX/glibc/opt/core
tar -xf /tmp/conf.tar -C $PREFIX/glibc/opt/conf
tar -xf /tmp/drivers.tar -C $PREFIX/glibc/opt/drivers
7z x /tmp/booster.7z -o$PREFIX/glibc/opt/bat-files -y > /dev/null
unzip -q /tmp/optimization-script.zip -d $PREFIX/glibc/opt/scripts

rm -f /tmp/dxvk.tar /tmp/turnip.tar /tmp/core.tar /tmp/conf.tar /tmp/drivers.tar /tmp/booster.7z /tmp/optimization-script.zip

chmod +x "$PREFIX/glibc/opt/scripts/testemu64"
chmod +x "$PREFIX/glibc/opt/scripts/testemu-optimizer.sh"
ln -sf $PREFIX/glibc/opt/scripts/testemu64 $PREFIX/bin/testemu64

echo -e "\n${C_NEON}${C_BOLD}>>> To start type - testemu64. <<<${NC}\n"
```</EOF></EOF></EOF></EOF>

```
