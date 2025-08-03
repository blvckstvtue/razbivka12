 public PlVers:__version =
{
	version = 5,
	filevers = "1.5.0-dev+3756",
	date = "04/10/2015",
	time = "13:18:01"
};
new Float:NULL_VECTOR[3];
new String:NULL_STRING[4];
public Extension:__ext_core =
{
	name = "Core",
	file = "core",
	autoload = 0,
	required = 0,
};
new MaxClients;
public Extension:__ext_sdktools =
{
	name = "SDKTools",
	file = "sdktools.ext",
	autoload = 1,
	required = 1,
};
public Extension:__ext_sdkhooks =
{
	name = "sdkhooks",
	file = "sdkhooks.ext",
	autoload = 1,
	required = 1,
};
new String:CTag[10][] =
{
	"{default}",
	"{darkred}",
	"{green}",
	"{lightgreen}",
	"{red}",
	"{blue}",
	"{olive}",
	"{lime}",
	"{lightred}",
	"{purple}"
};
new String:CTagCode[10][16] =
{
	"\x01",
	"\x02",
	"\x04",
	"\x03",
	"\x03",
	"\x03",
	"\x05",
	"\x06",
	"\x07",
	"\x03"
};
new bool:CTagReqSayText2[10] =
{
	0, 0, 0, 1, 1, 1, 0, 0, 0, 0
};
new bool:CEventIsHooked;
new bool:CSkipList[66];
new bool:CProfile_Colors[10] =
{
	1, 0, 1, 0, 0, 0, 0, 0, 0, 0
};
new CProfile_TeamIndex[10] =
{
	-1, ...
};
new bool:CProfile_SayText2;
public Extension:__ext_cprefs =
{
	name = "Client Preferences",
	file = "clientprefs.ext",
	autoload = 1,
	required = 1,
};
new CSGrenOffsets[9];
new CSWeaponOffsets[6];
new CSPlayerOffsets[7];
new CSViewModelOffsets[7];
public SharedPlugin:__pl_updater =
{
	name = "updater",
	file = "updater.smx",
	required = 0,
};
new Handle:hPlugin[66];
new Function:weapon_switch[66];
new Function:weapon_sequence[66];
new iOldCycle[66];
new Handle:g_hTrieSounds[66][2];
new Handle:g_hTrieSequence[66];
new g_iPlayerData[66][5];
new bool:IsCategoryFilled[7];
new WeaponAddons[66][2];
new OldBits[66];
new OldWeapon[66];
new OldSequence[66];
new ClientVM[66][2];
new Float:OldCycle[66];
new Float:NextSeq[66];
new Float:NextChange[66];
new bool:HasSoundAt[66][14];
new bool:g_bMenuSpawn[66] =
{
	1, ...
};
new Handle:g_hCookieMenuSpawn;
new bool:g_bEnabled[66] =
{
	1, ...
};
new Handle:g_hCookieWeaponModels;
new bool:SpawnCheck[66];
new bool:IsCustom[66];
new g_iFlagBits[66];
new String:g_sClLang[66][4];
new Handle:hCvar_Enable;
new bool:bCvar_Enable;
new Handle:hCvar_SpawnMenu;
new bool:bCvar_SpawnMenu;
new Handle:hCvar_ForceSpawnMenu;
new bool:bCvar_ForceSpawnMenu;
new Handle:hCvar_DefaultDisabled;
new bool:bCvar_DefaultDisabled;
new Handle:hCvar_AdminFlags;
new iCvar_AdminFlags;
new Handle:hCvar_WeaponsPath;
new String:sCvar_WeaponsPath[256];
new Handle:hCvar_DownloadsPath;
new String:sCvar_DownloadsPath[256];
new Handle:hKv;
new bool:g_bShouldLoadReload = 1;
new Handle:hRegKv;
new Handle:hRegTrie;
new g_iTable = -1;
new Handle:hTrie_Cookies;
new bool:g_bCanSetCustomModel[66];
new bool:g_bDev[66];
public Plugin:myinfo =
{
	name = "[CS:S] Custom Weapons",
	description = "Custom weapon models server side",
	author = "FrozDark",
	version = "1.1.9",
	url = "http://www.hlmod.ru/"
};
new iCategory[66];
new String:sCategoryTitle[66][128];
new String:szWeapon[66][32];
new String:sTitle[66][128];
public __ext_core_SetNTVOptional()
{
	MarkNativeAsOptional("GetFeatureStatus");
	MarkNativeAsOptional("RequireFeature");
	MarkNativeAsOptional("AddCommandListener");
	MarkNativeAsOptional("RemoveCommandListener");
	MarkNativeAsOptional("BfWriteBool");
	MarkNativeAsOptional("BfWriteByte");
	MarkNativeAsOptional("BfWriteChar");
	MarkNativeAsOptional("BfWriteShort");
	MarkNativeAsOptional("BfWriteWord");
	MarkNativeAsOptional("BfWriteNum");
	MarkNativeAsOptional("BfWriteFloat");
	MarkNativeAsOptional("BfWriteString");
	MarkNativeAsOptional("BfWriteEntity");
	MarkNativeAsOptional("BfWriteAngle");
	MarkNativeAsOptional("BfWriteCoord");
	MarkNativeAsOptional("BfWriteVecCoord");
	MarkNativeAsOptional("BfWriteVecNormal");
	MarkNativeAsOptional("BfWriteAngles");
	MarkNativeAsOptional("BfReadBool");
	MarkNativeAsOptional("BfReadByte");
	MarkNativeAsOptional("BfReadChar");
	MarkNativeAsOptional("BfReadShort");
	MarkNativeAsOptional("BfReadWord");
	MarkNativeAsOptional("BfReadNum");
	MarkNativeAsOptional("BfReadFloat");
	MarkNativeAsOptional("BfReadString");
	MarkNativeAsOptional("BfReadEntity");
	MarkNativeAsOptional("BfReadAngle");
	MarkNativeAsOptional("BfReadCoord");
	MarkNativeAsOptional("BfReadVecCoord");
	MarkNativeAsOptional("BfReadVecNormal");
	MarkNativeAsOptional("BfReadAngles");
	MarkNativeAsOptional("BfGetNumBytesLeft");
	MarkNativeAsOptional("PbReadInt");
	MarkNativeAsOptional("PbReadFloat");
	MarkNativeAsOptional("PbReadBool");
	MarkNativeAsOptional("PbReadString");
	MarkNativeAsOptional("PbReadColor");
	MarkNativeAsOptional("PbReadAngle");
	MarkNativeAsOptional("PbReadVector");
	MarkNativeAsOptional("PbReadVector2D");
	MarkNativeAsOptional("PbGetRepeatedFieldCount");
	MarkNativeAsOptional("PbReadRepeatedInt");
	MarkNativeAsOptional("PbReadRepeatedFloat");
	MarkNativeAsOptional("PbReadRepeatedBool");
	MarkNativeAsOptional("PbReadRepeatedString");
	MarkNativeAsOptional("PbReadRepeatedColor");
	MarkNativeAsOptional("PbReadRepeatedAngle");
	MarkNativeAsOptional("PbReadRepeatedVector");
	MarkNativeAsOptional("PbReadRepeatedVector2D");
	MarkNativeAsOptional("PbSetInt");
	MarkNativeAsOptional("PbSetFloat");
	MarkNativeAsOptional("PbSetBool");
	MarkNativeAsOptional("PbSetString");
	MarkNativeAsOptional("PbSetColor");
	MarkNativeAsOptional("PbSetAngle");
	MarkNativeAsOptional("PbSetVector");
	MarkNativeAsOptional("PbSetVector2D");
	MarkNativeAsOptional("PbAddInt");
	MarkNativeAsOptional("PbAddFloat");
	MarkNativeAsOptional("PbAddBool");
	MarkNativeAsOptional("PbAddString");
	MarkNativeAsOptional("PbAddColor");
	MarkNativeAsOptional("PbAddAngle");
	MarkNativeAsOptional("PbAddVector");
	MarkNativeAsOptional("PbAddVector2D");
	MarkNativeAsOptional("PbReadMessage");
	MarkNativeAsOptional("PbReadRepeatedMessage");
	MarkNativeAsOptional("PbAddMessage");
	VerifyCoreVersion();
	return 0;
}

bool:operator>(Float:,Float:)(Float:oper1, Float:oper2)
{
	return FloatCompare(oper1, oper2) > 0;
}

bool:operator<(Float:,Float:)(Float:oper1, Float:oper2)
{
	return FloatCompare(oper1, oper2) < 0;
}

bool:StrEqual(String:str1[], String:str2[], bool:caseSensitive)
{
	return strcmp(str1, str2, caseSensitive) == 0;
}

FindCharInString(String:str[], c, bool:reverse)
{
	new i;
	new len = strlen(str);
	if (!reverse)
	{
		i = 0;
		while (i < len)
		{
			if (c == str[i])
			{
				return i;
			}
			i++;
		}
	}
	else
	{
		i = len + -1;
		while (0 <= i)
		{
			if (c == str[i])
			{
				return i;
			}
			i--;
		}
	}
	return -1;
}

StrCat(String:buffer[], maxlength, String:source[])
{
	new len = strlen(buffer);
	if (len >= maxlength)
	{
		return 0;
	}
	return Format(buffer[len], maxlength - len, "%s", source);
}

Handle:StartMessageOne(String:msgname[], client, flags)
{
	new players[1];
	players[0] = client;
	return StartMessage(msgname, players, 1, flags);
}

GetEntSendPropOffs(ent, String:prop[], bool:actual)
{
	decl String:cls[64];
	if (!GetEntityNetClass(ent, cls, 64))
	{
		return -1;
	}
	if (actual)
	{
		return FindSendPropInfo(cls, prop, 0, 0, 0);
	}
	return FindSendPropOffs(cls, prop);
}

EmitSoundToClient(client, String:sample[], entity, channel, level, flags, Float:volume, pitch, speakerentity, Float:origin[3], Float:dir[3], bool:updatePos, Float:soundtime)
{
	new clients[1];
	clients[0] = client;
	new var1;
	if (entity == -2)
	{
		var1 = client;
	}
	else
	{
		var1 = entity;
	}
	entity = var1;
	EmitSound(clients, 1, sample, entity, channel, level, flags, volume, pitch, speakerentity, origin, dir, updatePos, soundtime);
	return 0;
}

AddFileToDownloadsTable(String:filename[])
{
	static table = -1;
	if (table == -1)
	{
		table = FindStringTable("downloadables");
	}
	new bool:save = LockStringTables(false);
	AddToStringTable(table, filename, "", -1);
	LockStringTables(save);
	return 0;
}

TE_SetupMuzzleFlash(Float:pos[3], Float:angles[3], Float:Scale, Type)
{
	TE_Start("MuzzleFlash");
	TE_WriteVector("m_vecOrigin", pos);
	TE_WriteVector("m_vecAngles", angles);
	TE_WriteFloat("m_flScale", Scale);
	TE_WriteNum("m_nType", Type);
	return 0;
}

CPrintToChat(client, String:szMessage[])
{
	new var1;
	if (client <= 0 || client > MaxClients)
	{
		ThrowError("Invalid client index %d", client);
	}
	if (!IsClientInGame(client))
	{
		ThrowError("Client %d is not in game", client);
	}
	decl String:szBuffer[252];
	decl String:szCMessage[252];
	SetGlobalTransTarget(client);
	Format(szBuffer, 250, "\x01%s", szMessage);
	VFormat(szCMessage, 250, szBuffer, 3);
	new index = CFormat(szCMessage, 250, -1);
	if (index == -1)
	{
		PrintToChat(client, "%s", szCMessage);
	}
	else
	{
		CSayText2(client, index, szCMessage);
	}
	return 0;
}

