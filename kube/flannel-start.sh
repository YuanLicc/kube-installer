# start flanneld
echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] reload config file
systemctl daemon-reload

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] set flanneld start when system start
systemctl enable flanneld

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] start flanneld
systemctl start flanneld

echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] see the flanneld status
systemctl status flanneld
