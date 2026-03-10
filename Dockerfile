FROM python:3.12-slim

WORKDIR /app

# Оновлюємо apt та ставимо системні залежності
RUN apt-get update && apt-get install -y \
    ffmpeg \
    curl \
    build-essential \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Оновлюємо pip і встановлюємо uv
RUN pip install --no-cache-dir --upgrade pip uv==0.5.29

# Дозволяємо UV синхронізацію
ENV UV_NO_SYNC=0

# Копіюємо pyproject.toml
COPY pyproject.toml ./

# Додаємо yt-dlp через UV
RUN uv add yt-dlp requests

# Встановлюємо всі залежності через UV
RUN uv install --locked --no-dev

# Копіюємо код
COPY . .

# Запуск бота
CMD ["python", "main.py"]
