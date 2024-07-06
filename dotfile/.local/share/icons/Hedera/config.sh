#!/bin/sh
_recolorfolders="action-albumfolder-importdir2.png
add-folder-to-archive.png
albumfolder-importdir.png
albumfolder-importimages.png
albumfolder-new.png
applications-accessories.png
applications-development-translation.png
applications-development-web.png
applications-development.png
applications-education-language.png
applications-education-mathematics.png
applications-education-miscellaneous.png
applications-education-preschool.png
applications-education-school.png
applications-education-science.png
applications-education-university.png
applications-education.png
applications-engineering.png
applications-games.png
applications-graphics.png
applications-internet.png
applications-multimedia.png
applications-office.png
applications-other.png
applications-science.png
applications-system.png
applications-toys.png
applications-utilities.png
archive-insert-directory.png
bookmark_folder.png
cxmenu-cxoffice-0-cxmenu.png
cxmenu.png
dialog-open.png
directory-closed.png
directory.png
document-open-data.png
document-open-folder.png
document-open-recent.png
document-open-remote.png
document-open.png
e-module-gadman.png
favorites.png
fileopen.png
folder-activities.png
folder-add.png
folder-bookmark.png
folder-cloud.png
folder-development.png
folder-documents.png
folder-download.png
folder-downloads.png
folder-dropbox.png
folder-drag-accept.png
folder-favorites.png
folder-gdrive.png
folder-html.png
folder-image-people.png
folder-image.png
folder-images.png
folder-important.png
folder-mail.png
folder-music.png
folder-network.png
folder-new.png
folder-onedrive.png
folder-open.png
folder-owncloud.png
folder-picture.png
folder-pictures.png
folder-print.png
folder-public.png
folder-publicshare.png
folder-remote.png
folder-script.png
folder-sound.png
folder-tar.png
folder-templates.png
folder-text.png
folder-video.png
folder-videos.png
folder-videos.png
folder.png
folder_color_downloads.png
folder_favorite.png
folder_html.png
folder_important.png
folder_new.png
folder_open.png
folder_sound.png
folder_txt.png
folder_video.png
folder_videos.png
folder_wordprocessing.png
folder_home.png
folder_home2.png
folder-home2.png
gfpm-instfromfile.png
gmpc-database.png
gnome-applications.png
gnome-devel.png
gnome-fs-desktop.png
gnome-fs-home.png
gnome-fs-directory.png
gnome-fs-ftp.png
gnome-fs-network.png
gnome-fs-nfs.png
gnome-fs-share.png
gnome-fs-smb.png
gnome-fs-ssh.png
gnome-globe.png
gnome-graphics.png
gnome-joystick.png
gnome-mime-x-directory-smb-share.png
gnome-mime-x-directory-smb-workgroup.png
gnome-multimedia.png
gnome-other.png
gnome-system.png
gnome-util.png
gtk-directory.png
gtk-network.png
gtk-open.png
inode-directory.png
insync-folder.png
knetattach.png
library-music.png
mate-panel-drawer.png
modules-system.png
modules-utils.png
network-server.png
network-workgroup.png
network.png
network_local.png
new-folder.png
open.png
org.kde.plasma.folder.png
package_development.png
package_games.png
package_graphics.png
package_multimedia.png
package_network.png
package_office.png
package_system.png
package_utilities.png
package_wordprocessing.png
plasmaapplet-shelf.png
preferences-directories.png
preferences-other.png
project-open.png
redhat-home.png
redhat-accessories.png
redhat-games.png
redhat-graphics.png
redhat-internet.png
redhat-office.png
redhat-programming.png
redhat-sound_video.png
redhat-system.png
redhat-system_tools.png
sidebar-places.png
stock_folder.png
stock_internet.png
stock_new-dir.png
stock_open.png
tag-folder.png
user-bookmarks.png
user-home.png
user-desktop.png
x-clementine-albums.png
xfce-devel.png
xfce-games.png
xfce-graphics.png
xfce-internet.png
xfce-multimedia.png
xfce-office.png
xfce-sound.png
xfce-system.png
xfce-unknown.png
xfce-utils.png
yast-nfs.png
yast-samba-client.png"

set -e
if [ ! -t 0 ]; then
	if type x-terminal-emulator &>/dev/null; then
		x-terminal-emulator -e "$0"
		exit 0
	else
		exit 1
	fi
fi
_basedir="$(dirname "$(readlink -f "${0}")")"
cd $_basedir
if [ ! -f ./icon-theme.cache ];then
	printf "You have to build the theme fist!\n"
	sleep 5
	exit 1
fi

