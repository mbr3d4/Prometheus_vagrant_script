#!/bin/bash -e

config_init()
{
echo '=============================='
echo 'Configurações Iniciais'
echo '=============================='
HOSTS=$(head -n7 /etc/hosts)
echo -e "$HOSTS" > /etc/hosts
sudo apt update
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config 
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config   
systemctl restart sshd.service
sudo echo "vagrant:vagrant" | sudo chpasswd
sudo echo "root:123456" | sudo chpasswd
sudo usermod -aG sudo vagrant
}


install_prometheus()
{
curl -LO https://github.com/prometheus/prometheus/releases/download/v2.38.0/prometheus-2.38.0.linux-amd64.tar.gz
tar -xvf prometheus-2.38.0.linux-amd64.tar.gz
sudo mv prometheus-2.38.0.linux-amd64/prometheus /usr/local/bin/prometheus
sudo mv prometheus-2.38.0.linux-amd64/promtool /usr/local/bin/promtool
sudo mkdir /etc/prometheus
sudo mv prometheus-2.38.0.linux-amd64/prometheus.yml /etc/prometheus/prometheus.yml
sudo mv prometheus-2.38.0.linux-amd64/consoles /etc/prometheus
sudo mv prometheus-2.38.0.linux-amd64/console_libraries /etc/prometheus
cp /vagrant/config/prometheus.yml  /etc/prometheus/prometheus.yml
sudo mkdir /var/lib/prometheus
sudo mkdir /var/log/prometheus
sudo addgroup --system prometheus
sudo adduser --shell /sbin/nologin --system --group prometheus
cp /vagrant/config/prometheus.service  /etc/systemd/system/prometheus.service
sudo chown -R prometheus:prometheus /var/log/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /var/lib/prometheus
sudo chown -R prometheus:prometheus /usr/local/bin/prometheus
sudo chown -R prometheus:prometheus /usr/local/bin/promtool
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

}

config_ssh()
{
echo '=============================='
echo 'Configurações SSH'
echo '=============================='
#sudo cp /vagrant/ssh/* /root/.ssh/
#sudo cp /vagrant/ssh/* /home/vagrant/.ssh/
authorized_keys=$(cat /vagrant/ssh/id_rsa.pub)
echo $authorized_keys >> /home/vagrant/.ssh/authorized_keys
echo $authorized_keys >> /root/.ssh/authorized_keys
}

config_init
install_prometheus
config_ssh