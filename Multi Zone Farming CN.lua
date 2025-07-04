--[[

********************************************************************************
*                             Multi Zone Farming                               *
*                                Version 1.0.1                                 *
********************************************************************************

多地图 FATE Farming 脚本，需要搭配 Fate Farming.lua 使用。
此脚本会按顺序遍历地图列表，在每个地图进行 FATE 伐木，直到地图中没有符合条件的FATE，
然后传送至下一地图并重新启动 FATE Farming 脚本。 

作者: pot0to (https://ko-fi.com/pot0to)
        
    -> 1.0.1    新增死亡检测和意外战斗检测
                首个发行版本

--#region Settings

--[[
********************************************************************************
*                                   设置                                       *
********************************************************************************
]]

FateMacro = "Fate Farming"      -- Fate Farming 脚本在 Snd 插件中的自定义名称

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

CharacterCondition = {
    casting=27,
    betweenAreas=45
}

function TeleportTo(aetheryteName)
    yield("/tp "..aetheryteName)
    yield("/wait 1") -- wait for casting to begin
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
while true do
    if not IsPlayerOccupied() and not IsMacroRunningOrQueued(FateMacro) then
        if GetCharacterCondition(2) or GetCharacterCondition(26) or GetZoneID() == ZonesToFarm[FarmingZoneIndex].zoneId then
            LogInfo("[MultiZone] Starting FateMacro")
            yield("/snd run "..FateMacro)
            repeat
                yield("/wait 1") --减少等待时间
            until not IsMacroRunningOrQueued(FateMacro)
            LogInfo("[MultiZone] FateMacro has stopped")
            NewBicolorGemCount = GetItemCount(26807)
            if NewBicolorGemCount == OldBicolorGemCount then
                yield("/echo Bicolor Count: "..NewBicolorGemCount)
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