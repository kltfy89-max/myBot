import os
import yt_dlp
from telegram import Update
from telegram.ext import Application, MessageHandler, filters, ContextTypes

# توكن البوت الخاص بك
TOKEN = "8701970648:AAHWP7Jbj_JawtRZwmQD9bjeAGCYbrMUhbo"

async def download_video(update: Update, context: ContextTypes.DEFAULT_TYPE):
    url = update.message.text
    chat_id = update.message.chat_id
    
    await update.message.reply_text("جاري معالجة الرابط والتحميل... انتظر قليلاً")

    try:
        # إعدادات تحميل الفيديو
        ydl_opts = {
            'format': 'best',
            'outtmpl': f'video_{chat_id}.%(ext)s',
            'max_filesize': 50 * 1024 * 1024, # حد أقصى 50 ميجا لتجنب قيود تليجرام العادية
        }

        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
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
