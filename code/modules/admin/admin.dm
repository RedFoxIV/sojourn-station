
var/global/BSACooldown = 0
var/global/floorIsLava = 0


////////////////////////////////
/proc/message_admins(var/msg)
	lobby_message(message = msg, color = "#FFA500")
	msg = "<span class=\"log_message\"><span class=\"prefix\">ADMIN LOG:</span> <span class=\"message\">[msg]</span></span>"
	log_adminwarn(msg)
	for(var/client/C in admins)
		if(R_ADMIN & C.holder.rights)
			to_chat(C, msg)

/proc/msg_admin_attack(var/text) //Toggleable Attack Messages
	log_attack(text)
	var/rendered = "<span class=\"log_message\"><span class=\"prefix\">ATTACK:</span> <span class=\"message\">[text]</span></span>"
	lobby_message(message = text, color = "#FFA500")
	for(var/client/C in admins)
		if(R_ADMIN & C.holder.rights)
			if(C.get_preference_value(/datum/client_preference/staff/show_attack_logs) == GLOB.PREF_SHOW)
				var/msg = rendered
				to_chat(C, msg)

proc/admin_notice(var/message, var/rights)
	for(var/mob/M in SSmobs.mob_list)
		if(check_rights(rights, 0, M))
			to_chat(M, message)

// Not happening.
/datum/admins/SDQL_update(var/const/var_name, var/new_value)
	return 0


///////////////////////////////////////////////////////////////////////////////////////////////Panels