auto_distroicon() {
	if [ -f /etc/debian_version ];then
		if dpkg --get-selections|grep siduction ;then
			_distributor="siduction"
		elif dpkg --get-selections|grep devuan ;then
			_distributor="devuan"
		elif dpkg --get-selections|grep trios ;then
			_distributor="trios"
		elif dpkg --get-selections|grep linuxmint ;then
			_distributor="linuxmint"
		elif dpkg --get-selections|grep ubuntu ;then
			_distributor="ubuntu"
		elif dpkg --get-selections|grep kfreebsd ;then
			_distributor="freebsd"
		else
			_distributor="debian"
		fi
	fi
	if [ -f /etc/SUSE-brand ];then
		_distributor="suse"
	fi
	if [ -f /etc/devuan_version ];then
		_distributor="devuan"
	fi
	if [ -f /etc/manjaro-release ];then
		_distributor="manjaro"
	fi
	if [ -f /etc/gentoo-release ];then
		_distributor="gentoo"
	fi
	if [ -f /etc/alpine-release ];then
		_distributor="alpine"
	fi
	if [ -f /etc/slackware-version ];then
		_distributor="slackware"
	fi
	if [ -f /etc/salix-update-notifier.conf ];then
		_distributor="salix"
	fi
	if [ -f /etc/GoboLinuxVersion ];then
		_distributor="gobo"
	fi
	if [ -f /etc/freebsd-update.conf ];then
		_distributor="freebsd"
	fi
	if [ -f /etc/chakra-release ];then
		_distributor="chakra"
	fi
#systemd
	if [ -f /etc/os-release ]; then
		if [ $(cat /etc/os-release|grep "^NAME=Puppy$") ];then
			_distributor="puppy"
		elif [ $(cat /etc/os-release|grep "^ID=ubuntu$") ];then
			_distributor="ubuntu"
		elif [ $(cat /etc/os-release|grep "^ID=neon$") ];then
			_distributor="ubuntu"
		elif [ $(cat /etc/os-release|grep "^ID=linuxmint$") ];then
			_distributor="ubuntu"
		fi
	fi
	printf "\nsearching distributor $_distributor icon...\n"
	if [ -f "${_basedir}"/240/logos/distributor-$_distributor.png ];then
		printf "\nSetting $_distributor as your distributior.\n"
		for _dir in $(echo $(find "${_basedir}" -maxdepth 1 -mindepth 1 -type d -not -name symbolic));do
			cd $_dir
			cp -fv "$_dir"/logos/distributor-$_distributor.png "$_dir"/logos/emblem-distributor.png
			cd $_basedir
		done
	fi
}

custom_distroicon() {
	printf "The following icons are currently available:\n"
	find "${_basedir}"/240/logos -name "distributor-*.png"|sed 's/^.*-//g;s/.png//g'
	printf "\nPlease enter the name of the icon(eg: kde for distributor-kde.png)\n\n"
	read _customiconname
	if [ ! -f "${_basedir}"/240/logos/distributor-$_customiconname.png ];then
		printf "\ndistributor-$_customiconname.png does not exist - Aborting!\n"
		exit 1
	else
		_distributor="$_customiconname"
	fi
	for _dir in $(echo $(find "${_basedir}" -maxdepth 1 -mindepth 1 -type d -not -name symbolic));do
		cd $_dir
		cp -fv "$_dir"/logos/distributor-$_distributor.png "$_dir"/logos/emblem-distributor.png
		cd $_basedir
	done
}

reset_distroicon() {
	for _dir in $(echo $(find "${_basedir}" -maxdepth 1 -mindepth 1 -type d -not -name symbolic));do
		cd $_dir
		cp -fv "$_dir"/logos/emblem-ivy.png "$_dir"/logos/emblem-distributor.png
		cd $_basedir
	done
}

toggleqtworkaround() {
	#if [ -f index.theme.xdg ];then
		#printf "disabling Qt-workaround\n"
		#mv -v index.theme index.theme.qt
		#mv -v index.theme.xdg index.theme
	#elif [ -f index.theme.qt ];then
		#printf "enabling Qt-workaround\n"
		#mv -v index.theme index.theme.xdg
		#mv -v index.theme.qt index.theme
	#fi
	printf "removed!\n"
}

