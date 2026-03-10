# Використовуємо повний Python 3.12 образ
FROM python:3.12

# Встановлюємо системні залежності для yt-dlp та збірки деяких пакетів
RUN apt-get update && apt-get install -y \
    ffmpeg \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Встановлюємо uv та інші Python залежності
RUN pip install --upgrade pip
RUN pip install uv==0.5.29 yt-dlp requests

# Створюємо робочу директорію
WORKDIR /app

# Копіюємо файли проекту
COPY pyproject.toml uv.lock ./
COPY . .

# Синхронізація uv залежностей
RUN uv sync --locked --no-dev --no-install-project
RUN uv sync --locked --no-dev --no-editable

# Встановлюємо UV змінні середовища
ENV UV_PYTHON_DOWNLOADS=never \
    UV_COMPILE_BYTECODE=1 \
    UV_NO_SYNC=1

# Запуск бота
CMD ["uv", "run", "main.py"]
