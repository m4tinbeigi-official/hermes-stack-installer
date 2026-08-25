# 🚀 Hermes Stack Installer (All-In-One AI Agent Suite)

یک اسکریپت جامع، هوشمند و کاملاً خودکار برای نصب، پیکربندی و اتصال اجزای اکوسیستم هرمس:
- **Hermes Agent** (هسته اصلی ایجنت خودمختار Nous Research)
- **Hermes WebUI** (رابط کاربری وب با قابلیت چت زنده، مدیریت سشن‌ها و ابزارها)
- **9Router** (گیت‌وی سبک و بهینه‌سازی مسیرهای هوش مصنوعی روی پورت `20128`)
- **OmniRoute / omnirouter** (روتر هوشمند چند مدلی با قابلیت Fallback روی پورت مجزای `20129` بدون هیچ‌گونه تداخل)

---

## ⚡️ نصب سریع با یک دستور (One-Line Quick Install)

### لینوکس و مک (Linux & macOS)

```bash
curl -fsSL https://raw.githubusercontent.com/m4tinbeigi-official/hermes-stack-installer/main/install.sh | bash
```

یا در صورت تمایل به تایید خودکار تمامی مراحل:
```bash
curl -fsSL https://raw.githubusercontent.com/m4tinbeigi-official/hermes-stack-installer/main/install.sh | bash -s -- --yes
```

### ویندوز (Windows PowerShell)

```powershell
irm https://raw.githubusercontent.com/m4tinbeigi-official/hermes-stack-installer/main/install.ps1 | iex
```

---

## 🌟 ویژگی‌ها و قابلیت‌های کلیدی

1. **تشخیص خودکار سیستم‌عامل و سخت‌افزار (OS & Arch Detection):**
   - پشتیبانی خودکار از Ubuntu، Debian، Fedora، Arch Linux، macOS (Intel و Apple Silicon) و WSL.
2. **بررسی و نصب هوشمند پیش‌نیازها:**
   - بررسی `git`, `curl`, `python3`, `node/npm`, `uv` و نصب خودکار در صورت عدم وجود.
3. **عدم تکرار و قابلیت Reinstall تعاملی:**
   - اگر هرکدام از کامپوننت‌ها از قبل نصب باشد، تشخیص داده شده و از کاربر سوال می‌شود که آیا تمایل به حذف و نصب مجدد دارد یا ادامه دهد.
4. **جلوگیری تضمینی از تداخل پورت‌ها (Zero Port Conflict):**
   - `9Router` روی پورت استاندارد `20128`
   - `OmniRoute` روی پورت مجزای `20129`
   - `Hermes WebUI` روی پورت `8787`
5. **اتصال خودکار به یکدیگر:**
   - کانفیگ هرمس ایجنت (`~/.hermes/config.yaml`) به صورت خودکار به روت‌های محلی متصل می‌شود.
6. **اسکریپت‌های مدیریت آسان:**
   - راه‌اندازی با دستور: `hermes-stack-start`
   - متوقف‌سازی با دستور: `hermes-stack-stop`
   - بررسی وضعیت سرویس‌ها: `hermes-stack-status`

---

## 🛠 اجزای پشته (Stack Architecture)

| Component | Port | Description |
| :--- | :--- | :--- |
| **Hermes WebUI** | `8787` | رابط مرورگر و کنترل پنل |
| **9Router** | `20128` | پروکسی هوش مصنوعی و مدل‌های محلی/کلود |
| **OmniRoute** | `20129` | روتر هوشمند و سوئیچ خودکار پرووایدرها |
| **Hermes Agent** | CLI | دستیار خودمختار ترمینال و گیت‌وی |

---

## 📋 دستورات مدیریت سرویس‌ها

پس از نصب، می‌توانید از طریق دستورات زیر سرویس‌ها را کنترل کنید:

```bash
# راه‌اندازی همزمان همه سرویس‌ها در پس‌زمینه
~/.hermes-stack/start.sh
# یا
hermes-stack-start

# مشاهده وضعیت و پورت‌ها
~/.hermes-stack/status.sh
# یا
hermes-stack-status

# متوقف کردن همه سرویس‌ها
~/.hermes-stack/stop.sh
# یا
hermes-stack-stop
```

---

## 📜 License
MIT License - Developed with ❤️ by [matinbeigi](https://github.com/m4tinbeigi-official)
