# rotate the log
mv -f /var/log/messages.logstash.json /var/log/messages.logstash.json.1
# give logstash-forwarder a chance to get going on the new file and mark a line position
sleep 5
# restart it to liberate file handles
/etc/init.d/logstash-forwarder restart