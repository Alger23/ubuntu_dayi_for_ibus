#!/usr/bin/env python
# -*- coding: utf-8 -*-

import datetime
import os
import re
import shutil
import subprocess
import uuid
import urllib.request

download = lambda url: urllib.request.urlopen(url).read()
# 輸入
cinurl = "https://raw.githubusercontent.com/Alger23/ubuntu_dayi_for_ibus/master/dayi3.cin"
cinfile = "dayi3.cin"
templatein="/usr/share/ibus-table/tables/template.txt"
iconurl="https://raw.github.com/hime-ime/hime/master/icons/blue/dayi3.png"
# 輸出
templatefile = "dayi3template.txt"
dbfile = "/usr/share/ibus-table/tables/dayi3.db"
iconpath="/usr/share/ibus-table/icons/dayi3.png"

if not os.path.isfile(cinfile):
    with open(cinfile, "w") as fp:
        fp.write(download(cinurl))

# 輸出字根表 tab 分隔
tabfile = []
with open(cinfile) as fp:
    begin=False
    count = {}
    for line in fp:
        if line.strip() == '%chardef begin':
            begin = True
        if not begin:
            continue
        if line.strip() == '%chardef end':
            break
        code, char = line.strip().split()
        count[code] = count.get(code, 0) + 1
        tabfile.append("%s\t%s\t%d" % (code.upper(), char, 100-count[code]))

# 從 ibus-table 的資料夾開啟輸入法表的範本,合拼輸入設定和字根表到 dayi3template.txt
templatein="/usr/share/ibus-table/tables/template.txt"
attrs = {
    "UUID": str(uuid.uuid4()),
    "SERIAL_NUMBER": datetime.datetime.now().strftime("%Y%m%d"),
    "ICON": "dayi3.png",
    "SYMBOL": u"易",
    "NAME": "dayi",
    "NAME.zh_CN": u"大易",
    "NAME.zh_HK": u"大易",
    "NAME.zh_TW": u"大易",
    "DESCRIPTION": "Chinese Dayi3 table for IBus Table.",
    "LANGUAGES": "zh_CN,zh_SG,zh_TW,zh_HK",
    "AUTHOR": "Alger Chen <alger.chen23@gmail.com>",
    "STATUS_PROMPT": u"易",
    "VALID_INPUT_CHARS": ",./;\\\\\`1234567890-abcdefghijklmnopqrstuvwxyz"
}
with open(templatefile, "w") as out, open(templatein) as fp:
    for line in fp:
        m = re.match(r"(\w+)(\s=\s)(.*$)", line)
        if m and m.group(1) in attrs:
            out.write("%s%s%s" % (m.group(1), m.group(2), attrs[m.group(1)]))
        else:
            out.write(line)
        if line.strip() == "BEGIN_TABLE":
            out.write("\n".join(tabfile) + "\n")
            for line in fp:
                # skip to END_TABLE
                if line.strip() == "END_TABLE":
                    out.write(line)
                    break
        elif line.strip() == "BEGIN_GOUCI":
            out.write("### "+line)
            for line in fp:
                out.write("### "+line)
            break

# dayi3template.txt 輸出為 /usr/share/ibus-table/tables/dayi3.db
subprocess.call(["ibus-table-createdb", "-n", dbfile, "-s", templatefile])

# dayi3 圖示複製到 /url/share/ibus-table/icons/
if not os.path.isfile(iconpath):
    if os.path.isfile("dayi3.png"):
        shutil.copyfile("dayi3.png", iconpath)
    else:
        with open(iconpath, "wb") as fp:
            fp.write(download(iconurl))
        
# 重新啟動 ibus
subprocess.call(["ibus-daemon","-d","-x","-r"])
