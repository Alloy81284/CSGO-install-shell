#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#====================================================
#	系统需求:Centos 7+/Debian 9+/Ubuntu 18.04+
#	作者:	Alloy
#	详细: CSGO 一键安装脚本
#	版本: 1.0.0
#====================================================

#fonts color
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
Font="\033[0m"

shell_version=1.0.0

THREAD=$(grep 'processor' /proc/cpuinfo | sort -u | wc -l)

source '/etc/os-release'

#从VERSION中提取发行版系统的英文名称，为了在debian/ubuntu下添加相对应的Nginx apt源
VERSION=$(echo "${VERSION}" | awk -F "[()]" '{print $2}')

check_system(){
    if [[ "${ID}" == "centos" && ${VERSION_ID} -ge 7 ]]; then
        echo -e "${OK} ${GreenBG} 当前系统为 Centos ${VERSION_ID} ${VERSION} ${Font}"
        INS="yum"
    elif [[ "${ID}" == "debian" && ${VERSION_ID} -ge 8 ]]; then
        echo -e "${OK} ${GreenBG} 当前系统为 Debian ${VERSION_ID} ${VERSION} ${Font}"
        INS="apt"
		${GreenBG} 当前系统为 Centos ${VERSION_ID} ${VERSION} ${Font}
    elif [[ "${ID}" == "ubuntu" && $(echo "${VERSION_ID}" | cut -d '.' -f1) -ge 16 ]]; then
        echo -e "${OK} ${GreenBG} 当前系统为 Ubuntu ${VERSION_ID} ${UBUNTU_CODENAME} ${Font}"
        INS="apt"
        rm /var/lib/dpkg/lock
        dpkg --configure -a
        rm /var/lib/apt/lists/lock
        rm /var/cache/apt/archives/lock
        $INS update
    fi
	
	menu
}
install_screen() {
    $INS install screen
    echo -e "${Yellow}安装 screen${Font}"
}
install_centos_required() {
    yum update
    yum upgrade
    yum install lib32gcc1
    yum install libstdc++6
    yum install lib32stdc++
    yum update libstdc++-4.8.5-11.el7.x86_64
    yum install glibc.i686
    yum install zlib.i686
	yum install libstdc++.i686
	yum install zlib-1.2.11-16.el8_2.i686
    yum install libuuid-2.32.1-22.el8.i686
    yum install lib32z1
    echo -e "${Yellow}安装 依赖${Font}"
}
install_steam() {
    mkdir -p /home/csgo
    cd /home/csgo
    curl -sSL -o steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
    tar -xvf steamcmd.tar.gz
	rm steamcmd_linux.tar.gz
	./steamcmd.sh +login anonymous +force_install_dir /home/csgo +app_update 740 +quit
	echo -e "${Yellow}Steam安装"
}
centos8_change() {
    cp -r /etc/yum.repos.d ~
    sudo sed -i -e "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-*
    sudo sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-*
	dnf distro-sync
	echo -e "${Yellow}Centos8迁移源${Font}"
}
install_centos() {
    install_centos_required
    install_screen
	install_steam
    echo -e "${Yellow}安装 CSGO${Font}"
}
install_centos8() {
    centos8_change
    install_centos
}
install_ubuntu/debian_required() {
    apt-get update
    apt-get upgrade
	apt-get install lib32gcc1
	apt-get install libstdc++6
    apt-get install lib32stdc++
    apt-get install lib32stdc++6
	apt-get install lib32z1
    echo -e "${Yellow}安装 依赖${Font}"
}
install_ubuntu/debian() {
	install screen
	install_steam
    echo -e "${Yellow}安装 CSGO${Font}"
}
menu(){
    echo -e "\t${Green}#===========================#${Font}"
    echo -e "\t${Green}#CSGO安装一键脚本${Red}[${shell_version}]${Font}"
    echo -e "\t${Green}#----------By Alloy----------${Font}"
    echo -e "\t${Green}#https://blog.alloyhe.top${Font}"
	echo -e "\t${Green}#脚本默认安装位置为/home/csgo${Font}"
	echo -e "\t${Green}#===========================#${Font}\n"

	echo -e "${Green}0.${Font}  版本检测 "
    echo -e "———————————————————— 安装向导 ————————————————————"""
    echo -e "${Green}1.${Font}  Centos 版本安装 【Centos7+通用（包括Stream）】"
	echo -e "${Green}2.${Font}  Centos8版本安装 【仅限未迁移源的Centos8】"
	echo -e "${Green}3.${Font}  Ubuntu 版本安装 【18.04+】"
	echo -e "${Green}4.${Font}  Debian 版本安装 【9+】"
    echo -e "———————————————————— 其他选项 ————————————————————"
    echo -e "${Green}5.${Font} 退出 \n"

    read -rp "请输入数字：" menu_num
    case $menu_num in

    0)
	
        check_system
        ;;
    1)

        install_centos
        ;;
	2)

        install_centos8
        ;;
	3)

        install_ubuntu/debian
        ;;
	4)

        install_ubuntu/debian
        ;;
    5)
        exit 0
        ;;
    *)
        echo -e "${RedBG}请输入正确的数字${Font}"
        ;;
    esac
}
menu