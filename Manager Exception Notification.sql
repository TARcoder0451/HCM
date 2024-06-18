SELECT 
		htrev.te_start_time ST,
		TO_char(htrev.te_start_time,'HH:MI') as start_time, 
		TO_char(htrev.te_stop_time,'HH:MI') as stop_time, 
		INITCAP(REPLACE(lower(hfmv.MESSAGE_NAME), '_', ' ')) MESSAGE_NAME,
		tkns.TOKEN_VAL_VARCHAR EXP_DUR,
		hfmv.message_text,
		hfmv.message_number,
		papf.person_number,
		ppnf.full_name,
	to_char (nvl(htrev.te_start_time,htrev.te_stop_time),'DD-Mon-YYYY','NLS_DATE_LANGUAGE=American') exception_date,
		papfm.person_number manager_person_number,
		paamsup.person_id Manager_person_id,
		ppnfsup.full_name Manager_Name
		,htrev.te_comment_text
		,paam.assignment_id 
	FROM 
		hwm_tm_rpt_entry_v htrev
		,hwm_tm_allow_exps_v htaev 
		,hwm_fnd_messages_vl hfmv 
		,per_all_assignments_m paam 
		,per_all_people_f papf
		,per_person_names_f ppnf
		,per_assignment_supervisors_f pasf
		,per_person_names_f ppnfsup
		,per_all_assignments_m paamsup 
		,per_all_people_f papfm
		,HWM_TM_REP_MSG_TKNS tkns
		
	WHERE 
		 	htrev.day_latest_version='Y' AND htrev.tc_latest_version='Y' AND htrev.te_latest_version='Y' AND htrev.anc_latest_version='Y' AND nvl(htrev.TC_DELETE_FLAG,'N')='N' AND nvl(htrev.TE_DELETE_FLAG,'N')='N' AND nvl(htrev.ANC_DELETE_FLAG,'N')='N' AND nvl(htrev.DAY_DELETE_FLAG ,'N') = 'N' 
		AND htaev.message_name = hfmv.message_name 
		AND htaev.application_short_name = hfmv.application_short_name 
		AND trunc(:p_exception_date) BETWEEN paam.effective_start_date AND paam.effective_end_date 
		AND papf.person_id = paam.person_id 
		AND trunc(:p_exception_date)  BETWEEN papf.effective_start_date AND papf.effective_end_date 

		AND paam.effective_latest_change = 'Y'
		AND paam.assignment_type in ('E','C','N','P')
		AND htrev.te_tm_rec_id = htaev.tm_bldg_blk_id(+) 
		AND trunc(htaev.Date_to) = to_date ('4712/12/31','YYYY/MM/DD')
		AND htrev.te_subresource_id = paam.assignment_id 
		AND 
		(
			NOT
			(
				hfmv.message_text IS NULL
			)
		)
		AND paam.person_id = ppnf.person_id
		AND trunc(:p_exception_date) BETWEEN ppnf.effective_start_date AND ppnf.effective_end_date
		AND ppnf.name_type = 'GLOBAL'
		and paam.assignment_id = pasf.assignment_id (+)
		and pasf.manager_assignment_id = paamsup.assignment_id (+)
		
		AND trunc(:p_exception_date) BETWEEN paamsup.effective_start_date AND paamsup.effective_end_date 
		AND trunc(:p_exception_date) BETWEEN papfm.effective_start_date AND papfm.effective_end_date 	
		AND paamsup.person_id = ppnfsup.person_id
		AND trunc(:p_exception_date) BETWEEN ppnfsup.effective_start_date AND ppnfsup.effective_end_date
		AND trunc(:p_exception_date) BETWEEN pasf.effective_start_date AND pasf.effective_end_date
		AND ppnfsup.name_type = 'GLOBAL'
		AND pasf.MANAGER_TYPE(+) = 'LINE_MANAGER'
		and htaev.TM_REP_MSGS_ID = tkns.TM_REP_MSGS_ID (+)
	    and tkns.TOKEN_NAME(+) = 'EXP_DUR'	
		AND papfm.person_id = pasf.manager_id
		AND trunc(htrev.te_start_time) BETWEEN trunc((:p_exception_date)-8) AND trunc((:p_exception_date)-2)
				order by htrev.te_start_time desc