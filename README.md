# logstashdemo_vagrantfile
A working demo of an ELK stack in a multivm Vagrantfile. 

logstashdemo_vagrantfile|master ⇒ vagrant status 
Current machine states:

elasticsearch-01          not created (virtualbox)
elasticsearch-02          not created (virtualbox)
logstash-server           not created (virtualbox)
kibana                    not created (virtualbox)
logstash-client           not created (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.

I tried to make it all mostly work on first provision, but it might need a few rounds of `vagrant provision <MACHINENAME>` to get things working.

Connect to the kibana instance at http://localhost:5601 after you get the whole thing running.

basic workflow:
   vagrant up
   vagrant provision
   vagrant ssh <MACHINENAME>
   vagrant destroy