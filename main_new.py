import telebot
import yt_dlp
import os

API_TOKEN = '8701970648:AAHWP7Jbj_JawtRZwmQD9bjeAGCYbrMUhbo'
bot = telebot.TeleBot(API_TOKEN)

@bot.message_handler(func=lambda message: True)
def download_video(message):
    url = message.text
    ydl_opts = {
        'format': 'best',
        'outtmpl': 'video.%(ext)s',
    }
    
    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=True)
            filename = ydl.prepare_filename(info)
            with open(filename, 'rb') as video:
                bot.send_video(message.chat.id, video)
            os.remove(filename)
    except Exception as e:
        bot.reply_to(message, "Error")

bot.infinity_polling()
