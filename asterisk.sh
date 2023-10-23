


#Update system & reboot
sudo apt update && sudo apt -y upgrade

#Install Asterisk 16 LTS dependencies
sudo apt -y install git curl wget libnewt-dev libssl-dev libncurses5-dev subversion  libsqlite3-dev build-essential libjansson-dev libxml2-dev  uuid-dev

#Add universe repository and install subversio
sudo add-apt-repository universe
sudo apt update && sudo apt -y install subversion

#Download Asterisk 16 LTS tarball
# sudo apt policy asterisk
#cd /usr/src/
cd ~
sudo curl -O http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-20-current.tar.gz

#Extract the file
tar xvf asterisk-20-current.tar.gz
cd asterisk-20*/

#download the mp3 decoder library
sudo contrib/scripts/get_mp3_source.sh

#Ensure all dependencies are resolved
sudo contrib/scripts/install_prereq install

#Run the configure script to satisfy build dependencies
sudo ./configure

#Setup menu options by running the following command:
sudo make menuselect

#Use arrow keys to navigate, and Enter key to select. On Add-ons select chan_ooh323 and format_mp3 . 
#On Core Sound Packages, select the formats of Audio packets. Music On Hold, select 'Music onhold file package' 
# select Extra Sound Packages
#Enable app_macro under Applications menu
#Change other configurations as required

#build Asterisk
sudo make

#Install Asterisk by running the command:
sudo make install

#Install documentation(Optionally)
sudo make progdocs

#Install configs and samples
sudo make samples
sudo make config

#Create a separate user and group to run asterisk services, and assign correct permissions:
sudo groupadd asterisk
sudo useradd -r -d /var/lib/asterisk -g asterisk asterisk
sudo usermod -aG audio,dialout asterisk
sudo chown -R asterisk.asterisk /etc/asterisk
sudo chown -R asterisk.asterisk /var/{lib,log,spool}/asterisk
sudo chown -R asterisk.asterisk /usr/lib/asterisk

#Set Asterisk default user to asterisk:
sudo vim /etc/default/asterisk

# AST_USER="asterisk"
# AST_GROUP="asterisk"
# sudo ldconfig

sudo vim /etc/asterisk/asterisk.conf
# runuser = asterisk ; The user to run as.
# rungroup = asterisk ; The group to run as.

#Restart asterisk service
sudo systemctl restart asterisk

#Enable asterisk service to start on system  boot
sudo systemctl enable asterisk

#Test to see if it connect to Asterisk CLI
sudo asterisk -rvv

#open http ports and ports 5060,5061 in ufw firewall
sudo ufw allow proto tcp from any to any port 5060,5061


### CONFIGURE SIP###

sudo vim /etc/asterisk/pjsip.conf

[transport-udp]
type=transport
protocol=udp
bind=0.0.0.0

[7000]
type=endpoint
context=from-internal
disallow=all
allow=ulaw
auth=7000
aors=7000

[7000]
type=auth
auth_type=userpass
password=password
username=7000

[7000]
type=aor
max_contacts=1

sudo vim /etc/asterisk/sip.conf

[general]
context=default

[6001]
type=friend
context=from-internal
host=dynamic
secret=unsecurepassword
disallow=all
allow=ulaw


sudo vim /etc/asterisk/extensions.conf

[from-internal]
exten = 100,1,Answer()
same = n,Wait(1)
same = n,Playback(hello-world)
same = n,Hangup()


#Troubleshooting

Problem: # *reference: https://www.clearhat.org/2019/04/12/a-fix-for-apt-install-asterisk-on-ubuntu-18-04/
radcli: rc_read_config: rc_read_config: can't open /etc/radiusclient-ng/radiusclient.conf: No such file or directory


Fix:
sed -i 's";\[radius\]"\[radius\]"g' /etc/asterisk/cdr.conf
sed -i 's";radiuscfg => /usr/local/etc/radiusclient-ng/radiusclient.conf"radiuscfg => /etc/radcli/radiusclient.conf"g' /etc/asterisk/cdr.conf
sed -i 's";radiuscfg => /usr/local/etc/radiusclient-ng/radiusclient.conf"radiuscfg => /etc/radcli/radiusclient.conf"g' /etc/asterisk/cel.conf

