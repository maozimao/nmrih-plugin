#include <sourcemod>
#include <sdktools>

enum struct UserInfo{
	int client;
	char user_name[128];
	char steam_id[32];
	int integral;
	int pay_money;
	int user_status;
	char lost_model_path[128];
}
UserInfo users[10];

bool bTPView[MAXPLAYERS+1];
Database DB;
static int pageSize = 9;

public Plugin myinfo = {
	name = "皮肤插件",
	author = "花茶苑-老毛子",
	description = "<- 专属和免费皮肤 ->",
	version = "1.0.0",
	url = "<- qq群576311971 ->"
}

public void OnPluginStart(){
	if(!SQL_CheckConfig("models")) SetFailState("皮肤数据库配置错误");
	Database.Connect(DbConnectCallback, "models");
	HookEvent("player_death", PlayerDeath);
	HookEvent("player_spawn", PlayerSpawn);
	RegConsoleCmd("sm_model", Cmd_Model);
	RegConsoleCmd("sm_models", Cmd_Model);
}

public void OnMapStart(){
	DownloadFolder("models");
	DownloadFolder("materials");
	for(int i = 1;i < 10; i++){
		if(i > 0  && IsClientConnected(i)){
			users[i].client = i;
			GetClientName(i,users[i].user_name,128)
			GetClientAuthId(i,AuthId_SteamID64,users[i].steam_id,32);
			initUser(i);
		}else{
			users[i].client = 0;
			bTPView[i] = false;
		}
	}
}

public void OnMapEnd(){
	for(int i = 1;i < 10; i++){
		int client = users[i].client;
		if(client > 0  && IsClientConnected(client)){
			GetClientName(client,users[i].user_name,128)
			GetClientAuthId(client,AuthId_SteamID64,users[i].steam_id,32);
			initUser(client);
		}
		users[i].client = 0;
		users[i].pay_money = 0;
		users[i].integral = 0;
		bTPView[i] = false;
	}
}

public void OnClientPostAdminCheck(int client){
	users[client].client = client;
	GetClientName(client,users[client].user_name,128)
	GetClientAuthId(client,AuthId_SteamID64,users[client].steam_id,32);
	initUser(client);
}

public void PlayerDeath(Event event, const char[] name, bool dontBroadcast){
	int client = GetClientOfUserId(event.GetInt("userid"));
}

public void PlayerSpawn(Event event, const char[] name, bool dontBroadcast){
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(!StrEqual(users[client].lost_model_path,"Undefined")&&FileExists(users[client].lost_model_path, true)){
		SetEntityModel(client,users[client].lost_model_path);
	}
	if (GetEntProp(client, Prop_Send, "m_iObserverMode") == 1) {
		bTPView[client] = false;
		ToggleView(client);
	}
}

public OnClientDisconnect(int client){
	initUser(client);
	users[client].client = 0;
}

void initUser(int client){
	char query[200];
    Format(query,sizeof(query),"SELECT steam_id,user_name,integral,pay_money,user_status,lost_model_path FROM nmrih_user WHERE steam_id = '%s'",users[client].steam_id);
	DB.Query(initCallback, query, client);
}

void initCallback(Database db, DBResultSet result, char[] error, any client){
    if(result.FetchRow()){
		int integral,user_status,pay_money;
		result.FieldNameToNum("integral", integral);
		result.FieldNameToNum("pay_money", pay_money);
		result.FieldNameToNum("user_status", user_status);
		users[client].integral = result.FetchInt(integral);
		users[client].pay_money = result.FetchInt(pay_money);
		users[client].user_status = result.FetchInt(user_status);
		result.FetchString(5, users[client].lost_model_path, 128);
		if(users[client].client > 0){
			char update[200];
			Format(update,sizeof(update),"UPDATE nmrih_user SET user_name='%s',integral='%d' WHERE steam_id = '%s'",users[client].user_name,users[client].integral,users[client].steam_id);
			DB.Query(Callback, update, client);
		}
	}else{
		users[client].integral = 0;
		users[client].user_status = 1;
		users[client].pay_money = 0;
		users[client].lost_model_path = "Undefined"
		if(users[client].client > 0){
			char insert[200];
			Format(insert,sizeof(insert),"INSERT INTO nmrih_user (steam_id,user_name,integral,pay_money,user_status) VALUES ('%s','%s','%d','%d','%d')",users[client].steam_id,users[client].user_name,users[client].integral,users[client].pay_money,users[client].user_status);
			DB.Query(Callback, insert, client);
		}
	}
}