/datum/admins/proc/view_log_panel(mob/M)
	if(!M)
		to_chat(usr, "That mob doesn't seem to exist! Something went wrong.")
		return

	if (!istype(src, /datum/admins))
		src = usr.client.holder
	if (!istype(src, /datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return

	var/body = "<html><head><title>Log Panel of [M.real_name]</title></head>"
	body += "<body><center>Logs of <b>[M]</b><br>"
	body += "<a href='?src=\ref[src];viewlogs=\ref[M]'>REFRESH</a></center><br>"


	var/i = length(M.attack_log)
	while(i > 0)
		body += M.attack_log[i] + "<br>"
		i--

	usr << browse(body, "window=\ref[M]logs;size=500x500")




ADMIN_VERB_ADD(/datum/admins/proc/show_player_panel, null, TRUE)
//shows an interface for individual players, with various links (links require additional flags
/datum/admins/proc/show_player_panel(var/mob/M in SSmobs.mob_list)
	set category = null
	set name = "Show Player Panel"
	set desc = "Edit player (respawn, ban, heal, etc)"

	if(!M)
		to_chat(usr, "You seem to be selecting a mob that doesn't exist anymore.")
		return
	if (!istype(src, /datum/admins))
		src = usr.client.holder
	if (!istype(src, /datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return

	var/body = "<meta charset=UTF-8><html><head><title>Опции для [M.key]</title></head>"
	body += "<body>Панель опций для <b>[M]</b>"

	if(M.client)
		body += " за которого играет <b><a href='http://byond.com/members/[M.client.ckey]'>[M.client]</b></a> "
		body += "\[<A href='?src=\ref[src];editrights=show'>[M.client.holder ? M.client.holder.rank : "Игрок"]</A>\]<br>"
		body += "<b>Дата регистрации:</b> [M.client.registration_date ? M.client.registration_date : "Неизвестно"]<br>"
		body += "<b>IP:</b> [M.client.address ? M.client.address : "Неизвестно"]<br>"

		var/country = M.client.country
		var/country_code = M.client.country_code
		if(country && country_code)
			// TODO (28.07.17): uncomment after flag icons resize
			// <img src=\"flag_[country_code].png\">
			// usr << browse_rsc(icon('icons/country_flags.dmi', country_code), "flag_[country_code].png")
			body += "<b>Страна:</b> [country]<br><br>"


	if(isnewplayer(M))
		body += " <B>Ещё не в игре</B> "
	else
		body += " \[<A href='?src=\ref[src];revive=\ref[M]'>Лечить</A>\] "

	body += {"
		<br><br>\[
		<a href='?_src_=vars;Vars=\ref[M]'>VV</a> -
		<a href='?src=\ref[src];traitor=\ref[M]'>TP</a> -
		<a href='?src=\ref[usr];priv_msg=\ref[M]'>PM</a> -
		<a href='?src=\ref[src];subtlemessage=\ref[M]'>SM</a> -
		[admin_jump_link(M, src)] -
		<a href='?src=\ref[src];viewlogs=\ref[M]'>LOGS</a>\] <br>
		<b>Тип моба</b> = [M.type]<br><br>
		<A href='?src=\ref[src];boot2=\ref[M]'>Кикнуть</A> |
		<A href='?_src_=holder;warn=[M.ckey]'>Варн</A> |
		<A href='?src=\ref[src];newban=\ref[M]'>Бан</A> |
		<A href='?src=\ref[src];jobban2=\ref[M]'>Джоббан</A> |
		<A href='?src=\ref[src];notes=show;mob=\ref[M]'>Заметки</A> |
		<A href='?src=\ref[src];adminpmhistory=\ref[M]'>История Сообщений Админа</A>
	"}

	if(M.client)
		var/muted = M.client.prefs.muted
		body += {"<br><b>Мут: </b>
			\[<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_IC]'><font color='[(muted & MUTE_IC)?"red":"blue"]'>IC</font></a> |
			<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_OOC]'><font color='[(muted & MUTE_OOC)?"red":"blue"]'>OOC</font></a> |
			<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_PRAY]'><font color='[(muted & MUTE_PRAY)?"red":"blue"]'>PRAY</font></a> |
			<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_ADMINHELP]'><font color='[(muted & MUTE_ADMINHELP)?"red":"blue"]'>ADMINHELP</font></a> |
			<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_DEADCHAT]'><font color='[(muted & MUTE_DEADCHAT)?"red":"blue"]'>DEADCHAT</font></a>\]
			(<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_ALL]'><font color='[(muted & MUTE_ALL)?"red":"blue"]'>переключить всё</font></a>)
		"}

	body += {"<br><br>
		<A href='?src=\ref[src];jumpto=\ref[M]'><b>Jump to</b></A> |
		<A href='?src=\ref[src];getmob=\ref[M]'>Get</A>
		<br><br>
		[check_rights(R_ADMIN|R_MOD,0) ? "<A href='?src=\ref[src];traitor=\ref[M]'>Панель спец.ролей</A> | " : "" ]
		<A href='?src=\ref[src];narrateto=\ref[M]'>Narrate to</A> |
		<A href='?src=\ref[src];subtlemessage=\ref[M]'>Subtle message</A>
	"}

	if (M.client)
		if(!isnewplayer(M))
			body += "<br><br>"
			body += "<b>Трансформация:</b>"
			body += "<br>"

			//Monkey
			if(issmall(M))
				body += "<B>Уже мартышка</B> | "
			else
				body += "<A href='?src=\ref[src];monkeyone=\ref[M]'>Манкизировать</A> | "

			//Corgi
			if(iscorgi(M))
				body += "<B>Corgized</B> | "
			else
				body += "<A href='?src=\ref[src];corgione=\ref[M]'>Коргизировать</A> | "

			//AI / Cyborg
			if(isAI(M))
				body += "<B>Это ИИ</B> "
			else if(ishuman(M))
				body += {"<A href='?src=\ref[src];makeai=\ref[M]'>Сделать ИИ</A> |
					<A href='?src=\ref[src];makerobot=\ref[M]'>Сделать Роботом</A> |
					<A href='?src=\ref[src];makealien=\ref[M]'>Сделать Чужим</A> |
					<A href='?src=\ref[src];makeslime=\ref[M]'>Сделать Слизнем</A>
				"}

			//Simple Animals
			if(isanimal(M))
				body += "<A href='?src=\ref[src];makeanimal=\ref[M]'>Переживотничать</A> | "
			else
				body += "<A href='?src=\ref[src];makeanimal=\ref[M]'>Животное</A> | "

			// DNA2 - Admin Hax
			if(M.dna && iscarbon(M))
				body += "<br><br>"
				body += "<b>Блоки ДНК:</b><br><table border='0'><tr><th>&nbsp;</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th>"
				var/bname
				for(var/block=1;block<=DNA_SE_LENGTH;block++)
					if(((block-1)%5)==0)
						body += "</tr><tr><th>[block-1]</th>"
					bname = assigned_blocks[block]
					body += "<td>"
					if(bname)
						var/bstate=M.dna.GetSEState(block)
						var/bcolor="[(bstate)?"#006600":"#ff0000"]"
						body += "<A href='?src=\ref[src];togmutate=\ref[M];block=[block]' style='color:[bcolor];'>[bname]</A><sub>[block]</sub>"
					else
						body += "[block]"
					body+="</td>"
				body += "</tr></table>"

			body += {"<br><br>
				<b>Рудиментарная трансформация:</b><br>
				<A href='?src=\ref[src];simplemake=observer;mob=\ref[M]'>Наблюдатель</A> |
				<A href='?src=\ref[src];simplemake=angel;mob=\ref[M]'>АНГЕЛ</A> |
				\[ Xenos: <A href='?src=\ref[src];simplemake=larva;mob=\ref[M]'>Лярва</A>
				<A href='?src=\ref[src];simplemake=human;species=Xenomorph Drone;mob=\ref[M]'>Дрон</A>
				<A href='?src=\ref[src];simplemake=human;species=Xenomorph Hunter;mob=\ref[M]'>Охотник</A>
				<A href='?src=\ref[src];simplemake=human;species=Xenomorph Sentinel;mob=\ref[M]'>Sentinel</A>
				<A href='?src=\ref[src];simplemake=human;species=Xenomorph Queen;mob=\ref[M]'>Королева</A> \] |
				\[ Экипаж: <A href='?src=\ref[src];simplemake=human;mob=\ref[M]'>Человек</A>
				<A href='?src=\ref[src];simplemake=nymph;mob=\ref[M]'>Нимфа</A>
				\[ слизень: <A href='?src=\ref[src];simplemake=slime;mob=\ref[M]'>Ребенок</A>,
				<A href='?src=\ref[src];simplemake=adultslime;mob=\ref[M]'>Взрослый</A> \]
				<A href='?src=\ref[src];simplemake=monkey;mob=\ref[M]'>Обезьяна</A> |
				<A href='?src=\ref[src];simplemake=robot;mob=\ref[M]'>Киборг</A> |
				<A href='?src=\ref[src];simplemake=cat;mob=\ref[M]'>Кошка</A> |
				<A href='?src=\ref[src];simplemake=runtime;mob=\ref[M]'>Рантайм</A> |
				<A href='?src=\ref[src];simplemake=corgi;mob=\ref[M]'>Корги</A> |
				<A href='?src=\ref[src];simplemake=ian;mob=\ref[M]'>Йан</A> |
				<A href='?src=\ref[src];simplemake=crab;mob=\ref[M]'>Краб</A> |
				<A href='?src=\ref[src];simplemake=coffee;mob=\ref[M]'>Коффи</A> |
				\[ Конструктор: <A href='?src=\ref[src];simplemake=constructarmoured;mob=\ref[M]'>Бронированный</A> ,
				<A href='?src=\ref[src];simplemake=constructbuilder;mob=\ref[M]'>Строитель</A> ,
				<A href='?src=\ref[src];simplemake=constructwraith;mob=\ref[M]'>Жнец</A> \]
				<A href='?src=\ref[src];simplemake=shade;mob=\ref[M]'>Тень</A>
				<br>
			"}
	body += {"<br><br>
			<b>Другие действия:</b>
			<br>
			<A href='?src=\ref[src];forcespeech=\ref[M]'>Заставить сказать</A>
			"}
	body += "<br><br><b>Языки:</b><br>"
	var/f = 1
	for(var/k in all_languages)
		var/datum/language/L = all_languages[k]
		if(!(L.flags & INNATE))
			if(!f) body += " | "
			else f = 0
			if(L in M.languages)
				body += "<a href='?src=\ref[src];toglang=\ref[M];lang=[html_encode(k)]' style='color:#006600'>[k]</a>"
			else
				body += "<a href='?src=\ref[src];toglang=\ref[M];lang=[html_encode(k)]' style='color:#ff0000'>[k]</a>"

	body += {"<br>
		</body></html>
	"}

	usr << browse(body, "window=adminplayeropts;size=550x515")



/datum/player_info/var/author // admin who authored the information
/datum/player_info/var/rank //rank of admin who made the notes
/datum/player_info/var/content // text content of the information
/datum/player_info/var/timestamp // Because this is bloody annoying

ADMIN_VERB_ADD(/datum/admins/proc/access_news_network, R_ADMIN, FALSE)
//allows access of newscasters
/datum/admins/proc/access_news_network() //MARKER
	set category = "Fun"
	set name = "Access Newscaster Network"
	set desc = "Allows you to view, add and edit news feeds."

	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return
	var/dat
	dat = text("<HEAD><TITLE>Admin Newscaster</TITLE></HEAD><H3>Admin Newscaster Unit</H3>")

	switch(admincaster_screen)
		if(0)
			dat += {"Welcome to the admin newscaster.<BR> Here you can add, edit and censor every newspiece on the network.
				<BR>Feed channels and stories entered through here will be uneditable and handled as official news by the rest of the units.
				<BR>Note that this panel allows full freedom over the news network, there are no constrictions except the few basic ones. Don't break things!
			"}
			if(news_network.wanted_issue)
				dat+= "<HR><A href='?src=\ref[src];admincaster=view_wanted'>Read Wanted Issue</A>"

			dat+= {"<HR><BR><A href='?src=\ref[src];admincaster=create_channel'>Create Feed Channel</A>
				<BR><A href='?src=\ref[src];admincaster=view'>View Feed Channels</A>
				<BR><A href='?src=\ref[src];admincaster=create_feed_story'>Submit new Feed story</A>
				<BR><BR><A href='?src=\ref[usr];mach_close=newscaster_main'>Exit</A>
			"}

			var/wanted_already = 0
			if(news_network.wanted_issue)
				wanted_already = 1

			dat+={"<HR><B>Feed Security functions:</B><BR>
				<BR><A href='?src=\ref[src];admincaster=menu_wanted'>[(wanted_already) ? ("Manage") : ("Publish")] \"Wanted\" Issue</A>
				<BR><A href='?src=\ref[src];admincaster=menu_censor_story'>Censor Feed Stories</A>
				<BR><A href='?src=\ref[src];admincaster=menu_censor_channel'>Mark Feed Channel with [company_name] D-Notice (disables and locks the channel.</A>
				<BR><HR><A href='?src=\ref[src];admincaster=set_signature'>The newscaster recognises you as:<BR> <span class='green'>[src.admincaster_signature]</span></A>
			"}
		if(1)
			dat+= "Station Feed Channels<HR>"
			if( isemptylist(news_network.network_channels) )
				dat+="<I>No active channels found...</I>"
			else
				for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
					if(CHANNEL.is_admin_channel)
						dat+="<B><FONT style='BACKGROUND-COLOR: LightGreen'><A href='?src=\ref[src];admincaster=show_channel;show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A></FONT></B><BR>"
					else
						dat+="<B><A href='?src=\ref[src];admincaster=show_channel;show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<span class='warning'>***</font>") : null]<BR></B>"
			dat+={"<BR><HR><A href='?src=\ref[src];admincaster=refresh'>Refresh</A>
				<BR><A href='?src=\ref[src];admincaster=setScreen;setScreen=[0]'>Back</A>
			"}

		if(2)
			dat+={"
				Creating new Feed Channel...
				<HR><B><A href='?src=\ref[src];admincaster=set_channel_name'>Channel Name</A>:</B> [src.admincaster_feed_channel.channel_name]<BR>
				<B><A href='?src=\ref[src];admincaster=set_signature'>Channel Author</A>:</B> <span class='green'>[src.admincaster_signature]</span><BR>
				<B><A href='?src=\ref[src];admincaster=set_channel_lock'>Will Accept Public Feeds</A>:</B> [(src.admincaster_feed_channel.locked) ? ("NO") : ("YES")]<BR><BR>
				<BR><A href='?src=\ref[src];admincaster=submit_new_channel'>Submit</A><BR><BR><A href='?src=\ref[src];admincaster=setScreen;setScreen=[0]'>Cancel</A><BR>
			"}
		if(3)
			dat+={"
				Creating new Feed Message...
				<HR><B><A href='?src=\ref[src];admincaster=set_channel_receiving'>Receiving Channel</A>:</B> [src.admincaster_feed_channel.channel_name]<BR>" //MARK
				<B>Message Author:</B> <span class='green'>[src.admincaster_signature]</span><BR>
				<B><A href='?src=\ref[src];admincaster=set_new_message'>Message Body</A>:</B> [src.admincaster_feed_message.body] <BR>
				<BR><A href='?src=\ref[src];admincaster=submit_new_message'>Submit</A><BR><BR><A href='?src=\ref[src];admincaster=setScreen;setScreen=[0]'>Cancel</A><BR>
			"}
		if(4)
			dat+={"
					Feed story successfully submitted to [src.admincaster_feed_channel.channel_name].<BR><BR>
					<BR><A href='?src=\ref[src];admincaster=setScreen;setScreen=[0]'>Return</A><BR>
				"}
		if(5)
			dat+={"
				Feed Channel [src.admincaster_feed_channel.channel_name] created successfully.<BR><BR>
				<BR><A href='?src=\ref[src];admincaster=setScreen;setScreen=[0]'>Return</A><BR>
			"}
		if(6)
			dat+="<B><FONT COLOR='maroon'>ERROR: Could not submit Feed story to Network.</B></FONT><HR><BR>"
			if(src.admincaster_feed_channel.channel_name=="")
				dat+="<FONT COLOR='maroon'>Invalid receiving channel name.</FONT><BR>"
			if(src.admincaster_feed_message.body == "" || src.admincaster_feed_message.body == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>Invalid message body.</FONT><BR>"
			dat+="<BR><A href='?src=\ref[src];admincaster=setScreen;setScreen=[3]'>Return</A><BR>"
		if(7)
			dat+="<B><FONT COLOR='maroon'>ERROR: Could not submit Feed Channel to Network.</B></FONT><HR><BR>"
			if(src.admincaster_feed_channel.channel_name =="" || src.admincaster_feed_channel.channel_name == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>Invalid channel name.</FONT><BR>"
			var/check = 0
			for(var/datum/feed_channel/FC in news_network.network_channels)
				if(FC.channel_name == src.admincaster_feed_channel.channel_name)
					check = 1
					break
			if(check)
				dat+="<FONT COLOR='maroon'>Channel name already in use.</FONT><BR>"
			dat+="<BR><A href='?src=\ref[src];admincaster=setScreen;setScreen=[2]'>Return</A><BR>"
		if(9)
			dat+="<B>[src.admincaster_feed_channel.channel_name]: </B><FONT SIZE=1>\[created by: <FONT COLOR='maroon'>[src.admincaster_feed_channel.author]</FONT>\]</FONT><HR>"
			if(src.admincaster_feed_channel.censored)
				dat+={"
					<span class='warning'><B>ATTENTION: </B></font>This channel has been deemed as threatening to the welfare of the station, and marked with a [company_name] D-Notice.<BR>
					No further feed story additions are allowed while the D-Notice is in effect.<BR><BR>
				"}
			else
				if( isemptylist(src.admincaster_feed_channel.messages) )
					dat+="<I>No feed messages found in channel...</I><BR>"
				else
					var/i = 0
					for(var/datum/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
						i++
						dat+="-[MESSAGE.body] <BR>"
						if(MESSAGE.img)
							usr << browse_rsc(MESSAGE.img, "tmp_photo[i].png")
							dat+="<img src='tmp_photo[i].png' width = '180'><BR><BR>"
						dat+="<FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>"
			dat+={"
				<BR><HR><A href='?src=\ref[src];admincaster=refresh'>Refresh</A>
				<BR><A href='?src=\ref[src];admincaster=setScreen;setScreen=[1]'>Back</A>
			"}
		if(10)
			dat+={"
				<B>[company_name] Feed Censorship Tool</B><BR>
				<FONT SIZE=1>NOTE: Due to the nature of news Feeds, total deletion of a Feed Story is not possible.<BR>
				Keep in mind that users attempting to view a censored feed will instead see the \[REDACTED\] tag above it.</FONT>
				<HR>Select Feed channel to get Stories from:<BR>
			"}
			if(isemptylist(news_network.network_channels))
				dat+="<I>No feed channels found active...</I><BR>"
			else
				for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
					dat+="<A href='?src=\ref[src];admincaster=pick_censor_channel;pick_censor_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<span class='warning'>***</font>") : null]<BR>"
			dat+="<BR><A href='?src=\ref[src];admincaster=setScreen;setScreen=[0]'>Cancel</A>"
		if(11)
			dat+={"
				<B>[company_name] D-Notice Handler</B><HR>
				<FONT SIZE=1>A D-Notice is to be bestowed upon the channel if the handling Authority deems it as harmful for the station's
				morale, integrity or disciplinary behaviour. A D-Notice will render a channel unable to be updated by anyone, without deleting any feed
				stories it might contain at the time. You can lift a D-Notice if you have the required access at any time.</FONT><HR>
			"}
			if(isemptylist(news_network.network_channels))
				dat+="<I>No feed channels found active...</I><BR>"
			else
				for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
					dat+="<A href='?src=\ref[src];admincaster=pick_d_notice;pick_d_notice=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<span class='warning'>***</font>") : null]<BR>"

			dat+="<BR><A href='?src=\ref[src];admincaster=setScreen;setScreen=[0]'>Back</A>"
		if(12)
			dat+={"
				<B>[src.admincaster_feed_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[src.admincaster_feed_channel.author]</FONT> \]</FONT><BR>
				<FONT SIZE=2><A href='?src=\ref[src];admincaster=censor_channel_author;censor_channel_author=\ref[src.admincaster_feed_channel]'>[(src.admincaster_feed_channel.author=="\[REDACTED\]") ? ("Undo Author censorship") : ("Censor channel Author")]</A></FONT><HR>
			"}
			if( isemptylist(src.admincaster_feed_channel.messages) )
				dat+="<I>No feed messages found in channel...</I><BR>"
			else
				for(var/datum/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
					dat+={"
						-[MESSAGE.body] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>
						<FONT SIZE=2><A href='?src=\ref[src];admincaster=censor_channel_story_body;censor_channel_story_body=\ref[MESSAGE]'>[(MESSAGE.body == "\[REDACTED\]") ? ("Undo story censorship") : ("Censor story")]</A>  -  <A href='?src=\ref[src];admincaster=censor_channel_story_author;censor_channel_story_author=\ref[MESSAGE]'>[(MESSAGE.author == "\[REDACTED\]") ? ("Undo Author Censorship") : ("Censor message Author")]</A></FONT><BR>
					"}
			dat+="<BR><A href='?src=\ref[src];admincaster=setScreen;setScreen=[10]'>Back</A>"
		if(13)
			dat+={"
				<B>[src.admincaster_feed_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[src.admincaster_feed_channel.author]</FONT> \]</FONT><BR>
				Channel messages listed below. If you deem them dangerous to the station, you can <A href='?src=\ref[src];admincaster=toggle_d_notice;toggle_d_notice=\ref[src.admincaster_feed_channel]'>Bestow a D-Notice upon the channel</A>.<HR>
			"}
			if(src.admincaster_feed_channel.censored)
				dat+={"
					<span class='warning'><B>ATTENTION: </B></font>This channel has been deemed as threatening to the welfare of the station, and marked with a [company_name] D-Notice.<BR>
					No further feed story additions are allowed while the D-Notice is in effect.<BR><BR>
				"}
			else
				if( isemptylist(src.admincaster_feed_channel.messages) )
					dat+="<I>No feed messages found in channel...</I><BR>"
				else
					for(var/datum/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
						dat+="-[MESSAGE.body] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>"

			dat+="<BR><A href='?src=\ref[src];admincaster=setScreen;setScreen=[11]'>Back</A>"
		if(14)
			dat+="<B>Wanted Issue Handler:</B>"
			var/wanted_already = 0
			var/end_param = 1
			if(news_network.wanted_issue)
				wanted_already = 1
				end_param = 2
			if(wanted_already)
				dat+="<FONT SIZE=2><BR><I>A wanted issue is already in Feed Circulation. You can edit or cancel it below.</FONT></I>"
			dat+={"
				<HR>
				<A href='?src=\ref[src];admincaster=set_wanted_name'>Criminal Name</A>: [src.admincaster_feed_message.author] <BR>
				<A href='?src=\ref[src];admincaster=set_wanted_desc'>Description</A>: [src.admincaster_feed_message.body] <BR>
			"}
			if(wanted_already)
				dat+="<B>Wanted Issue created by:</B><span class='green'> [news_network.wanted_issue.backup_author]</span><BR>"
			else
				dat+="<B>Wanted Issue will be created under prosecutor:</B><span class='green'> [src.admincaster_signature]</span><BR>"
			dat+="<BR><A href='?src=\ref[src];admincaster=submit_wanted;submit_wanted=[end_param]'>[(wanted_already) ? ("Edit Issue") : ("Submit")]</A>"
			if(wanted_already)
				dat+="<BR><A href='?src=\ref[src];admincaster=cancel_wanted'>Take down Issue</A>"
			dat+="<BR><A href='?src=\ref[src];admincaster=setScreen;setScreen=[0]'>Cancel</A>"
		if(15)
			dat+={"
				<span class='green'>Wanted issue for [src.admincaster_feed_message.author] is now in Network Circulation.</span><BR><BR>
				<BR><A href='?src=\ref[src];admincaster=setScreen;setScreen=[0]'>Return</A><BR>
			"}
		if(16)
			dat+="<B><FONT COLOR='maroon'>ERROR: Wanted Issue rejected by Network.</B></FONT><HR><BR>"
			if(src.admincaster_feed_message.author =="" || src.admincaster_feed_message.author == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>Invalid name for person wanted.</FONT><BR>"
			if(src.admincaster_feed_message.body == "" || src.admincaster_feed_message.body == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>Invalid description.</FONT><BR>"
			dat+="<BR><A href='?src=\ref[src];admincaster=setScreen;setScreen=[0]'>Return</A><BR>"
		if(17)
			dat+={"
				<B>Wanted Issue successfully deleted from Circulation</B><BR>
				<BR><A href='?src=\ref[src];admincaster=setScreen;setScreen=[0]'>Return</A><BR>
			"}
		if(18)
			dat+={"
				<B><FONT COLOR ='maroon'>-- STATIONWIDE WANTED ISSUE --</B></FONT><BR><FONT SIZE=2>\[Submitted by: <span class='green'>[news_network.wanted_issue.backup_author]</FONT>\]</span><HR>
				<B>Criminal</B>: [news_network.wanted_issue.author]<BR>
				<B>Description</B>: [news_network.wanted_issue.body]<BR>
				<B>Photo:</B>:
			"}
			if(news_network.wanted_issue.img)
				usr << browse_rsc(news_network.wanted_issue.img, "tmp_photow.png")
				dat+="<BR><img src='tmp_photow.png' width = '180'>"
			else
				dat+="None"
			dat+="<BR><A href='?src=\ref[src];admincaster=setScreen;setScreen=[0]'>Back</A><BR>"
		if(19)
			dat+={"
				<span class='green'>Wanted issue for [src.admincaster_feed_message.author] successfully edited.</span><BR><BR>
				<BR><A href='?src=\ref[src];admincaster=setScreen;setScreen=[0]'>Return</A><BR>
			"}
		else
			dat+="I'm sorry to break your immersion. This shit's bugged. Report this bug to Agouri, polyxenitopalidou@gmail.com"

	//world << "Channelname: [src.admincaster_feed_channel.channel_name] [src.admincaster_feed_channel.author]"
	//world << "Msg: [src.admincaster_feed_message.author] [src.admincaster_feed_message.body]"
	usr << browse(dat, "window=admincaster_main;size=400x600")
	onclose(usr, "admincaster_main")



/datum/admins/proc/Jobbans()
	if(!check_rights(R_MOD) && !check_rights(R_ADMIN))
		return

	var/dat = "<B>Job Bans!</B><HR><table>"
	for(var/t in jobban_keylist)
		var/r = t
		if( findtext(r,"##") )
			r = copytext( r, 1, findtext(r,"##") )//removes the description
		dat += text("<tr><td>[t] (<A href='?src=\ref[src];removejobban=[r]'>unban</A>)</td></tr>")
	dat += "</table>"
	usr << browse(dat, "window=ban;size=400x400")

/datum/admins/proc/Game()
	if(!check_rights(0))
		return

	var/dat = "<center><B>Game Panel</B></center><hr>"
	if(get_storyteller() && (SSticker.current_state != GAME_STATE_PREGAME))
		dat += "<A href='?src=\ref[get_storyteller()]'>Storyteller Panel</A><br>"
	else
		dat += "<A href='?src=\ref[src];c_mode=1'>Change Storyteller</A><br>"

	dat += {"
		<BR>
		<A href='?src=\ref[src];create_object=1'>Create Object</A><br>
		<A href='?src=\ref[src];quick_create_object=1'>Quick Create Object</A><br>
		<A href='?src=\ref[src];create_turf=1'>Create Turf</A><br>
		<A href='?src=\ref[src];create_mob=1'>Create Mob</A><br>
		<br><A href='?src=\ref[src];vsc=airflow'>Edit Airflow Settings</A><br>
		<A href='?src=\ref[src];vsc=plasma'>Edit Plasma Settings</A><br>
		<A href='?src=\ref[src];vsc=default'>Choose a default ZAS setting</A><br>
		"}

	usr << browse(dat, "window=admin2;size=210x280")
	return

/datum/admins/proc/Secrets()
	if(!check_rights(0))
		return

	var/dat = "<B>The first rule of adminbuse is: you don't talk about the adminbuse.</B><HR>"
	for(var/datum/admin_secret_category/category in admin_secrets.categories)
		if(!category.can_view(usr))
			continue
		dat += "<B>[category.name]</B><br>"
		if(category.desc)
			dat += "<I>[category.desc]</I><BR>"
		for(var/datum/admin_secret_item/item in category.items)
			if(!item.can_view(usr))
				continue
			dat += "<A href='?src=\ref[src];admin_secrets=\ref[item]'>[item.name()]</A><BR>"
		dat += "<BR>"
	usr << browse(dat, "window=secrets")
	return



/////////////////////////////////////////////////////////////////////////////////////////////////admins2.dm merge
//i.e. buttons/verbs


ADMIN_VERB_ADD(/datum/admins/proc/restart, R_SERVER, FALSE)
/datum/admins/proc/restart()
	set category = "Server"
	set name = "Restart"
	set desc="Restarts the world"
	if (!usr.client.holder)
		return
	var/confirm = alert("Restart the game world?", "Restart", "Yes", "Cancel")
	if(confirm == "Cancel")
		return
	if(confirm == "Yes")
		to_chat(world, "<span class='danger'>Restarting world!</span> <span class='notice'>Initiated by [usr.client.holder.fakekey ? "Admin" : usr.key]!</span>")
		log_admin("[key_name(usr)] initiated a reboot.")


		sleep(50)
		world.Reboot()


ADMIN_VERB_ADD(/datum/admins/proc/announce, R_ADMIN, FALSE)
//priority announce something to all clients.
/datum/admins/proc/announce()
	set category = "Special Verbs"
	set name = "Announce"
	set desc="Announce your desires to the world"
	if(!check_rights(0))
		return

	var/message = input("Global message to send:", "Admin Announce", null, null) as message
	if(message)
		if(!check_rights(R_SERVER,0))
			message = sanitize(message, 500, extra = 0)
		message = replacetext(message, "\n", "<br>") // required since we're putting it in a <p> tag
		to_chat(world, "<span class=notice><b>[usr.client.holder.fakekey ? "Administrator" : usr.key] Announces:</b><p style='text-indent: 50px'>[message]</p></span>")
		log_admin("Announce: [key_name(usr)] : [message]")


ADMIN_VERB_ADD(/datum/admins/proc/toggleooc, R_ADMIN, FALSE)
//toggles ooc on/off for everyone
/datum/admins/proc/toggleooc()
	set category = "Server"
	set desc="Globally Toggles OOC"
	set name="Toggle OOC"

	if(!check_rights(R_ADMIN))
		return

	config.ooc_allowed = !(config.ooc_allowed)
	if (config.ooc_allowed)
		to_chat(world, "<B>The OOC channel has been globally enabled!</B>")
	else
		to_chat(world, "<B>The OOC channel has been globally disabled!</B>")
	log_and_message_admins("toggled OOC.")

ADMIN_VERB_ADD(/datum/admins/proc/togglelooc, R_ADMIN, FALSE)
//toggles looc on/off for everyone
/datum/admins/proc/togglelooc()
	set category = "Server"
	set desc="Globally Toggles LOOC"
	set name="Toggle LOOC"

	if(!check_rights(R_ADMIN))
		return

	config.looc_allowed = !(config.looc_allowed)
	if (config.looc_allowed)
		to_chat(world, "<B>The LOOC channel has been globally enabled!</B>")
	else
		to_chat(world, "<B>The LOOC channel has been globally disabled!</B>")
	log_and_message_admins("toggled LOOC.")


ADMIN_VERB_ADD(/datum/admins/proc/toggledsay, R_ADMIN, FALSE)
//toggles dsay on/off for everyone
/datum/admins/proc/toggledsay()
	set category = "Server"
	set desc="Globally Toggles DSAY"
	set name="Toggle DSAY"

	if(!check_rights(R_ADMIN))
		return

	config.dsay_allowed = !(config.dsay_allowed)
	if (config.dsay_allowed)
		to_chat(world, "<B>Deadchat has been globally enabled!</B>")
	else
		to_chat(world, "<B>Deadchat has been globally disabled!</B>")
	log_admin("[key_name(usr)] toggled deadchat.")
	message_admins("[key_name_admin(usr)] toggled deadchat.", 1)

ADMIN_VERB_ADD(/datum/admins/proc/toggleoocdead, R_ADMIN, FALSE)
//toggles ooc on/off for everyone who is dead
/datum/admins/proc/toggleoocdead()
	set category = "Server"
	set desc="Toggle Dead OOC."
	set name="Toggle Dead OOC"

	if(!check_rights(R_ADMIN))
		return

	config.dooc_allowed = !( config.dooc_allowed )
	log_admin("[key_name(usr)] toggled Dead OOC.")
	message_admins("[key_name_admin(usr)] toggled Dead OOC.", 1)


ADMIN_VERB_ADD(/datum/admins/proc/startnow, R_SERVER, FALSE)
/datum/admins/proc/startnow()
	set category = "Server"
	set desc="Start the round RIGHT NOW"
	set name="Start Now"
	if(SSticker.current_state <= GAME_STATE_PREGAME)
		SSticker.start_immediately = TRUE
		log_admin("[usr.key] has started the game.")
		var/msg = ""
		if(SSticker.current_state == GAME_STATE_STARTUP)
			msg = " (The server is still setting up, but the round will be \
				started as soon as possible.)"
		message_admins("<font color='blue'>\
			[usr.key] has started the game.[msg]</font>")
	else
		to_chat(usr, "<span class='warning'>Error: Start Now: Game has already started.</font>")

ADMIN_VERB_ADD(/datum/admins/proc/toggleenter, R_ADMIN, FALSE)
//toggles whether people can join the current game
/datum/admins/proc/toggleenter()
	set category = "Server"
	set desc="People can't enter"
	set name="Toggle Entering"
	config.enter_allowed = !(config.enter_allowed)
	if (!(config.enter_allowed))
		to_chat(world, "<B>New players may no longer enter the game.</B>")
	else
		to_chat(world, "<B>New players may now enter the game.</B>")
	log_admin("[key_name(usr)] toggled new player game entering.")
	message_admins("\blue [key_name_admin(usr)] toggled new player game entering.", 1)
	world.update_status()


ADMIN_VERB_ADD(/datum/admins/proc/toggleAI, R_ADMIN, FALSE)
/datum/admins/proc/toggleAI()
	set category = "Server"
	set desc="People can't be AI"
	set name="Toggle AI"
	config.allow_ai = !( config.allow_ai )
	if (!( config.allow_ai ))
		to_chat(world, "<B>The AI job is no longer chooseable.</B>")
	else
		to_chat(world, "<B>The AI job is chooseable now.</B>")
	log_admin("[key_name(usr)] toggled AI allowed.")
	world.update_status()


ADMIN_VERB_ADD(/datum/admins/proc/toggleaban, R_SERVER, FALSE)
/datum/admins/proc/toggleaban()
	set category = "Server"
	set desc="Respawn basically"
	set name="Toggle Respawn"
	config.abandon_allowed = !(config.abandon_allowed)
	if(config.abandon_allowed)
		to_chat(world, "<B>You may now respawn.</B>")
	else
		to_chat(world, "<B>You may no longer respawn :(</B>")
	message_admins("\blue [key_name_admin(usr)] toggled respawn to [config.abandon_allowed ? "On" : "Off"].", 1)
	log_admin("[key_name(usr)] toggled respawn to [config.abandon_allowed ? "On" : "Off"].")
	world.update_status()


ADMIN_VERB_ADD(/datum/admins/proc/toggle_aliens, R_FUN|R_SERVER, FALSE)
/datum/admins/proc/toggle_aliens()
	set category = "Server"
	set desc="Toggle alien mobs"
	set name="Toggle Aliens"
	config.aliens_allowed = !config.aliens_allowed
	log_admin("[key_name(usr)] toggled Aliens to [config.aliens_allowed].")
	message_admins("[key_name_admin(usr)] toggled Aliens [config.aliens_allowed ? "on" : "off"].", 1)


ADMIN_VERB_ADD(/datum/admins/proc/delay, R_SERVER, FALSE)
/datum/admins/proc/delay()
	set category = "Server"
	set desc="Delay the game start/end"
	set name="Delay"

	if(!check_rights(R_SERVER))
		return
	if (SSticker.current_state != GAME_STATE_PREGAME && SSticker.current_state != GAME_STATE_STARTUP)
		SSticker.delay_end = !SSticker.delay_end
		log_admin("[key_name(usr)] [SSticker.delay_end ? "delayed the round end" : "has made the round end normally"].")
		message_admins("\blue [key_name(usr)] [SSticker.delay_end ? "delayed the round end" : "has made the round end normally"].", 1)
		return
	round_progressing = !round_progressing
	if (!round_progressing)
		to_chat(world, "<b>The game start has been delayed.</b>")
		log_admin("[key_name(usr)] delayed the game.")
	else
		to_chat(world, "<b>The game will start soon.</b>")
		log_admin("[key_name(usr)] removed the delay.")

ADMIN_VERB_ADD(/datum/admins/proc/adjump, R_SERVER, FALSE)
/datum/admins/proc/adjump()
	set category = "Server"
	set desc="Toggle admin jumping"
	set name="Toggle Jump"
	config.allow_admin_jump = !(config.allow_admin_jump)
	message_admins("\blue Toggled admin jumping to [config.allow_admin_jump].")


ADMIN_VERB_ADD(/datum/admins/proc/adspawn, R_SERVER, FALSE)
/datum/admins/proc/adspawn()
	set category = "Server"
	set desc="Toggle admin spawning"
	set name="Toggle Spawn"
	config.allow_admin_spawning = !(config.allow_admin_spawning)
	message_admins("\blue Toggled admin item spawning to [config.allow_admin_spawning].")


ADMIN_VERB_ADD(/datum/admins/proc/adrev, R_SERVER, FALSE)
/datum/admins/proc/adrev()
	set category = "Server"
	set desc="Toggle admin revives"
	set name="Toggle Revive"
	config.allow_admin_rev = !(config.allow_admin_rev)
	message_admins("\blue Toggled reviving to [config.allow_admin_rev].")


ADMIN_VERB_ADD(/datum/admins/proc/immreboot, R_SERVER, FALSE)
/datum/admins/proc/immreboot()
	set category = "Server"
	set desc="Reboots the server post haste"
	set name="Immediate Reboot"
	if(!usr.client.holder)
		return
	if( alert("Reboot server?",,"Yes","No") == "No")
		return
	to_chat(world, "\red <b>Rebooting world!</b> \blue Initiated by [usr.client.holder.fakekey ? "Admin" : usr.key]!")
	log_admin("[key_name(usr)] initiated an immediate reboot.")
	world.Reboot()


////////////////////////////////////////////////////////////////////////////////////////////////ADMIN HELPER PROCS

/proc/is_special_character(mob/M as mob) // returns 1 for special characters
	if (!istype(M))
		return FALSE

	if(M.mind && player_is_antag(M.mind))
		return TRUE


	if(isrobot(M))
		var/mob/living/silicon/robot/R = M
		if(R.emagged)
			return TRUE

	return FALSE

ADMIN_VERB_ADD(/datum/admins/proc/spawn_fruit, R_DEBUG, FALSE)
/datum/admins/proc/spawn_fruit(seedtype in plant_controller.seeds)
	set category = "Debug"
	set desc = "Spawn the product of a seed."
	set name = "Spawn Fruit"

	if(!check_rights(R_DEBUG))
		return

	if(!seedtype || !plant_controller.seeds[seedtype])
		return
	var/datum/seed/S = plant_controller.seeds[seedtype]
	S.harvest(usr,0,0,1)
	log_admin("[key_name(usr)] spawned [seedtype] fruit at ([usr.x],[usr.y],[usr.z])")

ADMIN_VERB_ADD(/datum/admins/proc/spawn_custom_item, R_DEBUG, FALSE)
/datum/admins/proc/spawn_custom_item()
	set category = "Debug"
	set desc = "Spawn a custom item."
	set name = "Spawn Custom Item"

	if(!check_rights(R_DEBUG))
		return

	var/owner = input("Select a ckey.", "Spawn Custom Item") as null|anything in custom_items
	if(!owner|| !custom_items[owner])
		return

	var/list/possible_items = custom_items[owner]
	var/datum/custom_item/item_to_spawn = input("Select an item to spawn.", "Spawn Custom Item") as null|anything in possible_items
	if(!item_to_spawn)
		return

	item_to_spawn.spawn_item(get_turf(usr))


ADMIN_VERB_ADD(/datum/admins/proc/check_custom_items, R_DEBUG, FALSE)
/datum/admins/proc/check_custom_items()
	set category = "Debug"
	set desc = "Check the custom item list."
	set name = "Check Custom Items"

	if(!check_rights(R_DEBUG))
		return

	if(!custom_items)
		to_chat(usr, "Custom item list is null.")
		return

	if(!custom_items.len)
		to_chat(usr, "Custom item list not populated.")
		return

	for(var/assoc_key in custom_items)
		to_chat(usr, "[assoc_key] has:")
		var/list/current_items = custom_items[assoc_key]
		for(var/datum/custom_item/item in current_items)
			to_chat(usr, "- name: [item.name] icon: [item.item_icon] path: [item.item_path] desc: [item.item_desc]")


ADMIN_VERB_ADD(/datum/admins/proc/spawn_plant, R_DEBUG, FALSE)
/datum/admins/proc/spawn_plant(seedtype in plant_controller.seeds)
	set category = "Debug"
	set desc = "Spawn a spreading plant effect."
	set name = "Spawn Plant"

	if(!check_rights(R_DEBUG))
		return

	if(!seedtype || !plant_controller.seeds[seedtype])
		return
	new /obj/effect/plant(get_turf(usr), plant_controller.seeds[seedtype])
	log_admin("[key_name(usr)] spawned [seedtype] vines at ([usr.x],[usr.y],[usr.z])")


ADMIN_VERB_ADD(/datum/admins/proc/spawn_atom, R_DEBUG, FALSE)
// allows us to spawn instances
/datum/admins/proc/spawn_atom(var/object as text)
	set category = "Debug"
	set desc = "(atom path) Spawn an atom"
	set name = "Spawn"

	if(!check_rights(R_DEBUG))
		return

	var/list/types = typesof(/atom)
	var/list/matches = new()

	for(var/path in types)
		if(findtext("[path]", object))
			matches += path

	if(matches.len==0)
		return

	var/chosen
	if(matches.len==1)
		chosen = matches[1]
	else
		chosen = input("Select an atom type", "Spawn Atom", matches[1]) as null|anything in matches
		if(!chosen)
			return

	if(ispath(chosen,/turf))
		var/turf/T = get_turf(usr.loc)
		T.ChangeTurf(chosen)
	else
		new chosen(usr.loc)

	log_and_message_admins("spawned [chosen] at ([usr.x],[usr.y],[usr.z])")


// -Removed due to rare practical use. Moved to debug verbs ~Errorage,
//ADMIN_VERB_ADD(/datum/admins/proc/show_traitor_panel, R_ADMIN, TRUE)
//interface which shows a mob's mind
/datum/admins/proc/show_traitor_panel(var/mob/M in SSmobs.mob_list)
	set category = "Admin"
	set desc = "Edit mobs's memory and role"
	set name = "Show Traitor Panel"

	if(!istype(M))
		to_chat(usr, "This can only be used on instances of type /mob")
		return
	if(!M.mind)
		to_chat(usr, "This mob has no mind!")
		return

	M.mind.edit_memory()

/*
ADMIN_VERB_ADD(/datum/admins/proc/show_game_mode, R_ADMIN, FALSE)
//Configuration window for the current game mode.
/datum/admins/proc/show_game_mode()
	set category = "Admin"
	set desc = "Show the current round storyteller."
	set name = "Show Storyteller"

	if(!get_storyteller())
		alert("Not before roundstart!", "Alert")
		return

	var/out = "<font size=3><b>Current storyteller: [get_storyteller().name] (<a href='?src=\ref[get_storyteller()];debug_antag=self'>[get_storyteller().config_tag]</a>)</b></font><br/>"
	out += "<hr>"

	if(SSticker.mode.antag_tags && SSticker.mode.antag_tags.len)
		out += "<b>Core antag templates:</b></br>"
		for(var/antag_tag in SSticker.mode.antag_tags)
			out += "<a href='?src=\ref[SSticker.mode];debug_antag=[antag_tag]'>[antag_tag]</a>.</br>"

	out += "<b>All antag ids:</b>"
	if(SSticker.mode.antag_templates && SSticker.mode.antag_templates.len).
		for(var/datum/antagonist/antag in SSticker.mode.antag_templates)
			antag.update_current_antag_max()
			out += " <a href='?src=\ref[SSticker.mode];debug_antag=[antag.id]'>[antag.id]</a>"
			out += " ([antag.get_antag_count()]/[antag.cur_max]) "
			out += " <a href='?src=\ref[SSticker.mode];remove_antag_type=[antag.id]'>\[-\]</a><br/>"
	else
		out += " None."
	out += " <a href='?src=\ref[SSticker.mode];add_antag_type=1'>\[+\]</a><br/>"

	usr << browse(out, "window=edit_mode[src]")
*/


/datum/admins/proc/toggletintedweldhelmets()
	set category = "Debug"
	set desc="Reduces view range when wearing welding helmets"
	set name="Toggle tinted welding helmets."
	config.welder_vision = !( config.welder_vision )
	if (config.welder_vision)
		to_chat(world, "<B>Reduced welder vision has been enabled!</B>")
	else
		to_chat(world, "<B>Reduced welder vision has been disabled!</B>")
	log_admin("[key_name(usr)] toggled welder vision.")
	message_admins("[key_name_admin(usr)] toggled welder vision.", 1)


ADMIN_VERB_ADD(/datum/admins/proc/toggleguests, R_ADMIN, FALSE)
//toggles whether guests can join the current game
/datum/admins/proc/toggleguests()
	set category = "Server"
	set desc="Guests can't enter"
	set name="Toggle guests"
	config.guests_allowed = !(config.guests_allowed)
	if (!(config.guests_allowed))
		to_chat(world, "<B>Guests may no longer enter the game.</B>")
	else
		to_chat(world, "<B>Guests may now enter the game.</B>")
	log_admin("[key_name(usr)] toggled guests game entering [config.guests_allowed?"":"dis"]allowed.")
	message_admins("\blue [key_name_admin(usr)] toggled guests game entering [config.guests_allowed?"":"dis"]allowed.", 1)


/datum/admins/proc/output_ai_laws()
	var/ai_number = 0
	for(var/mob/living/silicon/S in SSmobs.mob_list)
		ai_number++
		if(isAI(S))
			to_chat(usr, "<b>AI [key_name(S, usr)]'s laws:</b>")
		else if(isrobot(S))
			var/mob/living/silicon/robot/R = S
			to_chat(usr, "<b>CYBORG [key_name(S, usr)] [R.connected_ai?"(Slaved to: [R.connected_ai])":"(Independant)"]: laws:</b>")
		else if (ispAI(S))
			to_chat(usr, "<b>pAI [key_name(S, usr)]'s laws:</b>")
		else
			to_chat(usr, "<b>SOMETHING SILICON [key_name(S, usr)]'s laws:</b>")

		if (S.laws == null)
			to_chat(usr, "[key_name(S, usr)]'s laws are null?? Contact a coder.")
		else
			S.laws.show_laws(usr)
	if(!ai_number)
		to_chat(usr, "<b>No AIs located</b>" ) //Just so you know the thing is actually working and not just ignoring you.

/client/proc/update_mob_sprite(mob/living/carbon/human/H as mob)
	set category = "Admin"
	set name = "Update Mob Sprite"
	set desc = "Should fix any mob sprite update errors."

	if (!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if(istype(H))
		H.regenerate_icons()


/*
	helper proc to test if someone is a mentor or not.  Got tired of writing this same check all over the place.
*/
/proc/is_mentor(client/C)

	if(!istype(C))
		return 0
	if(!C.holder)
		return 0

	if(C.holder.rights == R_MENTOR)
		return 1
	return 0

/proc/get_options_bar(whom, detail = 2, name = 0, link = 1, highlight_special = 1)
	if(!whom)
		return "<b>(*null*)</b>"
	var/mob/M
	var/client/C
	if(istype(whom, /client))
		C = whom
		M = C.mob
	else if(ismob(whom))
		M = whom
		C = M.client
	else
		return "<b>(*not an mob*)</b>"
	switch(detail)
		if(0)
			return "<b>[key_name(C, link, name, highlight_special)]</b>"

		if(1)	//Private Messages
			return "<b>[key_name(C, link, name, highlight_special)](<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</A>)</b>"

		if(2)	//Admins
			var/ref_mob = "\ref[M]"
			return "<b>[key_name(C, link, name, highlight_special)](<A HREF='?_src_=holder;adminmoreinfo=[ref_mob]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=[ref_mob]'>PP</A>) (<A HREF='?_src_=vars;Vars=[ref_mob]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=[ref_mob]'>SM</A>) ([admin_jump_link(M, UNLINT(src))]) (<A HREF='?_src_=holder;check_antagonist=1'>CA</A>)</b>"
		if(3)	//Devs
			var/ref_mob = "\ref[M]"
			return "<b>[key_name(C, link, name, highlight_special)](<A HREF='?_src_=vars;Vars=[ref_mob]'>VV</A>)([admin_jump_link(M, UNLINT(src))])</b>"
		if(4)	//Mentors
			var/ref_mob = "\ref[M]"
			return "<b>[key_name(C, link, name, highlight_special)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=[ref_mob]'>PP</A>) (<A HREF='?_src_=vars;Vars=[ref_mob]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=[ref_mob]'>SM</A>) ([admin_jump_link(M, UNLINT(src))])</b>"


//
//
//ALL DONE
//*********************************************************************************************************
//

//Returns 1 to let the dragdrop code know we are trapping this event
//Returns 0 if we don't plan to trap the event
/datum/admins/proc/cmd_ghost_drag(var/mob/observer/ghost/frommob, var/mob/living/tomob)
	if(!istype(frommob))
		return //Extra sanity check to make sure only observers are shoved into things

	//Same as assume-direct-control perm requirements.
	if (!check_rights(R_ADMIN|R_DEBUG,0))
		return 0
	if (!frommob.ckey)
		return 0
	var/question = ""
	if (tomob.ckey)
		question = "This mob already has a user ([tomob.key]) in control of it! "
	question += "Are you sure you want to place [frommob.name]([frommob.key]) in control of [tomob.name]?"
	var/ask = alert(question, "Place ghost in control of mob?", "Yes", "No")
	if (ask != "Yes")
		return 1
	if (!frommob || !tomob) //make sure the mobs don't go away while we waited for a response
		return 1
	if(tomob.client) //No need to ghostize if there is no client
		tomob.ghostize(0)
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has put [frommob.ckey] in control of [tomob.name].</span>")
	log_admin("[key_name(usr)] stuffed [frommob.ckey] into [tomob.name].")

	tomob.ckey = frommob.ckey
	if(tomob.client)
		if(tomob.client.UI)
			tomob.client.UI.show()
		else
			tomob.client.create_UI(tomob.type)

	qdel(frommob)
	return 1

/*
ADMIN_VERB_ADD(/datum/admins/proc/force_mode_latespawn, R_ADMIN, FALSE)
//Force the mode to try a latespawn proc
/datum/admins/proc/force_mode_latespawn()
	set category = "Admin"
	set name = "Force Mode Spawn"
	set desc = "Force autotraitor to proc."

	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins) || !check_rights(R_ADMIN))
		to_chat(usr, "Error: you are not an admin!")
		return

	if(!SSticker.mode)
		to_chat(usr, "Mode has not started.")
		return

	log_and_message_admins("attempting to force mode autospawn.")
	SSticker.mode.process_autoantag()
*/

ADMIN_VERB_ADD(/datum/admins/proc/paralyze_mob, R_ADMIN, FALSE)
/datum/admins/proc/paralyze_mob(mob/living/H as mob)
	set category = "Fun"
	set name = "Toggle Paralyze"
	set desc = "Paralyzes a player. Or unparalyses them."

	var/msg

	if(check_rights(R_ADMIN))
		if (H.paralysis == 0)
			H.paralysis = 8000
			msg = "has paralyzed [key_name(H)]."
		else
			H.paralysis = 0
			msg = "has unparalyzed [key_name(H)]."
		log_and_message_admins(msg)
