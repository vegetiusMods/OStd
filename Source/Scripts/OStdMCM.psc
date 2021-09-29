Scriptname OStdMCM extends SKI_ConfigBase

int Property baseStdChance = 40 auto
int Property transmissionChance = 80 Auto
int Property npcAutoHealChance = 50  Auto

int idBaseStdChance
int idTransmissionChance
int idNpcAutoHealChance

Event OnPageReset(String Page)
	idBaseStdChance = AddSliderOption("Base NPCs STD chance", baseStdChance, "{0} %")
	AddEmptyOption()
    idNpcAutoHealChance = AddSliderOption("NPCs auto heal chance ", npcAutoHealChance, "{0} %")
	AddEmptyOption()
    idTransmissionChance = AddSliderOption("Transmission chance", transmissionChance, "{0} %")
EndEvent

Event OnOptionSliderOpen(int OptionID)
	If OptionID == idBaseStdChance
		SetSliderOptions(Value = baseStdChance, Default = 40, Min = 0, Max = 100, Interval = 1)
	EndIf
	If OptionID == idTransmissionChance
		SetSliderOptions(Value = transmissionChance, Default = 80, Min = 0, Max = 100, Interval = 1)
	EndIf
	If OptionID == idNpcAutoHealChance
		SetSliderOptions(Value = npcAutoHealChance, Default = 50, Min = 0, Max = 100, Interval = 1)
	EndIf
EndEvent

Event OnOptionHighlight(int option)
	If (Option == idBaseStdChance)
		SetInfoText("Base chance a NPC has a STD on initialization. May be modified by various factor (job, sexuality, etc...)")
	EndIf 
	If (Option == idNpcAutoHealChance)
		SetInfoText("Chances a NPC will naturally heal a STD over time. If this setting is lower than the Base NPCs STD chance and you are using ONight, you might create a STD ridden Skyrim.")
	EndIf 
	If (Option == idNpcAutoHealChance)
		SetInfoText("Chances a sick character will transmit a STD to an healthy one on intercourse.")
	EndIf 
EndEvent

Event OnOptionSliderAccept(int option, float value)
	If (option == idBaseStdChance)
		baseStdChance = value as int
		SetSliderOptionValue(idBaseStdChance, baseStdChance, a_formatString = "{0} %")
	EndIf
	If (option == idNpcAutoHealChance)
		npcAutoHealChance = value as int
		SetSliderOptionValue(idNpcAutoHealChance, npcAutoHealChance, a_formatString = "{0} %")
	EndIf
	If (option == idTransmissionChance)
		transmissionChance = value as int
		SetSliderOptionValue(idTransmissionChance, transmissionChance, a_formatString = "{0} %")
	EndIf
EndEvent

Function SetSliderOptions(Float Value, Float Default, Float Min, Float Max, Float Interval)
	SetSliderDialogStartValue(Value)
	SetSliderDialogDefaultValue(Default)
	SetSliderDialogRange(Min, Max)
	SetSliderDialogInterval(Interval)
EndFunction

