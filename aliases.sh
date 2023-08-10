if [ "$HY_MONITORING_HOME" = "" ]; then
  if [ ! -f $HOME/.hyphae_monitoring_home ]; then
    read -p 'Enter Hyphae Monitoring HOME DIR: ' HY_MONITORING_HOME
    echo $HY_MONITORING_HOME > $HOME/.hyphae_monitoring_home
  fi

  HY_MONITORING_HOME="$(cat $HOME/.hyphae_monitoring_home | xargs echo -n)"
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
  cd $HY_MONITORING_HOME
  git pull
  cp aliases.sh $HOME/.bash_aliases
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