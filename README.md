# 学伴小筑 · 内容数据仓库（单一真相源）

本仓库是小程序「学伴小筑」**内容数据的唯一维护地**。小程序运行时从这里读取大块内容（题库 / 单词），诗词 / 成语 / 语录仍本地打包，但其源码也在此备份，方便统一维护。

> 设计原则：**内容数据走云端版本号 + 覆盖式缓存，用户数据（错题本 / 连胜 / 习惯 / 观影）永远在用户手机本地，不参与云端合并。**

## 目录结构

```
github-data/
├── manifest.json          # 模块清单：每个模块的 version、remote 标记、文件列表、条数
├── data/
│   ├── quiz_0.json … quiz_3.json   # 题库 5690 题（切片，单文件 < 1MB，运行时远程拉取）
│   ├── word_0.json … word_2.json  # 单词 4009 词（切片，运行时远程拉取）
│   ├── poems.json                 # 诗词 169 首（本地打包，此处仅源码备份）
│   ├── idioms.json                # 成语 348 条（本地打包，此处仅源码备份）
│   └── quotes.json                # 语录 70 句（本地打包，此处仅源码备份）
└── push.sh                # 一键推送到 GitHub
```

## manifest.json 字段

```json
{
  "quiz":  { "version": 1, "remote": true,  "files": ["data/quiz_0.json", ...], "count": 5690 },
  "word":  { "version": 1, "remote": true,  "files": ["data/word_0.json", ...], "count": 4009 },
  "poems": { "version": 1, "remote": false, "file": "data/poems.json", "count": 169 }
}
```

- `remote: true` → 小程序运行时从 GitHub 拉取（题库 / 单词）。
- `remote: false` → 仅源码备份，小程序打包的是 `miniprogram/` 内的同名文件。

## 如何修改数据（无需重新发版）

1. 编辑对应的 `data/*.json`；
2. 把 `manifest.json` 里该模块的 `version` **+1**（如 1 → 2）；
3. 推送：`bash push.sh`；
4. 用户下次打开小程序（冷启动 / 切回前台），客户端发现云端版本更新 → 自动拉取覆盖缓存。**全程不需要重新打包、不需要提交微信审核。**

> 删除条目同理：从 JSON 删掉、升 version、推送即可。

## 如何推送到 GitHub

```sh
bash push.sh
```

脚本会 `git init`（首次）/ 提交 / 推到 `git@github.com:liumingmusic/xueban-data.git`（SSH）。
**前提**：GitHub 上已存在空仓库 `liumingmusic/xueban-data`，且本机已配置 SSH key（`ssh -T git@github.com` 可认证）。

若尚未建仓，任选一种建空仓：
- 网页：github.com → New repository → 命名 `xueban-data` → 不要勾 README；
- 或用 GitHub token（存于本机 keychain）：
  ```sh
  TOKEN=$(security find-internet-password -s github.com -a 7837372 -w)
  curl -X POST -H "Authorization: Bearer $TOKEN" https://api.github.com/user/repos -d '{"name":"xueban-data","private":false}'
  ```

## 小程序如何读取

`miniprogram/utils/remote.js`：

- 拉 `manifest.json` 比对本地 `version`；
- 仅当云端 `version > 本地` 时才重新拉取分片 JSON，否则直接读 Storage 缓存；
- 分片写入微信 Storage（单 key 上限 1MB，故题库 / 单词已切为多个 <1MB 文件）；
- 首次 / 缓存未命中 + 离线 → 模块内显示「离线模式」提示与「重试」按钮。

**微信公众平台必须配置 request 合法域名**：`raw.githubusercontent.com`（开发设置 → 服务器域名 → request 合法域名）。
