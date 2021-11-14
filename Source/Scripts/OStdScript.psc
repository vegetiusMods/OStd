Scriptname OStdScript extends Quest  

OsexIntegrationMain property ostim auto
OStdMCM property mcm auto

Actor Property PlayerRef Auto
GlobalVariable Property GameDaysPassed  Auto

ovirginityscript ovirginity
ORomanceScript oromance

FormList OStdDiseaseList

string npcStdsListKey = "Ostds"
string npcStdLastCheckKey = "OStdInitialized"

Event OnInit()
    OnLoad()
    debug.Notification("OStd installed")
	log("OStd installed")
EndEvent

Function OnLoad()
    ovirginity = game.GetFormFromFile(0x000800, "OVirginity.esp") as ovirginityscript
    oromance = game.GetFormFromFile(0x000800, "ORomance.esp") as ORomanceScript
    OStdDiseaseList = game.GetFormFromFile(0x000D63, "OStd.esp") as FormList

    RegisterForModEvent("ostim_prestart", "OstimPrestart")
    RegisterForModEvent("ostim_end", "OstimEnd")

    log("OStd loaded")
EndFunction

Event OstimPrestart(string eventName, string strArg, float numArg, Form sender)
    
    Actor[] actors = ostim.GetActors()

    int actorsCount = actors.Length
    log("OStimEnd prestart " + actorsCount)
    int actorIndex = 0
    while actorIndex < actorsCount
        actor acta = actors[actorIndex]
        if acta != playerRef
            InitNpc(acta)
        endIf
        actorIndex += 1
    endWhile
EndEvent

Event OstimEnd(string eventName, string strArg, float numArg, Form sender)
	; Get actors
    log("OStimEnd event, actors count " + actorsCount)
    Actor[] actors = ostim.GetActors()
    
    int actorsCount = actors.Length

    log("OStimEnd event, actors count " + actorsCount)

    if actorsCount > 1
        int infectorIndex = 0
        while infectorIndex < actorsCount
            actor infector = actors[infectorIndex]

            if infector == playerRef
                ; scan for disease
                int stdsCount = OStdDiseaseList.GetSize()
                int stdIndex = 0

                while stdIndex < stdsCount
                    Spell std = OStdDiseaseList.GetAt(stdIndex) as Spell

                    if IsPlayerInfected(std)
                        log("Player has " + std.GetName())

                        int infectedCounter = 0
                        while infectedCounter < actorsCount
                            
                            actor infected = actors[infectedCounter]

                            if infected != playerRef
                                bool playerGaveStd = InfectNpc(infected, std, PlayerRef)

                                if playerGaveStd
                                    if oromance
                                        debug.Notification(infected.GetDisplayName() + " is mad you gave them " + std.GetName())
                                        oromance.increasedislikestat(infected, 10)
                                        oromance.increasehatestat(infected, 1)
                                        oromance.oui.FireSuccessIncidcator(1)
                                    endIf
                                endIf

                            endIf

                            infectedCounter += 1
                        endWhile
                    endIf

                    stdIndex += 1
                endWhile

            else
                int stdsCount = StorageUtil.FormListCount(infector, npcStdsListKey)
                int stdIndex = 0
                while stdIndex < stdsCount
                    Spell disease = StorageUtil.FormListGet(infector, npcStdsListKey, stdIndex) as Spell

                    int infectedCounter = 0
                    while infectedCounter < actorsCount
                        actor infected = actors[infectedCounter]

                        if infected != infector
                            if infected == playerRef && !IsPlayerInfected(disease)
                                int roll = ostim.RandomInt(0, 99)
                                if roll > mcm.transmissionChance
                                    debug.Notification(infector.GetDisplayName() + " gave you " + disease.GetName())
                                    playerRef.AddSpell(disease)
                                endIf
                            elseif infected != playerRef
                                if InfectNpc(infected, disease, infector) && ostim.IsPlayerInvolved()
                                    debug.Notification(infected.GetDisplayName() + " gave " + disease.GetName() + " to " + infected.GetDisplayName())
                                endIf
                            endIf
                        endIf

                        infectedCounter += 1
                    endWhile

                    stdIndex += 1
                endWhile

            endIf

            infectorIndex += 1
        endWhile
        
    endIf

EndEvent

