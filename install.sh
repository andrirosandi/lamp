#!/bin/bash

homedir=$(pwd)
appname=$(basename "$homedir")

rm Dockerfile
rm docker-compose.yml

read -p "Masukkan versi PHP yang akan diinstal (kosongkan untuk versi terbaru): " php_version
php_version=${php_version:-8.3.2}
read -p "Masukkan port yang akan dipublish (default: 80): " port
port=${port:-80}

read -p "Masukkan ekstensi PHP yang ingin diinstal (pisahkan dengan spasi): " php_extensions

read -p "Apakah Anda ingin menginstal Composer? (y/n, default: y): " install_composer
install_composer=${install_composer:-y}

read -p "Apakah Anda ingin menginstal Laravel? (y/n, default: y): " install_laravel
install_laravel=${install_laravel:-y}

read -p "Apakah Anda ingin menginstal MariaDB? (y/n, default: y): " install_mariadb
install_mariadb=${install_mariadb:-y}
if [[ $install_mariadb == 'y' ]]
then
    read -p "Masukkan username (default: user): " username
    username=${username:-user}
    read -p "Masukkan password (default: pass): " password
    password=${password:-pass}
    read -p "Masukkan root password (default: root): " root_password
    root_password=${root_password:-root}
    read -p "Masukkan port yang akan dipublish (default: 3306): " db_port
    db_port=${db_port:-3306}
fi

read -p "Apakah Anda ingin menginstal phpMyAdmin? (y/n, default: y): " install_phpmyadmin
install_phpmyadmin=${install_phpmyadmin:-y}
if [[ $install_phpmyadmin == 'y' ]]
then
    read -p "Masukkan username (default: $username): " pma_username
    pma_username=${pma_username:-$username}
    read -p "Masukkan password (default: $password): " pma_password
    pma_password=${pma_password:-$password}
    read -p "Masukkan port yang akan dipublish (default: 8080): " pma_port
    pma_port=${pma_port:-8080}
fi

read -p "Masukkan nama network yang ingin digunakan (kosongkan untuk menggunakan nama aplikasi): " network
network=${network:-$appname}
if [[ -n $network && $network != $appname ]]
then
    read -p "Apakah network tersebut eksternal? (y/n, default: n): " network_external
else
    network_external=n
fi

cat << EOF > Dockerfile
FROM php:$php_version-apache

WORKDIR /var/www/html/
EOF

if [[ -n $php_extensions ]]
then
    cat << EOF >> Dockerfile
RUN docker-php-ext-install $php_extensions
EOF
fi

if [[ $install_composer == 'y' ]]
then
    cat << EOF >> Dockerfile
RUN apt-get update && apt-get install -y \\
        curl git unzip
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
EOF
fi

if [[ $install_laravel == 'y' ]]
then
    cat << EOF >> Dockerfile
RUN composer global require laravel/installer
EOF
fi

cat << EOF > docker-compose.yml
version: '3.8'
services:
  ${appname}_web:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: ${appname}_web
    ports:
      - "$port:80"
    volumes:
      - ./phpwww:/var/www/html
    networks:
      - $network
EOF

if [[ $install_mariadb == 'y' ]]
then
    cat << EOF >> docker-compose.yml
  ${appname}_db:
    image: mariadb
    container_name: ${appname}_db
    environment:
      MYSQL_DATABASE: $appname
      MYSQL_USER: $username
      MYSQL_PASSWORD: $password
      MYSQL_ROOT_PASSWORD: $root_password
    ports:
      - "$db_port:3306"
    volumes:
      - ./database:/var/lib/mysql
    networks:
      - $network
EOF
fi

if [[ $install_phpmyadmin == 'y' ]]
then
    cat << EOF >> docker-compose.yml
  ${appname}_phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: ${appname}_phpmyadmin
    environment:
      
      PMA_HOST: ${appname}_db
      
    ports:
      - "$pma_port:80"
    networks:
      - $network
    depends_on:
      - ${appname}_db
EOF
fi

cat << EOF >> docker-compose.yml
networks:
  $network:
    external: $([[ $network_external == 'y' ]] && echo true || echo false)
    

EOF

if [[ $(docker ps -a --format '{{.Names}}' | grep "^${appname}_web$") ]]
then
    sed -i "s/container_name: ${appname}_web/container_name: ${appname}_web-1/g" docker-compose.yml
fi
if [[ $install_mariadb == 'y' && $(docker ps -a --format '{{.Names}}' | grep "^${appname}_db$") ]]
then
    sed -i "s/container_name: ${appname}_db/container_name: ${appname}_db-1/g" docker-compose.yml
fi
if [[ $install_phpmyadmin == 'y' && $(docker ps -a --format '{{.Names}}' | grep "^${appname}_phpmyadmin$") ]]
then
    sed -i "s/container_name: ${appname}_phpmyadmin/container_name: ${appname}_phpmyadmin-1/g" docker-compose.yml
fi

echo "Berikut adalah konfigurasi yang telah Anda buat:"
echo "Nama aplikasi: $appname"
echo "Versi PHP: $php_version"
echo "Port web: $port"
echo "Install Composer: $install_composer"
echo "Install Laravel: $install_laravel"
if [[ $install_mariadb == 'y' ]]
then
    echo "Install MariaDB: Ya"
    echo "Username MariaDB: $username"
    echo "Password MariaDB: $password"
    echo "Root password MariaDB: $root_password"
    echo "Port MariaDB: $db_port"
else
    echo "Install MariaDB: Tidak"
fi
if [[ $install_phpmyadmin == 'y' ]]
then
    echo "Install phpMyAdmin: Ya"
    echo "Username phpMyAdmin: $pma_username"
    echo "Password phpMyAdmin: $pma_password"
    echo "Port phpMyAdmin: $pma_port"
else
    echo "Install phpMyAdmin: Tidak"
fi
echo "Ekstensi PHP: $php_extensions"
echo "Network: $network"
echo "Network eksternal: $network_external"

read -p "Dockerfile dan docker-compose.yml sudah terbentuk, apakah anda ingin melanjutkan dengan menjalankan docker-compose up -d ?  (y/n, default: y): " confirm
confirm=${confirm:-y}
if [[ $confirm == 'y' ]]
then
    docker-compose up -d
else
    echo "Anda bisa merubah file Dockerfile dan docker-compose.yml dan jalankan docker-compose up -d manual."
fi
