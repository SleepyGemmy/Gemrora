/client/proc/cmd_admin_drop_everything(mob/M as mob in GLOB.mob_list)
	set category = null
	set name = "Drop Everything"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/confirm = alert(src, "Make [M] drop everything?", "Message", "Yes", "No")
	if(confirm != "Yes")
		return

	for(var/obj/item/W in M)
		M.drop_from_inventory(W)

	log_admin("[key_name(usr)] made [key_name(M)] drop everything!")
	message_admins("[key_name_admin(usr)] made [key_name_admin(M)] drop everything!", 1)
	feedback_add_details("admin_verb","DEVR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/cmd_admin_subtle_message(mob/M as mob in GLOB.mob_list)
	set category = "Special Verbs"
	set name = "Subtle Message"

	if(!ismob(M))	return
	if (!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/msg = sanitize(input("Message:", "Subtle PM to [M.key]"))

	if (!msg)
		return
	if(usr)
		if (usr.client)
			if(usr.client.holder)
				to_chat(M, "<b>You hear a voice in your head... <i>[msg]</i></b>")

	log_admin("SubtlePM: [key_name(usr)] -> [key_name(M)] : [msg]")
	message_admins(SPAN_NOTICE("<b>SubtleMessage: [key_name_admin(usr)] -> [key_name_admin(M)] : [msg]</b>"), 1)
	feedback_add_details("admin_verb","SMS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_mentor_check_new_players()	//Allows mentors / admins to determine who the newer players are.
	set category = "Admin"
	set name = "Check new Players"
	if(!holder)
		to_chat(src, "Only staff members may use this command.")

	var/age = alert(src, "Age check", "Show accounts yonger then _____ days","7", "30" , "All")

	if(age == "All")
		age = 9999999
	else
		age = text2num(age)

	var/missing_ages = 0
	var/msg = ""

	var/highlight_special_characters = 1
	if(!check_rights(R_MOD|R_ADMIN, 0))
		highlight_special_characters = 0

	for(var/client/C in GLOB.clients)
		if(C.player_age == "Requires database")
			missing_ages = 1
			continue
		if(C.player_age < age)
			msg += "[key_name(C, 1, 1, highlight_special_characters)]: account is [C.player_age] days old<br>"

	if(missing_ages)
		to_chat(src, "Some accounts did not have proper ages set in their clients.  This function requires database to be present")

	if(msg != "")
		src << browse(HTML_SKELETON(msg), "window=Player_age_check")
	else
		to_chat(src, "No matches for that age range found.")


/client/proc/cmd_admin_world_narrate() // Allows administrators to fluff events a little easier -- TLE
	set category = "Special Verbs"
	set name = "Global Narrate"

	if (!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/msg = html_decode(sanitize(input("Message:", "Enter the text you wish to appear to everyone:")))

	if (!msg)
		return
	to_world("[msg]")
	log_admin("GlobalNarrate: [key_name(usr)] : [msg]")
	message_admins(SPAN_NOTICE("\bold GlobalNarrate: [key_name_admin(usr)] : [msg]<BR>"), 1)
	feedback_add_details("admin_verb","GLN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_local_narrate()
	set category = "Special Verbs"
	set name = "Local Narrate"

	if(!check_rights(R_ADMIN, TRUE))
		return

	var/list/mob/message_mobs = list()
	var/choice = alert(usr, "Local narrate will send a plain message to mobs. Do you want the mobs messaged to be only ones that you can see, or ignore blocked vision and message everyone within seven tiles of you?", "Narrate Selection", "In my view", "In range of me", "Cancel")
	if(choice != "Cancel")
		if(choice == "In my view")
			message_mobs = mobs_in_view(view, src.mob)
		else
			for(var/mob/M in range(view, src.mob))
				message_mobs += M
	else
		return

	var/msg = html_decode(sanitize(input("Message:", "Enter the text you wish to appear to everyone within seven tiles of you:")))
	if(!msg)
		return
	for(var/M in message_mobs)
		to_chat(M, msg)
	log_admin("LocalNarrate: [key_name(usr)] : [msg]")
	message_admins(SPAN_NOTICE("\bold LocalNarrate: [key_name_admin(usr)] : [msg]<BR>"), 1)
	feedback_add_details("admin_verb", "LCLN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/cmd_admin_local_screen_text()
	set category = "Special Verbs"
	set name = "Local Screen Text"

	if(!check_rights(R_ADMIN, TRUE))
		return

	var/list/mob/message_mobs = list()
	var/choice = tgui_alert(usr, "Local Screen Text will send a screen text message to mobs. Do you want the mobs messaged to be only ones that you can see, or ignore blocked vision and message everyone within seven tiles of you?", "Narrate Selection", list("View", "Range", "Cancel"))
	if(choice != "Cancel")
		if(choice == "View")
			message_mobs = mobs_in_view(view, src.mob)
		else
			for(var/mob/M in range(view, src.mob))
				message_mobs += M
	else
		return

	var/msg = tgui_input_text(usr, "Insert the screen message you want to send.", "Local Screen Text")
	if(!msg)
		return

	var/big_text = tgui_alert(src, "Do you want big or normal text?", "Local Screen Text", list("Big", "Normal"))
	var/text_type = /atom/movable/screen/text/screen_text
	if(big_text == "Big")
		text_type = /atom/movable/screen/text/screen_text/command_order

	for(var/mob/M in message_mobs)
		if(M.client)
			M.play_screen_text(msg,text_type, COLOR_RED)
	log_admin("LocalScreenText: [key_name(usr)] : [msg]")
	message_admins(SPAN_NOTICE("Local Screen Text: [key_name_admin(usr)] : [msg]"), 1)
	feedback_add_details("admin_verb", "LSTX") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_global_screen_text()
	set category = "Special Verbs"
	set name = "Global Screen Text"

	if(!check_rights(R_ADMIN, TRUE))
		return

	var/msg = tgui_input_text(usr, "Insert the screen message you want to send.", "Global Screen Text")
	if(!msg)
		return

	var/big_text = tgui_alert(src, "Do you want big or normal text?", "Global Screen Text", list("Big", "Normal"))
	var/text_type = /atom/movable/screen/text/screen_text
	if(big_text == "Big")
		text_type = /atom/movable/screen/text/screen_text/command_order

	for(var/mob/M in GLOB.mob_list)
		if(M.client)
			M.play_screen_text(msg, text_type, COLOR_RED)

	log_admin("GlobalScreenText: [key_name(usr)] : [msg]")
	message_admins(SPAN_NOTICE("Global Screen Text: [key_name_admin(usr)] : [msg]"), 1)
	feedback_add_details("admin_verb", "GSTX") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_direct_narrate(var/mob/M)	// Targetted narrate -- TLE
	set category = "Special Verbs"
	set name = "Direct Narrate"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if(!M)
		M = input("Direct narrate to who?", "Active Players") as null|anything in get_mob_with_client_list()

	if(!M)
		return

	var/msg = html_decode(sanitize(input("Message:", "Enter the text you wish to appear to your target:")))

	if( !msg )
		return

	to_chat(M, msg)
	log_admin("DirectNarrate: [key_name(usr)] to ([M.name]/[M.key]): [msg]")
	message_admins(SPAN_NOTICE("\bold DirectNarrate: [key_name(usr)] to ([M.name]/[M.key]): [msg]<BR>"), 1)
	feedback_add_details("admin_verb","DIRN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_godmode(mob/M as mob in GLOB.mob_list)
	set category = "Special Verbs"
	set name = "Godmode"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	M.status_flags ^= GODMODE
	to_chat(usr, SPAN_NOTICE("Toggled [(M.status_flags & GODMODE) ? "ON" : "OFF"]"))

	log_admin("[key_name(usr)] has toggled [key_name(M)]'s nodamage to [(M.status_flags & GODMODE) ? "On" : "Off"]")
	message_admins("[key_name_admin(usr)] has toggled [key_name_admin(M)]'s nodamage to [(M.status_flags & GODMODE) ? "On" : "Off"]", 1)
	feedback_add_details("admin_verb","GOD") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/proc/cmd_admin_mute(mob/M as mob, mute_type, automute = 0)
	if(automute)
		if(!GLOB.config.automute_on)	return
	else
		if(!usr || !usr.client)
			return
		if(!usr.client.holder)
			to_chat(usr, SPAN_WARNING("Error: cmd_admin_mute: You don't have permission to do this."))
			return
		if(!M.client)
			to_chat(usr, SPAN_WARNING("Error: cmd_admin_mute: This mob doesn't have a client tied to it."))
		if(M.client.holder)
			to_chat(usr, SPAN_WARNING("Error: cmd_admin_mute: You cannot mute an admin/mod."))
	if(!M.client)		return
	if(M.client.holder)	return

	var/muteunmute
	var/mute_string

	switch(mute_type)
		if(MUTE_IC)			mute_string = "IC (say and emote)"
		if(MUTE_OOC)		mute_string = "OOC"
		if(MUTE_PRAY)		mute_string = "pray"
		if(MUTE_ADMINHELP)	mute_string = "adminhelp, admin PM and ASAY"
		if(MUTE_DEADCHAT)	mute_string = "deadchat and DSAY"
		if(MUTE_AOOC)		mute_string = "AOOC"
		if(MUTE_ALL)		mute_string = "everything"
		else				return

	if(automute)
		muteunmute = "auto-muted"
		M.client.prefs.muted |= mute_type
		log_admin("SPAM AUTOMUTE: [muteunmute] [key_name(M)] from [mute_string]")
		message_admins("SPAM AUTOMUTE: [muteunmute] [key_name_admin(M)] from [mute_string].", 1)
		to_chat(M, "You have been [muteunmute] from [mute_string] by the SPAM AUTOMUTE system. Contact an admin.")
		feedback_add_details("admin_verb","AUTOMUTE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return

	if(M.client.prefs.muted & mute_type)
		muteunmute = "unmuted"
		M.client.prefs.muted &= ~mute_type
		M.client.spam_alert = 0
	else
		muteunmute = "muted"
		M.client.prefs.muted |= mute_type

	log_admin("[key_name(usr)] has [muteunmute] [key_name(M)] from [mute_string]")
	message_admins("[key_name_admin(usr)] has [muteunmute] [key_name_admin(M)] from [mute_string].", 1)
	to_chat(M, "You have been [muteunmute] from [mute_string].")
	feedback_add_details("admin_verb","MUTE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_add_random_ai_law()
	set category = "Fun"
	set name = "Add Random AI Law"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm != "Yes") return
	log_admin("[key_name(src)] has added a random AI law.")
	message_admins("[key_name_admin(src)] has added a random AI law.", 1)

	var/show_log = alert(src, "Show ion message?", "Message", "Yes", "No")
	if(show_log == "Yes")
		command_announcement.Announce("Incoming ion storm detected near the ship. Please check all AI-controlled equipment for errors.", "Anomaly Alert", new_sound = 'sound/AI/ionstorm.ogg')

	IonStorm(0)
	feedback_add_details("admin_verb","ION") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/*
Allow admins to set players to be able to respawn/bypass 30 min wait, without the admin having to edit variables directly
Ccomp's first proc.
*/

/proc/get_ghosts(var/notify = 0,var/what = 2, var/client/C = null)
	// what = 1, return ghosts ass list.
	// what = 2, return mob list

	var/list/mobs = list()
	var/list/ghosts = list()
	var/list/sortmob = sortAtom(GLOB.mob_list)                           // get the mob list.
	var/any=0
	for(var/mob/abstract/ghost/observer/M in sortmob)
		mobs.Add(M)                                             //filter it where it's only ghosts
		any = 1                                                 //if no ghosts show up, any will just be 0
	if(!any)
		if(notify && C)
			to_chat(C, "There doesn't appear to be any ghosts for you to select.")
		return

	for(var/mob/M in mobs)
		var/name = M.name
		ghosts[name] = M	//get the name of the mob for the popup list
	if(what==1)
		return ghosts
	else
		return mobs


/client/proc/allow_character_respawn()
	set category = "Special Verbs"
	set name = "Allow player to respawn"
	set desc = "Lets the player bypass the wait to respawn or allow them to re-enter their corpse."
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
	var/list/ghosts = get_ghosts(1,1,src)

	var/target = tgui_input_list(src, "Please, select a ghost!", "COME BACK TO LIFE!", ghosts)
	if(!target)
		to_chat(src, SPAN_WARNING("You didn't select a ghost!"))		// Sanity check, if no ghosts in the list we don't want to edit a null variable and cause a runtime error.)
		return

	var/mob/abstract/ghost/observer/G = ghosts[target]
	if(G.has_enabled_antagHUD && GLOB.config.antag_hud_restricted)
		var/response = alert(src, "Are you sure you wish to allow this individual to play?","Ghost has used AntagHUD","Yes","No")
		if(response == "No") return

	/* time of death is checked in /mob/verb/abandon_mob() which is the Respawn verb.
	timeofdeath is used for bodies on autopsy but since we're messing with a ghost I'm pretty sure there won't be an autopsy.*/
	G.timeofdeath=-19999
	var/datum/preferences/P

	if (G.client)
		P = G.client.prefs
	else if (G.ckey)
		P = GLOB.preferences_datums[G.ckey]
	else
		to_chat(src, "Something went wrong, couldn't find the target's preferences datum")
		return 0

	for (var/entry in P.time_of_death) //Set all the prefs' times of death to a huge negative value so any respawn timers will be fine
		P.time_of_death[entry] = -99999

	G.has_enabled_antagHUD = 2
	G.can_reenter_corpse = 1

	G.show_message(SPAN_NOTICE("<B>You may now respawn. You should roleplay as if you learned nothing about the round during your time with the dead.</B>"), 1)
	log_admin("[key_name(usr)] allowed [key_name(G)] to bypass the [GLOB.config.respawn_delay] minute respawn limit")
	message_admins("Admin [key_name_admin(usr)] allowed [key_name_admin(G)] to bypass the [GLOB.config.respawn_delay] minute respawn limit", 1)

/client/proc/allow_stationbound_reset(mob/living/silicon/robot/R in range(world.view))
	set category = "Special Verbs"
	set name = "Allow Stationbound Reset"
	set desc = "Select a stationbound to reset its module."

	if(!check_rights(R_ADMIN, TRUE))
		return
	if(!R || !istype(R))
		return

	R.uneq_all()
	R.mod_type = initial(R.mod_type)
	R.hands.icon_state = "nomod"

	R.module.Reset(R)
	QDEL_NULL(R.module)
	R.updatename("Default")

	to_chat(R, FONT_LARGE(SPAN_NOTICE("An admin has allowed you to reset your module.")))

	log_admin("[key_name(usr)] allowed [key_name(R)] to reset themselves as a stationbound.")
	message_admins("Admin [key_name_admin(usr)] allowed [key_name_admin(R)] to reset themselves as a stationbound.", 1)


/client/proc/toggle_antagHUD_use()
	set category = "Server"
	set name = "Toggle antagHUD usage"
	set desc = "Toggles antagHUD usage for observers"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
	var/action=""
	if(GLOB.config.antag_hud_allowed)
		for(var/mob/abstract/ghost/observer/g in get_ghosts())
			if(!g.client.holder)						//Remove the verb from non-admin ghosts
				remove_verb(g, /mob/abstract/ghost/observer/verb/toggle_antagHUD)
			if(g.antagHUD)
				g.antagHUD = 0						// Disable it on those that have it enabled
				g.has_enabled_antagHUD = 2				// We'll allow them to respawn
				to_chat(g, SPAN_WARNING("The Administrator has disabled AntagHUD."))
		GLOB.config.antag_hud_allowed = 0
		to_chat(src, SPAN_DANGER("AntagHUD usage has been disabled."))
		action = "disabled"
	else
		for(var/mob/abstract/ghost/observer/g in get_ghosts())
			if(!g.client.holder)						// Add the verb back for all non-admin ghosts
				add_verb(g,  /mob/abstract/ghost/observer/verb/toggle_antagHUD)
			to_chat(g, SPAN_NOTICE("<B>The Administrator has enabled AntagHUD.</B>"))	// Notify all observers they can now use AntagHUD)
		GLOB.config.antag_hud_allowed = 1
		action = "enabled"
		to_chat(src, SPAN_NOTICE("<B>AntagHUD usage has been enabled.</B>"))


	log_admin("[key_name(usr)] has [action] antagHUD usage for observers")
	message_admins("Admin [key_name_admin(usr)] has [action] antagHUD usage for observers", 1)



/client/proc/toggle_antagHUD_restrictions()
	set category = "Server"
	set name = "Toggle antagHUD Restrictions"
	set desc = "Restricts players that have used antagHUD from being able to join this round."
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
	var/action=""
	if(GLOB.config.antag_hud_restricted)
		for(var/mob/abstract/ghost/observer/g in get_ghosts())
			to_chat(g, SPAN_NOTICE("<B>The administrator has lifted restrictions on joining the round if you use AntagHUD</B>"))
		action = "lifted restrictions"
		GLOB.config.antag_hud_restricted = 0
		to_chat(src, SPAN_NOTICE("<B>AntagHUD restrictions have been lifted</B>"))
	else
		for(var/mob/abstract/ghost/observer/g in get_ghosts())
			to_chat(g, SPAN_DANGER("The administrator has placed restrictions on joining the round if you use AntagHUD"))
			to_chat(g, SPAN_DANGER("Your AntagHUD has been disabled, you may choose to re-enabled it but will be under restrictions "))
			g.antagHUD = 0
			g.has_enabled_antagHUD = 0
		action = "placed restrictions"
		GLOB.config.antag_hud_restricted = 1
		to_chat(src, SPAN_DANGER("AntagHUD restrictions have been enabled"))

	log_admin("[key_name(usr)] has [action] on joining the round if they use AntagHUD")
	message_admins("Admin [key_name_admin(usr)] has [action] on joining the round if they use AntagHUD", 1)

/*
If a guy was gibbed and you want to revive him, this is a good way to do so.
Works kind of like entering the game with a new character. Character receives a new mind if they didn't have one.
Traitors and the like can also be revived with the previous role mostly intact.
/N */
/client/proc/respawn_character()
	set category = "Special Verbs"
	set name = "Respawn Character"
	set desc = "Respawn a person that has been gibbed/dusted/killed. They must be a ghost for this to work and preferably should not have a body to go back into."

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	var/input = ckey(input(src, "Please specify which key will be respawned.", "Key", ""))
	if(!input)
		return

	var/mob/abstract/ghost/observer/G_found
	for(var/mob/abstract/ghost/observer/G in GLOB.player_list)
		if(G.ckey == input)
			G_found = G
			break

	if(!G_found)//If a ghost was not found.
		to_chat(usr, SPAN_WARNING("There is no active key like that in the game or the person is not currently a ghost."))
		return

	var/mob/living/carbon/human/new_character = new(pick(GLOB.latejoin))//The mob being spawned.

	var/datum/record/general/locked/record_found			//Referenced to later to either randomize or not randomize the character.
	if(G_found.mind && !G_found.mind.active)	//mind isn't currently in use by someone/something
		/*Try and locate a record for the person being respawned through data_core.
		This isn't an exact science but it does the trick more often than not.*/
		var/id = md5("[G_found.real_name][G_found.mind.assigned_role]")
		for(var/datum/record/general/locked/R in SSrecords.records_locked)
			if(R.nid == id)
				record_found = R//We shall now reference the record.
				break

	if(record_found)//If they have a record we can determine a few things.
		new_character.real_name = record_found.name
		new_character.gender = record_found.sex
		new_character.age = record_found.age
		new_character.b_type = record_found.medical.blood_type
	else
		new_character.gender = pick(MALE,FEMALE)
		var/datum/preferences/A = new()
		A.randomize_appearance_for(new_character)
		new_character.real_name = G_found.real_name

	if(!new_character.real_name)
		if(new_character.gender == MALE)
			new_character.real_name = capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))
		else
			new_character.real_name = capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))
	new_character.name = new_character.real_name

	if(G_found.mind && !G_found.mind.active)
		G_found.mind.transfer_to(new_character)	//be careful when doing stuff like this! I've already checked the mind isn't in use
		new_character.mind.special_verbs = list()
	else
		new_character.mind_initialize()
	if(!new_character.mind.assigned_role)	new_character.mind.assigned_role = "Assistant"//If they somehow got a null assigned role.

	//DNA
	if(record_found && record_found.medical)//Pull up their name from database records if they did have a mind.
		new_character.dna = new()//Let's first give them a new DNA.
		new_character.dna.unique_enzymes = record_found.medical.blood_dna //Enzymes are based on real name but we'll use the record for conformity.

		// I HATE BYOND.  HATE.  HATE. - N3X
		var/list/newSE= record_found.enzymes
		var/list/newUI = record_found.identity
		new_character.dna.SE = newSE.Copy() //This is the default of enzymes so I think it's safe to go with.
		new_character.dna.UpdateSE()
		new_character.UpdateAppearance(newUI.Copy())//Now we configure their appearance based on their unique identity, same as with a DNA machine or somesuch.
	else//If they have no records, we just do a random DNA for them, based on their random appearance/savefile.
		new_character.dna.ready_dna(new_character)

	new_character.key = G_found.key

	/*
	The code below functions with the assumption that the mob is already a traitor if they have a special role.
	So all it does is re-equip the mob with powers and/or items. Or not, if they have no special role.
	If they don't have a mind, they obviously don't have a special role.
	*/

	//Two variables to properly announce later on.
	var/admin = key_name_admin(src)
	var/player_key = G_found.key

	//Now for special roles and equipment.
	var/datum/antagonist/antag_data = get_antag_data(new_character.mind.special_role)
	if(antag_data)
		antag_data.add_antagonist(new_character.mind)
		antag_data.place_mob(new_character)
	else
		SSjobs.EquipRank(new_character, new_character.mind.assigned_role, 1)

	//Announces the character on all the systems, based on the record.
	if(!issilicon(new_character))//If they are not a cyborg/AI.
		if(!record_found && !player_is_antag(new_character.mind, only_offstation_roles = 1)) //If there are no records for them. If they have a record, this info is already in there. MODE people are not announced anyway.
			//Power to the user!
			if(alert(new_character,"Warning: No data core entry detected. Would you like to announce the arrival of this character by adding them to various databases, such as medical records?",,"No","Yes")=="Yes")
				SSrecords.generate_record(new_character)

			if(alert(new_character,"Would you like an active AI to announce this character?",,"No","Yes")=="Yes")
				call(/proc/AnnounceArrival)(new_character, new_character.mind.assigned_role)

	message_admins(SPAN_NOTICE("[admin] has respawned [player_key] as [new_character.real_name]."), 1)

	new_character << "You have been fully respawned. Enjoy the game."

	feedback_add_details("admin_verb","RSPCH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return new_character

/client/proc/cmd_admin_add_freeform_ai_law()
	set category = "Fun"
	set name = "Add Custom AI law"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	var/input = sanitize(input(usr, "Please enter anything you want the AI to do. Anything. Serious.", "What?", "") as text|null)
	if(!input)
		return
	for(var/mob/living/silicon/ai/M in GLOB.mob_list)
		if (M.stat == 2)
			to_chat(usr, "Upload failed. No signal is being detected from the AI.")
		else
			M.add_ion_law(input)
			for(var/mob/living/silicon/ai/O in GLOB.mob_list)
				to_chat(O, SPAN_DANGER("" + input + "...LAWS UPDATED"))
				O.show_laws()

	log_admin("Admin [key_name(usr)] has added a new AI law - [input]")
	message_admins("Admin [key_name_admin(usr)] has added a new AI law - [input]", 1)

	var/show_log = alert(src, "Show ion message?", "Message", "Yes", "No")
	if(show_log == "Yes")
		command_announcement.Announce("Incoming ion storm detected near the ship. Please check all AI-controlled equipment for errors.", "Anomaly Alert", new_sound = 'sound/AI/ionstorm.ogg')
	feedback_add_details("admin_verb","IONC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_rejuvenate(mob/living/M as mob in GLOB.mob_list)
	set category = "Special Verbs"
	set name = "Rejuvenate"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if(!mob)
		return
	if(!istype(M))
		alert("Cannot revive a ghost")
		return
	if(GLOB.config.allow_admin_rev)
		M.revive()

		log_admin("[key_name(usr)] healed / revived [key_name(M)]")
		message_admins(SPAN_DANGER("Admin [key_name_admin(usr)] healed / revived [key_name_admin(M)]!"), 1)
	else
		alert("Admin revive disabled")
	feedback_add_details("admin_verb","REJU") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_create_centcom_report()
	set category = "Special Verbs"
	set name = "Create Command Report"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/reporttitle
	var/reportbody
	var/reporter = null
	var/reporttype = tgui_alert(usr, "Choose whether to use a template or custom report.", "Create Command Report", list("Custom", "Template"))
	if(!reporttype)
		return
	switch(reporttype)
		if("Template")
			if (!establish_db_connection(GLOB.dbcon))
				to_chat(src, SPAN_NOTICE("Unable to connect to the database."))
				return
			var/DBQuery/query = GLOB.dbcon.NewQuery("SELECT title, message FROM ss13_ccia_general_notice_list WHERE deleted_at IS NULL")
			query.Execute()

			var/list/template_names = list()
			var/list/templates = list()

			while (query.NextRow())
				template_names += query.item[1]
				templates[query.item[1]] = query.item[2]

			// Catch empty list
			if (!templates.len)
				to_chat(src, SPAN_NOTICE("There are no templates in the database."))
				return

			reporttitle = tgui_input_list(usr, "Please select a command report template.", "Create Command Report", template_names)
			if(!reporttitle)
				return
			reportbody = templates[reporttitle]

		if("Custom")
			reporttitle = sanitizeSafe(tgui_input_text(usr, "Pick a title for the report.", "Title"))
			if(!reporttitle)
				reporttitle = "NanoTrasen Update"
			reportbody = sanitize(tgui_input_text(usr, "Please enter anything you want. Anything. Serious.", "Body", multiline = TRUE), extra = FALSE)
			if(!reportbody)
				return

	if (reporttype == "Template")
		reporter = sanitizeSafe(tgui_input_text(usr, "Please enter your CCIA name. (blank for CCIAAMS)", "Name"))
		if (reporter)
			reportbody += "\n\n- [reporter], Central Command Internal Affairs Agent, [commstation_name()]"
		else
			reportbody += "\n\n- CCIAAMS, [commstation_name()]"

	var/announce = tgui_alert(usr, "Should this be announced to the general population?", "Announcement", list("Yes","No"))
	switch(announce)
		if("Yes")
			command_announcement.Announce("[reportbody]", reporttitle, new_sound = 'sound/AI/commandreport.ogg', msg_sanitized = 1);
		if("No")
			to_world(SPAN_WARNING("New [SSatlas.current_map.company_name] Update available at all communication consoles."))
			sound_to_playing_players('sound/AI/commandreport.ogg')

	log_admin("[key_name(src)] has created a command report: [reportbody]")
	message_admins("[key_name_admin(src)] has created a command report", 1)
	feedback_add_details("admin_verb","CCR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	//New message handling
	post_comm_message(reporttitle, reportbody)

/client/proc/cmd_admin_delete(atom/O as obj|mob|turf in range(world.view))
	set category = "Admin"
	set name = "Delete"

	if (!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/action = alert(src, "Are you sure you want to delete:\n[O]\nat ([O.x], [O.y], [O.z])?", "Confirmation", "Yes", "No", "Hard Delete")

	if (action == "No" || !action)
		return

	if (istype(O, /mob/abstract/ghost/observer))
		var/mob/abstract/ghost/observer/M = O
		if (M.client && alert(src, "They are still connected. Are you sure, they will loose connection.", "Confirmation", "Yes", "No") != "Yes")
			return
	log_admin("[key_name(usr)] deleted [O] at ([O.x],[O.y],[O.z])")
	message_admins("[key_name_admin(usr)] deleted [O] at ([O.x],[O.y],[O.z])", 1)
	feedback_add_details("admin_verb","DEL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	if (isturf(O))	// Can't qdel a turf.
		var/turf/T = O
		T.ChangeTurf(/turf/space)
		return

	if (action == "Yes")
		qdel(O, TRUE)
	else
		// This is naughty, but sometimes necessary.
		O.Destroy(TRUE)	// Because direct del without this breaks things.
		del(O)

/client/proc/cmd_admin_list_open_jobs()
	set category = "Admin"
	set name = "List free slots"

	if (!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	for(var/datum/job/job in SSjobs.occupations)
		to_chat(src, "[job.title]: [job.get_total_positions() == -1 ? "unlimited" : job.get_total_positions()]")
	feedback_add_details("admin_verb","LFS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_explosion(atom/O as obj|mob|turf in range(world.view))
	set category = "Special Verbs"
	set name = "Explosion"

	if(!check_rights(R_DEBUG|R_FUN))	return

	var/devastation = input("Range of total devastation. -1 to none", "Input")  as num|null
	if(devastation == null) return
	var/heavy = input("Range of heavy impact. -1 to none", "Input")  as num|null
	if(heavy == null) return
	var/light = input("Range of light impact. -1 to none", "Input")  as num|null
	if(light == null) return
	var/flash = input("Range of flash. -1 to none", "Input")  as num|null
	if(flash == null) return

	if ((devastation != -1) || (heavy != -1) || (light != -1) || (flash != -1))
		if ((devastation > 20) || (heavy > 20) || (light > 20))
			if (alert(src, "Are you sure you want to do this? It will laaag.", "Confirmation", "Yes", "No") == "No")
				return

		explosion(O, devastation, heavy, light, flash)
		log_admin("[key_name(usr)] created an explosion ([devastation],[heavy],[light],[flash]) at ([O.x],[O.y],[O.z])")
		message_admins("[key_name_admin(usr)] created an explosion ([devastation],[heavy],[light],[flash]) at ([O.x],[O.y],[O.z])", 1)
		feedback_add_details("admin_verb","EXPL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return
	else
		return

/client/proc/cmd_admin_emp(atom/O as obj|mob|turf in range(world.view))
	set category = "Special Verbs"
	set name = "EM Pulse"

	if(!check_rights(R_DEBUG|R_FUN))	return

	var/heavy = input("Range of heavy pulse.", "Input")  as num|null
	if(heavy == null) return
	var/light = input("Range of light pulse.", "Input")  as num|null
	if(light == null) return

	if (heavy || light)

		empulse(O, heavy, light)
		log_admin("[key_name(usr)] created an EM Pulse ([heavy],[light]) at ([O.x],[O.y],[O.z])")
		message_admins("[key_name_admin(usr)] created an EM PUlse ([heavy],[light]) at ([O.x],[O.y],[O.z])", 1)
		feedback_add_details("admin_verb","EMP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

		return
	else
		return

/client/proc/cmd_admin_gib(mob/M as mob in GLOB.mob_list)
	set category = "Special Verbs"
	set name = "Gib"

	if(!check_rights(R_ADMIN|R_FUN))	return

	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm != "Yes") return
	//Due to the delay here its easy for something to have happened to the mob
	if(!M)	return

	log_admin("[key_name(usr)] has gibbed [key_name(M)]")
	message_admins("[key_name_admin(usr)] has gibbed [key_name_admin(M)]", 1)

	if(isobserver(M))
		gibs(M.loc, M.viruses)
		return

	M.gib()
	feedback_add_details("admin_verb","GIB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_gib_self()
	set name = "Gibself"
	set category = "Fun"

	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm == "Yes")
		if (istype(mob, /mob/abstract/ghost/observer)) // so they don't spam gibs everywhere
			return
		else
			mob.gib()

		log_admin("[key_name(usr)] used gibself.")
		message_admins(SPAN_NOTICE("[key_name_admin(usr)] used gibself."), 1)
		feedback_add_details("admin_verb","GIBS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_dust(mob/M as mob in GLOB.mob_list)
	set category = "Special Verbs"
	set name = "Turn to dust"

	if(!check_rights(R_ADMIN|R_FUN))
		return

	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm != "Yes")
		if(istype(mob, /mob/abstract/ghost/observer))
			return
		else
			mob.dust()

	log_admin("[key_name(usr)] has annihilated [key_name(M)]")
	message_admins("[key_name_admin(usr)] has annihilated [key_name_admin(M)]")
	feedback_add_details("admin_verb","DUST") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/*
/client/proc/cmd_manual_ban()
	set name = "Manual Ban"
	set category = "Special Verbs"
	if(!authenticated || !holder)
		to_chat(src, "Only administrators may use this command.")
		return
	var/mob/M = null
	switch(alert("How would you like to ban someone today?", "Manual Ban", "Key List", "Enter Manually", "Cancel"))
		if("Key List")
			var/list/keys = list()
			for(var/mob/M in world)
				keys += M.client
			var/selection = input("Please, select a player!", "Admin Jumping", null, null) as null|anything in keys
			if(!selection)
				return
			M = selection:mob
			if ((M.client && M.client.holder && (M.client.holder.level >= holder.level)))
				alert("You cannot perform this action. You must be of a higher administrative rank!")
				return

	switch(alert("Temporary Ban?",,"Yes","No"))
	if("Yes")
		var/mins = input(usr,"How long (in minutes)?","Ban time",1440) as num
		if(!mins)
			return
		if(mins >= 525600) mins = 525599
		var/reason = input(usr,"Reason?","reason","Griefer") as text
		if(!reason)
			return
		if(M)
			AddBan(M.ckey, M.computer_id, reason, usr.ckey, 1, mins)
			to_chat(M, "\red<BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG>")
			to_chat(M, "\red This is a temporary ban, it will be removed in [mins] minutes.")
			to_chat(M, "\red To try to resolve this matter head to http://ss13.donglabs.com/forum/")
			log_admin("[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.")
			message_admins("\blue[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.")
			world.Export("http://216.38.134.132/adminlog.php?type=ban&key=[usr.client.key]&key2=[M.key]&msg=[html_decode(reason)]&time=[mins]&server=[replacetext(GLOB.config.server_name, "#", "")]")
			del(M.client)
			qdel(M)
		else

	if("No")
		var/reason = input(usr,"Reason?","reason","Griefer") as text
		if(!reason)
			return
		AddBan(M.ckey, M.computer_id, reason, usr.ckey, 0, 0)
		to_chat(M, "\red<BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG>")
		to_chat(M, "\red This is a permanent ban.")
		to_chat(M, "\red To try to resolve this matter head to http://ss13.donglabs.com/forum/")
		log_admin("[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis is a permanent ban.")
		message_admins("\blue[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis is a permanent ban.")
		world.Export("http://216.38.134.132/adminlog.php?type=ban&key=[usr.client.key]&key2=[M.key]&msg=[html_decode(reason)]&time=perma&server=[replacetext(GLOB.config.server_name, "#", "")]")
		del(M.client)
		qdel(M)
*/

/client/proc/update_world()
	// If I see anyone granting powers to specific keys like the code that was here,
	// I will both remove their SVN access and permanently ban them from my servers.
	return

/client/proc/cmd_admin_check_contents(mob/living/M as mob in GLOB.mob_list)
	set category = "Special Verbs"
	set name = "Check Contents"

	var/list/L = M.get_contents()
	for(var/t in L)
		to_chat(usr, "[t]")
	feedback_add_details("admin_verb","CC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/* This proc is DEFERRED. Does not do anything.
/client/proc/cmd_admin_remove_phoron()
	set category = "Debug"
	set name = "Stabilize Atmos."
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	feedback_add_details("admin_verb","STATM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
// DEFERRED
	spawn(0)
		for(var/turf/T in view())
			T.poison = 0
			T.oldpoison = 0
			T.tmppoison = 0
			T.oxygen = 755985
			T.oldoxy = 755985
			T.tmpoxy = 755985
			T.co2 = 14.8176
			T.oldco2 = 14.8176
			T.tmpco2 = 14.8176
			T.n2 = 2.844e+006
			T.on2 = 2.844e+006
			T.tn2 = 2.844e+006
			T.tsl_gas = 0
			T.osl_gas = 0
			T.sl_gas = 0
			T.temp = 293.15
			T.otemp = 293.15
			T.ttemp = 293.15
*/

/client/proc/toggle_view_range()
	set category = "Special Verbs"
	set name = "Change View Range"
	set desc = "switches between 1x and custom views"

	if(view == world.view)
		view = input("Select view range:", "FUCK YE", 7) in list(1,2,3,4,5,6,7,8,9,10,11,12,13,14,128)
	else
		view = world.view

	log_admin("[key_name(usr)] changed their view range to [view].")
	//message_admins("\blue [key_name_admin(usr)] changed their view range to [view].", 1)	//why? removed by order of XSI

	feedback_add_details("admin_verb","CVRA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/admin_call_shuttle()

	set category = "Admin"
	set name = "Call Evacuation"

	if ((!( ROUND_IS_STARTED ) || !GLOB.evacuation_controller))
		return

	if(!check_rights(R_ADMIN))
		return

	if(alert(src, "Are you sure?", "Confirm", "Yes", "No") != "Yes")
		return

	if(SSatlas.current_map.shuttle_call_restarts)
		if(SSatlas.current_map.shuttle_call_restart_timer)
			to_chat(usr, SPAN_WARNING("The shuttle round restart timer is already active!"))
			return
		feedback_add_details("admin_verb","CSHUT")
		SSatlas.current_map.shuttle_call_restart_timer = addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(reboot_world)), 10 MINUTES, TIMER_UNIQUE|TIMER_STOPPABLE)
		log_game("[key_name(usr)] has admin-called the 'shuttle' round restart.")
		message_admins("[key_name_admin(usr)] has admin-called the 'shuttle' round restart.", 1)
		to_world(FONT_LARGE(SPAN_VOTE(SSatlas.current_map.shuttle_called_message)))
		return

	if(SSticker.mode.auto_recall_shuttle)
		if(input("The evacuation will just be cancelled if you call it. Call anyway?") in list("Confirm", "Cancel") != "Confirm")
			return

	var/choice = input("Is this an emergency evacuation, bluespace jump, or a crew transfer?") in list(TRANSFER_EMERGENCY, TRANSFER_CREW, TRANSFER_JUMP)
	GLOB.evacuation_controller.call_evacuation(usr, choice)


	feedback_add_details("admin_verb","CSHUT") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] admin-called an evacuation.")
	message_admins(SPAN_NOTICE("[key_name_admin(usr)] admin-called an evacuation"), 1)
	return

/client/proc/admin_cancel_shuttle()
	set category = "Admin"
	set name = "Cancel Evacuation"

	if(!check_rights(R_ADMIN))	return

	if(alert(src, "You sure?", "Confirm", "Yes", "No") != "Yes") return

	if(!ROUND_IS_STARTED || !GLOB.evacuation_controller)
		return

	if(SSatlas.current_map.shuttle_call_restarts)
		if(!SSatlas.current_map.shuttle_call_restart_timer)
			to_chat(usr, SPAN_WARNING("The restart timer for this map isn't active!"))
			return
		feedback_add_details("admin_verb","CCSHUT")
		deltimer(SSatlas.current_map.shuttle_call_restart_timer)
		SSatlas.current_map.shuttle_call_restart_timer = null
		log_game("[key_name(usr)] has admin-stopped the 'shuttle' round restart.", key_name(usr))
		message_admins("[key_name_admin(usr)] has admin-stopped the 'shuttle' round restart.", 1)
		to_world(FONT_LARGE(SPAN_VOTE(SSatlas.current_map.shuttle_recall_message)))
		return


	GLOB.evacuation_controller.cancel_evacuation()
	feedback_add_details("admin_verb","CCSHUT") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] admin-cancelled the evacuation.")
	message_admins(SPAN_NOTICE("[key_name_admin(usr)] admin-cancelled the evacuation."), 1)

	return

/client/proc/admin_deny_shuttle()
	set category = "Admin"
	set name = "Toggle Deny Evacuation"

	if (!ROUND_IS_STARTED)
		return

	if(!check_rights(R_ADMIN))
		return

	GLOB.evacuation_controller.deny = !GLOB.evacuation_controller.deny

	log_admin("[key_name(src)] has [GLOB.evacuation_controller.deny ? "denied" : "allowed"] the evacuation to be called.")
	message_admins("[key_name_admin(usr)] has [GLOB.evacuation_controller.deny ? "denied" : "allowed"] the evacuation to be called.")

/client/proc/cmd_admin_attack_log(mob/M as mob in GLOB.mob_list)
	set category = "Special Verbs"
	set name = "Attack Log"

	to_chat(usr, SPAN_DANGER("Attack Log for [mob]"))
	for(var/t in M.attack_log)
		to_chat(usr, t)
	feedback_add_details("admin_verb","ATTL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/everyone_random()
	set category = "Fun"
	set name = "Make Everyone Random"
	set desc = "Make everyone have a random appearance. You can only use this before rounds!"

	if(!check_rights(R_FUN))	return

	if (SSticker.mode)
		to_chat(usr, "Nope you can't do this, the game's already started. This only works before rounds!")
		return

	if(SSticker.random_players)
		SSticker.random_players = 0
		message_admins("Admin [key_name_admin(usr)] has disabled \"Everyone is Special\" mode.", 1)
		to_chat(usr, "Disabled.")
		return


	var/notifyplayers = alert(src, "Do you want to notify the players?", "Options", "Yes", "No", "Cancel")
	if(notifyplayers == "Cancel")
		return

	log_admin("Admin [key_name(src)] has forced the players to have random appearances.")
	message_admins("Admin [key_name_admin(usr)] has forced the players to have random appearances.", 1)

	if(notifyplayers == "Yes")
		to_world(SPAN_NOTICE("<b>Admin [usr.key] has forced the players to have completely random identities!</b>"))

	to_chat(usr, "<i>Remember: you can always disable the randomness by using the verb again, assuming the round hasn't started yet</i>.")

	SSticker.random_players = 1
	feedback_add_details("admin_verb","MER") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/toggle_random_events()
	set category = "Server"
	set name = "Toggle random events on/off"

	set desc = "Toggles random events such as meteors, black holes, blob (but not space dust) on/off"
	if(!check_rights(R_SERVER))	return

	if(!GLOB.config.allow_random_events)
		GLOB.config.allow_random_events = 1
		to_chat(usr, "Random events enabled")
		message_admins("Admin [key_name_admin(usr)] has enabled random events.", 1)
	else
		GLOB.config.allow_random_events = 0
		to_chat(usr, "Random events disabled")
		message_admins("Admin [key_name_admin(usr)] has disabled random events.", 1)
	feedback_add_details("admin_verb","TRE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/fab_tip()
	set category = "Admin"
	set name = "Fabricate Tip"
	set desc = "Sends a tip (that you specify) to all players. After all \
		you're the experienced player here."

	if(!holder)
		return

	var/input = input(usr, "Please specify your tip that you want to send to the players.", "Tip", "") as message|null
	if(!input)
		return

	SSticker.send_tip_of_the_round(input)

	message_admins("[key_name_admin(usr)] sent a tip of the round.")
	log_admin("[key_name(usr)] sent \"[input]\" as the Tip of the Round.")
	feedback_add_details("admin_verb","TIP")

/client/proc/show_tip()
	set category = "Debug"
	set name = "Show Tip"
	set desc = "Sends a random tip to all players. After all \
		you're not the experienced player here."

	if(!holder)
		return

	var/list/possible_categories = list("Random") + GLOB.tips_by_category.Copy()
	var/input = input(usr, "Please specify the tip category that you want to send to the players.", "Tip", "Random") as null|anything in possible_categories
	if(!input)
		return

	var/datum/tip/tip_datum
	if(input == "Random")
		var/chosen_tip_category = pick(GLOB.tips_by_category)
		tip_datum = GLOB.tips_by_category[chosen_tip_category]
	else
		tip_datum = GLOB.tips_by_category[input]

	SSticker.send_tip_of_the_round(pick(tip_datum.messages))


	message_admins("[key_name_admin(usr)] sent a pregenerated tip of the round.")
	log_admin("[key_name(usr)] sent a pregenerated Tip of the Round.")
	feedback_add_details("admin_verb","FAP")
