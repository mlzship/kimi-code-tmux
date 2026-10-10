# kimi-code-tmux

`kc` —— 在 tmux 会话中启动和管理 [Kimi Code CLI](https://www.kimi.com/code) 的便捷脚本。

## 功能

- `kc [会话名]` — 在 tmux 会话(默认名 `kimi`)中启动 Kimi Code,并开启鼠标模式;会话已存在则直接接入
- `kc upgrade [会话名]` — 一键升级 Kimi Code 到最新版,并原地重启 tmux 会话中的实例
  - 先执行 `kimi upgrade -y` 更新二进制
  - 再用 `tmux respawn-pane -k` 终止旧进程,以 `kimi --continue` 重启,会话历史自动恢复
  - 注意:重启会强制终止旧进程,请确保实例没有正在执行的任务

## 安装

```bash
sudo curl -fsSL https://raw.githubusercontent.com/mlzship/kimi-code-tmux/main/kc -o /usr/local/bin/kc
sudo chmod +x /usr/local/bin/kc
```

## 依赖

- `bash`
- `tmux`
- `kimi`(Kimi Code CLI)
