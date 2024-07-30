# MikroTik CHR Installer Script

این مخزن شامل اسکریپتی است که به شما امکان می‌دهد نسخه‌های مختلف MikroTik CHR را بر روی VPS نصب کنید. شما می‌توانید از میان لیست نسخه‌های موجود یکی را انتخاب کرده و فرآیند نصب را به صورت خودکار انجام دهید.

## ویژگی‌ها

- نمایش لیست نسخه‌های موجود به صورت دو ستونی
- دانلود نسخه انتخاب شده توسط کاربر
- نمایش درصد پیشرفت در مراحل نصب
- تنظیمات شبکه خودکار و ایجاد اسکریپت autorun

## پیش‌نیازها

- سیستم‌عامل لینوکس
- دسترسی ریشه (root) به سیستم

## نحوه استفاده

1. اجرای مستقیم اسکریپت با استفاده از `curl`:

    ```bash
    bash -c "$(curl -L https://raw.githubusercontent.com/o-k-l-l-a/Install-MikroTik-CHR-on-VPS/main/setup.sh)"
    ```

2. لیست نسخه‌های موجود MikroTik به شما نمایش داده می‌شود. نسخه مورد نظر خود را انتخاب کرده و Enter را بزنید.

3. اسکریپت به طور خودکار نسخه انتخاب شده را دانلود، استخراج، مونت و نصب می‌کند. درصد پیشرفت مراحل نصب به شما نمایش داده می‌شود.

## توجهات

- اسکریپت برای کار به دسترسی ریشه (root) نیاز دارد. مطمئن شوید که با کاربر ریشه یا با استفاده از `sudo` اسکریپت را اجرا می‌کنید.
- فرآیند نصب ممکن است چند دقیقه طول بکشد. لطفاً صبور باشید و اجازه دهید اسکریپت به طور کامل اجرا شود.

## پشتیبانی

اگر با مشکلی مواجه شدید یا سوالی داشتید، می‌توانید از طریق صفحه Issues در GitHub با ما در ارتباط باشید.

## لایسنس

این پروژه تحت مجوز MIT منتشر شده است. برای اطلاعات بیشتر به فایل LICENSE مراجعه کنید.

---

با اجرای این اسکریپت، شما می‌توانید به سادگی نسخه‌های مختلف MikroTik CHR را بر روی VPS خود نصب کنید و از امکانات این سیستم‌عامل قدرتمند بهره‌مند شوید.
