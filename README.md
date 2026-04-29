# myBot
بوت تليجرام تحميل  فيديو 
import os
import asyncio
import yt_dlp
from telegram import Update
from telegram.ext import ApplicationBuilder, CommandHandler, MessageHandler, filters, ContextTypes

# التوكن الخاص بك الذي أرفقته
TOKEN = "8701970648:AAHWdOA02KWnvNPEVpRfI169ww_TCwcBab8"

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text(
        '👋 أهلاً بك في بوت تحميل الفيديوهات!\n\n'
        'أرسل رابط الفيديو من (يوتيوب، تيك توك، فيسبوك) وسأقوم بتحميله لك فوراً.'
    )

async def download_video(update: Update, context: ContextTypes.DEFAULT_TYPE):
    url = update.message.text
    chat_id = update.message.chat_id
    
    # التأكد من أن النص المرسل هو رابط
    if not url.startswith(("http://", "https://")):
        await update.message.reply_text("❌ من فضلك أرسل رابطاً صحيحاً.")
        return

    status_msg = await update.message.reply_text('⏳ جاري التحميل... يرجى الانتظار.')
    
    # اسم ملف فريد لكل عملية تحميل لتجنب التداخل
    file_path = f"video_{chat_id}_{update.message.id}.mp4"
    
    ydl_opts = {
        'format': 'best[ext=mp4]/best', # اختيار أفضل جودة بصيغة mp4
        'outtmpl': file_path,
        'quiet': True,
        'no_warnings': True,
    }
    
    try:
        # تنفيذ التحميل في خيط (Thread) منفصل لضمان عدم توقف البوت
        loop = asyncio.get_event_loop()
        await loop.run_in_executor(None, lambda: yt_dlp.YoutubeDL(ydl_opts).download([url]))
        
        if os.path.exists(file_path):
            with open(file_path, 'rb') as video:
                await context.bot.send_video(
                    chat_id=chat_id, 
                    video=video, 
                    caption="✅ تم التحميل بنجاح بواسطة بوتك!"
                )
        else:
            await update.message.reply_text("❌ حدث خطأ: لم يتم العثور على الملف.")

    except Exception as e:
        print(f"Error: {e}")
        await update.message.reply_text(f'⚠️ حدث خطأ: تأكد من الرابط أو حاول لاحقاً. (تذكر أن تليجرام يسمح برفع ملفات حتى 50 ميجا فقط للبوتات العادية)')
    
    finally:
        # حذف الفيديو من السيرفر بعد الإرسال لتوفير المساحة
        if os.path.exists(file_path):
            os.remove(file_path)
        # حذف رسالة "جاري التحميل"
        await status_msg.delete()

if __name__ == '__main__':
    # بناء التطبيق باستخدام التوكن
    application = ApplicationBuilder().token(TOKEN).build()
    
    # إضافة الأوامر والمستقبلات
    application.add_handler(CommandHandler("start", start))
    application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, download_video))
    
    print("✅ البوت يعمل الآن... اضغط Ctrl+C لإيقافه.")
    application.run_polling()

