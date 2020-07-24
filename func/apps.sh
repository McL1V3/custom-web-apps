#!/usr/bin/env bash

# Verifica se o public_html é um diretório vazio
#
# Também é considerado vazio os diretórios que possuem apenas os arquivos padrão gerados pelo vesta
#
# Retorna "1" se o public_html estiver vazio
empty() {
    local web_path="$1"

    # Verifica se existe algum sistema instalado no diretório público caso ele exista e não esteja vazio
    if [[ -d "$web_path/public_html" && "$(ls -A "$web_path/public_html")" ]]; then
        # Lista de arquivos que não são considerados para identificar um sistema
        aceitos=( 'index.html' 'robots.txt' )
        for file_path in "$web_path/public_html/"*; do
            file=$(basename -- "$file_path")

            invalido="1"
            for item in "${aceitos[@]}"; do
                if [[ "$file" == "$item" ]]; then
                    invalido=""
                fi
            done

            # Não é um arquivo permitido para a instalação
            if [[ "$invalido" ]]; then
                return
            fi
        done
    fi

    echo "1"
}

check_web_dir() {
    local user_name="$1"
    local web_domain="$2"

    if [[ ! "$user_name" || ! "$web_domain" ]]; then
        echo "Invalid arguments"
        return
    fi

    web_path="/home/$user_name/web/$web_domain";

    # Check if web domain exist
    if [[ ! -d "$web_path" ]]; then
        echo "El directorio web no existe."
        return
    fi

    # Check if public_html is empty
    if [[ "$(empty "$web_path")" != "1" ]]; then
        echo "public_html no esta vacio."
        echo "Es necesario que elimines los datos manualmente para no perder los datos."
        return
    fi

    if [[ ! -d "$web_path/public_html" ]]; then
        mkdir -p "$web_path/public_html"
        chown "$user_name:$user_name" "$web_path/public_html"
    fi

    echo "1"
}

wordpress() {
    local user_name="$1"
    local web_domain="$2"

    web_path="/home/$user_name/web/$web_domain";

    check_dir="$(check_web_dir "$user_name" "$web_domain")"
    if [[ "$check_dir" != "1" ]]; then
        echo "$check_dir"
        return
    fi

    echo "== Descargando Wordpress..."
    curl -L -J  'https://wordpress.org/latest.zip' -o "/home/$user_name/tmp/wordpress.zip" 2>&1

    echo -e "\n== Extrayendo archivos..."
    unzip "/home/$user_name/tmp/wordpress.zip" -d "/home/$user_name/tmp"
    rm -f "/home/$user_name/tmp/wordpress.zip"

    # Change owner
    chown "$user_name:$user_name" -R "/home/$user_name/tmp/wordpress"
    # Clean up vesta initial files
    rm -rf "$web_path/public_html/index.html" "$web_path/public_html/robots.txt"
    # Move files to the public_html
    mv "/home/$user_name/tmp/wordpress/"* "$web_path/public_html"
    rm -rf "/home/$user_name/tmp/wordpress"

    echo -e "\nInstalacion Completada"
}
wordpress_with_database(){
    local user="$1"
    local domain="$2"
    local email="mclive.case@gmail.com"
    local WORKINGDIR="/home/$user/web/$domain/public_html"
    local DBUSERSUFB="wp"
    local VESTA='/usr/local/vesta'

    if [ ! -d "/home/$user" ]; then
        echo "User doesn't exist";
        return
    fi

    if [ ! -d "/home/$user/web/$domain/public_html" ]; then
        echo "Domain doesn't exist";
        return
    fi
    rm -rf $WORKINGDIR/*

    i=0;
    while [ $i -lt 99 ]
    do
    i=$((i+1));
     DBUSERSUF="${DBUSERSUFB}${i}";
     DBUSER=$user\_$DBUSERSUF;
    if [ ! -d "/var/lib/mysql/$DBUSER" ]; then
    break;
    fi
    done
    
    local PASSWDDB=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)

    $VESTA/bin/v-add-database $user $DBUSERSUF $DBUSERSUF $PASSWDDB mysql

    echo "Probando a este punto $user $DBUSERSUF $DBUSERSUF $PASSWDDB mysql";
    cd /home/$user

    rm -rf /home/$user/wp
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    sudo mv wp-cli.phar wp

    cd /home/$user/web/$domain/public_html

    sudo -H -u$user php -d disable_functions="" /home/$user/wp core download
    sudo -H -u$user php -d disable_functions="" /home/$user/wp core config --dbname=$DBUSER --dbuser=$DBUSER --dbpass=$PASSWDDB

    local password=$(LC_CTYPE=C tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+= < /dev/urandom | head -c 12)

    sudo -H -u$user php -d disable_functions="" /home/$user/wp core install --url="$domain" --title="$domain" --admin_user="admin" --admin_password="$password" --admin_email="$email" --path=$WORKINGDIR

    #FIX za https://github.com/wp-cli/wp-cli/issues/2632

    mysql -u$DBUSER -p$PASSWDDB -e "USE $DBUSER; update wp_options set option_value = 'https://$domain' where option_name = 'siteurl'; update wp_options set option_value = 'https://$domain' where option_name = 'home';"

    # clear

    echo "================================================================="
    echo "Installation is complete. Your username/password is listed below."
    echo ""
    echo "Site: https://$domain/"
    echo ""
    echo "Login: https://$domain/wp-admin/"
    echo "Username: admin"
    echo "Password: $password"
    echo ""
    echo "================================================================="

    chown -R $user:$user $WORKINGDIR

    rm -rf /home/$user/wp

    echo -e "create_wp: Done."
}

moodle() {
    local user_name="$1"
    local web_domain="$2"

    web_path="/home/$user_name/web/$web_domain";

    check_dir="$(check_web_dir "$user_name" "$web_domain")"
    if [[ "$check_dir" != "1" ]]; then
        echo "$check_dir"
        return
    fi

    echo "== Downloading Moodle..."
    curl -L -J  'https://download.moodle.org/stable38/moodle-latest-38.zip' -o "/home/$user_name/tmp/moodle.zip" 2>&1

    echo -e "\n== Extract files..."
    unzip "/home/$user_name/tmp/moodle.zip" -d "/home/$user_name/tmp"
    rm -f "/home/$user_name/tmp/moodle.zip"

    # Change owner
    chown "$user_name:$user_name" -R "/home/$user_name/tmp/moodle"
    # Clean up vesta initial files
    rm -rf "$web_path/public_html/index.html" "$web_path/public_html/robots.txt"
    # Move files to the public_html
    mv "/home/$user_name/tmp/moodle/"* "$web_path/public_html"
    mv "/home/$user_name/tmp/moodle/".* "$web_path/public_html"
    rm -rf "/home/$user_name/tmp/moodle"

    echo -e "\nInstallation completed"
}





