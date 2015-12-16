# this is a demo of a sensible start at a production logstash system
# -*- mode: ruby -*-

elasticsearch_script = <<EOF
rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
rpm -qa | grep -q elasticsearch || yum -y install https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/rpm/elasticsearch/2.1.0/elasticsearch-2.1.0.rpm
grep -q '_eth1:ipv4_' /etc/elasticsearch/elasticsearch.yml || echo 'network.host: _internal_ip:ipv4_' >> /etc/elasticsearch/elasticsearch.yml
grep -q '"elasticsearch-01", "elasticsearch-02"' /etc/elasticsearch/elasticsearch.yml || echo 'discovery.zen.ping.unicast.hosts: ["elasticsearch-01", "elasticsearch-02"]' >> /etc/elasticsearch/elasticsearch.yml
/etc/init.d/elasticsearch restart
EOF

kibana_script = <<EOF
curl https://download.elastic.co/kibana/kibana/kibana-4.3.0-linux-x64.tar.gz > /tmp/kibana-4.3.0-linux-x64.tar.gz
tar -zxvf /tmp/kibana-4.3.0-linux-x64.tar.gz -C /opt
echo 'elasticsearch.url: "http://elasticsearch-01:9200"' >> /opt/kibana-4.3.0-linux-x64/config/kibana.yml
nohup /opt/kibana-4.3.0-linux-x64/bin/kibana > /tmp/kibana.log
EOF

logstash_script = <<EOF
rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
rpm -qa | grep -q logstash || yum -y install https://download.elastic.co/logstash/logstash/packages/centos/logstash-2.1.1-1.noarch.rpm
/etc/init.d/logstash restart
EOF

modern_rsyslog_script = <<EOF
rpm --import http://rpms.adiscon.com/RPM-GPG-KEY-Adiscon
curl http://rpms.adiscon.com/v8-stable/rsyslog.repo > /etc/yum.repos.d/rsyslog.repo 
yum upgrade -y rsyslog
chmod +x /opt/rsyslog_logstash_json_rotate.sh
/etc/init.d/rsyslog restart
EOF

logstash_forwarder_script = <<EOF
rpm -qa | grep -q logstash-forwarder || yum install -y https://download.elasticsearch.org/logstash-forwarder/binaries/logstash-forwarder-0.4.0-1.x86_64.rpm
/etc/init.d/logstash-forwarder restart
EOF


hosts = <<EOF
echo '192.168.205.10   elasticsearch-01' >> /etc/hosts
echo '192.168.205.11   elasticsearch-02' >> /etc/hosts
echo '192.168.205.20   logstash-server' >> /etc/hosts
echo '192.168.205.21   kibana' >> /etc/hosts
echo '192.168.205.100  logstash-client' >> /etc/hosts
EOF

boxes = [
  {
    :name => "elasticsearch-01",
    :internal_ip => "192.168.205.10",
    :mem => "3072",
    :cpu => "2",
    :scripts => [elasticsearch_script],
  },
  {
    :name => "elasticsearch-02",
    :internal_ip => "192.168.205.11",
    :mem => "3072",
    :cpu => "2",
    :scripts => [elasticsearch_script,],
  },
  {
    :name => "logstash-server",
    :internal_ip => "192.168.205.20",
    :mem => "1536",
    :cpu => "4",
    :scripts => [logstash_script],
    :files => [
      {:src => './logstash_server.conf', :dest => '/etc/logstash/conf.d/server.conf'},
      {:src => './lumberjack.crt', :dest => '/etc/logstash/lumberjack.crt'},
      {:src => './lumberjack.key', :dest => '/etc/logstash/lumberjack.key'},
    ]
  },
  {
    :name => "kibana",
    :internal_ip => "192.168.205.21",
    :mem => "768",
    :cpu => "1",
    :scripts => [kibana_script],
    :port_forwards => [
      {
        :guest => 5601,
        :host => 5601
      },
    ],
  },
  {
    :name => "logstash-client",
    :internal_ip => "192.168.205.100",
    :mem => "768",
    :cpu => "1",
    :scripts => [logstash_script, modern_rsyslog_script, logstash_forwarder_script],
    :files => [
      {:src => './logstash_client.conf', :dest => '/etc/logstash/conf.d/client.conf'},
      {:src => './syslog_logstash_json.conf', :dest => '/etc/rsyslog.d/syslog_logstash_json.conf'},
      {:src => './rsyslog_logstash_json_rotate.sh', :dest => '/opt/rsyslog_logstash_json_rotate.sh'},
      {:src => './lumberjack.crt', :dest => '/etc/logstash/lumberjack.crt'},
      {:src => './logstash-forwarder.conf', :dest => '/etc/logstash-forwarder.conf'},
    ]
  }
]

pkgs = %w(
  nano
  java-1.8.0-openjdk
)


Vagrant.configure(2) do |config|
  if Vagrant.has_plugin?("vagrant-cachier")
      config.cache.scope = :box
  end
  config.vm.box = "bento/centos-6.7"
  config.vm.synced_folder ".", "/vagrant", disabled: true
  #config.vm.network "public_network", bridge: [
  #"enp0s25",
  #"wlp4s0",
  #]
  boxes.each do |opts|
    config.vm.define opts[:name] do | my_config |
      my_config.vm.hostname = opts[:name]
      my_config.vm.provision "shell", inline: "yum install -y #{pkgs.join(' ')}"
      my_config.vm.provision "shell", inline: hosts
      my_config.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--memory", opts[:mem]]
        v.customize ["modifyvm", :id, "--cpus", opts[:cpu]]
      end
      my_config.vm.network :private_network, ip: opts[:internal_ip]
      if opts[:port_forwards]
        opts[:port_forwards].each do |portfwd|
          my_config.vm.network "forwarded_port", guest: portfwd[:guest], host: portfwd[:host]
        end
      end
      if opts[:files] 
        opts[:files].each do |file|
          my_config.vm.provision "file", source: file[:src], destination: ('/tmp/' + File.basename(file[:dest]) )
          my_config.vm.provision "shell", inline: "mv #{'/tmp/' + File.basename(file[:dest])} #{file[:dest]} "
        end
      end
      if opts[:scripts] 
        opts[:scripts].each do |script|
          my_config.vm.provision "shell", inline: script
        end
      end
    end
  end
end
