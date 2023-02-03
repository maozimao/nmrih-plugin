#include <sourcemod>
#include <sdktools>

public Plugin myinfo = {
	name = "地图音乐关闭",
	author = "花茶苑-老毛子",
	description = "定时每20s关闭地图音乐",
	version = "1.0.0"
	url = "<- QQ群576311971 ->"
};

public void OnMapStart(){
	CreateTimer(20.0,StopMusic,_,TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action StopMusic(Handle timer){
	char sSound[PLATFORM_MAX_PATH];
	int entity = INVALID_ENT_REFERENCE;
	while ((entity = FindEntityByClassname(entity, "ambient_generic")) != INVALID_ENT_REFERENCE){
		GetEntPropString(entity, Prop_Data, "m_iszSound", sSound, sizeof(sSound));
		for(int i = 1; i < 10; i++){
			if(IsClientConnected(i)&&IsClientAuthorized(i)){
				EmitSoundToClient(i, sSound, entity, SNDCHAN_STATIC, SNDLEVEL_NONE, SND_STOP, 0.0, SNDPITCH_NORMAL, _, _, _, true);
			}
		}
	}
}