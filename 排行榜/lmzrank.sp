#include <sourcemod>
#include <sdktools>

//mysql数据
Database DB;
char error[70];

enum struct UserInfo{
	int client;
	char user_name[128];
	char steam_id[32];
	int exper_num;
	int death_num;
	int l_v_num;
	int kill_num;
	int money_num;
}

UserInfo users[10];

public Plugin myinfo = {
	name = "这是一个等级排名系统",
	author = "茉莉-老毛子",
	description = "<- 等级排名系统(金币已删除) ->",
	version = "1.0.0",
	url = "<- qq群576311971 ->"
}

public OnPluginStart()
{
	if(!SQL_CheckConfig("top")) SetFailState("数据库配置错误");
	Database.Connect(DbConnectCallback, "top");
	RegConsoleCmd("sm_top",usetTop);
	HookEvent("player_extracted", OnPlayerExtracted, EventHookMode_Post);//撤离
	HookEvent("player_death", OnPlayerDeath, EventHookMode_Post);//死亡
	HookEvent("npc_killed", OnNpcKilled, EventHookMode_Post);//杀敌
	HookEvent("zombie_head_split", ZombieHeadSplit, EventHookMode_Post);//爆头
}

public OnMapStart(){
	for(int i = 1;i < 10; i++){
		int client = users[i].client;
		if(client > 0  && IsClientAuthorized(client)){
			char update[200];
			Format(update,sizeof(update),"UPDATE nmrih_user SET user_name='%s',exper_num='%d',death_num='%d',l_v_num='%d',kill_num='%d',money_num='%d' WHERE steam_id = '%s'",users[client].user_name,users[client].exper_num,users[client].death_num,users[client].l_v_num,users[client].kill_num,users[client].money_num,users[client].steam_id);
			DB.Query(statusCallback, update, client);
		}
	}
}

public OnClientPostAdminCheck(int client){
	users[client].client = client;
	GetClientName(client,users[client].user_name,128)
	GetClientAuthId(client,AuthId_SteamID64,users[client].steam_id,32);
	initUser(client);
}


public OnClientDisconnect(int client){
	users[client].client = client;
	char query[200];
    Format(query,sizeof(query),"SELECT exper_num,death_num,l_v_num,kill_num,money_num FROM nmrih_user WHERE steam_id = '%s'",users[client].steam_id)
	DB.Query(endCallback, query, users[client].client);
}

public void ZombieHeadSplit(Event event, const char[] name, bool dontBroadcast)
{
	int client = event.GetInt("player_id");
	AddEX(client, 2);
}

public void OnPlayerExtracted(Event event, const char[] name, bool dontBroadcast)
{
	int client = event.GetInt("player_id");
	AddEX(client, 50);
	PrintToChatAll("\x07FFFF00★\x07FF0000幸存者 \x04%s \x07FF0000撤离成功 [经验 +20]", users[client].user_name);
}

public void OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	int attackerClient = GetClientOfUserId(event.GetInt("attacker"));
	users[client].death_num++;
	AddEX(client, -100);
	if(attackerClient>0&&attackerClient<10){
		if(client!=attackerClient&&IsPlayerAlive(attackerClient)){
			AddEX(attackerClient, -300);
		}
	}
}

public void OnNpcKilled(Event event, const char[] name, bool dontBroadcast)
{
	int killeridx = event.GetInt("killeridx");
	users[killeridx].kill_num++;
	AddEX(killeridx,1);
}


void AddEX(int client,int value){
	int userEx,lv;
	lv = users[client].l_v_num;
	userEx = users[client].exper_num + value;
	if(userEx >= lv * 10){
		users[client].l_v_num = lv + 1;
		users[client].exper_num = userEx - (lv * 10);
		PrintToChatAll("\x04幸存者 \x07FF0000%s \x04等级提升为 %d", users[client].user_name, users[client].l_v_num);
	}else{
		users[client].exper_num = userEx;
		if(value>0){
			PrintToChat(client,"\x04[Lv]: \x07FF0000%d | \x04总经验: %d | \x04经验: +%d", users[client].l_v_num, users[client].exper_num,value);
		}else{
			PrintToChat(client,"\x04[Lv]: \x07FF0000%d | \x04总经验: %d | \x04经验: %d", users[client].l_v_num, users[client].exper_num,value);
		}
	}

}

void DbConnectCallback(Database db, const char[] error, any data)
{
	if(!db) SetFailState("数据库连接失败: %s", error);
	db.SetCharset("utf8");
	DB = db;
	PrintToServer("数据库连接成功");
}

public Action PutInServerTimer(Handle timer, any client)
{	
	PrintToChatAll("\x07FF0000%s \x04等级:[\x07FF0000Lv. %d\x04] 经验:[\x07FF0000%d\x04] 击杀:[\x07FF0000%d\x04] 死亡:[\x07FF0000%d\x04]", users[client].user_name,users[client].l_v_num,users[client].exper_num,users[client].kill_num,users[client].death_num);
	return Plugin_Stop;
}

void initUser(int client){
	char query[200];
    Format(query,sizeof(query),"SELECT exper_num,death_num,l_v_num,kill_num,money_num FROM nmrih_user WHERE steam_id = '%s'",users[client].steam_id);
	DB.Query(initCallback, query, client);
}

