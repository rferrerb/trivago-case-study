# -*- mode: ruby -*-
# # vi: set ft=ruby :
## RESOURCES
# http://stackoverflow.com/questions/2366018/how-to-re-sync-the-mysql-db-if-master-and-slave-have-different-database-incase-o

VAGRANTFILE_API_VERSION = "2"

def configure_node(cluster_address)
    setup = <<-SCRIPT
    sudo apt-get install -y libaio-dev
    groupadd mysql
    useradd -g mysql mysql
    cd /usr/local/
    wget -q http://dev.mysql.com/get/Downloads/MySQL-Cluster-7.2/mysql-cluster-gpl-7.2.19-linux2.6-x86_64.tar.gz
    tar xfz mysql-cluster-gpl-7.2.19-linux2.6-x86_64.tar.gz
    ln -s mysql-cluster-gpl-7.2.19-linux2.6-x86_64 mysql
    cd mysql
    scripts/mysql_install_db --user=mysql
    chown -R root:mysql .
    chown -R mysql data
    cp support-files/mysql.server /etc/init.d/
    chmod 755 /etc/init.d/mysql.server
    cd /usr/local/mysql/bin
    mv * /usr/bin
    cd ../
    rm -fr /usr/local/mysql/bin
    ln -s /usr/bin /usr/local/mysql/bin

    echo '
[mysqld]
ndbcluster
# IP address of the cluster management node
ndb-connectstring=192.168.56.130
[mysql_cluster]
# IP address of the cluster management node
ndb-connectstring=192.168.56.130
    ' > /etc/my.cnf
    mkdir /var/lib/mysql-cluster
    cd /var/lib/mysql-cluster
    ndbd --initial
    /etc/init.d/mysql.server start
    echo 'ndbd' > /etc/init.d/ndbd
    chmod 755 /etc/init.d/ndbd

    SCRIPT
end

def configure_mng(mng_address)
    setup = <<-SCRIPT
    cd /usr/local/src
    wget -q http://dev.mysql.com/Downloads/MySQL-Cluster-7.2/mysql-cluster-gpl-7.2.19-linux2.6-x86_64.tar.gz
    tar xfz mysql-cluster-gpl-7.2.19-linux2.6-x86_64.tar.gz
    cd mysql-cluster-gpl-7.2.19-linux2.6-x86_64
    cp bin/ndb_mgm /usr/bin
    cp bin/ndb_mgmd /usr/bin
    chmod 755 /usr/bin/ndb_mg*
    cd /usr/local/src
    rm -rf /usr/local/src/mysql-mgm
    mkdir /var/lib/mysql-cluster

    echo '
[NDBD DEFAULT]

NoOfReplicas=2
DataMemory=80M
IndexMemory=18M
[MYSQLD DEFAULT]

[NDB_MGMD DEFAULT]
DataDir=/var/lib/mysql-cluster
[TCP DEFAULT]

# Section for the cluster management node
[NDB_MGMD]
NodeId=1
# IP address of the first management node (this system)
HostName=192.168.56.130

#[NDB_MGMD]
#NodeId=2
#IP address of the second management node
#HostName=192.168.56.136

# Section for the storage nodes
[NDBD]
# IP address of the first storage node
HostName=192.168.56.131
DataDir= /var/lib/mysql-cluster
[NDBD]
# IP address of the second storage node
HostName=192.168.56.132
DataDir=/var/lib/mysql-cluster
# one [MYSQLD] per storage node
[MYSQLD]
[MYSQLD]
    ' > /var/lib/mysql-cluster/config.ini
    ndb_mgmd -f /var/lib/mysql-cluster/config.ini --configdir=/var/lib/mysql-cluster/ 

    echo 'ndb_mgmd -f /var/lib/mysql-cluster/config.ini --configdir=/var/lib/mysql-cluster/ ' > /etc/init.d/ndb_mgmd
    chmod 755 /etc/init.d/ndb_mgmd

    SCRIPT
end

MNG_NODES = {
  "ndb-mng1" => "192.168.56.130"
}

CLUSTER_NODES = {
    "ndb-node1" => "192.168.56.131",
    "ndb-node2" => "192.168.56.132"
}


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
#  config.cache.enable :apt #cachier
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  MNG_NODES.each do |name, address|
    config.vm.define name do |mng|
      mng_address =   address
      mng.vm.hostname = name
      mng.vm.network :private_network, ip: address
      mng.vm.provision "shell", inline: configure_mng(MNG_NODES.values)
    end
  end
  CLUSTER_NODES.each do |name, address|
    config.vm.define name do |node|
      node_address =   address
      node.vm.hostname = name
      node.vm.network :private_network, ip: address
      node.vm.provision "shell", inline: configure_node(CLUSTER_NODES.values)
    end
  end
end
