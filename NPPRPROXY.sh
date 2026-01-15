#!/bin/bash

# ANSI цвета и стили
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Определение пакетного менеджера (dnf для CentOS 9+, yum для старых)
if command -v dnf >/dev/null 2>&1; then
    PKG_MANAGER="dnf"
else
    PKG_MANAGER="yum"
fi

# Функция для отображения шапки
show_header() {
    clear # Очистка экрана
    echo -e "${RED}"
    echo "███╗   ██╗██████╗ ██████╗ ██████╗ ████████╗███████╗ █████╗ ███╗   ███╗"
    echo "████╗  ██║██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██╔══██╗████╗ ████║"
    echo "██╔██╗ ██║██████╔╝██████╔╝██████╔╝   ██║   █████╗  ███████║██╔████╔██║"
    echo "██║╚██╗██║██╔═══╝ ██╔═══╝ ██╔══██╗   ██║   ██╔══╝  ██╔══██║██║╚██╔╝██║"
    echo "██║ ╚████║██║     ██║     ██║  ██║   ██║   ███████╗██║  ██║██║ ╚═╝ ██║"
    echo "╚═╝  ╚═══╝╚═╝     ╚═╝     ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝"
    echo -e "${NC}"
    echo -e "${GREEN}------------------------------------------------"
    echo "Наши контакты:"
    echo "Наш ТГ — https://t.me/nppr_team"
    echo "Наш ВК — https://vk.com/npprteam"
    echo "ТГ нашего магазина — https://t.me/npprteamshop"
    echo "Магазин аккаунтов, бизнес-менеджеров ФБ и Google — https://npprteam.shop"
    echo "Наш антидетект-браузер Antik Browser — https://antik-browser.com/"
    echo -e "------------------------------------------------${NC}"
}

# Вызов функции для отображения шапки
show_header

show_infinite_progress_bar() {
    local i=0
    local sp='/-\|'
    while true; do
        echo -ne "${RED}${sp:i++%${#sp}:1} ${NC}\b\b"
        sleep 0.2
    done
}

start_progress_bar() {
    local op=$1
    echo -ne "${GREEN}${op}... ${NC}"
    show_infinite_progress_bar &
    progress_bar_pid=$!
}

stop_progress_bar() {
    kill $progress_bar_pid
    wait $progress_bar_pid 2>/dev/null
    echo -e "${GREEN}Done!${NC}"
}

# Массив для генерации частей IPv6 адреса
array=(0 1 2 3 4 5 6 7 8 9 a b c d e f)

# Получение основного интерфейса
main_interface=$(ip -6 route show default | awk '{print $5}' | head -n1)
if [ -z "$main_interface" ]; then
    main_interface=$(ip route show default | awk '{print $5}' | head -n1)
fi

random() {
    tr </dev/urandom -dc A-Za-z0-9 | head -c5
}

gen_segment() {
    echo "${array[$RANDOM % 16]}${array[$RANDOM % 16]}${array[$RANDOM % 16]}${array[$RANDOM % 16]}"
}

gen64() { echo "$1:$(gen_segment):$(gen_segment):$(gen_segment):$(gen_segment)"; }

auto_detect_ipv6_info() {
    local ipv6_address=$(ip -6 addr show dev "$main_interface" | grep 'inet6' | grep -v 'fe80' | awk '{print $2}' | head -n1)
    if [ -z "$ipv6_address" ]; then return 1; fi
    
    local ipv6_prefix=$(echo "$ipv6_address" | cut -d: -f1-4)
    local ipv6_subnet_size=$(echo "$ipv6_address" | cut -d/ -f2)
    echo "$ipv6_prefix $ipv6_subnet_size"
}

