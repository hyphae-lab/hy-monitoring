if [ "$HY_MONITORING_HOME" = "" ]; then
  if [ "$(grep -Fc '.hyphae_monitoring_aliases' $HOME/.bashrc)" = '0' ]; then
    echo 'if [ -f $HOME/.hyphae_monitoring_aliases ]; then . $HOME/.hyphae_monitoring_aliases; fi;' >> $HOME/.bashrc
  fi

  if [ ! -f $HOME/.hyphae_monitoring_home ]; then
    read -p 'Enter Hyphae Monitoring HOME DIR: ' HY_MONITORING_HOME
    echo $HY_MONITORING_HOME > $HOME/.hyphae_monitoring_home
  fi

  HY_MONITORING_HOME="$(cat $HOME/.hyphae_monitoring_home | xargs echo -n)"
  export HY_MONITORING_HOME;
fi

. $HY_MONITORING_HOME/edit-ini.sh

hyphae-monitor-init() {
  if [ "$1" = '' ]; then
    echo ' When initializing choose "single" or "all" as first arg'
    return 1
  fi

  cd $HY_MONITORING_HOME

  scriptFilename=''
  iniFilename=''
  if [ "$1" = 'all' ]; then
    iniFilename='monitor-all.ini'
    hyphae-edit-ini $iniFilename 'port,from_email,secret' 'url,url_id,url_name,url_secret,alert_email'
    scriptFilename='monitor-all-server.py'
  else
    iniFilename='monitor.ini'
    hyphae-edit-ini $iniFilename 'port,secret' 'cmd,cmd_label,cmd_expected_ouput'
    scriptFilename='monitor-server.py'
  fi

  hyphae-monitor-start $1 restart;
}

__hyphae-monitor-helper-check-ps() {
  monitorProcess=$(ps aux | grep $1 | grep -v grep | tr -d '\n' )
  if [ "$monitorProcess" != "" ]; then
    sed -E -e 's/^[a-z]+ +([0-9]+).+/\1/' <<<$monitorProcess
    return 0
  else
    echo "no $1 running"
    return 1
  fi
}
__hyphae-monitor-helper-get-port() {
  grep -oE '^ *port=.+' $1 | sed 's/port=//'
  if [ "$?" = "1" ]; then
    echo 'no port defined'
  fi
}


# <cmd> all|single restart?
hyphae-monitor-start() {
  if [ "$1" = '' ]; then
    echo '  choose "single" or "all" as first arg'
    return 1
  fi

  cd $HY_MONITORING_HOME

  scriptFilename=''
  iniFilename=''
  if [ "$1" = 'all' ]; then
    iniFilename='monitor-all.ini'
    scriptFilename='monitor-all-server.py'
  else
    iniFilename='monitor.ini'
    scriptFilename='monitor-server.py'
  fi

  pid=$(__hyphae-monitor-helper-check-ps scriptFilename);

  if [ "$?" = "0" ]; then
    if [ "$2" = 'restart' ]; then
      kill $pid
    fi
    echo 'Monitor Server already running on port ' $(__hyphae-monitor-helper-get-port $iniFilename)
    return 1
  else
    echo 'Monitor Server is starting on port ' $(__hyphae-monitor-helper-get-port $iniFilename)
    sudo nohup python3 $scriptFilename 2>$HY_MONITORING_HOME/monitor.error 1>$HY_MONITORING_HOME/monitor.log &
    echo ' ...started'
  fi
}

hyphae-monitor-stop() {
  if [ "$1" = '' ]; then
    echo ' choose "single" or "all" as first arg'
    return 1
  fi

  cd $HY_MONITORING_HOME

  scriptFilename=''
  iniFilename=''
  if [ "$1" = 'all' ]; then
    iniFilename='monitor-all.ini'
    scriptFilename='monitor-all-server.py'
  else
    iniFilename='monitor.ini'
    scriptFilename='monitor-server.py'
  fi

  pid=$(__hyphae-monitor-helper-check-ps $scriptFilename)

  if [ "$?" = "0" ]; then
    echo " Stopping monitor (pid:$pid)"
    return 1
  else
    echo 'Monitor Server is not running'
  fi
}

hyphae-monitor-status() {
  if [ "$1" = '' ]; then
    echo '  choose "single" or "all" as first arg'
    return 1
  fi

  scriptFilename=''
  iniFilename=''
  if [ "$1" = 'all' ]; then
    iniFilename='monitor-all.ini'
    scriptFilename='monitor-all-server.py'
  else
    iniFilename='monitor.ini'
    scriptFilename='monitor-server.py'
  fi

  cd $HY_MONITORING_HOME
  if [ ! -f $iniFilename ]; then
    echo 'Missing ' $iniFilename
    echo "Please run 'hyphae-monitor-init $1' command"
    return 1
  fi
  
  __hyphae-monitor-helper-check-ps $scriptFilename;
  
  if [ "$?" = "1" ]; then
    echo 'Monitor Server is NOT running'
    return 1
  else
    echo 'Monitor Server is running on port ' $(__hyphae-monitor-helper-get-port $iniFilename)
  fi
  
  if [ "$1" = 'all' ]; then
    echo 'Monitor is monitoring the following URLs:'
    grep -E '^(url|alert)' monitor-all.ini | sed -E -e 's/^url_//'
  else
    echo 'Monitor is check the following commands, with label and expected output:'
    grep '^cmd' monitor.ini | sed -E -e 's/^cmd_//'
  fi
  
  return 0
}

hyphae-monitor-self-update() {
  cd $HY_MONITORING_HOME
  git pull
  cp aliases.sh $HOME/.hyphae_monitoring_aliases
  . $HOME/.hyphae_monitoring_aliases
}

hyphae-monitor-help() {
  echo 'Hyphae Monitoring'
  echo " home dir: $HY_MONITORING_HOME"
  echo ' commands available:'
  echo
  echo '   hyphae-monitor-help'
  echo
  echo '   hyphae-monitor-self-update'
  echo
  echo '   hyphae-monitor-init [all|single]'
  echo '   hyphae-monitor-status [all|single]'
  echo '   hyphae-monitor-start [all|single]'
  echo '   hyphae-monitor-stop [all|single]'
  echo
  echo '   hyphae-edit-ini <file_path> <fields_comma_delim> <groupped_fields_comma delim>'
}

hyphae-monitor-help;