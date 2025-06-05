--[[

********************************************************************************
*                             Multi Zone Farming                               *
*                                Version 1.0.1                                 *
********************************************************************************

多地图 FATE Farming 脚本，设计用于配合 Fate Farming.lua 使用。
此脚本会按顺序遍历地图列表，在每个地图进行 FATE 伐木，直到地图中没有符合条件的FATE，
然后传送至下一区域并重新启动 FATE Farming 脚本。 

作者: pot0to (https://ko-fi.com/pot0to)
        
    -> 1.0.1    新增死亡检测和意外战斗检测
                首个发行版本

--#region Settings

--[[
********************************************************************************
*                                   设置                                       *
********************************************************************************
]]

FateMacro = "Fate Farming Companion"      -- Fate Farming 脚本在 Snd 插件中的自定义名称

-- 在 Fate Farming 脚本中按 Ctrl+F 查找 zoneId，或使用 Godbert 工具查询
ZonesToFarm =
{
    { zoneName = "奥阔帕恰山", zoneId = 1187 },
    { zoneName = "克扎玛乌卡湿地", zoneId = 1188 },
    { zoneName = "亚特克尔树海", zoneId = 1189 },
    { zoneName = "夏劳尼荒野", zoneId = 1190 },
    { zoneName = "遗产之地", zoneId = 1191 },
    { zoneName = "活着的记忆", zoneId = 1192 }
    --{ zoneName = "厄尔庇斯", zoneId = 961 }

}

--#endregion Settings

------------------------------------------------------------------------------------------------------------------------------------------------------

--[[
**************************************************************
*        代码部分: 除非你清楚自己在做什么，否则请勿修改          *
**************************************************************
]]

StopScript = false
CharacterCondition = {
    casting=27,
    betweenAreas=45
}

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

function TeleportTo(aetheryteName)
    yield("/tp "..aetheryteName)
    yield("/wait 1") -- wait for casting to begin

    if IsAddonVisible("_TextError") and GetNodeText("_TextError", 1) == "无法发动传送，其他传送正在进行。" then --使用 Daily Routines 插件处理卡顿，如果没安装则停用脚本
        EscapeTeleportStuckDR()
    end

    while GetCharacterCondition(CharacterCondition.casting) do
        yield("/wait 1")
    end
    yield("/wait 1") -- wait for that microsecond in between the cast finishing and the transition beginning
    while GetCharacterCondition(CharacterCondition.betweenAreas) do
        yield("/wait 1")
    end
    yield("/wait 1")
end

yield("/at y")
FarmingZoneIndex = 1
OldBicolorGemCount = GetItemCount(26807)
while StopScript == false do
    if not IsPlayerOccupied() and not IsMacroRunningOrQueued(FateMacro) then
        if GetCharacterCondition(2) or GetCharacterCondition(26) or GetZoneID() == ZonesToFarm[FarmingZoneIndex].zoneId then
            LogInfo("[MultiZone] Starting FateMacro")
            yield("/snd run "..FateMacro)
            repeat
                yield("/wait 1") --等待太久了，缩短时间
            until not IsMacroRunningOrQueued(FateMacro)
            LogInfo("[MultiZone] FateMacro has stopped")
            NewBicolorGemCount = GetItemCount(26807)
            if NewBicolorGemCount == OldBicolorGemCount then
                yield("/echo 双色宝石: "..NewBicolorGemCount)
                FarmingZoneIndex  = (FarmingZoneIndex % #ZonesToFarm) + 1
            else
                OldBicolorGemCount = NewBicolorGemCount
            end
        else
            LogInfo("[MultiZone] Teleporting to "..ZonesToFarm[FarmingZoneIndex].zoneName)
            TeleportTo(GetAetheryteName(GetAetherytesInZone(ZonesToFarm[FarmingZoneIndex].zoneId)[0]))
        end
    end
    yield("/wait 1")
end