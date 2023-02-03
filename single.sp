#include <sourcemod>
#include <sdktools>

public Plugin myinfo ={
	name = "单通插件",
	author = "花茶苑-老毛子",
	description = "<- 只能一个人存活，可移交单通资格，可投票选举单通人员 ->",
	version = "1.0.0",
	url = "<- QQ群576311971 ->"
}

static char playSteamId[32] = "123";
static int enable = 1;
static int killNum = 0;


public void OnPluginStart(){
	HookEvent("player_spawn", PlayerSpawn);
	HookEvent("nmrih_round_begin", RoundBegin);
	RegConsoleCmd("sm_replace", PlayReplace);
	RegConsoleCmd("sm_single",SinglePlay);
}

public Action KillPlayerTasks(Handle timer, int aliveNum){
	if(getPlayerAliveNum() > aliveNum){
		for(int i = 1; i <= 9; i++){
			if(IsClientConnected(i) && IsClientAuthorized(i)){
				if(IsPlayerAlive(i)){
					char steamId[32];
					GetClientAuthId(i,AuthId_SteamID64,steamId,sizeof(steamId));
					if(!StrEqual(steamId,playSteamId)){
						FakeClientCommandEx(i,"kill");
					}
				}
			}
		}
	}
}


//开始时间
public Action RoundBegin(Event e, const char[] n, bool b){
	enable = 1;
	killNum = 0;
}
public void PlayerSpawn(Event event, const char[] name, bool dontBroadcast){
	char steamId[32];
	int client = GetClientOfUserId(event.GetInt("userid"));
	GetClientAuthId(client,AuthId_SteamID64,steamId,sizeof(steamId));
	if(PlayExis()){
		if(!StrEqual(steamId,playSteamId)){
			FakeClientCommandEx(client,"kill");
		}
	}else{
		playSteamId = steamId;
		KillOtherPlay(client);
	}
}

public OnClientDisconnect(int client){
	char steamId[32];
	GetClientAuthId(client,AuthId_SteamID64,steamId,sizeof(steamId));
	if(StrEqual(steamId,playSteamId)){
		CreateTimer(1.0, Tasks, client);
	}
}

public void OnClientPostAdminCheck(int client){
	if(!PlayExis()){
		SelectionPlay();
		enable = 1;
	}
}

