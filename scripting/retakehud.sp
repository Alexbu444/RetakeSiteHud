#include <sourcemod>
#include <sdktools>
#include <retakes>
#include <cstrike>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_AUTHOR "Czar, B3none"
#define PLUGIN_VERSION "1.4"

Handle cvar_red = INVALID_HANDLE;
Handle cvar_green = INVALID_HANDLE;
Handle cvar_blue = INVALID_HANDLE;
Handle cvar_fadein = INVALID_HANDLE;
Handle cvar_fadeout = INVALID_HANDLE;
Handle cvar_xcord = INVALID_HANDLE;
Handle cvar_ycord = INVALID_HANDLE;
Handle cvar_holdtime = INVALID_HANDLE;
Handle cvar_usingautoplant = INVALID_HANDLE;
Handle cvar_showterrorists = INVALID_HANDLE;

public Plugin myinfo =
{
	name = "Retake hud",
	author = PLUGIN_AUTHOR,
	description = "Bombsite Hud",
	version = PLUGIN_VERSION,
	url = "https://github.com/Czar-VG/RetakeSiteHud"
};

public void OnPluginStart()
{
	cvar_red = CreateConVar("sm_redhud", "255");
	cvar_green = CreateConVar("sm_greenhud", "255");
	cvar_blue = CreateConVar("sm_bluehud", "255");
	cvar_fadein = CreateConVar("sm_fadein", "0.5");
	cvar_fadeout = CreateConVar("sm_fadeout", "0.5");
	cvar_holdtime = CreateConVar("sm_holdtime", "5.0");
	cvar_xcord = CreateConVar("sm_xcord", "0.42");
	cvar_ycord = CreateConVar("sm_ycord", "0.3");
	cvar_usingautoplant = CreateConVar("sm_usingautoplant", "0");
	cvar_showterrorists = CreateConVar("sm_showterrorists", "1");

	AutoExecConfig(true, "retakehud");
	HookEvent("round_start", Event_OnRoundStart);
}
public void Event_OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	CreateTimer(1.0, displayHud);
}

public Action displayHud(Handle timer)
{
	if (IsWarmup())
	{
		return;
	}

	char bombsite[8];
	bombsite = (Retakes_GetCurrrentBombsite() == BombsiteA) ? "A" : "B";

	bool usingAutoplant = GetConVarBool(cvar_usingautoplant);
	bool showTerrorists = GetConVarBool(cvar_showterrorists);
	int red = GetConVarInt(cvar_red);
	int green = GetConVarInt(cvar_green);
	int blue = GetConVarInt(cvar_blue);
	float fadein = GetConVarFloat(cvar_fadein);
	float fadeout = GetConVarFloat(cvar_fadeout);
	float holdtime = GetConVarFloat(cvar_holdtime);
	float xcord = GetConVarFloat(cvar_xcord);
	float ycord = GetConVarFloat(cvar_ycord);

	for (int i = 1; i <= MaxClients; i++)
	{
		int clientTeam = GetClientTeam(i);
		if (IsValidClient(i))
		{
			SetHudTextParams(xcord, ycord, holdtime, red, green, blue, 255, 0, 0.25, fadein, fadeout);

			if (!usingAutoplant && HasBomb(i))
			{
			    // We always want to show this one regardless
                ShowHudText(i, 5, "Plant The Bomb!");
			}
			else
			{
				if (clientTeam == CS_TEAM_CT || (clientTeam == CS_TEAM_T && showTerrorists))
				{
					ShowHudText(i, 5, "%s Bombsite: %s", clientTeam == CS_TEAM_T ? "Defend" : "Retake", bombsite);
				}
			}
		}
	}
}

stock bool IsValidClient(int client)
{
    return client > 0
        && client <= MaxClients
        && IsClientConnected(client)
        && IsClientInGame(client)
        && !IsFakeClient(client);
}

stock bool HasBomb(int client)
{
    return GetPlayerWeaponSlot(client, 4) != -1;
}

stock bool IsWarmup()
{
	return GameRules_GetProp("m_bWarmupPeriod") == 1;
}