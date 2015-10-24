#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="retropiemenu"
rp_module_desc="RetroPie configuration menu for EmulationStation"
rp_module_menus="3+"
rp_module_flags="nobin"

function depends_retropiemenu() {
    getDepends mc
}

function configure_retropiemenu()
{
    local rpdir="$home/RetroPie/retropiemenu"
    mkdir -p "$rpdir"

    files=(
        'rpsetup.rp'
        'configedit.rp'
        'retroarch.rp'
        'audiosettings.rp'
        'retronetplay.rp'
        'splashscreen.rp'
        'filemanager.rp'
        'showip.rp'
        'wifi.rp'
    )

    for file in "${files[@]}"; do
        touch "$rpdir/$file"
    done

    chown -R $user:$user "$rpdir"

    # add some information
    mkdir -p "$home/.emulationstation/gamelists/retropie/"
    cat > "$home/.emulationstation/gamelists/retropie/gamelist.xml" <<_EOF_
<?xml version="1.0"?>
<gameList>
    <game>
        <path>$rpdir/rpsetup.rp</path>
        <name>RetroPie-Setup</name>
    </game>
    <game>
        <path>$rpdir/configedit.rp</path>
        <name>Edit RetroPie/RetroArch configurations</name>
    </game>
    <game>
        <path>$rpdir/filemanager.rp</path>
        <name>File Manager</name>
    </game>
    <game>
        <path>$rpdir/retroarch.rp</path>
        <name>Configure RetroArch / Launch RetroArch RGUI</name>
    </game>
    <game>
        <path>$rpdir/audiosettings.rp</path>
        <name>Configure audio settings</name>
    </game>
    <game>
        <path>$rpdir/retronetplay.rp</path>
        <name>Configure RetroArch netplay</name>
    </game>
    <game>
        <path>$rpdir/splashscreen.rp</path>
        <name>Configure Splashscreen</name>
    </game>
    <game>
        <path>$rpdir/showip.rp</path>
        <name>Show IP address</name>
    </game>
    <game>
        <path>$rpdir/wifi.rp</path>
        <name>Configure Wifi</name>
    </game>
</gameList>
_EOF_
    chown -R $user:$user "$home/.emulationstation"
    setESSystem "RetroPie" "retropie" "~/RetroPie/retropiemenu" ".rp .sh" "sudo $scriptdir/retropie_packages.sh retropiemenu launch %ROM% </dev/tty >/dev/tty" "" "retropie"
}

function launch_retropiemenu() {
    clear
    local command="$1"
    local basename="${command##*/}"
    case $basename in
        retroarch.rp)
            cp "$configdir/all/retroarch.cfg" "$configdir/all/retroarch.cfg.bak"
            chown $user:$user "$configdir/all/retroarch.cfg.bak"
            su $user -c "\"$emudir/retroarch/bin/retroarch\" --menu --config \"$configdir/all/retroarch.cfg\""
            ;;
        rpsetup.rp)
            "$scriptdir/retropie_setup.sh"
            ;;
        raspiconfig.rp)
            raspi-config
            ;;
        filemanager.rp)
            mc
            ;;
        showip.rp)
            ip addr show
            sleep 5
            ;;
        *.rp)
            local no_ext=${basename%.rp}
            rp_callModule $no_ext
            ;;
        *.sh)
            cd "$home/RetroPie/retropiemenu"
            bash "$command"
            ;;
    esac
    clear
}
