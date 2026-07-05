# reNgine-ng Custom Dark Theme Patch

<div align="center">

![reNgine-ng](https://img.shields.io/badge/reNgine--ng-v3.0.0-blue?style=for-the-badge)
![Patch](https://img.shields.io/badge/Patch-v1.5.0-green?style=for-the-badge)
![Nuclei Templates](https://img.shields.io/badge/Nuclei_Templates-v10.4.5-orange?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Production-brightgreen?style=for-the-badge)

**Custom dark theme, mobile navigation fix, visual improvement, dan nuclei templates update untuk reNgine-ng v3.0.0**

</div>

---

## 📋 Daftar Isi

- [Tentang Patch Ini](#-tentang-patch-ini)
- [Apa yang Diperbaiki](#-apa-yang-diperbaiki)
- [Persyaratan Sistem](#-persyaratan-sistem)
- [Instalasi Cepat](#-instalasi-cepat)
- [Instalasi Manual Lengkap](#-instalasi-manual-lengkap)
- [Struktur File](#-struktur-file)
- [Sistem Versioning](#-sistem-versioning)
- [Cara Update Patch](#-cara-update-patch)
- [Rollback / Pembatalan](#-rollback--pembatalan)
- [Troubleshooting](#-troubleshooting)
- [Changelog Lengkap](#-changelog-lengkap)

---

## 🎯 Tentang Patch Ini

Patch ini memperbaiki berbagai masalah visual pada **reNgine-ng v3.0.0** setelah upgrade dari versi sebelumnya. reNgine-ng v3.0.0 memperkenalkan design system baru berbasis Tailwind v4 + shadcn-svelte, namun beberapa elemen UI tidak tampil dengan benar karena konflik CSS.

**Repository resmi reNgine-ng:** https://github.com/yogeshojha/rengine  
**Patch ini berlaku untuk:** reNgine-ng v3.0.0  
**Server target:** Ubuntu/Debian dengan Docker Compose

---

## ✅ Apa yang Diperbaiki

### Patch v1.1.0 — Scan Results & Dashboard

| Masalah | Penyebab | Status |
|---------|----------|--------|
| Badge status scan tidak berwarna (semua abu-abu) | Base `.badge` override `background` semua variant | ✅ Fixed |
| Badge `bg-info`, `bg-warning`, `bg-danger` tidak terlihat | Tidak ada `color` property di `.bg-*` utilities | ✅ Fixed |
| Progress bar semua warna sama | `.progress-bar` base override `.bg-*` variant | ✅ Fixed |
| Teks ApexCharts tidak terlihat | SVG `tspan` butuh `fill`, bukan `color` | ✅ Fixed |
| Angka statistik dashboard tidak muncul | CSS counterup conflict | ✅ Fixed |

### Patch v1.2.0 — Mobile Navigation Dark Theme

| Masalah | Penyebab | Status |
|---------|----------|--------|
| Teks sidebar mobile hampir tidak terlihat | `.mobile-nav-menu` tidak punya CSS dark theme | ✅ Fixed |
| Blok "Switch Project" tampil putih/terang | Inline style `background: #f8f9fa` hardcoded | ✅ Fixed |
| Badge current project warna terang (`#e3f2fd`) | Inline style hardcoded di `top_bar.html` | ✅ Fixed |
| Submenu items tidak berwarna | Tidak ada CSS untuk `.mobile-submenu` | ✅ Fixed |

### Patch v1.3.0 — Hamburger Menu

| Masalah | Penyebab | Status |
|---------|----------|--------|
| Tombol hamburger background hitam solid | Theme CSS target class lama `.navbar-toggle`, bukan Bootstrap 5 `.navbar-toggler` | ✅ Fixed |
| Garis hamburger tidak terlihat | `.lines span` tidak di-style untuk selector baru | ✅ Fixed |
| Tidak ada animasi buka/tutup | `aria-expanded` state tidak di-handle | ✅ Fixed |

### Patch v1.5.0 — Nuclei Patterns "Invalid Path"

| Masalah | Penyebab | Status |
|---------|----------|--------|
| Settings → Nuclei menampilkan "Error! Invalid Path" | `tool.html` line 105: `{{ file.3 }}` salah index — mengirim nama direktori bukan filename ke API | ✅ Fixed |
| Template buttons tidak bisa diklik | `load_nuclei_template('nuclei-templates')` path tidak ada | ✅ Fixed |

> **Root cause**: Path `/home/rengine/nuclei-templates/ssrf_nagli.yaml` dipecah dengan `.split('/')` menghasilkan 5 bagian (index 0–4). `file.3` = `"nuclei-templates"` (salah), `file.4` = `"ssrf_nagli.yaml"` (benar).

---

## 💻 Persyaratan Sistem

```
OS          : Ubuntu 20.04+ / Debian 11+
reNgine-ng  : v3.0.0 (wajib — patch ini spesifik untuk versi ini)
Docker      : 24.x+
Docker Compose : v2.x+
RAM         : Minimum 4GB (rekomendasi 8GB)
CPU         : 2 core+
Disk        : Minimum 20GB free
Akses       : SSH root/sudo ke server
```

---

## ⚡ Instalasi Cepat

> **PENTING:** Buat backup dulu sebelum instalasi!

```bash
# 1. Download script instalasi otomatis
curl -fsSL https://raw.githubusercontent.com/pt-zenity/renginefix/main/install_patch.sh -o install_patch.sh

# 2. Beri permission eksekusi
chmod +x install_patch.sh

# 3. Jalankan sebagai user yang mengelola reNgine (bukan root)
bash install_patch.sh
```

---

## 🔧 Instalasi Manual Lengkap

### Langkah 1: Persiapan & Backup

```bash
# Login ke server
ssh zenity@103.31.205.120
# atau: ssh USER@IP_SERVER_KAMU

# Pastikan reNgine berjalan normal dulu
cd /home/rengine
docker ps --format "table {{.Names}}\t{{.Status}}"
# Pastikan semua container "healthy" atau "Up"

# Buat backup CSS original
cp /home/rengine/web/static/custom/custom.css \
   /home/rengine/web/static/custom/custom.css.bak_$(date +%Y%m%d_%H%M%S)

cp /home/rengine/web/staticfiles/custom/custom.css \
   /home/rengine/web/staticfiles/custom/custom.css.bak_$(date +%Y%m%d_%H%M%S)

# Backup template yang akan dimodifikasi
cp /home/rengine/web/templates/base/_items/top_bar.html \
   /home/rengine/web/templates/base/_items/top_bar.html.bak_$(date +%Y%m%d_%H%M%S)

echo "✅ Backup selesai"
```

### Langkah 2: Clone Repo Patch

```bash
# Clone repo ini ke /tmp (bukan ke folder reNgine!)
cd /tmp
git clone https://github.com/pt-zenity/renginefix.git
cd renginefix

echo "✅ Clone selesai"
ls -la
```

### Langkah 3: Apply Patch CSS

```bash
# Salin custom.css ke lokasi yang tepat
# PENTING: Ada DUA lokasi yang harus diupdate

# Lokasi 1: static/custom/ (source — digunakan untuk development)
cp /tmp/renginefix/web/static/custom/custom.css \
   /home/rengine/web/static/custom/custom.css

# Lokasi 2: staticfiles/custom/ (served langsung oleh nginx)
cp /tmp/renginefix/web/static/custom/custom.css \
   /home/rengine/web/staticfiles/custom/custom.css

# Verifikasi ukuran file (harus > 80KB)
wc -c /home/rengine/web/staticfiles/custom/custom.css
# Output yang diharapkan: ~84604 bytes

echo "✅ CSS patch applied"
```

### Langkah 4: Apply Patch Template HTML

```bash
# Salin top_bar.html yang sudah diperbaiki
cp /tmp/renginefix/web/templates/base/_items/top_bar.html \
   /home/rengine/web/templates/base/_items/top_bar.html

# Verifikasi inline style sudah diperbaiki (tidak boleh ada warna terang)
grep "background-color: #e3f2fd\|background-color: #f8f9fa" \
  /home/rengine/web/templates/base/_items/top_bar.html

# Jika output kosong = ✅ BENAR (tidak ada warna terang)
# Jika ada output = ❌ Template belum terpatch

echo "✅ Template patch applied"
```

### Langkah 5: Reload nginx

```bash
# Test konfigurasi nginx dulu
docker exec rengine-proxy-1 nginx -t

# Jika output: "syntax is ok" dan "test is successful"
docker exec rengine-proxy-1 nginx -s reload
echo "✅ nginx reloaded"
```

### Langkah 6: Restart Web Container

Diperlukan agar perubahan template HTML (top_bar.html) aktif di Django.

```bash
docker restart rengine-web-1

# Tunggu container healthy (±30 detik)
sleep 30
docker ps --format "table {{.Names}}\t{{.Status}}" | grep rengine-web-1
# Harus tampil: "Up X seconds (healthy)"

echo "✅ Web container restarted"
```

### Langkah 7: Verifikasi Instalasi

```bash
# 1. Cek CSS HTTP response
curl -skI https://localhost/staticfiles/custom/custom.css | \
  grep -E "HTTP|Content-Length|Cache-Control"
# Harapan: HTTP/2 200, Content-Length: ~84604

# 2. Cek CSS version header
curl -sk https://localhost/staticfiles/custom/custom.css | head -15
# Harapan: muncul @version: 3.0.1-patch.1.3.0

# 3. Cek badge-soft rules ada di CSS
curl -sk https://localhost/staticfiles/custom/custom.css | \
  grep -c "badge-soft"
# Harapan: 34 (atau lebih)

# 4. Cek mobile nav rules ada
curl -sk https://localhost/staticfiles/custom/custom.css | \
  grep -c "mobile-nav-menu"
# Harapan: 26 (atau lebih)

# 5. Cek hamburger toggler rules ada
curl -sk https://localhost/staticfiles/custom/custom.css | \
  grep -c "navbar-toggler"
# Harapan: 12 (atau lebih)

echo "✅ Verifikasi selesai"
```

### Langkah 8: Test di Browser

```
1. Buka https://DOMAIN_KAMU/dashboard/
2. Hard refresh: Ctrl+Shift+R (atau Cmd+Shift+R di Mac)
3. Cek desktop:
   - Dashboard card dengan angka statistik ✅
   - Badge status berwarna (info=biru, warning=kuning, danger=merah) ✅
   - Progress bar berwarna sesuai status ✅
   - Grafik ApexCharts dengan label terlihat ✅
4. Cek mobile (resize browser atau gunakan DevTools):
   - Tap hamburger menu → drawer muncul ✅
   - Teks menu terlihat jelas (terang di background gelap) ✅
   - Badge project saat ini berwarna biru gelap ✅
   - "Switch Project" header tampil gelap ✅
   - Tombol hamburger terlihat (tidak hitam/invisible) ✅
```

---

## 📁 Struktur File

```
renginefix/
├── README.md                          # File ini
├── install_patch.sh                   # Script instalasi otomatis
├── CHANGELOG.md                       # Changelog detail semua versi
├── web/
│   ├── static/
│   │   └── custom/
│   │       ├── custom.css             # ⭐ File CSS utama (DIMODIFIKASI)
│   │       ├── PATCH_VERSION          # Tracker versi patch
│   │       └── custom.js             # JavaScript (tidak dimodifikasi)
│   ├── staticfiles/
│   │   └── custom/
│   │       └── custom.css             # Mirror dari static/custom/ (SAMA)
│   └── templates/
│       └── base/
│           └── _items/
│               └── top_bar.html       # ⭐ Template navbar (DIMODIFIKASI)
└── patches/
    ├── v1.1.0_fix_badges_charts.css   # Patch individual v1.1.0
    ├── v1.2.0_mobile_dark_theme.css   # Patch individual v1.2.0
    └── v1.3.0_hamburger_fix.css       # Patch individual v1.3.0
```

### File yang Dimodifikasi

| File | Lokasi di Server | Perubahan |
|------|-----------------|-----------|
| `custom.css` | `/home/rengine/web/static/custom/custom.css` | +687 baris patch (dari 1048 → 2035 baris) |
| `custom.css` | `/home/rengine/web/staticfiles/custom/custom.css` | Mirror — identik dengan di atas |
| `top_bar.html` | `/home/rengine/web/templates/base/_items/top_bar.html` | 2 inline style diperbaiki |

---

## 🔢 Sistem Versioning

### Format Version

```
[reNgine base version]-patch.[patch major].[patch minor].[patch fix]

Contoh: 3.0.1-patch.1.3.0
         │         │ │ └── Fix (bugfix kecil)
         │         │ └──── Minor (fitur/fix baru)
         │         └────── Major (perubahan besar)
         └────────────────  Versi reNgine base
```

### Cek Versi Saat Ini

```bash
# Cek versi patch di header CSS
head -15 /home/rengine/web/static/custom/custom.css | grep @version

# Cek PATCH_VERSION tracker
cat /home/rengine/web/static/custom/PATCH_VERSION

# Cek dari live server
curl -sk https://DOMAIN_KAMU/staticfiles/custom/custom.css | head -15
```

### Riwayat Versi

| Versi | Tanggal | Keterangan |
|-------|---------|-----------|
| `3.0.1-patch.1.0.0` | 2026-07-05 | Initial dark theme design system |
| `3.0.1-patch.1.1.0` | 2026-07-05 | Fix badges, charts, progress bars |
| `3.0.1-patch.1.2.0` | 2026-07-05 | Fix mobile navigation dark theme |
| `3.0.1-patch.1.3.0` | 2026-07-05 | Fix hamburger menu button |
| `3.0.1-patch.1.4.0` | 2026-07-05 | Update nuclei-templates v10.3.8 → v10.4.5 |

---

## 🔄 Cara Update Patch

Setiap kali ada patch baru, ikuti langkah ini:

```bash
# 1. Pull perubahan terbaru
cd /tmp/renginefix
git pull origin main

# 2. Cek versi baru
cat web/static/custom/PATCH_VERSION

# 3. Backup CSS yang ada
cp /home/rengine/web/static/custom/custom.css \
   /home/rengine/web/static/custom/custom.css.bak_$(date +%Y%m%d_%H%M%S)

# 4. Apply update
cp /tmp/renginefix/web/static/custom/custom.css \
   /home/rengine/web/static/custom/custom.css

cp /tmp/renginefix/web/static/custom/custom.css \
   /home/rengine/web/staticfiles/custom/custom.css

# 5. Jika ada perubahan template
cp /tmp/renginefix/web/templates/base/_items/top_bar.html \
   /home/rengine/web/templates/base/_items/top_bar.html

# 6. Reload services
docker exec rengine-proxy-1 nginx -s reload
docker restart rengine-web-1

echo "✅ Update selesai"
```

---

## ↩️ Rollback / Pembatalan

Jika patch menyebabkan masalah, kembalikan ke versi backup:

```bash
# Lihat daftar backup yang tersedia
ls -la /home/rengine/web/static/custom/*.bak_*
ls -la /home/rengine/web/staticfiles/custom/*.bak_*

# Restore dari backup (ganti TIMESTAMP dengan waktu backup)
TIMESTAMP="20260705_103000"  # sesuaikan dengan nama file backup

cp /home/rengine/web/static/custom/custom.css.bak_${TIMESTAMP} \
   /home/rengine/web/static/custom/custom.css

cp /home/rengine/web/staticfiles/custom/custom.css.bak_${TIMESTAMP} \
   /home/rengine/web/staticfiles/custom/custom.css

# Restore template jika dibackup
cp /home/rengine/web/templates/base/_items/top_bar.html.bak_${TIMESTAMP} \
   /home/rengine/web/templates/base/_items/top_bar.html

# Reload services
docker exec rengine-proxy-1 nginx -s reload
docker restart rengine-web-1

echo "✅ Rollback selesai"
```

---

## 🐛 Troubleshooting

### Masalah: CSS tidak berubah setelah patch

```bash
# 1. Pastikan file sudah tercopy dengan benar
wc -c /home/rengine/web/staticfiles/custom/custom.css
# Harus ~84604 bytes

# 2. Reload nginx
docker exec rengine-proxy-1 nginx -t && docker exec rengine-proxy-1 nginx -s reload

# 3. Cek Cache-Control header
curl -skI https://localhost/staticfiles/custom/custom.css | grep Cache-Control
# Harus: Cache-Control: no-cache, must-revalidate

# 4. Di browser: hard refresh Ctrl+Shift+R
# Atau buka di incognito window
```

### Masalah: Template tidak berubah (mobile menu masih warna lama)

```bash
# Perubahan template butuh restart container
docker restart rengine-web-1

# Tunggu healthy
sleep 30
docker ps | grep rengine-web-1
```

### Masalah: Container tidak mau start setelah restart

```bash
# Cek log error
docker logs rengine-web-1 --tail 50

# Jika ada error Python/Django, cek apakah ada syntax error di template
# Restore template dari backup
ls /home/rengine/web/templates/base/_items/top_bar.html.bak_*
```

### Masalah: nginx gagal reload

```bash
# Test konfigurasi
docker exec rengine-proxy-1 nginx -t

# Jika error, cek log nginx
docker logs rengine-proxy-1 --tail 20
```

### Masalah: Badge masih tidak berwarna

```bash
# Pastikan CSS sudah mengandung badge-soft rules
curl -sk https://localhost/staticfiles/custom/custom.css | grep -c "badge-soft"
# Harus: 34

# Jika 0, berarti CSS belum terupdate
# Ulangi Langkah 3 (Apply Patch CSS)
```

### Masalah: Hamburger button masih hitam

```bash
# Pastikan rules ada di CSS
curl -sk https://localhost/staticfiles/custom/custom.css | grep -c "navbar-toggler"
# Harus: 12

# Hard refresh browser Ctrl+Shift+R
```

---

## 📝 Changelog Lengkap

### v1.5.0 — 2026-07-05 — Fix Nuclei Patterns "Invalid Path"
**File diubah:** `scanEngine/templates/scanEngine/settings/tool.html`

**Perubahan:**
```html
<!-- SEBELUM (broken) — line 105 -->
<span onclick="load_nuclei_template('{{file.3}}')">{{file.3}}</span>

<!-- SESUDAH (fixed) -->
<span onclick="load_nuclei_template('{{file.4}}')">{{file.4}}</span>
```

**Penjelasan:** Django split path `/home/rengine/nuclei-templates/file.yaml` menghasilkan index 0–4. `file.3` = nama direktori `"nuclei-templates"` (salah). `file.4` = nama file `"ssrf_nagli.yaml"` (benar).

---

### v1.4.0 — 2026-07-05 — Nuclei Templates Update v10.4.5
**Tindakan:** Update nuclei-templates dari v10.3.8 → v10.4.5 (+86 template baru, total 22.153 file)

---

### v1.3.0 — 2026-07-05 — Hamburger Menu Fix
**File diubah:** `web/static/custom/custom.css`

**Perubahan CSS yang ditambahkan:**
```css
/* Reset button.navbar-toggler */
#mobileHamburger, button.navbar-toggler {
  background: transparent !important;
  border: none !important;
  box-shadow: none !important;
}

/* .lines span — hamburger garis */
#mobileHamburger .lines span,
button.navbar-toggler .lines span {
  background-color: #c4c4c4 !important;
  height: 2px !important;
}

/* Animasi open state */
#mobileHamburger[aria-expanded="true"] .lines span:nth-child(1) {
  transform: translateY(6px) rotate(45deg) !important;
}
```

---

### v1.2.0 — 2026-07-05 — Mobile Navigation Dark Theme
**File diubah:**
- `web/static/custom/custom.css` (+203 baris)
- `web/templates/base/_items/top_bar.html` (2 inline style)

**Inline style diperbaiki di top_bar.html:**
```html
<!-- SEBELUM (baris 223) — warna terang -->
<div class="nav-link text-center" 
  style="background-color: #e3f2fd; color: #3283f6; font-weight: 600;">

<!-- SESUDAH — warna gelap -->
<div class="nav-link text-center" 
  style="background: rgba(109,142,240,.18); color: #6d8ef0; font-weight: 600;">

<!-- SEBELUM (baris 322) — header putih -->
<div class="nav-link mobile-submenu-header" 
  style="background-color: #f8f9fa; font-weight: 600; color: #495057;">

<!-- SESUDAH — header gelap -->
<div class="nav-link mobile-submenu-header" 
  style="background: rgba(255,255,255,.06); font-weight: 600; color: #a1a1a1;">
```

---

### v1.1.0 — 2026-07-05 — Scan Results & Dashboard Fix
**File diubah:** `web/static/custom/custom.css`

**Bug root cause:**
```css
/* SEBELUM (broken) — base .badge override semua variant */
.badge {
  background: var(--secondary) !important;   /* ← ini masalahnya */
  color: var(--secondary-foreground) !important;
  border: 1px solid var(--border) !important;
}

/* SESUDAH (fixed) — background/color dihapus dari base */
.badge {
  display: inline-flex;
  align-items: center;
  border-radius: var(--radius-md) !important;
  font-size: 11px !important;
  font-weight: 500 !important;
  padding: 3px 8px !important;
  white-space: nowrap;
  /* Tidak ada background/color — biarkan variant yang set */
}
```

---

### v1.0.0 — 2026-07-05 — Initial Dark Theme Design System
**File dibuat:** `web/static/custom/custom.css`

Design system awal dengan 1048 baris mencakup:
- CSS custom properties (design tokens)
- Layout: topbar, sidebar, content
- Components: cards, badges, buttons, forms, tables
- Dark mode overrides untuk Bootstrap 5

---

## 🔍 Nuclei Templates

Repo ini juga mendokumentasikan update **nuclei-templates** yang digunakan oleh reNgine-ng untuk vulnerability scanning.

### Versi Saat Ini

| Item | Version |
|------|---------|
| nuclei engine | v3.10.0 |
| nuclei-templates | **v10.4.5** (2026-06-23) |
| Total templates | 22,153 .yaml |
| Ukuran | 615 MB |

### Cara Update Nuclei Templates

```bash
# Masuk ke server
ssh USER@SERVER_IP

# Update templates (jalankan di dalam container)
docker exec rengine-celery-1 nuclei -ut -ud /home/rengine/nuclei-templates

# Cek versi setelah update
docker exec rengine-celery-1 nuclei -templates-version
```

### Riwayat Update Templates

| Tanggal | Versi Lama | Versi Baru | New Templates |
|---------|-----------|-----------|---------------|
| 2026-07-05 | v10.3.8 | **v10.4.5** | +86 |

---

## 🤝 Kontribusi

1. Fork repo ini
2. Buat branch: `git checkout -b fix/nama-fix`
3. Apply perubahan di `web/static/custom/custom.css` atau template
4. Update `PATCH_VERSION` dengan versi baru
5. Update bagian Changelog di `README.md`
6. Commit: `git commit -m "fix: deskripsi fix (patch v1.X.X)"`
7. Push dan buat Pull Request

---

## 📄 Lisensi

Patch ini berlisensi MIT. reNgine-ng sendiri berlisensi sesuai [lisensi resminya](https://github.com/yogeshojha/rengine/blob/main/LICENSE).

---

<div align="center">
Made with ❤️ for the reNgine-ng community<br>
<a href="https://github.com/pt-zenity/renginefix">github.com/pt-zenity/renginefix</a>
</div>
