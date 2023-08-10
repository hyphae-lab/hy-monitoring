. edit-ini.sh

hyphae-monitor-init() {
  hyphae-edit-ini monitor.ini 'port,secret' 'cmd,cmd_label,cmd_expected_ouput'
}

hyphae-monitor-all-init() {
  hyphae-edit-ini monitor-all.ini 'port,from_email,secret' 'url,url_id,url_name,url_secret,alert_email'
}
