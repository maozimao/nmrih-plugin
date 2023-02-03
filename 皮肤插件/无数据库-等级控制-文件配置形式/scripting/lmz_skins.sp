#include <sdktools>
#include <sourcemod>

Handle db;
Handle playerDb;
static char KVPath[PLATFORM_MAX_PATH];
static char PLAYERPath[PLATFORM_MAX_PATH];
bool bTPView[MAXPLAYERS+1];

enum struct UserInfo{
	int client;
	char userName[128];
	char steamId[32];
	int lv;
	char lostModelPath[128];
}

UserInfo users[10];

public Plugin myinfo = {
	name = "皮肤插件",
	author = "老毛子",
	description = "管理皮肤插件",
	version = "1.0.0",
	url = "QQ群576311971"
}

public void OnPluginStart(){
	RegConsoleCmd("sm_model", Cmd_Model);
	RegConsoleCmd("sm_models", Cmd_Model);
	HookEvent("player_spawn", PlayerSpawn);
}

public void PlayerSpawn(Event event, const char[] name, bool dontBroadcast){
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(!StrEqual(users[client].lostModelPath,"NULL")&&FileExists(users[client].lostModelPath, true)){
		SetEntityModel(client,users[client].lostModelPath);
	}
	if (GetEntProp(client, Prop_Send, "m_iObserverMode") == 1) {
		bTPView[client] = false;
		ToggleView(client);
	}
}

public void OnClientPostAdminCheck(int client){
	char clientName[MAX_NAME_LENGTH],steamId[32];
	GetClientName(client,clientName,sizeof(clientName));
	GetClientAuthId(client,AuthId_SteamID64,steamId,sizeof(steamId));
	users[client].userName = clientName;
	users[client].steamId = steamId;
	if(KvJumpToKey(playerDb,steamId,false)){
		users[client].lv = KvGetNum(playerDb,"lv",1);
		char path[128];
		KvGetString(playerDb,"path",path,sizeof(path),"NULL");
		users[client].lostModelPath = path;
		KvRewind(playerDb);
		KeyValuesToFile(playerDb,PLAYERPath);
	}else{
		if(KvJumpToKey(playerDb,steamId,true)){
			KvSetNum(playerDb,"lv",1);
			KvSetString(playerDb,"path","NULL");
			KvSetString(playerDb,"name",clientName);
			KvRewind(playerDb);
			KeyValuesToFile(playerDb,PLAYERPath);
		}
	}
}

public void OnMapStart(){
	DownloadFolder("models");
	DownloadFolder("materials");
	LoadFile();
	for(int client = 0; client < 10; client++){
		users[client].client = client;
		users[client].userName = "";
		users[client].steamId = "";
		users[client].lv = 1;
		users[client].lostModelPath = "NULL";
	}
}

public void OnMapEnd(){
	CloneHandle(db);
	CloseHandle(playerDb);
}

public void LoadFile(){
	db = CreateKeyValues("Skins");
	BuildPath(Path_SM, KVPath, sizeof(KVPath), "configs/nmrih_skins/skins_menu.ini");
	FileToKeyValues(db, KVPath);
	
	playerDb = CreateKeyValues("Items");
	BuildPath(Path_SM, PLAYERPath, sizeof(PLAYERPath), "configs/nmrih_skins/skins_player.ini");
	FileToKeyValues(playerDb, PLAYERPath);
}

public Action Cmd_Model(int client, int args){
	CreateInitMenu(client);
}

public void CreateInitMenu(int client){
	Handle menu  = CreateMenu(MainMenuCallback, MENU_ACTIONS_ALL);
	SetMenuTitle(menu,"皮肤列表");
	AddMenuItem(menu,"1","专属皮肤");
	AddMenuItem(menu,"2","免费皮肤");
	SetMenuPagination(menu,9);
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
	if(!KvGotoFirstSubKey(db)) return;
	char path[128],lv[2],modelName[32],title[130];
	KvJumpToKey(db, "ItemList");
	KvGotoFirstSubKey(db);
	
	Handle menu = CreateMenu(SelectPageCallback,MENU_ACTIONS_ALL);
	SetMenuTitle(menu,"皮肤列表");
	do{
		KvGetString(db, "path", path, sizeof(path),"");
		KvGetString(db, "lv", lv, sizeof(lv),"");
		KvGetSectionName(db, modelName, sizeof(modelName));
		Format(title,sizeof(title),"%s--%s",lv,path)
		if(value == 1 && StringToInt(lv) > value){
			if(FileExists(path, true)){
				AddMenuItem(menu,title,modelName);
			}
		}else if(value == 2){
			if(StringToInt(lv) == 1){
				if(FileExists(path, true)){
					AddMenuItem(menu,title,modelName);
				}
			}
		}
	}while(KvGotoNextKey(db));
	KvRewind(db);
	SetMenuPagination(menu,9);
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
			char item[128],tempstr[2][130];
			GetMenuItem(menu,Position,item,sizeof(item));
			ExplodeString(item,"--",tempstr,2,130);
			if(users[client].lv >= StringToInt(tempstr[0])){
				SetEntityModel(client,tempstr[1]);
				if(KvJumpToKey(playerDb,users[client].steamId)){
					KvSetString(playerDb,"path",tempstr[1]);
					KvRewind(playerDb);
					KeyValuesToFile(playerDb,PLAYERPath);
				}
			}else{
				PrintToChat(client,"\x07FF0000你的专属等级不够 \x04");
			}
			CreateInitMenu(client);
		}
		case MenuAction_Cancel: {
			if(Position == MenuCancel_ExitBack){
				CreateInitMenu(client);
			}else{
				bTPView[client] = false;
				ToggleView(client);
			}
		}
		case MenuAction_End: CloseHandle(menu);
	}
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

stock bool IsValidClient(int client){
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
