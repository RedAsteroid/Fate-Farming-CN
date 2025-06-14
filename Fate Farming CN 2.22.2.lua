--[[

********************************************************************************
*                                Fate Farming                                  *
*                               Version 2.22.2                                 *
********************************************************************************

作者: pot0to (https://ko-fi.com/pot0to)
贡献者: Prawellp, Mavi, Allison
状态机图: https://github.com/pot0to/pot0to-SND-Scripts/blob/main/FateFarmingStateMachine.drawio.png
原始来源: https://github.com/pot0to/pot0to-SND-Scripts/blob/main/Fate%20Farming/Fate%20Farming.lua
汉化仓库: https://github.com/RedAsteroid/Fate-Farming-CN
汉化者: RedAsteroid
test5.2

简介:
    - 此脚本基于 pot0to 的 Fate Farming.lua 进行适配与修改使其适配中国服务器客户端 ，也参考了 https://github.com/Bread-Sp/Fate-Farming-CN-Client- 的更改内容
    - 仍存在问题：脚本无法处理护送任务，2.0 - 4.0 版本的地图 FATE 未核对适配情况

    感谢 @pot0to 创造了如此优秀的脚本与设计方案！
    感谢 Daily Routines 群友在适配阶段提供测试与各位大佬的技术支持！

修改内容: 
    1. 新增支持 AEAssist 循环
    2. 修改 MinWait 和 MaxWait 默认值（3秒，4秒），减少 FATE 完成后的等待时间
    3. 额外奖励 FATE 提升为最高优先级
    4. 修复 FlyBackToAetheryte 逻辑无法寻路到以太之光以及寻路到以太之光模型内部的问题
    5. Retainers 默认设置更改为 false，如果您需要收雇员请手动改为 true
    6. 改动 陆行鸟搭档 相关参数，以确保刷怪时血量相对健康
    7. SelectNextZone 添加更多防御性检测(其实没用)
    8. FATE 后处理任务添加延迟防止执行过快导致卡死
    9. 大幅调整 MoveToFate 逻辑，现在会更加精准快速地抵达 FATE 位置
    10. 大幅调整 DoFate 逻辑，选择目标与处理阻挡/距离异常逻辑将更加迅速
    11. 调整 HandleUnexpectedCombat 的冷却周期，减少发呆时间
    12. 修复 暗物质少于待修理装备数量时报错，购买 8级暗物质 的错误逻辑顺序
    13. 允许 Bossmod / Bossmod Reborn 脱战时跟随在战斗逻辑中启用
    14. TeleportTo 逻辑增加空值/空字符串检查，新增逻辑用于脱离 Daily Routines 插件由于兼容性导致的传送卡死
    15. 补充 FATE 进行时，意外在 FATE 范围外上坐骑后的复位逻辑
    16. 移除了 InteractWithFateNpc、Mount 逻辑的延迟，大幅提高移动到 FATE 与 NPC FATE 的落地效率
    17. 修复 多地图伐木的场景下，FATE 完成时的逻辑缺失，解决收集类 FATE 进度 100% 时不会前往下一个 FATE 的问题
    18. 补充 3.0 FATE 表信息，版本内所有 特殊FATE 与 成就FATE 已加入黑名单，支持魂武流光水晶伐木

插件兼容性问题: 
    1. 如需使用 BossMod / BossModReborn 插件的循环功能，请安装 44451516 维护的 BossMod / BossModReborn 插件
        - 仓库链接: https://raw.githubusercontent.com/44451516-ff14/BossmodRebornCN/main/pluginmaster.json

       如不想使用 BossMod / BossModReborn 插件的循环功能，请安装 逆光喵 维护的 BossMod / BossModReborn 插件，并清理插件配置确保循环功能彻底阉割
        - 仓库地址：https://raw.githubusercontent.com/NiGuangOwO/DalamudPlugins/main/pluginmaster.json

       原因: BossMod / BossModReborn 插件的 AI 模块"脱战时跟随"绑定循环，导致在使用其他循环插件工作时争夺技能使用控制权

    2. 使用任何 配套脚本 进行切换地图的 FATE 伐木时，务必禁用 Daily Routines 插件，否则每次在切换地图脚本重新运行时一定概率游戏崩溃
       单地图伐木可使用 Daily Routines 插件，决定开始运行时尽量避开 Daily Routines 在切换地图后访问 AetheryteList 的时间区间防止发生崩溃

    3. Daily Routines 插件有许多便利的模块:
        - 自动开始临危受命任务 
            直接开始 NPC FATE，开启后可以移除 FATE 开始 NPC 因重名问题而注释或加入黑名单的 FATE(如果没进黑名单，FATE 开始了也会去打)
        - 自动取消交易
            处理小警察的交易请求
        - 自动临危受命
            Daily Routines 插件的自动 FATE 脚本模块，无兼容问题、高效且不需要拼好挂，刷双色非常推荐尝试这个方案而非此脚本

       请加入 Discord 获取插件详细信息，但不要过度讨论有关这个 SND 脚本的内容
       - Repository 仓库: https://github.com/AtmoOmen/DalamudPlugins
       - Discord: https://discord.gg/dailyroutines

安全使用守则推荐:
    1. 不要无人值守
    2. 不要一天25小时挂着
    3. 不在事件的风口浪尖顶风作案
    4. 警惕小警察录屏
    5. 不要在任何地方承认使用外挂或者脚本(除非自己能保证规避或不在意风险)

    自动 FATE 有明确的封号案例，
    已知的案例发生在小号集群、人口大区(鸟猫)，小警察录屏反而没有明确的后续查封。
    汉化者在鬼服大区刷完 10000 FATE 成就无事发生，24 小时不间断刷的同行一个多月后依然健在，与封号反馈对不上。
    所以基于个人经历认为风险集中于人多的大区和小号针对，虽然身边统计学不严谨，但规避明面上的风险总不会错的。

    上述5条只是建议，这种无聊重复的玩法肯定少不了无人值守且每天挂很长时间。
    刷双色建议遗产之地、夏劳尼荒野双地图，或者遗产之地单地图(荒野单刷可能无法净空地图回到遗产之地导致效率下降)，职业选择画家(绘灵法师)，陆行鸟治疗战术维持血线。
    单刷遗产之地参考收益 1 小时近似 450 - 550 双色宝石(可能会超出这个区间)，20 - 30 FATE 数量。
    如果有同行在一张地图持续刷不跑路效率更高，相反打了就跑 FATE 血量、击杀数、收集量增加等等会导致效率急剧下降。
    小鸣鼠角笛 ≈ 2500 - 3000 FATE，所需时间 ≈ 100 - 120 小时

    【运行前请检查设置，默认配置可能不适配用户的运行环境与需求导致运行出错或无法运行】

以下更新日志仅为原始版本的翻译。

    -> 2.22.2   新增选项：死亡后自动返回可设置为禁用
                修复命令 /vnav flag 与 /vnav moveflag 的选择使用条件
                更新: MoveToFate 逻辑改为导航到 flag 位置，此方法在新月岛表现更佳。
                更新: 阻止 TextAdvance 信息刷屏。
                为 FlyBackToAetheryte 逻辑新增更多日志记录。
                    新增了上坐骑后 1 秒的等待时间，确保玩家完全处于骑乘状态。
                    某些语言版本（如中文）的日志和默语处理速度比英文版更快，
                    导致系统过早触发下一步寻路，此时玩家尚未完成上坐骑，仍处于跳跃过程中。
                    这种情况会导致 vnavmesh 强制生成行走路径而不是飞行路径，从而引发卡顿问题。
    -> 2.21.10  修复对 vbmai 预设的调用。
    -> 2.21.9   By Allison
                新增距离检测优先级逻辑
                    - 现在会考虑传送后可能缩短的距离来优化 FATE 距离检测。
                    - 新增 FatePriority 设置选项，默认行为与之前一致，但包含上述新检测逻辑。
                    - 优先级顺序：进度 → 额外奖励 → 剩余时间 → 距离。
                新增等待位置设置
                    - 当未找到符合条件的 FATE 时，可选择是否在以太之光处等待（默认启用）。
                      若禁用，则会在上一个 FATE 完成的位置等待。
                新增/调整等待时间设置
                    - 新增 MinWait（最小等待时间）设置，因原3秒等待有时过长。
                    - 将 WaitUpTo 更名为 MinWait 以保持命名一致性。
                战斗系统优化
                    - 新增检测: 当使用 RSR 作为循环插件时，自动禁用 VBM 的目标选择功能。
                    - 微调选择下一个 FATE 后的等待时间，现在接近 FATE 时会落在离中心更远的位置。
                    - 新增移动中的额外检测，防止技能施放被打断。
                问题修复    
                    - 修复脱离 FATE 范围时可能出现的异常问题。
                    - 修正文本错误: 将 "should it to Turn" 改为 "should it do Turn"。
                
********************************************************************************
*                               依赖插件                                        *
********************************************************************************

运行所需的插件:

    -> Something Need Doing [Expanded Edition] : (主插件，所有功能运行的基础)   https://puni.sh/api/repository/croizat
    -> VNavmesh :   (用于寻路/移动)    https://puni.sh/api/repository/veyn
    -> 任意一种技能循环插件（用于攻击敌人），可选:
        -> RotationSolver Reborn: https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json       
        -> BossMod Reborn: https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json
        -> Veyn's BossMod: https://puni.sh/api/repository/veyn
        -> Wrath Combo: https://love.puni.sh/ment.json
    -> 任意一种 AI 躲避插件，可选:
        -> BossMod Reborn: https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json
        -> Veyn's BossMod: https://puni.sh/api/repository/veyn
    -> TextAdvance: (用于与 FATE NPC 交互) https://github.com/NightmareXIV/MyDalamudPlugins/raw/main/pluginmaster.json
    -> Teleporter :  (用于传送至以太之光 [传送][兑换][雇员])
    -> Lifestream :  (用于切换副本区域 [切换副本][交换]) https://raw.githubusercontent.com/NightmareXIV/MyDalamudPlugins/main/pluginmaster.json

********************************************************************************
*                                可选插件                                       *
********************************************************************************

这些插件为可选插件，除非在设置中启用，否则不需要安装:

    -> AutoRetainer : (用于雇员管理 [雇员])   https://love.puni.sh/ment.json
    -> Deliveroo : (用于军队筹备提交 [提交])   https://plugins.carvel.li/
    -> YesAlready : (用于精制魔晶石)
    -> Daily Routines : (用于处理传送卡死)  https://raw.githubusercontent.com/AtmoOmen/DalamudPlugins/main/pluginmaster.json

--------------------------------------------------------------------------------------------------------------------------------------------------------------
]]

--#region Settings

--[[
********************************************************************************
*                                   设置                                       *
********************************************************************************
]]

--FATE 前处理设置
Food                                = ""            --如果不想使用任何食物请留空，如果要使用高品质食物，请在名称旁添加<hq>标记，例如"烧烤暗色茄子 <hq>"。
Potion                              = ""            --如果不想使用任何药水请留空。
ShouldSummonChocobo                 = true          --是否召唤陆行鸟搭档？
    ResummonChocoboTimeLeft         = 5 * 60        --当陆行鸟搭档剩余时间少于这个秒数时重新召唤，避免在 FATE 中途消失。
    ChocoboStance                   = "治疗战术"      --可选指令: 跟随/自由战术/防护战术/治疗战术/进攻战术。
    ShouldAutoBuyGysahlGreens       = true          --当基萨尔野菜用完时，自动从利姆萨·罗敏萨的商人处购买99个基萨尔野菜。
MountToUse                          = "随机坐骑"       --在 FATE 之间飞行时想要使用的坐骑，填写"随机坐骑"则使用随机坐骑
FatePriority                        = {"Bonus", "Progress", "DistanceTeleport", "TimeLeft", "Distance"} --FATE 优先级顺序

--FATE 战斗设置
CompletionToIgnoreFate              = 80            --如果 FATE 进度已超过此百分比，则跳过（默认80%）
MinTimeLeftToIgnoreFate             = 3 * 60        --如果 FATE 剩余时间少于此时长（秒），则跳过（默认3分钟）
CompletionToJoinBossFate            = 0             --如果 Boss FATE 进度低于此值，则跳过（用于避免单挑 Boss，默认0%）
    CompletionToJoinSpecialBossFates = 20           --用于特殊 Boss FATE（如"蛇王得酷热涅：荒野的死斗"或"亩鼠米卡：盛装巡游皆大欢喜"）的加入进度阈值（默认20%）
    ClassForBossFates               = ""            --如需为 Boss FATE 使用不同职业，请在此设置三字母职业缩写（如"PLD"）
                                                        --例如骑士，填入: "PLD"。
JoinCollectionsFates                = true          --设置为 false，则永不参与收集型 FATE（默认true）
BonusFatesOnly                      = false         --设置为 true，则仅完成额外奖励 FATE，忽略其他所有 FATE（默认false）

MeleeDist                           = 2.5           --近战攻击距离（单位：码）。近战自动攻击的最大有效距离为 2.59 码，2.60 码会显示"目标在射程之外"
RangedDist                          = 20            --远程攻击距离（单位：码）。远程技能和魔法的最大有效距离为 25.49 码，25.5 码会显示"目标在射程之外"

RotationPlugin                      = "None"        --选择使用的循环插件，可选：RSR/BMR/VBM/Wrath/AE/None
    RSRAoeType                      = "Full"        --RSR 的 AOE 技能类型选择，可选：Cleave/Full/Off

    --（BMR/VBM/Wrath 专用设置）
    RotationSingleTargetPreset      = ""            --单目标预设名称（用于迷失者）。注意: 激活此预设时会自动关闭目标选择功能。
    RotationAoePreset               = ""            --AOE + buff 的预设名称。
    RotationHoldBuffPreset          = ""            --保留2分钟爆发技能在进度达到设定值时使用的预设名称。
    PercentageToHoldBuff            = 65            --FATE 进度低于此值时将使用保留爆发预设，理想情况下应充分利用爆发技能，若进度过高，设置超过 70% 仍会浪费数秒buff时间。
DodgingPlugin                       = "BMR"         --选择躲避插件，可选：BMR/VBM/无（若循环插件已选BMR/VBM，此项将被覆盖）

IgnoreForlorns                      = false         --设置为 true，将忽略迷失者/迷失少女
    IgnoreBigForlornOnly            = false         --设置为 true，将只忽略迷失者

--FATE 后处理设置
MinWait                             = 3             --执行下一个 FATE 前，上坐骑前的最小等待时间（秒）。
MaxWait                             = 4             --执行下一个 FATE 前，上坐骑前的最大等待时间（秒）。
                                                        --实际等待时间将在最小值和最大值之间随机生成。
DownTimeWaitAtNearestAetheryte      = false         --等待 FATE 出现时，是否飞往最近的以太之光处等待？
EnableChangeInstance                = true          --当地图内没有 FATE 时是否切换副本区域（仅限 金曦之遗辉 区域的 FATE）。
    WaitIfBonusBuff                 = true          --如果角色持有“危命奖励提高”buff，不切换副本区域。
    NumberOfInstances               = 2
ShouldExchangeBicolorGemstones      = true          --是否自动兑换双色宝石凭证？
    ItemToPurchase                  = "图拉尔双色宝石的收据"        -- 旧萨雷安兑换"双色宝石的收据"，九号解决方案兑换"图拉尔双色宝石的收据"。
SelfRepair                          = false         --自己修理装备，若为 false，则前往利姆萨·罗敏萨修理装备。
    RepairAmount                    = 20            --耐久度低于该数值时进行修理（设为0则禁用自动修理）。
    ShouldAutoBuyDarkMatter         = true          --当暗物质耗尽时，自动从利姆萨·罗敏萨金币商店购买99个8级暗物质。
ShouldExtractMateria                = true          --是否进行精制魔晶石？
Retainers                           = false         --是否处理雇员探险？（如果您不在原始服务器请设置为 false，否则会卡死）
ShouldGrandCompanyTurnIn            = false         --是否向大国防联军提交筹备（需要 Deliveroo 插件支持，但是国服不能用）
    InventorySlotsLeft              = 5             --提交筹备前要求的最低剩余背包格数

ReturnOnDeath                       = true          --角色死亡后是否确认自动返回（默认true）

Echo                                = "All"         --选项: All/Gems/None 打印信息（All = 全部，Gems = 票据，None = 不打印）

CompanionScriptMode                 = false         --如果您需要将 FATE 脚本与其他配套脚本配合使用（如魂晶收集脚本 Atma Famer、多地图伐木脚本 Multi Zone Farming），请设置为 true。

--#endregion Settings

--[[
********************************************************************************
*               代码部分: 除非你清楚自己在做什么，否则请勿修改                     *
********************************************************************************
]]

--#region Plugin Checks and Setting Init

if not HasPlugin("vnavmesh") then
    yield("/echo [FATE] 请安装 vnavmesh 插件")
end

if not HasPlugin("BossMod") and not HasPlugin("BossModReborn") then
    yield("/echo [FATE] 请安装一个 AI 躲避插件，可选择 BossMod 或 BossMod Reborn")
end

if not HasPlugin("TextAdvance") then
    yield("/echo [FATE] 请安装 TextAdvance 插件")
end

if EnableChangeInstance == true  then
    if HasPlugin("Lifestream") == false then
        yield("/echo [FATE] 请安装 Lifestream 插件，或者在设置中将 ChangeInstance 设置为 false")
    end
end
if Retainers then
    if not HasPlugin("AutoRetainer") then
        yield("/echo [FATE] 请安装 AutoRetainer 插件")
    end
end
if ShouldGrandCompanyTurnIn then
    if not HasPlugin("Deliveroo") then
        ShouldGrandCompanyTurnIn = false
        yield("/echo [FATE] 请安装 Deliveroo 插件")
    end
end
if ShouldExtractMateria then
    if HasPlugin("YesAlready") == false then
        yield("/echo [FATE] 请安装 YesAlready 插件")
    end
end
if DodgingPlugin == "None" then
    -- do nothing
elseif RotationPlugin == "BMR" and DodgingPlugin ~= "BMR" then
    DodgingPlugin = "BMR"
elseif RotationPlugin == "VBM" and DodgingPlugin ~= "VBM"  then
    DodgingPlugin = "VBM"
end

if not CompanionScriptMode then --如果使用配套脚本，/at y 命令将由配套脚本进行控制
    yield("/at y")
end

--snd property
function setSNDProperty(propertyName, value)
    local currentValue = GetSNDProperty(propertyName)
    if currentValue ~= value then
        SetSNDProperty(propertyName, tostring(value))
        LogInfo("[SetSNDProperty] " .. propertyName .. " set to " .. tostring(value))
    end
end

setSNDProperty("UseItemStructsVersion", true)
setSNDProperty("UseSNDTargeting", true)
setSNDProperty("StopMacroIfTargetNotFound", false)
setSNDProperty("StopMacroIfCantUseItem", false)
setSNDProperty("StopMacroIfItemNotFound", false)
setSNDProperty("StopMacroIfAddonNotFound", false)
setSNDProperty("StopMacroIfAddonNotVisible", false)

--#endregion Plugin Checks and Setting Init

--#region Data

CharacterCondition = {
    normalconditions=1,
    dead=2,
    mounted=4,
    inCombat=26,
    casting=27,
    occupiedInEvent=31,
    occupiedInQuestEvent=32,
    occupied=33,
    boundByDuty34=34,
    occupiedMateriaExtractionAndRepair=39,
    betweenAreas=45,
    jumping48=48,
    jumping61=61,
    occupiedSummoningBell=50,
    betweenAreasForDuty=51,
    boundByDuty56=56,
    mounting57=57,
    mounting64=64,
    beingMoved=70,
    flying=77
}

ClassList =
{
    gla = { classId=1, className="剑术师", isMelee=true, isTank=true },
    pgl = { classId=2, className="格斗家", isMelee=true, isTank=false },
    mrd = { classId=3, className="斧术师", isMelee=true, isTank=true },
    lnc = { classId=4, className="枪术师", isMelee=true, isTank=false },
    arc = { classId=5, className="弓箭手", isMelee=false, isTank=false },
    cnj = { classId=6, className="幻术师", isMelee=false, isTank=false },
    thm = { classId=7, className="咒术师", isMelee=false, isTank=false },
    pld = { classId=19, className="骑士", isMelee=true, isTank=true },
    mnk = { classId=20, className="武僧", isMelee=true, isTank=false },
    war = { classId=21, className="战士", isMelee=true, isTank=true },
    drg = { classId=22, className="龙骑士", isMelee=true, isTank=false },
    brd = { classId=23, className="诗人", isMelee=false, isTank=false },
    whm = { classId=24, className="白魔法师", isMelee=false, isTank=false },
    blm = { classId=25, className="黑魔法师", isMelee=false, isTank=false },
    acn = { classId=26, className="秘术师", isMelee=false, isTank=false },
    smn = { classId=27, className="召唤师", isMelee=false, isTank=false },
    sch = { classId=28, className="学者", isMelee=false, isTank=false },
    rog = { classId=29, className="双剑师", isMelee=false, isTank=false },
    nin = { classId=30, className="忍者", isMelee=true, isTank=false },
    mch = { classId=31, className="机工士", isMelee=false, isTank=false},
    drk = { classId=32, className="暗黑骑士", isMelee=true, isTank=true },
    ast = { classId=33, className="占星术士", isMelee=false, isTank=false },
    sam = { classId=34, className="武士", isMelee=true, isTank=false },
    rdm = { classId=35, className="赤魔法师", isMelee=false, isTank=false },
    blu = { classId=36, className="青魔法师", isMelee=false, isTank=false },
    gnb = { classId=37, className="绝枪战士", isMelee=true, isTank=true },
    dnc = { classId=38, className="舞者", isMelee=false, isTank=false },
    rpr = { classId=39, className="钐镰客", isMelee=true, isTank=false },
    sge = { classId=40, className="贤者", isMelee=false, isTank=false },
    vpr = { classId=41, className="蝰蛇剑士", isMelee=true, isTank=false },
    pct = { classId=42, className="绘灵法师", isMelee=false, isTank=false }
}

BicolorExchangeData =
{
    {
        shopKeepName = "广域交易商 加德弗里德",
        zoneName = "旧萨雷安",
        zoneId = 962,
        aetheryteName = "旧萨雷安",
        x=78, y=5, z=-37,
        shopItems =
        {
            { itemName = "双色宝石的收据", itemIndex = 8, price = 100 },
            { itemName = "麝牛奶", itemIndex = 9, price = 2 },
            { itemName = "桓娑鸟胸肉", itemIndex = 10, price = 2 },
            { itemName = "亚考牛肩肉", itemIndex = 11, price = 2 },
            { itemName = "厄尔庇斯之鸟胸肉", itemIndex = 12, price = 2 },
            { itemName = "厄尔庇斯之鸟蛋", itemIndex = 13, price = 2 },
            { itemName = "庵摩罗果", itemIndex = 14, price = 2 },
            { itemName = "潜能量碎晶", itemIndex = 15, price = 2 },
            { itemName = "阿尔马斯提毛发", itemIndex = 16, price = 2 },
            { itemName = "伽迦象的粗皮", itemIndex = 17, price = 2 },
            { itemName = "山鸡的粗皮", itemIndex = 18, price = 2 },
            { itemName = "赛加羚羊的粗皮", itemIndex = 19, price = 2 },
            { itemName = "金毗罗鳄的粗皮", itemIndex = 20, price = 2 },
            { itemName = "蛇牛的粗皮", itemIndex = 21, price = 2 },
            { itemName = "贝尔卡楠的树液", itemIndex = 22, price = 2 },
            { itemName = "炸药怪的灰", itemIndex = 23, price = 2 },
            { itemName = "月面仙人刺的花", itemIndex = 24, price = 2 },
            { itemName = "慕斯怪的肉", itemIndex = 25, price = 2 },
            { itemName = "彩蝶鳞粉", itemIndex = 26, price = 2 },
        }
    },
    {
        shopKeepName = "广域交易商 贝瑞尔",
        zoneName = "九号解决方案",
        zoneId = 1186,
        aetheryteName = "九号解决方案",
        x=-198.47, y=0.92, z=-6.95,
        miniAethernet = {
            name = "联合商城",
            x=-157.74, y=0.29, z=17.43
        },
        shopItems =
        {
            { itemName = "图拉尔双色宝石的收据", itemIndex = 6, price = 100 },
            { itemName = "羊驼的里脊肉", itemIndex = 7, price = 3 },
            { itemName = "沼泽鬼鱼的腿肉", itemIndex = 8, price = 3 },
            { itemName = "犎牛肩肉", itemIndex = 9, price = 3 },
            { itemName = "巨龙舌兰的球茎", itemIndex = 10, price = 3 },
            { itemName = "拟鸟枝的果实", itemIndex = 11, price = 3 },
            { itemName = "圆扇刺梨", itemIndex = 12, price = 3 },
            { itemName = "犎牛兽毛", itemIndex = 13, price = 3 },
            { itemName = "奥阔银狼的粗皮", itemIndex = 14, price = 3 },
            { itemName = "锤头鳄的粗皮", itemIndex = 15, price = 3 },
            { itemName = "狞豹的粗皮", itemIndex = 16, price = 3 },
            { itemName = "嵌齿象的粗皮", itemIndex = 17, price = 3 },
            { itemName = "卡冈图亚的粗皮", itemIndex = 18, price = 3 },
            { itemName = "小鸣鼠的刃爪", itemIndex = 19, price = 3 },
            { itemName = "毒蛙的粘液", itemIndex = 20, price = 3 },
            { itemName = "斧喙魔鸟的翼膜", itemIndex = 21, price = 3 },
            { itemName = "小亚波伦的甲壳", itemIndex = 22, price = 3 },
            { itemName = "风滚蟹的枯草", itemIndex = 23, price = 3 },
        }
    }
}

FatesData = {
    {
        zoneName = "中拉诺西亚",
        zoneId = 134,
        fatesList = {
            collectionsFates= {},
            otherNpcFates= {
                { fateName="鼹鼠的秘密" , npcName="一筹莫展的农夫" },
                { fateName="实战巡礼", npcName="黄衫队训练教官"},
                { fateName="鼠害的小聪明", npcName="求助的农夫" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "拉诺西亚低地",
        zoneId = 135,
        fatesList = {
            collectionsFates= {},
            otherNpcFates= {
                { fateName="麻烦人生——偷渡者阿科特修提姆" , npcName="熟练的警备兵" },
                { fateName="花丛噩梦", npcName="愤怒的农夫" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "中萨纳兰",
        zoneId = 141,
        fatesList = {
            collectionsFates= {
                { fateName="营养丰富的仙人掌", npcName="饥饿的少女"},
            },
            otherNpcFates= {
                { fateName="屈伊伯龙家的人" , npcName="无计可施的商人" },
                { fateName="深不见底——酒豪谷谷卢恩", npcName="金库灵柩亭的保镖" },
                { fateName="粗野的赌徒——无赖格里希尔德", npcName="失败的冒险者" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "东萨纳兰",
        zoneId = 145,
        fatesList = {
            collectionsFates= {},
            otherNpcFates= {
                { fateName="跨天桥上的死斗 市民营救战" , npcName="铜刃团卫兵" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "南萨纳兰",
        zoneId = 146,
        fatesList = {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            blacklistedFates= {}
        },
        flying = false
    },
    {
        zoneName = "拉诺西亚外地",
        zoneId = 180,
        fatesList = {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            blacklistedFates= {}
        },
        flying = false
    },
    {
        zoneName = "库尔札斯中央高地",
        zoneId = 155,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            specialFates = {
                "受伤的魔兽——贝希摩斯" --贝爷
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "库尔札斯西部高地",
        zoneId = 397,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {
                { fateName="巡礼骑士", npcName="巡礼骑士" },
                { fateName="年轻龙骑士——阿莱姆贝", npcName="圣菲内雅连队的骑兵" },
                { fateName="功绩掠夺者——卑鄙的维尔纳", npcName="直率的博多内" }
            },
            fatesWithContinuations = {
                { fateName="黑铁桥之战", continuationIsBoss=true },
                { fateName="白雪茫茫", continuationIsBoss=true },
                { fateName="讨伐龙之眷属", continuationIsBoss=true },
                { fateName="年轻龙骑士——阿莱姆贝", continuationIsBoss=false }
            },
            blacklistedFates= {
                "吞噬牦牛的巨人——巨脚雪人", -- 成就 FATE 数值怪，单刷必死
            }
        }
    },
    {
        zoneName = "摩杜纳",
        zoneId = 156,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "阿巴拉提亚云海",
        zoneId = 401,
        fatesList= {
            collectionsFates= {
                { fateName="天空之云", npcName="年轻的尊杜人" },
            },
            otherNpcFates= {
                { fateName="突飞猛进", npcName="云顶蔷薇骑兵" },
                { fateName="逃亡者", npcName="逃亡的尊杜奴隶" }
            },
            fatesWithContinuations = {
                { fateName="冠恐鸟窝破坏命令", continuationIsBoss=true },
                { fateName="逃亡者", continuationIsBoss=false },
                { fateName="云神祭司——凯那瓦努", continuationIsBoss=false },
                { fateName="凯那瓦努的弟子们", continuationIsBoss=true }
            },
            blacklistedFates= {
                "逃亡者", -- 护送任务
                "暴食人形岩——大地饕餮" -- 成就 FATE 数值怪，单刷必死
            }
        }
    },
    {
        zoneName = "魔大陆阿济兹拉",
        zoneId = 402,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {
                { fateName="错误报告199号", npcName="检查系统" }
            },
            fatesWithContinuations = {
                { fateName="全自动手工业", continuationIsBoss=true }
            },
            specialFates = {
                "太古威胁 夜光花歼灭战" --夜光花特殊fate
            },
            blacklistedFates= {
                "太古威胁 夜光花歼灭战" --夜光花特殊fate，不打
            }
        }
    },
    {
        zoneName = "龙堡参天高地",
        zoneId = 398,
        fatesList= {
            collectionsFates= {
                { fateName="不灭之箭", npcName="尾羽集落的猎人" }
            },
            otherNpcFates= {
                { fateName="芳香四溢", npcName="散发醇香的莫西·匹克" }
            },
            fatesWithContinuations = {
                { fateName="敌人的敌人还是敌人", continuationIsBoss=true }
            },
            specialFates = {
                "雷兽女王——长须豹女王", --长须豹
                "幻影女王——长须豹女王", --长须豹
                "逆袭女王——长须豹女王" --长须豹             
            },
            blacklistedFates= {
                "雷兽女王——长须豹女王", --长须豹
                "幻影女王——长须豹女王", --长须豹
                "逆袭女王——长须豹女王", --长须豹 
                "坚甲铁龙——塔拉斯克" --成就 FATE 数值怪，单刷必死
            }
        }
    },
    {
        zoneName = "龙堡内陆低地",
        zoneId=399,
        tpZoneId = 478,
        fatesList= {
            collectionsFates= {
                { fateName="珍惜古书", npcName="视书如命 布罗菲克斯" },
                { fateName="恶魔机器", npcName="多面玲珑 斯里克崔克斯" }
            },
            otherNpcFates= {
                { fateName="使魔不好当", npcName="马洛·罗格" }, -- 护送任务，黑名单
            },
            fatesWithContinuations = {
                { fateName="哥布林纷争", continuationIsBoss=true },
                { fateName="恶魔机器", continuationIsBoss=false }
                --{ fateName="复仇者们", continuationIsBoss=true }, -- 成就 FATE 前置，无视
            },
            blacklistedFates= {
                "全面改造机——3号哥布林装甲J型", --成就 FATE 数值怪，单刷必死
                "使魔不好当" --护送任务
            }
        }
    },
    {
        zoneName = "翻云雾海",
        zoneId=400,
        fatesList= {
            collectionsFates= {
                { fateName="莫古力赚钱之道", npcName="追求时尚的莫古力" }
            },
            otherNpcFates= {
                { fateName="古恐龙再见", npcName="小顽童 莫古希" },
                { fateName="云海小顽童——莫古希", npcName="优等生 莫古珀" },
                { fateName="永不衰退的吸引力", npcName="滔滔不绝的莫古力" }, --护送任务，黑名单
                { fateName="天极白垩宫防卫战 救助幼龙", npcName="天极幼龙" },
                { fateName="夜与雾", npcName="法亚拉" },
                { fateName="圣与邪的扭曲", npcName="天极幼龙" }
            },
            fatesWithContinuations = {
                { fateName="火尾飞蜥大军", continuationIsBoss=false },
                { fateName="与龙共舞", continuationIsBoss=false },
                { fateName="暗鳞黑龙征讨战 白龙支援", continuationIsBoss=false },
                { fateName="暗鳞黑龙征讨战 追击作战", continuationIsBoss=false }
                --{ fateName="暗鳞黑龙征讨战 决战", continuationIsBoss=true }, --成就 FATE 前置，无视
            },
            blacklistedFates= {
                "永不衰退的吸引力", --护送任务
                "暗鳞黑龙征讨战 决战", --防御，成就任务，不知道血量情况
                "苍天白龙——维德佛尔尼尔" --成就 FATE 数值怪，单刷必死
            }
        }
    },
    {
        zoneName = "基拉巴尼亚边区",
        zoneId = 612,
        fatesList= {
            collectionsFates= {
                { fateName="集中训练营 士兵之章", npcName="弗雷拉克·巴尔本辛协漩校" },
                { fateName="新石器时代", npcName="梅氏的少女" },
            },
            otherNpcFates= {
                { fateName="冥河世界", npcName="黑涡团传令员" },
                { fateName="蚁狮没有攻击性", npcName="梅氏的猎人" },
                { fateName="下个岩石继续", npcName="阿拉米格解放军战士" }, -- need check
                { fateName="边境巡视员", npcName="阿拉米格解放军战士" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "基拉巴尼亚山区",
        zoneId = 620,
        fatesList= {
            collectionsFates= {
                { fateName="狮鹫物语", npcName="流浪的酒保商人" }
            },
            otherNpcFates= {
                { fateName="勇敢的蚱蜢", npcName="受伤的战士" },
                { fateName="生死关头", npcName="阿拉加纳的居民" },
                { fateName="等好久了！", npcName="寒炉村居民" },
                { fateName="血的收获", npcName="倔强的农夫" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {
                "失控的最终兵器——致命武器", --escort
                "素食主义者" --escort
            }
        }
    },
    {
        zoneName = "基拉巴尼亚湖区",
        zoneId = 621,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            specialFates = {
                "传说中的雷马——伊克西翁" --雷马
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "红玉海",
        zoneId = 613,
        fatesList= {
            collectionsFates= {
                { fateName="红甲族千两首", npcName="被打劫的碧甲族" },
                { fateName="红色珊瑚礁", npcName="稳重的海盗" }
            },
            otherNpcFates= {
                { fateName="兵法修行者——一刀客千万", npcName="海贼众的少女" },
                { fateName="红甲族恣意的风筝", npcName="负伤的海盗" },
                { fateName="无礼的牛鬼——尘轮鬼", npcName="十分困扰的海盗" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "延夏",
        zoneId = 614,
        fatesList= {
            collectionsFates= {
                { fateName="稻生物怪录", npcName="束手无策的农妇" },
                { fateName="银狐的心愿", npcName="银狐" }
            },
            otherNpcFates= {
                { fateName="金狐的心愿", npcName="金狐" },
                { fateName="倒霉的鱼群", npcName="大鱼丰收 鱼群" }
            },
            specialFates = {
                "九尾妖狐——玉藻御前" --玉藻前
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "太阳神草原",
        zoneId = 622,
        fatesList= {
            collectionsFates= {
                { fateName="答塔克的旅程之挤羊奶", npcName="阿儿塔尼" }
            },
            otherNpcFates= {
                { fateName="忏悔", npcName="奥罗尼部年轻人" },
                { fateName="归家路上的放牛少女", npcName="奥儿昆德部牛倌" },
                { fateName="转瞬的噩梦", npcName="模儿部羊倌" },
                { fateName="沉默的制裁", npcName="凯苏提尔部商人" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "雷克兰德",
        zoneId = 813,
        fatesList= {
            collectionsFates= {
                { fateName="樵夫之歌", npcName="雷克兰德的樵夫" }
            },
            otherNpcFates= {
                { fateName="与紫叶团的战斗之卑鄙陷阱", npcName="像是旅行商人的男子" },
                { fateName="污秽之血", npcName="乔布要塞的卫兵" }
            },
            fatesWithContinuations = {
                "高度进化"
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "珂露西亚岛",
        zoneId = 814,
        fatesList= {
            collectionsFates= {
                { fateName="制作战士之自走人偶", npcName="图尔家族的技师" }
            },
            otherNpcFates= {
                { fateName="制作战士之实机测试", npcName="图尔家族的技师" }
            },
            fatesWithContinuations = {},
            specialFates = {
                "激斗畏惧装甲之秘密武器" -- 畏惧装甲
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "安穆·艾兰",
        zoneId = 815,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {
                { fateName="拾荒者之萨迈尔脊骨", npcName="达马尔" },
                { fateName="寻求者之探索遗迹", npcName="达马尔" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {
                "托尔巴龟最棒", -- 对敌寻路困难
            }
        }
    },
    {
        zoneName = "伊尔美格",
        zoneId = 816,
        fatesList= {
            collectionsFates= {
                { fateName="仙子尾巴之金黄花蜜", npcName="寻找花蜜的仙子" }
            },
            otherNpcFates= {
                { fateName="仙子尾巴之魔物包围网", npcName="寻找花蜜的仙子" },
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "拉凯提卡大森林",
        zoneId = 817,
        fatesList= {
            collectionsFates= {
                { fateName="粉红鹳", npcName="夜之民导师" },
                { fateName="缅楠的巡逻之补充弓箭", npcName="散弓音 缅楠" },
                { fateName="传说诞生", npcName="法诺的看守" }
            },
            otherNpcFates= {
                { fateName="死相陆鸟——刻莱诺", npcName="法诺的猎人" },
                { fateName="吉梅与萨梅", npcName="血红枪 吉梅" },
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "黑风海",
        zoneId = 818,
        fatesList= {
            collectionsFates= {
                { fateName="灾厄的古塔尼亚之收集红血珊瑚", npcName="提乌嘶·澳恩" },
                { fateName="珍珠永恒", npcName="鳍人族捕鱼人" }
            },
            otherNpcFates= {
                { fateName="灾厄的古塔尼亚之开始追踪", npcName="提乌嘶·澳恩" },
                { fateName="灾厄的古塔尼亚之兹姆嘶登场", npcName="提乌嘶·澳恩" },
                { fateName="灾厄的古塔尼亚之保护提乌嘶", npcName="提乌嘶·澳恩" },
            },
            fatesWithContinuations = {},
            specialFates = {
                "灾厄的古塔尼亚之深海讨伐战" --古塔尼亚
            },
            blacklistedFates= {
                "灾厄的古塔尼亚之护卫提乌嘶", -- escort fate
                "贝汁物语", -- escort fate
            }
        }
    },
    {
        zoneName = "迷津",
        zoneId = 956,
        fatesList= {
            collectionsFates= {
                { fateName="迷津风玫瑰", npcName="束手无策的研究员" },
                { fateName="纯天然保湿护肤品", npcName="皮肤很好的研究员" },
                { fateName="牧羊人的日常", npcName="种畜研究所的驯兽人" }
            },
            otherNpcFates= {},
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "萨维奈岛",
        zoneId = 957,
        fatesList= {
            collectionsFates= {
                { fateName="芳香的炼金术士：危险的芬芳", npcName="调香师 萨加巴缇" }
            },
            otherNpcFates= {
                { fateName="少年与海", npcName="渔夫的儿子" },
                { fateName="猴子军团", npcName="采草药的女孩" },
            },
            specialFates = {
                "兽道诸神信仰：伪神降临" --明灯天王
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "加雷马",
        zoneId = 958,
        fatesList= {
            collectionsFates= {
                { fateName="资源回收分秒必争", npcName="沦为难民的魔导技师" }
            },
            otherNpcFates= {
                { fateName="魔导技师的归乡之旅：启程", npcName="柯尔特隆纳协漩尉" },
                { fateName="魔导技师的归乡之旅：落入陷阱", npcName="埃布雷尔诺" },
                { fateName="魔导技师的归乡之旅：实弹射击", npcName="柯尔特隆纳协漩尉" },
                { fateName="雪原的巨魔", npcName="幸存的难民" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "叹息海",
        zoneId = 959,
        fatesList= {
            collectionsFates= {
                { fateName="如何追求兔生刺激", npcName="担惊威" }
            },
            otherNpcFates= {
                { fateName="叹息的白兔之轰隆隆大爆炸", npcName="战兵威" },
                { fateName="叹息的白兔之乱糟糟大失控", npcName="落名威" },
                { fateName="叹息的白兔之怒冲冲大处理", npcName="落名威" },
            },
            fatesWithContinuations = {},
            blacklistedFates= {
                "跨海而来的老饕", --由于斜坡上视野不佳，可能什么都做不了就呆站着
            }
        }
    },
    {
        zoneName = "天外天垓",
        zoneId = 960,
        fatesList= {
            collectionsFates= {
                { fateName="侵略兵器召回指令：扩建通信设备", npcName="N-6205" }
            },
            otherNpcFates= {
                { fateName="荣光之翼——阿尔·艾因", npcName="阿尔·艾因的朋友" },
                { fateName="侵略兵器召回指令：保护N-6205", npcName="N-6205"},
                { fateName="走向永恒的结局", npcName="米克·涅尔" }
            },
            specialFates = {
                "侵略兵器召回指令：破坏侵略兵器希" --希
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "厄尔庇斯",
        zoneId = 961,
        fatesList= {
            collectionsFates= {
                { fateName="望请索克勒斯先生谅解", npcName="负责植物的观察者" }
            },
            otherNpcFates= {
                { fateName="创造计划：过于新颖的理念", npcName="神秘莫测 莫勒图斯" },
                { fateName="创造计划：伊娥观察任务", npcName="神秘莫测 莫勒图斯" },
                { fateName="告死鸟", npcName="一角兽的观察者" },
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "奥阔帕恰山",
        zoneId = 1187,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {
                { fateName="牧场关门", npcName="健步如飞 基维利" },
                { fateName="不死之人", npcName="扫墓的尤卡巨人" },
                { fateName="失落的山顶都城", npcName="守护遗迹的尤卡巨人" },
                { fateName="咖啡豆岌岌可危", npcName="咖啡农园的工作人员" },
                { fateName="千年孤独", npcName="其瓦固佩刀者" },
                { fateName="跃动的火热——山火", npcName="健步如飞 基维利"} ,
                { fateName="飞天魔厨——佩鲁的天敌", npcName="佩鲁佩鲁的旅行商人" },
                { fateName="狼之家族", npcName="佩鲁佩鲁的旅行商人" }
            },
            fatesWithContinuations = {
                { fateName="千年孤独", continuationIsBoss=true }
            },
            blacklistedFates= {
                --"只有爆炸", -- 能打
                "狼之家族", -- 存在多个 佩鲁佩鲁族的旅行商人 npc，能否与正确npc交互开始FATE存在随机性，开启DR"自动开始临危受命任务"可以取消这条黑名单（佩鲁佩鲁的旅行商人）
                "飞天魔厨——佩鲁的天敌", -- 存在多个 佩鲁佩鲁族的旅行商人 npc，开启DR"自动开始临危受命任务"可以取消这条黑名单（佩鲁佩鲁的旅行商人）
                "跃动的火热——山火" -- FATE周围有石头挡着，AI 躲避会日墙无限抽搐，但是能打得过
            }
        }
    },
    {
        zoneName="克扎玛乌卡湿地",
        zoneId=1188,
        fatesList={
            collectionsFates={
                { fateName="密林淘金", npcName="莫布林族采集者" },
                { fateName="巧若天工", npcName="哈努族手艺人" },
                
            },
            otherNpcFates= {
                { fateName="怪力大肚王——非凡飔戮龙", npcName="哈努族捕鱼人" },
                { fateName="贡品小偷", npcName="哈努族巫女" },
                { fateName="美丽菇世界", npcName="贴心巧匠 巴诺布罗坷" },
                { fateName="芦苇荡的时光", npcName="哈努族农夫" },
                { fateName="横征暴敛？", npcName="佩鲁佩鲁族商人" },

            },
            fatesWithContinuations = {},
            blacklistedFates= {
                --"打鼹鼠行动", -- 地形烂，在改良逻辑后能打了
                "横征暴敛？" -- 存在多个 佩鲁佩鲁族旅行商人 npc，开启DR"自动开始临危受命任务"可以取消这条黑名单（佩鲁佩鲁的旅行商人）
            }
        }
    },
    {
        zoneName="亚克特尔树海",
        zoneId=1189,
        fatesList= {
            collectionsFates= {
                { fateName="逃离恐怖菇", npcName="霍比格族采集者" }
            },
            otherNpcFates= {
                --{ fateName="顶击大貒猪", npcName="灵豹之民猎人" }, 2 npcs names same thing.... 开启DR"自动开始临危受命任务"可以取消这条黑名单
                --{ fateName="血染利爪——米尤鲁尔", npcName="灵豹之民猎人" }, 2 npcs names same thing.... 开启DR"自动开始临危受命任务"可以取消这条黑名单
                { fateName="辉鳞族不法之徒袭击事件", npcName="朵普罗族枪手" },
                { fateName="守护秘药之战", npcName="霍比格族运货人" }
                -- { fateName="致命螳螂", npcName="灵豹之民猎人" }, -- 2 npcs named same thing..... 开启DR"自动开始临危受命任务"可以取消这条黑名单
            },
            fatesWithContinuations = {
                "辉鳞族不法之徒袭击事件"
            },
            blacklistedFates= {
                --"圣树邪魔——坏死花" -- 能打
            }
        }
    },
    {
        zoneName="夏劳尼荒野",
        zoneId=1190,
        fatesList= {
            collectionsFates= {
                { fateName="剃毛时间", npcName="迎曦之民采集者" },
                { fateName="蛇王得酷热涅：狩猎前的准备", npcName="夕阳尚红 布鲁克·瓦" }
            },
            otherNpcFates= {
                { fateName="死而复生的恶棍——阴魂不散 扎特夸", npcName="迎曦之民劳动者" }, --22 boss
                { fateName="和牛一起旅行", npcName="崇灵之民女性" }, --23 normal
                { fateName="不甘的冲锋者——灰达奇", npcName="崇灵之民男性" }, --22 boss
                { fateName="大湖之恋", npcName="崇灵之民渔夫" }, --24 tower defense
                { fateName="蛇王得酷热涅：狩猎的杀手锏", npcName="夕阳尚红 布鲁克·瓦" }, -- need check
                { fateName="神秘翼龙荒野奇谈", npcName="佩鲁佩鲁族旅行商人" }, --wiki 有误，已修正
            },
            fatesWithContinuations = {
                "蛇王得酷热涅：狩猎前的准备" -- 这是一个收集类 FATE
            },
            specialFates = {
                "蛇王得酷热涅：荒野的死斗" -- 得酷热涅
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName="遗产之地",
        zoneId=1191,
        fatesList= {
            collectionsFates= {
                { fateName="药师的工作", npcName="迎曦之民栽培者" },
                { fateName="亮闪闪的可回收资源", npcName="英姿飒爽的再造者" }
            },
            otherNpcFates= {
                { fateName="机械迷城", npcName="初出茅庐的狩猎者" },
                { fateName="你来我往", npcName="初出茅庐的狩猎者" },
                { fateName="剥皮行者", npcName="陷入危机的狩猎者" },
                { fateName="机械公敌", npcName="走投无路的再造者" },
                { fateName="铭刻于灵魂中的恐惧", npcName="终流地的再造者" },
                { fateName="前路多茫然", npcName="害怕的运送者" }
            },
            fatesWithContinuations = {
                { fateName="机械公敌", continuationIsBoss=false } --已解决地底寻路问题，fatesWithContinuations 表内 fate 打完后会原地等 30 秒等下一个连续的 FATE
            },
            blacklistedFates= {
                --"亮闪闪的可回收资源", -- 地形问题，非常容易被卡住直到FATE结束或角色死亡，改良逻辑后正常了
                --"养虺成蛇", -- 问题同上
                --"机械公敌", -- 可能会寻路到地底导致卡死，改良逻辑后正常了
                --"基本有害" -- 地形问题，可能会降落在石头上卡寻路，改良逻辑后正常了
            }
        }
    },
    {
        zoneName="活着的记忆",
        zoneId=1192,
        fatesList= {
            collectionsFates= {
                { fateName="良种难求", npcName="无失哨兵GX" },
                { fateName="记忆的碎片", npcName="无失哨兵GX" }
            },
            otherNpcFates= {
                { fateName="为了运河镇的安宁", npcName="无失哨兵GX" },
                { fateName="亩鼠米卡：盛装巡游开始", npcName="滑稽巡游主宰" }
            },
            fatesWithContinuations =
            {
                { fateName="水城噩梦", continuationIsBoss=true },
                { fateName="亩鼠米卡：盛装巡游开始", continuationIsBoss=true }
            },
            specialFates =
            {
                "亩鼠米卡：盛装巡游皆大欢喜"
            },
            blacklistedFates= {
            }
        }
    }
}

--#endregion Data

--#region Fate Functions
function IsCollectionsFate(fateName)
    for i, collectionsFate in ipairs(SelectedZone.fatesList.collectionsFates) do
        if collectionsFate.fateName == fateName then
            return true
        end
    end
    return false
end

function IsBossFate(fateId)
    local fateIcon = GetFateIconId(fateId)
    return fateIcon == 60722
end

function IsOtherNpcFate(fateName)
    for i, otherNpcFate in ipairs(SelectedZone.fatesList.otherNpcFates) do
        if otherNpcFate.fateName == fateName then
            return true
        end
    end
    return false
end

function IsSpecialFate(fateName)
    if SelectedZone.fatesList.specialFates == nil then
        return false
    end
    for i, specialFate in ipairs(SelectedZone.fatesList.specialFates) do
        if specialFate == fateName then
            return true
        end
    end
end

function IsBlacklistedFate(fateName)
    for i, blacklistedFate in ipairs(SelectedZone.fatesList.blacklistedFates) do
        if blacklistedFate == fateName then
            return true
        end
    end
    if not JoinCollectionsFates then
        for i, collectionsFate in ipairs(SelectedZone.fatesList.collectionsFates) do
            if collectionsFate.fateName == fateName then
                return true
            end
        end
    end
    return false
end

function GetFateNpcName(fateName)
    for i, fate in ipairs(SelectedZone.fatesList.otherNpcFates) do
        if fate.fateName == fateName then
            return fate.npcName
        end
    end
    for i, fate in ipairs(SelectedZone.fatesList.collectionsFates) do
        if fate.fateName == fateName then
            return fate.npcName
        end
    end
end

function IsFateActive(fateId)
    local activeFates = GetActiveFates()
    for i = 0, activeFates.Count-1 do
        if fateId == activeFates[i] then
            return true
        end
    end
    return false
end

function EorzeaTimeToUnixTime(eorzeaTime)
    return eorzeaTime/(144/7) -- 24h Eorzea Time equals 70min IRL
end

function SelectNextZone()
    local nextZone = nil
    local nextZoneId = GetZoneID()

    for i, zone in ipairs(FatesData) do
        if nextZoneId == zone.zoneId then
            nextZone = zone
        end
    end
    if nextZone == nil then
        yield("/echo [FATE] 当前地图暂不支持，缺少 NPC FATE 数据。")
        nextZone = {
            zoneName = "",
            zoneId = nextZoneId,
            fatesList= {
                collectionsFates= {},
                otherNpcFates= {},
                bossFates= {},
                blacklistedFates= {},
                fatesWithContinuations = {}
            }
        }
    end

    if nextZone.zoneId == nil then --增加检查 nextZone.zoneId 是否存在，否则 return
        LogInfo("[FATE] 获取地图 ID 异常，返回")
        yield("/e [FATE] 获取地图 ID 异常，返回")
        return
    end

    nextZone.zoneName = nextZone.zoneName
    nextZone.aetheryteList = {}
    local aetheryteIds = GetAetherytesInZone(nextZone.zoneId)
    for i=0, aetheryteIds.Count-1 do
        local aetherytePos = GetAetheryteRawPos(aetheryteIds[i])
        local aetheryteTable = {
            aetheryteName = GetAetheryteName(aetheryteIds[i]),
            aetheryteId = aetheryteIds[i],
            x = aetherytePos.Item1,
            y = QueryMeshPointOnFloorY(aetherytePos.Item1, 1024, aetherytePos.Item2, true, 50),
            z = aetherytePos.Item2
        }
        table.insert(nextZone.aetheryteList, aetheryteTable)
    end

    if nextZone.flying == nil then
        nextZone.flying = true
    end

    if nextZone.aetheryteList == nil then
        LogInfo("[FATE] 没有获取到当前地图的以太之光信息！")
        yield("/e [FATE] 没有获取到当前地图的以太之光信息！")
        return
    end

    return nextZone
end

--[[
    Selects the better fate based on the priority order defined in FatePriority.
    Default Priority order is "Progress" -> "DistanceTeleport" -> "Bonus" -> "TimeLeft" -> "Distance"
]]
function SelectNextFateHelper(tempFate, nextFate)
    --Check if WaitForBonusIfBonusBuff is true, and have eithe buff, then set BonusFatesOnlyTemp to true
    if BonusFatesOnly then
        if not tempFate.isBonusFate and nextFate ~= nil and nextFate.isBonusFate then
            return nextFate
        elseif tempFate.isBonusFate and (nextFate == nil or not nextFate.isBonusFate) then
            return tempFate
        elseif not tempFate.isBonusFate and (nextFate == nil or not nextFate.isBonusFate) then
            return nil
        end
        -- if both are bonus fates, go through the regular fate selection process
    end

    if tempFate.timeLeft < MinTimeLeftToIgnoreFate or tempFate.progress > CompletionToIgnoreFate then
        LogInfo("[FATE] Ignoring fate #"..tempFate.fateId.." due to insufficient time or high completion.")
        return nextFate
    elseif nextFate == nil then
        LogInfo("[FATE] Selecting #"..tempFate.fateId.." because no other options so far.")
        return tempFate
    elseif nextFate.timeLeft < MinTimeLeftToIgnoreFate or nextFate.progress > CompletionToIgnoreFate then
        LogInfo("[FATE] Ignoring fate #"..nextFate.fateId.." due to insufficient time or high completion.")
        return tempFate
    end

    -- Evaluate based on priority (Loop through list return first non-equal priority)
    for _, criteria in ipairs(FatePriority) do
        if criteria == "Progress" then
            LogInfo("[FATE] Comparing progress: "..tempFate.progress.." vs "..nextFate.progress)
            if tempFate.progress > nextFate.progress then return tempFate end
            if tempFate.progress < nextFate.progress then return nextFate end
        elseif criteria == "Bonus" then
            LogInfo("[FATE] Checking bonus status: "..tostring(tempFate.isBonusFate).." vs "..tostring(nextFate.isBonusFate))
            if tempFate.isBonusFate and not nextFate.isBonusFate then return tempFate end
            if nextFate.isBonusFate and not tempFate.isBonusFate then return nextFate end
        elseif criteria == "TimeLeft" then
            LogInfo("[FATE] Comparing time left: "..tempFate.timeLeft.." vs "..nextFate.timeLeft)
            if tempFate.timeLeft > nextFate.timeLeft then return tempFate end
            if tempFate.timeLeft < nextFate.timeLeft then return nextFate end
        elseif criteria == "Distance" then
            local tempDist = GetDistanceToPoint(tempFate.x, tempFate.y, tempFate.z)
            local nextDist = GetDistanceToPoint(nextFate.x, nextFate.y, nextFate.z)
            LogInfo("[FATE] Comparing distance: "..tempDist.." vs "..nextDist)
            if tempDist < nextDist then return tempFate end
            if tempDist > nextDist then return nextFate end
        elseif criteria == "DistanceTeleport" then
            local tempDist = GetDistanceToPointWithAetheryteTravel(tempFate.x, tempFate.y, tempFate.z)
            local nextDist = GetDistanceToPointWithAetheryteTravel(nextFate.x, nextFate.y, nextFate.z)
            LogInfo("[FATE] Comparing distance: "..tempDist.." vs "..nextDist)
            if tempDist < nextDist then return tempFate end
            if tempDist > nextDist then return nextFate end
        end
    end

    -- Fallback: Select fate with the lower ID
    LogInfo("[FATE] Selecting lower ID fate: "..tempFate.fateId.." vs "..nextFate.fateId)
    return (tempFate.fateId < nextFate.fateId) and tempFate or nextFate
end

function BuildFateTable(fateId)
    local fateTable = {
        fateId = fateId,
        fateName = GetFateName(fateId),
        progress = GetFateProgress(fateId),
        duration = GetFateDuration(fateId),
        startTime = GetFateStartTimeEpoch(fateId),
        x = GetFateLocationX(fateId),
        y = GetFateLocationY(fateId),
        z = GetFateLocationZ(fateId),
        isBonusFate = GetFateIsBonus(fateId),
    }
    fateTable.npcName = GetFateNpcName(fateTable.fateName)

    local currentTime = EorzeaTimeToUnixTime(GetCurrentEorzeaTimestamp())
    if fateTable.startTime == 0 then
        fateTable.timeLeft = 900
    else
        fateTable.timeElapsed = currentTime - fateTable.startTime
        fateTable.timeLeft = fateTable.duration - fateTable.timeElapsed
    end

    fateTable.isCollectionsFate = IsCollectionsFate(fateTable.fateName)
    fateTable.isBossFate = IsBossFate(fateTable.fateId)
    fateTable.isOtherNpcFate = IsOtherNpcFate(fateTable.fateName)
    fateTable.isSpecialFate = IsSpecialFate(fateTable.fateName)
    fateTable.isBlacklistedFate = IsBlacklistedFate(fateTable.fateName)

    fateTable.continuationIsBoss = false
    fateTable.hasContinuation = false
    for _, continuationFate in ipairs(SelectedZone.fatesList.fatesWithContinuations) do
        if fateTable.fateName == continuationFate.fateName then
            fateTable.hasContinuation = true
            fateTable.continuationIsBoss = continuationFate.continuationIsBoss
        end
    end

    return fateTable
end

--Gets the Location of the next Fate. Prioritizes anything with progress above 0, then by shortest time left
function SelectNextFate()
    local fates = GetActiveFates()
    if fates == nil then
        return
    end

    local nextFate = nil
    for i = 0, fates.Count-1 do
        local tempFate = BuildFateTable(fates[i])
        LogInfo("[FATE] Considering fate #"..tempFate.fateId.." "..tempFate.fateName)
        LogInfo("[FATE] Time left on fate #:"..tempFate.fateId..": "..math.floor(tempFate.timeLeft//60).."min, "..math.floor(tempFate.timeLeft%60).."s")

        if not (tempFate.x == 0 and tempFate.z == 0) then -- sometimes game doesn't send the correct coords
            if not tempFate.isBlacklistedFate then -- check fate is not blacklisted for any reason
                if tempFate.isBossFate then
                    if (tempFate.isSpecialFate and tempFate.progress >= CompletionToJoinSpecialBossFates) or
                        (not tempFate.isSpecialFate and tempFate.progress >= CompletionToJoinBossFate) then
                        nextFate = SelectNextFateHelper(tempFate, nextFate)
                    else
                        LogInfo("[FATE] Skipping fate #"..tempFate.fateId.." "..tempFate.fateName.." due to boss fate with not enough progress.")
                    end
                elseif (tempFate.isOtherNpcFate or tempFate.isCollectionsFate) and tempFate.startTime == 0 then
                    if nextFate == nil then -- pick this if there's nothing else
                        nextFate = tempFate
                    elseif tempFate.isBonusFate then
                        nextFate = SelectNextFateHelper(tempFate, nextFate)
                    elseif nextFate.startTime == 0 then -- both fates are unopened npc fates
                        nextFate = SelectNextFateHelper(tempFate, nextFate)
                    end
                elseif tempFate.duration ~= 0 then -- else is normal fate. avoid unlisted talk to npc fates
                    nextFate = SelectNextFateHelper(tempFate, nextFate)
                end
                LogInfo("[FATE] Finished considering fate #"..tempFate.fateId.." "..tempFate.fateName)
            else
                LogInfo("[FATE] Skipping fate #"..tempFate.fateId.." "..tempFate.fateName.." due to blacklist.")
            end
        end
    end

    LogInfo("[FATE] Finished considering all fates")

    if nextFate == nil then
        LogInfo("[FATE] No eligible fates found.")
        if Echo == "All" then
            yield("/echo [FATE] 未找到符合条件的 FATE。")
        end
    else
        LogInfo("[FATE] Final selected fate #"..nextFate.fateId.." "..nextFate.fateName)
    end
    yield("/wait 0.211")

    return nextFate
end

function RandomAdjustCoordinates(x, y, z, maxDistance)
    local angle = math.random() * 2 * math.pi
    local x_adjust = maxDistance * math.random()
    local z_adjust = maxDistance * math.random()

    local randomX = x + (x_adjust * math.cos(angle))
    local randomY = y + maxDistance
    local randomZ = z + (z_adjust * math.sin(angle))

    return randomX, randomY, randomZ
end

--#endregion Fate Functions

--#region Movement Functions

function DistanceFromClosestAetheryteToPoint(x, y, z, teleportTimePenalty)
    if not SelectedZone or not SelectedZone.aetheryteList then
        yield("/e <获取以太之光与 FATE 之间的距离> 无地图以太之光信息，重新获取当前地图水晶信息")
        SelectedZone = SelectNextZone()
        return math.maxinteger
    end

    local closestAetheryte = nil
    local closestTravelDistance = math.maxinteger
    for _, aetheryte in ipairs(SelectedZone.aetheryteList) do
        -- 检查 aetheryte.aetheryteName 是否是数字（异常情况）
        if type(aetheryte.aetheryteName) == "number" then
            yield("/e <错误> 以太之光名称异常（数字），重新获取地图信息")
            SelectedZone = SelectNextZone()
            return math.maxinteger  -- 终止当前计算，等待下次调用
        end
        local distanceAetheryteToFate = DistanceBetween(aetheryte.x, y, aetheryte.z, x, y, z)
        local comparisonDistance = distanceAetheryteToFate + teleportTimePenalty
        LogInfo("[FATE] Distance via "..aetheryte.aetheryteName.." adjusted for tp penalty is "..tostring(comparisonDistance)) --Bug: aetheryte.aetheryteName 可能是数字或者为空，为什么会这样？

        if comparisonDistance < closestTravelDistance then
            LogInfo("[FATE] Updating closest aetheryte to "..aetheryte.aetheryteName)
            closestTravelDistance = comparisonDistance
            closestAetheryte = aetheryte
        end
    end

    return closestTravelDistance
end

function GetDistanceToPointWithAetheryteTravel(x, y, z)
    -- Get the direct flight distance (no aetheryte)
    local directFlightDistance = GetDistanceToPoint(x, y, z)
    LogInfo("[FATE] Direct flight distance is: " .. directFlightDistance)
    
    -- Get the distance to the closest aetheryte, including teleportation penalty
    local distanceToAetheryte = DistanceFromClosestAetheryteToPoint(x, y, z, 200)
    LogInfo("[FATE] Distance via closest Aetheryte is: " .. (distanceToAetheryte or "nil"))

    -- Return the minimum distance, either via direct flight or via the closest aetheryte travel
    if distanceToAetheryte == nil then
        return directFlightDistance
    else
        return math.min(directFlightDistance, distanceToAetheryte)
    end
end

function GetClosestAetheryte(x, y, z, teleportTimePenalty)
    if not SelectedZone or not SelectedZone.aetheryteList then
        yield("/e <获取最近水晶> 无地图以太之光信息，返回最大整数值 math.maxinteger")
        return math.maxinteger  -- 返回默认值
    end


    local closestAetheryte = nil
    local closestTravelDistance = math.maxinteger
    for _, aetheryte in ipairs(SelectedZone.aetheryteList) do
        LogInfo("[FATE] Considering aetheryte "..aetheryte.aetheryteName) -- 2.21.12 update
        local distanceAetheryteToFate = DistanceBetween(aetheryte.x, y, aetheryte.z, x, y, z)
        local comparisonDistance = distanceAetheryteToFate + teleportTimePenalty
        LogInfo("[FATE] Distance via "..aetheryte.aetheryteName.." adjusted for tp penalty is "..tostring(comparisonDistance))

        if comparisonDistance < closestTravelDistance then
            LogInfo("[FATE] Updating closest aetheryte to "..aetheryte.aetheryteName)
            closestTravelDistance = comparisonDistance
            closestAetheryte = aetheryte
        end
    end
    if closestAetheryte ~= nil then -- 2.21.13 update
        LogInfo("[FATE] Final selected aetheryte is: "..closestAetheryte.aetheryteName)
    else
        LogInfo("[FATE] Closest aetheryte is nil")
    end

    return closestAetheryte
end

function GetClosestAetheryteToPoint(x, y, z, teleportTimePenalty)
    local directFlightDistance = GetDistanceToPoint(x, y, z)
    LogInfo("[FATE] Direct flight distance is: "..directFlightDistance)
    local closestAetheryte = GetClosestAetheryte(x, y, z, teleportTimePenalty)
    if closestAetheryte ~= nil then
        local aetheryteY = QueryMeshPointOnFloorY(closestAetheryte.x, y, closestAetheryte.z, true, 50)
        if aetheryteY == nil then
            aetheryteY = GetPlayerRawYPos()
        end
        local closestAetheryteDistance = DistanceBetween(x, y, z, closestAetheryte.x, aetheryteY, closestAetheryte.z) + teleportTimePenalty

        if closestAetheryteDistance < directFlightDistance then
            return closestAetheryte
        end
    end
    return nil
end

function TeleportToClosestAetheryteToFate(nextFate)
    local aetheryteForClosestFate = GetClosestAetheryteToPoint(nextFate.x, nextFate.y, nextFate.z, 200)
    if aetheryteForClosestFate ~=nil then
        TeleportTo(aetheryteForClosestFate.aetheryteName)
        return true
    end
    return false
end

function AcceptTeleportOfferLocation(destinationAetheryte)
    if IsAddonVisible("_NotificationTelepo") then
        local location = GetNodeText("_NotificationTelepo", 3, 4)
        yield("/callback _Notification true 0 16 "..location)
        yield("/wait 1")
    end

    if IsAddonVisible("SelectYesno") then
        local teleportOfferMessage = GetNodeText("SelectYesno", 15)
        if type(teleportOfferMessage) == "string" then
            local teleportOfferLocation = teleportOfferMessage:match("要接受前往“(.+?)”的传送邀请吗？") --Replace: Accept Teleport to (.+)%?
            if teleportOfferLocation ~= nil then
                if string.lower(teleportOfferLocation) == string.lower(destinationAetheryte) then
                    yield("/callback SelectYesno true 0") -- accept teleport
                    return
                else
                    LogInfo("Offer for "..teleportOfferLocation.." and destination "..destinationAetheryte.." are not the same. Declining teleport.")
                end
            end
            yield("/callback SelectYesno true 2") -- decline teleport
            return
        end
    end
end

function AcceptNPCFateOrRejectOtherYesno()
    if IsAddonVisible("SelectYesno") then
        local dialogBox = GetNodeText("SelectYesno", 15)
        if type(dialogBox) == "string" and dialogBox:find("此危命任务的推荐等级为") then --Replace: The recommended level for this FATE is
            yield("/callback SelectYesno true 0") --accept fate
        else
            yield("/callback SelectYesno true 1") --decline all other boxes
        end
    end
end

-- 只有使用 AEAssist 作为循环才会出现这种问题，因为其他acr脱战不画，AE 脱战死也要画完
-- ※ 如何主动触发传送卡死：使用野菜，然后狂点/tp命令的宏，你就会发现自己没法传送了！
-- 这个问题目前只会出现在启用 Daily Routines 插件的情况下，禁用时不会发生
function EscapeTeleportStuckDR()
    --检查 Daily Routines 插件是否启用，如果没有启用则停止循环，有则自动进出本
    if not HasPlugin("DailyRoutines") then
        LogInfo("[FATE] 准备处理传送卡死，但由于没有安装或启用 Daily Routines 插件此功能无法生效，脚本即将停止，感谢您的使用，祝您好运！")
        yield("/e [FATE] 准备处理传送卡死，但由于没有安装或启用 Daily Routines 插件此功能无法生效，脚本即将停止，感谢您的使用，祝您好运！")
        StopScript = true
    else
        LogInfo("[FATE] 准备处理传送卡死！")
        yield("/e [FATE] 准备处理传送卡死！")

        --功能启用初始化
        yield("/pdr load AutoCommenceDuty")
        yield("/pdr load AutoJoinExitDuty")

        yield("/wait 1") --1秒延迟避免异常发生

        -- 执行进出副本
        yield("/pdr joinexitduty")
    end
end

--这个问题目前只会出现在启用 Daily Routines 插件的情况下，禁用时不会发生
--/tp 命令发起的传送会忽略动画锁，如果传送在动画锁内发起，极有可能在当前地图永久报错：无法发动传送，其他传送正在进行。
--这个问题主要发生在使用 AEAssist 循环画家职业在脱战后画画，使用技能的动画锁正好与发起传送时间碰一起了，之后无法在当前地图再次发起传送。
--SND 没有相关的逻辑封装来处理这个问题，如果卡传送了，重启游戏、回到标题、进出副本、切换地图脱困。
function TeleportTo(aetheryteName)
    -- 检查 aetheryteName 是否为空，如果为空则重新获取当前地图水晶并退出函数
    if aetheryteName == nil or aetheryteName == "" then
        LogInfo("[FATE] aetheryteName为空值！重新获取以太之光信息！")
        yield("/e aetheryteName为空值！重新获取以太之光信息！")
        SelectedZone = SelectNextZone()
        return
    end

    AcceptTeleportOfferLocation(aetheryteName)

    while EorzeaTimeToUnixTime(GetCurrentEorzeaTimestamp()) - LastTeleportTimeStamp < 5 do
        LogInfo("[FATE] Too soon since last teleport. Waiting...")
        yield("/wait 5.001")
    end

    yield("/tp "..aetheryteName)
    yield("/wait 1") -- wait for casting to begin

    if IsAddonVisible("_TextError") and GetNodeText("_TextError", 1) == "无法发动传送，其他传送正在进行。" then --使用 Daily Routines 插件处理卡顿，如果没安装则停用脚本
        EscapeTeleportStuckDR()
    end

    while GetCharacterCondition(CharacterCondition.casting) do
        LogInfo("[FATE] Casting teleport...")
        yield("/wait 1")
    end
    yield("/wait 1") -- wait for that microsecond in between the cast finishing and the transition beginning
    while GetCharacterCondition(CharacterCondition.betweenAreas) do
        LogInfo("[FATE] Teleporting...")
        yield("/wait 1")
    end
    yield("/wait 1")
    LastTeleportTimeStamp = EorzeaTimeToUnixTime(GetCurrentEorzeaTimestamp())
end

function ChangeInstance()
    if SuccessiveInstanceChanges >= NumberOfInstances then
        if CompanionScriptMode then
            local shouldWaitForBonusBuff = WaitIfBonusBuff and (HasStatusId(1288) or HasStatusId(1289))
            if WaitingForFateRewards == 0 and not shouldWaitForBonusBuff then
                StopScript = true
            else
                LogInfo("[Fate Farming] Waiting for buff or fate rewards")
                yield("/wait 3")
            end
        else
            yield("/wait 10")
            SuccessiveInstanceChanges = 0
        end
        return
    end

    yield("/target 以太之光") -- search for nearby aetheryte
    if not HasTarget() or GetTargetName() ~= "以太之光" then -- if no aetheryte within targeting range, teleport to it
        LogInfo("[FATE] Aetheryte not within targetable range")

        if not SelectedZone or not SelectedZone.aetheryteList or #SelectedZone.aetheryteList == 0 then --检查 SelectedZone.aetheryteList 不存在的情况
            LogInfo("[FATE] 当前地图未定义以太之光，换线任务中止")
            yield("/e [FATE] 当前地图未定义以太之光，换线任务中止")
            yield("/wait 5")
            return  -- 提前退出，避免后续报错
        end

        local closestAetheryte = nil
        local closestAetheryteDistance = math.maxinteger
        for i, aetheryte in ipairs(SelectedZone.aetheryteList) do
            -- GetDistanceToPoint is implemented with raw distance instead of distance squared
            local distanceToAetheryte = GetDistanceToPoint(aetheryte.x, aetheryte.y, aetheryte.z)
            if distanceToAetheryte < closestAetheryteDistance then
                closestAetheryte = aetheryte
                closestAetheryteDistance = distanceToAetheryte
            end
        end
        TeleportTo(closestAetheryte.aetheryteName)
        return
    end

    if WaitingForFateRewards ~= 0 then
        yield("/wait 10")
        return
    end

    if GetDistanceToTarget() > 10 then
        LogInfo("[FATE] Targeting aetheryte, but greater than 10 distance")
        if GetDistanceToTarget() > 20 and not GetCharacterCondition(CharacterCondition.mounted) then
            State = CharacterState.mounting
            LogInfo("[FATE] State Change: Mounting")
        elseif not (PathfindInProgress() or PathIsRunning()) then
            PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos(), GetCharacterCondition(CharacterCondition.flying) and SelectedZone.flying)
        end
        return
    end

    LogInfo("[FATE] Within 10 distance")
    if PathfindInProgress() or PathIsRunning() then
        yield("/vnav stop")
        return
    end

    if GetCharacterCondition(CharacterCondition.mounted) then
        State = CharacterState.changeInstanceDismount
        LogInfo("[FATE] State Change: ChangeInstanceDismount")
        return
    end

    LogInfo("[FATE] Transferring to next instance")
    local nextInstance = (GetZoneInstance() % 2) + 1
    yield("/li "..nextInstance) -- start instance transfer
    yield("/wait 5") -- wait for instance transfer to register 过短延迟会导致连续使用命令卡死
    State = CharacterState.ready
    SuccessiveInstanceChanges = SuccessiveInstanceChanges + 1
    LogInfo("[FATE] State Change: Ready")
end

function WaitForContinuation()
    if IsInFate() then
        LogInfo("WaitForContinuation IsInFate")
        local nextFateId = GetNearestFate()
        if nextFateId ~= CurrentFate.fateId then
            CurrentFate = BuildFateTable(nextFateId)
            State = CharacterState.doFate
            LogInfo("[FATE] State Change: DoFate")
        end
    elseif os.clock() - LastFateEndTime > 30 then
        LogInfo("WaitForContinuation Abort")
        LogInfo("Over 30s since end of last fate. Giving up on part 2.")
        TurnOffCombatMods()
        State = CharacterState.ready
        LogInfo("State Change: Ready")
    else
        LogInfo("WaitForContinuation Else")
        if BossFatesClass ~= nil then
            local currentClass = GetClassJobId()
            LogInfo("WaitForContinuation "..CurrentFate.fateName)
            if not IsPlayerOccupied() then
                if CurrentFate.continuationIsBoss and currentClass ~= BossFatesClass.classId then
                    LogInfo("WaitForContinuation SwitchToBoss")
                    yield("/gs change "..BossFatesClass.className)
                elseif not CurrentFate.continuationIsBoss and currentClass ~= MainClass.classId then
                    LogInfo("WaitForContinuation SwitchToMain")
                    yield("/gs change "..MainClass.className)
                end
            end
        end

        yield("/wait 1")
    end
end

function FlyBackToAetheryte()
    NextFate = SelectNextFate()
    if NextFate ~= nil then
        yield("/vnav stop")
        State = CharacterState.ready
        LogInfo("[FATE] State Change: Ready")
        return
    end

    local x = GetPlayerRawXPos()
    local y = GetPlayerRawYPos()
    local z = GetPlayerRawZPos()
    local closestAetheryte = GetClosestAetheryte(x, y, z, 0)
    -- if you get any sort of error while flying back, then just abort and tp back
    if IsAddonVisible("_TextError") and GetNodeText("_TextError", 1) == "抵达高度上限，无法继续提升高度。" then
        yield("/vnav stop")
        TeleportTo(closestAetheryte.aetheryteName)
        return
    end

    yield("/target 以太之光")

    if HasTarget() and GetTargetName() == "以太之光" and DistanceBetween(GetTargetRawXPos(), y, GetTargetRawZPos(), x, y, z) <= 20 then
        if PathfindInProgress() or PathIsRunning() then
            yield("/vnav stop")
        end

        if GetCharacterCondition(CharacterCondition.flying) then
            yield("/ac 跳下") -- land but don't actually dismount, to avoid running chocobo timer
        elseif GetCharacterCondition(CharacterCondition.mounted) then
            State = CharacterState.ready
            LogInfo("[FATE] State Change: Ready")
        else
            if MountToUse == "随机坐骑" then
                yield('/gaction "随机坐骑"')
            else
                yield('/mount "' .. MountToUse)
            end
        end
        return
    end

    if not GetCharacterCondition(CharacterCondition.mounted) then
        State = CharacterState.mounting
        LogInfo("[FATE] State Change: Mounting")
        return
    end
    
    if not (PathfindInProgress() or PathIsRunning()) then
        LogInfo("[FATE] ClosestAetheryte.y: "..closestAetheryte.y)
        if closestAetheryte ~= nil then
            SetMapFlag(SelectedZone.zoneId, closestAetheryte.x, closestAetheryte.y, closestAetheryte.z)
            if (not GetCharacterCondition(CharacterCondition.flying) and SelectedZone.flying) then --补充跳跃动作，防止寻路失败（起始点位于地底或异常的碰撞位置导致超长时间生成或失败）
            yield('/gaction 跳跃')
            yield('/wait 1')
            end
            PathfindAndMoveTo(closestAetheryte.x, closestAetheryte.y + 15, closestAetheryte.z, GetCharacterCondition(CharacterCondition.flying) and SelectedZone.flying) --追加高度修正 15y，防止寻路到水晶模型内部，好像有点高？
        end
    end
end

--脚本中只有3处引用，分别是无FATE飞回水晶、移动到FATE、切换分线。取消依旧工作正常。
function Mount()
    if GetCharacterCondition(CharacterCondition.mounted) then
        --yield("/wait 1") -- wait a second to make sure you're firmly on the mount  // movetofate 逻辑自带大约 0.2s + 脚本循环的 0.1s 延迟 取消依旧工作正常
        State = CharacterState.moveToFate
        LogInfo("[FATE] State Change: MoveToFate")
    else
        if MountToUse == "随机坐骑" then
            yield('/gaction "随机坐骑"')
        else
            yield('/mount "' .. MountToUse)
        end
    end
    --yield("/wait 1") --冷却(默认值1)，似乎是为了防止被重复触发，取消依旧工作正常
end

function Dismount()
    if GetCharacterCondition(CharacterCondition.flying) then
        yield('/ac 跳下')

        local now = os.clock()
        if now - LastStuckCheckTime > 1 then
            local x = GetPlayerRawXPos()
            local y = GetPlayerRawYPos()
            local z = GetPlayerRawZPos()

            if GetCharacterCondition(CharacterCondition.flying) and GetDistanceToPoint(LastStuckCheckPosition.x, LastStuckCheckPosition.y, LastStuckCheckPosition.z) < 2 then
                LogInfo("[FATE] Unable to dismount here. Moving to another spot.")
                local random_x, random_y, random_z = RandomAdjustCoordinates(x, y, z, 10)
                local nearestPointX = QueryMeshNearestPointX(random_x, random_y, random_z, 100, 100)
                local nearestPointY = QueryMeshNearestPointY(random_x, random_y, random_z, 100, 100)
                local nearestPointZ = QueryMeshNearestPointZ(random_x, random_y, random_z, 100, 100)
                if nearestPointX ~= nil and nearestPointY ~= nil and nearestPointZ ~= nil then
                    PathfindAndMoveTo(nearestPointX, nearestPointY, nearestPointZ, GetCharacterCondition(CharacterCondition.flying) and SelectedZone.flying)
                    yield("/wait 1")
                end
            end

            LastStuckCheckTime = now
            LastStuckCheckPosition = {x=x, y=y, z=z}
        end
    elseif GetCharacterCondition(CharacterCondition.mounted) then
        yield('/ac 跳下')
    end
end

function MiddleOfFateDismount()
    if not IsFateActive(CurrentFate.fateId) then
        State = CharacterState.ready
        LogInfo("[FATE] State Change: Ready")
        return
    end

    if HasTarget() then
        if DistanceBetween(GetPlayerRawXPos(), 0, GetPlayerRawZPos(), GetTargetRawXPos(), 0, GetTargetRawZPos()) > (MaxDistance + GetTargetHitboxRadius() + 5) then
            if not (PathfindInProgress() or PathIsRunning()) then
                LogInfo("[FATE] MiddleOfFateDismount PathfindAndMoveTo")
                PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos(), GetCharacterCondition(CharacterCondition.flying))
            end
        else
            if GetCharacterCondition(CharacterCondition.mounted) then
                LogInfo("[FATE] MiddleOfFateDismount Dismount()")
                Dismount()
            else
                yield("/vnav stop")
                State = CharacterState.doFate
                LogInfo("[FATE] State Change: DoFate")
            end
        end
    else
        if not IsInFate() then
            LogInfo("[FATE] FATE 区域内下坐骑任务意外在 FATE 范围外，尝试寻路接近 FATE")
            yield("/e [FATE] FATE 区域内下坐骑任务意外在 FATE 范围外，尝试寻路接近 FATE")
            PathfindAndMoveTo(CurrentFate.x, CurrentFate.y, CurrentFate.z, GetCharacterCondition(CharacterCondition.flying))
            yield("/wait 2.005")
        end
        TargetClosestFateEnemy()
    end
end

function NPCDismount()
    if GetCharacterCondition(CharacterCondition.mounted) then
        Dismount()
    else
        State = CharacterState.interactWithNpc
        LogInfo("[FATE] State Change: InteractWithFateNpc")
    end
end

function ChangeInstanceDismount()
    if GetCharacterCondition(CharacterCondition.mounted) then
        Dismount()
    else
        State = CharacterState.changingInstances
        LogInfo("[FATE] State Change: ChangingInstance")
    end
end

--Paths to the Fate NPC Starter
function MoveToNPC()
    yield("/target "..CurrentFate.npcName)
    if HasTarget() and GetTargetName()==CurrentFate.npcName then
        if GetDistanceToTarget() > 5 then
            PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos(), false)
        end
    end
end

--Paths to the Fate. CurrentFate is set here to allow MovetoFate to change its mind,
--so CurrentFate is possibly nil.
function MoveToFate()
    SuccessiveInstanceChanges = 0

    if not IsPlayerAvailable() then
        return
    end

    if CurrentFate~=nil and not IsFateActive(CurrentFate.fateId) then
        LogInfo("[FATE] Next Fate is dead, selecting new Fate.")
        yield("/vnav stop")
        State = CharacterState.ready
        LogInfo("[FATE] State Change: Ready")
        return
    end

    NextFate = SelectNextFate()
    if NextFate == nil then -- when moving to next fate, CurrentFate == NextFate
        yield("/vnav stop")
        State = CharacterState.ready
        LogInfo("[FATE] State Change: Ready")
        return
    elseif CurrentFate == nil or NextFate.fateId ~= CurrentFate.fateId then
        yield("/vnav stop")
        CurrentFate = NextFate
        SetMapFlag(SelectedZone.zoneId, CurrentFate.x, CurrentFate.y, CurrentFate.z)
        return
    end

    -- change to secondary class if it's a boss fate
    if BossFatesClass ~= nil then
        local currentClass = GetClassJobId()
        if CurrentFate.isBossFate and currentClass ~= BossFatesClass.classId then
            yield("/gs change "..BossFatesClass.className)
            return
        elseif not CurrentFate.isBossFate and currentClass ~= MainClass.classId then
            yield("/gs change "..MainClass.className)
            return
        end
    end

    -- upon approaching fate, pick a target and switch to pathing towards target
    -- FATE 半径大概 40 y，按照原来的 60 y，如果角色在距离 FATE 60y 之内，并且距离 NPC > 50y，会卡死，因为降落依据于选中的目标，大于 50y 则永远选不中
    -- 直接规定距离 FATE 40y 内进行目标操作
    if GetDistanceToPoint(CurrentFate.x, CurrentFate.y, CurrentFate.z) < 40 then
        if HasTarget() then
            LogInfo("[FATE] Found FATE target, immediate rerouting.")
                PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos(), GetCharacterCondition(CharacterCondition.flying) and SelectedZone.flying) --这里异常的一点是：默认地面寻路(?)导致寻路失败。但一般使用时是飞行寻路，反正我改了暂时没发现问题。
            if (CurrentFate.isOtherNpcFate or CurrentFate.isCollectionsFate) then --目标为 NPC 类型 FATE时，执行降落逻辑。但是有个问题：降落到障碍地形（目标之间有阻碍，有高低差的杂乱地形）会导致角色完全无法脱离。举例：遗产之地左下降落到房屋废墟完全无法脱离，添加延迟确保寻路到怪物位置缓解问题影响，但是极端情况下仍会发生异常。
                --所以我想针对 NPC 类型 FATE，最好是保证在一个绝对能安全降落的位置进行降落，这个位置有很多，比如：FATE 中心较近内再选目标降落，距离 NPC 一个很近的位置降落
                if GetDistanceToPoint(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos()) > 5 and not (PathIsRunning() or PathfindInProgress()) then --对于 NPC FATE 如果距离目标 >5 且不在寻路状态则重定向寻路到目标，只在距离 <5 时执行后续 NPC 交互处理。注意此处不管选中NPC还是敌人，都是期望与目标距离小于 5 时再执行后续步骤。
                    PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos(), GetCharacterCondition(CharacterCondition.flying) and SelectedZone.flying)
                elseif GetDistanceToPoint(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos()) < 5 then --距离目标 <5 时进入交互状态。
                    State = CharacterState.interactWithNpc
                    LogInfo("[FATE] State Change: Interact with npc")
                    -- if GetTargetName() == CurrentFate.npcName then
                    --     State = CharacterState.interactWithNpc
                    -- elseif GetTargetFateID() == CurrentFate.fateId then
                    --     State = CharacterState.middleOfFateDismount
                    --     LogInfo("[FATE] State Change: MiddleOfFateDismount")
                end
            else
                --根据距离判断下坐骑
                if GetDistanceToPoint(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos()) < 5 then --确保 3D 距离小于 5 再下坐骑，这里针对普通 FATE 降落，主要为了防止掉沟里
                    State = CharacterState.middleOfFateDismount
                    LogInfo("[FATE] State Change: MiddleOfFateDismount")
                end
            end
            return
        else
            if (CurrentFate.isOtherNpcFate or CurrentFate.isCollectionsFate) and not IsInFate() then --NPC 类型 FATE，不在 FATE 范围内，选择 NPC（应用于还未激活的 NPC FATE）
                yield("/target "..CurrentFate.npcName)
            elseif (CurrentFate.isOtherNpcFate or CurrentFate.isCollectionsFate) and IsInFate() then --NPC 类型 FATE，在 FATE 范围内，距离寻路终点小于 40，选择敌人 （应用于已经激活的 NPC FATE），但是对于连续型 FATE 且为 NPC FATE，这 25 会导致玩家原地不动，因此区分是否在坐骑上
                --if GetDistanceToPoint(CurrentFate.x, CurrentFate.y, CurrentFate.z) < 40 then -- 弃用，只要在 FATE 范围内就尝试选择目标
                    TargetClosestFateEnemy()
                --end
            elseif not (CurrentFate.isOtherNpcFate or CurrentFate.isCollectionsFate) then --非 NPC 类型 FATE，忽略是否在 FATE 范围内，选择敌人 （这是原先的 else 条件，应用于普通 FATE。实际上不限定在 FATE 内执行会导致一些 FATE 更容易降落在边缘）
                TargetClosestFateEnemy()
            end
            yield("/wait 0.5") -- give it a moment to make sure the target sticks
            return
        end
    end

    -- check for stuck
    if (PathIsRunning() or PathfindInProgress()) and GetCharacterCondition(CharacterCondition.mounted) then
        local now = os.clock()
        if now - LastStuckCheckTime > 10 then
            local x = GetPlayerRawXPos()
            local y = GetPlayerRawYPos()
            local z = GetPlayerRawZPos()

            if GetDistanceToPoint(LastStuckCheckPosition.x, LastStuckCheckPosition.y, LastStuckCheckPosition.z) < 3 then
                yield("/vnav stop")
                yield("/wait 1")
                LogInfo("[FATE] Antistuck")
                PathfindAndMoveTo(x, y + 10, z, GetCharacterCondition(CharacterCondition.flying) and SelectedZone.flying) -- fly up 10 then try again
            end
            
            LastStuckCheckTime = now
            LastStuckCheckPosition = {x=x, y=y, z=z}
        end
        return
    end

    if not MovingAnnouncementLock then
        LogInfo("[FATE] Moving to fate #"..CurrentFate.fateId.." "..CurrentFate.fateName)
        MovingAnnouncementLock = true
        if Echo == "All" then
            yield("/echo [FATE] 正在移动到 FATE #"..CurrentFate.fateId.." "..CurrentFate.fateName)
        end
    end

    if TeleportToClosestAetheryteToFate(CurrentFate) then
        return
    end

    if not GetCharacterCondition(CharacterCondition.mounted) then
        State = CharacterState.mounting
        LogInfo("[FATE] State Change: Mounting")
        return
    end

    local nearestLandX, nearestLandY, nearestLandZ = CurrentFate.x, CurrentFate.y, CurrentFate.z
    if not (CurrentFate.isCollectionsFate or CurrentFate.isOtherNpcFate) then
        nearestLandX, nearestLandY, nearestLandZ = RandomAdjustCoordinates(CurrentFate.x, CurrentFate.y, CurrentFate.z, 10)
    end

    --此为旧方法，如果发生了异常就回滚到这个逻辑
    --[[if (GetDistanceToPoint(nearestLandX, nearestLandY, nearestLandZ) > 5 and not GetCharacterCondition(CharacterCondition.flying))  then -- 补充缺失的动作，在寻路到 FATE 前跳跃进入飞行状态，如果没有这一步会导致寻路起点可能在地底一类的异常位置
        yield("/gaction 跳跃")
        yield("/wait 1")
        PathfindAndMoveTo(nearestLandX, nearestLandY, nearestLandZ, HasFlightUnlocked(SelectedZone.zoneId) and SelectedZone.flying)
    elseif (GetDistanceToPoint(nearestLandX, nearestLandY, nearestLandZ) > 5 and GetCharacterCondition(CharacterCondition.flying)) then
        PathfindAndMoveTo(nearestLandX, nearestLandY, nearestLandZ, HasFlightUnlocked(SelectedZone.zoneId) and SelectedZone.flying)
    else
        State = CharacterState.middleOfFateDismount
    end]]

    if GetDistanceToPoint(nearestLandX, nearestLandY, nearestLandZ) > 5 then --此新方法在 AtmoOmen 维护的 vnavmesh 插件工作正常，尚未发现地底寻路问题，但我需要更多样本去评估稳定性，同时也推荐国服玩家优先用这个版本
        if HasFlightUnlocked(SelectedZone.zoneId) and SelectedZone.flying then
            yield("/vnav flyflag")
        else
            yield("/vnav moveflag")
        end
        -- LogInfo("[FATE] Moving to: "..nearestLandX..", "..nearestLandY.." "..nearestLandZ..", "..tostring(HasFlightUnlocked(SelectedZone.zoneId) and SelectedZone.flying))
        -- PathfindAndMoveTo(nearestLandX, nearestLandY, nearestLandZ, HasFlightUnlocked(SelectedZone.zoneId) and SelectedZone.flying)
    else
        State = CharacterState.middleOfFateDismount
    end
end

function InteractWithFateNpc()
    if IsInFate() or GetFateStartTimeEpoch(CurrentFate.fateId) > 0 then
        yield("/vnav stop")
        State = CharacterState.doFate
        LogInfo("[FATE] State Change: DoFate")
        --yield("/wait 1") -- give the fate a second to register before dofate and lsync 非必要延迟，lsync在dofate逻辑内，在这里加延迟会更稳定吗？如果要加延迟希望在 0.5s 以下
    elseif not IsFateActive(CurrentFate.fateId) then
        State = CharacterState.ready
        LogInfo("[FATE] State Change: Ready")
    elseif PathfindInProgress() or PathIsRunning() then
        if HasTarget() and GetTargetName() == CurrentFate.npcName and GetDistanceToTarget() < (5*math.random()) then
            yield("/vnav stop")
        end
        return
    else
        -- if target is already selected earlier during pathing, avoids having to target and move again
        if (not HasTarget() or GetTargetName()~=CurrentFate.npcName) then
            yield("/target "..CurrentFate.npcName)
            return
        end

        if GetCharacterCondition(CharacterCondition.mounted) then
            State = CharacterState.npcDismount
            LogInfo("[FATE] State Change: NPCDismount")
            return
        end

        if GetDistanceToPoint(GetTargetRawXPos(), GetPlayerRawYPos(), GetTargetRawZPos()) > 5 then
            MoveToNPC()
            return
        end

        if IsAddonVisible("SelectYesno") then
            AcceptNPCFateOrRejectOtherYesno()
        elseif not GetCharacterCondition(CharacterCondition.occupied) then
            yield("/interact")
        end
    end
end

function CollectionsFateTurnIn()
    AcceptNPCFateOrRejectOtherYesno()

    if CurrentFate ~= nil and not IsFateActive(CurrentFate.fateId) then
        CurrentFate = nil
        State = CharacterState.ready
        LogInfo("[FATE] State Change: Ready")
        return
    end

    if (not HasTarget() or GetTargetName()~=CurrentFate.npcName) then
        TurnOffCombatMods()
        yield("/target "..CurrentFate.npcName)
        yield("/wait 1")

        -- if too far from npc to target, then head towards center of fate
        if (not HasTarget() or GetTargetName()~=CurrentFate.npcName and GetFateProgress(CurrentFate.fateId) < 100) then
            if not PathfindInProgress() and not PathIsRunning() then
                PathfindAndMoveTo(CurrentFate.x, CurrentFate.y, CurrentFate.z)
            end
        else
            yield("/vnav stop")
        end
        return
    end

    if GetDistanceToPoint(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos()) > 5 then
        if not (PathfindInProgress() or PathIsRunning()) then
            MoveToNPC()
        elseif (PathfindInProgress() or PathIsRunning()) then
            local now = os.clock()
            if now - LastStuckCheckTime > 10 then -- 10 秒内移动距离小于 3 则执行接下来逻辑，但这个逻辑好像不对，会在任务之外触发…… 虽然不影响整体运行
                local x = GetPlayerRawXPos()
                local y = GetPlayerRawYPos()
                local z = GetPlayerRawZPos()

                if GetDistanceToPoint(LastStuckCheckPosition.x, LastStuckCheckPosition.y, LastStuckCheckPosition.z) < 3 then
                    yield("/e [FATE] 提交物品寻路卡地形，尝试跳跃")
                    LogInfo("[FATE] Antistuck in collect fate")
                    yield("/gaction 跳跃") -- 尝试跳跃
                end
                LastStuckCheckTime = now
                LastStuckCheckPosition = {x=x, y=y, z=z}
                return
            end
        end
    else
        if GetItemCount(GetFateEventItem(CurrentFate.fateId)) >= 7 then -- 撤回，7 个物品是最低金牌要求，单人数值的收集任务需要提交大概 18 个左右完成 // 也许应该根据进度决定触发提交物品不会好一点？问题是如何确定角色在对应的收集类FATE已经交了多少个防止溢出，那得新写一个逻辑
            GotCollectionsFullCredit = true
        end

        yield("/vnav stop")
        yield("/interact")
        yield("/wait 2") --冷却（默认值3），不想发呆太久，2s 足够处理提交了

        if GetFateProgress(CurrentFate.fateId) < 100 then
            TurnOnCombatMods()
            State = CharacterState.doFate
            LogInfo("[FATE] State Change: DoFate")
        else
            if GotCollectionsFullCredit then
                State = CharacterState.unexpectedCombat
                LogInfo("[FATE] State Change: UnexpectedCombat")
            end
        end

        if CurrentFate ~=nil and CurrentFate.npcName ~=nil and GetTargetName() == CurrentFate.npcName then
            LogInfo("[FATE] Attempting to clear target.")
            ClearTarget()
            yield("/wait 1")
        end
    end
end

--#endregion

--#region Combat Functions

function GetClassJobTableFromId(jobId)
    if jobId == nil then
        LogInfo("[FATE] JobId is nil")
        return nil
    end
    for _, classJob in pairs(ClassList) do
        if classJob.classId == jobId then
            return classJob
        end
    end
    LogInfo("[FATE] Cannot recognize combat job.")
    return nil
end

function GetClassJobTableFromAbbrev(classString)
    if classString == "" then
        LogInfo("[FATE] No class set")
        return nil
    end
    for classJobAbbrev, classJob in pairs(ClassList) do
        if classJobAbbrev == string.lower(classString) then
            return classJob
        end
    end
    LogInfo("[FATE] Cannot recognize combat job.")
    return nil
end

function SummonChocobo()
    if GetCharacterCondition(CharacterCondition.mounted) then
        Dismount()
        return
    end

    if ShouldSummonChocobo and GetBuddyTimeRemaining() <= ResummonChocoboTimeLeft then
        if GetItemCount(4868) > 0 then
            yield("/item 基萨尔野菜")
            yield("/wait 3")
            yield('/cac "'..ChocoboStance..'"')
        elseif ShouldAutoBuyGysahlGreens then
            State = CharacterState.autoBuyGysahlGreens
            LogInfo("[FATE] State Change: AutoBuyGysahlGreens")
            return
        end
    end
    yield("/wait 1") --增加延迟，防止卡顿
    State = CharacterState.ready
    LogInfo("[FATE] State Change: Ready")
end

function AutoBuyGysahlGreens()
    if GetItemCount(4868) > 0 then -- don't need to buy
        if IsAddonVisible("Shop") then
            yield("/callback Shop true -1")
        elseif IsInZone(SelectedZone.zoneId) then
            yield("/item 基萨尔野菜")
        else
            yield("/wait 3") --增加延迟，防止卡死在当前地图
            State = CharacterState.ready
            LogInfo("State Change: ready")
        end
        return
    else
        if not IsInZone(129) then
            yield("/vnav stop")
            TeleportTo("利姆萨·罗敏萨下层甲板")
            return
        else
            local gysahlGreensVendor = { x=-62.1, y=18.0, z=9.4, npcName="班戈·赞戈" }
            if GetDistanceToPoint(gysahlGreensVendor.x, gysahlGreensVendor.y, gysahlGreensVendor.z) > 5 then
                if not (PathIsRunning() or PathfindInProgress()) then
                    PathfindAndMoveTo(gysahlGreensVendor.x, gysahlGreensVendor.y, gysahlGreensVendor.z)
                end
            elseif HasTarget() and GetTargetName() == gysahlGreensVendor.npcName then
                yield("/vnav stop")
                if IsAddonVisible("SelectYesno") then
                    yield("/wait 1") --添加延迟，防止UI出现过慢卡死
                    yield("/callback SelectYesno true 0")
                elseif IsAddonVisible("SelectIconString") then
                    yield("/wait 1") --添加延迟，防止UI出现过慢卡死
                    yield("/callback SelectIconString true 0")
                    return
                elseif IsAddonVisible("Shop") then
                    yield("/wait 1") --添加延迟，防止UI出现过慢卡死
                    yield("/callback Shop true 0 2 99")
                    return
                elseif not GetCharacterCondition(CharacterCondition.occupied) then
                    yield("/interact")
                    yield("/wait 1")
                    return
                end
            else
                yield("/vnav stop")
                yield("/target "..gysahlGreensVendor.npcName)
            end
        end
    end
end

--Paths to the enemy (for Meele)
function EnemyPathing()
    while HasTarget() and GetDistanceToTarget() > (GetTargetHitboxRadius() + MaxDistance) do
        local enemy_x = GetTargetRawXPos()
        local enemy_y = GetTargetRawYPos()
        local enemy_z = GetTargetRawZPos()
        if PathIsRunning() == false then
            PathfindAndMoveTo(enemy_x, enemy_y, enemy_z, GetCharacterCondition(CharacterCondition.flying) and SelectedZone.flying)
        end
        yield("/wait 0.1")
    end
end

function TurnOnAoes()
    if not AoesOn then
        if RotationPlugin == "RSR" then
            yield("/rotation off")
            yield("/rotation auto on")
            LogInfo("[FATE] TurnOnAoes /rotation auto on")

            if RSRAoeType == "Off" then
                yield("/rotation settings aoetype 0")
            elseif RSRAoeType == "Cleave" then
                yield("/rotation settings aoetype 1")
            elseif RSRAoeType == "Full" then
                yield("/rotation settings aoetype 2")
            end
        elseif RotationPlugin == "BMR" then
            yield("/bmrai setpresetname "..RotationAoePreset)
        elseif RotationPlugin == "VBM" then
            yield("/vbm ar toggle "..RotationAoePreset)
        end
        AoesOn = true
    end
end

function TurnOffAoes()
    if AoesOn then
        if RotationPlugin == "RSR" then
            yield("/rotation settings aoetype 1")
            yield("/rotation manual")
            LogInfo("[FATE] TurnOffAoes /rotation manual")
        elseif RotationPlugin == "BMR" then
            yield("/bmrai setpresetname "..RotationSingleTargetPreset)
        elseif RotationPlugin == "VBM" then
            yield("/vbm ar toggle "..RotationSingleTargetPreset)
        end
        AoesOn = false
    end
end

function TurnOffRaidBuffs()
    if AoesOn then
        if RotationPlugin == "BMR" then
            yield("/bmrai setpresetname "..RotationHoldBuffPreset)
        elseif RotationPlugin == "VBM" then
            yield("/vbm ar toggle "..RotationHoldBuffPreset)
        end
    end
end

function SetMaxDistance()
    MaxDistance = MeleeDist --default to melee distance
    --ranged and casters have a further max distance so not always running all way up to target
    local currentClass = GetClassJobTableFromId(GetClassJobId())
    if not currentClass.isMelee then
        MaxDistance = RangedDist
    end
end

function TurnOnCombatMods(rotationMode)
    if not CombatModsOn then
        CombatModsOn = true
        -- turn on RSR in case you have the RSR 30 second out of combat timer set
        if RotationPlugin == "RSR" then
            if rotationMode == "manual" then
                yield("/rotation manual")
                LogInfo("[FATE] TurnOnCombatMods /rotation manual")
            else
                yield("/rotation off")
                yield("/rotation auto on")
                LogInfo("[FATE] TurnOnCombatMods /rotation auto on")
            end
        elseif RotationPlugin == "BMR" then
            yield("/bmrai setpresetname "..RotationAoePreset)
        elseif RotationPlugin == "VBM" then
            yield("/vbm ar toggle "..RotationAoePreset)
        elseif RotationPlugin == "Wrath" then
            yield("/wrath auto on")
        elseif RotationPlugin == "AE" then
            yield("/aestop off")
            yield("/aepull on")
            LogInfo("[FATE] AE rotation is now active")
        end

        local class = GetClassJobTableFromId(GetClassJobId())
        
        if not AiDodgingOn then
            SetMaxDistance()
            
            if DodgingPlugin == "BMR" then
                yield("/bmrai on")
                yield("/bmrai followtarget on") -- overrides navmesh path and runs into walls sometimes
                yield("/bmrai followcombat on")
                yield("/bmrai followoutofcombat on") --如果不启用，会导致迷失少女过远时与其脱战导致停留在原地，需要评估启用后的稳定性
                yield("/bmrai maxdistancetarget " .. MaxDistance)
            elseif DodgingPlugin == "VBM" then
                yield("/vbmai on")
                yield("/vbmai followtarget on") -- overrides navmesh path and runs into walls sometimes
                yield("/vbmai followcombat on")
                yield("/bmrai followoutofcombat on")
                yield("/vbmai maxdistancetarget " .. MaxDistance)
                if RotationPlugin ~= "VBM" then
                    yield("/vbmai ForbidActions on") --This Disables VBM AI Auto-Target
                end
            end
            AiDodgingOn = true
        end
    end
end

function TurnOffCombatMods()
    if CombatModsOn then
        LogInfo("[FATE] Turning off combat mods")
        CombatModsOn = false

        if RotationPlugin == "RSR" then
            yield("/rotation off")
            LogInfo("[FATE] TurnOffCombatMods /rotation off")
        elseif RotationPlugin == "BMR" or RotationPlugin == "VBM" then
            yield("/bmrai setpresetname null")
        elseif RotationPlugin == "Wrath" then
            yield("/wrath auto off")
        elseif RotationPlugin == "AE" then
            yield("/aestop on")
            yield("/aepull off")
            LogInfo("[FATE] AE rotation is now inactive")
        end

        -- turn off BMR so you don't start following other mobs
        if AiDodgingOn then
            if DodgingPlugin == "BMR" then
                yield("/bmrai off")
                yield("/bmrai followtarget off")
                yield("/bmrai followcombat off")
                yield("/bmrai followoutofcombat off")
            elseif DodgingPlugin == "VBM" then
                yield("/vbm ar disable")
                yield("/vbmai off")
                yield("/vbmai followtarget off")
                yield("/vbmai followcombat off")
                yield("/vbmai followoutofcombat off")
                if RotationPlugin ~= "VBM" then
                    yield("/vbmai ForbidActions off") --This Enables VBM AI Auto-Target
                end
            end
            AiDodgingOn = false
        end
    end
end

function HandleUnexpectedCombat()
    TurnOnCombatMods("manual")

    if IsInFate() and GetFateProgress(GetNearestFate()) < 100 then
        CurrentFate = BuildFateTable(GetNearestFate())
        State = CharacterState.doFate
        LogInfo("[FATE] State Change: DoFate")
        return
    elseif not GetCharacterCondition(CharacterCondition.inCombat) then
        yield("/vnav stop")
        ClearTarget()
        TurnOffCombatMods()
        State = CharacterState.ready
        LogInfo("[FATE] State Change: Ready")
        local randomWait = (math.floor(math.random()*MaxWait * 1000)/1000) + MinWait -- truncated to 3 decimal places
        yield("/wait "..randomWait)
        return
    end

    if GetCharacterCondition(CharacterCondition.mounted) then
        if not (PathfindInProgress() or PathIsRunning()) then
            PathfindAndMoveTo(GetPlayerRawXPos(), GetPlayerRawYPos() + 10, GetPlayerRawZPos(), true)
        end
        yield("/wait 3") --减少在坐骑上时发生意外战斗的等待时间。一般在移动到FATE过程中拉到野怪触发
        return
    end

    -- targets whatever is trying to kill you
    if not HasTarget() then
        yield("/battletarget")
    end

    -- pathfind closer if enemies are too far
    if HasTarget() then
        if GetDistanceToTarget() > (MaxDistance + GetTargetHitboxRadius()) then
            if not (PathfindInProgress() or PathIsRunning()) then
                PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos(), GetCharacterCondition(CharacterCondition.flying) and SelectedZone.flying)
            end
        else
            if PathfindInProgress() or PathIsRunning() then
                yield("/vnav stop")
            elseif not GetCharacterCondition(CharacterCondition.inCombat) then
                --inch closer 3 seconds
                PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos(), GetCharacterCondition(CharacterCondition.flying) and SelectedZone.flying)
                yield("/wait 3")
            end
        end
    end
    yield("/wait 1")
end

function DoFate()
    if WaitingForFateRewards ~= CurrentFate.fateId then
        WaitingForFateRewards = CurrentFate.fateId
        LogInfo("[FATE] WaitingForFateRewards DoFate: "..tostring(WaitingForFateRewards))
    end
    local currentClass = GetClassJobId()
    -- switch classes (mostly for continutation fates that pop you directly into the next one)
    if CurrentFate.isBossFate and BossFatesClass ~= nil and currentClass ~= BossFatesClass.classId and not IsPlayerOccupied() then
        TurnOffCombatMods()
        yield("/gs change "..BossFatesClass.className)
        yield("/wait 1")
        return
    elseif not CurrentFate.isBossFate and BossFatesClass ~= nil and currentClass ~= MainClass.classId and not IsPlayerOccupied() then
        TurnOffCombatMods()
        yield("/gs change "..MainClass.className)
        yield("/wait 1")
        return
    elseif IsInFate() and (GetFateMaxLevel(CurrentFate.fateId) < GetLevel()) and not IsLevelSynced() then
        yield("/lsync")
        yield("/wait 0.5") -- give it a second to register
    elseif IsFateActive(CurrentFate.fateId) and not IsInFate() and GetFateProgress(CurrentFate.fateId) < 100 and
        (GetDistanceToPoint(CurrentFate.x, CurrentFate.y, CurrentFate.z) < GetFateRadius(CurrentFate.fateId) + 10) and
        not GetCharacterCondition(CharacterCondition.mounted) and not (PathIsRunning() or PathfindInProgress())
    then -- got pushed out of fate. go back
        yield("/vnav stop")
        yield("/wait 1")
        LogInfo("[FATE] pushed out of fate going back!")
        PathfindAndMoveTo(CurrentFate.x, CurrentFate.y, CurrentFate.z, GetCharacterCondition(CharacterCondition.flying) and SelectedZone.flying)
        return
    elseif not IsFateActive(CurrentFate.fateId) or GetFateProgress(CurrentFate.fateId) == 100 then
        yield("/vnav stop")
        ClearTarget()
        if not LogInfo("[FATE] HasContintuation check") and CurrentFate.hasContinuation then
            LastFateEndTime = os.clock()
            State = CharacterState.waitForContinuation
            LogInfo("[FATE] State Change: WaitForContinuation")
            return
        else
            DidFate = true
            LogInfo("[FATE] No continuation for "..CurrentFate.fateName)
            local randomWait = (math.floor(math.random() * (math.max(0, MaxWait - 3)) * 1000)/1000) + MinWait -- truncated to 3 decimal places
            yield("/wait "..randomWait)
            TurnOffCombatMods()
            State = CharacterState.ready
            LogInfo("[FATE] State Change: Ready")
        end
        return
    elseif GetCharacterCondition(CharacterCondition.mounted) then
        State = CharacterState.middleOfFateDismount
        LogInfo("[FATE] State Change: MiddleOfFateDismount")
        return
    elseif CurrentFate.isCollectionsFate then
        yield("/wait 1") -- needs a moment after start of fate for GetFateEventItem to populate
        if GetItemCount(GetFateEventItem(CurrentFate.fateId)) >= 7 or (GotCollectionsFullCredit and GetFateProgress(CurrentFate.fateId) == 100) then --撤回，7 个物品是最低金牌要求
            yield("/vnav stop")
            State = CharacterState.collectionsFateTurnIn
            LogInfo("[FATE] State Change: CollectionsFatesTurnIn")
        end
    end

    LogInfo("DoFate->Finished transition checks")

    -- do not target fate npc during combat
    if CurrentFate.npcName ~=nil and GetTargetName() == CurrentFate.npcName then
        LogInfo("[FATE] Attempting to clear target.")
        ClearTarget()
        yield("/wait 1")
    end

    TurnOnCombatMods("auto")

    GemAnnouncementLock = false

    -- switches to targeting forlorns for bonus (if present)
    if not IgnoreForlorns then --值得一提的是，如果把陆行鸟或者玩家名称改名为 迷失少女/迷失者，会选到它们，一般只有小警察(bot hunter)会这么干，您可以尝试使用 visibility 插件(主库)屏蔽它们
        yield("/target 迷失少女")
        if not IgnoreBigForlornOnly then
            yield("/target 迷失者")
        end
    end

    if (GetTargetName() == "迷失少女" or GetTargetName() == "迷失者") then
        if IgnoreForlorns or (IgnoreBigForlornOnly and GetTargetName() == "迷失者") then
            ClearTarget()
        elseif GetTargetHP() > 0 then
            if not ForlornMarked then
                yield("/marking attack1")
                if Echo == "All" then
                    yield("/echo 发现迷失少女/迷失者！<se.3>")
                end
                TurnOffAoes()
                ForlornMarked = true
            end
        else
            ClearTarget()
            TurnOnAoes()
        end
    else
        TurnOnAoes()
    end

    -- targets whatever is trying to kill you
    if not HasTarget() then
        yield("/battletarget")
    end

    -- clears target
    if GetTargetFateID() ~= CurrentFate.fateId and not IsTargetInCombat() then
        ClearTarget()
    end

    -- do not interrupt casts to path towards enemies
    if GetCharacterCondition(CharacterCondition.casting) then
        return
    end

    -- 大幅改动逻辑，我有点看不懂了……
    -- pathfind closer if enemies are too far
    if not GetCharacterCondition(CharacterCondition.inCombat) then --条件：脱战状态
        if HasTarget() then --条件：选中目标
            local x,y,z = GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos()
            if GetDistanceToTarget() <= (MaxDistance + GetTargetHitboxRadius()) then --条件：与目标距离 小于等于(<=) 最大攻击距离 + 目标碰撞体积。即目标处于攻击距离内，可以攻击目标的情况 
                if PathfindInProgress() or PathIsRunning() then --条件：正在寻路。任务：停止寻路，冷却 2.002 秒后执行后续代码
                    yield("/vnav stop")
                    yield("/wait 2.002") -- wait 5s before inching any closer // Maybe it won't take that long
                --elseif (GetDistanceToTarget() > (1 + GetTargetHitboxRadius())) and not GetCharacterCondition(CharacterCondition.casting) then -- never move into hitbox 条件：与目标距离 大于(>) 1 + 碰撞体积 并且 角色不在咏唱状态。任务：寻路到目标，冷却 1 秒后执行后续代码。画家频繁离开画魔纹的元凶，似乎是作为射程外/看不到目标的替代方案，但在实际运行中没什么必要性，反而会让读条职业乱跑发呆。
                elseif (GetDistanceToTarget() > (MaxDistance + GetTargetHitboxRadius())) and not GetCharacterCondition(CharacterCondition.casting) then --二次检查是否在射程距离内，是否不在咏唱状态，如果是则固定寻路 1 秒接近，几乎没有机会触发这个条件。
                    PathfindAndMoveTo(x, y, z)
                    yield("/wait 1") -- inch closer by 1s
                elseif IsAddonVisible("_TextError") and GetNodeText("_TextError", 1) == "看不到目标。" then --通常发生在被石头|棍母挡住的情况
                    LogInfo("[FATE] 看不到目标，尝试寻路修正(脱战)")
                    yield("/e [FATE] 看不到目标，尝试寻路修正(脱战)")
                    PathfindAndMoveTo(x, y, z)
                    yield("/wait 1.501")
                    return --退出函数
                end
            elseif not (PathfindInProgress() or PathIsRunning()) then --条件：非寻路状态
                yield("/wait 3.003") -- give 5s for enemy AoE casts to go off before attempting to move closer // change to 3.003s 冷却 3.003 秒
                if (x ~= 0 and z~=0 and not GetCharacterCondition(CharacterCondition.inCombat)) and not GetCharacterCondition(CharacterCondition.casting) then --条件：目标xz不为0，脱战状态。任务：寻路到目标。用于脱战状态下周期性的非读条状态接近，对于画家来说还行。
                    PathfindAndMoveTo(x, y, z)
                end
            elseif (PathfindInProgress() or PathIsRunning()) then --处理被地形障碍卡住的情况，简单来说专用于脱战时，选中目标但是寻路过程中被什么东西卡住了，尝试跳一下。如果在战斗中寻路到另一个较远的敌人时被什么玩意卡住了，并且无法进入射程内，不会触发这个任务进行脱困！
                local now = os.clock()
                if now - LastStuckCheckTime > 3 then -- 3 秒内移动距离小于 1 则执行接下来逻辑
                    local x1,y1,z1 = GetPlayerRawXPos(), GetPlayerRawYPos(), GetPlayerRawZPos()
                    if GetDistanceToPoint(LastStuckCheckPosition.x, LastStuckCheckPosition.y, LastStuckCheckPosition.z) < 1 then
                        yield("/e [FATE] FATE 进行中接近敌人寻路时卡地形，尝试跳跃并重新寻路")
                        LogInfo("[FATE] Antistuck in fate idle")
                        PathfindAndMoveTo(x, y, z)
                        yield("/gaction 跳跃") -- 尝试跳跃
                    end
                    LastStuckCheckTime = now
                    LastStuckCheckPosition = {x=x1, y=y1, z=z1}
                    return
                end
            end
        else --条件：未选择目标
            TargetClosestFateEnemy()
            yield("/wait 1") -- wait in case target doesn't stick
            if (not HasTarget()) and not GetCharacterCondition(CharacterCondition.casting) then
                PathfindAndMoveTo(CurrentFate.x, CurrentFate.y, CurrentFate.z) --寻路到当前 FATE 接近中心的位置
            end
        end
    else --条件：战斗状态
        if HasTarget() and IsAddonVisible("_TextError") and GetNodeText("_TextError", 1) == "看不到目标。" then --尝试处理战斗中看不到目标
            local x1,y1,z1 = GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos()
            LogInfo("[FATE] 看不到目标，尝试寻路修正(战斗中)")
            yield("/e [FATE] 看不到目标，尝试寻路修正(战斗中)")
            PathfindAndMoveTo(x1, y1, z1)
            yield("/wait 1.501")
            return --退出函数
        elseif HasTarget() and (GetDistanceToTarget() <= (MaxDistance + GetTargetHitboxRadius())) then --有目标，与目标距离在攻击范围内。
            if PathfindInProgress() or PathIsRunning() then --条件：寻路中。任务：中止寻路。
                yield("/vnav stop")
            end
        elseif not CurrentFate.isBossFate then --当前 FATE 为非 Boss FATE    如果迷失少女刷新在 Boss FATE 并且不在射程之内，可能会导致玩家什么都做不了，直到被Boss的AoE赶到攻击范围内，或者卡住直到结束。这个问题丢给 Bossmod 脱战时跟随进行处理，但是我需要评估脱战接近敌人的稳定性。
            if not (PathfindInProgress() or PathIsRunning()) then --不在寻路中，等待2秒，如果目标xz不为0(约等于有目标)且不在咏唱状态，寻路到目标。但这不够严谨！假设普通 FATE 在多个怪物战斗，读条职业处于瞬发技能期间，会寻路然后在下一轮dofate立刻停止移动从而发生不必要的移动。
                if (GetDistanceToTarget() > (MaxDistance + GetTargetHitboxRadius())) then --补充条件：与目标距离大于攻击范围，即射程外，固定寻路 2.004 秒后接近目标敌人
                    local x,y,z = GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos()
                    if (x ~= 0 and z~=0)  and not GetCharacterCondition(CharacterCondition.casting) then
                        PathfindAndMoveTo(x,y,z, GetCharacterCondition(CharacterCondition.flying) and SelectedZone.flying)
                    end
                    yield("/wait 2.004")
                end
            end
        end
    end

    --hold buff thingy
    if GetFateProgress(CurrentFate.fateId) >= PercentageToHoldBuff then
        TurnOffRaidBuffs()
    end
end

--#endregion

--#region State Transition Functions

function FoodCheck()
    --food usage
    if not HasStatusId(48) and Food ~= "" then
        yield("/item " .. Food)
    end
end

function PotionCheck()
    --pot usage
    if not HasStatusId(49) and Potion ~= "" then
        yield("/item " .. Potion)
    end
end

function Ready()
    FoodCheck()
    PotionCheck()

    CombatModsOn = false -- expect RSR to turn off after every fate
    GotCollectionsFullCredit = false
    ForlornMarked = false
    MovingAnnouncementLock = false

    local shouldWaitForBonusBuff = WaitIfBonusBuff and (HasStatusId(1288) or HasStatusId(1289))

    NextFate = SelectNextFate()
    if CurrentFate ~= nil and not IsFateActive(CurrentFate.fateId) then
        CurrentFate = nil
    end

    if CurrentFate == nil then
        LogInfo("[FATE] CurrentFate is nil")
    else
        LogInfo("[FATE] CurrentFate is "..CurrentFate.fateName)
    end

    if NextFate == nil then
        LogInfo("[FATE] NextFate is nil")
    else
        LogInfo("[FATE] NextFate is "..NextFate.fateName)
    end

    if not LogInfo("[FATE] Ready -> IsPlayerAvailable()") and not IsPlayerAvailable() then
        return
    elseif not LogInfo("[FATE] Ready -> Repair") and RepairAmount > 0 and NeedsRepair(RepairAmount) and
        (not shouldWaitForBonusBuff or (SelfRepair and GetItemCount(33916) > 12)) then --调整8级暗物质起购数量，要修的装备如果多余暗物质数量，会卡死，一次修理最大数量装备为12
        State = CharacterState.repair
        LogInfo("[FATE] State Change: Repair")
    elseif not LogInfo("[FATE] Ready -> ExtractMateria") and ShouldExtractMateria and CanExtractMateria(100) and GetInventoryFreeSlotCount() > 1 then
        State = CharacterState.extractMateria
        LogInfo("[FATE] State Change: ExtractMateria")
    elseif (not LogInfo("[FATE] Ready -> WaitBonusBuff") and NextFate == nil and shouldWaitForBonusBuff) and DownTimeWaitAtNearestAetheryte then
        if not HasTarget() or GetTargetName() ~= "以太之光" or GetDistanceToTarget() > 20 then
            State = CharacterState.flyBackToAetheryte
            LogInfo("[FATE] State Change: FlyBackToAetheryte")
        else
            yield("/wait 10")
        end
        return
    elseif not LogInfo("[FATE] Ready -> ExchangingVouchers") and WaitingForFateRewards == 0 and
        ShouldExchangeBicolorGemstones and (BicolorGemCount >= 1400) and not shouldWaitForBonusBuff
    then
        State = CharacterState.exchangingVouchers
        LogInfo("[FATE] State Change: ExchangingVouchers")
    elseif not LogInfo("[FATE] Ready -> ProcessRetainers") and WaitingForFateRewards == 0 and
        Retainers and ARRetainersWaitingToBeProcessed() and GetInventoryFreeSlotCount() > 1  and not shouldWaitForBonusBuff
    then
        State = CharacterState.processRetainers
        LogInfo("[FATE] State Change: ProcessingRetainers")
    elseif not LogInfo("[FATE] Ready -> GC TurnIn") and ShouldGrandCompanyTurnIn and
        GetInventoryFreeSlotCount() < InventorySlotsLeft and not shouldWaitForBonusBuff
    then
        State = CharacterState.gcTurnIn
        LogInfo("[FATE] State Change: GCTurnIn")
    elseif not LogInfo("[FATE] Ready -> TeleportBackToFarmingZone") and not IsInZone(SelectedZone.zoneId) then
        TeleportTo(SelectedZone.aetheryteList[1].aetheryteName)
        return
    elseif not LogInfo("[FATE] Ready -> SummonChocobo") and ShouldSummonChocobo and GetBuddyTimeRemaining() <= ResummonChocoboTimeLeft and
        (not shouldWaitForBonusBuff or GetItemCount(4868) > 0) then
        State = CharacterState.summonChocobo
    elseif not LogInfo("[FATE] Ready -> NextFate nil") and NextFate == nil then --?
        if EnableChangeInstance and GetZoneInstance() > 0 and not shouldWaitForBonusBuff then
            State = CharacterState.changingInstances
            LogInfo("[FATE] State Change: ChangingInstances")
            return
        elseif CompanionScriptMode and not shouldWaitForBonusBuff then --配套脚本切图逻辑
            if WaitingForFateRewards == 0 then
                StopScript = true
                LogInfo("[FATE] StopScript: Ready")
            else
                LogInfo("[FATE] Waiting for fate rewards(ChangingZone)")
            end
        elseif (not HasTarget() or GetTargetName() ~= "以太之光" or GetDistanceToTarget() > 20) and DownTimeWaitAtNearestAetheryte then
            State = CharacterState.flyBackToAetheryte
            LogInfo("[FATE] State Change: FlyBackToAetheryte")
        else
            yield("/wait 10")
        end
        return
    elseif CompanionScriptMode and DidFate and not shouldWaitForBonusBuff then
        if WaitingForFateRewards == 0 then
            StopScript = true
            LogInfo("[FATE] StopScript: DidFate")
        else
            LogInfo("[FATE] Waiting for fate rewards(Didfate)")

            --多地图伐木漏洞：FATE 完成后如果是收集型 FATE 达到 100%，再次进入 Ready 逻辑时，此分支将被占用，导致无法移动到下个 FATE，直到 FATE 结束。通常为收集类 FATE 100% 后准备离开时引战小怪导致。
            --（多地图伐木完成 FATE 时的专属处理）补充 FATE 进度为 100%，且下个 FATE 存在，那么执行寻路到下个 FATE，而不是原地干等。
            if (GetFateProgress(CurrentFate.fateId) == 100) and NextFate ~= nil then
                CurrentFate = NextFate
                SetMapFlag(SelectedZone.zoneId, CurrentFate.x, CurrentFate.y, CurrentFate.z)
                State = CharacterState.moveToFate
                LogInfo("[FATE] State Change: MovingtoFate(Multi Zone) "..CurrentFate.fateName)
            end
        end
    elseif not LogInfo("[FATE] Ready -> MovingToFate") then -- and ((CurrentFate == nil) or (GetFateProgress(CurrentFate.fateId) == 100) and NextFate ~= nil) then
        CurrentFate = NextFate
        SetMapFlag(SelectedZone.zoneId, CurrentFate.x, CurrentFate.y, CurrentFate.z)
        State = CharacterState.moveToFate
        LogInfo("[FATE] State Change: MovingtoFate "..CurrentFate.fateName)
    end

    if not GemAnnouncementLock and (Echo == "All" or Echo == "Gems") then
        GemAnnouncementLock = true
        if BicolorGemCount >= 1400 then
            yield("/echo [FATE] 您的双色宝石即将达到上限 "..tostring(BicolorGemCount).."/1500 ! <se.3>")
        else
            yield("/echo [FATE] 双色宝石: "..tostring(BicolorGemCount).."/1500")
        end
    end
end


function HandleDeath()
    CurrentFate = nil

    if CombatModsOn then
        TurnOffCombatMods()
    end

    if PathfindInProgress() or PathIsRunning() then
        yield("/vnav stop")
    end

    --[[if GetCharacterCondition(CharacterCondition.dead) then --Condition Dead
        if Echo and not DeathAnnouncementLock then
            DeathAnnouncementLock = true
            if Echo == "All" then
                yield("/echo [FATE] 您陷入了无法战斗的状态，返回到登记的以太之光。")
            end
        end

        if IsAddonVisible("SelectYesno") then --rez addon yes
            yield("/callback SelectYesno true 0")
            yield("/wait 0.1")
        end
    else
        yield("/wait 3") -- 添加延迟，避免执行过快卡死在当前地图
        State = CharacterState.ready
        LogInfo("[FATE] State Change: Ready")
        DeathAnnouncementLock = false
    end]]

    -- update 2.22.2
    if GetCharacterCondition(CharacterCondition.dead) then --Condition Dead
        if ReturnOnDeath then
            if Echo and not DeathAnnouncementLock then
                DeathAnnouncementLock = true
                if Echo == "All" then
                    yield("/echo [FATE] 您陷入了无法战斗的状态，返回到登记的以太之光。")
                end
            end

            if IsAddonVisible("SelectYesno") then --rez addon yes
                yield("/callback SelectYesno true 0")
                yield("/wait 0.1")
            end
        else
            if Echo and not DeathAnnouncementLock then
                DeathAnnouncementLock = true
                if Echo == "All" then
                    yield("/echo [FATE] 您陷入了无法战斗的状态，正在等待脚本重新检测到角色复活...")
                end
            end
            yield("/wait 1")
        end
    else
        yield("/wait 3") -- 添加延迟，避免执行过快卡死在当前地图
        State = CharacterState.ready
        LogInfo("[FATE] State Change: Ready")
        DeathAnnouncementLock = false
    end
end

function ExecuteBicolorExchange()
    CurrentFate = nil

    if BicolorGemCount >= 1400 then
        if IsAddonVisible("SelectYesno") then
            yield("/callback SelectYesno true 0")
            return
        end

        if IsAddonVisible("ShopExchangeCurrency") then
            yield("/callback ShopExchangeCurrency false 0 "..SelectedBicolorExchangeData.item.itemIndex.." "..(BicolorGemCount//SelectedBicolorExchangeData.item.price))
            return
        end

        if not IsInZone(SelectedBicolorExchangeData.zoneId) then
            TeleportTo(SelectedBicolorExchangeData.aetheryteName)
            return
        end
    
        local shopX = SelectedBicolorExchangeData.x
        local shopY = SelectedBicolorExchangeData.y
        local shopZ = SelectedBicolorExchangeData.z
    
        if SelectedBicolorExchangeData.miniAethernet ~= nil and
            GetDistanceToPoint(shopX, shopY, shopZ) > (DistanceBetween(SelectedBicolorExchangeData.miniAethernet.x, SelectedBicolorExchangeData.miniAethernet.y, SelectedBicolorExchangeData.miniAethernet.z, shopX, shopY, shopZ) + 10) then
            LogInfo("Distance to shopkeep is too far. Using mini aetheryte.")
            yield("/li "..SelectedBicolorExchangeData.miniAethernet.name)
            yield("/wait 5") -- give it a moment to register 过短延迟会导致连续使用命令卡死，这里完全是等待传送后 UI 恢复，如果你的计算机配置特别特别特别差或者发生了极端卡顿，依旧会卡死
            return
        elseif IsAddonVisible("TelepotTown") then
            LogInfo("TelepotTown open")
            yield("/callback TelepotTown false -1")
        elseif GetDistanceToPoint(shopX, shopY, shopZ) > 5 then
            LogInfo("Distance to shopkeep is too far. Walking there.")
            if not (PathfindInProgress() or PathIsRunning()) then
                LogInfo("Path not running")
                PathfindAndMoveTo(shopX, shopY, shopZ)
            end
        else
            LogInfo("[FATE] Arrived at Shopkeep")
            if PathfindInProgress() or PathIsRunning() then
                yield("/vnav stop")
            end
    
            if not HasTarget() or GetTargetName() ~= SelectedBicolorExchangeData.shopKeepName then
                yield("/target "..SelectedBicolorExchangeData.shopKeepName)
            elseif not GetCharacterCondition(CharacterCondition.occupiedInQuestEvent) then
                yield("/interact")
            end
        end
    else
        if IsAddonVisible("ShopExchangeCurrency") then
            LogInfo("[FATE] Attemping to close shop window")
            yield("/callback ShopExchangeCurrency true -1")
            return
        elseif GetCharacterCondition(CharacterCondition.occupiedInEvent) then
            LogInfo("[FATE] Character still occupied talking to shopkeeper")
            yield("/wait 0.5")
            return
        end

        yield("/wait 3") --添加延迟，避免执行过快卡死在当前地图
        State = CharacterState.ready
        LogInfo("[FATE] State Change: Ready")
        return
    end
end

function ProcessRetainers()
    CurrentFate = nil

    LogInfo("[FATE] Handling retainers...")
    if ARRetainersWaitingToBeProcessed() and GetInventoryFreeSlotCount() > 1 then
    
        if PathfindInProgress() or PathIsRunning() then
            return
        end

        if not IsInZone(129) then
            yield("/vnav stop")
            TeleportTo("利姆萨·罗敏萨下层甲板")
            return
        end

        local summoningBell = {
            x = -122.72,
            y = 18.00,
            z = 20.39
        }
        if GetDistanceToPoint(summoningBell.x, summoningBell.y, summoningBell.z) > 4.5 then
            PathfindAndMoveTo(summoningBell.x, summoningBell.y, summoningBell.z)
            return
        end

        if not HasTarget() or GetTargetName() ~= "传唤铃" then
            yield("/target 传唤铃")
            return
        end

        if not GetCharacterCondition(CharacterCondition.occupiedSummoningBell) then
            yield("/interact")
            if IsAddonVisible("RetainerList") then
                yield("/ays e")
                if Echo == "All" then
                    yield("/echo [FATE] 正在处理雇员")
                end
                yield("/wait 1")
            end
        end
    else
        if IsAddonVisible("RetainerList") then
            yield("/callback RetainerList true -1")
        elseif not GetCharacterCondition(CharacterCondition.occupiedSummoningBell) then
            yield("/wait 5") --添加延迟，否则脚本将极有可能返回原地图失败导致卡死在海都
            State = CharacterState.ready
            LogInfo("[FATE] State Change: Ready")
        end
    end
end

function GrandCompanyTurnIn()
    if GetInventoryFreeSlotCount() <= InventorySlotsLeft then
        local playerGC = GetPlayerGC()
        local gcZoneIds = {
            129, --利姆萨·罗敏萨下层甲板
            132, --格里达尼亚新街
            130 --乌尔达哈现世回廊
        }
        if not IsInZone(gcZoneIds[playerGC]) then
            yield("/li gc")
            yield("/wait 5") -- 过短延迟会导致连续使用命令卡死
        elseif DeliverooIsTurnInRunning() then
            return
        else
            yield("/deliveroo enable")
        end
    else
        yield("/wait 3") --添加延迟，避免执行过快卡死在当前地图
        State = CharacterState.ready
        LogInfo("State Change: Ready")
    end
end

function Repair()
    if IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")
        return
    end

    if IsAddonVisible("Repair") then
        if not NeedsRepair(RepairAmount) then
            yield("/callback Repair true -1") -- if you don't need repair anymore, close the menu
            yield("/wait 1") --添加延迟，防止关闭修理窗口后角色未就绪时立刻发起传送
        else
            yield("/callback Repair true 0") -- select repair 严重问题：如果有8级暗物质，但是数量少于要修的装备，会卡死。调整需要购买的阈值
        end
        return
    end

    -- if occupied by repair, then just wait
    if GetCharacterCondition(CharacterCondition.occupiedMateriaExtractionAndRepair) then
        LogInfo("[FATE] Repairing...")
        yield("/wait 1")
        return
    end

    local hawkersAlleyAethernetShard = { x=-213.95, y=15.99, z=49.35 }
    if SelfRepair then
        if GetItemCount(33916) > 12 then --持有8级暗物质数量大于 12 时，关闭 shop addon
            if IsAddonVisible("Shop") then
                yield("/callback Shop true -1")
                return
            end

            if not IsInZone(SelectedZone.zoneId) then
                TeleportTo(SelectedZone.aetheryteList[1].aetheryteName)
                return
            end

            if GetCharacterCondition(CharacterCondition.mounted) then
                Dismount()
                LogInfo("[FATE] State Change: Dismounting")
                return
            end

            if NeedsRepair(RepairAmount) then
                if not IsAddonVisible("Repair") then
                    LogInfo("[FATE] Opening repair menu...")
                    yield("/generalaction 修理")
                end
            else
                yield("/wait 3") --添加延迟，防止任务卡死
                State = CharacterState.ready
                LogInfo("[FATE] State Change: Ready")
            end
        elseif ShouldAutoBuyDarkMatter then
            if not IsInZone(129) then
                if Echo == "All" then
                    yield("/echo 暗物质已耗尽！前往利姆萨·罗敏萨进行购买。")
                end
                TeleportTo("利姆萨·罗敏萨下层甲板")
                return
            end

            local darkMatterVendor = { npcName="乌恩辛雷尔", x=-257.71, y=16.19, z=50.11, wait=0.08 }
            if GetDistanceToPoint(darkMatterVendor.x, darkMatterVendor.y, darkMatterVendor.z) > (DistanceBetween(hawkersAlleyAethernetShard.x, hawkersAlleyAethernetShard.y, hawkersAlleyAethernetShard.z,darkMatterVendor.x, darkMatterVendor.y, darkMatterVendor.z) + 10) then
                yield("/li 市场（国际广场）")
                yield("/wait 5") -- give it a moment to register // 连发2个lifestream命令会导致卡死，加长延迟
            elseif IsAddonVisible("TelepotTown") then
                yield("/callback TelepotTown false -1")
            elseif GetDistanceToPoint(darkMatterVendor.x, darkMatterVendor.y, darkMatterVendor.z) > 5 then
                if not (PathfindInProgress() or PathIsRunning()) then
                    PathfindAndMoveTo(darkMatterVendor.x, darkMatterVendor.y, darkMatterVendor.z)
                end
            else
                if not HasTarget() or GetTargetName() ~= darkMatterVendor.npcName then
                    yield("/vnav stop")
                    yield("/target "..darkMatterVendor.npcName)
                --elseif not GetCharacterCondition(CharacterCondition.occupiedInQuestEvent) then ???
                elseif IsAddonVisible("SelectYesno") then
                    yield("/callback SelectYesno true 0")
                    return
                elseif IsAddonVisible("Shop") then
                    yield("/wait 1") --添加延迟，防止 UI 未出现
                    yield("/callback Shop true 0 40 99")
                    return
                elseif HasTarget() and GetTargetName() == darkMatterVendor.npcName then --参考购买野菜的逻辑，调整顺序将交互置底，原先的逻辑会无限卡在交互判断
                    yield("/vnav stop")
                    yield("/interact")
                    yield("/wait 1") --添加延迟，防止 UI 未出现
                    return
                end
            end
        else
            if Echo == "All" then
                yield("/echo 暗物质已耗尽且自动购买功能已关闭，正在前往利姆萨·罗敏萨修理工。")
            end
            SelfRepair = false
        end
    else
        if NeedsRepair(RepairAmount) then
            if not IsInZone(129) then
                TeleportTo("利姆萨·罗敏萨下层甲板")
                return
            end
            
            local mender = { npcName="阿里斯特尔", x=-246.87, y=16.19, z=49.83 }
            if GetDistanceToPoint(mender.x, mender.y, mender.z) > (DistanceBetween(hawkersAlleyAethernetShard.x, hawkersAlleyAethernetShard.y, hawkersAlleyAethernetShard.z, mender.x, mender.y, mender.z) + 10) then
                yield("/li 市场（国际广场）")
                yield("/wait 5") -- give it a moment to register 同上
            elseif IsAddonVisible("TelepotTown") then
                yield("/callback TelepotTown false -1")
            elseif GetDistanceToPoint(mender.x, mender.y, mender.z) > 5 then
                if not (PathfindInProgress() or PathIsRunning()) then
                    PathfindAndMoveTo(mender.x, mender.y, mender.z)
                end
            else
                if not HasTarget() or GetTargetName() ~= mender.npcName then
                    yield("/target "..mender.npcName)
                elseif not GetCharacterCondition(CharacterCondition.occupiedInQuestEvent) then
                    yield("/interact")
                end
            end
        else
            yield("/wait 3") --添加延迟，避免执行过快卡死在海都
            State = CharacterState.ready
            LogInfo("[FATE] State Change: Ready")
        end
    end
end

function ExtractMateria()
    if GetCharacterCondition(CharacterCondition.mounted) then
        Dismount()
        LogInfo("[FATE] State Change: Dismounting")
        return
    end

    if GetCharacterCondition(CharacterCondition.occupiedMateriaExtractionAndRepair) then
        return
    end

    if CanExtractMateria(100) and GetInventoryFreeSlotCount() > 1 then
        if not IsAddonVisible("Materialize") then
            yield("/gaction 精制魔晶石")
            return
        end

        LogInfo("[FATE] Extracting materia...")
            
        if IsAddonVisible("MaterializeDialog") then
            yield("/callback MaterializeDialog true 0")
        else
            yield("/callback Materialize true 2 0")
        end
    else
        if IsAddonVisible("Materialize") then
            yield("/callback Materialize true -1")
        else
            yield("/wait 1") --添加延迟，避免执行过快卡死
            State = CharacterState.ready
            LogInfo("[FATE] State Change: Ready")
        end
    end
end

CharacterState = {
    ready = Ready,
    dead = HandleDeath,
    unexpectedCombat = HandleUnexpectedCombat,
    mounting = Mount,
    npcDismount = NPCDismount,
    middleOfFateDismount = MiddleOfFateDismount,
    moveToFate = MoveToFate,
    interactWithNpc = InteractWithFateNpc,
    collectionsFateTurnIn = CollectionsFateTurnIn,
    doFate = DoFate,
    waitForContinuation = WaitForContinuation,
    changingInstances = ChangeInstance,
    changeInstanceDismount = ChangeInstanceDismount,
    flyBackToAetheryte = FlyBackToAetheryte,
    extractMateria = ExtractMateria,
    repair = Repair,
    exchangingVouchers = ExecuteBicolorExchange,
    processRetainers = ProcessRetainers,
    gcTurnIn = GrandCompanyTurnIn,
    summonChocobo = SummonChocobo,
    autoBuyGysahlGreens = AutoBuyGysahlGreens
}

--#endregion State Transition Functions

--#region Main

LogInfo("[FATE] Starting fate farming script.")

StopScript = false
DidFate = false
GemAnnouncementLock = false
DeathAnnouncementLock = false
MovingAnnouncementLock = false
SuccessiveInstanceChanges = 0
LastInstanceChangeTimestamp = 0
LastTeleportTimeStamp = 0
TeleportToCATimeStamp = 0
GotCollectionsFullCredit = false -- needs 7 items for  full
-- variable to track collections fates that you have completed but are still active.
-- will not leave area or change instance if value ~= 0
WaitingForFateRewards = 0
LastFateEndTime = os.clock()
LastStuckCheckTime = os.clock()
LastStuckCheckPosition = {x=GetPlayerRawXPos(), y=GetPlayerRawYPos(), z=GetPlayerRawZPos()}
MainClass = GetClassJobTableFromId(GetClassJobId())
BossFatesClass = nil
if ClassForBossFates ~= "" then
    BossFatesClass = GetClassJobTableFromAbbrev(ClassForBossFates)
end
SetMaxDistance()

SelectedZone = SelectNextZone()
if SelectedZone.zoneName ~= "" and Echo == "All" then
    yield("/echo [FATE] 正在伐木 "..SelectedZone.zoneName)
end
LogInfo("[FATE] Farming Start for "..SelectedZone.zoneName)

for _, shop in ipairs(BicolorExchangeData) do
    for _, item in ipairs(shop.shopItems) do
        if item.itemName == ItemToPurchase then
            SelectedBicolorExchangeData = {
                shopKeepName = shop.shopKeepName,
                zoneId = shop.zoneId,
                aetheryteName = shop.aetheryteName,
                miniAethernet = shop.miniAethernet,
                x = shop.x, y = shop.y, z = shop.z,
                item = item
            }
        end
    end
end
if SelectedBicolorExchangeData == nil then
    yield("/echo [FATE] 无法识别双色宝石商店物品 "..ItemToPurchase.."！ 请确保该物品已录入 BicolorExchangeData 表！")
    StopScript = true
end

State = CharacterState.ready
CurrentFate = nil
if IsInFate() and GetFateProgress(GetNearestFate()) < 100 then
    CurrentFate = BuildFateTable(GetNearestFate())
end

if ShouldSummonChocobo and GetBuddyTimeRemaining() > 0 then
    yield('/cac "'..ChocoboStance..'"')
end

while not StopScript do
    if not NavIsReady() then
        yield("/echo [FATE] 正在等待 vnavmesh 构建完成...")
        LogInfo("[FATE] Waiting for vnavmesh to build...")
        repeat
            yield("/wait 1")
        until NavIsReady()
    end
    if State ~= CharacterState.dead and GetCharacterCondition(CharacterCondition.dead) then
        State = CharacterState.dead
        LogInfo("[FATE] State Change: Dead")
    elseif State ~= CharacterState.unexpectedCombat and State ~= CharacterState.doFate and
        State ~= CharacterState.waitForContinuation and State ~= CharacterState.collectionsFateTurnIn and
        (not IsInFate() or (IsInFate() and IsCollectionsFate(GetFateName(GetNearestFate())) and GetFateProgress(GetNearestFate()) == 100)) and
        GetCharacterCondition(CharacterCondition.inCombat)
    then
        State = CharacterState.unexpectedCombat
        LogInfo("[FATE] State Change: UnexpectedCombat")
    end
    
    BicolorGemCount = GetItemCount(26807)

    if not (IsPlayerCasting() or
        GetCharacterCondition(CharacterCondition.betweenAreas) or
        GetCharacterCondition(CharacterCondition.jumping48) or
        GetCharacterCondition(CharacterCondition.jumping61) or
        GetCharacterCondition(CharacterCondition.mounting57) or
        GetCharacterCondition(CharacterCondition.mounting64) or
        GetCharacterCondition(CharacterCondition.beingMoved) or
        GetCharacterCondition(CharacterCondition.occupiedMateriaExtractionAndRepair) or
        LifestreamIsBusy())
    then
        if WaitingForFateRewards ~= 0 and not IsFateActive(WaitingForFateRewards) then
            WaitingForFateRewards = 0
            LogInfo("[FATE] WaitingForFateRewards: "..tostring(WaitingForFateRewards))
        end
        State()
    end
    yield("/wait 0.1")
end
yield("/vnav stop")

if GetClassJobId() ~= MainClass.classId then
    yield("/gs change "..MainClass.className)
end
--#endregion Main