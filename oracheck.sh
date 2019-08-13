#!/bin/bash
localpath=/home/userx
dbhost=/home/userx/dbhosts.list
if [ ! -f "$localpath/oraup-base.sh" ]; then
        echo -e "\e[32m No oraup-bash.sh found. Exiting.\e[0m"
        exit 1
fi

dbmod=$( echo "$@" | awk '{print tolower($0)}')

if [ -z "$dbmod" ]; then
        echo "usage: ./oracheck.sh <all/dev/test/prod/ctor/arm/idm/ocr/idim/arch/kon/edr/c5/lin/sol>"
	echo "only the first modifier will be used."
        exit 1
fi

dball() {
	echo -e "\e[96m------------------------------------------------\e[0m"
	dbos=$(ssh -q $i "uname -a | cut -d' ' -f1")
	dbhn=$(ssh -q $i "hostname")
	fping -c1 -t300 $i 2>/dev/null 1>/dev/null
	pup=$?
	if [ "$pup" -ge 1 ]; then
		echo -e "\e[32m > $i not responding.\e[0m"
	elif [ "$pup" = 0 ]; then
		if [ $dbos = "Linux" ]; then
			linux
		elif [ $dbos = "SunOS" ]; then
			solaris
		else
			echo -e "\e[33m$dbhost - OS not recognized. Exiting.\e[0m"
		fi
	else
		echo -e "Something spooky happened with $dbhn."
	fi
	workall
}

linux() {
			echo -e "#!/bin/bash\n" > $localpath/oraup-mod.sh	
			cat $localpath/oraup-base.sh >> $localpath/oraup-mod.sh
			echo "$i - linux - $dbhn"
			scp -q $localpath/oraup-mod.sh $i:/home/userx/
			ssh -qt $i "sudo mv /home/userx/oraup-mod.sh /tmp/oraup-mod.sh"
			rm -rf $localpath/oraup-mod.sh
}

solaris() {
			echo -e "#!/usr/bin/bash\n" > $localpath/oraup-mod.sh
			cat $localpath/oraup-base.sh >> $localpath/oraup-mod.sh
			echo "$i - solaris - $dbhn"
			scp -q $localpath/oraup-mod.sh $i:/export/home/userx/
			ssh -qt $i "sudo mv /export/home/userx/oraup-mod.sh /tmp/oraup-mod.sh"
			rm -rf $localpath/oraup-mod.sh
}

workall() {
		dbuser=$(ssh -q $i "cat /etc/passwd | grep ora | cut -d: -f1")
		ssh -qt $i "sudo chmod 755 /tmp/oraup-mod.sh; sudo chown $dbuser:dba /tmp/oraup-mod.sh"
		ssh -qt $i "sudo -i -u $dbuser /tmp/oraup-mod.sh"
		ssh -qt $i  "sudo rm -rf /tmp/oraup-mod.sh"
}

if [ "$dbmod" = "all" ]; then
	for i in `cat $dbhost | awk '{print $1}'`; do
		dball
	done
else
	for i in `cat $dbhost | grep "$dbmod" | awk '{print $1}'`; do
		dball
	done
fi