void UpdateUserModelPath(int client){
	char update[200];
	Format(update,sizeof(update),"UPDATE nmrih_user SET lost_model_path='%s' WHERE steam_id = '%s'",users[client].lost_model_path,users[client].steam_id);
	DB.Query(Callback, update, client);
}

void Callback(Database db, DBResultSet result, char[] error, any client){
    if(!result.FetchRow()){
		PrintToChatAll("玩家数据未保存成功!");
	}
}

public Action Cmd_Model(int client, int args){
	MainMenu(client);
}

public void MainMenu(int client){
	Handle menu  = CreateMenu(MainMenuCallback, MENU_ACTIONS_ALL);
	SetMenuTitle(menu,"皮肤列表");
	AddMenuItem(menu,"1","专属皮肤");
	AddMenuItem(menu,"2","免费皮肤");
	//AddMenuItem(menu,"3","积分皮肤");
	SetMenuPagination(menu,pageSize);
	DisplayMenu(menu,client,30);
}

public MainMenuCallback(Handle menu, MenuAction action, client, Position){
	if(action == MenuAction_Select){
		char item[2];
		GetMenuItem(menu,Position,item,sizeof(item));
		SelectMenu(client,StringToInt(item));
	}else if(action == MenuAction_End){
		bTPView[client] = false;
		ToggleView(client);
		CloseHandle(menu);
	}else if(action == MenuAction_Display){
		bTPView[client] = true;
		ToggleView(client);
	}else if(MenuAction_Cancel){
		bTPView[client] = false;
		ToggleView(client);
	}
}

public void SelectMenu(int client,int value){
	char query[200];
	Format(query,sizeof(query),"SELECT id,model_title,model_name,model_file_path,pay_money,money_or_free_or_integral,need_integral FROM nmrih_model WHERE is_open = 1 and money_or_free_or_integral = %d ORDER BY model_sort DESC",value);
	DB.Query(SelectPage, query, client);
}

public void SelectPage(Database db, DBResultSet results, char[] error, any client){
	Handle menu = CreateMenu(SelectPageCallback,MENU_ACTIONS_ALL);
	SetMenuTitle(menu,"皮肤列表");
	int pay_money;
	char model_name[256],model_title[128],model_file_path[256];
	if(!results.FieldNameToNum("pay_money", pay_money)){
		PrintToServer("数据库列名错误!");
		return;
	}
	while(results.FetchRow()){
		char menuName[256];
		results.FetchString(2, model_name, sizeof(model_name));
		results.FetchString(1, model_title, sizeof(model_title));
		results.FetchString(3, model_file_path, sizeof(model_file_path));
		if(FileExists(model_file_path, true)){
			Format(menuName,sizeof(menuName),"%s",model_name);
			AddMenuItem(menu,model_title,menuName);
		}
	}
	SetMenuPagination(menu,pageSize);
	SetMenuExitBackButton(menu,true);
	DisplayMenu(menu,client,MENU_TIME_FOREVER);
}

public SelectPageCallback(Handle menu, MenuAction action, client, Position){
	switch(action){
		case MenuAction_Display: {
			bTPView[client] = true;
			ToggleView(client);
		}
		case MenuAction_Select: {
			char item[128];
			GetMenuItem(menu,Position,item,sizeof(item));
			char query[256];
			Format(query,sizeof(query),"SELECT model_name,model_file_path,pay_money,money_or_free_or_integral FROM nmrih_model WHERE model_title = '%s' and is_open = 1",item);
			DB.Query(ApplyModel, query, users[client].client);
		}
		case MenuAction_Cancel: {
			if(Position == MenuCancel_ExitBack){
				MainMenu(client);
			}else{
				bTPView[client] = false;
				ToggleView(client);
			}
		}
		case MenuAction_End: CloseHandle(menu);
	}
}

