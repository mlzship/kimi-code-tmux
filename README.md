# kimi-code-tmux

`kc` —— 在 tmux 会话中启动和管理 [Kimi Code CLI](https://www.kimi.com/code) 的便捷脚本。

## 用法

```
kc [-C 目录] [会话名] [-- kimi参数...]  启动或接入会话(默认会话名: kimi)
kc ls                                  列出所有会话及 kimi 运行状态
kc peek [会话名] [行数]                 查看实例最近输出(默认 40 行)
kc restart [-y|--yes] [会话名]          原地重启实例(kimi --continue,保留会话历史)
kc upgrade [-y|--yes] [--all] [会话名]  升级 kimi 并重启实例
kc stop [会话名]                        结束整个 tmux 会话
kc -h|--help                           显示帮助
kc -V|--version                        显示 kc 版本
```

## 特性

- **一键升级**:`kc upgrade` 先执行 `kimi upgrade -y`,再用 `tmux respawn-pane -k` 终止旧进程、
  以 `kimi --continue` 原地重启 —— 新进程加载新版二进制,会话历史自动恢复
  - 已是最新版时自动跳过重启,不打断实例
  - 重启前检测实例 CPU 占用,疑似正在执行任务时要求确认(`-y` 跳过)
  - `--all` 批量更新所有受管会话
  - 多窗口/多面板时精确定位运行 kimi 的面板
- **参数透传**:`kc work -- --yolo` 启动时把参数传给 kimi,并记录在会话中,
  `restart`/`upgrade` 时自动复用
- **tmux 内智能切换**:已在 tmux 中执行 `kc` 时自动 `switch-client`,无需先 detach
- **会话管理**:`ls` 总览(版本/PID/运行时长)、`peek` 不进会话也能看实例输出、`stop` 结束会话
- 新会话自动开启鼠标模式,支持 `-C` 指定工作目录

## 安装

```bash
sudo curl -fsSL https://raw.githubusercontent.com/mlzship/kimi-code-tmux/main/kc -o /usr/local/bin/kc
sudo chmod +x /usr/local/bin/kc
```

可选:bash 补全

```bash
sudo curl -fsSL https://raw.githubusercontent.com/mlzship/kimi-code-tmux/main/completion/kc.bash -o /etc/bash_completion.d/kc
```

## 依赖

- `bash` (>= 4)
- `tmux`
- `kimi`(Kimi Code CLI)
- `procps`(`ps`/`top`,用于运行时长和繁忙检测,一般系统自带)
