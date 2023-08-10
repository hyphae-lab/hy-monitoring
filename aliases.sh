if [ "$HY_MONITORING_HOME" = "" ]; then
  read -p 'Enter Hyphae Monitoring HOME DIR: ' HY_MONITORING_HOME
  export HY_MONITORING_HOME;
fi

. $HY_MONITORING_HOME/edit-ini.sh

hyphae-monitor-init() {
  hyphae-edit-ini monitor.ini 'port,secret' 'cmd,cmd_label,cmd_expected_ouput'
}

hyphae-monitor-all-init() {
  hyphae-edit-ini monitor-all.ini 'port,from_email,secret' 'url,url_id,url_name,url_secret,alert_email'
}

hyphae-self-update() {
  git pull
  cp $HY_MONITORING_HOME/aliases.sh $HOME/.bash_aliases
  . $HOME/.bash_aliases
}

hyphae-help() {
  echo 'Hyphae Monitoring'
  echo " home dir: $HY_MONITORING_HOME"
  echo ' commands available:'
  echo
  echo '   hyphae-help'
  echo '   hyphae-self-update'
  echo
  echo '   hyphae-monitor-init'
  echo '   hyphae-monitor-all-init'
  echo
  echo '   hyphae-edit-ini <file_path> <fields_comma_delim> <groupped_fields_comma delim>'
}

hyphae-help;