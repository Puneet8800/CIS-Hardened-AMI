echo "*******Installing AWS Inspector Agent********"
curl -o "/tmp/inspector_install" https://inspector-agent.amazonaws.com/linux/latest/install
sudo bash /tmp/inspector_install
sudo /etc/init.d/awsagent start
rm -rf /tmp/inspector_install
