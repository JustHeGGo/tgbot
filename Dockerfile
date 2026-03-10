# Використовуємо Python 3.12 slim для легкого образу
FROM python:3.12-slim

# Встановлюємо робочу директорію
WORKDIR /app

# Копіюємо файли залежностей (якщо є)
COPY pyproject.toml uv.lock ./

# Оновлюємо pip та встановлюємо необхідні пакети
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir uv==0.10.9 yt-dlp requests python-dotenv python-telegram-bot==22.8

# Копіюємо весь код проєкту
COPY . .

# Створюємо папку для тимчасових відео
RUN mkdir -p videos

# Вказуємо команду запуску
CMD ["uv", "run", "main.py"]
