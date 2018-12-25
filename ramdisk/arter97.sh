#!/system/bin/sh

exec > /dev/kmsg 2>&1

export PATH=/res/asset:$PATH

cd /link
find . -type f -exec mount --bind {} /{} \;
find . -type l -exec mount --bind {} /{} \;

touch /.bind

while ! pgrep -f com.android.systemui > /dev/null; do
  sleep 1
done

/init.qcom.post_boot.sh

while pgrep -f bootanimation > /dev/null; do
  sleep 1
done

# Run fstrim
fstrim -v /data
