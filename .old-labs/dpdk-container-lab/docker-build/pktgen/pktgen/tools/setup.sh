#!/bin/bash

# Use 'sudo -E ./setup.sh' to include environment variables
Sudo="sudo -E"

if [ -z ${RTE_SDK} ] ; then
	echo "*** RTE_SDK is not set, did you forget to do 'sudo -E ./setup.sh'"
	exit 1
fi
sdk=${RTE_SDK}

if [ -z ${RTE_TARGET} ]; then
	echo "*** RTE_TARGET is not set, did you forget to do 'sudo -E ./setup.sh'"
	exit 1
else
	target=${RTE_TARGET}
fi

echo "Using directory: "$sdk"/"$target

function nr_hugepages_fn {
    ${Sudo} echo /sys/devices/system/node/node${1}/hugepages/hugepages-2048kB/nr_hugepages
}

function num_cpu_sockets {
    local sockets=0
    while [ -f $(nr_hugepages_fn $sockets) ]; do
		sockets=$(( $sockets + 1 ))
    done
    ${Sudo} echo $sockets
    if [ $sockets -eq 0 ]; then
	echo "Huge TLB support not found make sure you are using a kernel >= 2.6.34" >&2
	exit 1
    fi
}

${Sudo} rm -fr /mnt/huge/*

NR_HUGEPAGES=$(( `sysctl -n vm.nr_hugepages` / $(num_cpu_sockets) ))
echo "Setup "$(num_cpu_sockets)" socket(s) with "$NR_HUGEPAGES" pages."
for socket in $(seq 0 $(( $(num_cpu_sockets) - 1 )) ); do
    ${Sudo} echo $NR_HUGEPAGES > $(nr_hugepages_fn $socket)
done

grep -i huge /proc/meminfo
${Sudo} modprobe uio
echo "trying to remove old igb_uio module and may get an error message, ignore it"
${Sudo} rmmod igb_uio
${Sudo} insmod $sdk/$target/kmod/igb_uio.ko
#echo "trying to remove old rte_kni module and may get an error message, ignore it"
#${Sudo} rmmod rte_kni
#${Sudo} insmod $sdk/$target/kmod/rte_kni.ko "lo_mode=lo_mode_ring"

name=`uname -n`
if [ $name == "rkwiles-DESK1.intel.com" ]; then
	${Sudo} -E $sdk/tools/dpdk-devbind.py -b igb_uio 04:00.0 04:00.1 04:00.2 04:00.3 81:00.0 81:00.1 81:00.2 81:00.3 82:00.0 83:00.0
fi
$sdk/tools/dpdk-devbind.py --status