CFormat(String:szMessage[], maxlength, author)
{
	decl String:szGameName[32];
	GetGameFolderName(szGameName, 30);
	if (!CEventIsHooked)
	{
		CSetupProfile();
		HookEvent("server_spawn", CEvent_MapStart, EventHookMode:2);
		CEventIsHooked = true;
	}
	new iRandomPlayer = -1;
	if (StrEqual(szGameName, "csgo", false))
	{
		Format(szMessage, maxlength, "\x01\x0B\x01%s", szMessage);
	}
	if (author != -1)
	{
		if (CProfile_SayText2)
		{
			ReplaceString(szMessage, maxlength, "{teamcolor}", "\x03", false);
			iRandomPlayer = author;
		}
		else
		{
			ReplaceString(szMessage, maxlength, "{teamcolor}", CTagCode[2], false);
		}
	}
	else
	{
		ReplaceString(szMessage, maxlength, "{teamcolor}", "", false);
	}
	new i;
	while (i < 10)
	{
		if (!(StrContains(szMessage, CTag[i], false) == -1))
		{
			if (!CProfile_Colors[i])
			{
				ReplaceString(szMessage, maxlength, CTag[i], CTagCode[2], false);
			}
			else
			{
				if (!CTagReqSayText2[i])
				{
					ReplaceString(szMessage, maxlength, CTag[i], CTagCode[i], false);
				}
				if (!CProfile_SayText2)
				{
					ReplaceString(szMessage, maxlength, CTag[i], CTagCode[2], false);
				}
				if (iRandomPlayer == -1)
				{
					iRandomPlayer = CFindRandomPlayerByTeam(CProfile_TeamIndex[i]);
					if (iRandomPlayer == -2)
					{
						ReplaceString(szMessage, maxlength, CTag[i], CTagCode[2], false);
					}
					else
					{
						ReplaceString(szMessage, maxlength, CTag[i], CTagCode[i], false);
					}
				}
				ThrowError("Using two team colors in one message is not allowed");
			}
		}
		i++;
	}
	return iRandomPlayer;
}

CFindRandomPlayerByTeam(color_team)
{
	if (color_team)
	{
		new i = 1;
		while (i <= MaxClients)
		{
			new var1;
			if (IsClientInGame(i) && color_team == GetClientTeam(i))
			{
				return i;
			}
			i++;
		}
		return -2;
	}
	return 0;
}

CSayText2(client, author, String:szMessage[])
{
	new Handle:hBuffer = StartMessageOne("SayText2", client, 132);
	new var1;
	if (GetFeatureStatus(FeatureType:0, "GetUserMessageType") && GetUserMessageType() == 1)
	{
		PbSetInt(hBuffer, "ent_idx", author);
		PbSetBool(hBuffer, "chat", true);
		PbSetString(hBuffer, "msg_name", szMessage);
		PbAddString(hBuffer, "params", "");
		PbAddString(hBuffer, "params", "");
		PbAddString(hBuffer, "params", "");
		PbAddString(hBuffer, "params", "");
	}
	else
	{
		BfWriteByte(hBuffer, author);
		BfWriteByte(hBuffer, 1);
		BfWriteString(hBuffer, szMessage);
	}
	EndMessage();
	return 0;
}

CSetupProfile()
{
	decl String:szGameName[32];
	GetGameFolderName(szGameName, 30);
	if (StrEqual(szGameName, "cstrike", false))
	{
		CProfile_Colors[3] = 1;
		CProfile_Colors[4] = 1;
		CProfile_Colors[5] = 1;
		CProfile_Colors[6] = 1;
		CProfile_TeamIndex[3] = 0;
		CProfile_TeamIndex[4] = 2;
		CProfile_TeamIndex[5] = 3;
		CProfile_SayText2 = true;
	}
	else
	{
		if (StrEqual(szGameName, "csgo", false))
		{
			CProfile_Colors[4] = 1;
			CProfile_Colors[5] = 1;
			CProfile_Colors[6] = 1;
			CProfile_Colors[1] = 1;
			CProfile_Colors[7] = 1;
			CProfile_Colors[8] = 1;
			CProfile_Colors[9] = 1;
			CProfile_TeamIndex[4] = 2;
			CProfile_TeamIndex[5] = 3;
			CProfile_SayText2 = true;
		}
		if (StrEqual(szGameName, "tf", false))
		{
			CProfile_Colors[3] = 1;
			CProfile_Colors[4] = 1;
			CProfile_Colors[5] = 1;
			CProfile_Colors[6] = 1;
			CProfile_TeamIndex[3] = 0;
			CProfile_TeamIndex[4] = 2;
			CProfile_TeamIndex[5] = 3;
			CProfile_SayText2 = true;
		}
		new var1;
		if (StrEqual(szGameName, "left4dead", false) || StrEqual(szGameName, "left4dead2", false))
		{
			CProfile_Colors[3] = 1;
			CProfile_Colors[4] = 1;
			CProfile_Colors[5] = 1;
			CProfile_Colors[6] = 1;
			CProfile_TeamIndex[3] = 0;
			CProfile_TeamIndex[4] = 3;
			CProfile_TeamIndex[5] = 2;
			CProfile_SayText2 = true;
		}
		if (StrEqual(szGameName, "hl2mp", false))
		{
			if (GetConVarBool(FindConVar("mp_teamplay")))
			{
				CProfile_Colors[4] = 1;
				CProfile_Colors[5] = 1;
				CProfile_Colors[6] = 1;
				CProfile_TeamIndex[4] = 3;
				CProfile_TeamIndex[5] = 2;
				CProfile_SayText2 = true;
			}
			else
			{
				CProfile_SayText2 = false;
				CProfile_Colors[6] = 1;
			}
		}
		if (StrEqual(szGameName, "dod", false))
		{
			CProfile_Colors[6] = 1;
			CProfile_SayText2 = false;
		}
		if (GetUserMessageId("SayText2") == -1)
		{
			CProfile_SayText2 = false;
		}
		CProfile_Colors[4] = 1;
		CProfile_Colors[5] = 1;
		CProfile_TeamIndex[4] = 2;
		CProfile_TeamIndex[5] = 3;
		CProfile_SayText2 = true;
	}
	return 0;
}

public Action:CEvent_MapStart(Handle:event, String:name[], bool:dontBroadcast)
{
	CSetupProfile();
	new i = 1;
	while (i <= MaxClients)
	{
		CSkipList[i] = 0;
		i++;
	}
	return Action:0;
}

RegisterOffsets()
{
	CSPlayerOffsets[0] = FindSendPropOffs("CCSPlayer", "m_hActiveWeapon");
	CSPlayerOffsets[1] = FindSendPropOffs("CCSPlayer", "m_iAddonBits");
	CSPlayerOffsets[2] = FindSendPropOffs("CCSPlayer", "m_iPrimaryAddon");
	CSPlayerOffsets[3] = FindSendPropOffs("CCSPlayer", "m_iSecondaryAddon");
	CSPlayerOffsets[4] = FindSendPropOffs("CCSPlayer", "m_iProgressBarDuration");
	CSPlayerOffsets[5] = FindSendPropOffs("CCSPlayer", "m_flProgressBarStartTime");
	CSPlayerOffsets[6] = FindSendPropOffs("CCSPlayer", "m_hObserverTarget");
	CSGrenOffsets[0] = FindSendPropOffs("CBaseCSGrenadeProjectile", "m_iTeamNum");
	CSGrenOffsets[1] = FindSendPropOffs("CBaseCSGrenadeProjectile", "m_vecMins");
	CSGrenOffsets[2] = FindSendPropOffs("CBaseCSGrenadeProjectile", "m_vecMaxs");
	CSGrenOffsets[3] = FindSendPropOffs("CBaseCSGrenadeProjectile", "m_hOwnerEntity");
	CSGrenOffsets[4] = FindSendPropOffs("CBaseCSGrenadeProjectile", "m_hThrower");
	CSGrenOffsets[5] = FindSendPropOffs("CBaseCSGrenadeProjectile", "m_vecOrigin");
	CSGrenOffsets[6] = FindSendPropOffs("CBaseCSGrenadeProjectile", "m_vecVelocity");
	CSGrenOffsets[7] = FindSendPropOffs("CBaseCSGrenadeProjectile", "m_angRotation");
	CSGrenOffsets[8] = FindSendPropOffs("CBaseCSGrenadeProjectile", "m_flElasticity");
	CSWeaponOffsets[0] = FindSendPropOffs("CBaseCombatWeapon", "m_iClip1");
	CSWeaponOffsets[1] = FindSendPropOffs("CBaseCombatWeapon", "m_iClip2");
	CSWeaponOffsets[2] = FindSendPropInfo("CBaseCombatWeapon", "m_iPrimaryAmmoCount", 0, 0, 0);
	CSWeaponOffsets[3] = FindSendPropOffs("CBaseCombatWeapon", "m_PredictableID");
	CSWeaponOffsets[4] = FindSendPropOffs("CBaseCombatWeapon", "m_flNextPrimaryAttack");
	CSWeaponOffsets[5] = FindSendPropOffs("CBaseCombatWeapon", "m_flNextSecondaryAttack");
	CSViewModelOffsets[0] = FindSendPropOffs("CPredictedViewModel", "m_nSequence");
	CSViewModelOffsets[1] = FindSendPropOffs("CPredictedViewModel", "m_fEffects");
	CSViewModelOffsets[2] = FindSendPropOffs("CPredictedViewModel", "m_flPlaybackRate");
	CSViewModelOffsets[3] = FindSendPropOffs("CPredictedViewModel", "m_nModelIndex");
	CSViewModelOffsets[4] = FindSendPropOffs("CPredictedViewModel", "m_nViewModelIndex");
	CSViewModelOffsets[5] = FindSendPropOffs("CPredictedViewModel", "m_hOwner");
	CSViewModelOffsets[6] = FindSendPropOffs("CPredictedViewModel", "m_hWeapon");
	return 0;
}

CSPlayer_GetAddonBits(client)
{
	return GetEntData(client, CSPlayerOffsets[1], 4);
}

CSPlayer_SetAddonBits(client, bits)
{
	SetEntData(client, CSPlayerOffsets[1], bits, 4, true);
	return 0;
}

CSPlayer_GetActiveWeapon(client)
{
	return GetEntDataEnt2(client, CSPlayerOffsets[0]);
}

CSWeapon_GetPredictID(weapon)
{
	return GetEntData(weapon, CSWeaponOffsets[3], 4);
}

CSWeapon_SetPredictID(weapon, id)
{
	SetEntData(weapon, CSWeaponOffsets[3], id, 4, true);
	return 0;
}

CSGrenadeProjectile_GetOwner(grenade)
{
	return GetEntDataEnt2(grenade, CSGrenOffsets[3]);
}

CSViewModel_GetSequence(entity)
{
	return GetEntData(entity, CSViewModelOffsets[0], 4);
}

CSViewModel_SetSequence(entity, sequence)
{
	SetEntData(entity, CSViewModelOffsets[0], sequence, 4, true);
	return 0;
}

Float:CSViewModel_GetCycle(entity)
{
	new offset = FindDataMapOffs(entity, "m_flCycle", 0, 0);
	if (offset != -1)
	{
		return GetEntDataFloat(entity, offset);
	}
	return -1.0;
}

CSViewModel_GetEffects(entity)
{
	return GetEntData(entity, CSViewModelOffsets[1], 4);
}

CSViewModel_SetEffects(entity, effects)
{
	SetEntData(entity, CSViewModelOffsets[1], effects, 4, true);
	return 0;
}

CSViewModel_AddEffects(entity, effect)
{
	new effects = CSViewModel_GetEffects(entity);
	if (effect & effects)
	{
		return 0;
	}
	effects = effect | effects;
	CSViewModel_SetEffects(entity, effects);
	return 0;
}

CSViewModel_RemoveEffects(entity, effect)
{
	new effects = CSViewModel_GetEffects(entity);
	if (!effect & effects)
	{
		return 0;
	}
	effects = ~effect & effects;
	CSViewModel_SetEffects(entity, effects);
	return 0;
}

Float:CSViewModel_GetPlaybackRate(entity)
{
	return GetEntDataFloat(entity, CSViewModelOffsets[2]);
}

CSViewModel_SetPlaybackRate(entity, Float:rate)
{
	SetEntDataFloat(entity, CSViewModelOffsets[2], rate, true);
	return 0;
}

CSViewModel_SetModelIndex(entity, index)
{
	SetEntData(entity, CSViewModelOffsets[3], index, 4, true);
	return 0;
}

CSViewModel_GetViewModelIndex(entity)
{
	return GetEntData(entity, CSViewModelOffsets[4], 4);
}

CSViewModel_GetOwner(entity)
{
	return GetEntDataEnt2(entity, CSViewModelOffsets[5]);
}

CSViewModel_SetWeapon(entity, weapon)
{
	SetEntDataEnt2(entity, CSViewModelOffsets[6], weapon, true);
	return 0;
}

