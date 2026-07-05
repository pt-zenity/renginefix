#!/usr/bin/env bash
# =============================================================================
# install_patch.sh — reNgine-ng Custom Dark Theme Patch Installer
# Version: 1.3.0
# Author : pt-zenity
# Repo   : https://github.com/pt-zenity/renginefix
# =============================================================================
set -euo pipefail

# ── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'; BOLD='\033[1m'

log()    { echo -e "${GREEN}[✅ OK]${NC} $1"; }
warn()   { echo -e "${YELLOW}[⚠️  WARN]${NC} $1"; }
error()  { echo -e "${RED}[❌ ERROR]${NC} $1"; exit 1; }
info()   { echo -e "${CYAN}[ℹ️  INFO]${NC} $1"; }
header() { echo -e "\n${BOLD}${BLUE}══════════════════════════════════════${NC}"; echo -e "${BOLD}${BLUE}  $1${NC}"; echo -e "${BOLD}${BLUE}══════════════════════════════════════${NC}\n"; }

# ── Config ───────────────────────────────────────────────────────────────────
RENGINE_WEB_DIR="${RENGINE_WEB_DIR:-/home/rengine/web}"
RENGINE_STATICFILES="${RENGINE_WEB_DIR}/staticfiles"
RENGINE_STATIC="${RENGINE_WEB_DIR}/static"
RENGINE_TEMPLATES="${RENGINE_WEB_DIR}/templates"
PROXY_CONTAINER="${PROXY_CONTAINER:-rengine-proxy-1}"
WEB_CONTAINER="${WEB_CONTAINER:-rengine-web-1}"
PATCH_CSS_SOURCE="$(dirname "$0")/web/static/custom/custom.css"
PATCH_TOPBAR_SOURCE="$(dirname "$0")/web/templates/base/_items/top_bar.html"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# ── Banner ───────────────────────────────────────────────────────────────────
echo -e "${BOLD}${CYAN}"
cat << 'EOF'
  ██████╗ ███████╗███╗   ██╗ ██████╗ ██╗███╗   ██╗███████╗    ███████╗██╗██╗  ██╗
  ██╔══██╗██╔════╝████╗  ██║██╔════╝ ██║████╗  ██║██╔════╝    ██╔════╝██║╚██╗██╔╝
  ██████╔╝█████╗  ██╔██╗ ██║██║  ███╗██║██╔██╗ ██║█████╗      █████╗  ██║ ╚███╔╝
  ██╔══██╗██╔══╝  ██║╚██╗██║██║   ██║██║██║╚██╗██║██╔══╝      ██╔══╝  ██║ ██╔██╗
  ██║  ██║███████╗██║ ╚████║╚██████╔╝██║██║ ╚████║███████╗    ██║     ██║██╔╝ ██╗
  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝╚══════╝    ╚═╝     ╚═╝╚═╝  ╚═╝
EOF
echo -e "${NC}"
echo -e "  ${BOLD}reNgine-ng Custom Dark Theme Patch Installer${NC}"
echo -e "  Version: ${GREEN}1.3.0${NC} | Repo: ${CYAN}github.com/pt-zenity/renginefix${NC}"
echo ""

# ── Pre-flight checks ────────────────────────────────────────────────────────
header "Pre-flight Checks"

# Check if running as correct user (not root)
if [[ $EUID -eq 0 ]]; then
    warn "Berjalan sebagai root. Disarankan jalankan sebagai user 'zenity' atau yang manage reNgine."
fi

# Check docker availability
if ! command -v docker &>/dev/null; then
    error "Docker tidak ditemukan. Pastikan Docker terinstall."
fi
log "Docker tersedia: $(docker --version | cut -d' ' -f3)"

# Check reNgine web directory
if [[ ! -d "$RENGINE_WEB_DIR" ]]; then
    error "Direktori reNgine tidak ditemukan: ${RENGINE_WEB_DIR}\nAtur path dengan: RENGINE_WEB_DIR=/path/ke/web bash install_patch.sh"
fi
log "reNgine web dir: ${RENGINE_WEB_DIR}"

