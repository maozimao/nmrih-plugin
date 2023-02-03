#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin myinfo ={
	name = "特殊裸男丧尸",
	author = "花茶苑-老毛子",
	description = "<- 特殊丧尸默认概率1/25，血量300，伤害正常伤害的2倍 ->",
	version = "1.0.0",
	url = "<- QQ群576311971 ->"
}

public void OnEntityCreated(entity,const char[] classname){
	if(IsValidEntity(entity)){
		if(StrEqual(classname,"npc_nmrih_turnedzombie")||StrEqual(classname,"npc_nmrih_runnerzombie")||StrEqual(classname,"npc_nmrih_shamblerzombie")){
			if(GetURandomInt() % 25 == 0){
				CreateTimer(0.3, Tasks, entity);
			}
		}else if(StrEqual(classname, "player")){
			SDKHookEx(entity, SDKHook_OnTakeDamage, OnTake_Damage_Pre);
		}
	}
}

Action Tasks(Handle timer, any entity){
	float monsterorgin[3];
    GetEntPropVector(entity, Prop_Send, "m_vecOrigin", monsterorgin);
	int zb = CreateEntityByName("npc_nmrih_runnerzombie")
	DispatchSpawn(zb);
	TeleportEntity(zb, monsterorgin, NULL_VECTOR, NULL_VECTOR);
	SDKHookEx(zb, SDKHook_OnTakeDamage, OnTake_Damage_Pre);
	CreateTimer(0.3, TasksZb, zb);
}

Action TasksZb(Handle timer, any entity){
	SetEntityModel(entity,"models/nmr_zombie/runner.mdl");
	SetEntProp(entity, Prop_Data, "m_iHealth", 300);
	SetEntPropString(entity, Prop_Data, "m_iName", "zb");
}

public Action OnTake_Damage_Pre(int iVictim, int & iAttacker, int & iInflictor, float & fDamage, int & iDamagetype){
	if (!IsValidEntity(iInflictor)) return Plugin_Continue;
	if (iAttacker == iVictim) return Plugin_Continue;
	if ((iAttacker >= 1) && (iAttacker <= 9)){
		char sWeapon[32];
		bool bSuccess = GetEntityClassname(iInflictor, sWeapon, sizeof(sWeapon));
		if (!bSuccess) return Plugin_Continue;
		if(StrEqual(sWeapon, "grenade_projectile", true)) return Plugin_Continue;
		if(StrEqual(sWeapon, "molotov_projectile", true)) return Plugin_Continue;
		if(StrEqual(sWeapon, "tnt_projectile", true)) return Plugin_Continue;
		if ((iVictim >= 1) && (iVictim <= 9)) return Plugin_Continue;
	}
	char classname[32];
	GetEntPropString(iAttacker, Prop_Data, "m_iName",classname,sizeof(classname));
	if (iVictim >= 1 && iVictim <= 9 && StrEqual(classname,"zb")){
			fDamage = fDamage * 2;
			return Plugin_Changed;
	}
	return Plugin_Continue;
}

public OnMapStart(){
	PrecacheModel("models/nmr_zombie/Runner.mdl", true);
}
