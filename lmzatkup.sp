#include <sourcemod>
#include <sdkhooks>

public Plugin myinfo = {
	name = "伤害",
	author = "花茶苑-老毛子",
	description = "修改伤害",
	version = "1.0.0"
	url = "QQ群576311971"
};

ConVar is_fixed,fixed_atk,multiple_atk;

public OnPluginStart(){
	is_fixed = CreateConVar("sm_fixed","0","倍率还是固定 1-固定伤害,0-倍率伤害",0,true, 0.0, true, 1.0);
	fixed_atk = CreateConVar("sm_fixedatk","1.0","固定伤害",0,true, 0.0, true, 100.0);
	multiple_atk = CreateConVar("sm_multipleatk","1.0","伤害倍数",0,true, 0.0, true, 10.0);
	AutoExecConfig(true,"lmz_atk_update");
}

//生成丧尸修改伤害
public void OnEntityCreated(int iEntity, const char[] sClassname)
{
	if (!IsValidEntity(iEntity)) return;
	if(StrEqual(sClassname, "player")||
		StrEqual(sClassname, "npc_nmrih_shamblerzombie")||
		StrEqual(sClassname, "npc_nmrih_turnedzombie")||
		StrEqual(sClassname, "npc_nmrih_runnerzombie")||
		StrEqual(sClassname, "npc_nmrih_kidzombie")){
		//伤害钩子
		SDKHookEx(iEntity, SDKHook_OnTakeDamage, OnTake_Damage_Pre);
	}
}


public Action OnTake_Damage_Pre(int iVictim, int & iAttacker, int & iInflictor, float & fDamage, int & iDamagetype)
{
	if (!IsValidEntity(iInflictor)) return Plugin_Continue;		//是否是实体
	if (iAttacker == iVictim) return Plugin_Continue;				//自杀
	if ((iAttacker >= 1) && (iAttacker <= MaxClients)){			//友军
		//爆炸物过滤
		char sWeapon[32];
		bool bSuccess = GetEntityClassname(iInflictor, sWeapon, sizeof(sWeapon));
		if (!bSuccess) return Plugin_Continue;
		if(StrEqual(sWeapon, "grenade_projectile", true)) return Plugin_Continue;
		if(StrEqual(sWeapon, "molotov_projectile", true)) return Plugin_Continue;
		if(StrEqual(sWeapon, "tnt_projectile", true)) return Plugin_Continue;
		//友伤
		if ((iVictim >= 1) && (iVictim <= MaxClients)) return Plugin_Continue;
	}

	//修改伤害
	if ((iVictim >= 1) && (iVictim <= MaxClients))
	{
		//固定伤害
		if(is_fixed.IntValue==1){
			fDamage = fixed_atk.FloatValue;
		}else{
			fDamage = fDamage * multiple_atk.FloatValue
		}
		return Plugin_Changed;
	}
	return Plugin_Continue;
}