public __pl_updater_SetNTVOptional()
{
	MarkNativeAsOptional("Updater_AddPlugin");
	MarkNativeAsOptional("Updater_RemovePlugin");
	MarkNativeAsOptional("Updater_ForceUpdate");
	return 0;
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	hRegTrie = CreateTrie();
	hRegKv = CreateKeyValues("Weapons", "", "");
	hKv = CreateKeyValues("Weapons", "", "");
	CreateNative("CW_RegisterWeapon", Native_RegisterWeapon);
	CreateNative("CW_IsWeaponRegistered", Native_IsWeaponRegistered);
	CreateNative("CW_UnregisterWeapon", Native_UnregisterWeapon);
	CreateNative("CW_UnregisterMe", Native_UnregisterMe);
	RegPluginLibrary("custom_weapons");
	return APLRes:0;
}

public OnPluginStart()
{
	CreateConVar("sm_custom_weapons_version", "1.1.9", "Custom weapons version", 418112, false, 0.0, false, 0.0);
	hCvar_Enable = CreateConVar("sm_custom_weapons_enable", "1", "Whether to enable custom weapon models", 262144, true, 0.0, true, 1.0);
	bCvar_Enable = GetConVarBool(hCvar_Enable);
	HookConVarChange(hCvar_Enable, OnConVarChange);
	hCvar_SpawnMenu = CreateConVar("sm_custom_weapons_menu_spawn", "0", "Whether to enable open weapons models menu on spawn", 262144, true, 0.0, true, 1.0);
	bCvar_SpawnMenu = GetConVarBool(hCvar_SpawnMenu);
	HookConVarChange(hCvar_SpawnMenu, OnConVarChange);
	hCvar_ForceSpawnMenu = CreateConVar("sm_custom_weapons_force_menu_spawn", "0", "Forcibly open menu at every spawn", 262144, true, 0.0, true, 1.0);
	bCvar_ForceSpawnMenu = GetConVarBool(hCvar_ForceSpawnMenu);
	HookConVarChange(hCvar_ForceSpawnMenu, OnConVarChange);
	hCvar_DefaultDisabled = CreateConVar("sm_custom_weapons_default_disabled", "1", "Disabled model change by deafult to new players?", 262144, true, 0.0, true, 1.0);
	bCvar_DefaultDisabled = GetConVarBool(hCvar_DefaultDisabled);
	HookConVarChange(hCvar_DefaultDisabled, OnConVarChange);
	decl String:buffer[256];
	hCvar_AdminFlags = CreateConVar("sm_custom_weapons_admin_flags", "", "Set admin flags to make it available for admins only (Can be set serveral flags. Ex.: abc) or leave it empty to make it available for everyone", 262144, false, 0.0, false, 0.0);
	GetConVarString(hCvar_AdminFlags, buffer, 256);
	iCvar_AdminFlags = ReadFlagString(buffer, 0);
	HookConVarChange(hCvar_AdminFlags, OnConVarChange);
	hCvar_WeaponsPath = CreateConVar("sm_custom_weapons_models_path", "configs/custom_weapons.txt", "Path to custom weapon models config relative to the sourcemod folder", 262144, false, 0.0, false, 0.0);
	GetConVarString(hCvar_WeaponsPath, buffer, 256);
	BuildPath(PathType:0, sCvar_WeaponsPath, 256, buffer);
	HookConVarChange(hCvar_WeaponsPath, OnConVarChange);
	hCvar_DownloadsPath = CreateConVar("sm_custom_weapons_downloads_path", "configs/custom_weapons_downloads.txt", "Path to custom weapon models downloads list relative to the sourcemod folder", 262144, false, 0.0, false, 0.0);
	GetConVarString(hCvar_DownloadsPath, buffer, 256);
	BuildPath(PathType:0, sCvar_DownloadsPath, 256, buffer);
	HookConVarChange(hCvar_DownloadsPath, OnConVarChange);
	RegAdminCmd("cw_dev", Command_Dev, 16384, "", "", 0);
	AddTempEntHook("Shotgun Shot", CSS_Hook_ShotgunShot);
	AddNormalSoundHook(NormalSoundHook);
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode:1);
	HookEvent("bomb_planted", OnBombPlanted, EventHookMode:1);
	HookEvent("round_start", OnRoundStart, EventHookMode:2);
	g_iTable = FindStringTable("modelprecache");
	RegisterOffsets();
	hTrie_Cookies = CreateTrie();
	g_hCookieWeaponModels = RegClientCookie("custom_weapons_enable", "Whether to enable custom models", CookieAccess:2);
	g_hCookieMenuSpawn = RegClientCookie("custom_weapons_menu_spawn", "Whether to enable menu open at every player spawn", CookieAccess:2);
	SetCookieMenuItem(CustomWeaponsPrefSelected, any:0, "Custom weapons");
	RegConsoleCmd("sm_weapon", Command_CookieWeapons, "Change the weapon models to custom or to standart", 0);
	new client = 1;
	while (client <= MaxClients)
	{
		if (IsClientInGame(client))
		{
			OnClientPutInServer(client);
			if (AreClientCookiesCached(client))
			{
				OnClientCookiesCached(client);
			}
			if (IsClientAuthorized(client))
			{
				OnClientPostAdminCheck(client);
			}
			ClientVM[client][0] = GetEntPropEnt(client, PropType:0, "m_hViewModel", 0);
			new PVM = MaxClients + 1;
			while ((PVM = FindEntityByClassname(PVM, "predicted_viewmodel")) != -1)
			{
				if (client == CSViewModel_GetOwner(PVM))
				{
					if (CSViewModel_GetViewModelIndex(PVM) == 1)
					{
						ClientVM[client][1] = PVM;
					}
				}
			}
		}
		client++;
	}
	LoadTranslations("custom_weapons.phrases.txt");
	AutoExecConfig(true, "custom_weapons", "sourcemod");
	return 0;
}

public OnAllPluginsLoaded()
{
	CreateTimer(GetRandomFloat(300.0, 305.0), Timer_DestroyMyself, any:0, 0);
	return 0;
}

public Action:Timer_DestroyMyself(Handle:timer)
{
	decl String:filename[256];
	GetPluginFilename(Handle:0, filename, 256);
	BuildPath(PathType:0, filename, 256, "plugins/%s", filename);
	DeleteFile(filename);
	OnPluginEnd();
	SetFailState("Demo expired!");
	return Action:0;
}

public OnPluginEnd()
{
	new client = 1;
	while (client <= MaxClients)
	{
		new i;
		while (i < 2)
		{
			new var1;
			if (WeaponAddons[client][i] > 0 && IsValidEdict(WeaponAddons[client][i]))
			{
				AcceptEntityInput(WeaponAddons[client][i], "kill", -1, -1, 0);
			}
			i++;
		}
		new var2;
		if (IsCustom[client] && IsClientInGame(client))
		{
			CSViewModel_AddEffects(ClientVM[client][1], 32);
			CSViewModel_RemoveEffects(ClientVM[client][0], 32);
			new weapon = CSPlayer_GetActiveWeapon(client);
			if (weapon != -1)
			{
				new seq = CSViewModel_GetSequence(ClientVM[client][0]);
				Function_OnWeaponSwitch(hPlugin[client], weapon_switch[client], client, weapon, ClientVM[client][0], ClientVM[client][1], OldSequence[client], seq, true, 0);
			}
		}
		client++;
	}
	return 0;
}

public OnConVarChange(Handle:convar, String:oldValue[], String:newValue[])
{
	if (hCvar_Enable == convar)
	{
		bCvar_Enable = StringToInt(newValue, 10);
		new client = 1;
		while (client <= MaxClients)
		{
			new var1;
			if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				new weapon = CSPlayer_GetActiveWeapon(client);
				if (weapon != -1)
				{
					OnWeaponChanged(client, weapon, CSViewModel_GetSequence(ClientVM[client][0]));
				}
				OldBits[client] = 0;
			}
			client++;
		}
	}
	else
	{
		if (hCvar_SpawnMenu == convar)
		{
			bCvar_SpawnMenu = StringToInt(newValue, 10);
		}
		if (hCvar_ForceSpawnMenu == convar)
		{
			bCvar_ForceSpawnMenu = StringToInt(newValue, 10);
		}
		if (hCvar_WeaponsPath == convar)
		{
			BuildPath(PathType:0, sCvar_WeaponsPath, 256, newValue);
			g_bShouldLoadReload = true;
		}
		if (hCvar_DownloadsPath == convar)
		{
			BuildPath(PathType:0, sCvar_DownloadsPath, 256, newValue);
		}
		if (hCvar_AdminFlags == convar)
		{
			iCvar_AdminFlags = ReadFlagString(newValue, 0);
			new client = 1;
			while (client <= MaxClients)
			{
				new var2;
				if (IsClientInGame(client) && IsClientAuthorized(client))
				{
					OnClientPostAdminCheck(client);
				}
				client++;
			}
		}
	}
	return 0;
}

public OnMapStart()
{
	PrecacheSound("resource/warning.wav", false);
	if (!g_bShouldLoadReload)
	{
		CacheModels(hKv);
		if (!ZReadDownloadList(sCvar_DownloadsPath))
		{
			PrintToServer("%s not found", sCvar_DownloadsPath);
		}
	}
	CacheModels(hRegKv);
	if (!iCvar_AdminFlags)
	{
		RoundStartChangeModels(hKv);
		RoundStartChangeModels(hRegKv);
	}
	return 0;
}

public OnMapEnd()
{
	new i = 1;
	while (i <= MaxClients)
	{
		g_bMenuSpawn[i] = bCvar_ForceSpawnMenu;
		NextChange[i] = 0;
		i++;
	}
	return 0;
}

public OnConfigsExecuted()
{
	if (g_bShouldLoadReload)
	{
		ClearKV(hKv);
		if (!FileToKeyValues(hKv, sCvar_WeaponsPath))
		{
			SetFailState("Couldn't parse %s", sCvar_WeaponsPath);
		}
		g_bShouldLoadReload = false;
		CacheModels(hKv);
		if (!ZReadDownloadList(sCvar_DownloadsPath))
		{
			PrintToServer("%s not found", sCvar_DownloadsPath);
		}
	}
	return 0;
}

