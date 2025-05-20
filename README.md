# Fate Farming CN
原作者库：https://github.com/pot0to/pot0to-SND-Scripts

适配中国服务器客户端使用

Fate Farming 脚本具有以下功能：
- 在双色宝石接近上限时，自动兑换两种新旧版本的 **「双色宝石收据」**
- FATE 优先级系统: 额外奖励 > 最高进度 > 距离水晶最近的 FATE > 剩余时间 > 距离玩家最近的 FATE
- FATE 期间出现 **「迷失少女/迷失者」** 时进行优先处理
- 支持处理所有类型的 FATE，包括 NPC 收集物品 FATE
- 角色死亡后自动复活并返回 FATE 地图继续进行伐木
- 当前地图无可用 FATE 时自动尝试切换副本区域
- 可自动处理雇员任务和军队筹备，完成后返回 FATE 地图继续进行伐木
- 自动购买 **「基萨尔野菜」** 和 **「8级暗物质」** 在这些物品用完时
- 提供配套的 **「Atma farming」** 专用子脚本，也支持自定义脚本（参见 [配套脚本部分](#配套脚本)）

相较于原版做了以下改动：
- 新增支持 AEAssist 循环
- 修改 MinWait 和 MaxWait 默认值，减少 FATE 完成后的等待时间
- 额外奖励 FATE 提升为最高优先级
- 减少了接近敌人逻辑的等待时间（5秒 → 3秒）
- 修复 DownTimeWaitAtNearestAetheryte 相关方法无法寻路到以太之光和寻路到以太之光模型内部的问题
- 移动到 FATE 位置时如果角色未处于飞行状态，将尝试跳跃后再执行寻路
- 将 Retainers 默认设置为 false，防止不在原始服务器时卡死
- 改动 陆行鸟搭档 相关默认参数，以确保刷怪时血量相对健康
- SelectNextZone 逻辑添加更多防御性检测(没用)
- 调整多项 FATE 后处理任务延迟，防止执行时卡住
- 修复 自己修理装备暗物质少于修理装备数量报错的判断，以及购买 8 级暗物质任务的错误逻辑顺序
- 调整 FATE 进行时对敌寻路逻辑（新增处理：目标在射程之外、看不到目标、寻路时被地形障碍卡住）
- 调整 移动到 FATE 任务的选中NPC/怪物的逻辑，避免降落到无法脱离的障碍地形，再次修改现在会降落在更接近目标的位置
- 允许 Bossmod / Bossmod Reborn 脱战时跟随在战斗逻辑中启用
- TeleportTo 逻辑增加空值/空字符串检查

一些其他注意事项：
- 中国服务器当前版本为`7.15`，卫月核心只支持`API 11`版本插件，国际服`API 12`插件无法正常安装，下方的相关插件请自行搜索**旧版本**或**本地化版本**进行安装
- SelectNextZone 逻辑中使用的方法可能与其他插件发生冲突导致游戏崩溃，具体表现为使用多地图脚本伐木时，传送到不同的地图后重新运行 Fate Farming 脚本时游戏崩溃。**已知与 Daily Routines 插件中的某些模块冲突，如果您需要多地图伐木，请考虑禁用插件，如果仍有崩溃发生请自行排查异常插件。**
- 在中国服务器，比起考虑 FATE 伐木效率，您更应该关心无偿帮助 Game Master 举报您使用脚本刷 FATE 的玩家
- 禁止倒卖本仓库的任何内容，如果你从闲鱼购买了这个脚本，不要找我当客服，滚去找你亲爱的倒狗野爹

##  Something Need Doing 插件入门（SND）
![SND Basics](img/1.png)

## 安装依赖插件
### 必要插件
| 插件名称 | 用途 | 仓库 |
|-------------|---------|------|
| Something Need Doing [Expanded Edition] | 运行代码的主插件 | https://puni.sh/api/repository/croizat |
| VNavmesh | 寻路与移动 | https://puni.sh/api/repository/veyn |
| RotationSolver Reborn <b>或</b> BossMod Reborn <b>或</b> Veyn's BossMod <b>或</b> Wrath Combo | 选择目标并攻击敌人 | https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json<br>https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json<br>https://puni.sh/api/repository/veyn<br>https://love.puni.sh/ment.json |
| TextAdvance | 与 FATE NPC 进行交互 | https://github.com/NightmareXIV/MyDalamudPlugins/raw/main/pluginmaster.json |
| Teleporter | 传送到以太之光 | Dalamud 主库 |
| Lifestream | 切换副本区域 | https://raw.githubusercontent.com/NightmareXIV/MyDalamudPlugins/main/pluginmaster.json |

### 可选插件
| 插件名称 | 用途 | 仓库 |
|-------------|---------|------|
| BossMod Reborn <b>或</b> Veyn's BossMod | AI 功能用于躲避机制 | https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json<br>https://puni.sh/api/repository/veyn |
| AutoRetainer | 在雇员就绪时处理雇员任务，然后返回 FATE 地图继续伐木 | https://love.puni.sh/ment.json |
| Deliveroo | 在您的雇员带回太多物品堵塞物品栏时，向大国防联军提交装备 | https://plugins.carvel.li/ |

## 设置
### 脚本设置
脚本包含多项可调整参数用于精细化调整双色宝石收益。此部分内容持续更新，建议您在每次更新脚本后重新查阅！
![Script Settings](img/2.png)

### RSR 设置
| | |
|--|--|
| ![RSR Engage Settings](img/31.png) | 无论您的职业是否为 Tank，都选择 "All Targets that are in range for any abilities (Tanks/Autoduty)" |
| ![RSR Map Specific Priorities](img/32.png) | 将 **「迷失少女」** 和 **「迷失者」** 添加到 Prio Target 中 |
| ![RSR Gap Closer Distance](img/33.png) | 推荐近战设置：gapcloser distance = 20y |

## 配套脚本
配套脚本需与基础脚本 `Fate Farming.lua` 配合使用，可针对不同 FATE 伐木场景提供更精细的控制。


以 `Atma Farming.lua` 脚本为例：


1. 将 `Atma Farming.lua` 和 `Fate Farming.lua` 同时设置为SND中的宏命令。
2. 确保 `Fate Farming.lua` 中的参数满足：`CompanionScriptMode` 设置为 `true`。
   可选：可同时关闭 `WaitIfBonusBuff` 功能。
3. 确认 `Atma Farming.lua` 中的 `FateMacro` 参数值需与您命名的 FATE 宏完全一致。
4. 启动 `Atma Farming.lua` 脚本。

## FAQ 常见问题解答
### 最佳的 FATE 伐木地图在哪里？
根据您所在的的服务器人口与地图人数决定。人数越多，FATE 怪物血量越高，
但同时完成速度也越快，热门地图推荐：
- 遗产之地：FATE 等级低到既可以快速击杀怪物，同时又高到不需要等级同步
- 克扎玛乌卡湿地：以太之光位置覆盖范围良好，没有像遗产之地那样的高墙
- 夏劳尼荒野：如果您不介意专心照看角色并且对特殊 FATE (蛇王得酷热涅：荒野的死斗 > `美花帕拉` 坐骑)或 S 级狩猎怪物感兴趣，
可以选择这张地图，不过两者都需要手动干预。
由于特殊 FATE 和 S 级狩猎怪物的存在，这个地图通常有很多人。
情况好坏取决于：这些人是在和你一起刷 FATE 还是只是在挂机。
- 汉化者建议：最佳地图为遗产之地、夏劳尼荒野、厄尔庇斯这三张地图，优先级从高到低。

### 使用什么职业最好？
取决于你拥有的职业，但热门选择是：
- 你拥有最佳装备(BiS)的任何职业
- **`战士`** 生存能力强且有突进技能。非常适合单刷，因为您可以拉所有怪
- **`白魔法师`** 的神圣连发可以击晕敌人。如果你能在神圣发动前承受住初始攻击，可能比 **`战士`** 完成 FATE 更快
- **`蝰蛇剑士`** 伤害很高，但生存可能是个问题，将你的陆行鸟设为治疗战术
- **`绘灵法师`**(最佳) 同样伤害很高，但 FATE 脚本可能会经常让你离开绘灵幻景区域
- 汉化者建议：无脑绘灵法师，陆行鸟搭档选治疗战术保活。治疗坦克输出不够，而近战在输出环境上会丢失大量伤害影响效率，因此选画家，实战也是最佳的。

### 为什么我的游戏会卡顿？特别是在进行 BOSS FATE 时？
您安装了 Pandora's Box 吗？尝试完全关闭它。
### 为什么粘贴到 SND 后无法编辑脚本？
尝试先粘贴到记事本，在那里编辑，然后使用 SND 中的 "从剪贴板导入" 按钮粘贴进去。
![Import From Clipboard](img/4.png)

## Discord
**请不要在频道里询问此汉化版本的任何问题，脚本只适配于中国服务器的客户端且有部分代码改动，如有问题请在此仓库提交 issue！**

**Please do not ask any questions about this localized version in the channel. The script is only adapted for the Chinese server client with some code modifications. If you encounter any issues, please submit them as issues in this repository!**

https://discord.gg/punishxiv > ffxiv-snd (channel) > pot0to's fate script (thread)