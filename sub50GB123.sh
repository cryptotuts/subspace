#!/bin/bash

function colors {
  GREEN="\e[32m"
  RED="\e[39m"
  NORMAL="\e[0m"
}


function read_nodename1 {
  if [ ! $SUBSPACE_NODENAME1 ]; then
  echo -e "Enter your node name(random name for telemetry)"
  line_1
  read SUBSPACE_NODENAME1
  fi
}

function read_wallet1 {
  if [ ! $WALLET_ADDRESS1 ]; then
  echo -e "Enter your polkadot.js extension address"
  line_1
  read WALLET_ADDRESS1
  fi
}


function eof_docker_compose1 {
  mkdir -p $HOME/subspace_docker1/
  sudo tee <<EOF >/dev/null $HOME/subspace_docker1/docker-compose.yml
  version: "3.7"
  services:
    node:
      image: ghcr.io/subspace/node:gemini-2a-2022-sep-06
      volumes:
        - node-data:/var/subspace1:rw
      ports:
        - "0.0.0.0:30334:30334"
      restart: unless-stopped
      command: [
        "--chain", "gemini-2a",
        "--base-path", "/var/subspace1",
        "--execution", "wasm",
        "--pruning", "1024",
        "--keep-blocks", "1024",
        "--port", "30334",
        "--rpc-cors", "all",
        "--rpc-methods", "safe",
        "--unsafe-ws-external",
        "--validator",
        "--name", "$SUBSPACE_NODENAME1",
        "--telemetry-url", "wss://telemetry.subspace.network/submit 0",
        "--telemetry-url", "wss://telemetry.postcapitalist.io/submit 0"
      ]
      healthcheck:
        timeout: 5s
        interval: 30s
        retries: 5
    farmer:
      depends_on:
        - node
      image: ghcr.io/subspace/farmer:gemini-2a-2022-sep-06
      volumes:
        - farmer-data:/var/subspace1:rw
      restart: unless-stopped
      command: [
        "--base-path", "/var/subspace1",
        "farm",
        "--node-rpc-url", "ws://node:9945",
        "--ws-server-listen-addr", "0.0.0.0:9956",
        "--reward-address", "$WALLET_ADDRESS1",
        "--plot-size", "50G"
      ]
  volumes:
    node-data:
    farmer-data:
EOF
}

function docker_compose_up {
  docker-compose -f $HOME/subspace_docker1/docker-compose.yml up -d
}

function echo_info {
  echo -e "${GREEN}Для остановки ноды и фармера subspace: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace_docker/docker-compose.yml down \n ${NORMAL}"
  echo -e "${GREEN}Для запуска ноды и фармера subspace: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace_docker/docker-compose.yml up -d \n ${NORMAL}"
  echo -e "${GREEN}Для перезагрузки ноды subspace: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace_docker/docker-compose.yml restart node \n ${NORMAL}"
  echo -e "${GREEN}Для перезагрузки фармера subspace: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace_docker/docker-compose.yml restart farmer \n ${NORMAL}"
  echo -e "${GREEN}Для проверки логов ноды выполняем команду: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace_docker/docker-compose.yml logs -f --tail=100 node \n ${NORMAL}"
  echo -e "${GREEN}Для проверки логов фармера выполняем команду: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace_docker/docker-compose.yml logs -f --tail=100 farmer \n ${NORMAL}"
}

function delete_old {
  docker-compose -f $HOME/subspace_docker1/docker-compose.yml down &>/dev/null
  docker volume rm subspace_docker_subspace-farmer subspace_docker_subspace-node &>/dev/null
}

colors
line_1
logo
line_2
read_nodename1
line_2
read_wallet1
line_2
echo -e "Установка tools, ufw, docker"
line_1
install_docker
delete_old
line_1
echo -e "Создаем docker-compose файл"
line_1
eof_docker_compose1
line_1
echo -e "Запускаем docker контейнеры для node and farmer Subspace"
line_1
docker_compose_up
line_2
echo_info
line_2
