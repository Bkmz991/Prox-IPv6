# 📋 Шпаргалка по командам IPv6 Proxy

## 🚀 Быстрый запуск

```bash
# Вариант 1: С шифрованием
python3 npprproxy.py

# Вариант 2: Без шифрования
python3 start.py

# Вариант 3: Прямой запуск
chmod +x NPPRPROXY.sh && sudo ./NPPRPROXY.sh
```

---

## 📥 Скачивание файлов

```bash
# Список файлов на сервере
ssh root@SERVER_IP "ls -lh /root/proxy_exports/"

# Скачать архив
scp root@SERVER_IP:/root/proxy_exports/proxy_*.zip ./

# Скачать текстовый файл
scp root@SERVER_IP:/root/proxy_exports/proxy_*.txt ./

# Распаковать архив
unzip -P PASSWORD proxy_*.zip
```

---

## 🔧 Управление 3proxy

```bash
# Статус
systemctl status 3proxy

# Запуск
systemctl start 3proxy

# Остановка
systemctl stop 3proxy

# Перезапуск
systemctl restart 3proxy

# Автозапуск при загрузке
systemctl enable 3proxy

# Отключить автозапуск
systemctl disable 3proxy
```

---

## 📊 Мониторинг

```bash
# Активные соединения
netstat -tulpn | grep 3proxy

# Количество открытых портов
netstat -tulpn | grep 3proxy | wc -l

# Процессы 3proxy
ps aux | grep 3proxy

# Использование памяти
top -p $(pgrep 3proxy)

# Проверка IPv6
curl -6 https://api64.ipify.org
```

---

## 🔍 Проверка работы прокси

```bash
# Тест HTTP прокси
curl -x http://USER:PASS@SERVER_IP:10000 https://api.ipify.org?format=json

# Тест SOCKS5 прокси
curl -x socks5://USER:PASS@SERVER_IP:30000 https://api.ipify.org?format=json

# Проверить все прокси из файла (первые 5)
head -5 proxy.txt | while IFS=: read ip port user pass; do
  echo "Тестирую $ip:$port..."
  curl -s -x http://$user:$pass@$ip:$port https://api.ipify.org?format=json
done
```

---

## 📁 Файлы конфигурации

```bash
# Конфиг 3proxy
cat /usr/local/etc/3proxy/3proxy.cfg

# Редактировать конфиг
nano /usr/local/etc/3proxy/3proxy.cfg

# Скрипт iptables
cat /home/proxy-installer/boot_iptables.sh

# Скрипт ifconfig (IPv6 адреса)
cat /home/proxy-installer/boot_ifconfig.sh

# Данные прокси
cat /home/proxy-installer/data.txt
```

---

## 🧹 Очистка

```bash
# Удалить экспортированные файлы
rm -rf /root/proxy_exports/*

# Удалить временные файлы
rm -rf /home/proxy-installer

# Полное удаление прокси
systemctl stop 3proxy
systemctl disable 3proxy
rm -rf /3proxy /usr/local/etc/3proxy /root/proxy_exports /home/proxy-installer
```

---

## 🔐 Безопасность

```bash
# Проверить правила iptables
iptables -L -n -v
ip6tables -L -n -v

# Проверить DNS настройки
cat /etc/resolv.conf

# Проверить dnsmasq
systemctl status dnsmasq

# Логи системы
journalctl -u 3proxy -f
journalctl -u dnsmasq -f
```

---

## 🌐 Проверка IPv6

```bash
# Ваш основной IPv6
ip -6 addr show

# IPv6 маршруты
ip -6 route show

# Проверить IPv6 подключение
ping6 google.com

# Получить внешний IPv6
curl -6 https://api64.ipify.org

# Трассировка IPv6
traceroute6 google.com
```

---

## 📝 Логи и отладка

```bash
# Системные логи
tail -f /var/log/messages

# Логи 3proxy (если включены)
tail -f /usr/local/etc/3proxy/logs/3proxy.log

# Логи iptables
dmesg | grep iptables

# Проверить открытые файлы
lsof -i -P -n | grep 3proxy
```

---

## 🔄 Перезагрузка конфигурации

```bash
# После изменения конфига 3proxy
systemctl restart 3proxy

# После изменения iptables
bash /home/proxy-installer/boot_iptables.sh

# После изменения IPv6 адресов
bash /home/proxy-installer/boot_ifconfig.sh

# Применить все изменения
bash /etc/rc.local
```

---

## 🧪 Тестирование ротации IP

```bash
# Проверить 5 запросов через один прокси (должны быть разные IP при ротации)
for i in {1..5}; do
  curl -s -x http://USER:PASS@SERVER:10000 https://api.ipify.org?format=json
  sleep 1
done
```

---

## 💡 Полезные однострочники

```bash
# Количество настроенных IPv6 адресов
ip -6 addr show | grep -c inet6

# Список всех прокси портов
netstat -tulpn | grep 3proxy | awk '{print $4}' | cut -d: -f2 | sort -n

# Проверить доступность всех портов
for port in {10000..10010}; do
  timeout 1 bash -c "echo >/dev/tcp/SERVER_IP/$port" && echo "Port $port: OK" || echo "Port $port: FAIL"
done

# Генерация нового IPv6 из подсети
printf "2a01:4f8:1234:5678:%04x:%04x:%04x:%04x\n" $RANDOM $RANDOM $RANDOM $RANDOM

# Подсчет активных соединений
netstat -an | grep :10000 | grep ESTABLISHED | wc -l
```

---

## 🐛 Решение проблем

### Прокси не работают

```bash
# 1. Проверить запущен ли 3proxy
systemctl status 3proxy

# 2. Проверить конфигурацию
cat /usr/local/etc/3proxy/3proxy.cfg

# 3. Проверить порты
netstat -tulpn | grep 3proxy

# 4. Проверить firewall
systemctl status firewalld
iptables -L -n
```

### IPv6 не работает

```bash
# 1. Проверить наличие IPv6
ip -6 addr show

# 2. Проверить роутинг
ip -6 route show

# 3. Пинг Google IPv6
ping6 -c 4 2001:4860:4860::8888

# 4. Проверить форвардинг
sysctl net.ipv6.conf.all.forwarding
```

### DNS утечки

```bash
# 1. Проверить dnsmasq
systemctl status dnsmasq

# 2. Проверить iptables правила
iptables -L OUTPUT -n -v | grep ":53"

# 3. Тест DNS leak
curl -x http://USER:PASS@SERVER:10000 https://www.dnsleaktest.com
```

---

## 📞 Быстрая помощь

```bash
# Собрать информацию для отладки
echo "=== System Info ===" && uname -a && \
echo "=== IPv6 ===" && ip -6 addr show && \
echo "=== 3proxy ===" && systemctl status 3proxy && \
echo "=== Ports ===" && netstat -tulpn | grep 3proxy | head -5 && \
echo "=== Config ===" && head -20 /usr/local/etc/3proxy/3proxy.cfg
```

---

**Совет:** Сохраните эту шпаргалку и держите под рукой при настройке прокси! 📌


