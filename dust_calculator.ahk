#SingleInstance Force

amuletsModDict := LoadModDictionary("./mods/parsed_Amulets.json")
beltsModDict := LoadModDictionary("./mods/parsed_Belts.json")
bodyArmoursModDict := LoadModDictionary("./mods/parsed_Body_Armours.json")
bootsModDict := LoadModDictionary("./mods/parsed_Boots.json")
bowsModDict := LoadModDictionary("./mods/parsed_Bows.json")
clawsModDict := LoadModDictionary("./mods/parsed_Claws.json")
daggersModDict := LoadModDictionary("./mods/parsed_Daggers.json")
glovesModDict := LoadModDictionary("./mods/parsed_Gloves.json")
helmetsModDict := LoadModDictionary("./mods/parsed_Helmets.json")
oneHandAxesModDict := LoadModDictionary("./mods/parsed_One_Hand_Axes.json")
oneHandMacesModDict := LoadModDictionary("./mods/parsed_One_Hand_Maces.json")
oneHandSwordsModDict := LoadModDictionary("./mods/parsed_One_Hand_Swords.json")
quiversModDict := LoadModDictionary("./mods/parsed_Quivers.json")
ringsModDict := LoadModDictionary("./mods/parsed_Rings.json")
runeDaggersModDict := LoadModDictionary("./mods/parsed_Rune_Daggers.json")
sceptresModDict := LoadModDictionary("./mods/parsed_Sceptres.json")
shieldsModDict := LoadModDictionary("./mods/parsed_Shields.json")
stavesModDict := LoadModDictionary("./mods/parsed_Staves.json")
thrustingOneHandSwordsModDict := LoadModDictionary("./mods/parsed_Thrusting_One_Hand_Swords.json")
twoHandAxesModDict := LoadModDictionary("./mods/parsed_Two_Hand_Axes.json")
twoHandMacesModDict := LoadModDictionary("./mods/parsed_Two_Hand_Maces.json")
twoHandSwordsModDict := LoadModDictionary("./mods/parsed_Two_Hand_Swords.json")
wandsModDict := LoadModDictionary("./mods/parsed_Wands.json")
warstavesModDict := LoadModDictionary("./mods/parsed_Warstaves.json")

findMissingMods := true

NumpadMult::Reload
#IfWinActive ahk_exe PathOfExile.exe
    *\::
        SendToChat("/hideout")
    Return

    *F4::
        SendToChat("/exit")

    Insert::
        CalculateDustValue() ; FIXME: Magic items say zero dust value
#IfWinActive
Return

SendToChat(text) {
    Send, {Enter}
    Send, ^a
    placeholder := Clipboard
    Clipboard := text
    Send, ^v
    Send, {Enter}
    Clipboard := placeholder
    Return
}

RandSleep(x, y) {
    global
    Random, rand, %x%, %y%
    Sleep, rand + extraDelay
    Return
}

