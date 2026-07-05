# Changelog

All notable changes to **reNgine-ng Custom Dark Theme Patch** are documented here.

Format: `[version] — YYYY-MM-DD — Summary`

---

## [1.4.0] — 2026-07-05 — Nuclei Templates Update to v10.4.5

### Updated
- **nuclei-templates** `v10.3.8` → **`v10.4.5`** (released 2026-06-23)
- **86 new templates** ditambahkan termasuk CVE-2026 terbaru
- Total templates: **22,153 .yaml files** (615 MB)

### Detail
| Item | Sebelum | Sesudah |
|------|---------|---------|
| nuclei-templates version | v10.3.8 | **v10.4.5** |
| nuclei engine | v3.10.0 | v3.10.0 |
| Total .yaml templates | ~22,153 | 22,153 (+86 new) |

### Template Categories (v10.4.5)
| Kategori | Templates |
|----------|-----------|
| http | 10,193 |
| workflows | 9,834 |
| cloud | 663 |
| file | 447 |
| code | 288 |
| dast | 249 |
| network | 277 |
| javascript | 104 |
| ssl | 38 |
| dns | 30 |
| headless | 24 |

### New CVE Templates Sample
- `CVE-2026-10795.yaml`
- `CVE-2026-31431.yaml`
- `CVE-2022-44727.yaml`
- `CVE-2021-3239.yaml`
- `CVE-2020-36884.yaml`
- +81 more

### How to Update Templates
```bash
# Di dalam container rengine-celery-1
docker exec rengine-celery-1 nuclei -ut -ud /home/rengine/nuclei-templates
```

### Files Changed
- `/home/rengine/nuclei-templates/` — updated in-place (server volume)

---

## [1.3.0] — 2026-07-05 — Hamburger Menu Button Fix

### Fixed
- **Hamburger menu button invisible** — tombol `#mobileHamburger` (Bootstrap 5 `button.navbar-toggler`) tampil dengan background hitam solid karena theme CSS hanya meng-handle class lama `.navbar-toggle`, bukan `.navbar-toggler`
- **Hamburger lines tidak terlihat** — `.lines span` di dalam `.navbar-toggler-icon` tidak punya color karena selector tidak match
- **Bootstrap SVG icon interference** — `navbar-toggler-icon` background-image SVG dari Bootstrap override custom lines

### Added
- CSS rules untuk `#mobileHamburger` dan `button.navbar-toggler`
- Hamburger lines dengan warna `#c4c4c4` (terang di background gelap)
- Hover effect: `rgba(255,255,255,.08)` + border-radius
- Animasi buka/tutup via `aria-expanded="true"` state:
  - Line 1: rotate 45°
  - Line 2: fade out
  - Line 3: rotate -45°
- `.navbar-custom .col-auto.d-lg-none` transparent background

### Files Changed
- `web/static/custom/custom.css` (+96 baris patch section)

---

## [1.2.0] — 2026-07-05 — Mobile Navigation Dark Theme

### Fixed
- **Mobile sidebar teks tidak terlihat** — `.mobile-nav-menu` sebelumnya tidak punya CSS dark theme sama sekali, teks gelap di background hampir hitam
- **"Switch Project" header tampil putih** — hardcoded inline `style="background-color: #f8f9fa; color: #495057"` di `top_bar.html` baris 322
- **Current project badge warna terang** — hardcoded inline `style="background-color: #e3f2fd; color: #3283f6"` di `top_bar.html` baris 223
- **Submenu items tidak berwarna** — tidak ada CSS untuk `.mobile-submenu`, `.mobile-submenu-header`

### Added
CSS rules baru (203 baris) untuk:
- `#mobileNavMenu` — background `#1a1a1a`
- `.mobile-nav-menu` — dark background, proper padding
- `.mobile-nav-menu .nav-link` — text `#d4d4d4`, icon `#6d8ef0`, hover effect
- `.mobile-nav-menu .nav-link.active` — text `#6d8ef0`, background highlight
- `.mobile-submenu-header` — uppercase section label, abu-abu gelap
- `.mobile-submenu` — indented dark bg + border kiri biru
- `.mobile-projects-submenu` — Switch Project list, dark + active highlight
- `.dropdown-divider` — warna border gelap `rgba(255,255,255,.08)`
- `@media (max-width: 991px)` — topbar gelap, search input gelap

### Template Changes
`web/templates/base/_items/top_bar.html`:
- Baris 223: `background-color: #e3f2fd; color: #3283f6` → `background: rgba(109,142,240,.18); color: #6d8ef0`
- Baris 322: `background-color: #f8f9fa; color: #495057` → `background: rgba(255,255,255,.06); color: #a1a1a1; ... text-transform: uppercase`

### Files Changed
- `web/static/custom/custom.css` (+203 baris)
- `web/templates/base/_items/top_bar.html` (2 inline style diubah)

---

## [1.1.0] — 2026-07-05 — Scan Results Dashboard Fix

### Fixed
- **Badge status scan semua abu-abu** — base `.badge` rule mengandung `background: var(--secondary) !important` yang override semua `.badge-soft-*` variant
- **Badge `bg-info`/`bg-warning`/`bg-danger` tidak terlihat** — tidak ada `color` property di `.bg-*` utilities
- **Progress bar semua warna sama** — `.progress-bar` base override variant `.bg-*`
- **Teks ApexCharts tidak terlihat** — SVG `tspan` perlu `fill`, bukan `color`
- **Angka statistik dashboard (counterup) tidak muncul** — CSS conflict
- **Duplicate `.badge` block** di section patch yang menyebabkan konflik

### Root Cause Detail
```css
/* SEBELUM — base .badge override semua variant */
.badge {
  background: var(--secondary) !important;   /* ← ROOT CAUSE */
  color: var(--secondary-foreground) !important;
  border: 1px solid var(--border) !important;
}

/* Hasilnya: .badge-soft-danger, .badge-soft-success, dll — semua warnanya */
/* sama: var(--secondary) = abu-abu gelap */
```

### Fix Applied
- Hapus `background`, `color`, `border` dari base `.badge` rule
- Tambah `color` ke semua `.bg-*` utilities
- Tambah `color` + `background` yang benar ke `.badge.bg-*` solid
- Tingkatkan specificity `.progress-bar.bg-*` dengan `.progress .progress-bar.bg-*`
- Tambah `fill: #a1a1a1` ke `.apexcharts-*-label tspan`

### Files Changed
- `web/static/custom/custom.css`:
  - Baris 134-136: hapus 3 property dari base `.badge`
  - Hapus duplicate `.badge {}` block di patch section
  - +206 baris patch (rengine30_fix2)

---

## [1.0.0] — 2026-07-05 — Initial Dark Theme Design System

### Added
Initial custom CSS dengan 1048 baris design system mencakup:

**Design Tokens (CSS Custom Properties):**
```css
--background: #141414
--foreground: #fafafa
--sidebar: #1f1f1f
--sidebar-foreground: #fafafa
--sidebar-primary: #6d8ef0
--border: #2c2c2c
--muted-foreground: #a1a1a1
--primary: #6d8ef0
```

**Components:**
- Cards dengan dark background
- Badge variants (badge-soft-*, bg-*)
- Button variants
- Form controls
- Table dark theme
- Progress bars
- Modal dark theme
- Dropdown dark theme

**Layout:**
- Topbar/navbar dark
- Sidebar dark (horizontal layout)
- Content area dark background

**Typography:**
- DM Sans font integration
- JetBrains Mono for code

### Files Changed
- `web/static/custom/custom.css` (dibuat dari awal, 1048 baris)
