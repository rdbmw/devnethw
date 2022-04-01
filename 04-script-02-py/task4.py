#!/usr/bin/env python3

import socket
import time
import sys

# Задержка по умолчанию
delay = 1
if len(sys.argv) >= 2:
    delay = int(sys.argv[1])

# Инициализация словаря
spaces = 0
servers = {"drive.google.com": "0", "mail.google.com": "0", "google.com": "0"}
for server_name in servers.keys():
    servers[server_name] = socket.gethostbyname(server_name)
    spaces = max(spaces, len(server_name))

while True:
    for server_name, server_ip in servers.items():
        new_ip = socket.gethostbyname(server_name)
        if server_ip != new_ip:
            print(f"{time.strftime('%d.%m.%Y %H:%M:%S', time.localtime())} [ERROR] {server_name.ljust(spaces)}: ip "
                  f"mismatch {server_ip} {new_ip}")
            servers[server_name] = new_ip
        else:
            print(f"{time.strftime('%d.%m.%Y %H:%M:%S', time.localtime())}         {server_name.ljust(spaces)}: "
                  f"{server_ip}")
    time.sleep(delay)
