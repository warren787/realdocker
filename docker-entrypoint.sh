#!/bin/bash

# Define Environment Variables
export UUID=$(openssl rand -hex 16 | awk '{print substr($0,1,8)"-"substr($0,9,4)"-"substr($0,13,4)"-"substr($0,17,4)"-"substr($0,21,12)}')
export FILE_PATH=${FILE_PATH:-'./app'}
export SNI=${SNI:-'www.yahoo.com'}

# If the PORT environment variable is empty, use a random port
if [ -z "$PORT" ]; then
  PORT=$(shuf -i 2000-65000 -n 1)
fi

# Download Dependency Files
ARCH=$(uname -m) && DOWNLOAD_DIR="${FILE_PATH}" && mkdir -p "$DOWNLOAD_DIR" && FILE_INFO=()
if [ "$ARCH" == "arm" ] || [ "$ARCH" == "arm64" ] || [ "$ARCH" == "aarch64" ]; then
    FILE_INFO=("https://github.com/eooce/test/releases/download/arm64/web web" "https://github.com/eooce/test/releases/download/ARM/swith npm")
elif [ "$ARCH" == "amd64" ] || [ "$ARCH" == "x86_64" ] || [ "$ARCH" == "x86" ]; then
    FILE_INFO=("https://github.com/eooce/test/releases/download/amd64/web web" "https://github.com/eooce/test/releases/download/bulid/swith npm")
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi
for entry in "${FILE_INFO[@]}"; do
    URL=$(echo "$entry" | cut -d ' ' -f 1)
    NEW_FILENAME=$(echo "$entry" | cut -d ' ' -f 2)
    FILENAME="$DOWNLOAD_DIR/$NEW_FILENAME"
    if [ -e "$FILENAME" ]; then
        echo -e "\e[1;32m$FILENAME already exists,Skipping download\e[0m"
    else
        curl -L -sS -o "$FILENAME" "$URL"
        echo -e "\e[1;32mDownloading $FILENAME\e[0m"
    fi
    chmod +x $FILENAME
done
wait

# Generating Configuration Files
generate_config() {

    X25519Key=$(./"${FILE_PATH}/web" x25519)
    PrivateKey=uMI0uWAIgLgHYU55B18ISCqXFtThW68raRE3LUBu4BA
    PublicKey=ZrEiT1rtftA1QP1sXSHlYtBjGXYmzUruXyPagMDbKU0
    shortid=55a8055f2804d938

  cat > ${FILE_PATH}/config.json << EOF
{
    "inbounds": [
        {
            "port": $PORT,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "$UUID",
                        "flow": "xtls-rprx-vision"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "tcp",
                "security": "reality",
                "realitySettings": {
                    "show": false,
                    "dest": "1.1.1.1:443",
                    "xver": 0,
                    "serverNames": [
                        "$SNI"
                    ],
                    "privateKey": "$PrivateKey",
                    "minClientVer": "",
                    "maxClientVer": "",
                    "maxTimeDiff": 0,
                    "shortIds": [
                        "$shortid"
                    ]
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        },
        {
            "protocol": "blackhole",
            "tag": "blocked"
        }
    ]    
}
EOF
}
generate_config

# running files
run() {
  if [ -e "${FILE_PATH}/web" ]; then
    chmod 777 "${FILE_PATH}/web"
    nohup ${FILE_PATH}/web -c ${FILE_PATH}/config.json >/dev/null 2>&1 &
	sleep 2
    pgrep -x "web" > /dev/null && echo -e "\e[1;32mweb is running\e[0m" || { echo -e "\e[1;35mweb is not running, restarting...\e[0m"; pkill -x "web" && nohup "${FILE_PATH}/web" -c ${FILE_PATH}/config.json >/dev/null 2>&1 & sleep 2; echo -e "\e[1;32mweb restarted\e[0m"; }
  fi

}
run

# get ip
IP=$(curl -s https://ipv4.icanhazip.com)

# get ipinfo
ISP=$(curl -s https://speed.cloudflare.com/meta | awk -F\" '{print $26"-"$18}' | sed -e 's/ /_/g')

cat > ${FILE_PATH}/list.txt <<EOF

vless://${UUID}@${IP}:${PORT}?encryption=none&flow=xtls-rprx-vision&security=reality&sni=${SNI}&fp=chrome&pbk=${PublicKey}&sid=${shortid}&type=tcp&headerType=none#$ISP

EOF

base64 -w0 ${FILE_PATH}/list.txt > ${FILE_PATH}/url.txt
echo $PublicKey
echo $vless
cat ${FILE_PATH}/url.txt
echo -e "\n\e[1;32m${FILE_PATH}/url.txt saved successfully\e[0m"
rm -rf ${FILE_PATH}/list.txt
echo ""
echo -e "\n\e[1;32mInstall success!\e[0m"

exit 0
