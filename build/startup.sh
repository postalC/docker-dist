/usr/sbin/sshd -f ~/ssh/etc/sshd_config
if [ $? -eq 0 ];then
	echo "ssh server started!"
fi
