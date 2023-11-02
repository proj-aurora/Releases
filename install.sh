#!/bin/bash

echo "installing runtimes, dependencies"
sudo apt-get update
sudo apt-get install unzip dotnet-runtime-7.0 -y

echo "installing aurora agent..."
URL="https://github.com/proj-aurora/Releases/raw/main/agent_linux_amd64.zip"
wget "$URL" -O /tmp/agent.zip

# 압축 해제
unzip /tmp/agent.zip -d /opt/aurora-agent

# start.sh 파일 생성
echo $'#!/bin/bash\ndotnet /opt/aurora-agent/Agent.dll $1' > /opt/aurora-agent/start.sh

# 실행 권한 부여
chmod +x /opt/aurora-agent/start.sh

# 실행 가능한 경로에 심볼릭 링크 생성
ln -s /opt/aurora-agent/start.sh /usr/local/bin/aurora-agent

echo "agent installation done."



echo "installing fluentd"
CONFIG_URL="https://github.com/proj-aurora/Releases/raw/main/fluent-bit.yml"
SERVICE_URL="https://github.com/proj-aurora/Releases/raw/main/fluentbit.service"
SERVICE1_URL="https://github.com/proj-aurora/Releases/raw/main/aurora-agent.service"

curl https://raw.githubusercontent.com/proj-aurora/Releases/main/fluentinstall.sh | sh
wget "$CONFIG_URL" -O /etc/fluent-bit/fluent-bit.yml
wget "$SERVICE_URL" -O /etc/systemd/system/fluentbit.service
wget "$SERVICE1_URL" -O /etc/systemd/system/aurora-agent.service

echo "installing new crontab"
(crontab -l 2>/dev/null; echo "*/10 * * * * systemctl restart fluentbit") | sudo crontab -

sudo systemctl enable --now fluentbit.service
sudo systemctl daemon-reload


echo "Please Configure agent by sudo aurora-agent -c"
echo "START AGENT BY systemctl enable --now aurora-agent"
