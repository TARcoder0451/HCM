SELECT 
			papf.person_number
			,ppnf.display_name as FULL_NAME
			,pd.name
			,
			(
				SELECT papfsup1.person_number FROM per_person_names_f ppnfsup1 ,per_all_assignments_m paamsup1 ,per_all_people_f papfsup1 ,per_asg_responsibilities par_dep_man1 WHERE paam.effective_latest_change = 'Y' AND paam.assignment_type IN ( 'E' ,'C' ,'N' ,'P' ) AND paam.person_id = papf.person_id AND TRUNC(:p_exception_date) BETWEEN paam.effective_start_date AND paam.effective_end_date AND TRUNC(:p_exception_date) BETWEEN papf.effective_start_date AND papf.effective_end_date AND paam.business_unit_id = paamsup1.business_unit_id AND paamsup1.effective_latest_change = 'Y' AND paamsup1.assignment_type IN ( 'E' ,'C' ,'N' ,'P' ) AND paamsup1.person_id = ppnfsup1.person_id AND ppnfsup1.name_type = 'GLOBAL' AND paamsup1.person_id = papfsup1.person_id AND par_dep_man1.person_id = papfsup1.person_id AND par_dep_man1.responsibility_type = 'SECTION_HEAD' AND rownum = 1 
			) SECTION_HEAD_Pno
			,
			(
				SELECT ppnfsup1.display_name FROM per_person_names_f ppnfsup1 ,per_all_assignments_m paamsup1 ,per_all_people_f papfsup1 ,per_asg_responsibilities par_dep_man1 WHERE paam.effective_latest_change = 'Y' AND paam.assignment_type IN ( 'E' ,'C' ,'N' ,'P' ) AND paam.person_id = papf.person_id AND TRUNC(:p_exception_date) BETWEEN paam.effective_start_date AND paam.effective_end_date AND TRUNC(:p_exception_date) BETWEEN papf.effective_start_date AND papf.effective_end_date AND paam.business_unit_id = paamsup1.business_unit_id AND paamsup1.effective_latest_change = 'Y' AND paamsup1.assignment_type IN ( 'E' ,'C' ,'N' ,'P' ) AND paamsup1.person_id = ppnfsup1.person_id AND ppnfsup1.name_type = 'GLOBAL' AND paamsup1.person_id = papfsup1.person_id AND par_dep_man1.person_id = papfsup1.person_id AND par_dep_man1.responsibility_type = 'SECTION_HEAD' AND rownum = 1 
			) SECTION_HEAD_name
			,
			(
				SELECT papfsup1.person_number FROM per_person_names_f ppnfsup1 ,per_all_assignments_m paamsup1 ,per_all_people_f papfsup1 ,per_asg_responsibilities par_dep_man1 WHERE paam.effective_latest_change = 'Y' AND paam.assignment_type IN ( 'E' ,'C' ,'N' ,'P' ) AND paam.person_id = papf.person_id AND TRUNC(:p_exception_date) BETWEEN paam.effective_start_date AND paam.effective_end_date AND TRUNC(:p_exception_date) BETWEEN papf.effective_start_date AND papf.effective_end_date AND paam.business_unit_id = paamsup1.business_unit_id AND paamsup1.effective_latest_change = 'Y' AND paamsup1.assignment_type IN ( 'E' ,'C' ,'N' ,'P' ) AND paamsup1.person_id = ppnfsup1.person_id AND ppnfsup1.name_type = 'GLOBAL' AND paamsup1.person_id = papfsup1.person_id AND par_dep_man1.person_id = papfsup1.person_id AND par_dep_man1.responsibility_type = 'DEPARTMENT_MANAGER' AND rownum = 1 
			) DEPARTMENT_MANAGER_Pno
			,
			(
				SELECT ppnfsup1.display_name FROM per_person_names_f ppnfsup1 ,per_all_assignments_m paamsup1 ,per_all_people_f papfsup1 ,per_asg_responsibilities par_dep_man1 WHERE paam.effective_latest_change = 'Y' AND paam.assignment_type IN ( 'E' ,'C' ,'N' ,'P' ) AND paam.person_id = papf.person_id AND TRUNC(:p_exception_date) BETWEEN paam.effective_start_date AND paam.effective_end_date AND TRUNC(:p_exception_date) BETWEEN papf.effective_start_date AND papf.effective_end_date AND paam.business_unit_id = paamsup1.business_unit_id AND paamsup1.effective_latest_change = 'Y' AND paamsup1.assignment_type IN ( 'E' ,'C' ,'N' ,'P' ) AND paamsup1.person_id = ppnfsup1.person_id AND ppnfsup1.name_type = 'GLOBAL' AND paamsup1.person_id = papfsup1.person_id AND par_dep_man1.person_id = papfsup1.person_id AND par_dep_man1.responsibility_type = 'DEPARTMENT_MANAGER' AND rownum = 1 
			) DEPARTMENT_MANAGER_name
			,papfm.person_number Manager_Pno
			,ppnfsup.display_name Manager_Fullname
			, '1' AS DURATION
			, to_char(:p_exception_date-1,'DD-MM-YYYY') As Absent_Date
			
		FROM 
				per_all_assignments_m paam 
				,per_all_people_f papf
				,per_person_names_f ppnf
				,per_assignment_supervisors_f pasf
				,per_person_names_f ppnfsup
				,per_all_assignments_m paamsup 
				,per_all_people_f papfm
				,per_departments pd
			
		WHERE 
			
				:p_exception_date-1 /* date '2023-08-07' */ BETWEEN paam.effective_start_date AND paam.effective_end_date 
				AND papf.person_id = paam.person_id 
				AND :p_exception_date-1/* date '2023-08-07' */ BETWEEN papf.effective_start_date AND papf.effective_end_date 
				AND paam.effective_latest_change = 'Y'
				AND paam.assignment_type in ('E','C','N','P')
				
				--AND papf.person_number = '12960'
				
				AND paam.person_id = ppnf.person_id
				AND :p_exception_date BETWEEN ppnf.effective_start_date AND ppnf.effective_end_date
				AND ppnf.name_type = 'GLOBAL'
				
				and paam.assignment_id = pasf.assignment_id (+)
				and pasf.manager_assignment_id = paamsup.assignment_id (+)
				
				AND :p_exception_date /* date '2023-08-07' */ BETWEEN paamsup.effective_start_date AND paamsup.effective_end_date 
				
				AND :p_exception_date /* date '2023-08-07' */ BETWEEN papfm.effective_start_date AND papfm.effective_end_date 
				
				AND paamsup.person_id = ppnfsup.person_id
				AND :p_exception_date BETWEEN ppnfsup.effective_start_date AND ppnfsup.effective_end_date
				AND ppnfsup.name_type = 'GLOBAL'
				AND pasf.MANAGER_TYPE(+) = 'LINE_MANAGER'
				
				AND papfm.person_id = pasf.manager_id
				AND PD.ORGANIZATION_ID (+) = PAAM.ORGANIZATION_ID
				AND TRUNC(:p_exception_date-1) BETWEEN PD.EFFECTIVE_START_DATE (+) AND PD.EFFECTIVE_END_DATE (+)
				
			
			AND NOT EXISTS(
				SELECT 1
				FROM 
				PER_PERIODS_OF_SERVICE PPOS1
			, ANC_PER_ABS_ENTRIES APAE1
			WHERE PAPF.PERSON_ID = PPOS1.PERSON_ID
			AND APAE1.PERIOD_OF_SERVICE_ID = PPOS1.PERIOD_OF_SERVICE_ID
			AND TRUNC(:p_exception_date-1) BETWEEN APAE1.start_date and APAE1.end_date

			)
		
			AND NOT EXISTS(
			SELECT   1
			FROM  
			TABLE (hts_ff_util.hts_get_scheduled_shifts(

			  p_resource_id => to_char(PAAM.person_id),

			  p_start_time => to_date(:p_exception_date-1),

			  p_stop_time => (:p_exception_date),

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
				htrev.day_delete_flag IS NULL 
				AND htrev.day_latest_version = 'Y' 
				AND htrev.tc_delete_flag IS NULL 
				AND htrev.tc_latest_version = 'Y' 
				AND htrev.te_delete_flag IS NULL 
				AND htrev.te_latest_version = 'Y' 
				AND htrev.anc_latest_version = 'Y' 
				AND htrev.anc_delete_flag IS NULL 
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