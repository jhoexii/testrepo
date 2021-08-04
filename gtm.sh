#!/bin/bash
sed -i "s|80|8081|g" /etc/httpd/conf/httpd.conf
service httpd restart
wget --no-check-certificate -O /etc/ssl/proxy.py https://raw.githubusercontent.com/jhoexii/testrepo/main/proxy.py -q
/bin/cat <<"EOM" >/etc/gtm
#!/bin/bash
nc -zv 127.0.0.1 80 && sudo kill $( sudo lsof -i:80 -t )
if nc -z localhost 80; then
    echo "stunnel running"
else
    echo "80 Started"
    screen -dmS openvpn python /etc/ssl/proxy.py 80
fi
sudo sync; echo 3 > /proc/sys/vm/drop_caches
swapoff -a && swapon -a
echo "Ram Cleaned!"
EOM
chmod +x /etc/ssl/proxy.py
chmod +x /etc/gtm
sed -i '/gtm/d' /root/vpn
printf "\nbash /etc/gtm\n" >> /root/vpn
bash vpn