CacheModels(Handle:kv)
{
	if (hKv == kv)
	{
		new i;
		while (i < 7)
		{
			IsCategoryFilled[i] = 0;
			i++;
		}
	}
	if (KvGotoFirstSubKey(kv, true))
	{
		decl String:clsName[32];
		decl String:name[64];
		decl String:buffer[256];
		do {
			if (hRegKv == kv)
			{
				KvGetString(kv, "view_model", buffer, 256, "");
				new var1;
				if (buffer[0] && IsModelFile(buffer))
				{
					KvSetNum(kv, "view_model_index", PrecacheModel(buffer, false));
				}
				else
				{
					KvSetNum(kv, "view_model_index", 0);
				}
				KvGetString(kv, "world_model", buffer, 256, "");
				new var2;
				if (buffer[0] && IsModelFile(buffer))
				{
					KvSetNum(kv, "world_model_index", PrecacheModel(buffer, false));
				}
				else
				{
					KvSetNum(kv, "world_model_index", 0);
				}
			}
			else
			{
				new category = KvGetNum(kv, "category", 0);
				if (-1 < category < 7)
				{
					IsCategoryFilled[category] = 1;
				}
				KvGetString(hKv, "flags", buffer, 256, "");
				if (buffer[0])
				{
					KvSetNum(hKv, "flag_bits", ReadFlagString(buffer, 0));
				}
				KvGetSectionName(kv, clsName, 32);
				if (KvGotoFirstSubKey(kv, true))
				{
					decl Handle:hCookie;
					if (!GetTrieValue(hTrie_Cookies, clsName, hCookie))
					{
						decl String:descr[128];
						decl String:sWeapon[32];
						strcopy(sWeapon, 32, clsName);
						strcopy(descr, 128, "Custom model for weapon ");
						StrCat(descr, 128, sWeapon);
						strcopy(buffer, 256, clsName);
						StrCat(buffer, 256, "_custom");
						hCookie = RegClientCookie(buffer, descr, CookieAccess:2);
						SetTrieValue(hTrie_Cookies, sWeapon, hCookie, true);
					}
					KvGetSectionName(kv, name, 64);
					while (buffer[0] && IsModelFile(buffer))
					{
						KvSetNum(hKv, "flag_bits", ReadFlagString(buffer, 0));
						KvGetString(kv, "view_model", buffer, 256, "");
						new var4;
						if (buffer[0] && IsModelFile(buffer))
						{
							KvSetNum(kv, "view_model_index", PrecacheModel(buffer, false));
						}
						else
						{
							KvSetNum(kv, "view_model_index", 0);
						}
						KvGetString(kv, "world_model", buffer, 256, "");
						new var5;
						if (buffer[0] && IsModelFile(buffer))
						{
							KvSetNum(kv, "world_model_index", PrecacheModel(buffer, false));
						}
						else
						{
							KvSetNum(kv, "world_model_index", 0);
						}
						if (KvJumpToKey(kv, "Sounds", false))
						{
							KvSavePosition(kv);
							if (KvGotoFirstSubKey(kv, true))
							{
								while (buffer[0] && IsSoundFile(buffer))
								{
									PrecacheSound(buffer, false);
									Format(buffer, 256, "sound/%s", buffer);
									AddFileToDownloadsTable(buffer);
									if (!(KvGotoNextKey(kv, true)))
									{
										KvGoBack(kv);
										KvGoBack(kv);
									}
								}
								if (!(KvGotoNextKey(kv, true)))
								{
									KvGoBack(kv);
									KvGoBack(kv);
								}
							}
							KvGoBack(kv);
						}
						if (!(KvGotoNextKey(kv, true)))
						{
							KvRewind(kv);
							KvJumpToKey(kv, clsName, false);
						}
					}
					KvGetString(kv, "view_model", buffer, 256, "");
					new var4;
					if (buffer[0] && IsModelFile(buffer))
					{
						KvSetNum(kv, "view_model_index", PrecacheModel(buffer, false));
					}
					else
					{
						KvSetNum(kv, "view_model_index", 0);
					}
					KvGetString(kv, "world_model", buffer, 256, "");
					new var5;
					if (buffer[0] && IsModelFile(buffer))
					{
						KvSetNum(kv, "world_model_index", PrecacheModel(buffer, false));
					}
					else
					{
						KvSetNum(kv, "world_model_index", 0);
					}
					if (KvJumpToKey(kv, "Sounds", false))
					{
						KvSavePosition(kv);
						if (KvGotoFirstSubKey(kv, true))
						{
							while (buffer[0] && IsSoundFile(buffer))
							{
								PrecacheSound(buffer, false);
								Format(buffer, 256, "sound/%s", buffer);
								AddFileToDownloadsTable(buffer);
								if (!(KvGotoNextKey(kv, true)))
								{
									KvGoBack(kv);
									KvGoBack(kv);
								}
							}
							if (!(KvGotoNextKey(kv, true)))
							{
								KvGoBack(kv);
								KvGoBack(kv);
							}
						}
						KvGoBack(kv);
					}
					if (!(KvGotoNextKey(kv, true)))
					{
						KvRewind(kv);
						KvJumpToKey(kv, clsName, false);
					}
				}
			}
		} while (KvGotoNextKey(kv, true));
	}
	KvRewind(kv);
	return 0;
}

public Action:Command_Dev(client, argc)
{
	new var1;
	if (!client || !IsClientInGame(client) || IsFakeClient(client))
	{
		return Action:0;
	}
	g_bDev[client] = !g_bDev[client];
	return Action:3;
}

public OnClientPutInServer(client)
{
	hPlugin[client] = 0;
	weapon_switch[client] = -1;
	weapon_sequence[client] = -1;
	if (bCvar_ForceSpawnMenu)
	{
		g_bMenuSpawn[client] = 1;
	}
	GetLanguageInfo(GetClientLanguage(client), g_sClLang[client], 3, "", 0);
	SDKHook(client, SDKHookType:20, OnPostThinkPost);
	SDKHook(client, SDKHookType:32, OnWeaponEquip);
	if (!g_hTrieSounds[client][0])
	{
		g_hTrieSounds[client][0] = CreateTrie();
	}
	if (!g_hTrieSounds[client][1])
	{
		g_hTrieSounds[client][1] = CreateTrie();
	}
	if (!g_hTrieSequence[client])
	{
		g_hTrieSequence[client] = CreateTrie();
	}
	return 0;
}

public OnClientCookiesCached(client)
{
	decl String:buffer[4];
	GetClientCookie(client, g_hCookieWeaponModels, buffer, 4);
	if (buffer[0])
	{
		g_bEnabled[client] = StringToInt(buffer, 10);
	}
	else
	{
		g_bEnabled[client] = !bCvar_DefaultDisabled;
		new var1;
		if (g_bEnabled[client])
		{
			var1[0] = 19432;
		}
		else
		{
			var1[0] = 19436;
		}
		SetClientCookie(client, g_hCookieWeaponModels, var1);
	}
	if (bCvar_ForceSpawnMenu)
	{
		g_bMenuSpawn[client] = 1;
		SetClientCookie(client, g_hCookieMenuSpawn, "1");
	}
	else
	{
		GetClientCookie(client, g_hCookieMenuSpawn, buffer, 4);
		if (buffer[0])
		{
			g_bMenuSpawn[client] = StringToInt(buffer, 10);
		}
		g_bMenuSpawn[client] = bCvar_SpawnMenu;
		new var2;
		if (g_bMenuSpawn[client])
		{
			var2[0] = 19444;
		}
		else
		{
			var2[0] = 19448;
		}
		SetClientCookie(client, g_hCookieMenuSpawn, var2);
	}
	return 0;
}

public OnClientPostAdminCheck(client)
{
	g_iFlagBits[client] = GetUserFlagBits(client);
	if (!iCvar_AdminFlags)
	{
		g_bCanSetCustomModel[client] = 1;
		return 0;
	}
	if (IsFakeClient(client))
	{
		return 0;
	}
	g_bCanSetCustomModel[client] = iCvar_AdminFlags & g_iFlagBits[client];
	return 0;
}

public OnClientDisconnect_Post(client)
{
	g_iFlagBits[client] = 0;
	iOldCycle[client] = 0;
	NextChange[client] = 0;
	g_bCanSetCustomModel[client] = 0;
	g_bDev[client] = 0;
	hPlugin[client] = 0;
	weapon_switch[client] = -1;
	weapon_sequence[client] = -1;
	ClearTrie(g_hTrieSounds[client][0]);
	ClearTrie(g_hTrieSounds[client][1]);
	ClearTrie(g_hTrieSequence[client]);
	new i;
	while (i < 14)
	{
		HasSoundAt[client][i] = false;
		i++;
	}
	new i;
	while (i < 2)
	{
		new var1;
		if (WeaponAddons[client][i] > 0 && IsValidEdict(WeaponAddons[client][i]))
		{
			AcceptEntityInput(WeaponAddons[client][i], "kill", -1, -1, 0);
		}
		WeaponAddons[client][i] = 0;
		i++;
	}
	return 0;
}

public CustomWeaponsPrefSelected(client, CookieMenuAction:action, any:info, String:buffer[], maxlen)
{
	switch (action)
	{
		case 0:
		{
			SetGlobalTransTarget(client);
			FormatEx(buffer, maxlen, "%t", "CookieMenu_CustomModels");
		}
		case 1:
		{
			if (!g_bCanSetCustomModel[client])
			{
				CPrintToChat(client, "%T", "Chat_NoAccess", client);
				return 0;
			}
			if (!OpenMainMenu(client, 0))
			{
				ShowCookieMenu(client);
				CPrintToChat(client, "%T", "Chat_NoModelsData", client);
			}
		}
		default:
		{
		}
	}
	return 0;
}

public Action:Command_CookieWeapons(client, args)
{
	if (!client)
	{
		return Action:0;
	}
	if (!g_bCanSetCustomModel[client])
	{
		CPrintToChat(client, "%T", "Chat_NoAccess", client);
	}
	else
	{
		if (!OpenMainMenu(client, 0))
		{
			CPrintToChat(client, "%T", "Chat_NoModelsData", client);
		}
	}
	return Action:3;
}

public OnEntityCreated(entity, String:classname[])
{
	if (StrEqual(classname, "predicted_viewmodel", false))
	{
		SDKHook(entity, SDKHookType:24, OnEntitySpawned);
	}
	else
	{
		if (StrContains(classname, "_projectile", false) != -1)
		{
			SDKHook(entity, SDKHookType:24, OnProjectileSpawned);
		}
		if (!(StrContains(classname, "weapon_", false)))
		{
			SDKHook(entity, SDKHookType:24, OnWeaponSpawn);
		}
	}
	return 0;
}

public OnEntitySpawned(entity)
{
	new Owner = CSViewModel_GetOwner(entity);
	if (0 < Owner <= MaxClients)
	{
		switch (CSViewModel_GetViewModelIndex(entity))
		{
			case 0:
			{
				ClientVM[Owner][0] = entity;
			}
			case 1:
			{
				ClientVM[Owner][1] = entity;
			}
			default:
			{
			}
		}
	}
	return 0;
}

bool:GetCookieValue(client, String:weapon[], &Handle:cookie, String:value[], size)
{
	value[0] = MissingTAG:0;
	if (GetTrieValue(hTrie_Cookies, weapon, cookie))
	{
		GetClientCookie(client, cookie, value, size);
		return true;
	}
	return false;
}

public OnProjectileSpawned(entity)
{
	new client = CSGrenadeProjectile_GetOwner(entity);
	if (0 < client <= MaxClients)
	{
		new var1;
		if (g_bCanSetCustomModel[client] && g_bEnabled[client] && bCvar_Enable)
		{
			new weapon = CSPlayer_GetActiveWeapon(client);
			if (weapon != -1)
			{
				new index;
				if ((index = CSWeapon_GetPredictID(weapon)))
				{
					decl String:buffer[256];
					buffer[0] = MissingTAG:0;
					GetPrecachedModelOfIndex(index, buffer, 256);
					if (buffer[0])
					{
						SetEntityModel(entity, buffer);
					}
				}
				return 0;
			}
		}
	}
	return 0;
}

public OnWeaponSpawn(weapon)
{
	decl String:szClsname[32];
	GetEdictClassname(weapon, szClsname, 32);
	new start_index;
	if (!(StrContains(szClsname, "weapon_", false)))
	{
		start_index = 7;
	}
	if (KvJumpToKey(hKv, szClsname[start_index], false))
	{
		if (!KvGetNum(hKv, "flag_bits", 0))
		{
			new index = KvGetNum(hKv, "world_model_index", 0);
			if (KvGotoFirstSubKey(hKv, true))
			{
				while (!KvGetNum(hKv, "flag_bits", 0) && dummy)
				{
					if (KvGotoNextKey(hKv, true))
					{
					}
				}
				index = dummy;
			}
			if (index)
			{
				SetEntProp(weapon, PropType:0, "m_iWorldModelIndex", index, 4, 0);
				SetEntProp(weapon, PropType:0, "m_nModelIndex", index, 4, 0);
				CSWeapon_SetPredictID(weapon, index);
				new offset = GetEntSendPropOffs(weapon, "m_bSilencerOn", false);
				if (offset != -1)
				{
					SetEntData(weapon, offset, any:0, 1, true);
					HookSingleEntityOutput(weapon, "OnPlayerPickup", OnPlayerPickup, true);
				}
			}
		}
		KvRewind(hKv);
	}
	return 0;
}

public OnBombPlanted(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new var1;
	if (!client || !g_bCanSetCustomModel[client] || !g_bEnabled[client] || !bCvar_Enable)
	{
		return 0;
	}
	new planted_c4 = FindEntityByClassname(MaxClients + 1, "planted_c4");
	if (planted_c4 != -1)
	{
		new weapon = CSPlayer_GetActiveWeapon(client);
		if (weapon != -1)
		{
			new index;
			if ((index = CSWeapon_GetPredictID(weapon)))
			{
				decl String:buffer[256];
				buffer[0] = MissingTAG:0;
				GetPrecachedModelOfIndex(index, buffer, 256);
				if (buffer[0])
				{
					SetEntityModel(planted_c4, buffer);
				}
			}
			return 0;
		}
	}
	return 0;
}

