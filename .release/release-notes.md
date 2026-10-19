## 本次升级（v0.5.84 → v0.5.90）

包含 6 个版本的改动；每项附对应 Git 提交。源码链接需要源码仓库访问权限。

[完整代码差异](https://github.com/blingbling2333/TabExtend/compare/74dfb9603b00aa6b9b08d33820e6ce19783535ea...3f6dc761f97df70ea93b6a110ef814e23944b026)

### v0.5.85

侧栏悬停立即展开，同时保持快捷图标稳定可点。

- 移除 350ms 悬停等待；移入摘要或空白区域即可展开。
- 快捷图标、两侧留白和图标间隙保持折叠，鼠标靠近及点击时不会被展开动画挤走。
- 保留键盘操作、底部搜索以及窄窗口下的点击行为。

[Git 23c566f](https://github.com/blingbling2333/TabExtend/commit/23c566f54913296006cd43be1af870921c158eee)

### v0.5.86

侧栏展开带轻微回弹，内容同步滑入，收起更利落。

- 展开约 360ms、收起约 220ms，展开末端约 4px 轻微回弹。
- 固定内容宽度，避免动画中标题反复换行；连续移入移出可平滑反向。
- 遵循系统减少动态效果设置，并修复提前聚焦搜索时侧栏意外横向滚动的问题。

[Git 30d2c82](https://github.com/blingbling2333/TabExtend/commit/30d2c8233bca31a187d5581f6fa61a5955c5b600)

![侧栏展开与收起的实际页面动图](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.90/v0.5.86-sidebar-motion.webp)

### v0.5.87

正式发布改为每 5 个补丁版本一次，集中展示升级特性和变更证据。

- 仅补丁号能被 5 整除的版本进入打包和发布，手动触发也遵循同一规则。
- 发布页汇总上次发布以来的版本变化，逐项附 Git 提交，并支持压缩截图或动图。
- 单张图片限制 200 KiB、每次发布合计 1 MiB；校验截图和说明的 SHA-256，并保留旧版本的发布恢复能力。

[Git 3054491](https://github.com/blingbling2333/TabExtend/commit/305449186d0ef9151c9b9b60157ecc8ddb2ead99)

### v0.5.88

Frequent Links 支持在 Settings 中选择 1 天、7 天、30 天或全部历史的统计周期。

- 新增 Settings → General → Frequent links period，提供 1 day、7 days、30 days、Total，默认 7 days。
- 按当前时刻滚动统计最近 N×24 小时，Total 使用浏览器保留的全部有效历史；所选范围内没有访问的链接不进入榜单。
- 修改周期后立即重新统计侧栏和外侧快捷图标，保留 Current / All 范围；自动保存选择，重开页面继续生效，并丢弃旧周期的过期请求结果。

[Git 19290fc](https://github.com/blingbling2333/TabExtend/commit/19290fcb380ac7a8f68cba7c61118ab31bb3bb8c)

![Settings 的 General 页可选择 1 day、7 days、30 days 或 Total，默认 7 days](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.90/v0.5.88-period-settings.webp)

![演示数据：近期访问较多的链接排在历史累计较多的链接前，过期访问不进入榜单](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.90/v0.5.88-seven-day-ranking.webp)

![同一页面新增有效访问后，Frequent Links 排名自动更新](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.90/v0.5.88-live-update.webp)

### v0.5.89

常用链接统计周期新增 3 days 选项。

- Settings → General → Frequent links period 现在提供 1 day、3 days、7 days、30 days、Total，默认仍为 7 days。
- 3 days 按滚动最近 72 小时统计，修改后同步更新侧栏和快捷图标排序，并自动保存。

[Git c460371](https://github.com/blingbling2333/TabExtend/commit/c460371dc1f4157c753108e738715e68c7678799)

![常用链接统计周期新增 3 days，选择后自动保存](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.90/v0.5.89-three-day-settings.webp)

### v0.5.90

侧栏和外侧快捷图标新增工作区切换、排名重排动画。

- Current workspace 模式切换工作区时，链接轻滑淡入并依次出现；All workspaces 模式不因当前工作区变化而重复播放。
- 访问次数或统计周期改变排名时，原有链接平滑移到新位置，连续更新从动画当前位置衔接，向前移动的链接轻微浮起。
- 按住链接时暂停位移，排名更新等到原生点击完成再应用；淡出或裁切区域的快捷图标始终禁用交互，并遵循系统减少动态效果设置。

[Git 3f6dc76](https://github.com/blingbling2333/TabExtend/commit/3f6dc761f97df70ea93b6a110ef814e23944b026)

![实际页面演示 Current workspace 切换后链接依次淡入，以及 Notion 排名上升时平滑前移](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.90/v0.5.90-workspace-and-ranking.webp)
