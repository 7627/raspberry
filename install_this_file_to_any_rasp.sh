#!/bin/bash

#send public key to server, to add to the authincate keys file
read -p 'Username:   ' username

scp ./.ssh/id_rsa.pub $username@172.26.83.102:$(logname).pub &&
	ssh $username@172.26.83.102 "cat $(logname).pub >> ./.ssh/authorized_keys"

 echo "@reboot $(logname) /home/$(logname)/cronjob_ssh.sh &> /dev/null
* * * * * $(logname) /home/$(logname)/send_port.sh &> /dev/null" > /etc/cron.d/ssh_tunnel 


echo "#!/bin/bash
X=\$(shuf -i 10000-65000 -n 1)
echo \$X > /home/$(logname)/x.txt
autossh -i /home/$(logname)/.ssh/id_rsa -f -N -R \$X:localhost:22 $username@172.26.83.102" > /home/$(logname)/cronjob_ssh.sh


chmod u+x /home/$(logname)/cronjob_ssh.sh


echo "#!/bin/bash
X=\$(cat /home/$(logname)/x.txt)
ssh -i /home/$(logname)/.ssh/id_rsa $username@172.26.83.102 \"echo \$X > $(logname).txt\"
" > /home/$(logname)/send_port.sh

chmod u+x /home/$(logname)/send_port.sh


sh cronjob_ssh.sh
sh send_port.sh
