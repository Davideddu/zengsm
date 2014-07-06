#!/bin/bash
if [[ $EUID -ne 0 ]]; then
  echo "Questo script deve essere eseguito come root." 2>&1
  exit 1
fi

echo "Installazione..."
mkdir "/usr/local/share/zengsm/"
cp "detailed_info" "/usr/local/share/zengsm/"
cp "get_info" "/usr/local/share/zengsm/"
cp "list_modems" "/usr/local/share/zengsm/"
cp "ussd" "/usr/local/share/zengsm/"
cp "operators" "/usr/local/share/zengsm/"
cp "get_operator" "/usr/local/share/zengsm/"
cp "get_reg_status" "/usr/local/share/zengsm/"
cp "disable" "/usr/local/share/zengsm/"
cp "scan" "/usr/local/share/zengsm/"
cp "enable" "/usr/local/share/zengsm/"
cp "disconnect" "/usr/local/share/zengsm/"
cp "sms_send" "/usr/local/share/zengsm/"
cp "zengsm" "/usr/local/share/zengsm/"
cp "kgsm" "/usr/local/share/zengsm/"
cp "zengsm.desktop" "/usr/share/applications/"
cp "kgsm.desktop" "/usr/share/applications/"
chmod +x /usr/local/share/zengsm/*
ln -s "/usr/local/share/zengsm/zengsm" "/usr/local/bin/zengsm"
ln -s "/usr/local/share/zengsm/kgsm" "/usr/local/bin/kgsm"
echo "Fatto. Puoi ora eseguire \"zengsm\"/\"kgsm\" o cercare ZenGSM/KGSM tra le applicazioni."