void initCallback(Database db, DBResultSet result, char[] error, any client){
    if(result.FetchRow()){
		int exper_num,death_num,l_v_num,kill_num,money_num;
		result.FieldNameToNum("exper_num", exper_num);
		result.FieldNameToNum("death_num", death_num);
		result.FieldNameToNum("l_v_num", l_v_num);
		result.FieldNameToNum("kill_num", kill_num);
		result.FieldNameToNum("money_num", money_num);
		users[client].exper_num = result.FetchInt(exper_num);
		users[client].death_num = result.FetchInt(death_num);
		users[client].l_v_num = result.FetchInt(l_v_num);
		users[client].kill_num = result.FetchInt(kill_num);
		users[client].money_num = result.FetchInt(money_num);
	}else{
		users[client].exper_num = 0;
		users[client].death_num = 0;
		users[client].l_v_num = 0;
		users[client].kill_num = 0;
		users[client].money_num = 0;
	}
	CreateTimer(3, PutInServerTimer, client, TIMER_FLAG_NO_MAPCHANGE);
}

void endCallback(Database db, DBResultSet result, char[] error, any client){
	if(result.FetchRow()){
		if(users[client].client > 0){
			char update[200];
			Format(update,sizeof(update),"UPDATE nmrih_user SET user_name='%s',exper_num='%d',death_num='%d',l_v_num='%d',kill_num='%d',money_num='%d' WHERE steam_id = '%s'",users[client].user_name,users[client].exper_num,users[client].death_num,users[client].l_v_num,users[client].kill_num,users[client].money_num,users[client].steam_id);
			DB.Query(updateCallback, update, client);
		}
	}else{
		if(users[client].client > 0){
			char insert[200];
			Format(insert,sizeof(insert),"INSERT INTO nmrih_user (user_name,steam_id,exper_num,death_num,l_v_num,kill_num,money_num) VALUES ('%s','%s','%d','%d','%d','%d','%d')",users[client].user_name,users[client].steam_id,users[client].exper_num,users[client].death_num,users[client].l_v_num,users[client].kill_num,users[client].money_num);
			DB.Query(insertCallback, insert, client);
		}
	}
}

void updateCallback(Database db, DBResultSet result, char[] error, any client){
    if(!result.FetchRow()){
		PrintToChatAll("刚刚那个玩家数据丢失了");
	}
	users[client].client = -1;
	users[client].steam_id = "";
	users[client].user_name = "";
	users[client].exper_num = 0;
	users[client].death_num = 0;
	users[client].l_v_num = 0;
	users[client].kill_num = 0;
	users[client].money_num = 0;
}

void insertCallback(Database db, DBResultSet result, char[] error, any client){
    if(!result.FetchRow()){
		PrintToChatAll("刚刚那个玩家数据丢失了");
	}
	users[client].client = -1;
	users[client].steam_id = "";
	users[client].user_name = "";
	users[client].exper_num = 0;
	users[client].death_num = 0;
	users[client].l_v_num = 0;
	users[client].kill_num = 0;
	users[client].money_num = 0;
}

public Action usetTop(int client, int args)
{	
	if(!IsClientInGame(client)) return Plugin_Handled;
	char update[200];
    Format(update,sizeof(update),"SELECT exper_num,death_num,l_v_num,kill_num,money_num FROM nmrih_user WHERE steam_id = '%s'",users[client].steam_id);
	DB.Query(statusCallback, update, client);
	return Plugin_Handled;
}

void statusCallback(Database db, DBResultSet result, char[] error, any client){
	if(!result) PrintToServer("数据库查询失败: %s", error);
    if(result.FetchRow()){
		if(users[client].client > 0){
			char update[200];
			Format(update,sizeof(update),"UPDATE nmrih_user SET user_name='%s',exper_num='%d',death_num='%d',l_v_num='%d',kill_num='%d',money_num='%d' WHERE steam_id = '%s'",users[client].user_name,users[client].exper_num,users[client].death_num,users[client].l_v_num,users[client].kill_num,users[client].money_num,users[client].steam_id);
			DB.Query(statusCallback, update, client);
		}
	}else{
		if(users[client].client > 0){
			char insert[200];
			Format(insert,sizeof(insert),"INSERT INTO nmrih_user (user_name,steam_id,exper_num,death_num,l_v_num,kill_num,money_num) VALUES ('%s','%s','%d','%d','%d','%d','%d')",users[client].user_name,users[client].steam_id,users[client].exper_num,users[client].death_num,users[client].l_v_num,users[client].kill_num,users[client].money_num);
			DB.Query(insertCallback, insert, client);
		}
	}
	char query[] = "SELECT user_name,l_v_num FROM nmrih_user ORDER BY l_v_num DESC limit 10";
	DB.Query(RankQueryCallback, query, client);
}

public void RankQueryCallback(Database db, DBResultSet results, const char[] error, any client)
{
	if(!results){
		PrintToServer("数据库查询失败: %s", error);
		return;
	}
	char lines[10][256];
	int l_v_num,line;
	if(!results.FieldNameToNum("l_v_num", l_v_num)){
		PrintToServer("数据库列名错误: l_v_num");
		return;
	}
	PrintToChat(client, "\x07FFFF00★\x04[幸存者等级排名]:");
	while(results.FetchRow())
	{
		results.FetchString(0, lines[line], sizeof(lines[]));
		Format(lines[line], sizeof(lines[]), "\x04排名: \x07FF0000No.%d \x04| 幸存者: \x07FF0000 %s \x04| 等级: [\x07FF0000%d\x04]", line + 1, lines[line], results.FetchInt(l_v_num));
		line++;
	}
	while(line--) PrintToChat(client, lines[line]);
}
