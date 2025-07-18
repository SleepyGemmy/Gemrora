/datum/event/communications_blackout
	no_fake = 1
	var/damage_machinery = 0

/datum/event/communications_blackout/damage_machinery
	damage_machinery = 1

/datum/event/communications_blackout/announce()
	var/alert = pick(	"Ionospheric anomalies detected. Temporary telecommunication failure imminent. Please contact you*%fj00)`5vc-BZZT", \
						"Ionospheric anomalies detected. Temporary telecommunication failu*3mga;b4;'1v-BZZZT", \
						"Ionospheric anomalies detected. Temporary telec#MCi46:5.;@63-BZZZZT", \
						"Ionospheric anomalies dete'fZ\\kg5_0-BZZZZZT", \
						"Ionospheri:% MCayj^j<.3-BZZZZZZT", \
						"#4nd%;f4y6,>%-BZZZZZZZT")

	for(var/mob/living/silicon/ai/A in GLOB.player_list)	//AIs are always aware of communication blackouts.
		if(A.z in affecting_z)
			to_chat(A, "<br>")
			to_chat(A, SPAN_WARNING("<b>[alert]</b>"))
			to_chat(A, "<br>")

	if(prob(30))	//most of the time, we don't want an announcement, so as to allow AIs to fake blackouts.
		command_announcement.Announce(alert, zlevels = affecting_z)
		return
	return 1


/datum/event/communications_blackout/start()
	..()

	for(var/obj/machinery/telecomms/T in SSmachinery.all_telecomms)
		if(T.z in affecting_z)
			T.emp_act(EMP_HEAVY)
		// 10% chance for a given machine to take damage: slight delays in transmission time or slight message garbling until repaired.
		if(damage_machinery && prob(10))
			T.emp_damage()
