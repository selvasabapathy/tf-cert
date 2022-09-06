#!/bin/bash
yum -y update
yum -y install httpd
MYIP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

cat <<EOF > /var/www/html/index.html
<html>
<h2>Webserver built by <font color="red">Terraform</font></h2><br/>
<h3>PrivateIP: $MYIP</h3><br/>

Server owner is ${f_name} ${l_name}<br/><br/>

Assistants are<br/>
%{ for x in assistants ~}
${x}<br/>
%{ endfor ~}
</html>
EOF

service httpd start
chkconfig httpd on