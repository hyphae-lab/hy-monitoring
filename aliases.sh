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
  cd $HY_MONITORING_HOME
  hyphae-edit-ini monitor.ini 'port,secret' 'cmd,cmd_label,cmd_expected_ouput'
  if [ "$(ps aux | grep monitor-server.py | grep -v | wc -l | tr -d ' ')" = "0" ]; then
    echo 'Monitor Server is starting on port ' $(grep port monitor.ini | sed -e 's/port=//' -e 's/ //g' )
    nohup python3 monitor-server.py 2>$HY_MONITORING_HOME/monitor.error 1>$HY_MONITORING_HOME/monitor.log &
    echo ' ...started'
  else
    echo 'Monitor Server is running on port ' $(grep port monitor.ini | sed -e 's/port=//' -e 's/ //g' )
  fi
}

hyphae-monitor-status() {
  cd $HY_MONITORING_HOME
  if [ ! -f monitor.ini ]; then
    echo 'Missing monitor.ini'
    echo 'Please run hyphae-monitor-init command'
    return 1
  fi
  if [ "$(ps aux | grep monitor-server.py | grep -v grep | wc -l | tr -d ' ')" = "0" ]; then
    echo 'Monitor Server is NOT running'
    return 1
  else
    echo 'Monitor Server is running on port ' $(grep port monitor.ini | sed -e 's/port=//' -e 's/ //g' )
  fi
  echo 'Monitor is check the following commands, with label and expected output:'
  $(grep '^cmd' monitor.ini | sed -E -e 's/^cmd_//' )
}

hyphae-monitor-all-init() {
  hyphae-edit-ini monitor-all.ini 'port,from_email,secret' 'url,url_id,url_name,url_secret,alert_email'
  if [ "$(ps aux | grep monitor-all-server.py | grep -v | wc -l | tr -d ' ')" = "0" ]; then
    echo 'Monitor ALL Server is running on port ' $(grep port monitor-all.ini | sed -e 's/port=//' -e 's/ //g' )
    nohup python3 monitor-all-server.py 2>$HY_MONITORING_HOME/monitor.error 1>$HY_MONITORING_HOME/monitor.log &
  else
    echo 'Monitor ALL Server is running on port ' $(grep port monitor-all.ini | sed -e 's/port=//' -e 's/ //g' )
  fi
}

hyphae-monitor-all-status() {
  cd $HY_MONITORING_HOME
  if [ ! -f monitor-all.ini ]; then
    echo 'Missing monitor-all.ini'
    echo 'Please run hyphae-monitor-all-init command'
    return 1
  fi
  if [ "$(ps aux | grep monitor-all-server.py | grep -v grep | wc -l | tr -d ' ')" = "0" ]; then
    echo 'Monitor ALL Server is NOT running'
    return 1
  else
    echo 'Monitor ALL Server is running on port ' $(grep port monitor-all.ini | sed -e 's/port=//' -e 's/ //g' )
  fi
  echo 'Monitor is monitoring the following URLs:'
  $(grep -E '^(url|alert)' monitor-all.ini | sed -E -e 's/^url_//' )
}

hyphae-monitor-self-update() {
  cd $HY_MONITORING_HOME
  git pull
  if [ "$(grep -Fc '.hyphae_monitoring_aliases' $HOME/.bashrc)" = '0' ]; then
    echo 'if [ -f $HOME/.hyphae_monitoring_aliases ]; then . $HOME/.hyphae_monitoring_aliases; fi;' >> $HOME/.bashrc
  fi
  cp aliases.sh $HOME/.hyphae_monitoring_aliases
  . $HOME/.hyphae_monitoring_aliases
}

hyphae-monitor-help() {
  echo 'Hyphae Monitoring'
  echo " home dir: $HY_MONITORING_HOME"
  echo ' commands available:'
  echo
  echo '   hyphae-monitor-help'
  echo '   hyphae-monitor-self-update'
  echo
  echo '   hyphae-monitor-init'
  echo '   hyphae-monitor-all-init'
  echo
  echo '   hyphae-edit-ini <file_path> <fields_comma_delim> <groupped_fields_comma delim>'
}

hyphae-help;