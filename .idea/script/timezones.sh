#!/bin/bash
set -e

# Вывод текущего времени в разных часовых поясах
echo "$(date -u '+%H:%M'): Current time in UTC time zone"
echo "$(TZ=America/New_York date '+%H:%M'): Current time in America/New_York time zone"
echo "$(TZ=Asia/Tokyo date '+%H:%M'): Current time in Asia/Tokyo time zone"

# Определение дня недели завтра и вывод информации
tomorrow_weekday=$(date -d 'tomorrow' '+%A')

if [[ "$tomorrow_weekday" == "Saturday" || "$tomorrow_weekday" == "Sunday" ]]; then
    echo "$tomorrow_weekday: Tommorow day ;-)"
else
    echo "$tomorrow_weekday: Tommorow day"
fi
