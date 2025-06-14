--[[

********************************************************************************
*                        Anima Luminous Crystal Farming                        *
*                                Version 1.0.1                                 *
********************************************************************************

流光水晶伐木脚本，需要搭配 Fate Farming.lua 使用。
此脚本会按顺序遍历地图列表，完成 FATE 获取流光水晶，
直至角色物品栏中集齐指定数量的流光水晶，
然后传送至下一地图并重新启动 FATE Farming 脚本。

（流光水晶 = 元灵武器 = 魂武 Patch 3.0）

作者: pot0to (https://ko-fi.com/pot0to)
        
    -> 1.0.1    CharacterCondition 表新增 mounted
                首个发行版本

--#region Settings

--[[
********************************************************************************
*                                   设置                                       *
********************************************************************************
]]

FateMacro = "Fate Farming"
NumberToFarm = 1                -- 设置刷取每种流光水晶的目标数量(一共13把武器)
MountToUse = "随机坐骑"       --在田园郡移动到龙堡内陆低地时想要使用的坐骑，填写"随机坐骑"则使用随机坐骑

--#endregion Settings

------------------------------------------------------------------------------------------------------------------------------------------------------

--[[
**************************************************************
*         代码部分: 除非你清楚自己在做什么，否则请勿修改         *
**************************************************************
]]
Atmas =
{
    {zoneName = "库尔札斯西部高地", zoneId = 397, itemName = "流光冰之水晶", itemId = 13569},
    {zoneName = "龙堡参天高地", zoneId = 398, itemName = "流光土之水晶", itemId = 13572},
    {zoneName = "龙堡内陆低地", zoneId = 399, itemName = "流光水之水晶", itemId = 13574},
    {zoneName = "翻云雾海", zoneId = 400, itemName = "流光雷之水晶", itemId = 13573},
    {zoneName = "阿巴拉提亚云海", zoneId = 401, itemName = "流光风之水晶", itemId = 13570},
    {zoneName = "魔大陆阿济兹拉", zoneId = 402, itemName = "流光火之水晶", itemId = 13571}
}

CharacterCondition = {
    mounted=4,
    casting=27,
    betweenAreas=45
}

function Mount()
    if MountToUse == "随机坐骑" then
        yield('/gaction "随机坐骑"')
    else
        yield('/mount "' .. MountToUse)
    end
end

function GetNextAtmaTable()
    for _, atmaTable in pairs(Atmas) do
        if GetItemCount(atmaTable.itemId) < NumberToFarm then
            return atmaTable
        end
    end
end

function TeleportTo(aetheryteName)
    yield("/tp "..aetheryteName)
    yield("/wait 1") -- wait for casting to begin
    while GetCharacterCondition(CharacterCondition.casting) do
        LogInfo("[AnimaFarming] Casting teleport...")
        yield("/wait 1")
    end
    yield("/wait 1") -- wait for that microsecond in between the cast finishing and the transition beginning
    while GetCharacterCondition(CharacterCondition.betweenAreas) do
        LogInfo("[AnimaFarming] Teleporting...")
        yield("/wait 1")
    end
    yield("/wait 1")
end

function GoToDravanianHinterlands()
    if GetCharacterCondition(CharacterCondition.betweenAreas) then
        return
    elseif IsInZone(478) then
        if not GetCharacterCondition(CharacterCondition.mounted) then
            --State = CharacterState.mounting
            Mount()
            LogInfo("[AnimaFarming] State Change: Mounting")
        elseif not PathIsRunning() and not PathfindInProgress() then
            PathfindAndMoveTo(148.51, 207.0, 118.47)
        end
    else
        TeleportTo("田园郡")
    end
end

yield("/at y")
NextAtmaTable = GetNextAtmaTable()
while NextAtmaTable ~= nil do
    if not IsPlayerOccupied() and not IsMacroRunningOrQueued(FateMacro) then
        if GetItemCount(NextAtmaTable.itemId) >= NumberToFarm then
            NextAtmaTable = GetNextAtmaTable()
        elseif not IsInZone(NextAtmaTable.zoneId) then
            if NextAtmaTable.zoneId == 399 then
                GoToDravanianHinterlands()
            else
                TeleportTo(GetAetheryteName(GetAetherytesInZone(NextAtmaTable.zoneId)[0]))
            end
        else
            yield("/snd run "..FateMacro)
        end
    end
    yield("/wait 1")
end