#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#====================================================
#	系统需求:Centos 7+/Debian 9+/Ubuntu 18.04+
#	作者:	Alloy
#	详细: CSGO Linux一键安装脚本
#	版本: 2.0.0
#====================================================

#fonts color
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
Skyblue="\033[36m"
SkyblueBG="\033[46;37m"
Font="\033[0m"

OK="${Green}[OK]${Font}"
Error="${Red}[错误]${Font}"
Loading="${Skyblue}[Loading]${Font}"

shell_version=2.0.0

autoexec_cfg="/root/csgo/csgo/cfg/autoexec.cfg"
startcsgo_sh="/root/startcsgo.sh"

THREAD=$(grep 'processor' /proc/cpuinfo | sort -u | wc -l)

source '/etc/os-release'

#从VERSION中提取发行版系统的英文名称
VERSION=$(echo "${VERSION}" | awk -F "[()]" '{print $2}')

check_system(){
    if [[ "${NAME}" == "CentOS Linux" && ${VERSION_ID} -le 8 && ${VERSION_ID} -ge 7 ]]; then
        echo -e "${OK} ${GreenBG} 当前系统为 Centos ${VERSION_ID} ${VERSION} ${Font}"
		is_root
		centos_csgo
    elif [[ "${NAME}" == "CentOS Linux" && ${VERSION_ID} -ge 8 ]]; then
        echo -e "${OK} ${GreenBG} 当前系统为 Centos ${VERSION_ID} ${VERSION} ${Font}"
		is_root
		centos8_csgo
    elif [[ "${NAME}" == "CentOS Stream" && ${VERSION_ID} -ge 7 ]]; then
        echo -e "${OK} ${GreenBG} 当前系统为 Centos Stream ${VERSION_ID} ${VERSION} ${Font}"
		is_root
		centos_csgo
    elif [[ "${ID}" == "debian" && ${VERSION_ID} -ge 8 ]]; then
        echo -e "${OK} ${GreenBG} 当前系统为 Debian ${VERSION_ID} ${VERSION} ${Font}"
		is_root
        apt update
		install_ubuntu/debian
    elif [[ "${ID}" == "ubuntu" && $(echo "${VERSION_ID}" | cut -d '.' -f1) -ge 16 ]]; then
        echo -e "${OK} ${GreenBG} 当前系统为 Ubuntu ${VERSION_ID} ${UBUNTU_CODENAME} ${Font}"
		is_root
        rm /var/lib/dpkg/lock
        dpkg --configure -a
        rm /var/lib/apt/lists/lock
        rm /var/cache/apt/archives/lock
        apt update
		install_ubuntu/debian
    else
        echo -e "${Error} ${RedBG} 当前系统为 ${ID} ${VERSION_ID} 不在支持的系统列表内，安装中断 ${Font}"
        exit 1
    fi
}
is_root() {
    if [ 0 == $UID ]; then
        echo -e "${OK} ${GreenBG} 当前用户是root用户，开始安装 ${Font}"
        sleep 3
    else
        echo -e "${Error} ${RedBG} 当前用户不是root用户，请切换到root用户后重新执行脚本 ${Font}"
        exit 1
    fi
}
judge() {
    if [[ 0 -eq $? ]]; then
        echo -e "${OK} $1 成功 ${Font}"
        sleep 1
    else
        echo -e "${Error} ${RedBG} $1 失败${Font}"
        exit 1
    fi
}
install_centos_screen() {
	yum install epel-release -y
    yum install screen -y 
    judge "${GreenBG} 安装screen ${Font}"
}
install_centos_tar() {
    yum install tar -y
    judge "${GreenBG} 安装tar ${Font}"
}
install_centos_wget() {
    yum install wget -y
    judge "${GreenBG} 安装wget ${Font}"
}
install_centos_curl() {
    yum install curl -y
    judge "${GreenBG} 安装curl ${Font}"
}
centos8_change() {
    cp -r /etc/yum.repos.d ~
    sudo sed -i -e "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-*
    sudo sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-*
    dnf distro-sync
    judge "${GreenBG} Centos8迁移源 ${Font}"
}
install_screen() {
    apt-get install screen
    judge "${GreenBG} 安装screen ${Font}"
}
install_tar() {
    apt-get install tar
    judge "${GreenBG} 安装tar ${Font}"
}
install_wget() {
    apt-get install wget
    judge "${GreenBG} 安装wget ${Font}"
}
install_curl() {
    apt-get install curl
    judge "${GreenBG} 安装curl ${Font}"
}
install_centos_required() {
    yum install glibc.i686 -y
    yum install zlib.i686 -y
	yum install libstdc++.i686 -y
	yum install zlib-1.2.11-16.el8_2.i686 -y
    yum install libuuid-2.32.1-22.el8.i686 -y
    yum install lib32z1 -y
    echo -e "${OK} ${GreenBG} ${GreenBG} 安装依赖完成 ${Font}"
}
install_steam() {
    echo -e "${Skyblue}[Loading] ${GreenBG}安装 Steam${Font}"
    mkdir -p /root/csgo
    cd /root
    curl -sSL -o steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
    tar -xvf steamcmd.tar.gz
	rm steamcmd.tar.gz
	echo -e "${Skyblue}[loading] ${GreenBG}安装 CSGO${Font}"
	echo -e "${Yellow}"
	./steamcmd.sh +force_install_dir ./csgo +login anonymous +app_update 740 validate +quit
	echo -e "${Font}"
	cd /root/csgo/csgo/cfg
    wget --no-check-certificate https://down.hejincn.com/d/OneDrive/personal/autoexec.cfg
	cd 
	wget --no-check-certificate https://down.hejincn.com/d/OneDrive/personal/startcsgo.sh
	chmod -R 744 ${startcsgo_sh}
	wget --no-check-certificate https://down.hejincn.com/d/OneDrive/personal/csgo.sh
	chmod -R 744 csgo.sh
}
install_ubuntu/debian_required() {
    apt-get update
    apt-get upgrade
	apt-get install lib32gcc1
	apt-get install libstdc++6
    apt-get install lib32stdc++
    apt-get install lib32stdc++6
	apt-get install lib32z1
    judge "${GreenBG} 安装依赖 ${Font}"
}
install_ubuntu/debian() {
    is_root
    disable_firewall
    install_ubuntu/debian_required
	install screen
	install_tar
	install_wget
	install_curl
	install_steam
	install_completed
}
centos_csgo(){
    is_root
    disable_firewall
	install_centos_required
    install_centos_screen
	install_centos_tar
    install_centos_wget
	install_centos_curl
	install_steam
	install_completed
}
centos8_csgo(){
    is_root
    disable_firewall
    centos8_change
	install_centos_required
    install_centos_screen
	install_centos_tar
    install_centos_wget
	install_centos_curl
	install_steam
	install_completed
}
disable_firewall(){
    systemctl stop firewalld
    systemctl disable firewalld
    echo -e "${OK} ${GreenBG} firewalld 已关闭 ${Font}"

    systemctl stop ufw
    systemctl disable ufw
    echo -e "${OK} ${GreenBG} ufw 已关闭 ${Font}"
}
install_csgo_plugins_required(){
    echo -e "${Skyblue}[Loading]${GreenBG}安装插件端${Font}"
    cd /root/csgo/csgo
    wget https://sm.alliedmods.net/smdrop/1.11/sourcemod-1.11.0-git6919-linux.tar.gz
	tar -xvf sourcemod-1.11.0-git6916-linux.tar.gz
	wget https://mms.alliedmods.net/mmsdrop/1.11/mmsource-1.11.0-git1148-linux.tar.gz
	tar -xvf mmsource-1.11.0-git1148-linux.tar.gz
	rm mmsource-1.11.0-git1148-linux.tar.gz
	rm sourcemod-1.11.0-git6916-linux.tar.gz
	judge "${GreenBG}安装csgo插件端依赖 ${Font}"
    echo -e "${Skyblue}[Loading]${GreenBG}安装自动更新${Font}"
    cd /root/csgo/csgo/addons/sourcemod/plugins
	wget https://github.com/Sarabveer/SM-Plugins/raw/master/sw_auto_steam_update/plugins/auto_steam_update.smx
	wget https://forums.alliedmods.net/attachment.php?attachmentid=149268&d=1446230007
	cd /root/csgo/csgo
	wget https://github.com/KyleSanderson/SteamWorks/releases/download/1.2.3c/package-lin.tgz
	tar -xvf package-lin.tgz
	rm package-lin.tgz
	cd 
	wget https://down.hejincn.com/d/OneDrive/personal/autoupdate/steam.sh
	wget https://down.hejincn.com/d/OneDrive/personal/autoupdate/steamcmd.sh
	wget https://down.hejincn.com/d/OneDrive/personal/autoupdate/update.txt
	chmod -R 744 steam.sh
	chmod -R 744 steamcmd.sh
	chmod -R 744 update.txt
}
install_completed(){
    echo -e "${OK} ${GreenBG} CSGO一键安装脚本执行完成 ${Font}"
	echo -e "给服务器添加管理员打开/root/csgo/csgo/addons/sourcemod/configs/admins_simple.ini/ 最后加上一行 ”STEAM_1:0:111111“ ”z“（此处为英文双引号）
配置游戏启动配置"
    echo -e "允许自由选择饰品请打开/root/csgo/csgo/addons/sourcemod/configs/core.cfg将147行的FollowCSGOServerGuidelines的yes改为no"
    echo -e "进入/root/csgo/csgo/cfg下打开或新建文件autoexec.cfg填写cfg"
	echo -e "具体cfg填写教程可以参考 https://blog.hejincn.com/csgo%e6%9c%8d%e5%8a%a1%e5%99%a8%e6%90%ad%e5%bb%ba.html"
}
echo -e ${Skyblue}"
#==========================================================
#	系统需求:Centos 7+/Debian 9+/Ubuntu 18.04+
#	作者:	Alloy
#	个人博客：https://blog.hejincn.com
#	详细: CSGO Linux一键安装脚本
#	版本: 2.0.0
#	脚本默认安装在root目录下，请确保你有40GB以上空间安装
#==========================================================
"
check_system