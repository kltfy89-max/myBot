import telebot
from yt_dlp import YoutubeDL
import os

# Your Telegram Bot Token
API_TOKEN = '8701970648:AAHWP7Jbj_JawtRZwmQD9bjeAGCYbrMUhbo'
bot = telebot.TeleBot(API_TOKEN)

@bot.message_handler(commands=['start', 'help'])
def send_welcome(message):
    welcome_text = (
        "Welcome! Send me a video link to download it.\n"
        "Supported platforms: YouTube, Facebook, TikTok, etc."
    )
    bot.reply_to(message, welcome_text)

@bot.message_handler(func=lambda message: True)
def download_video(message):
    url = message.text
    bot.reply_to(message, "Processing... please wait ⏳")

    try:
        # Download settings
        ydl_opts = {
            'format': 'best',
            'outtmpl': 'downloaded_video.mp4',
            'quiet': True,
            'no_warnings': True,
        }

        with YoutubeDL(ydl_opts) as ydl:
            ydl.download([url])

        # Sending the video to the user
        with open('downloaded_video.mp4', 'rb') as video:
            bot.send_video(
                message.chat.id, 
                video, 
                caption="Downloaded successfully! ✅"
            )
        
        # Clean up: remove the file from the server after sending
        os.remove('downloaded_video.mp4')

    except Exception as e:
        bot.reply_to(message, f"An error occurred. Please make sure the link is valid.\nError: {str(e)}")

print("Bot is running...")
bot.infinity_polling()