install_3proxy() {
    start_progress_bar "Building 3proxy 0.9.4"
    mkdir -p /3proxy && cd /3proxy
    URL="https://github.com/z3APA3A/3proxy/archive/0.9.4.tar.gz"
    wget -qO- $URL | tar xzf -
    cd 3proxy-0.9.4
    make -f Makefile.Linux >/dev/null 2>&1
    mkdir -p /usr/local/etc/3proxy/{bin,logs,stat}
    cp bin/3proxy /usr/local/etc/3proxy/bin/
    
    # Регуляция лимитов
    echo "* hard nofile 999999" >> /etc/security/limits.conf
    echo "* soft nofile 999999" >> /etc/security/limits.conf
    
    # Системные настройки
    cat >> /etc/sysctl.conf <<EOF
net.ipv4.ip_nonlocal_bind = 1
net.ipv6.ip_nonlocal_bind = 1
net.ipv6.conf.all.proxy_ndp = 1
net.ipv6.conf.all.forwarding = 1
net.ipv6.conf.all.mtu = 1280
EOF
    sysctl -p >/dev/null 2>&1
    systemctl stop firewalld >/dev/null 2>&1
    systemctl disable firewalld >/dev/null 2>&1
    stop_progress_bar
}

gen_3proxy() {
    cat <<EOF
daemon
nserver 8.8.8.8
nserver 1.1.1.1
nscache 65536
timeouts 1 5 30 60 180 1800 15 60
users $USERNAME:CL:$PASSWORD

auth strong
allow $USERNAME
$(awk -F "/" '{print "proxy -64 -n -m1460 -a -p" $4 " -i" $3 " -e" $5}' ${WORKDATA})
$(awk -F "/" '{print "socks -64 -n -m1460 -a -p" $4+20000 " -i" $3 " -e" $5}' ${WORKDATA})
EOF
}

# Begin
echo -e "${GREEN}Starting installation...${NC}"
start_progress_bar "Updating system and installing tools"
sudo $PKG_MANAGER update -y >/dev/null 2>&1
sudo $PKG_MANAGER install -y gcc make wget tar gzip zip jq net-tools >/dev/null 2>&1
stop_progress_bar

install_3proxy

WORKDIR="/home/proxy-installer"
BINDIR="/usr/local/etc/3proxy/bin"
WORKDATA="${WORKDIR}/data.txt"
mkdir -p $WORKDIR && cd $WORKDIR

ipv6_info=$(auto_detect_ipv6_info)
if [ $? -eq 0 ]; then
    read IP6_PREFIX IP6_SIZE <<< "$ipv6_info"
else
    echo -e "${RED}Error: Could not detect IPv6 prefix.${NC}"
    exit 1
fi

IP4=$(curl -4 -s icanhazip.com)
USERNAME=$(random)
PASSWORD=$(random)

echo -ne "How many proxies? (default 100): "
read COUNT
COUNT=${COUNT:-100}
FIRST_PORT=10000

echo "Generating data..."
cat > $WORKDATA <<EOF
$(for i in $(seq 1 $COUNT); do
    echo "${USERNAME}/${PASSWORD}/${IP4}/$((FIRST_PORT + i))/${IP6_PREFIX}::$(printf '%x' $i)"
done)
EOF

# Скрипт поднятия IP (сохраняем в bin для надежности)
cat > ${BINDIR}/up_ips.sh <<EOF
#!/bin/bash
while read line; do
  ip=\$(echo \$line | cut -d'/' -f5)
  ip -6 addr add \$ip/64 dev $main_interface >/dev/null 2>&1 || true
done < ${WORKDATA}
exit 0
EOF
chmod +x ${BINDIR}/up_ips.sh
sudo ${BINDIR}/up_ips.sh

# Конфиг 3proxy
gen_3proxy > /usr/local/etc/3proxy/3proxy.cfg

# Systemd
sudo cat > /etc/systemd/system/3proxy.service <<EOF
[Unit]
Description=3proxy Proxy Server
After=network.target

[Service]
Type=forking
LimitNOFILE=1000000
LimitNPROC=infinity
ExecStartPre=${BINDIR}/up_ips.sh
ExecStart=/usr/local/etc/3proxy/bin/3proxy /usr/local/etc/3proxy/3proxy.cfg
Restart=always
TimeoutStartSec=300

[Install]
WantedBy=multi-user.target
EOF

echo "Cleaning up old processes and starting service..."
sudo pkill -9 3proxy >/dev/null 2>&1
sudo systemctl daemon-reload
sudo systemctl enable 3proxy
sudo systemctl restart 3proxy

# Формирование proxy.txt
cat > proxy.txt <<EOF
$(awk -F "/" '{print $3 ":" $4 ":" $1 ":" $2 }' ${WORKDATA})
EOF

echo -e "${GREEN}Successfully installed! List saved to ${WORKDIR}/proxy.txt${NC}"
cd /root
