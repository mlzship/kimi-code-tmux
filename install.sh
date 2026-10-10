#!/usr/bin/env bash
# kc 一键安装脚本
#   - 检查并安装依赖: bash / tmux / procps(ps,top) / curl或wget
#   - 未安装 kimi 时,调用 Kimi Code 官方安装脚本
#   - 安装 kc 到 /usr/local/bin(无 root/sudo 时退到 ~/.local/bin)
# 用法: curl -fsSL https://raw.githubusercontent.com/mlzship/kimi-code-tmux/main/install.sh | bash
# 支持: Debian/Ubuntu(apt) RHEL/Fedora(dnf/yum) Arch(pacman) Alpine(apk) openSUSE(zypper)

set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/mlzship/kimi-code-tmux/main"
KIMI_INSTALL_URL="https://code.kimi.com/kimi-code/install.sh"

info() { echo "==> $*"; }
warn() { echo "警告: $*" >&2; }
die() { echo "错误: $*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

IS_ROOT=0
[ "$(id -u)" -eq 0 ] && IS_ROOT=1
SUDO=""
if [ "$IS_ROOT" = 0 ] && have sudo; then
    SUDO="sudo"
fi

fetch() {
    if have curl; then
        curl -fsSL "$1"
    elif have wget; then
        wget -qO- "$1"
    else
        die "缺少 curl/wget,无法下载"
    fi
}

detect_pkg_mgr() {
    local m
    for m in apt-get dnf yum pacman apk zypper; do
        if have "$m"; then
            PKG_MGR="$m"
            return 0
        fi
    done
    return 1
}

pkg_update() {
    if [ "$PKG_MGR" = "apt-get" ]; then
        $SUDO apt-get update -qq
    fi
}

pkg_install() {
    local pkgs=() p
    for p in "$@"; do
        if [ "$p" = "procps" ]; then
            case "$PKG_MGR" in
                dnf|yum|pacman) pkgs+=(procps-ng) ;;
                *) pkgs+=(procps) ;;
            esac
        else
            pkgs+=("$p")
        fi
    done
    info "使用 $PKG_MGR 安装: ${pkgs[*]}"
    case "$PKG_MGR" in
        apt-get) $SUDO apt-get install -y "${pkgs[@]}" ;;
        dnf) $SUDO dnf install -y "${pkgs[@]}" ;;
        yum) $SUDO yum install -y "${pkgs[@]}" ;;
        pacman) $SUDO pacman -Sy --noconfirm --needed "${pkgs[@]}" ;;
        apk) $SUDO apk add "${pkgs[@]}" ;;
        zypper) $SUDO zypper --non-interactive install "${pkgs[@]}" ;;
    esac
}

ensure_deps() {
    local missing=()
    have bash || missing+=(bash)
    have tmux || missing+=(tmux)
    { have ps && have top; } || missing+=(procps)
    { have curl || have wget; } || missing+=(curl)
    if [ ${#missing[@]} -eq 0 ]; then
        info "系统依赖已就绪 (bash, tmux, procps, curl/wget)"
        return
    fi
    if [ "$IS_ROOT" = 0 ] && [ -z "$SUDO" ]; then
        die "缺少依赖: ${missing[*]};且当前非 root 也没有 sudo,请手动安装后重试"
    fi
    detect_pkg_mgr || die "缺少依赖: ${missing[*]};未找到支持的包管理器(支持 apt/dnf/yum/pacman/apk/zypper),请手动安装后重试"
    info "安装缺失依赖: ${missing[*]}"
    pkg_update
    pkg_install "${missing[@]}"
}

ensure_kimi() {
    export PATH="$HOME/.kimi-code/bin:$PATH"
    if have kimi; then
        info "kimi 已安装 ($(kimi --version 2>/dev/null | head -1))"
        return
    fi
    info "未检测到 kimi,使用官方脚本安装 Kimi Code CLI..."
    fetch "$KIMI_INSTALL_URL" | bash
    hash -r
    have kimi || die "kimi 安装后仍未在 PATH 中找到,请参照 https://www.kimi.com/code 的安装说明手动安装"
    info "kimi 安装完成 ($(kimi --version 2>/dev/null | head -1))"
}

install_kc() {
    local dest
    if [ "$IS_ROOT" = 1 ] || [ -n "$SUDO" ]; then
        dest="/usr/local/bin/kc"
        info "安装 kc -> $dest"
        fetch "$REPO_RAW/kc" | $SUDO tee "$dest" >/dev/null
        $SUDO chmod 755 "$dest"
        if [ -d /etc/bash_completion.d ]; then
            if fetch "$REPO_RAW/completion/kc.bash" | $SUDO tee /etc/bash_completion.d/kc >/dev/null; then
                info "bash 补全 -> /etc/bash_completion.d/kc(重新登录后生效)"
            fi
        fi
    else
        dest="$HOME/.local/bin/kc"
        warn "无 root/sudo 权限,kc 安装到用户目录: $dest"
        mkdir -p "$HOME/.local/bin"
        fetch "$REPO_RAW/kc" >"$dest"
        chmod 755 "$dest"
        case ":$PATH:" in
            *":$HOME/.local/bin:"*) ;;
            *) warn "请把 ~/.local/bin 加入 PATH" ;;
        esac
    fi
    info "安装完成: $("$dest" -V)"
    echo
    echo "下一步:"
    echo "  1. 首次使用先运行 kimi 并在界面里 /login 登录(若尚未登录)"
    echo "  2. 运行 kc 即可在 tmux 中启动 Kimi Code;kc -h 查看全部功能"
}

main() {
    ensure_deps
    ensure_kimi
    install_kc
}

main "$@"
