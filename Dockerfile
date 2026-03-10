FROM python:3.12-slim

WORKDIR /app

# Оновлюємо pip і ставимо uv
RUN pip install --no-cache-dir --upgrade pip uv==0.5.29

# Set UV environment variables
ENV UV_PYTHON_DOWNLOADS=never \
    UV_COMPILE_BYTECODE=1 \
    UV_NO_SYNC=1

# Копіюємо конфіги
COPY pyproject.toml uv.lock ./

# Додаємо yt-dlp через UV
RUN uv add yt-dlp requests

# Встановлюємо всі залежності
RUN uv install --locked --no-dev

# Копіюємо код
COPY . .

# Запуск бота
CMD ["python", "main.py"]
