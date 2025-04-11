#!/bin/bash

# Инициализация строки
INIT_STRING="1234567890"

# Проверка переменной TEST_COUNTER
if [ -z "$TEST_COUNTER" ]; then
    TEST_COUNTER=0
fi

if [ "$TEST_COUNTER" -eq 0 ]; then
    # Бесконечный цикл с добавлением чисел
    i=1
    while true; do
        INIT_STRING="${INIT_STRING}${i}"
        echo "$INIT_STRING"
        sleep 0.1
        ((i++))
    done
else
    # Цикл for с числами от 1 до TEST_COUNTER
    for (( num=1; num<=$TEST_COUNTER; num++ )); do
        INIT_STRING="${INIT_STRING}${num}"
        echo "$INIT_STRING"
        # Вычисление задержки с помощью bc
        delay=$(echo "$TEST_COUNTER * 0.1" | bc)
        sleep $delay
    done
fi