# Check reNgine version
RENGINE_VERSION=$(cat "${RENGINE_WEB_DIR}/reNgine/version.txt" 2>/dev/null || echo "unknown")
info "reNgine version: ${RENGINE_VERSION}"
if [[ "$RENGINE_VERSION" != "3.0."* ]]; then
    warn "Patch ini didesain untuk reNgine v3.0.x. Versi Anda: ${RENGINE_VERSION}"
    read -p "Lanjutkan? [y/N]: " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || error "Dibatalkan."
fi

# Check patch source files
if [[ ! -f "$PATCH_CSS_SOURCE" ]]; then
    error "File patch CSS tidak ditemukan: ${PATCH_CSS_SOURCE}\nPastikan jalankan script dari dalam folder repo renginefix."
fi
log "Patch CSS source ditemukan"

if [[ ! -f "$PATCH_TOPBAR_SOURCE" ]]; then
    warn "File patch top_bar.html tidak ditemukan. Skip template patch."
    SKIP_TEMPLATE=true
else
    log "Patch template source ditemukan"
    SKIP_TEMPLATE=false
fi

# Check containers running
if ! docker ps --format '{{.Names}}' | grep -q "^${PROXY_CONTAINER}$"; then
    warn "Container ${PROXY_CONTAINER} tidak berjalan. nginx reload akan dilewati."
    SKIP_NGINX=true
else
    log "Container ${PROXY_CONTAINER} berjalan"
    SKIP_NGINX=false
fi

if ! docker ps --format '{{.Names}}' | grep -q "^${WEB_CONTAINER}$"; then
    warn "Container ${WEB_CONTAINER} tidak berjalan. Restart akan dilewati."
    SKIP_RESTART=true
else
    log "Container ${WEB_CONTAINER} berjalan"
    SKIP_RESTART=false
fi

# ── Backup ───────────────────────────────────────────────────────────────────
header "Membuat Backup"

backup_file() {
    local src="$1"
    if [[ -f "$src" ]]; then
        cp "$src" "${src}.bak_${TIMESTAMP}"
        log "Backup: ${src}.bak_${TIMESTAMP}"
    else
        warn "File tidak ada, skip backup: ${src}"
    fi
}

backup_file "${RENGINE_STATIC}/custom/custom.css"
backup_file "${RENGINE_STATICFILES}/custom/custom.css"
backup_file "${RENGINE_TEMPLATES}/base/_items/top_bar.html"

# ── Apply CSS Patch ──────────────────────────────────────────────────────────
header "Apply Patch CSS"

# Copy ke static (source)
cp "$PATCH_CSS_SOURCE" "${RENGINE_STATIC}/custom/custom.css"
log "CSS disalin ke: ${RENGINE_STATIC}/custom/custom.css"

# Copy ke staticfiles (nginx-served)
cp "$PATCH_CSS_SOURCE" "${RENGINE_STATICFILES}/custom/custom.css"
log "CSS disalin ke: ${RENGINE_STATICFILES}/custom/custom.css"

# Verifikasi ukuran
CSS_SIZE=$(wc -c < "${RENGINE_STATICFILES}/custom/custom.css")
CSS_LINES=$(wc -l < "${RENGINE_STATICFILES}/custom/custom.css")
log "CSS size: ${CSS_SIZE} bytes, ${CSS_LINES} baris"

if [[ $CSS_SIZE -lt 50000 ]]; then
    warn "CSS tampak terlalu kecil (${CSS_SIZE} bytes). Cek apakah file patch lengkap."
fi

# Verifikasi version header
CSS_VERSION=$(head -5 "${RENGINE_STATICFILES}/custom/custom.css" | grep "@version" | awk '{print $NF}')
log "CSS version: ${CSS_VERSION}"

# ── Apply Template Patch ─────────────────────────────────────────────────────
header "Apply Patch Template"

if [[ "$SKIP_TEMPLATE" == "false" ]]; then
    cp "$PATCH_TOPBAR_SOURCE" "${RENGINE_TEMPLATES}/base/_items/top_bar.html"
    log "Template disalin ke: ${RENGINE_TEMPLATES}/base/_items/top_bar.html"

    # Verifikasi inline style sudah benar
    BAD_STYLES=$(grep -c "background-color: #e3f2fd\|background-color: #f8f9fa" \
        "${RENGINE_TEMPLATES}/base/_items/top_bar.html" 2>/dev/null || echo "0")

    if [[ "$BAD_STYLES" -eq 0 ]]; then
        log "Template verified: inline style hardcoded sudah diperbaiki"
    else
        warn "Ditemukan ${BAD_STYLES} inline style lama. Template mungkin belum terpatch."
    fi
