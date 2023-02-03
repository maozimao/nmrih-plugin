#include <sourcemod>
#include <sdktools>

public Plugin myinfo ={
	name = "永久扳人插件升级为菜单栏版本",
	author = "花茶苑-老毛子",
	description = "<- 扳人插件 ->",
	version = "2.0.0",
	url = "<- QQ群576311971 ->"
}

Database DB;

public OnPluginStart(){
	if(!SQL_CheckConfig("banren")) SetFailState("数据库配置错误");
	Database.Connect(DbConnectCallback, "banren");
	RegAdminCmd("sm_banuser",BanUser,ADMFLAG_SLAY,"永久封禁玩家");
}

void DbConnectCallback(Database db, const char[] error, any data){
	if(!db) SetFailState("数据库连接失败: %s", error);
	db.SetCharset("utf8");
	DB = db;
	PrintToServer("数据库连接成功");
}

public OnClientPostAdminCheck(int client){
	char steamid[32],query[200];
	GetClientAuthId(client,AuthId_SteamID64,steamid,sizeof(steamid));
	Format(query,sizeof(query),"SELECT user_name,steamid FROM ban_user WHERE steamid = '%s'",steamid);
	DB.Query(KickBack,query,client);
}

void KickBack(Database db, DBResultSet result, char[] error, any client){
	if(result.FetchRow()){
		KickClient(client,"你已被永久封禁!");
	}
}

public Action BanUser(client,args){
	char item[2],clientName[256];
	Handle menu = CreateMenu(PlayMenu);
	SetMenuTitle(menu,"永久封禁谨慎使用");
	for(int id = 1;id <= 9;id++){
		if(IsClientConnected(id)){
			IntToString(id,item,sizeof(item))
			GetClientName(id,clientName,sizeof(clientName));
			AddMenuItem(menu,item,clientName);
		}
	}
	SetMenuPagination(menu,9);
	DisplayMenu(menu,client,30);
}

public PlayMenu(Handle menu,MenuAction action,client,Position){
	if(action == MenuAction_Select){
		char item[2];
		GetMenuItem(menu,Position,item,sizeof(item));
		char targetId[32],targetName[256],adminId[32],adminName[256];
		GetClientName(StringToInt(item),targetName,sizeof(targetName));
		GetClientAuthId(StringToInt(item),AuthId_SteamID64,targetId,sizeof(targetId));
		GetClientAuthId(client,AuthId_SteamID64,adminId,sizeof(adminId));
		GetClientName(client,adminName,sizeof(adminName));
		char insert[256];
		Format(insert,sizeof(insert),"INSERT INTO ban_user (user_name,steamid,admin_steamid) VALUES ('%s','%s','%s')",targetName,targetId,adminId)
		int tkId = StringToInt(item);
		DB.Query(BanBack, insert, tkId);
	}else if(action == MenuAction_End){
		CloseHandle(menu);
	}
}

void BanBack(Database db, DBResultSet result, char[] error, any tkId){
	PrintToChatAll("[系统]玩家- %N -被管理员永久封禁!",tkId);
	KickClient(tkId,"你已被永久封禁!");
}
//"DELETE FROM ban_user WHERE steamid = '%s'"
