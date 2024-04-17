#! /bin/bash
echo "------------------------------------------------------------------------------"
echo "Yeni disk taraniyor..."
ls /sys/class/scsi_host/ | while read host ; do echo "- - -" > /sys/class/scsi_host/$host/scan ; done
clear

filesystem_type=$(df -T $selectedDevMapperName | awk '$1 ~ /^\/dev\/mapper\// {print $2}')

# Choose the appropriate command based on the filesystem type
if [ "$filesystem_type" == "xfs" ]; then
    resize_command="xfs_growfs"
elif [ "$filesystem_type" == "ext4" ]; then
    resize_command="resize2fs"
else
    echo "Unsupported filesystem type: $filesystem_type"
    exit 1
fi


########################################## STEP #1 - Get Avaiable disks to extend LVM based that disks are named /dev/sd* ##########################################

disks_var=$(fdisk -l | grep '^Disk /dev/sd')
SAVEIFS=$IFS   # Save current IFS
IFS=$'\n'      # Change IFS to new line
disks=($disks_var) # split to array $names
IFS=$SAVEIFS   # Restore IFS

echo -n "Yeni Ekledigin Diski Sec:"
echo

for (( i=0; i<${#disks[@]}; i++ ))
do
    echo "$i: ${disks[$i]}"
done

read -r disk_option

selectedDisk=$(echo ${disks[$disk_option]} | cut -d ":" -f1)
selectedDisk=$(cut -d " " -f2 <<< "$selectedDisk")

########################################## STEP #2 + #3 - Get LV Name + LV Path ##########################################

lvName_var=$(lvdisplay | grep 'LV Name')
SAVEIFS=$IFS      # Save current IFS
IFS=$'\n'         # Change IFS to new line
lvs=($lvName_var) # split to array $names
IFS=$SAVEIFS      # Restore IFS


echo -n "Genisletilecek Logic Volume sec:"
echo

for (( i=0; i<${#lvs[@]}; i++ ))
do
    echo "$i: ${lvs[$i]}"
done

read -r lvName_option
selectedLVName=$(echo ${lvs[$lvName_option]} | cut -d ":" -f1)
selectedLVName=$(cut -d " " -f3 <<< "$selectedLVName")
lvPath_var=$(lvdisplay | grep "$selectedLVName")
selectedLVPath=$(echo $lvPath_var | cut -d " " -f3)
lvPath_var=$(lvdisplay | grep "$selectedLVName")
selectedLVPath=$(echo $lvPath_var | cut -d " " -f3)


########################################## STEP #4 - Get Device Mapper Path ##########################################

devmapper_var=$(fdisk -l | grep '^Disk /dev/m')
SAVEIFS=$IFS          # Save current IFS
IFS=$'\n'             # Change IFS to new line
dmp=($devmapper_var)  # split to array $names
IFS=$SAVEIFS          # Restore IFS

echo -n "Genisletilecek Device Mapper Sec:"
echo
for (( i=0; i<${#dmp[@]}; i++ ))
do
echo "$i: ${dmp[$i]}"
done

read -r dmp_option

selectedDEVMAPPER=$(echo ${dmp[$dmp_option]} | cut -d ":" -f1)

echo "1 selectedDEVMAPPER: $selectedDEVMAPPER"

selectedDevMapperName=$(cut -d " " -f2 <<< "$selectedDEVMAPPER")

echo "2 selectedDevMapperName: |$selectedDevMapperName|"



########################################## STEP #5 - Get Avaiable Volume Groups ##########################################

vg_var=$(vgdisplay | grep 'VG Name')


SAVEIFS=$IFS   # Save current IFS
IFS=$'\n'      # Change IFS to new line
vgs=($vg_var)  # split to array $names
IFS=$SAVEIFS   # Restore IFS


echo -n "Genisletilecek Volume Group sec"
echo

for (( i=0; i<${#vgs[@]}; i++ ))
do
    echo "$i: ${vgs[$i]}"
done

read -r vg_option

selectedVG=$(echo ${vgs[$vg_option]} | cut -d ":" -f2)
selectedVG=$(cut -d " " -f3 <<< "$selectedVG")

########################################## COMMANDS OUTPUT ##########################################
echo "---Disk Genisletme Islemi Basladi---"
pvcreate $selectedDisk
sleep 2
vgextend $selectedVG $selectedDisk
sleep 2
lvm lvextend -l +100%FREE $selectedDevMapperName
sleep 2
$resize_command $selectedDevMapperName
sleep 2
echo "--Disk Boyutunu Kontrol Et--"
df -h