else
    info "Template patch dilewati (file source tidak ditemukan)"
fi

# ── Reload nginx ─────────────────────────────────────────────────────────────
header "Reload nginx"

if [[ "$SKIP_NGINX" == "false" ]]; then
    if docker exec "$PROXY_CONTAINER" nginx -t 2>&1 | grep -q "successful"; then
        docker exec "$PROXY_CONTAINER" nginx -s reload
        log "nginx berhasil di-reload"
    else
        error "nginx config test gagal. Cek: docker exec ${PROXY_CONTAINER} nginx -t"
    fi
else
    warn "nginx reload dilewati (container tidak berjalan)"
fi

# ── Restart Web Container ────────────────────────────────────────────────────
header "Restart Web Container"

if [[ "$SKIP_RESTART" == "false" ]]; then
    info "Merestart ${WEB_CONTAINER}..."
    docker restart "$WEB_CONTAINER"

    info "Menunggu container healthy (maks 60 detik)..."
    for i in $(seq 1 12); do
        sleep 5
        STATUS=$(docker inspect --format '{{.State.Health.Status}}' "$WEB_CONTAINER" 2>/dev/null || echo "unknown")
        if [[ "$STATUS" == "healthy" ]]; then
            log "${WEB_CONTAINER} healthy setelah $((i*5)) detik"
            break
        fi
        if [[ $i -eq 12 ]]; then
            warn "${WEB_CONTAINER} belum healthy setelah 60 detik. Cek: docker logs ${WEB_CONTAINER} --tail 30"
        fi
        echo -n "."
    done
    echo ""
else
    warn "Container restart dilewati (container tidak berjalan)"
fi

# ── Verifikasi Final ─────────────────────────────────────────────────────────
header "Verifikasi Final"

# Test HTTP response
if command -v curl &>/dev/null; then
    HTTP_STATUS=$(curl -skI https://localhost/staticfiles/custom/custom.css | grep "^HTTP" | awk '{print $2}')
    SERVED_SIZE=$(curl -sk https://localhost/staticfiles/custom/custom.css | wc -c)
    BADGE_COUNT=$(curl -sk https://localhost/staticfiles/custom/custom.css | grep -c "badge-soft" || echo "0")
    MOBILE_COUNT=$(curl -sk https://localhost/staticfiles/custom/custom.css | grep -c "mobile-nav-menu" || echo "0")
    TOGGLE_COUNT=$(curl -sk https://localhost/staticfiles/custom/custom.css | grep -c "navbar-toggler" || echo "0")

    log "HTTP Status: ${HTTP_STATUS}"
    log "CSS served: ${SERVED_SIZE} bytes"
    log "badge-soft rules: ${BADGE_COUNT}"
    log "mobile-nav-menu rules: ${MOBILE_COUNT}"
    log "navbar-toggler rules: ${TOGGLE_COUNT}"
fi

# ── Summary ──────────────────────────────────────────────────────────────────
header "Instalasi Selesai! 🎉"

echo -e "  ${GREEN}✅ CSS patch applied${NC}    — ${CSS_SIZE} bytes, ${CSS_LINES} baris"
if [[ "$SKIP_TEMPLATE" == "false" ]]; then
    echo -e "  ${GREEN}✅ Template patched${NC}     — inline style diperbaiki"
fi
if [[ "$SKIP_NGINX" == "false" ]]; then
    echo -e "  ${GREEN}✅ nginx reloaded${NC}"
fi
if [[ "$SKIP_RESTART" == "false" ]]; then
    echo -e "  ${GREEN}✅ Web container restarted${NC}"
fi

echo ""
echo -e "  ${BOLD}Langkah selanjutnya:${NC}"
echo -e "  1. Buka browser → https://DOMAIN_KAMU/dashboard/"
echo -e "  2. Hard refresh: ${BOLD}Ctrl+Shift+R${NC}"
echo -e "  3. Cek tampilan di desktop dan mobile"
echo ""
echo -e "  ${CYAN}Backup tersimpan dengan suffix: .bak_${TIMESTAMP}${NC}"
echo -e "  ${CYAN}Dokumentasi: https://github.com/pt-zenity/renginefix${NC}"
echo ""
