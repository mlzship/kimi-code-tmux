# kimi-code-tmux

`kc` —— 在 tmux 会话中启动和管理 [Kimi Code CLI](https://www.kimi.com/code) 的便捷脚本。

## 用法

```
kc [-C 目录] [会话名] [-- kimi参数...]  启动或接入会话(默认会话名: kimi)
kc ls [-a|--all]                       列出受管会话及 kimi 运行状态(--all 显示全部 tmux 会话)
kc peek [会话名] [行数]                 查看实例最近输出(默认 40 行)
kc restart [-y|--yes] [会话名]          原地重启实例(kimi --session 精确恢复原会话,保留历史)
kc upgrade [-y|--yes] [--all] [会话名]  升级 kimi 并重启实例
kc stop [会话名]                        结束整个 tmux 会话
kc -h|--help                           显示帮助
kc -V|--version                        显示 kc 版本
```

## 特性

- **一键升级**:`kc upgrade` 先执行 `kimi upgrade -y`,再用 `tmux respawn-pane -k` 终止旧进程、
  原地重启 —— 新进程加载新版二进制
  - **精确恢复原会话**:实例绑定的 kimi 会话 id 记录在 tmux 选项 `@kc_session_id` 中,
    重启时用 `kimi --session <id>` 恢复原来的那一个会话,而不是像 `kimi --continue` 那样
    捡同目录下"最近"的会话(同目录有多个会话时会捡错);无记录时回退 `--continue`
    并在启动后自动捕获绑定关系供下次使用
  - 二进制已是最新时,还会检查运行中的实例是否过旧(旧进程 exe 指向已删除文件),只重启真正过旧的实例
  - 重启前检测实例 CPU 占用,疑似正在执行任务时要求确认(`-y` 跳过)
  - `--all` 批量更新所有受管会话
  - 多窗口/多面板时精确定位运行 kimi 的面板(兼容 `kimi`/`kimi-code` 两种进程名)
- **参数透传**:`kc work -- --yolo` 启动时把参数传给 kimi,并记录在会话中,
  `restart`/`upgrade` 时自动复用
- **tmux 内智能切换**:已在 tmux 中执行 `kc` 时自动 `switch-client`,无需先 detach
- **会话管理**:`ls` 总览(版本/PID/运行时长)、`peek` 不进会话也能看实例输出、`stop` 结束会话
- 新会话自动开启鼠标模式,支持 `-C` 指定工作目录

## 安装

一行命令(自动检查并安装缺失依赖,包括 Kimi Code CLI 本体):

```bash
curl -fsSL https://raw.githubusercontent.com/mlzship/kimi-code-tmux/main/install.sh | bash
```

没有 curl 时可用 wget:

```bash
wget -qO- https://raw.githubusercontent.com/mlzship/kimi-code-tmux/main/install.sh | bash
```

安装脚本会:

1. 检查 `bash` / `tmux` / `procps`(`ps`,`top`) / `curl`或`wget`,缺失时自动用系统包管理器安装
   (支持 apt / dnf / yum / pacman / apk / zypper,即 Debian、Ubuntu、RHEL、Fedora、Arch、Alpine、openSUSE 等常见发行版)
2. 未检测到 `kimi` 时,调用 [Kimi Code 官方安装脚本](https://www.kimi.com/code/docs/en/kimi-code-cli/guides/getting-started.html)安装
3. 把 `kc` 安装到 `/usr/local/bin`(无 root/sudo 权限时退到 `~/.local/bin`),并尽量安装 bash 补全

也可手动安装:

```bash
sudo curl -fsSL https://raw.githubusercontent.com/mlzship/kimi-code-tmux/main/kc -o /usr/local/bin/kc
sudo chmod +x /usr/local/bin/kc
```

## 依赖

- `bash` (>= 4)
- `tmux`
- `kimi`(Kimi Code CLI)
- `procps`(`ps`/`top`,用于运行时长和繁忙检测,一般系统自带)