CalculateDustValue() {
    global
    OldClipboard := Clipboard
    Clipboard := ""
    totalValue := 0

    Send, ^!c

    ClipWait, 1

    itemData := Clipboard 

    RegexMatch(itemData, "Item Class: (\w.*?)\R+", itemClassOut)
    itemClass := itemClassOut1
    RegExMatch(itemData, "Item Level: (\d+)", itemLevel)
    baseIlvl := itemLevel1
    valueMultiplier := CalcValueMultiplier(baseIlvl)

    ; Cleanup Item Data
    itemData := RegExReplace(itemData, "\R+\(.*\)\R+", "") ; Remove explanations e.g. `(Only Abyss Jewels can be Socketed in Abyssal Sockets)`
    itemData := RegExReplace(itemData, "\R+", "") ; Flatten for Regex
    itemData := RegExReplace(itemData, " \(crafted\)", "") ; Remove crafted explainer
    itemData := RegExReplace(itemData, "\d+\.\d+\(", "(") ; Remove mod values with Decimals
    itemData := RegExReplace(itemData, "\d+\(", "(") ; Remove mod values
    itemData := itemData " {" ; Add a `{` for regex hilarity
    
    modDictionary := GetModDictByItemClass(itemClass)

    ; Analyze modifiers
    pattern := "\{ .*? Modifier ""([^""]+)"".*?\}(.*?)(?:\{|-----)"
    pos := 2 ; jank fix for `{` at end of regex
    While (pos := RegExMatch(itemData, pattern, match, pos-1)) {
        ; modName := match1
        modDetails := RTrim(match2, " ")

        ; MsgBox,,, %modDetails%
        modLvl := modDictionary[modDetails]

        ; Debugging
        ; If modLvl is not found, MsgBox the modDetails
        if (findMissingMods && !modLvl) {
            MsgBox,,, ||%modDetails%||
            continue
        }

        modValue := Floor(5.403 * (1.05 ** modLvl) + 0.5)
        modifierValue := valueMultiplier * modValue

        totalValue += modifierValue

        ; log the value of each mod
        ; MsgBox,,, %modDetails%: %modifierValue% || %modLvl%
        
        pos += StrLen(match)
    }

    totalValue := Round(totalValue, 0)
    tooltipText := "Dust Value: " . totalValue

    MouseGetPos, mouseX, mouseY
    zxc := mouseY - 20
    ToolTip, %tooltipText%, %mouseX%, %zxc%

    SetTimer, RemoveToolTip, Off
    SetTimer, RemoveToolTip, 2000

    Clipboard := OldClipboard
    Return

}

CalcValueMultiplier(baseItemLevel) {
    valueMultiplier := 1
    if(baseItemLevel >= 68) {
        valueMultiplier := Min(20, baseItemLevel - 64) * 0.5
    } else {
        ; Item level 53 bases might be slightly wrong
        valueMultiplier := Max(6, Floor((baseItemLevel - 45) / 4) + 6)
    }

    return valueMultiplier
}

RemoveToolTip() {
    ToolTip
    Return
}

GetModDictByItemClass(itemClass) {
    global
    switch itemClass
    {
        case "Amulets":
            return amuletsModDict
        case "Belts":
            return beltsModDict
        case "Body Armours":
            return bodyArmoursModDict
        case "Boots":
            return bootsModDict
        case "Bows":
            return bowsModDict
        case "Claws":
            return clawsModDict
        case "Daggers":
            return daggersModDict
        case "Gloves":
            return glovesModDict
        case "Helmets":
            return helmetsModDict
        case "One Hand Axes":
            return oneHandAxesModDict
        case "One Hand Swords":
            return oneHandSwordsModDict
        case "One Hand Maces":
            return oneHandMacesModDict
        case "Quivers":
            return quiversModDict
        case "Rings":
            return ringsModDict
        case "Rune Daggers":
            return runeDaggersModDict
        case "Sceptres":
            return sceptresModDict
        case "Shields":
            return shieldsModDict
        case "Staves":
            return stavesModDict
        case "Thrusting One Hand Swords":
            return thrustingOneHandSwordsModDict
        case "Two Hand Axes":
            return twoHandAxesModDict
        case "Two Hand Swords":
            return twoHandMacesModDict
        case "Two Hand Maces":
            return twoHandSwordsModDict
        case "Wands":
            return wandsModDict
        case "Warstaves":
            return warstavesModDict
        default:
            return {}
    }
}

LoadModDictionary(filePath) {
    modDict := {}
    Loop, Read, %filePath%
    {
        if (A_LoopReadLine = "" || A_LoopReadLine = "{" || A_LoopReadLine = "}")
            continue
        line := Trim(A_LoopReadLine)
        line := RTrim(line, ",")
        colonPos := InStr(line, ":")
        if (colonPos) {
            key := Trim(SubStr(line, 1, colonPos - 1))
            value := Trim(SubStr(line, colonPos + 1))
            key := RTrim(LTrim(key, """"), """")
            value += 0
            
            modDict[key] := value
        }
    }

    return modDict
}
