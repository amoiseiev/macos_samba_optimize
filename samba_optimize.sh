#!/bin/zsh
set -e
NSMB_TMP=/etc/nsmb.conf_tmp
NSMB=/etc/nsmb.conf
ID=`whoami`
SELF=$0
SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

init() {
	echo "Checking UID"
	if [[ $ID == "root" ]]; then
		echo "The script must be ran with user permissions, not root"
		echo
		exit 2
	else
		echo "Your user is: $ID. Proceeding"
		echo
	fi
	
	echo "Writting desktopservices plist"
	echo
	defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE

	echo "Checking for sudoers records to run sysctl, please enter your password if asked"
	echo

	set +e
	sudo grep -E "^$ID\s+.*\/usr\/sbin\/sysctl" /etc/sudoers &> /dev/null
	sudo_check_exit_code=$?
	set -e

	if [ $sudo_check_exit_code -ne 0 ]; then
		echo "sudo sudo bootstrap needed"
		echo "$ID ALL = (ALL) NOPASSWD: /usr/sbin/sysctl" | sudo tee -a /etc/sudoers
		echo

	else
		echo "no sudo bootstrap needed"
		echo
	fi

        echo "Writing nsmb.conf"
	echo
        sudo rm -fv $NSMB_TMP
        echo "[default]" | sudo tee -a $NSMB_TMP
        echo "dir_cache_off=yes" | sudo tee -a $NSMB_TMP
        echo "signing_required=no" | sudo tee -a $NSMB_TMP
        sudo mv -fv $NSMB_TMP $NSMB

	echo "Generating launchd plist from template"
	echo
	rm -fv com.samba_optimize.plist
	cp -fv com.samba_optimize.plist_tpl com.samba_optimize.plist
	sed -i '' -e "s/<PATHTOFILE>/${SCRIPTPATH//\//\\/}/g" com.samba_optimize.plist
	mv -fv com.samba_optimize.plist ~/Library/LaunchAgents/
	echo "Adding to launchd configuration"
	launchctl load -w ~/Library/LaunchAgents/com.samba_optimize.plist
	launchctl list | grep -i samba_optimize
	
	echo "All set!"
}

run() {
	echo "Setting desktop services network browsing detault"
	echo
	echo "Removing MacOS IO throttling"
	sudo /usr/sbin/sysctl debug.lowpri\_throttle_enabled=0
}

remove() {
	echo "Removing nsmb.conf file"
	echo "Resetting default network folders browsing conf"
	echo "Removing samba_optimize from auto start"
	echo "Removing logs"
	echo "Removing sudoers record"
}

main() {
	echo \[`date`\] "Staring samba_optimize"
	echo $SCRIPTPATH/$SELF

    	case "$1" in
        	"init" )
        	   	init;;
        	"remove" )
        		remove;;
		"run" )
			run;;
        	*) 
			echo "Usage: (init|remove|run)"
			exit 2
		;;
	esac
}

main $1;
