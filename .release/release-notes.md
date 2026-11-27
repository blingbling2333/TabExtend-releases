## 本次升级（v0.5.115 → v0.6.0）

包含 16 个版本的改动；每项附对应 Git 提交。源码链接需要源码仓库访问权限。

[完整代码差异](https://github.com/blingbling2333/TabExtend/compare/61a75e6f7a2143edcea5443f383e10aae34470ae...64fb6752b911eaa9c059bccdf329828b1c1d844e)

### v0.5.116

内置 Inter 可变字体并开启光学字号与抗锯齿渲染，所有设备都能一致展示界面文字。

- 在新标签页、扩展弹窗与移动端内置本地 Inter 光学字号可变字体（woff2）及 OFL 许可文件。
- 统一开启光学字号与抗锯齿，并补全中文字体回退栈，避免受本机是否安装 Inter 影响。

[Git 6d7f9c2](https://github.com/blingbling2333/TabExtend/commit/6d7f9c2832a4fdce9e44d696b2e677edba7f1610)

![内置 Inter 字体后的主看板文字与分组卡片效果](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.6.0/v0.5.116-inter-font.webp)

### v0.5.117

将英文界面中的菜单项、抽屉栏与侧栏标题统一为规范的实词首字母大写（Title Case）。

- 主菜单、同步菜单、工作区与分组操作菜单改用标准英文 Title Case（如 New Group、Import Bookmarks、Check for Updates、Duplicate Group）。
- 底部打开标签页抽屉、标签页整理页与侧边栏标题同步调整为 Title Case（如 Open Browser Tabs、Organize Tabs、Frequent Links）。

[Git 2ef84e8](https://github.com/blingbling2333/TabExtend/commit/2ef84e8c6bb6b66011476a8d745d8e135827df08)

![英文主菜单与底部标签页抽屉的 Title Case 标题效果](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.6.0/v0.5.117-title-case-menus.webp)

### v0.5.118

优化标签页整理页顶部结构：在页眉右侧展示打开与重复标签页总数，并移除下方重复的水平分隔线。

- 在「Good morning / 打开的标签页」页眉右侧新增当前标签页数与重复页数概览，取代原页脚总数区块。
- 移除分组标题行与「稍后查看」栏头中的第二条分隔线，整个顶部保持单线清爽层次。

[Git e5b0bc0](https://github.com/blingbling2333/TabExtend/commit/e5b0bc025ec4e088544024145f5ac138aae72a1b)

![标签页整理页顶部的单线页眉与右侧数量概览](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.6.0/v0.5.118-organizer-masthead.webp)

### v0.5.119

补齐 Tab Out 体验：新增扩展图标打开标签数徽标、多余新标签页一键清理、关标签轻音效与彩屑、全局去重及稍后查看升级。

- 浏览器工具栏图标实时显示当前打开的网页标签数量，并按数量分段呈现绿 / 琥珀 / 红三色提示。
- 打开多个 TabExtend 新标签页时，整理页顶部展示提示横幅，可一键关闭其余多余标签页。
- 关闭标签页新增 Web Audio 轻音效与彩屑动画（整理页工具栏支持一键静音切换），并补充全局「一键清理重复页」与清空态提示。
- 「稍后查看」新增相对保存时间、单条移除（不删原收藏）以及已读归档搜索框。

[Git 7800e58](https://github.com/blingbling2333/TabExtend/commit/7800e583e38d421aa040742ae42bd79ac778886d)

![整理页的多余新标签页横幅、全局去重、音效开关与稍后查看增强效果](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.6.0/v0.5.119-tab-out-parity.webp)

### v0.5.120

左侧收起态常用站点图标统一加上圆角边框底框，与底部打开标签栏图标样式保持一致。

- 为左侧快捷站点胶囊内的站点图标补充圆角浅底边框与轻投影，使不同形状或浅色网站图标视觉更整齐统一。
- 同步调整左侧快捷图标的悬停微抬与键盘聚焦外框样式，并兼容浅色、深色与各套皮肤主题。

[Git 6caa3f2](https://github.com/blingbling2333/TabExtend/commit/6caa3f251b7afe80e4d9dca110cadc66aa05b8a7)

![左侧快捷站点图标加上圆角外框后与底部打开标签栏图标的统一效果](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.6.0/v0.5.120-rail-site-icon-frame.webp)

### v0.5.121

修复整理页「稍后查看」已读搜索框与控件聚焦高亮边缘被滚动容器裁剪的问题。

- 为「稍后查看」滚动侧栏（.ot-saved）补充 4px 内边距并用负外边距保持对齐，防止内部按钮与输入框聚焦高亮被左右裁切。
- 优化已读归档搜索框的聚焦态样式，改为边框高亮与柔和外环，去除生硬的双层分离外框。

[Git 933e3c0](https://github.com/blingbling2333/TabExtend/commit/933e3c03ad36ec99df1a75ed0e459cda21c9deb1)

![稍后查看已读归档搜索框聚焦高亮完整显示效果](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.6.0/v0.5.121-archive-search-focus.webp)

### v0.5.122

拆分整理页的「稍后查看」与「收藏到分组」操作，支持一键暂存稍后看及后续转存分组。

- 每个打开的标签行（及批量选择栏）新增独立的一键「稍后查看」按钮，无需弹窗即可将标签暂存到右侧 Saved for Later 并关闭，不污染正式看板分组。
- 「收藏到分组」默认仅保存到目标分组，弹窗内提供可选勾选「同时加入稍后查看」。
- Saved for Later 中的独立暂存条目支持一键「收藏到分组」，看完觉得值得可随时转入正式看板并自动移出暂存列表。

[Git 79bc84c](https://github.com/blingbling2333/TabExtend/commit/79bc84c1d548e748e72c90458e196c62cbae11ce)

![整理页拆分一键稍后查看与收藏到分组按钮，及稍后查看条目的转存分组操作](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.6.0/v0.5.122-split-save-read-later.webp)

### v0.5.123

收紧整理页标签行右侧三个快捷按钮的间距与宽度，给标题留出更多展示空间。

- 将整理页标签行右侧的「稍后查看 / 收藏到分组 / 关闭」三个按钮收拢到紧凑动作组中，单按钮由 24px 调整为 20px 且去除多余间隙，为每行标题腾出约 20px 宽度。

[Git 00ab44f](https://github.com/blingbling2333/TabExtend/commit/00ab44f5bad60331fc488595363f1298337de57e)

![整理页标签行右侧三个操作按钮收紧间距后的效果](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.6.0/v0.5.123-compact-row-actions.webp)

### v0.5.124

调整左侧收起态快捷站点容器为同心 14px 圆角与均衡内边距，收紧图标纵向间距。

- 将左侧快捷站点胶囊的外圆角由 20px 半圆收口调整为 14px，与上方侧栏入口按钮圆角及内部 8px 图标底框形成同心比例。
- 统一容器上下左右留白并收紧单个站点槽位高度，消除顶部与底部过大的空胶囊帽，单屏可展示更多常用站点。

[Git bc35607](https://github.com/blingbling2333/TabExtend/commit/bc356076b47a6fc6426a2129bfef1de12b58b12d)

![左侧快捷站点容器调整为同心 14px 圆角与均衡留白后的浅色和深色效果](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.6.0/v0.5.124-rail-capsule-radius.webp)

### v0.5.125

将左侧栏常用链接入口与关联区域的闪电图标替换为双色调极简罗盘图标。

- 新增双色调极简罗盘图标组件，替换左侧栏顶部入口按钮中原有的 24px 闪电轮廓图标，在 40×40 圆角按键中呈现更稳重均衡的 20px 视觉比例。
- 同步更新侧边栏视图切换菜单、底部状态栏、空态提示及外观设置中的常用链接图标，保持整体视觉语义统一。

[Git 416d918](https://github.com/blingbling2333/TabExtend/commit/416d918cee70e51e1862fbd916f213722ab736c2)

![左侧栏顶部入口按钮换为双色调极简罗盘图标后的浅色与深色效果](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.6.0/v0.5.125-rail-compass-logo.webp)

### v0.5.126

左侧栏入口图标改用素雅双层叠卡品牌标，并适度拉大左侧快捷站点图标纵向间距。

- 将左侧栏顶部入口及视图切换菜单、底部状态栏、空态和外观设置中的常用链接图标切换为素雅双层圆角叠卡标，呼应 TabNav 扩展原版叠卡基因并适配浅色、深色与各皮肤背景。
- 在保持外层容器 14px 同心圆角与 5px 均衡首尾留白不变的前提下，将快捷站点胶囊内相邻图标间距由 6px 放宽至 12px，视觉呼吸感更舒展。

[Git e54ab0d](https://github.com/blingbling2333/TabExtend/commit/e54ab0d7aff8febcb2190d3381bf8d7611cfaf88)

![左侧栏换为素雅双层叠卡品牌标并拉大快捷站点图标间距后的浅色与深色效果](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.6.0/v0.5.126-rail-layered-tabs-and-spacing.webp)

### v0.5.127

底部“打开的标签页”抽屉支持靠近渐进露头与触底自动展开，展开时把手随抽屉升至顶部。

- 收起态默认仅在底部保留 16px 轻巧贴边抓手，为看板留出更多纵向可视空间；鼠标移入底部感应区后抽屉把手与整理视图顶沿随指针下移实时渐进露头。
- 指针靠近最底边并短暂减速停留（约 220ms，顶部显示细微进度线）时自动展开抽屉，同时把手随抽屉升至顶部转为“返回看板”栏，并在拖拽、弹窗、多选工具栏及快速划离窗口时自动防误触。

[Git 4797919](https://github.com/blingbling2333/TabExtend/commit/479791947a4cc35033e3e11aca765abb0c2a7c26)

![底部打开的标签页抽屉的贴边收起、靠近渐进露头与升至顶部展开三态效果](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.6.0/v0.5.127-proximity-peek-tabs-drawer.webp)

### v0.5.128

修复底部“打开的标签页”抽屉被收起态工作区切换菜单误拦截、导致无法靠近触发露头的问题。

- 遮罩检测改为仅拦截真正可见的弹窗与菜单，忽略带有 inert 或 aria-hidden="true" 的常驻隐藏菜单（如收起态的工作区切换弹窗）。
- 为底边坐标判断增加 2px 高分屏亚像素容差，避免指针贴紧屏幕最底像素时误回缩。

[Git 6bb4345](https://github.com/blingbling2333/TabExtend/commit/6bb4345993290910fff32d9e2a5dc2954366ce02)

### v0.5.129

补齐展开态“打开的标签页”顶栏与分类标签栏之间的 16px 间距与清晰上边缘分隔线。

- 为抽屉容器补充 16px 顶部外边距，使展开后的把手栏与上方分类标签栏保持与看板卡片一致的呼吸间距。
- 保留抽屉展开态把手的 1px 上边缘分隔线，在浅色与深色主题下清晰界定顶栏与标签整理区。

[Git fd04cb9](https://github.com/blingbling2333/TabExtend/commit/fd04cb9928c7a465c57bb305a9ebec0f484b77b7)

![展开态打开的标签页把手与上方分类栏保留 16px 间距和 1px 上边缘线的浅色与深色效果](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.6.0/v0.5.129-open-drawer-top-gap-border.webp)

### v0.5.130

底部抽屉顶部进度条改为从进入靠近感应区起全程连续推进，与露头和触底展开无缝衔接。

- 指针刚进入底部 132px 感应区并开始露头时，顶部 2px 进度线即随露头高度从 0% 平滑推进至 82%，不再等到触底最后瞬间才闪现。
- 进入底部 18px 触发带后由当前进度无缝续推至 100% 自动展开，鼠标移开或上撤时与抽屉同步平滑退回至 0%。

[Git 29bed68](https://github.com/blingbling2333/TabExtend/commit/29bed68e3da96bbb67c42a174be78e1e70070e31)

![底部抽屉顶部进度条从初入感应区、持续下移露头到触底确认三段连续推进的效果](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.6.0/v0.5.130-continuous-drawer-progress.webp)

### v0.6.0

TabNav 0.6.0 里程碑版本：全新左侧栏视觉体系、底部靠近渐进露头标签整理抽屉与 Tab Out 整理能力全面升级。

- 全新底部“打开的标签页”交互：收起态精简为 16px 贴边抓手，鼠标靠近底部即随下移实时渐进露头并连贯推进顶部进度线，触底自动展开且把手自然升至顶栏下方。
- 标签整理面板升级：拆分为一键“稍后阅读”与“收藏到分组”双路径，新增稍后阅读书架、已读归档搜索、一键清理重复标签、关闭动效与静音开关以及更紧凑的行操作按钮。
- 左侧收起栏与整体排版焕新：内嵌 Inter 字体，统一 Title Case 英文文案，左侧常用站点采用素雅双层叠卡标、14px 同心圆角胶囊、加宽纵向间距与统一圆角图标底框。

[Git 64fb675](https://github.com/blingbling2333/TabExtend/commit/64fb6752b911eaa9c059bccdf329828b1c1d844e)