bool function IsPlayerInfected(Spell disease)
    MagicEffect stdEffect = disease.GetNthEffectMagicEffect(0)

    return playerRef.HasMagicEffect(stdEffect)
endFunction

bool function InfectNpc(actor npc, Spell std, actor source)
    InitNpc(npc)

    if StorageUtil.FormListHas(npc, npcStdsListKey, std)
        log(npc.GetDisplayName() + " already has " + std.GetName())
        return false
    else
        int roll = ostim.RandomInt(0, 99)
        if roll > mcm.transmissionChance
            log(npc.GetDisplayName() + " rolled " + roll + " doesn't catch " + std.GetName() + " from " + source.GetDisplayName() + " (target: " + mcm.transmissionChance + ")")
            return false
        endIf

        log(npc.GetDisplayName() + " rolled " + roll + " and catch " + std.GetName() + " from " + source.GetDisplayName() + " (target: " + mcm.transmissionChance + ")")
    endIf

    npc.AddSpell(std)
    StorageUtil.FormListAdd(npc, npcStdsListKey, std, false)
    return true
endFunction

Function InitNpc(actor npc)
    bool update
    if !StorageUtil.HasIntValue(npc, npcStdLastCheckKey)
        log(npc.GetDisplayName() + " first time initialization")
        update = true
    elseif GameDaysPassed.GetValueInt() - StorageUtil.GetIntValue(npc, npcStdLastCheckKey) > 3
        log(npc.GetDisplayName() + " last check was more than 3 days ago, rerolling")
        update = true
    endIf

    StorageUtil.SetIntValue(npc, npcStdLastCheckKey, GameDaysPassed.GetValueInt())

    if !update
        return
    endIf

        int modifier = 0

        ; First check if NPC has healed
        int stdsCount = StorageUtil.FormListCount(npc, npcStdsListKey)

        int stdIndex = 0
        while stdIndex < stdsCount
            Spell disease = StorageUtil.FormListGet(npc, npcStdsListKey, stdIndex) as Spell

            int roll = ostim.RandomInt(0, 99)
            if roll < mcm.npcAutoHealChance
                log(npc.GetDisplayName() + " has " + disease.GetName() + " and rolled " + roll + ", they are cured (target: " +  mcm.npcAutoHealChance+ ")")

                npc.RemoveSpell(disease)
                StorageUtil.FormListRemove(npc, npcStdsListKey, disease, true)
            else
                log(npc.GetDisplayName() + " has " + disease.GetName() + " and rolled " + roll + ", they stay diseased (target was: " +  mcm.npcAutoHealChance+ ")")
            endIf

            stdIndex += 1
        endWhile

        ; modifiers
        if oromance   
            int sexDesireStat = oromance.getSexDesireStat(npc)
            int monog = oromance.getMonogamyDesireStat(npc) ;1- 100
            int prude = oromance.getPrudishnessStat(npc)
        
            if oromance.isvirgin(npc) 
                log(npc.GetDisplayName() + " is a virgin, no std")
                return
            elseif oromance.IsProstitute(npc)
                log(npc.GetDisplayName() + " is a prostitute, increasing std chances")
                modifier = -40
            elseif monog > 94 || prude > 80 || sexdesirestat < 16
                log(npc.GetDisplayName() + " is prude/faithful, decreasing std chances")
                modifier = 20
            elseif (sexdesirestat > 85)
                log(npc.GetDisplayName() + " lives for sex, increasing std chances")
                modifier = -20
            endif 
        elseif ovirginity && ovirginity.IsVirgin(npc)
            log(npc.GetDisplayName() + " is a virgin, no std")
        endIf
    
        ; target is sick
        int roll = ostim.RandomInt(0, 99) 
        if roll + modifier < mcm.baseStdChance
            Spell disease = OStdDiseaseList.GetAt(ostim.RandomInt(0, OStdDiseaseList.GetSize() - 1)) as Spell

            log(npc.GetDisplayName() + " rolled " + roll + " and catched " + disease.GetName() + " target was " + (mcm.baseStdChance - modifier))
            npc.AddSpell(disease)
            StorageUtil.FormListAdd(npc, npcStdsListKey, disease, false)
            return
        endIf

        log(npc.GetDisplayName() + " rolled " + roll + ", they has no disease (target was " + (mcm.baseStdChance - modifier) + ")")

EndFunction

function log(string in)
	MiscUtil.PrintConsole("OStd: " + In)
EndFunction