#!/usr/bin/env python3

import os

src = "G:/devnethw/04-script-02-py"
bash_command = ["cd " + src, "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(os.path.abspath(os.path.join(src, prepare_result)))
