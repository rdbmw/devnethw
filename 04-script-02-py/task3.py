#!/usr/bin/env python3

import os
import sys

src = os.getcwd()
if len(sys.argv) >= 2:
    src = sys.argv[1]

bash_command = ["cd " + src, "git status 2>&1"]
result_os = os.popen(' && '.join(bash_command),).read()
for result in result_os.split('\n'):
    if result.find('fatal: not a git repository') != -1:
        print(f"Директория {src} не является локальным git-репозиторием")
        break
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(os.path.join(src, prepare_result))
