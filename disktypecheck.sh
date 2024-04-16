#!/bin/bash

df_output=$(df -h)

if [[ $df_output =~ /dev/mapper ]]; then
    echo "$df_output"
    echo "--LVM DİSK TESPİT EDİLDİ --"
    echo "LVM icin sanallastirma platformu uzerinden "new device" olarak disk eklemen gerek. eklediysen E tusuna basarak devam edebilir yada hemen ekleyerek ardıdnan E tusuna baa
sarak devam edebilirsin. iptal icin herhangi bir tusa bas."
    read -n 1 input
    if [[ $input == 'e' ]]; then
        echo -n
        ./lvmdiskextend.sh
    else
        echo "byeee"
    fi
else
    echo "$df_output"
    echo "--STANDART PARTITION TESPIT EDILDI--"
        echo -n
        ./stddiskextend.sh
fi
