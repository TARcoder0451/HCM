SELECT 
    --htrev.te_start_time ST
	/* NVL(TO_char(htrev.te_start_time,'HH24:MI'), TO_char(htrev.te_stop_time,'HH24:MI')) start_time
	,NVL(TO_char(htrev.te_stop_time,'HH24:MI'), TO_char(htrev.te_start_time,'HH24:MI')) end_time */
	(
		case 
			when htrev.te_stop_time is null then htrev.te_start_time + 1 /(24*60)
			else htrev.te_stop_time - 1 /(24*60)
		 end
	) request_time 
	,hfmv.message_text
	,papf.person_number
	,ppnf.full_name
	,to_char (nvl(htrev.te_start_time,htrev.te_stop_time),'DD-Mon-YYYY','NLS_DATE_LANGUAGE=American') exception_date
	,htrev.TC_CREATION_DATE
	/* ,pd.name
	,htrev.TC_TM_REC_GRP_ID time_entry_id
	,htrev.TC_TM_REC_GRP_VERSION version_id */
	,(
		case 
			when htrev.te_stop_time is not null then 'QS_AUTO_IN' 
			else 'QS_AUTO_OUT'
		 end
	) error_type 
	
FROM 
	hwm_tm_rpt_entry_v htrev, 
	hwm_tm_allow_exps_v htaev, 
	hwm_fnd_messages_vl hfmv, 
	per_all_assignments_m paam, 
	per_persons pp, 
	per_all_people_f papf,
	per_person_names_f ppnf,
	per_departments pd
	,hwm_tm_rep_m_ptt_atrbs_v htrm
	
WHERE 

	
	1=1
	AND nvl(htrev.TC_DELETE_FLAG,'N')='N' AND nvl(htrev.TE_DELETE_FLAG,'N')='N' AND nvl(htrev.ANC_DELETE_FLAG,'N')='N' AND nvl(htrev.DAY_DELETE_FLAG ,'N') = 'N'
	AND papf.person_number = '11042' 
	AND htrev.day_latest_version = 'Y' 
	AND htrev.tc_latest_version = 'Y' 
	AND htrev.te_latest_version = 'Y' 
	AND htrev.anc_latest_version = 'Y' 
	AND htaev.message_name = hfmv.message_name 
	AND htaev.application_short_name = hfmv.application_short_name 
	AND trunc(htaev.DATE_TO) = to_date('31/12/4712','DD/MM/YYYY')
	AND trunc(:p_exception_date-1) /* date '2023-08-07' */ BETWEEN paam.effective_start_date AND paam.effective_end_date 
	AND pp.person_id = papf.person_id 
	AND pp.person_id = paam.person_id 
	AND trunc(:p_exception_date-1)/* date '2023-08-07' */ BETWEEN papf.effective_start_date AND papf.effective_end_date 
	--AND SYSDATE -1/* date '2023-08-07' */ BETWEEN paam.effective_start_date AND paam.effective_end_date 
	AND paam.effective_latest_change = 'Y'
	AND paam.assignment_type in ('E','C','N','P')
	AND htrev.te_tm_rec_id = htaev.tm_bldg_blk_id(+) 
	AND htrev.te_tm_rec_version = htaev.tm_bldg_blk_version(+) 
	AND htrev.te_subresource_id = paam.assignment_id 

    AND 
	(
		NOT
		(
            hfmv.message_text IS NULL
		)
    )
	AND paam.person_id = ppnf.person_id
	AND trunc(:p_exception_date-1) BETWEEN ppnf.effective_start_date AND ppnf.effective_end_date
	AND ppnf.name_type = 'GLOBAL'
	
	--AND htaev.message_level = 'ERROR'
	AND (
		case 
			when htrev.te_stop_time is null then trunc(htrev.te_start_time) 
			else trunc(htrev.te_stop_time)
		 end
	) = trunc(:p_exception_date-1)
	
	AND pd.organization_id = paam.organization_id
	AND trunc(:p_exception_date-1) /* date '2023-08-07' */ BETWEEN pd.effective_start_date AND pd.effective_end_date
	AND hfmv.message_number=3750051
	AND htrev.TE_TM_REC_ID = htrm.USAGES_SOURCE_ID(+)
    AND htrev.TE_TM_REC_VERSION = htrm.USAGES_SOURCE_VERSION(+)
	AND htrm.PAY_PAYROLL_TIME_TYPE like ('%Regular%')