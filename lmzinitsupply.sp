#include <sourcemod>
#include <sdktools>

//控制台可以变得变量
ConVar c_enable,c_initsup,c_initmedic,c_initsupnum,c_initmedicnum;
char sups[10][32] = {
	"me_machete",
	"me_axe_fire",
	"me_crowbar",
	"me_bat_metal",
	"me_hatchet",
	"me_kitknife",
	"me_pipe_lead",
	"me_sledge",
	"me_shovel",
	"me_wrench"
}

char medics[][] = {
	"item_bandages",
	"item_first_aid",
	"item_pills"
}

public Plugin:myinfo ={
	name = "初始武器配置",
	author = "花茶苑-老毛子",
	description = "<- 这是一个获取初始装备的插件 ->",
	version = "1.0.0",
	url = "<- QQ群576311971 ->"
}

public OnPluginStart(){
	//创建一个控制台变量
	c_enable = CreateConVar("sm_initenable","1","1开,0关",0,true, 0.0, true, 1.0);
	c_initsup = CreateConVar("sm_initsup","1","1砍刀,0近战武器随机",0,true, 0.0, true, 1.0);
	c_initmedic = CreateConVar("sm_initmedic","0","1三个医疗物品,0随机医疗物品",0,true, 0.0, true, 1.0);
	c_initsupnum = CreateConVar("sm_initsupnum","1","随机近战数量",0,true, 0.0, true, 2.0);
	c_initmedicnum = CreateConVar("sm_initmedicnum","2","医疗物品数量",0,true, 0.0, true, 2.0);
	//将所有的插件配置保存在一个文件中
	AutoExecConfig(true,"lmzinitsupply");
	HookEvent("player_spawn", GiveInitEquip, EventHookMode_Post);
}

void GiveInitEquip(Event event, const char[] name, bool dontBroadcast)
{	
	if(c_enable.IntValue < 1) return;
	int client = GetClientOfUserId(event.GetInt("userid"));
	RequestFrame(GiveSups, client);
	RequestFrame(GiveMedics, client);
}

public void GiveSups(any client){
	if(c_initsup.IntValue == 1){
		int entity = GivePlayerItem(client,"me_machete");
		if(IsValidEntity(entity)){
			AcceptEntityInput(entity, "Use", client, client);
		}
	}else{
		if(c_initsupnum.IntValue < 1) return;
		int num = c_initsupnum.IntValue;
		if(num==1){
			int entity = GivePlayerItem(client, sups[GetURandomInt() % sizeof(sups)]);
			if(!IsValidEntity(entity)) return;
			AcceptEntityInput(entity, "Use", client, client);
		}else if(num==2){
			for(int i = 0;i < 2; i++){
				int entity = GivePlayerItem(client, sups[GetURandomInt() % sizeof(sups)]);
				if(IsValidEntity(entity)){
					AcceptEntityInput(entity, "Use", client, client);
				}
			}
		}else{
			return;
		}
	}
}

public void GiveMedics(any client){
	if(c_initmedic.IntValue == 1){
		for(int i = 0;i < sizeof(medics);i++){
			int entity = GivePlayerItem(client,medics[i]);
			if(IsValidEntity(entity)){
				AcceptEntityInput(entity, "Use", client, client);
			}
		}
	}else{
		if(c_initmedicnum.IntValue < 1) return;
		int num = c_initmedicnum.IntValue;
		if(num==1){
			int entity = GivePlayerItem(client, medics[GetURandomInt() % sizeof(medics)]);
			if(!IsValidEntity(entity)) return;
			AcceptEntityInput(entity, "Use", client, client);
		}else if(num==2){
			int ramdom = GetURandomInt() % sizeof(medics);
			for(int i = 0;i < 3; i++){
				if(i!=ramdom){
					int entity = GivePlayerItem(client, medics[i]);
					if(IsValidEntity(entity)){
						AcceptEntityInput(entity, "Use", client, client);
					}
				}
			}
		}else{
			return;
		}
	}
}