public void OnMapStart(){
	enable = 1;
	if(getClientNum()>0){
		if(!PlayExis()){
			SelectionPlay();
			enable = 1;
		}
	}
	//最多存活人数
	CreateTimer(10.0, KillPlayerTasks, 1, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action SinglePlay(client,args){
	if(enable == 0){
		PrintToChat(client,"\x04[单通]: \x07FF0000投票冷却3分钟...");
	}else{
		Handle PlayerMenu = CreateMenu(SinglePlayCall);
		SetMenuTitle(PlayerMenu,"单通玩家投票");
		for(int i = 1; i <= 9; i++){
			if(IsClientConnected(i) && IsClientAuthorized(i)){
				char username[256],clientStr[2];
				GetClientName(i,username,sizeof(username));
				IntToString(i,clientStr,sizeof(clientStr));
				AddMenuItem(PlayerMenu,clientStr,username);
			}else{
				continue;
			}
		}
		SetMenuExitBackButton(PlayerMenu,true);
		VoteMenuToAll(PlayerMenu, 20, 0);
		enable = 0;
	}
}

public SinglePlayCall(Handle PlayerMenu,MenuAction action,voteresult,votecountinfo){
	//当客户端选择了一个节点的时候
	if(action == MenuAction_VoteEnd){
		//开始处理他选择内容
		char commandparam[32],resultname[256];//, winvotecount, totalvotecount;
		//GetMenuVoteInfo(votecountinfo, winvotecount, totalvotecount);
		GetMenuItem(PlayerMenu, voteresult, commandparam, sizeof(commandparam),_,resultname, sizeof(resultname));
		char steamId[32];
		GetClientAuthId(StringToInt(commandparam),AuthId_SteamID64,steamId,sizeof(steamId));
		playSteamId = steamId;
		PrintToChatAll("\x04[单通]: \x07FF0000谈判成功新的单通人员 %s",resultname);
	}else if(action == MenuAction_End){
		CloseHandle(PlayerMenu);
	}
}

public Action PlayReplace(int client, int args){
	char steamId[32];
	GetClientAuthId(client,AuthId_SteamID64,steamId,sizeof(steamId));
	if(StrEqual(steamId,playSteamId)){
		Handle spawnMenu = CreateMenu(SpawnMenu);
		SetMenuTitle(spawnMenu,"玩家列表-转让单通");
		for(int i = 1; i <= 9; i++){
			if(IsClientConnected(i) && IsClientAuthorized(i)){
				char username[256],clientStr[2];
				GetClientName(i,username,sizeof(username));
				IntToString(i,clientStr,sizeof(clientStr));
				AddMenuItem(spawnMenu,clientStr,username);
			}else{
				continue;
			}
		}
		SetMenuPagination(spawnMenu,9);
		DisplayMenu(spawnMenu,client,30);
	}else{
		PrintToChat(client,"\x04[单通]: \x07FF0000你不是单通人员");
		return;
	}
	PrintToChat(client,"\x04[单通]: \x07FF0000转让单通后会立即自杀!!!");
}

public SpawnMenu(Handle spawnMenu, MenuAction action,client, itempos){
	if(action == MenuAction_Select){
		char item[2];
		GetMenuItem(spawnMenu,itempos,item,sizeof(item));
		if(StringToInt(item) == client){
			PrintToChat(client,"\x04[单通]: \x07FF0000请不要转移给自己...")
			return;
		}else{
			char steamId[32],username[256];
			GetClientName(StringToInt(item),username,sizeof(username));
			GetClientAuthId(StringToInt(item),AuthId_SteamID64,steamId,sizeof(steamId));
			playSteamId = steamId;
			PrintToChatAll("\x04[单通]: \x07FF0000新的单通人员 %s",username);
			FakeClientCommandEx(client,"kill");
		}
	}else if(action == MenuAction_End){
		CloseHandle(spawnMenu);
	}
}

Action Tasks(Handle timer, int client){
	enable = 1;
	SelectionPlay();
}

void SelectionPlay(){
	char steamId[32];
	int client = (GetURandomInt() % 9) + 1;
	while(true){
		if(getClientNum() < 1){
			playSteamId = "123";
			break;
		}
		if(IsClientConnected(client)&&IsClientAuthorized(client)){
			GetClientAuthId(client,AuthId_SteamID64,steamId,sizeof(steamId));
			if(!StrEqual(steamId,playSteamId)){
				char clientName[256];
				GetClientName(client,clientName,sizeof(clientName));
				playSteamId = steamId;
				PrintToChatAll("\x04[单通]: \x07FF0000单通人员 %s",clientName);
				break;
			}
		}else{
			client = (GetURandomInt() % 9) + 1;
		}
	}
}

void KillOtherPlay(int client){
	for(int i = 1; i <= 9; i++){
		if(i != client && IsClientConnected(i) && IsClientAuthorized(i)){
			if(IsPlayerAlive(i)){
				FakeClientCommandEx(i,"kill");
			}
		}
	}
}

bool PlayExis(){
	char steamId[32];
	for(int i = 1; i <= 9; i++){
		if(IsClientConnected(i)&&IsClientAuthorized(i)){
			GetClientAuthId(i,AuthId_SteamID64,steamId,sizeof(steamId));
			if(StrEqual(steamId,playSteamId)){
				return true;
			}
		}
	}
	return false;
}

int getClientNum(){
	int count = 0;
	for(int i = 1; i <= 9; i++){
		if(IsClientConnected(i)&&IsClientAuthorized(i)){
			count++;
		}
	}
	return count;
}

int getPlayerAliveNum(){
	int count = 0;
	for(int i = 1; i <= 9; i++){
		if(IsClientConnected(i)&&IsClientAuthorized(i)){
			if(IsPlayerAlive(i)){
				count++;
			}
		}
	}
	return count;
}