public void ApplyModel(Database db, DBResultSet results, char[] error, any client){
	if(results.FetchRow()){
		int pay_money,money_or_free_or_integral;
		if(!results.FieldNameToNum("money_or_free_or_integral", money_or_free_or_integral)){
			PrintToServer("数据库列名错误!");
			bTPView[client] = false;
			ToggleView(client);
			return;
		}
		char modelPath[128];
		results.FetchString(1,modelPath, sizeof(modelPath));
		if(results.FetchInt(money_or_free_or_integral)==1){//会员换皮
			if(!results.FieldNameToNum("pay_money", pay_money)){
				PrintToServer("数据库列名错误!");
				bTPView[client] = false;
				ToggleView(client);
				return;
			}
			if(users[client].pay_money >= results.FetchInt(pay_money)){
				SetEntityModel(client,modelPath);
				users[client].lost_model_path = modelPath;
				UpdateUserModelPath(client);
			}else{
				PrintToChat(client,"\x07FF0000你的专属等级不够 \x04");
			}
		}else if(results.FetchInt(money_or_free_or_integral)==2){//免费换皮
			SetEntityModel(client,modelPath);
			users[client].lost_model_path = modelPath;
			UpdateUserModelPath(client);
		}else{//积分换皮
			PrintToChat(client,"积分功能暂时未开放!");
		}
		bTPView[client] = false;
		ToggleView(client);
	}
	MainMenu(client);
}

stock void ToggleView(int client)
{
	if(!IsValidClient(client) || !IsPlayerAlive(client)) return;

	if(bTPView[client])
	{
		int iRagdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
		if (IsValidEntity(iRagdoll)) {
			AcceptEntityInput(iRagdoll, "Kill");
		}
		SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", 0);
		SetEntProp(client, Prop_Send, "m_iObserverMode", 1);
		SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 0);
		SetEntProp(client, Prop_Send, "m_iFOV", 70);
	}
	else
	{
		SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", client);
		SetEntProp(client, Prop_Send, "m_iObserverMode", 0);
		SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1);
		SetEntProp(client, Prop_Send, "m_iFOV", 90);
	}
}

void DbConnectCallback(Database db, const char[] error, any data)
{
	if(!db) SetFailState("数据库连接失败: %s", error);
	db.SetCharset("utf8");
	DB = db;
	PrintToServer("数据库连接成功");
}

stock bool IsValidClient(int client)
{
	return 0 < client <= MaxClients && IsClientInGame(client);
}

stock void DownloadFolder(char[] Folder){
    char Suffix[][] = {
        "mdl", 
        "phy",
        "vtx", 
        "vvd",
        "vmt", 
        "vtf", 
        "mp3", 
        "wav"
    };
    Handle Dir = OpenDirectory(Folder);
    FileType FILETYPE;
    char FileBuffer[PLATFORM_MAX_PATH]
    
    if(DirExists(Folder))
    {
        while(ReadDirEntry(Dir, FileBuffer, sizeof(FileBuffer), FILETYPE))
        {
            if(!StrEqual(FileBuffer, "") && !StrEqual(FileBuffer, ".") && !StrEqual(FileBuffer, ".."))
            {
                Format(FileBuffer, sizeof(FileBuffer), "%s/%s", Folder, FileBuffer);
                if(FILETYPE == FileType_File)
                {
                    if(FileExists(FileBuffer, true))
                    {
                        char SuffixBuffer[PLATFORM_MAX_PATH];
                        int Dot = FindCharInString(FileBuffer, '.', true);
                        if(Dot == -1)
                        {
                            return;
                        }
                        strcopy(SuffixBuffer, sizeof(SuffixBuffer), FileBuffer[Dot + 1]);
                        for(new i = 0; i < sizeof(Suffix); i++)
                        {
                            if(StrEqual(SuffixBuffer, Suffix[i], false))
                            {
								if(StrContains(FileBuffer,".mdl")!=-1){
									PrintToServer(FileBuffer);
									PrecacheModel(FileBuffer, true);
								}
                                AddFileToDownloadsTable(FileBuffer);
                                break;
                            }
                        }
                    }
                }
                else if(FILETYPE == FileType_Directory)
                {
                    DownloadFolder(FileBuffer);
                }
            }
        }
        CloseHandle(Dir);
    }
}