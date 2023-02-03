#include <sourcemod>
#include <sdktools>

enum struct UserInfo{
	int LastButton;
}
UserInfo users[10];

public Plugin myinfo = {
	name = "超级手电筒",
	author = "花茶苑-老毛子",
	description = "玩家按x键开关超级手电筒",
	version = "1.0.0"
	url = "<- QQ群576311971 ->"
};

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2]){
    if(buttons & 16777216){
        if (!(users[client].LastButton & 16777216)){
            FlashLight(client, true);
        }else if ((users[client].LastButton & 16777216)){
            FlashLight(client, false);
        }
    }
    users[client].LastButton = buttons;
    return Plugin_Continue;
}

void FlashLight(int client, bool state){
    if(state == true){
        SetEntProp(client, Prop_Send, "m_fEffects", GetEntProp(client, Prop_Send, "m_fEffects") ^ 4);
    }else{
        SetEntProp(client, Prop_Send, "m_fEffects", GetEntProp(client, Prop_Send, "m_fEffects") ^ 0);
    }
}