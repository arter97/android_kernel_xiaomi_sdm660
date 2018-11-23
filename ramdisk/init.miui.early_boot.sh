#!/system/bin/sh

export PATH=/system/bin:/system/xbin

configure_dex2oat_threads_dlmalloc()
{
        if [ -f /dev/cpuset/background/tasks ]; then
            if [ -f /dev/cpuset/background/cpus ]; then
                cpus=`cat /dev/cpuset/background/cpus`
                count=`get_cpu_count $cpus`
                if [ $count -gt 0 ]; then
                    current=`getprop dalvik.vm.bg-dex2oat-threads`
                    if [ -z "$current" ]; then
                        setprop dalvik.vm.bg-dex2oat-threads $count
                    fi
                fi
            fi
        fi

        if [ -f /sys/devices/system/cpu/present ]; then
            cpus=`cat /sys/devices/system/cpu/present`
            count=`get_cpu_count $cpus`

            current=`getprop dalvik.vm.dex2oat-threads`
            if [ -z "$current" ]; then
                if [ $count -eq 8 ]; then
                    setprop dalvik.vm.dex2oat-threads 4
                elif [ $count -eq 6 ]; then
                    setprop dalvik.vm.dex2oat-threads 2
                fi
            fi

            current=`getprop dalvik.vm.boot-dex2oat-threads`
            if [ -z "$current" ]; then
                if [ $count -eq 8 ]; then
                    setprop dalvik.vm.boot-dex2oat-threads 4
                elif [ $count -eq 6 ]; then
                    setprop dalvik.vm.boot-dex2oat-threads 2
                fi
            fi
        fi
}

get_cpu_count()
{
        #Usage get_cpu_count <cpulist>
        cpu_num=0
        if [ ! $(echo $1 | grep -e [a-z]) ]; then
            for no in `echo "$1" | sed 's/,/\n/g'`
            do
                case "$no" in
                    [0-9])
                        cpu_num=`expr $cpu_num \+ 1`
                        ;;
                    [0-9]-[0-9])
                        last=`expr ${no:2}`
                        first=`expr ${no:0:1}`
                        if [ $(echo $last | grep -e [0-9]) ]; then
                            if [ $(echo $first | grep -e [0-9]) ]; then
                                if [ $last -gt $first ]; then
                                    cpu_num=`expr $cpu_num \+ $last - $first \+ 1`
                                fi
                            fi
                        fi
                        ;;
                esac
            done
        fi
        echo $cpu_num
}


configure_dex2oat_threads_jemalloc()
{
        if [ -f /dev/cpuset/background/tasks ]; then
            if [ -f /dev/cpuset/background/cpus ]; then
                cpus=`cat /dev/cpuset/background/cpus`
                count=`get_cpu_count $cpus`
                if [ $count -gt 0 ]; then
                    current=`getprop dalvik.vm.bg-dex2oat-threads`
                    if [ -z "$current" ]; then
                        setprop dalvik.vm.bg-dex2oat-threads $count
                    fi
                fi
            fi
        fi

        if [ -f /sys/devices/system/cpu/present ]; then
            cpus=`cat /sys/devices/system/cpu/present`
            count=`get_cpu_count $cpus`

            current=`getprop dalvik.vm.dex2oat-threads`
            if [ -z "$current" ]; then
                if [ $count -eq 8 ]; then
                    setprop dalvik.vm.dex2oat-threads 6
                elif [ $count -eq 4 ]; then
                    setprop dalvik.vm.dex2oat-threads 3
                fi
            fi
        fi
}

sdk=`getprop ro.build.version.sdk`

malloc=`getprop ro.malloc.impl`

case "$sdk" in
    "23" | "24" | "25")
        case "$malloc" in
            "dlmalloc")
                 configure_dex2oat_threads_dlmalloc
                 ;;
            "jemalloc")
                 configure_dex2oat_threads_jemalloc
                 ;;
        esac
esac