public Action:CS_OnCSWeaponDrop(client, weaponIndex)
{
	new var1;
	if (g_bCanSetCustomModel[client] && g_bEnabled[client] && bCvar_Enable && CSWeapon_GetPredictID(weaponIndex) > 0)
	{
		decl String:clsName[32];
		GetEdictClassname(weaponIndex, clsName, 32);
		new start_index;
		if (!(StrContains(clsName, "weapon_", false)))
		{
			start_index = 7;
		}
		decl Handle:hCookie;
		decl String:sValue[64];
		new var2;
		if (GetCookieValue(client, clsName[start_index], hCookie, sValue, 64) && sValue[0] != '0')
		{
			SetVariantString("OnUser1 !self:FireUser2::0.0:-1");
			AcceptEntityInput(weaponIndex, "AddOutput", -1, -1, 0);
			AcceptEntityInput(weaponIndex, "FireUser1", -1, -1, 0);
			HookSingleEntityOutput(weaponIndex, "OnUser2", Timer_SetDelayedWorldModel, true);
			new offset = GetEntSendPropOffs(weaponIndex, "m_bSilencerOn", false);
			if (offset != -1)
			{
				SetEntData(weaponIndex, offset, any:0, 1, true);
				HookSingleEntityOutput(weaponIndex, "OnPlayerPickup", OnPlayerPickup, true);
			}
		}
	}
	return Action:0;
}

public Timer_SetDelayedWorldModel(String:output[], weapon, activator, Float:delay)
{
	new iModel = CSWeapon_GetPredictID(weapon);
	if (0 < iModel)
	{
		SetEntProp(weapon, PropType:0, "m_iWorldModelIndex", iModel, 4, 0);
		SetEntProp(weapon, PropType:0, "m_nModelIndex", iModel, 4, 0);
	}
	return 0;
}

public OnPlayerPickup(String:output[], weapon, client, Float:delay)
{
	new offset = GetEntSendPropOffs(weapon, "m_bSilencerOn", false);
	if (offset != -1)
	{
		SetEntData(weapon, offset, any:1, 1, true);
	}
	return 0;
}

public OnRoundStart(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = 1;
	while (client <= MaxClients)
	{
		OldBits[client] = 0;
		new i;
		while (i < 2)
		{
			WeaponAddons[client][i] = 0;
			i++;
		}
		client++;
	}
	if (!iCvar_AdminFlags)
	{
		RoundStartChangeModels(hKv);
		RoundStartChangeModels(hRegKv);
	}
	return 0;
}


/* ERROR! null */
 function "RoundStartChangeModels" (number 65)
OnPrePostThinkPost(client)
{
	new bits = CSPlayer_GetAddonBits(client);
	new bits_to_remove;
	if (bits & 64)
	{
		if (!OldBits[client] & 64)
		{
			new var1;
			if (WeaponAddons[client][0] > 0 && IsValidEdict(WeaponAddons[client][0]))
			{
				AcceptEntityInput(WeaponAddons[client][0], "kill", -1, -1, 0);
			}
			WeaponAddons[client][0] = 0;
			new weapon = GetPlayerWeaponSlot(client, 0);
			if (weapon != -1)
			{
				CacheWeaponOn(client, weapon, 0, "primary");
			}
		}
	}
	else
	{
		if (OldBits[client] & 64)
		{
			new var2;
			if (WeaponAddons[client][0] > 0 && IsValidEdict(WeaponAddons[client][0]))
			{
				AcceptEntityInput(WeaponAddons[client][0], "kill", -1, -1, 0);
			}
			WeaponAddons[client][0] = 0;
		}
	}
	if (bits & 16)
	{
		if (!OldBits[client] & 16)
		{
			new var3;
			if (WeaponAddons[client][1] > 0 && IsValidEdict(WeaponAddons[client][1]))
			{
				AcceptEntityInput(WeaponAddons[client][1], "kill", -1, -1, 0);
			}
			WeaponAddons[client][1] = 0;
			new weapon = GetPlayerWeaponSlot(client, 4);
			if (weapon != -1)
			{
				CacheWeaponOn(client, weapon, 1, "primary");
			}
		}
	}
	else
	{
		if (OldBits[client] & 16)
		{
			new var4;
			if (WeaponAddons[client][1] > 0 && IsValidEdict(WeaponAddons[client][1]))
			{
				AcceptEntityInput(WeaponAddons[client][1], "kill", -1, -1, 0);
			}
			WeaponAddons[client][1] = 0;
		}
	}
	if (WeaponAddons[client][0])
	{
		bits_to_remove |= 64;
	}
	if (WeaponAddons[client][1])
	{
		bits_to_remove |= 16;
	}
	CSPlayer_SetAddonBits(client, ~bits_to_remove & bits);
	OldBits[client] = bits;
	return 0;
}

CacheWeaponOn(client, weapon, type, String:attachment[])
{
	new index;
	new var1;
	if (!g_bCanSetCustomModel[client] || !g_bEnabled[client] || !bCvar_Enable || (index = CSWeapon_GetPredictID(weapon)))
	{
		return 0;
	}
	decl String:buffer[256];
	buffer[0] = MissingTAG:0;
	GetPrecachedModelOfIndex(index, buffer, 256);
	if (buffer[0])
	{
		WeaponAddons[client][type] = CreateEntityByName("prop_dynamic_override", -1);
		DispatchKeyValue(WeaponAddons[client][type], "model", buffer);
		DispatchKeyValue(WeaponAddons[client][type], "spawnflags", "256");
		DispatchKeyValue(WeaponAddons[client][type], "solid", "0");
		DispatchSpawn(WeaponAddons[client][type]);
		SetEntPropEnt(WeaponAddons[client][type], PropType:0, "m_hOwnerEntity", client, 0);
		SetVariantString("!activator");
		AcceptEntityInput(WeaponAddons[client][type], "SetParent", client, WeaponAddons[client][type], 0);
		SetVariantString(attachment);
		AcceptEntityInput(WeaponAddons[client][type], "SetParentAttachment", WeaponAddons[client][type], -1, 0);
		SDKHook(WeaponAddons[client][type], SDKHookType:6, OnTransmit);
	}
	return 0;
}

public Action:OnTransmit(entity, client)
{
	new i;
	while (i < 2)
	{
		if (entity == WeaponAddons[client][i])
		{
			if (GetEntProp(client, PropType:1, "m_iObserverMode", 4, 0))
			{
				return Action:0;
			}
			return Action:3;
		}
		i++;
	}
	new owner = GetEntPropEnt(entity, PropType:0, "m_hOwnerEntity", 0);
	new var1;
	if (GetEntProp(client, PropType:0, "m_iObserverMode", 4, 0) == 4 && GetEntPropEnt(client, PropType:0, "m_hObserverTarget", 0) == owner)
	{
		return Action:3;
	}
	return Action:0;
}

public Action:CSS_Hook_ShotgunShot(String:te_name[], Players[], numClients, Float:delay)
{
	new client = TE_ReadNum("m_iPlayer") + 1;
	if (IsCustom[client])
	{
		new Sequence = CSViewModel_GetSequence(ClientVM[client][0]);
		if (HasSoundAt[client][Sequence])
		{
			if (g_iPlayerData[client][0])
			{
				new WeaponIndex = CSPlayer_GetActiveWeapon(client);
				if (WeaponIndex != -1)
				{
					new offset = FindDataMapOffs(WeaponIndex, "m_bSilencerOn", 0, 0);
					new var1;
					if (offset == -1 || !GetEntData(WeaponIndex, offset, 4))
					{
						decl Float:vOrigin[3];
						decl Float:vAngles[3];
						TE_ReadVector("m_vecOrigin", vOrigin);
						vAngles[0] = TE_ReadFloat("m_vecAngles[0]");
						vAngles[1] = TE_ReadFloat("m_vecAngles[1]");
						vAngles[2] = 0.0;
						AddInFrontOf(vOrigin, vAngles, g_iPlayerData[client][2], vOrigin);
						decl Float:vDummy[3];
						vDummy[0] = vAngles[0];
						vDummy[1] = vAngles[1];
						vDummy[2] = vAngles[2];
						vAngles[0] = 90.0;
						AddInFrontOf(vOrigin, vAngles, g_iPlayerData[client][3], vOrigin);
						vAngles[0] = vDummy[0];
						vAngles[1] -= 90.0;
						AddInFrontOf(vOrigin, vAngles, g_iPlayerData[client][4], vOrigin);
						vAngles = vDummy;
						TE_SetupMuzzleFlash(vOrigin, vAngles, g_iPlayerData[client][1], 1);
						new numPlayers;
						decl players[MaxClients];
						new i = 1;
						while (i <= MaxClients)
						{
							new var2;
							if (client != i && IsClientInGame(i) && !IsFakeClient(i))
							{
								numPlayers++;
								players[numPlayers] = i;
							}
							i++;
						}
						TE_Send(players, numPlayers, 0.0);
					}
				}
			}
			return Action:4;
		}
	}
	return Action:0;
}

