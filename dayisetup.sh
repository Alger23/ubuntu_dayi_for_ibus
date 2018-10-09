#!/bin/bash

# 輸入
cinfile="dayi3.cin"

# 輸出
tabfile="dayi_tab.txt"
templatefile="dayi3template.txt"
dbfile="dayi3.db"

# 輸出字根表 tab 分隔
awk '/\%chardef begin/{f=1;next}/\%chardef end/{exit}f' $cinfile | awk '{count[$1]++}{print $1"\t"$2"\t"101-count[$1]}' | tr '[A-Z]' '[a-z]' > $tabfile

# 從 ibus-table 的資料夾複製輸入法表的範本到目前的工作目錄
cp /usr/share/ibus-table/tables/template.txt .

### 使用者輸入設定後合輸出成 template.txt
uuid=$(uuidgen)
#echo "UUID = ${uuid}"
microseconds=$(($(date +%s%N)/1000000))
#echo "SERIAL_NUMBER = ${microseconds}"
icon="dayi3.png"
symbol="易"
name="dayi"
cn="大易"
hk="大易"
tw="大易"
desc="Chinese Dayi3 table for IBus Table."
lang="zh_CN,zh_SG,zh_TW,zh_HK"
author="Alger Chen <alger.chen23@gmail.com>"
statusprompt="易"
inputchars=",./;\\\\\`1234567890-abcdefghijklmnopqrstuvwxyz"

# 字根表合併到 dayi3template.txt
# awk '{
#  output="on"
#  if($0 ~ /BEGIN\_TABLE/){print; output="off"; next}
#  if($0 ~ /END\_TABlE/){print; output="on"; next}
#  if(output == "on"){print}
#}' <template.txt >dayi3template.txt
awk '1;/BEGIN\_TABLE/{exit}' <template.txt >$templatefile
awk '{if($2) print}' <$tabfile >> $templatefile
awk '/END\_TABlE/ {seen=1} seen {print}' <template.txt >>$templatefile

sed -i "/UUID =/c\UUID = ${uuid}" $templatefile
sed -i "/SERIAL =\_NUMBER/c\SERIAL_NUMBER = ${microseconds}" $templatefile
sed -i "/ICON =/c\ICON = ${icon}" $templatefile
sed -i "/SYMBOL =/c\SYMBOL = ${symbol}" $templatefile
sed -i "/NAME =/c\NAME = ${name}" $templatefile
sed -i "/NAME\.zh_CN =/c\NAME.zh_CN = ${cn}" $templatefile
sed -i "/NAME\.zh_HK =/c\NAME.zh_HK = ${hk}" $templatefile
sed -i "/NAME\.zh_TW =/c\NAME.zh_TW = ${tw}" $templatefile
sed -i "/DESCRIPTIONas =/c\DESCRIPTION = ${desc}" $templatefile
sed -i "/LANGUAGES =/c\LANGUAGES = ${lang}" $templatefile
sed -i "/AUTHOR =/c\AUTHOR = ${author}" $templatefile
sed -i "/STATUS\_PROMPT =/c\STATUS_PROMPT = ${statusprompt}" $templatefile
sed -i "/VALID\_INPUT\_CHARS =/c\VALID_INPUT_CHARS = ${inputchars}" $templatefile

sed -i "/BEGIN_GOUCI/c\### BEGIN_GOUCI" $templatefile
sed -i "/character_1	goucima_1/c\### character_1	goucima_1" $templatefile
sed -i "/character_1	goucima_2/c\### character_1	goucima_2" $templatefile
sed -i "/END_GOUCI/c\### END_GOUCI" $templatefile

# dayi3template.txt 輸出為 dayi3.db
ibus-table-createdb -n $dbfile -s $templatefile

# dayi3.db 複製到 /usr/share/ibus-table/tables/
cp $dbfile /usr/share/ibus-table/tables/

# dayi3 圖示複製到 /url/share/ibus-table/icons/
if [ ! -e dayi3.png ]
then
    wget https://raw.github.com/hime-ime/hime/master/icons/blue/dayi3.png
    cp dayi3.png /usr/share/ibus-table/icons/
fi


# 設定 ibus
#read -p "Do you wish to setup IBus?(y/n)?" choice
#case "$choice" in 
#  y|Y ) echo "yes" && ibus-setup;;
#  n|N ) echo "no";;
#  * ) echo "no";;
#esac

# 重新啟動 ibus
ibus-daemon -d -x -r
