## 本次升级（v0.5.90 → v0.5.100）

包含 10 个版本的改动；每项附对应 Git 提交。源码链接需要源码仓库访问权限。

[完整代码差异](https://github.com/blingbling2333/TabExtend/compare/3f6dc761f97df70ea93b6a110ef814e23944b026...04cef493af18ff6864418f1a0186e85638788d2b)

### v0.5.91

修复首次发布后升级说明核验找不到本地版本标签的问题。

- 公开发布前先创建本地版本标签，再推送同一个标签，确保发布后的升级说明核验能够读取正确版本。
- 增加真实临时 Git 仓库回归测试，覆盖首次发布、发布后核验及相同版本重试。

[Git d46e8da](https://github.com/blingbling2333/TabExtend/commit/d46e8dadb4c428813e26832e39e1e0b965f63ecd)

### v0.5.92

工作区快捷菜单支持右侧分类子菜单，直接跳转到指定分类。

- 悬停工作区或点击右侧箭头即可浏览分类；点击工作区名称仍直接进入其第一个分类。
- 二级菜单始终与一级菜单顶部对齐，只显示分类列表，沿用现有菜单的弹出与选中动画。
- 两个菜单独立滚动，支持方向键跨层级操作，并保留系统减少动态效果设置。

[Git 80f2e82](https://github.com/blingbling2333/TabExtend/commit/80f2e82f0a1fe4bec942e650d042d2d2041c5851)

![独立演示环境中的工作区分类菜单，全部使用虚构的 Workspace Alpha/Beta/Gamma 与 Category One 至 Five，两个菜单顶部对齐](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.100/v0.5.92-workspace-category-menu.webp)

### v0.5.93

分类二级菜单随内容增高，空间足够时一次显示全部分类。

- 取消二级菜单最多显示五行的限制，仅在分类列表超出窗口可用高度时滚动。

[Git b3c5cba](https://github.com/blingbling2333/TabExtend/commit/b3c5cbac42eb0fda88f0b320063bc195925518fa)

![完全虚构的 Demo A/B 和 Category 01 至 08 演示数据；二级菜单一次显示八个分类，保持顶部对齐且没有滚动条](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.100/v0.5.93-category-menu-height.webp)

### v0.5.94

修复分类菜单切换时滚动条短暂闪现，并优化切换动效。

- 将滚动区域与动画裁切分开，避免长列表切到短列表时高亮背景短暂撑出滚动条。
- 菜单顶部保持对齐，高度平滑回弹，分类行轻滑依次入场；连续切换从当前位置衔接，并遵循减少动态效果设置。

[Git 531ef68](https://github.com/blingbling2333/TabExtend/commit/531ef68e841da57f67885272f6383720a96ceece)

![仅含虚构 Demo A/B/C 和 Category 编号数据的修复后界面；长短列表及连续切换已逐帧检查，无意外滚动条](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.100/v0.5.94-category-menu-motion.webp)

### v0.5.95

修复从下方工作区斜向移动到分类菜单时，菜单提前消失的问题。

- 保护工作区到二级菜单之间的斜向鼠标路径，短菜单下方的空白区域也能顺利经过。
- 朝分类菜单移动时暂缓其他工作区的预览，停留后正常切换；移出路径或点击外部仍立即关闭。

[Git 7ad3dd6](https://github.com/blingbling2333/TabExtend/commit/7ad3dd6f8485979ccff6ea9934fae89cd883f283)

![仅含虚构 Demo A/B/C 数据：从底部工作区斜向进入顶部分类菜单，菜单保持打开，路径与交互检查通过。](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.100/v0.5.95-category-menu-pointer-path.webp)

### v0.5.96

精简侧栏常用链接列表，搜索框改为普通圆角。

- 侧栏搜索框改用 8px 圆角，保留现有配色、尺寸和筛选操作。
- 移除常用链接列表内重复的标题、链接数量和分隔线，链接直接从列表顶部展示。

[Git 566e16a](https://github.com/blingbling2333/TabExtend/commit/566e16a7d089b9d8550f3c168a7b8ddbac76ae52)

![使用演示链接的深色侧栏：普通圆角搜索框与没有重复表头的常用链接列表。](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.100/v0.5.96-sidebar-search-cleanup.webp)

### v0.5.97

增大侧栏搜索框圆角，边角更柔和。

- 将侧栏搜索框圆角从 8px 调整为 12px。

[Git 42e7118](https://github.com/blingbling2333/TabExtend/commit/42e7118bc37a5893e31e7c85794a7e17ffaeaa50)

![演示数据侧栏：搜索框使用更柔和的 12px 圆角。](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.100/v0.5.97-sidebar-search-radius.webp)

### v0.5.98

加高侧栏搜索框并增大文字，提升输入和阅读舒适度。

- 侧栏搜索框高度从 38px 增加到 44px，文字从 12px 增大到 14px。
- 搜索和清空图标同步增大，保留 12px 圆角。

[Git c5eab85](https://github.com/blingbling2333/TabExtend/commit/c5eab857b5dcc6e470ee9d17bc59f3e99754cc65)

![演示数据侧栏：加高至 44px 的搜索框、14px 文字与 12px 圆角。](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.100/v0.5.98-sidebar-search-comfort.webp)

### v0.5.99

侧栏搜索框文字进一步增大至 15px。

- 将侧栏搜索框文字从 14px 微调到 15px，沿用现有高度与圆角。

[Git 39900b3](https://github.com/blingbling2333/TabExtend/commit/39900b376a9db209d77ee5e2097c72081f15cec6)

![演示数据侧栏：搜索框文字增大至 15px。](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.100/v0.5.99-sidebar-search-font.webp)

### v0.5.100

chore: bump version to 0.5.100 for release

[Git 04cef49](https://github.com/blingbling2333/TabExtend/commit/04cef493af18ff6864418f1a0186e85638788d2b)
