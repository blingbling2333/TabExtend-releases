## 本次升级（v0.5.105 → v0.5.115）

包含 10 个版本的改动；每项附对应 Git 提交。源码链接需要源码仓库访问权限。

[完整代码差异](https://github.com/blingbling2333/TabExtend/compare/830cd073a5606ff529190dabe9d048f3ed8ee0dd...61a75e6f7a2143edcea5443f383e10aae34470ae)

### v0.5.106

桌面收藏看板新增「打开的标签页」入口，可跨窗口整理标签、清理重复页，并保存到收藏分组后关闭。

[Git 11c9103](https://github.com/blingbling2333/TabExtend/commit/11c9103b2f9f3420f753a0e74069f00cbc5edf6c)

![收藏看板右上角、搜索按钮左侧的打开标签页入口。](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.115/v0.5.106-entry.webp)

![标签整理页按站点展示当前设备的网页，并标记重复页。](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.115/v0.5.106-organizer.webp)

### v0.5.107

标签整理页采用 TabExtend 原生配色与按内容高度分栏的站点卡片，右上角入口改为轻量的叠页图标和文字。

- 每行展示站点图标，支持直接收藏、关闭或切换到原页，多选时才显示复选框。
- 从整理页收藏的网页可在「稍后查看」中打开或标为已读，支持浅色、深色和窄窗口。

[Git 63d03b4](https://github.com/blingbling2333/TabExtend/commit/63d03b43294dbd140e8c3dd2fa3e1aa2a1a6c0c3)

![与搜索控件并列的标签页入口。](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.115/v0.5.107-entry.webp)

![整理页用项目蓝色标识重复项，各站点卡片按内容高度排列。](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.115/v0.5.107-organizer.webp)

![深色外观下的标签整理页。](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.115/v0.5.107-dark.webp)

### v0.5.108

标签整理页新增双向切换和卡片入场动效，站点分组和网页标题更易读。

- 看板与整理页在同一工具栏下左右切换，站点卡片依次浮现，支持系统减弱动态效果设置。
- 站点分组显示品牌名或更易读的域名标题；悬停站点名可查看域名，悬停网页标题可核对原始标题及完整网址。

[Git 192adbf](https://github.com/blingbling2333/TabExtend/commit/192adbff9fbe739ab58f066b18a795a860bd57ff)

![从收藏看板进入整理页，卡片依次出现，再返回看板的实机动效。](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.115/v0.5.108-motion.webp)

![站点卡片以可读名称展示，同名的不同网址分行保留。](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.115/v0.5.108-titles.webp)

### v0.5.109

标签整理页保存弹窗改用与看板设置一致的分组下拉菜单，支持键盘选组和创建新分组。

[Git a22c813](https://github.com/blingbling2333/TabExtend/commit/a22c813020ac4e6815a097260860cc6abba0cdec)

![保存标签页时，目标分组菜单标记当前选择，末尾可创建新分组。](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.115/v0.5.109-destination.webp)

![深色主题下的目标分组菜单。](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.115/v0.5.109-destination-dark.webp)

### v0.5.110

收藏看板底部新增标签页抽屉，能从网站图标认出正在浏览的内容，一键展开整理。

- 抽屉预览最多三个网站的图标，标签页数量随浏览器更新。
- 收起再展开会保留滚动位置和已勾选的标签页。批量保存操作位于抽屉入口上方。

[Git be9ffac](https://github.com/blingbling2333/TabExtend/commit/be9ffac4fc9ca88ec0193511642acdc46878e9c2)

![收藏看板底边显示打开的网站图标、标签页数量与展开整理入口。](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.115/v0.5.110-drawer.webp)

![展开抽屉后，已选标签页的批量操作位于返回看板入口上方。](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.115/v0.5.110-selection.webp)

### v0.5.111

底部标签页抽屉与左侧栏的交界改为直角。

[Git 3377456](https://github.com/blingbling2333/TabExtend/commit/3377456dd778cc8eaf842176e7ed84bd9c5a2c22)

![收藏看板底部，标签页抽屉以直角贴齐左侧栏。](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.115/v0.5.111-corner.webp)

### v0.5.112

标签整理页的行高亮在图标和操作按钮两侧留出空间，悬停、键盘聚焦和勾选时都更清晰。

[Git 8dd1012](https://github.com/blingbling2333/TabExtend/commit/8dd101260c6bd0cf05dce5d7dd0efae65d014713)

![深色主题下，标签行的高亮在网站图标左侧和操作按钮右侧留有空隙。](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.115/v0.5.112-row-highlight.webp)

### v0.5.113

标签整理页和「稍后查看」沿用工作区分类菜单的细滚动条，鼠标移入或键盘聚焦时显示。

[Git ee84230](https://github.com/blingbling2333/TabExtend/commit/ee8423027041f90eab96d82170b07bca852f030e)

![标签整理页右侧的细滚动条与卡片共用当前主题的灰色。](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.115/v0.5.113-scrollbar.webp)

### v0.5.114

新增暖纸、峡湾和玫瑰墨三套配色，可在设置的「外观」中选择，原有配色保留为默认。

- 每套皮肤均支持浅色、深色和跟随系统，收藏看板、标签整理页和工具栏收藏弹窗使用同一配色。
- 皮肤选择保存在当前浏览器，重新打开扩展时继续生效。

[Git 10edbba](https://github.com/blingbling2333/TabExtend/commit/10edbbacd5754fce7ba431330f37cb7211d196c4)

![TabExtend 桌面扩展的浅色皮肤。](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.115/v0.5.114-skins-light.webp)

![TabExtend 桌面扩展的深色皮肤。](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.115/v0.5.114-skins-dark.webp)

### v0.5.115

新增林间、青花、金盏和石墨四款皮肤，每款都有独立设计的白天和夜间配色。

- 设置的「外观」页现在并排展示每款皮肤的日间与夜间效果，共有八款可选。
- 选皮肤时保留当前的浅色、深色或跟随系统设置。

[Git 61a75e6](https://github.com/blingbling2333/TabExtend/commit/61a75e6f7a2143edcea5443f383e10aae34470ae)

![收藏看板上林间与青花两款皮肤的白天和夜间配色对照](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.115/v0.5.115-grove-porcelain.webp)

![收藏看板上金盏与石墨两款皮肤的白天和夜间配色对照](https://github.com/blingbling2333/TabExtend-releases/releases/download/v0.5.115/v0.5.115-marigold-graphite.webp)
