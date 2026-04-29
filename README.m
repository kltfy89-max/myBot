import telebot
import yt_dlp
import os

# وضع التوكن الخاص بك هنا
API_TOKEN = '8701970648:AAHWP7Jbj_JawtRZwmQD9bjeAGCYbrMUhbo'

bot = telebot.TeleBot(API_TOKEN)

@bot.message_handler(commands=['start', 'help'])
def send_welcome(message):
    bot.reply_to(message, "أهلاً بك! أرسل لي رابط الفيديو (يوتيوب، فيسبوك، إنستغرام) وسأقوم بتحميله لك.")

@bot.message_handler(func=lambda message: True)
def process_link(message):
    url = message.text
    chat_id = message.chat.id
    
    # إرسال رسالة انتظار
    msg = bot.reply_to(message, "⏳ جاري فحص الرابط والتحميل...")

    try:
        # إعدادات yt-dlp لضبط الجودة واسم الملف
        ydl_opts = {
            'format': 'best[ext=mp4]/best', # تحميل أفضل جودة بصيغة mp4
            'outtmpl': f'video_{chat_id}.%(ext)s', # اسم ملف فريد لكل مستخدم
            'max_filesize': 48 * 1024 * 1024, # تحديد الحجم بـ 48 ميجا لتجنب قيود تليجرام
        }

        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            # استخراج المعلومات والتحميل
            info = ydl.extract_info(url, download=True)
            filename = ydl.prepare_filename(info)

        # إرسال الفيديو المحمل
        with open(filename, 'rb') as video:
            bot.send_video(chat_id, video, caption="تم التحميل بواسطة بوتك ✅")
        
        # حذف الفيديو من جهازك/سيرفرك لتوفير المساحة
        os.remove(filename)
        bot.delete_message(chat_id, msg.message_id)

    except Exception as e:
        bot.edit_message_text(f"❌ حدث خطأ: تأكد من الرابط أو حجم الفيديو.\nالتفاصيل: {str(e)}", chat_id, msg.message_id)

print("البوت يعمل الآن...")
bot.infinity_polling()
            info = ydl.extract_info(url, download=True)
            filename = ydl.prepare_filename(info)

        # إرسال الفيديو للمستخدم
        with open(filename, 'rb') as video:
            await update.message.reply_video(video=video, caption="تم التحميل بنجاح ✅")

        # حذف الملف من السيرفر بعد الإرسال لتوفير المساحة
        os.remove(filename)

    except Exception as e:
        await update.message.reply_text(f"حدث خطأ أثناء التحميل: {str(e)}")

def main():
    # تشغيل البوت
    app = Application.builder().token(TOKEN).build()
    
    # التعامل مع أي نص يرسله المستخدم على أنه رابط فيديو
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, download_video))
    
    print("Bot is running...")
    app.run_polling()

if __name__ == '__main__':
    main()