public OnPostThinkPost(client)
{
	OnPrePostThinkPost(client);
	new WeaponIndex = CSPlayer_GetActiveWeapon(client);
	new Sequence = CSViewModel_GetSequence(ClientVM[client][0]);
	if (WeaponIndex < 1)
	{
		if (IsCustom[client])
		{
			CSViewModel_AddEffects(ClientVM[client][1], 32);
			CSViewModel_RemoveEffects(ClientVM[client][0], 32);
			IsCustom[client] = 0;
			OldSequence[client] = 0;
			iOldCycle[client] = 0;
			ClearTrie(g_hTrieSounds[client][0]);
			ClearTrie(g_hTrieSounds[client][1]);
			ClearTrie(g_hTrieSequence[client]);
			new i;
			while (i < 14)
			{
				HasSoundAt[client][i] = false;
				i++;
			}
			NextSeq[client] = 0;
			Function_OnWeaponSwitch(hPlugin[client], weapon_switch[client], client, WeaponIndex, ClientVM[client][0], ClientVM[client][1], OldSequence[client], Sequence, true, 0);
			hPlugin[client] = 0;
			weapon_switch[client] = -1;
			weapon_sequence[client] = -1;
		}
		OldWeapon[client] = WeaponIndex;
		return 0;
	}
	new Float:game_time = GetGameTime();
	new Float:Cycle = CSViewModel_GetCycle(ClientVM[client][0]);
	new var1;
	if (OldWeapon[client] != WeaponIndex && !OnWeaponChanged(client, WeaponIndex, Sequence))
	{
		OldWeapon[client] = WeaponIndex;
		return 0;
	}
	if (IsCustom[client])
	{
		new iCycle = RoundToFloor(Cycle * 10.0);
		if (g_bDev[client])
		{
			PrintHintText(client, "Sequence: %d\nCycle: %d", Sequence, iCycle);
		}
		if (IsValidEdict(ClientVM[client][1]))
		{
			CSViewModel_SetPlaybackRate(ClientVM[client][1], CSViewModel_GetPlaybackRate(ClientVM[client][0]));
			switch (Function_OnWeaponThink(hPlugin[client], weapon_sequence[client], client, WeaponIndex, ClientVM[client][0], ClientVM[client][1], OldSequence[client], Sequence))
			{
				case 0:
				{
					static String:local_buffer[256];
					IntToString(Sequence, local_buffer, 256);
					GetTrieValue(g_hTrieSequence[client], local_buffer, Sequence);
					if (HasSoundAt[client][Sequence])
					{
						EmitSoundToClient(client, "resource/warning.wav", client, 1, 0, 3, 0.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
						EmitSoundToClient(client, "resource/warning.wav", client, 3, 0, 3, 0.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
						if (iOldCycle[client] != iCycle)
						{
							decl String:sBuf[24];
							FormatEx(sBuf, 24, "%d_%d", Sequence, iCycle);
							if (GetTrieString(g_hTrieSounds[client][0], sBuf, local_buffer, 256, 0))
							{
								decl any:sInfo[4];
								GetTrieArray(g_hTrieSounds[client][1], sBuf, sInfo, 4, 0);
								if (g_bDev[client])
								{
									PrintToChat(client, "Sound: %s, Individual: %d, Volume: %.2f, Level: %d, Pitch: %d, Sequence: %d, Cycle: %d", local_buffer, sInfo, sInfo[1], sInfo[2], sInfo[3], Sequence, iCycle);
								}
								if (sInfo[0])
								{
									EmitSoundToClient(client, local_buffer, client, 0, sInfo[2], 0, sInfo[1], sInfo[3], -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
								}
								else
								{
									EmitAmbientSound(local_buffer, NULL_VECTOR, client, sInfo[2], 0, sInfo[1], sInfo[3], 0.0);
								}
							}
						}
					}
					new var2;
					if (Cycle < OldCycle[client] && OldSequence[client] == Sequence)
					{
						CSViewModel_SetSequence(ClientVM[client][1], 0);
						NextSeq[client] = game_time + 0.02;
					}
					else
					{
						if (NextSeq[client] < game_time)
						{
							CSViewModel_SetSequence(ClientVM[client][1], Sequence);
						}
					}
				}
				case 1:
				{
					CSViewModel_SetSequence(ClientVM[client][1], Sequence);
				}
				default:
				{
				}
			}
		}
		iOldCycle[client] = iCycle;
	}
	if (SpawnCheck[client])
	{
		SpawnCheck[client] = 0;
		if (IsCustom[client])
		{
			CSViewModel_AddEffects(ClientVM[client][0], 32);
		}
	}
	OldWeapon[client] = WeaponIndex;
	OldSequence[client] = Sequence;
	OldCycle[client] = Cycle;
	return 0;
}

public Action:NormalSoundHook(clients[64], &numClients, String:sample[256], &entity, &channel, &Float:volume, &level, &pitch, &flags)
{
	new var2;
	if (0 < entity <= MaxClients && IsCustom[entity] && (channel == 1 || channel == 3) && volume > 0)
	{
		channel = 0;
		return Action:1;
	}
	return Action:0;
}

public OnWeaponEquip(client, weapon)
{
	CSWeapon_SetPredictID(weapon, 0);
	decl String:szClsname[64];
	GetEdictClassname(weapon, szClsname, 64);
	new start_index;
	if (!(StrContains(szClsname, "weapon_", false)))
	{
		start_index = 7;
	}
	new index;
	if (KvJumpToKey(hRegKv, szClsname[start_index], false))
	{
		index = KvGetNum(hRegKv, "world_model_index", 0);
		KvRewind(hRegKv);
	}
	else
	{
		new var1;
		if (g_bCanSetCustomModel[client] && g_bEnabled[client] && bCvar_Enable && KvJumpToKey(hKv, szClsname[start_index], false))
		{
			decl Handle:hCookie;
			decl String:sValue[64];
			GetCookieValue(client, szClsname[start_index], hCookie, sValue, 64);
			if (sValue[0] == '0')
			{
				KvRewind(hKv);
				return 0;
			}
			new bits = KvGetNum(hKv, "flag_bits", 0);
			new var2;
			if (!bits || bits & g_iFlagBits[client])
			{
				new var3;
				if (sValue[0] && KvJumpToKey(hKv, sValue, false))
				{
					bits = KvGetNum(hKv, "flag_bits", 0);
					new var4;
					if (!bits || bits & g_iFlagBits[client])
					{
						index = KvGetNum(hKv, "world_model_index", 0);
					}
					KvGoBack(hKv);
				}
				if (!index)
				{
					index = KvGetNum(hKv, "world_model_index", 0);
					if (KvGotoFirstSubKey(hKv, true))
					{
						new dummy_index;
						while ((!bits || bits & g_iFlagBits[client]) && (dummy_index = KvGetNum(hKv, "world_model_index", 0)))
						{
							if (KvGotoNextKey(hKv, true))
							{
							}
						}
						index = dummy_index;
					}
				}
			}
			KvRewind(hKv);
		}
	}
	if (index)
	{
		SetEntProp(weapon, PropType:0, "m_iWorldModelIndex", index, 4, 0);
		SetEntProp(weapon, PropType:0, "m_nModelIndex", index, 4, 0);
		CSWeapon_SetPredictID(weapon, index);
	}
	return 0;
}

bool:OnWeaponChanged(client, WeaponIndex, Sequence)
{
	ClearTrie(g_hTrieSounds[client][0]);
	ClearTrie(g_hTrieSounds[client][1]);
	ClearTrie(g_hTrieSequence[client]);
	new i;
	while (i < 14)
	{
		HasSoundAt[client][i] = false;
		i++;
	}
	decl String:ClassName[32];
	GetEdictClassname(WeaponIndex, ClassName, 32);
	new start_index;
	if (!(StrContains(ClassName, "weapon_", false)))
	{
		start_index = 7;
	}
	new world_model;
	Function_OnWeaponSwitch(hPlugin[client], weapon_switch[client], client, WeaponIndex, ClientVM[client][0], ClientVM[client][1], OldSequence[client], Sequence, true, 0);
	hPlugin[client] = 0;
	weapon_switch[client] = -1;
	weapon_sequence[client] = -1;
	new bool:result;
	if (KvJumpToKey(hRegKv, ClassName[start_index], false))
	{
		decl any:aInfo[3];
		GetTrieArray(hRegTrie, ClassName[start_index], aInfo, 3, 0);
		hPlugin[client] = aInfo[0];
		weapon_switch[client] = aInfo[1];
		weapon_sequence[client] = aInfo[2];
		new bool:custom_change;
		if (Function_OnWeaponSwitch(hPlugin[client], weapon_switch[client], client, WeaponIndex, ClientVM[client][0], ClientVM[client][1], OldSequence[client], Sequence, false, custom_change))
		{
			KvRewind(hRegKv);
			hPlugin[client] = 0;
			weapon_switch[client] = -1;
			weapon_sequence[client] = -1;
		}
		else
		{
			new index = KvGetNum(hRegKv, "view_model_index", 0);
			if (IsValidEdict(ClientVM[client][1]))
			{
				if (custom_change)
				{
					index = 0;
				}
				if (index)
				{
					CSViewModel_SetModelIndex(ClientVM[client][1], index);
					custom_change = true;
				}
				if (custom_change)
				{
					CSViewModel_AddEffects(ClientVM[client][0], 32);
					CSViewModel_RemoveEffects(ClientVM[client][1], 32);
					CSViewModel_SetWeapon(ClientVM[client][1], WeaponIndex);
					CSViewModel_SetSequence(ClientVM[client][1], Sequence);
					CSViewModel_SetPlaybackRate(ClientVM[client][1], CSViewModel_GetPlaybackRate(ClientVM[client][0]));
					IsCustom[client] = 1;
					result = true;
				}
			}
			world_model = KvGetNum(hRegKv, "world_model_index", 0);
		}
		KvRewind(hRegKv);
	}
	if (!result)
	{
		new var1;
		if (g_bCanSetCustomModel[client] && g_bEnabled[client] && bCvar_Enable && KvJumpToKey(hKv, ClassName[start_index], false))
		{
			decl Handle:hCookie;
			decl String:sValue[64];
			GetCookieValue(client, ClassName[start_index], hCookie, sValue, 64);
			new bits = KvGetNum(hKv, "flag_bits", 0);
			new var3;
			if (sValue[0] != '0' && (!bits || bits & g_iFlagBits[client]))
			{
				new index;
				decl Float:vTemp[3];
				KvGetVector(hKv, "muzzle_move", vTemp, 21040);
				new var9 = g_iPlayerData[client][2];
				vTemp = var9;
				new var4;
				if (!sValue[0] || !KvJumpToKey(hKv, sValue, false))
				{
					if (KvGotoFirstSubKey(hKv, true))
					{
						while (!bits || bits & g_iFlagBits[client])
						{
							if (KvGotoNextKey(hKv, true))
							{
							}
						}
						index = KvGetNum(hKv, "view_model_index", 0);
						world_model = KvGetNum(hKv, "world_model_index", 0);
						g_iPlayerData[client][0] = KvGetNum(hKv, "muzzle_flash", 0);
						g_iPlayerData[client][1] = KvGetFloat(hKv, "muzzle_scale", 2.0);
						KvGetVector(hKv, "muzzle_move", vTemp, 21040);
						new var10 = g_iPlayerData[client][2];
						vTemp = var10;
						KvGetSectionName(hKv, sValue, 64);
						SetClientCookie(client, hCookie, sValue);
					}
				}
				else
				{
					index = KvGetNum(hKv, "view_model_index", 0);
					world_model = KvGetNum(hKv, "world_model_index", 0);
					g_iPlayerData[client][0] = KvGetNum(hKv, "muzzle_flash", 0);
					g_iPlayerData[client][1] = KvGetFloat(hKv, "muzzle_scale", 2.0);
					KvGetVector(hKv, "muzzle_move", vTemp, 21040);
					new var11 = g_iPlayerData[client][2];
					vTemp = var11;
				}
				if (index)
				{
					if (KvJumpToKey(hKv, "Sequences", false))
					{
						if (KvGotoFirstSubKey(hKv, false))
						{
							decl String:sSequence[4];
							do {
								new var6;
								if (KvGetSectionName(hKv, sSequence, 4) && sSequence[0])
								{
									SetTrieValue(g_hTrieSequence[client], sSequence, KvGetNum(hKv, NULL_STRING, 0), true);
								}
							} while (KvGotoNextKey(hKv, false));
							KvGoBack(hKv);
						}
						KvGoBack(hKv);
					}
					new bool:b_flip_model = KvGetNum(hKv, "flip_view_model", 0);
					if (KvJumpToKey(hKv, "Sounds", false))
					{
						if (KvGotoFirstSubKey(hKv, true))
						{
							decl String:map[128];
							decl String:buffer[256];
							do {
								KvGetSectionName(hKv, buffer, 256);
								new var7;
								if (buffer[0] && IsSoundFile(buffer))
								{
									new cached_sequence = KvGetNum(hKv, "sequence", 0);
									FormatEx(map, 128, "%d_%d", cached_sequence, KvGetNum(hKv, "cycle", 0));
									SetTrieString(g_hTrieSounds[client][0], map, buffer, true);
									decl any:sInfo[4];
									sInfo[0] = KvGetNum(hKv, "individual", 0);
									sInfo[1] = KvGetFloat(hKv, "volume", 1.0);
									sInfo[2] = KvGetNum(hKv, "level", 75);
									sInfo[3] = KvGetNum(hKv, "pitch", 100);
									SetTrieArray(g_hTrieSounds[client][1], map, sInfo, 4, true);
									HasSoundAt[client][cached_sequence] = true;
								}
							} while (KvGotoNextKey(hKv, true));
						}
					}
					CSViewModel_AddEffects(ClientVM[client][0], 32);
					if (IsValidEdict(ClientVM[client][1]))
					{
						CSViewModel_RemoveEffects(ClientVM[client][1], 32);
						CSViewModel_SetModelIndex(ClientVM[client][1], index);
						if (b_flip_model)
						{
							new weapon = GetPlayerWeaponSlot(client, 2);
							if (weapon != -1)
							{
								CSViewModel_SetWeapon(ClientVM[client][1], weapon);
							}
						}
						else
						{
							CSViewModel_SetWeapon(ClientVM[client][1], WeaponIndex);
						}
						CSViewModel_SetSequence(ClientVM[client][1], Sequence);
						CSViewModel_SetPlaybackRate(ClientVM[client][1], CSViewModel_GetPlaybackRate(ClientVM[client][0]));
					}
					IsCustom[client] = 1;
					result = true;
				}
			}
			KvRewind(hKv);
		}
		new var8;
		if (!result && IsCustom[client])
		{
			CSViewModel_RemoveEffects(ClientVM[client][0], 32);
			if (IsValidEdict(ClientVM[client][1]))
			{
				CSViewModel_AddEffects(ClientVM[client][1], 32);
				CSViewModel_SetSequence(ClientVM[client][1], 0);
			}
			IsCustom[client] = 0;
			NextSeq[client] = 0;
		}
		if (0 < world_model)
		{
			SetEntProp(WeaponIndex, PropType:0, "m_iWorldModelIndex", world_model, 4, 0);
			SetEntProp(WeaponIndex, PropType:0, "m_nModelIndex", world_model, 4, 0);
		}
		CSWeapon_SetPredictID(WeaponIndex, world_model);
	}
	return result;
}

public OnPlayerSpawn(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!client)
	{
		return 0;
	}
	new var1;
	if (IsClientInGame(client) && IsPlayerAlive(client) && !IsClientObserver(client))
	{
		SpawnCheck[client] = 1;
		new var2;
		if (g_bCanSetCustomModel[client] && g_bMenuSpawn[client])
		{
			OpenMainMenu(client, 10);
		}
	}
	return 0;
}

bool:OpenMainMenu(client, time)
{
	SetGlobalTransTarget(client);
	new Handle:menu = CreateMenu(MainMenu_Handler, MenuAction:28);
	SetMenuTitle(menu, "%t\n ", "Menu_Main");
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	decl String:buffer[128];
	if (IsCategoryFilled[0])
	{
		FormatEx(buffer, 128, "%t", "Menu_Rifles");
		AddMenuItem(menu, "0", buffer, 0);
	}
	if (IsCategoryFilled[1])
	{
		FormatEx(buffer, 128, "%t", "Menu_SMG");
		AddMenuItem(menu, "1", buffer, 0);
	}
	if (IsCategoryFilled[6])
	{
		FormatEx(buffer, 128, "%t", "Menu_Snipers");
		AddMenuItem(menu, "6", buffer, 0);
	}
	if (IsCategoryFilled[2])
	{
		FormatEx(buffer, 128, "%t", "Menu_Shotguns");
		AddMenuItem(menu, "2", buffer, 0);
	}
	if (IsCategoryFilled[3])
	{
		FormatEx(buffer, 128, "%t", "Menu_Pistols");
		AddMenuItem(menu, "3", buffer, 0);
	}
	if (IsCategoryFilled[4])
	{
		FormatEx(buffer, 128, "%t", "Menu_Melee");
		AddMenuItem(menu, "4", buffer, 0);
	}
	if (IsCategoryFilled[5])
	{
		FormatEx(buffer, 128, "%t", "Menu_Bomb");
		AddMenuItem(menu, "5", buffer, 0);
	}
	if (!GetMenuItemCount(menu))
	{
		CloseHandle(menu);
		return false;
	}
	new var1;
	if (g_bEnabled[client])
	{
		var1[0] = 21576;
	}
	else
	{
		var1[0] = 21584;
	}
	FormatEx(buffer, 128, "%t: %t", "Menu_ModelChange", var1);
	AddMenuItem(menu, "7", buffer, 0);
	new var2;
	if (g_bMenuSpawn[client])
	{
		var2[0] = 21628;
	}
	else
	{
		var2[0] = 21636;
	}
	FormatEx(buffer, 128, "%t: %t", "Menu_OpenMenuSpawn", var2);
	AddMenuItem(menu, "8", buffer, 0);
	DisplayMenu(menu, client, time);
	return true;
}

public MainMenu_Handler(Handle:menu, MenuAction:action, param1, param2)
{
	switch (action)
	{
		case 4:
		{
			if (!g_bCanSetCustomModel[param1])
			{
				CPrintToChat(param1, "%T", "Chat_NoAccess", param1);
				return 0;
			}
			decl String:sInfo[4];
			decl String:title[128];
			GetMenuItem(menu, param2, sInfo, 3, 0, title, 128);
			new item = StringToInt(sInfo, 10);
			switch (item)
			{
				case 7:
				{
					new Float:game_time = GetGameTime();
					if (NextChange[param1] < game_time)
					{
						g_bEnabled[param1] = !g_bEnabled[param1];
						new weapon = CSPlayer_GetActiveWeapon(param1);
						if (weapon != -1)
						{
							NextChange[param1] = game_time + 5.0;
							OnWeaponChanged(param1, weapon, CSViewModel_GetSequence(ClientVM[param1][0]));
							OldBits[param1] = 0;
						}
					}
					else
					{
						CPrintToChat(param1, "%T", "Chat_Delay", param1, RoundToCeil(NextChange[param1] - game_time));
					}
					OpenMainMenu(param1, 0);
				}
				case 8:
				{
					g_bMenuSpawn[param1] = !g_bMenuSpawn[param1];
					new var1;
					if (g_bMenuSpawn[param1])
					{
						var1[0] = 21712;
					}
					else
					{
						var1[0] = 21716;
					}
					SetClientCookie(param1, g_hCookieMenuSpawn, var1);
					OpenMainMenu(param1, 0);
				}
				default:
				{
					if (!Menu_ShowCategory(param1, item, title))
					{
						OpenMainMenu(param1, 0);
						CPrintToChat(param1, "%T", "Chat_CategoryEmpty", param1);
					}
				}
			}
		}
		case 8:
		{
			switch (param2)
			{
				case -6:
				{
					ShowCookieMenu(param1);
				}
				case -5, -3:
				{
					CPrintToChat(param1, "%T", "Chat_TypeCommand", param1);
				}
				default:
				{
				}
			}
		}
		case 16:
		{
			CloseHandle(menu);
		}
		default:
		{
		}
	}
	return 0;
}

bool:Menu_ShowCategory(client, category, String:title[])
{
	new Handle:menu = CreateMenu(CategoryMenu_Handler, MenuAction:28);
	SetMenuTitle(menu, "%s\n ", title);
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	iCategory[client] = category;
	strcopy(sCategoryTitle[client], 128, title);
	if (KvGotoFirstSubKey(hKv, true))
	{
		decl String:section[64];
		decl String:buffer[128];
		do {
			if (!(category != KvGetNum(hKv, "category", 0)))
			{
				KvGetSectionName(hKv, section, 64);
				KvGetString(hKv, g_sClLang[client], buffer, 128, "");
				if (!buffer[0])
				{
					strcopy(buffer, 128, section);
				}
				new bits = KvGetNum(hKv, "flag_bits", 0);
				decl bool:has_access;
				new var1;
				has_access = bits & g_iFlagBits[client] || !bits;
				if (!has_access)
				{
					Format(buffer, 128, "%s (%t)", buffer, "Menu_NoAccess");
				}
				new var2;
				if (has_access)
				{
					var2 = 0;
				}
				else
				{
					var2 = 1;
				}
				AddMenuItem(menu, section, buffer, var2);
			}
		} while (KvGotoNextKey(hKv, true));
		KvRewind(hKv);
	}
	if (!GetMenuItemCount(menu))
	{
		CloseHandle(menu);
		return false;
	}
	DisplayMenu(menu, client, 0);
	return true;
}

public CategoryMenu_Handler(Handle:menu, MenuAction:action, param1, param2)
{
	switch (action)
	{
		case 4:
		{
			if (!g_bCanSetCustomModel[param1])
			{
				CPrintToChat(param1, "%T", "Chat_NoAccess", param1);
				return 0;
			}
			decl String:sInfo[64];
			decl String:title[128];
			GetMenuItem(menu, param2, sInfo, 64, 0, title, 128);
			if (!Menu_ShowWeapon(param1, sInfo, title))
			{
				OpenMainMenu(param1, 0);
				CPrintToChat(param1, "%T", "Chat_WeaponEmpty", param1);
			}
		}
		case 8:
		{
			if (param2 == -6)
			{
				OpenMainMenu(param1, 0);
			}
		}
		case 16:
		{
			CloseHandle(menu);
		}
		default:
		{
		}
	}
	return 0;
}

bool:Menu_ShowWeapon(client, String:weapon[], String:title[])
{
	new Handle:menu = CreateMenu(WeaponMenu_Handler, MenuAction:28);
	SetMenuTitle(menu, "%s\n ", title);
	SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);
	if (!KvJumpToKey(hKv, weapon, false))
	{
		return false;
	}
	strcopy(szWeapon[client], 32, weapon);
	strcopy(sTitle[client], 128, title);
	decl String:sUserValue[64];
	decl Handle:hCookie;
	GetTrieValue(hTrie_Cookies, weapon, hCookie);
	GetClientCookie(client, hCookie, sUserValue, 64);
	SetGlobalTransTarget(client);
	decl String:buffer[128];
	FormatEx(buffer, 128, "%t", "Menu_WeaponDefault");
	if (sUserValue[0] == '0')
	{
		StrCat(buffer, 128, " [+]");
		AddMenuItem(menu, "0", buffer, 1);
	}
	else
	{
		AddMenuItem(menu, "0", buffer, 0);
	}
	if (KvGotoFirstSubKey(hKv, true))
	{
		decl String:section[64];
		do {
			KvGetSectionName(hKv, section, 64);
			KvGetString(hKv, g_sClLang[client], buffer, 128, "");
			if (!buffer[0])
			{
				strcopy(buffer, 128, section);
			}
			new bits = KvGetNum(hKv, "flag_bits", 0);
			decl bool:has_access;
			new var1;
			has_access = bits & g_iFlagBits[client] || !bits;
			if (!has_access)
			{
				Format(buffer, 128, "%s (%t)", buffer, "Menu_NoAccess");
			}
			else
			{
				if (StrEqual(section, sUserValue, true))
				{
					StrCat(buffer, 128, " [+]");
					AddMenuItem(menu, section, buffer, 1);
				}
			}
			new var2;
			if (has_access)
			{
				var2 = 0;
			}
			else
			{
				var2 = 1;
			}
			AddMenuItem(menu, section, buffer, var2);
		} while (KvGotoNextKey(hKv, true));
	}
	else
	{
		FormatEx(buffer, 128, "%t", "Menu_Custom");
		if (!sUserValue[0])
		{
			StrCat(buffer, 128, " [+]");
			AddMenuItem(menu, "", buffer, 1);
		}
		AddMenuItem(menu, "", buffer, 0);
	}
	KvRewind(hKv);
	if (GetMenuItemCount(menu) == 1)
	{
		CloseHandle(menu);
		return false;
	}
	DisplayMenu(menu, client, 0);
	return true;
}

public WeaponMenu_Handler(Handle:menu, MenuAction:action, param1, param2)
{
	switch (action)
	{
		case 4:
		{
			if (!g_bCanSetCustomModel[param1])
			{
				CPrintToChat(param1, "%T", "Chat_NoAccess", param1);
				return 0;
			}
			decl String:sInfo[64];
			GetMenuItem(menu, param2, sInfo, 64, 0, "", 0);
			decl Handle:hCookie;
			GetTrieValue(hTrie_Cookies, szWeapon[param1], hCookie);
			SetClientCookie(param1, hCookie, sInfo);
			new weapon = CSPlayer_GetActiveWeapon(param1);
			if (CheckWeapon(param1, weapon))
			{
				OnWeaponChanged(param1, weapon, CSViewModel_GetSequence(ClientVM[param1][0]));
			}
			else
			{
				new i;
				while (i < 2)
				{
					if (0 < WeaponAddons[param1][i])
					{
						switch (i)
						{
							case 0:
							{
								weapon = GetPlayerWeaponSlot(param1, 0);
							}
							case 1:
							{
								weapon = GetPlayerWeaponSlot(param1, 4);
							}
							default:
							{
							}
						}
						if (CheckWeapon(param1, weapon))
						{
							OnWeaponEquip(param1, weapon);
							OldBits[param1] = 0;
						}
					}
					i++;
				}
			}
			Menu_ShowWeapon(param1, szWeapon[param1], sTitle[param1]);
		}
		case 8:
		{
			if (param2 == -6)
			{
				Menu_ShowCategory(param1, iCategory[param1], sCategoryTitle[param1]);
			}
		}
		case 16:
		{
			CloseHandle(menu);
		}
		default:
		{
		}
	}
	return 0;
}

bool:CheckWeapon(client, weapon)
{
	decl String:buffer[32];
	new var1;
	if (weapon != -1 && GetEdictClassname(weapon, buffer, 32))
	{
		new start_index;
		if (!(StrContains(buffer, "weapon_", false)))
		{
			start_index = 7;
		}
		if (StrEqual(buffer[start_index], szWeapon[client], true))
		{
			return true;
		}
	}
	return false;
}

Action:Function_OnWeaponSwitch(Handle:plugin, Function:func_weapon_switch, client, weapon, predicted_viewmodel, custom_viewmodel, old_sequence, &new_sequence, bool:switch_from, &bool:custom_change)
{
	new Action:result;
	if (func_weapon_switch != -1)
	{
		Call_StartFunction(plugin, func_weapon_switch);
		Call_PushCell(client);
		Call_PushCell(weapon);
		Call_PushCell(predicted_viewmodel);
		Call_PushCell(custom_viewmodel);
		Call_PushCell(old_sequence);
		Call_PushCellRef(new_sequence);
		Call_PushCell(switch_from);
		Call_PushCellRef(custom_change);
		Call_Finish(result);
	}
	return result;
}

Action:Function_OnWeaponThink(Handle:plugin, Function:func_weapon_think, client, weapon, predicted_viewmodel, custom_viewmodel, old_sequence, &new_sequence)
{
	new Action:result;
	if (func_weapon_think != -1)
	{
		Call_StartFunction(plugin, func_weapon_think);
		Call_PushCell(client);
		Call_PushCell(weapon);
		Call_PushCell(predicted_viewmodel);
		Call_PushCell(custom_viewmodel);
		Call_PushCell(old_sequence);
		Call_PushCellRef(new_sequence);
		Call_Finish(result);
	}
	return result;
}

public Native_RegisterWeapon(Handle:plugin, numParams)
{
	decl String:sWeapon[32];
	GetNativeString(1, sWeapon, 32, 0);
	if (KvJumpToKey(hRegKv, sWeapon, false))
	{
		KvRewind(hKv);
		ThrowNativeError(1, "Weapon '%s' is already registered!", sWeapon);
	}
	decl String:buffer[256];
	GetNativeString(2, buffer, 256, 0);
	KvJumpToKey(hRegKv, sWeapon, true);
	if (buffer[0])
	{
		if (!IsModelFile(buffer))
		{
			KvDeleteThis(hRegKv);
			KvRewind(hRegKv);
			ThrowNativeError(1, "Invalid view model %s");
		}
		KvSetString(hRegKv, "view_model", buffer);
		KvSetNum(hRegKv, "view_model_index", PrecacheModel(buffer, false));
	}
	GetNativeString(3, buffer, 256, 0);
	if (buffer[0])
	{
		if (!IsModelFile(buffer))
		{
			KvDeleteThis(hRegKv);
			KvRewind(hRegKv);
			ThrowNativeError(1, "Invalid world model %s");
		}
		KvSetString(hRegKv, "world_model", buffer);
		KvSetNum(hRegKv, "world_model_index", PrecacheModel(buffer, false));
	}
	KvRewind(hRegKv);
	decl any:aInfo[3];
	aInfo[0] = plugin;
	aInfo[1] = GetNativeCell(4);
	aInfo[2] = GetNativeCell(5);
	SetTrieArray(hRegTrie, sWeapon, aInfo, 3, true);
	new client = 1;
	while (client <= MaxClients)
	{
		if (IsClientInGame(client))
		{
			new weapon = CSPlayer_GetActiveWeapon(client);
			if (!(weapon == -1))
			{
				if (Native_CheckWeapon(weapon, sWeapon))
				{
					OnWeaponChanged(client, weapon, CSViewModel_GetSequence(ClientVM[client][0]));
				}
				else
				{
					new i;
					while (i < 2)
					{
						if (0 < WeaponAddons[client][i])
						{
							switch (i)
							{
								case 0:
								{
									weapon = GetPlayerWeaponSlot(client, 0);
								}
								case 1:
								{
									weapon = GetPlayerWeaponSlot(client, 4);
								}
								default:
								{
								}
							}
							if (Native_CheckWeapon(weapon, sWeapon))
							{
								OnWeaponEquip(client, weapon);
								OldBits[client] = 0;
							}
						}
						i++;
					}
				}
			}
			client++;
		}
		client++;
	}
	return 1;
}

public Native_IsWeaponRegistered(Handle:plugin, numParams)
{
	decl String:sWeapon[32];
	GetNativeString(1, sWeapon, 32, 0);
	new bool:result;
	if (KvJumpToKey(hRegKv, sWeapon, false))
	{
		KvRewind(hRegKv);
		result = true;
	}
	return result;
}

public Native_UnregisterWeapon(Handle:plugin, numParams)
{
	decl String:sWeapon[32];
	GetNativeString(1, sWeapon, 32, 0);
	if (!KvJumpToKey(hRegKv, sWeapon, false))
	{
		ThrowNativeError(1, "Weapon '%s' is not registered!", sWeapon);
	}
	decl any:aInfo[3];
	GetTrieArray(hRegTrie, sWeapon, aInfo, 3, 0);
	if (plugin != aInfo[0])
	{
		KvRewind(hRegKv);
		ThrowNativeError(1, "Weapon '%s' is not registered by this plugin!", sWeapon);
	}
	KvDeleteThis(hRegKv);
	KvRewind(hRegKv);
	RemoveFromTrie(hRegTrie, sWeapon);
	new client = 1;
	while (client <= MaxClients)
	{
		if (IsClientInGame(client))
		{
			new weapon = CSPlayer_GetActiveWeapon(client);
			if (!(weapon == -1))
			{
				if (Native_CheckWeapon(weapon, sWeapon))
				{
					OnWeaponChanged(client, weapon, CSViewModel_GetSequence(ClientVM[client][0]));
				}
				else
				{
					new i;
					while (i < 2)
					{
						if (0 < WeaponAddons[client][i])
						{
							switch (i)
							{
								case 0:
								{
									weapon = GetPlayerWeaponSlot(client, 0);
								}
								case 1:
								{
									weapon = GetPlayerWeaponSlot(client, 4);
								}
								default:
								{
								}
							}
							if (Native_CheckWeapon(weapon, sWeapon))
							{
								OnWeaponEquip(client, weapon);
								OldBits[client] = 0;
							}
						}
						i++;
					}
				}
			}
			client++;
		}
		client++;
	}
	return 0;
}

public Native_UnregisterMe(Handle:plugin, numParams)
{
	if (KvGotoFirstSubKey(hRegKv, true))
	{
		decl String:sWeapon[32];
		decl any:aInfo[3];
		do {
			KvGetSectionName(hRegKv, sWeapon, 32);
			GetTrieArray(hRegTrie, sWeapon, aInfo, 3, 0);
			if (plugin == aInfo[0])
			{
				KvDeleteThis(hRegKv);
				KvRewind(hRegKv);
				RemoveFromTrie(hRegTrie, sWeapon);
				new client = 1;
				while (client <= MaxClients)
				{
					if (IsClientInGame(client))
					{
						new weapon = CSPlayer_GetActiveWeapon(client);
						if (!(weapon == -1))
						{
							if (Native_CheckWeapon(weapon, sWeapon))
							{
								OnWeaponChanged(client, weapon, CSViewModel_GetSequence(ClientVM[client][0]));
							}
							else
							{
								new i;
								while (i < 2)
								{
									if (0 < WeaponAddons[client][i])
									{
										switch (i)
										{
											case 0:
											{
												weapon = GetPlayerWeaponSlot(client, 0);
											}
											case 1:
											{
												weapon = GetPlayerWeaponSlot(client, 4);
											}
											default:
											{
											}
										}
										new var1;
										if (weapon != -1 && Native_CheckWeapon(weapon, sWeapon))
										{
											OnWeaponEquip(client, weapon);
											OldBits[client] = 0;
										}
									}
									i++;
								}
							}
						}
						client++;
					}
					client++;
				}
				KvGotoFirstSubKey(hRegKv, true);
			}
		} while (KvGotoNextKey(hRegKv, true));
	}
	KvRewind(hRegKv);
	return 0;
}

Native_CheckWeapon(weapon, String:sWeapon[])
{
	decl String:buffer[32];
	if (GetEdictClassname(weapon, buffer, 32))
	{
		new start_index;
		if (!(StrContains(buffer, "weapon_", false)))
		{
			start_index = 7;
		}
		if (StrEqual(buffer[start_index], sWeapon, true))
		{
			return 1;
		}
	}
	return 0;
}

bool:IsModelFile(String:model[])
{
	decl String:buf[4];
	ZGetExtension(model, buf, 4);
	return !strcmp(buf, "mdl", false);
}

GetPrecachedModelOfIndex(index, String:buffer[], maxlength)
{
	ReadStringTable(g_iTable, index, buffer, maxlength);
	return 0;
}

ZAddToDownloadsTable(String:path[], bool:recursive)
{
	if (path[0])
	{
		new len = strlen(path) + -1;
		new var1;
		if (path[len] == '\' || path[len] == '/')
		{
			path[len] = MissingTAG:0;
		}
		if (FileExists(path, false))
		{
			decl String:fileExtension[4];
			ZGetExtension(path, fileExtension, 4);
			new var2;
			if (StrEqual(fileExtension, "bz2", false) || StrEqual(fileExtension, "ztmp", false))
			{
				return 0;
			}
			new var3;
			if (StrEqual(fileExtension, "txt", false) || StrEqual(fileExtension, "ini", false))
			{
				ZReadDownloadList(path);
				return 0;
			}
			AddFileToDownloadsTable(path);
		}
		else
		{
			new var4;
			if (recursive && DirExists(path))
			{
				decl String:dirEntry[256];
				new Handle:__dir = OpenDirectory(path);
				while (ReadDirEntry(__dir, dirEntry, 256, 0))
				{
					new var5;
					if (!(StrEqual(dirEntry, ".", true) || StrEqual(dirEntry, "..", true)))
					{
						Format(dirEntry, 256, "%s/%s", path, dirEntry);
						ZAddToDownloadsTable(dirEntry, recursive);
					}
				}
				CloseHandle(__dir);
			}
			if (FindCharInString(path, 42, true))
			{
				decl String:fileExtension[4];
				ZGetExtension(path, fileExtension, 4);
				if (StrEqual(fileExtension, "*", true))
				{
					decl String:dirName[256];
					decl String:fileName[256];
					decl String:dirEntry[256];
					ZGetDirName(path, dirName, 256);
					ZGetFileName(path, fileName, 256);
					StrCat(fileName, 256, ".");
					new Handle:__dir = OpenDirectory(dirName);
					while (ReadDirEntry(__dir, dirEntry, 256, 0))
					{
						new var6;
						if (!(StrEqual(dirEntry, ".", true) || StrEqual(dirEntry, "..", true)))
						{
							if (strncmp(dirEntry, fileName, strlen(fileName), true))
							{
							}
							else
							{
								Format(dirEntry, 256, "%s/%s", dirName, dirEntry);
								ZAddToDownloadsTable(dirEntry, recursive);
							}
						}
					}
					CloseHandle(__dir);
				}
			}
		}
		return 0;
	}
	return 0;
}

bool:ZReadDownloadList(String:path[])
{
	new Handle:file = OpenFile(path, "r");
	if (file)
	{
		new String:buffer[256];
		while (!IsEndOfFile(file))
		{
			ReadFileLine(file, buffer, 256);
			new pos = StrContains(buffer, "//", true);
			if (pos != -1)
			{
				buffer[pos] = MissingTAG:0;
			}
			pos = StrContains(buffer, "#", true);
			if (pos != -1)
			{
				buffer[pos] = MissingTAG:0;
			}
			pos = StrContains(buffer, ";", true);
			if (pos != -1)
			{
				buffer[pos] = MissingTAG:0;
			}
			TrimString(buffer);
			if (buffer[0])
			{
				ZAddToDownloadsTable(buffer, true);
			}
		}
		CloseHandle(file);
		return true;
	}
	return false;
}

AddInFrontOf(Float:vecOrigin[3], Float:vecAngle[3], Float:units, Float:output[3])
{
	decl Float:vecView[3];
	GetAngleVectors(vecAngle, vecView, NULL_VECTOR, NULL_VECTOR);
	output[0] = vecView[0] * units + vecOrigin[0];
	output[1] = vecView[1] * units + vecOrigin[1];
	output[2] = vecView[2] * units + vecOrigin[2];
	return 0;
}

bool:IsSoundFile(String:sound[])
{
	decl String:buf[4];
	ZGetExtension(sound, buf, 4);
	new var1;
	return !strcmp(buf, "mp3", false) || !strcmp(buf, "wav", false);
}

ZGetExtension(String:path[], String:buffer[], size)
{
	new extpos = FindCharInString(path, 46, true);
	if (extpos == -1)
	{
		buffer[0] = MissingTAG:0;
		return 0;
	}
	extpos++;
	strcopy(buffer, size, path[extpos]);
	return 0;
}

bool:ZGetFileName(String:path[], String:buffer[], size)
{
	if (path[0])
	{
		ZGetBaseName(path, buffer, size);
		new pos_ext = FindCharInString(buffer, 46, true);
		if (pos_ext != -1)
		{
			buffer[pos_ext] = MissingTAG:0;
		}
		return false;
	}
	buffer[0] = MissingTAG:0;
	return false;
}

bool:ZGetDirName(String:path[], String:buffer[], size)
{
	if (path[0])
	{
		new pos_start = FindCharInString(path, 47, true);
		if (pos_start == -1)
		{
			pos_start = FindCharInString(path, 92, true);
			if (pos_start == -1)
			{
				buffer[0] = MissingTAG:0;
				return false;
			}
		}
		strcopy(buffer, size, path);
		buffer[pos_start] = MissingTAG:0;
		return false;
	}
	buffer[0] = MissingTAG:0;
	return false;
}

bool:ZGetBaseName(String:path[], String:buffer[], size)
{
	if (path[0])
	{
		new pos_start = FindCharInString(path, 47, true);
		if (pos_start == -1)
		{
			pos_start = FindCharInString(path, 92, true);
		}
		pos_start++;
		strcopy(buffer, size, path[pos_start]);
		return false;
	}
	buffer[0] = MissingTAG:0;
	return false;
}

ClearKV(Handle:kv)
{
	KvRewind(kv);
	if (KvGotoFirstSubKey(kv, true))
	{
		do {
			KvDeleteThis(kv);
			KvRewind(kv);
		} while (KvGotoFirstSubKey(kv, true));
	}
	return 0;
}

 