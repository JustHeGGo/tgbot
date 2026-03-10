import os
import time
import requests
import re
import yt_dlp
from telegram import Update
from telegram.ext import ApplicationBuilder, CommandHandler, MessageHandler, ContextTypes, filters
from dotenv import load_dotenv

# Завантажуємо .env локально (для Railway не обов'язково, там змінні середовища автоматично доступні)
load_dotenv()

# Змінна середовища для токена
BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
if not BOT_TOKEN:
    raise ValueError("CRITICAL ERROR: TELEGRAM_BOT_TOKEN не знайдено!")

# Папка для тимчасових відео
VIDEO_FOLDER = "videos"
os.makedirs(VIDEO_FOLDER, exist_ok=True)

# ------------------------
# Команди
# ------------------------
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("Надішли посилання на відео з TikTok або Likee.")

# ------------------------
# Скачування відео
# ------------------------
def download_video(video_url):
    filename = os.path.join(VIDEO_FOLDER, f"{int(time.time())}.mp4")
    r = requests.get(video_url, stream=True)
    with open(filename, "wb") as f:
        for chunk in r.iter_content(1024):
            if chunk:
                f.write(chunk)
    return filename

def download_tiktok(url):
    filename = os.path.join(VIDEO_FOLDER, f"{int(time.time())}.mp4")
    ydl_opts = {"outtmpl": filename, "format": "mp4", "quiet": True}
    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        info = ydl.extract_info(url, download=True)
        return ydl.prepare_filename(info)

def find_likee_mp4(url):
    headers = {"User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X)"}
    r = requests.get(url, headers=headers)
    html = r.text
    video = re.search(r'https://[^"]+\.mp4', html)
    if video:
        return video.group(0)
    else:
        raise Exception("MP4 не знайдено")

def download_likee(url):
    mp4_url = find_likee_mp4(url)
    return download_video(mp4_url)

# ------------------------
# Обробка повідомлень
# ------------------------
async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    url = update.message.text.strip()
    await update.message.reply_text("⏳ Шукаю відео...")

    try:
        if "tiktok.com" in url:
            file_path = download_tiktok(url)
        elif "likee.video" in url:
            file_path = download_likee(url)
        else:
            await update.message.reply_text("Підтримуються тільки TikTok та Likee")
            return

        with open(file_path, "rb") as video:
            await update.message.reply_video(video)

        os.remove(file_path)
        await update.message.reply_text("✅ Готово. Надішли нове посилання.")

    except Exception as e:
        await update.message.reply_text(f"⚠️ Помилка: {e}")

# ------------------------
# Запуск бота
# ------------------------
def main():
    app = ApplicationBuilder().token(BOT_TOKEN).build()
    app.add_handler(CommandHandler("start", start))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))
    print("Bot started")
    app.run_polling()

if __name__ == "__main__":
    main()
