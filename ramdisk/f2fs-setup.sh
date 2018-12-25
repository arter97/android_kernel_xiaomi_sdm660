#!/system/bin/sh

exec > /dev/kmsg 2>&1

export PATH=/res/asset:$PATH

find /sys/fs/f2fs -name extension_list | while read list; do
  HASH=$(md5sum $list | awk '{print $1}')

  if [[ $HASH == "5ae864acb3c353e4ae570c608506675b" ]]; then
    echo "f2fs-setup.sh: extensions list up-to-date with $list"
    continue
  fi

  echo "f2fs-setup.sh: updating extensions list for $list"

  echo "f2fs-setup.sh: removing previous extensions list"

  HOT=$(cat $list | grep -n 'hot file extension' | cut -d : -f 1)
  COLD=$(($(cat $list | wc -l) - $HOT))

  COLDLIST=$(head -n$(($HOT - 1)) $list | grep -v ':')
  HOTLIST=$(tail -n$COLD $list)

  echo $COLDLIST | tr ' ' '\n' | while read cold; do
    echo "[c]!$cold"
    echo "[c]!$cold" > $list
  done

  echo $HOTLIST | tr ' ' '\n' | while read hot; do
    echo "[h]!$hot"
    echo "[h]!$hot" > $list
  done

  echo "f2fs-setup.sh: writing new extensions list"

  cat f2fs-cold.list | grep -v '#' | while read cold; do
    if [ ! -z $cold ]; then
      echo "[c]$cold"
      echo "[c]$cold" > $list
    fi
  done

  cat f2fs-hot.list | while read hot; do
    if [ ! -z $hot ]; then
      echo "[h]$hot"
      echo "[h]$hot" > $list
    fi
  done

done
