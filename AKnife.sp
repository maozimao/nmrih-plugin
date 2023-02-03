#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin myinfo = {
    name = "一拳超人",
    author = "花茶苑-老毛子",
	version = "1.0.0",
	description = "<- 一拳超人 ->",
	url = "<- QQ群576311971 ->"
}

public void OnEntityCreated(int entity, const char[] classname){
	bool npc_shambler = StrEqual(classname, "npc_nmrih_shamblerzombie", false);
	bool npc_kid = StrEqual(classname, "npc_nmrih_kidzombie", false);
	bool npc_runner = StrEqual(classname, "npc_nmrih_runnerzombie", false);
	bool npc_turned = StrEqual(classname, "npc_nmrih_turnedzombie", false);
	bool player = StrEqual(classname, "player", false);
	if (npc_shambler || npc_kid || npc_runner || npc_turned ||player){
		SDKHookEx(entity, SDKHook_OnTakeDamage, OnTake_Damage_Pre);
	}
}

public Action OnTake_Damage_Pre(int iVictim, int & iAttacker, int & iInflictor, float & fDamage, int & iDamagetype){
	if (!IsValidEntity(iInflictor)) return Plugin_Continue;
	if (iVictim > 9 && iAttacker <= 9 && iAttacker >= 1){
		fDamage = 999999999.0;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}