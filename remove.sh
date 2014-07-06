#!/bin/bash
if [[ $EUID -ne 0 ]]; then
  echo "Questo script deve essere eseguito come root." 2>&1
  exit 1
fi

echo "Rimozione..."
rm -R "/usr/local/share/zengsm/"
rm "/usr/share/applications/zengsm.desktop"
rm "/usr/local/bin/zengsm"
echo "Fatto."