## 本次升级（v0.6.0 → v0.6.5）

包含 5 个版本的改动；每项附对应 Git 提交。源码链接需要源码仓库访问权限。

[完整代码差异](https://github.com/blingbling2333/TabExtend/compare/64fb6752b911eaa9c059bccdf329828b1c1d844e...2d727e25503df8894049dd471565b92cf2d24414)

### v0.6.1

将公开下载与发布仓库更名为 Open-TabExtend，并同步更新扩展内检查更新与自动发版地址。

- 公开下载仓库更名为 blingbling2333/Open-TabExtend，同步更新扩展内置更新检查与下载跳转地址。
- 同步更新 GitHub Actions 自动发版工作流、暂存与核验脚本以及发布说明中的公开仓库地址。

[Git d24b021](https://github.com/blingbling2333/TabExtend/commit/d24b021eccc50bb2f63a8e56763fd93601ddde50)

### v0.6.2

统一标签页整理器、稍后查看与侧栏常访列表的悬停信息框样式，与主看板链接提示框保持一致。

- 移除打开的标签页、稍后查看与侧栏常访条目上的浏览器原生 title 灰框，改为复用主看板统一的深色圆角 .link-tooltip，支持长网址中间省略、自动避让视口边缘与柔和淡入淡出。
- 为标签页整理器与稍后查看中的行操作按钮和音效开关补充紧凑型深色悬停提示胶囊，避免在多列卡片或滚动容器边缘被裁切。

[Git 154184f](https://github.com/blingbling2333/TabExtend/commit/154184f75e6b54aa632e907b6db71c639087ec3b)

![打开的标签页与稍后查看在浅色与深色主题下统一使用深色圆角悬停信息框的效果](https://github.com/blingbling2333/Open-TabExtend/releases/download/v0.6.5/v0.6.2-organizer-styled-tooltip.webp)

### v0.6.3

将标签页整理器的操作反馈统一接入右下角通用绿色通知提示框（Toast），移除独立悬浮提示条。

- 关闭标签页、清理重复页、放入稍后查看以及收藏到分组等操作反馈改为调用应用右下角通用 Toast（统一使用绿色提示样式），与主看板通知保持视觉和交互一致。
- 保留弹窗内表单提交失败时的就地错误提示，移除整理页底部独立的 .open-tabs-feedback 悬浮条。

[Git ef81eaf](https://github.com/blingbling2333/TabExtend/commit/ef81eaf387020bdfe53db9bd9ca005c400475dbd)

![标签页整理器关闭标签与收藏操作统一使用右下角绿色通用提示框的效果](https://github.com/blingbling2333/Open-TabExtend/releases/download/v0.6.5/v0.6.3-organizer-unified-toast.webp)

### v0.6.4

支持通过自有域名 tabextend.iambling.com 直连 Google OIDC 登录，避免授权页展示默认 Supabase 子域名。

- 在手机站新增 /auth/callback 安全中转页（严格白名单回跳至固定扩展 ID 或同源首页）与中英双语 /privacy 隐私政策页，并在手机登录页补充隐私政策入口。
- 桌面扩展与手机网页在配置 VITE_GOOGLE_CLIENT_ID 后改用 Google OIDC id_token + SHA-256 nonce + Supabase signInWithIdToken 登录，未配置或本地调试时自动回退至原有 PKCE 流程。
- 发布工作流接入可选的 VITE_GOOGLE_CLIENT_ID 与 VITE_GOOGLE_AUTH_CALLBACK_URL 构建变量。

[Git 184f5b8](https://github.com/blingbling2333/TabExtend/commit/184f5b82094ec9bd659b304112e04fac51368a9a)

### v0.6.5

收紧左上角侧栏入口图标外框尺寸与圆角，使其与顶部工具栏及下方快捷图标比例更协调。

- 将收起态左侧栏顶部图标容器（.rail-count）从 40×40px（圆角 14px）微调为 34×34px（圆角 11px），内部图标保持 20×20px，边框留白由 10px 收紧至 7px 并与右侧顶栏高度对齐。
- 同步微调笔记模式下的计数角标尺寸（20×20px）与阴影层次。

[Git 2d727e2](https://github.com/blingbling2333/TabExtend/commit/2d727e25503df8894049dd471565b92cf2d24414)

![左上角侧栏入口图标外框收紧为 34×34px 并与顶栏对齐后的效果](https://github.com/blingbling2333/Open-TabExtend/releases/download/v0.6.5/v0.6.5-compact-rail-logo.webp)
