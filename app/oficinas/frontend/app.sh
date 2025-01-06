#!/usr/bin/env bash
#
# Script simples para iniciar e parar um container Docker.
# Uso:
#   ./app.sh start
#   ./app.sh stop
#

APP_NAME="my-app"             # nome do container
IMAGE_NAME="my-app-image"     # nome da imagem
PORT=3000                     # porta que a aplicação usa

start_container() {
  echo "===> Iniciando o container '$APP_NAME'..."

  # Se já existir um container com esse nome, parar e remover
  if [ "$(docker ps -q -f name=^${APP_NAME}$)" ]; then
    echo "===> Parando container em execução..."
    docker stop "$APP_NAME"
    docker rm "$APP_NAME"
  elif [ "$(docker ps -aq -f name=^${APP_NAME}$)" ]; then
    # Se existe parado, apenas remover
    docker rm "$APP_NAME"
  fi

  # (Opcional) Construir a imagem antes de rodar
  # Se já estiver construída, pode pular esta etapa
  echo "===> Construindo a imagem '$IMAGE_NAME'..."
  docker build -t "$IMAGE_NAME" .

  # Iniciar o container em modo "detached"
  echo "===> Subindo o container '$APP_NAME' na porta $PORT..."
  docker run -d \
    --name "$APP_NAME" \
    -p "$PORT:$PORT" \
    "$IMAGE_NAME"

  # Verificar se subiu corretamente
  if [ "$(docker ps -q -f name=^${APP_NAME}$)" ]; then
    echo "===> Container '$APP_NAME' em execução!"
  else
    echo "===> Erro ao iniciar o container '$APP_NAME'."
    exit 1
  fi
}

stop_container() {
  echo "===> Parando o container '$APP_NAME'..."

  # Verificar se há container em execução
  if [ "$(docker ps -q -f name=^${APP_NAME}$)" ]; then
    docker stop "$APP_NAME"
    docker rm "$APP_NAME"
    echo "===> Container '$APP_NAME' parado e removido."
  elif [ "$(docker ps -aq -f name=^${APP_NAME}$)" ]; then
    # Se existir, mas parado, remover
    docker rm "$APP_NAME"
    echo "===> Container '$APP_NAME' estava parado e foi removido."
  else
    echo "===> Nenhum container '$APP_NAME' em execução ou parado."
  fi
}

case "$1" in
  start)
    start_container
    ;;
  stop)
    stop_container
    ;;
  *)
    echo "Uso: $0 {start|stop}"
    exit 1
    ;;
esac

