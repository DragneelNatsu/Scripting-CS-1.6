#include <amxmodx>

#define Autor "Natsu"
#define Versiune "1.1"
#define Nume "Leader Board"

new cvar_on, cvar_tag, cvar_show, cvar_hudcolor, cvar_hudposition
new TaG[8], r, kills[32], HasALeader = 0, bool:Something, Count = 0, OldMaxKills = 0, OldMaxKillsID = 0, rMaxKills = 0,
rMaxKillsID = 0, SyncShowLeader

public plugin_init(){
	register_plugin(Nume, Versiune, Autor)
	
	register_dictionary("score_leader.txt")
	
	register_event("HLTV", "NewRoundEvent", "a", "1=0", "2=0")
	
	cvar_tag = register_cvar("leader_board_tag", "Leader")
	cvar_on = register_cvar("leader_board", "1")
	cvar_show = register_cvar("leader_board_show", "1")
	cvar_hudcolor = register_cvar("leader_board_hudcolor", "255 170 0")
	cvar_hudposition = register_cvar("leader_board_hudposition", "0.05 -1.0")
	
	get_pcvar_string(cvar_tag, TaG, charsmax(TaG))
	
	SyncShowLeader = CreateHudSyncObj()
	
	set_task(0.5, "rLeaderCheckTask", _, _, _, "b", 0)
}

public rLeaderCheckTask(){
	if(get_pcvar_num(cvar_on) == 0){
		return PLUGIN_HANDLED
	}
	
	new rPlayers[32], rNum, rPID
	get_players(rPlayers, rNum)
	
	if(get_user_frags(rMaxKillsID) == 0){
		if(!is_user_connected(rMaxKillsID)){
			OldMaxKills = 0
			OldMaxKillsID = 0
			rMaxKills = 0
			rMaxKillsID = 0
			
			if(Count > 0)ColorChatAlpha(0, "%L", LANG_PLAYER, "DISCONNECTED", TaG)
			
			Count = 0
		}
		OldMaxKills = 0
		OldMaxKillsID = 0
		rMaxKills = 0
		rMaxKillsID = 0
		
		if(Count > 0)ColorChatAlpha(0, "%L", LANG_PLAYER, "RESET_SCORE", TaG)
		
		Count = 0
	}
	
	for(r = 0;r < rNum;r++){
		rPID = rPlayers[r]
		kills[rPID] = get_user_frags(rPID)
		
		if(Count == 0){
			if(get_user_frags(rPID) == 0){
				Something = false
			}
			else {
				Something = true
				Count++
			}
		}
		
		ShowWhosLeader(rPID)
		
		if(kills[rPID] > kills[rMaxKillsID]){
			rMaxKillsID = rPID
			rMaxKills = kills[rMaxKillsID]
		}
	}
	
	if(!Something)return PLUGIN_HANDLED
	
	CheckLeader(rMaxKillsID)
	
	return PLUGIN_HANDLED
}

public CheckLeader(rMaxKillsID){
	if(OldMaxKills == rMaxKills || OldMaxKillsID == rMaxKillsID)
		return
		
	if(rMaxKills > 0 && HasALeader == 0){
		ColorChatAlpha(0, "%L", LANG_PLAYER, "THE_LEADER", TaG, get_pname(rMaxKillsID), kills[rMaxKillsID], kills[rMaxKillsID] == 1 ? "" : "s", get_user_deaths(rMaxKillsID), get_user_deaths(rMaxKillsID) == 1 ? "" : "s")
		HasALeader = 1
		OldMaxKills = get_user_frags(rMaxKillsID)
		OldMaxKillsID = rMaxKillsID
	}
	else if(rMaxKills > 0 && HasALeader == 1){
		ColorChatAlpha(0, "%L", LANG_PLAYER, "THE_NEW_LEADER", TaG, get_pname(rMaxKillsID), kills[rMaxKillsID], kills[rMaxKillsID] == 1 ? "" : "s", get_user_deaths(rMaxKillsID), get_user_deaths(rMaxKillsID) == 1 ? "" : "s")
		OldMaxKills = rMaxKills
		OldMaxKillsID = rMaxKillsID
	}
}

public ShowWhosLeader(id){
	if(get_pcvar_num(cvar_show) == 1){
		static hud_red, hud_green, hud_blue, Float:hud_x, Float:hud_y

		new color[16], red[4], green[4], blue[4], position[19], positionX[6], positionY[6]
		get_pcvar_string(cvar_hudcolor, color, 15)
		get_pcvar_string(cvar_hudposition, position, 18)
		parse(color, red, 3, green, 3, blue, 3)
		parse(position, positionX, 6, positionY, 6)
			
		hud_red = str_to_num(red)
		hud_green = str_to_num(green)
		hud_blue = str_to_num(blue)
		hud_x = str_to_float(positionX)
		hud_y = str_to_float(positionY)
	
		if(!Something){
			set_hudmessage(hud_red, hud_green, hud_blue, hud_x, hud_y, 0, 0.5, 0.5)
			ShowSyncHudMsg(id, SyncShowLeader, "[The Leader]^n%s", "Still no Leader")
		}
		else {
			set_hudmessage(hud_red, hud_green, hud_blue, hud_x, hud_y, 0, 0.5, 0.5)
			ShowSyncHudMsg(id, SyncShowLeader, "[The Leader]^n%s", get_pname(rMaxKillsID))
		}
	}
}

public NewRoundEvent(id){
	if(get_pcvar_num(cvar_show) == 2){
		if(!Something){
			ColorChatAlpha(id, "%L", LANG_PLAYER, "STILL_NO_LEADER2", TaG)
		}
		else {
			ColorChatAlpha(id, "%L", LANG_PLAYER, "CURRENT_LEADER", TaG, get_pname(rMaxKillsID))
		}
	}
}

stock get_pname(index){
	new rName[32]
	get_user_name(index, rName, charsmax(rName))
	
	return rName
}

stock ColorChatAlpha(index, const text[], any:...){
	new MaxPlayers, MsgSayText
	static Msg[128]
	vformat(Msg, sizeof(Msg) - 1, text, 3)

	replace_all(Msg, sizeof(Msg) - 1, "!g", "^x04")
	replace_all(Msg, sizeof(Msg) - 1, "!n", "^x01")
	replace_all(Msg, sizeof(Msg) - 1, "!t", "^x03")
	
	MaxPlayers = get_maxplayers()
	MsgSayText = get_user_msgid("SayText")

	if(!index){
		for(new i = 0; i < MaxPlayers; i++){
			if(!is_user_connected(i))
				continue;
				
			message_begin(MSG_ONE_UNRELIABLE, MsgSayText, _, i)
			write_byte(i)
			write_string(Msg)
			message_end()
		}		
	}
}
