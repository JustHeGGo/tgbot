# Базовий образ Python 3.12 slim
FROM python:3.12-slim

# Робоча директорія
WORKDIR /app

# Оновлення пакунків та встановлення системних залежностей для yt-dlp
RUN apt-get update && apt-get install -y \
    ffmpeg \
    curl \
    build-essential \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Оновлюємо pip та встановлюємо uv
RUN pip install --no-cache-dir --upgrade pip uv==0.5.29

# Дозволяємо UV синхронізацію
ENV UV_NO_SYNC=0 \
    UV_COMPILE_BYTECODE=1 \
    UV_PYTHON_DOWNLOADS=never

# Копіюємо pyproject.toml (якщо є uv.lock, то теж)
COPY pyproject.toml uv.lock* ./

# Додаємо yt-dlp та requests через UV
RUN uv add yt-dlp requests

# Встановлюємо всі залежності (не встановлюємо dev-пакети)
RUN uv install --locked --no-dev

# Копіюємо весь код
COPY . .

# Запуск бота
CMD ["python", "main.py"]
