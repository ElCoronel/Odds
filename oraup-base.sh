
orasid=$(env | grep SID | cut -d= -f2)

check_stat=$(ps -ef|grep "$orasid"|grep pmon|wc -l)
oracle_num=$(expr $check_stat)
if [ $oracle_num -lt 1 ]
then
 echo -e "\e[31m > Database is not running!\e[0m"
exit 0
fi

check_lsnr=$(ps -ef |grep tnslsnr | grep -v grep | wc -l)
lsnr_num=$(expr $check_lsnr)
if [ $lsnr_num -lt 1 ]; then
        echo -e "\e[31m > Listener is down!\e[0m"
else
        echo -e "\e[32m > Listener is up.\e[0m"
fi

$ORACLE_HOME/bin/sqlplus -s / as sysdba<<! > /tmp/check_$orasid.ora
  select open_mode from v\$database;
exit
!

check_open=$(cat /tmp/check_$orasid.ora|grep "READ WRITE"|wc -l)
oracle_num=$(expr $check_open)
if [ $oracle_num -lt 1 ]
then
 echo -e "\e[31m > SID $ORACLE_SID is down!\e[0m"
else
 echo -e "\e[32m > SID $ORACLE_SID is up.\e[0m"
exit 16
fi
rm -rf /tmp/check_$orasid.ora
