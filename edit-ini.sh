hyphae-edit-ini() {
  IFS=$'\n'
  fileName=$1
  fileNameNew=${fileName}.new
  echo -n > $fileNameNew

  allowedSingleKeys=$2
  allowedGrouppedKeys=$3

  for line in $(cat $fileName); do
    key=$(cut -d '=' -f 1 <<<$line | tr -d ' ')
    value=$(sed -E -e 's/^[^=]+=(.+)/\1/' <<<$line)
    echo $key = $value
    read -p ' edit line? (y) or leave _blank_ to skip: ' zzz
    if [ "$zzz" = "y" ]; then
      read -p '  new value (enter REMOVE to remove): ' newValue
      if [ "$newValue" = "REMOVE" ]; then
        echo "   Removing line..."
      elif [ "$newValue" = "" ]; then
        echo "   No changes entered, skipping..."
        echo $key=$value >> $fileNameNew
      else
        echo "   New line: " $newValue
        echo $key=$newValue >> $fileNameNew
      fi
    else
      echo $key=$value >> $fileNameNew
    fi
  done

  echo
  read -p " Add new values ($allowedSingleKeys)? (y or leave _blank_ to skip) " zzz
  while [ "$zzz" = "y" ]; do
    echo "Enter one of the keys: " $allowedSingleKeys
    read -p '  key=' newKey
    read -p '  value=' newValue
    if [ "$newKey" != "" ] && [ "$newValue" != "" ]; then
      echo $newKey=$newValue >> $fileNameNew
    else
      echo '  did not add line as new key or new value were blank'
    fi
    echo
    read -p ' Add new lines? (y or leave _blank_ to skip) ' zzz
  done

  read -p " Add new groups of values ($allowedGrouppedKeys)? (y or leave _blank_ to skip) " zzz
  oldIFS="$IFS"
  IFS=','
  while [ "$zzz" = "y" ]; do
    echo >> $fileNameNew
    echo "Enter one of the keys: " $allowedGrouppedKeys
    for gKey in $(echo "$allowedGrouppedKeys"); do
      read -p "  $gKey=" newValue
      echo $gKey=$newValue >> $fileNameNew
    done
    echo
    read -p " Add new groups of values ($allowedGrouppedKeys)? (y or leave _blank_ to skip) " zzz
  done
  IFS="$oldIFS"

  echo " Do you approve of the edits to $fileName ?"
  cat $fileNameNew
  read -p ' Yes? (y) ' zzz
  if [ "$zzz" = "y" ]; then
    mv $fileNameNew $fileName
  else
    rm $fileNameNew
  fi
}

