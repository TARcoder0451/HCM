SELECT 
	papf.person_number Employee_Number,
(SELECT   SCHEDULED_START_TIME
			  
			FROM  
			TABLE (hts_ff_util.hts_get_scheduled_shifts(
 
			  p_resource_id => to_char(paam.person_id),
 
			  p_start_time => :p_exception_date,
 
			  p_stop_time => to_date(:p_exception_date+1),
 
			  p_assignment_id =>to_char(paam.assignment_id))
			  )
	) scheduled_start_time
	,(SELECT   SCHEDULED_STOP_TIME
			FROM  
			TABLE (hts_ff_util.hts_get_scheduled_shifts(
 
			  p_resource_id => to_char(paam.person_id),
 
			  p_start_time => :p_exception_date,
 
			  p_stop_time => to_date(:p_exception_date+1),
 
			  p_assignment_id =>to_char(paam.assignment_id))
			  )
	) scheduled_end_time

FROM 
	per_all_assignments_f paam,
	per_person_names_f ppnf,
	per_all_people_f papf

WHERE 1 = 1
	and TRUNC(:p_exception_date-1) BETWEEN papf.effective_start_date
		AND papf.effective_end_date
	--Assignment
	AND papf.person_id = paam.person_id
	AND TRUNC(:p_exception_date-1) BETWEEN paam.effective_start_date
		AND paam.effective_end_date
	AND paam.assignment_type = 'E'
	AND paam.primary_Flag = 'Y'
	--PersonName
	AND papf.person_id = ppnf.person_id
	AND TRUNC(:p_exception_date-1) BETWEEN ppnf.effective_StarT_Date AND ppnf.effective_End_Date
	AND ppnf.name_type = 'GLOBAL'
	AND NOT EXISTS(
				SELECT 1
				FROM 
				PER_PERIODS_OF_SERVICE PPOS1
			, ANC_PER_ABS_ENTRIES APAE1
			WHERE PAPF.PERSON_ID = PPOS1.PERSON_ID
			AND APAE1.PERIOD_OF_SERVICE_ID = PPOS1.PERIOD_OF_SERVICE_ID
			AND TRUNC(:p_exception_date-1) BETWEEN APAE1.start_date and APAE1.end_date
			AND apae1.approval_status_cd = 'APPROVED'
			AND  apae1.absence_status_cd = 'SUBMITTED'
		)
		AND EXISTS(
			SELECT   1
			FROM  
			TABLE (hts_ff_util.hts_get_scheduled_shifts(
 
			  p_resource_id => to_char(paam.person_id),
 
			  p_start_time => :p_exception_date,
 
			  p_stop_time => to_date(:p_exception_date+1),
 
			  p_assignment_id =>to_char(paam.assignment_id))
			  ) ds
			)
			AND NOT EXISTS(
			SELECT   1
			FROM  
				hwm_tm_rpt_entry_v htrev
				,hwm_tm_allow_exps_v htaev 
				,hwm_fnd_messages_vl hfmv 
			WHERE
				/* htrev.day_delete_flag IS NULL 
				AND */ htrev.day_latest_version = 'Y' 
				--AND htrev.tc_delete_flag IS NULL 
				AND htrev.tc_latest_version = 'Y' 
				--AND htrev.te_delete_flag IS NULL 
				AND htrev.te_latest_version = 'Y' 
				AND htrev.anc_latest_version = 'Y' 
				--AND htrev.anc_delete_flag IS NULL 
				AND htrev.te_tm_rec_id = htaev.tm_bldg_blk_id(+) 
				AND htrev.te_tm_rec_version = htaev.tm_bldg_blk_version(+) 
				AND htrev.te_subresource_id = paam.assignment_id 
				AND trunc(htrev.te_start_time) = trunc(:p_exception_date-1)
				AND htaev.message_name = hfmv.message_name 
				AND htaev.application_short_name = hfmv.application_short_name 
				AND 
					(
						NOT
						(
							hfmv.message_text IS NULL
						)
					)
			)
