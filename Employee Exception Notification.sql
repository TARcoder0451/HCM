SELECT 
        to_char(htrev.te_start_time,'DD-Mon-YYYY') Start_date,
	TO_char(htrev.te_start_time,'HH24:MI') as start_time, 
	TO_char(htrev.te_stop_time,'HH24:MI') as stop_time, 
	replace(hfmv.message_text,'{EXP_DUR}',nvl(tkns.TOKEN_VAL_VARCHAR,'')) message_text,
	INITCAP(REPLACE(lower(hfmv.MESSAGE_NAME), '_', ' ')) MESSAGE_NAME,
	--hfmv.MESSAGE_NAME,
	tkns.TOKEN_VAL_VARCHAR EXP_DUR,
	papf.person_number,
	ppnf.full_name,
	htrev.te_start_time,
       paam.assignment_id,
to_char (nvl(htrev.te_start_time,htrev.te_stop_time),'DD-Mon-YYYY','NLS_DATE_LANGUAGE=American') exception_date
-- htaev.*
	,htrev.TC_CREATION_DATE
	,pd.name
	,htaev.TM_BLDG_BLK_ID  time_id
	,papf.person_id person_Id
	,to_char(htrev.te_start_time,'YYYY-MM-DD') earnedDate
	
FROM 
	hwm_tm_rpt_entry_v htrev, 
	hwm_tm_allow_exps_v htaev, 
	hwm_fnd_messages_vl hfmv, 
	per_all_assignments_m paam, 
	per_persons pp, 
	per_all_people_f papf,
	per_person_names_f ppnf,
	per_departments pd,
	HWM_TM_REP_MSG_TKNS tkns
	
WHERE 
	htrev.day_latest_version='Y' AND htrev.tc_latest_version='Y' AND htrev.te_latest_version='Y' AND htrev.anc_latest_version='Y' AND nvl(htrev.TC_DELETE_FLAG,'N')='N' AND nvl(htrev.TE_DELETE_FLAG,'N')='N' AND nvl(htrev.ANC_DELETE_FLAG,'N')='N' AND nvl(htrev.DAY_DELETE_FLAG ,'N') = 'N'
	AND htaev.message_name = hfmv.message_name 
	AND htaev.application_short_name = hfmv.application_short_name 
	AND trunc(htaev.DATE_TO) = to_date('31/12/4712','DD/MM/YYYY')
	AND pp.person_id = papf.person_id 
	AND pp.person_id = paam.person_id 
	--AND SYSDATE -1/* date '2023-08-07' */ BETWEEN paam.effective_start_date AND paam.effective_end_date 
	AND paam.effective_latest_change = 'Y'
	AND paam.assignment_type in ('E','C','N','P')
	AND htrev.te_tm_rec_id = htaev.tm_bldg_blk_id(+) 
	-- AND htrev.te_tm_rec_version = htaev.tm_bldg_blk_version(+) 
	AND htrev.te_subresource_id = paam.assignment_id 
    AND 
	(
		NOT
		(
            hfmv.message_text IS NULL
		)
    )
	AND paam.person_id = ppnf.person_id
	AND ppnf.name_type = 'GLOBAL'
	
	--AND htaev.message_level = 'ERROR'
	AND pd.organization_id = paam.organization_id
	and htaev.TM_REP_MSGS_ID = tkns.TM_REP_MSGS_ID (+)
	and tkns.TOKEN_NAME(+) = 'EXP_DUR'
-- AND hfmv.message_number<>3750051

AND trunc(:p_exception_date-1) /* date '2023-08-07' */ BETWEEN paam.effective_start_date AND paam.effective_end_date 
AND trunc(:p_exception_date-1)/* date '2023-08-07' */ BETWEEN papf.effective_start_date AND papf.effective_end_date 
AND trunc(:p_exception_date-1) BETWEEN ppnf.effective_start_date AND ppnf.effective_end_date
AND trunc(htrev.te_start_time) = trunc(:p_exception_date-1)
AND trunc(:p_exception_date-1) /* date '2023-08-07' */ BETWEEN pd.effective_start_date AND pd.effective_end_date