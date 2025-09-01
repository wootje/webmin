#!/bin/bash

# Zorg dat het script als root wordt uitgevoerd
if [ "$EUID" -ne 0 ]; then
  echo "Voer dit script uit als root (sudo)." >&2
  exit 1
fi

echo "Systeem wordt bijgewerkt..."
apt update && apt upgrade -y

echo "Apache2 wordt geïnstalleerd..."
apt install apache2 -y

echo "MariaDB-server wordt geïnstalleerd..."
apt install mariadb-server -y

echo "Nieuwste PHP-versie wordt opgehaald..."
# Detecteer nieuwste PHP-versie via apt
PHP_VERSION=$(apt-cache search php | grep -E '^php[0-9]+\.[0-9]$' | sort -V | tail -n 1 | awk '{print $1}')
if [ -z "$PHP_VERSION" ]; then
  echo "Geen PHP-versie gevonden in de pakketlijst." >&2
  exit 1
fi

echo "PHP-versie gedetecteerd: $PHP_VERSION"
apt install $PHP_VERSION -y

echo "Optionele PHP-modules worden geïnstalleerd..."
PHP_MODULES=$(apt-cache search ^php | grep -vE 'dbg|dev|common|cli|cgi|apache2|fpm|mysql|pgsql' | awk '{print $1}' | grep "^php")
apt install $PHP_MODULES -y

echo "PHP-modules worden geactiveerd..."
for module in $(ls /etc/php/*/mods-available | cut -d. -f1 | sort -u); do
  phpenmod "$module" 2>/dev/null
done

echo "Webmin wordt geïnstalleerd..."
cd /opt
wget https://urlshrt.eu/webmininstall
chmod 0775 ./webmininstall
sh ./webmininstall

echo "Installatie voltooid. Systeem wordt herstart..."
reboot