createsymbolicsymlinks() {
	printf "removed!\n"
	#cd $_basedir
	#unset "_tmpicons"
	#if [ -d /usr/share/icons ];then
		#_prefix=/usr
	#elif [ -d $(getconf PATH| sed 's/\/bin//g;s/://g')/share/icons ];then
		#_prefix=$(getconf PATH| sed 's/\/bin//g;s/://g')
	#else
		#printf "couldn't find prefix"
	#fi
	#if [ -d $_prefix/share/icons/[Gg]nome ]; then
		#_tmpicons="$_tmpicons\n$(find $_prefix/share/icons/[Gg]nome -mindepth 1 -type f -iname "*symbolic*" -printf "%f\n"|sed 's/.svg/.png/g')"
	#else
		#printf "The Gnome theme isn't installed you will probably miss some icons"
		#sleep 3
	#fi
	#if [ -d $_prefix/share/icons/[Aa]dwaita ]; then
		#_tmpicons="$_tmpicons\n$(find $_prefix/share/icons/[Aa]dwaita -mindepth 1 -type f -iname "*symbolic*" -printf "%f\n"|sed 's/.svg/.png/g')"
	#else
		#printf "The Adwaita theme isn't installed you will probably miss some icons"
		#sleep 3
	#fi
	#if [ -d $_prefix/share/icons/[Hh]icolor ]; then
		#_tmpicons="$_tmpicons\n$(find $_prefix/share/icons/[Hh]icolor -mindepth 1 -type f -iname "*symbolic*" -printf "%f\n"|sed 's/.svg/.png/g')"
	#fi
	#printf "$_tmpicons" > symboliclinks
	#sort symboliclinks|uniq > icons
	#cd 16
	#if [ ! -f $_basedir/pre_symbolicicons ];then
		#find misc-symbolic >$_basedir/pre_symbolicicons
	#fi
	#if [ ! -d misc-symbolic ];then
		#mkdir misc-symbolic
	#fi
	#for _icon in $(cat ../icons); do
		#if [ -f "misc/$(echo "$_icon"|sed 's/-symbolic.symbolic.png/.png/')" ];then
			#if [ ! -L misc-symbolic/$_icon ]; then
				#ln -sv ../misc/$(echo $_icon|sed 's/-symbolic.symbolic.png/.png/') misc-symbolic/$_icon
			#fi
		#fi
		#if [ -f "misc/$(echo "$_icon"|sed 's/-symbolic.png/.png/')" ];then
			#if [ ! -L misc-symbolic/$_icon ]; then
				#ln -sv ../misc/$(echo $_icon|sed 's/-symbolic.png/.png/') misc-symbolic/$_icon
			#fi
		#fi
	#done
	#cd $_basedir
	#rm symboliclinks icons
	#for _dir in $(echo $(find -maxdepth 1 -mindepth 1 -type d)|sed 's#./16##');do
			#cp -r 16/misc-symbolic $_dir
	#done
}

removesymbolicsymlinks() {
	printf "removed!\n"
	#cd $_basedir
	#cd 16
	#find misc-symbolic >$_basedir/post_symbolicicons
	#_createdicons=$(diff $_basedir/pre_symbolicicons $_basedir/post_symbolicicons|grep "[<>]"|sort|sed 's/^[<>] //'|uniq -u)
	#cd $_basedir
	#for _dir in $(echo $(find -maxdepth 1 -mindepth 1 -type d)|sed 's#./16##');do
		#cd $_dir
		#for _createdicon in $(echo $_createdicons); do
			#if [ -f $_createdicon ];then
				#rm -vf $_createdicon
			#fi
		#done
		#cd $_basedir
	#done
	#rm -f $_basedir/pre_symbolicicons $_basedir/post_symbolicicons
}

recolorfolders() {
	cd $_basedir
	printf "Please enter a color name! \n(blue, pink, violet, green, red, yellow, grey, orange, white, ecru(default), brown, cyan)\n\n"
	read _newcolor
	if [ ! -f "${_basedir}"/240/folders/folder-$_newcolor.png ];then
		printf "\n$_newcolor is not a valid color! - Aborting!\n"
		exit 1
	else
		_oldcolor=$(readlink "${_basedir}"/240/misc-filesystems/inode-directory.png|sed 's/^.*-//g;s/\..*$//g')
		for _recolorfolder in $(echo $_recolorfolders); do
			for _reallink in $(echo $(find ${_basedir} -name "$_recolorfolder")); do
				ln -sf $(readlink $_reallink|sed 's/'$_oldcolor'/'$_newcolor'/g') $_reallink
			done
		done
	fi
}


rebuildgtkiconcache() {
	if type gtk-update-icon-cache &>/dev/null; then
        rm -rf $_basedir/icon-theme.cache
		gtk-update-icon-cache $_basedir
	elif type gtk-update-icon-cache-3.0 &>/dev/null; then
        rm -rf $_basedir/icon-theme.cache
		gtk-update-icon-cache-3.0 $_basedir
	fi
	if [ ! -f $_basedir/icon-theme.cache ]; then
		printf "\nIcon cache creation failed!, is gtk-update-icon-cache installed?\n\n"
	fi
}

case "$1" in
    -i)
		auto_distroicon
		rebuildgtkiconcache
		exit 0
    ;;
esac

while [ 1 ];do
	clear
	printf "\nWhat would you like to do?:\n
#1: Try to automatically set the distributor icon
#2: Set a custom distributor icon
#3: Reset distributor icon
#4: Change the current folder color
#5: Rebuild GTK+ icon cache
#6: Exit this script\n\n"
	printf "Make your choice: [1,2,3,4,5,6]"
	read _choice
	case $_choice in
		1)
			clear
			auto_distroicon
			rebuildgtkiconcache
			sleep 5
		;;
		2)
			clear
			custom_distroicon
			rebuildgtkiconcache
			sleep 5
		;;
		3)
			clear
			reset_distroicon
			rebuildgtkiconcache
			sleep 5
		;;
		4)
			clear
			recolorfolders
			rebuildgtkiconcache
			sleep 5
		;;
		5)
			clear
			rebuildgtkiconcache
			sleep 5
		;;
		6)
			printf "\nbye\n"
			sleep 2
			exit 0
			break
		;;
		*)
			printf '\nnothing more here\n'
		;;
	esac
done
