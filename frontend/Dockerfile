# Используем официальный nginx образ
FROM nginx:alpine

# Копируем собранные файлы Flutter
COPY build/web /usr/share/nginx/html

# Копируем конфигурацию nginx для Flutter
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Открываем порт 80
EXPOSE 80

# Nginx запускается автоматически в базовом образе
