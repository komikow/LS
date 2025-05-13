#!/bin/bash

# Автоматически завершать работу при любой ошибке
set -e

# Лог-файл
LOG_FILE="/var/log/process_manager.log"

# Функция для логирования
log() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

# Проверка количества аргументов
if [ "$#" -ne 2 ]; then
    log "Ошибка: Необходимо указать 2 аргумента."
    log "Использование: $0 <PID|имя_процесса> <kill|forcekill>"
    exit 1
fi

TARGET=$1
MODE=$2

# Проверка режима завершения
if [[ "$MODE" != "kill" && "$MODE" != "forcekill" ]]; then
    log "Ошибка: Неверный режим завершения. Используйте 'kill' или 'forcekill'."
    exit 1
fi

# Функция для проверки существования процесса по PID
check_pid() {
    if ! kill -0 "$1" 2>/dev/null; then
        log "Ошибка: Процесс с PID $1 не существует."
        exit 1
    fi
}

# Функция для проверки существования процесса по имени
check_name() {
    if ! pgrep -x "$1" >/dev/null; then
        log "Ошибка: Нет процессов с именем '$1'."
        exit 1
    fi
}

# Функция для завершения процесса по PID
terminate_pid() {
    local pid=$1
    local mode=$2
    
    check_pid "$pid"
    
    if [ "$mode" == "kill" ]; then
        log "Отправка SIGTERM процессу с PID $pid"
        kill -15 "$pid"
        log "Процесс с PID $pid получил SIGTERM"
    elif [ "$mode" == "forcekill" ]; then
        log "Отправка SIGTERM процессу с PID $pid (первый этап forcekill)"
        kill -15 "$pid"
        
        # Ждем 10 секунд
        local wait_time=10
        log "Ожидание $wait_time секунд для завершения процесса..."
        
        for ((i=1; i<=$wait_time; i++)); do
            if ! kill -0 "$pid" 2>/dev/null; then
                log "Процесс с PID $pid успешно завершился после SIGTERM"
                return 0
            fi
            sleep 1
        done
        
        log "Процесс с PID $pid не завершился после SIGTERM, отправка SIGKILL"
        kill -9 "$pid"
        log "Процесс с PID $pid получил SIGKILL"
    fi
}

# Функция для завершения процессов по имени
terminate_name() {
    local name=$1
    local mode=$2
    
    check_name "$name"
    
    if [ "$mode" == "kill" ]; then
        log "Отправка SIGTERM всем процессам с именем '$name'"
        pkill -x -15 "$name"
        log "Все процессы с именем '$name' получили SIGTERM"
    elif [ "$mode" == "forcekill" ]; then
        log "Отправка SIGTERM всем процессам с именем '$name' (первый этап forcekill)"
        pkill -x -15 "$name"
        
        # Ждем 10 секунд
        local wait_time=10
        log "Ожидание $wait_time секунд для завершения процессов..."
        
        for ((i=1; i<=$wait_time; i++)); do
            if ! pgrep -x "$name" >/dev/null; then
                log "Все процессы с именем '$name' успешно завершились после SIGTERM"
                return 0
            fi
            sleep 1
        done
        
        log "Некоторые процессы с именем '$name' не завершились после SIGTERM, отправка SIGKILL"
        pkill -x -9 "$name"
        log "Все процессы с именем '$name' получили SIGKILL"
    fi
}

# Основная логика
if [[ "$TARGET" =~ ^[0-9]+$ ]]; then
    log "Цель - процесс с PID $TARGET"
    terminate_pid "$TARGET" "$MODE"
else
    log "Цель - процессы с именем '$TARGET'"
    terminate_name "$TARGET" "$MODE"
fi

log "Операция успешно завершена"
exit 0
