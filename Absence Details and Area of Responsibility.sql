select 
	/*To count the number of days absence*/
	( SELECT count(*) FROM TABLE (hts_ff_util.hts_get_scheduled_shifts( p_resource_id => to_char(paam.person_id), p_start_time => (SELECT max(trunc(htrev.te_stop_time)+1) FROM hwm_tm_rpt_entry_v htrev WHERE /* htrev.day_delete_flag IS NULL AND */ htrev.day_latest_version = 'Y' AND nvl(htrev.TC_DELETE_FLAG,'N')='N' AND nvl(htrev.TE_DELETE_FLAG,'N')='N' AND nvl(htrev.ANC_DELETE_FLAG,'N')='N' AND nvl(htrev.DAY_DELETE_FLAG ,'N') = 'N' AND htrev.tc_latest_version = 'Y' /* AND htrev.te_delete_flag IS NULL */ AND htrev.te_latest_version = 'Y' AND htrev.anc_latest_version = 'Y' /* AND htrev.anc_delete_flag IS NULL */ AND trunc(htrev.te_stop_time) < trunc(:p_exception_date)AND htrev.te_subresource_id = paam.assignment_id   group by papf.person_id) , p_stop_time => (SELECT max(trunc(htrev.te_stop_time)) FROM hwm_tm_rpt_entry_v htrev WHERE /* htrev.day_delete_flag IS NULL AND */ htrev.day_latest_version = 'Y' AND nvl(htrev.TC_DELETE_FLAG,'N')='N' AND nvl(htrev.TE_DELETE_FLAG,'N')='N' AND nvl(htrev.ANC_DELETE_FLAG,'N')='N' AND nvl(htrev.DAY_DELETE_FLAG ,'N') = 'N' AND htrev.tc_latest_version = 'Y' /* AND htrev.te_delete_flag IS NULL */ AND htrev.te_latest_version = 'Y' AND htrev.anc_latest_version = 'Y' /* AND htrev.anc_delete_flag IS NULL */ AND trunc(htrev.te_stop_time) = trunc(:p_exception_date) AND htrev.te_subresource_id = paam.assignment_id  group by papf.person_id) , p_assignment_id =>to_char(paam.assignment_id)) ) ds ) DURATION
	
	/*To get the end date of the employee's is absence*/
	,to_char(( SELECT max(SCHEDULED_START_TIME) FROM TABLE (hts_ff_util.hts_get_scheduled_shifts( p_resource_id => to_char(paam.person_id), p_start_time => (SELECT max(trunc(htrev.te_stop_time)+1) FROM hwm_tm_rpt_entry_v htrev WHERE /* htrev.day_delete_flag IS NULL AND */ htrev.day_latest_version = 'Y' AND nvl(htrev.TC_DELETE_FLAG,'N')='N' AND nvl(htrev.TE_DELETE_FLAG,'N')='N' AND nvl(htrev.ANC_DELETE_FLAG,'N')='N' AND nvl(htrev.DAY_DELETE_FLAG ,'N') = 'N' AND htrev.tc_latest_version = 'Y' /* AND htrev.te_delete_flag IS NULL */ AND htrev.te_latest_version = 'Y' AND htrev.anc_latest_version = 'Y' /* AND htrev.anc_delete_flag IS NULL */ AND trunc(htrev.te_stop_time) < trunc(:p_exception_date) AND htrev.te_subresource_id = paam.assignment_id group by papf.person_id) , p_stop_time => (SELECT max(trunc(htrev.te_stop_time)) FROM hwm_tm_rpt_entry_v htrev WHERE /* htrev.day_delete_flag IS NULL AND */ htrev.day_latest_version = 'Y' AND nvl(htrev.TC_DELETE_FLAG,'N')='N' AND nvl(htrev.TE_DELETE_FLAG,'N')='N' AND nvl(htrev.ANC_DELETE_FLAG,'N')='N' AND nvl(htrev.DAY_DELETE_FLAG ,'N') = 'N' AND htrev.tc_latest_version = 'Y' /* AND htrev.te_delete_flag IS NULL */ AND htrev.te_latest_version = 'Y' AND htrev.anc_latest_version = 'Y' /* AND htrev.anc_delete_flag IS NULL */ AND trunc(htrev.te_stop_time) = trunc(:p_exception_date) AND htrev.te_subresource_id = paam.assignment_id group by papf.person_id) , p_assignment_id =>to_char(paam.assignment_id)) ) ds ),'YYYY-MM-DD')Absence_End_Date
	
	,'Pending With Supervisor' APPROVAL_STATUS
	
	/* To get the starting date of the employee's absence*/
	,to_char(( SELECT min(SCHEDULED_START_TIME) FROM TABLE (hts_ff_util.hts_get_scheduled_shifts( p_resource_id => to_char(paam.person_id), p_start_time => (SELECT max(trunc(htrev.te_stop_time)+1) FROM hwm_tm_rpt_entry_v htrev WHERE /* htrev.day_delete_flag IS NULL AND */ htrev.day_latest_version = 'Y' AND nvl(htrev.TC_DELETE_FLAG,'N')='N' AND nvl(htrev.TE_DELETE_FLAG,'N')='N' AND nvl(htrev.ANC_DELETE_FLAG,'N')='N' AND nvl(htrev.DAY_DELETE_FLAG ,'N') = 'N' AND htrev.tc_latest_version = 'Y' /* AND htrev.te_delete_flag IS NULL */ AND htrev.te_latest_version = 'Y' AND htrev.anc_latest_version = 'Y' /* AND htrev.anc_delete_flag IS NULL */ AND trunc(htrev.te_stop_time) < trunc(:p_exception_date) AND htrev.te_subresource_id = paam.assignment_id group by papf.person_id) , p_stop_time => (SELECT max(trunc(htrev.te_stop_time)) FROM hwm_tm_rpt_entry_v htrev WHERE /* htrev.day_delete_flag IS NULL AND */ htrev.day_latest_version = 'Y' AND nvl(htrev.TC_DELETE_FLAG,'N')='N' AND nvl(htrev.TE_DELETE_FLAG,'N')='N' AND nvl(htrev.ANC_DELETE_FLAG,'N')='N' AND nvl(htrev.DAY_DELETE_FLAG ,'N') = 'N' AND htrev.tc_latest_version = 'Y' /* AND htrev.te_delete_flag IS NULL */ AND htrev.te_latest_version = 'Y' AND htrev.anc_latest_version = 'Y' /* AND htrev.anc_delete_flag IS NULL */ AND trunc(htrev.te_stop_time) = trunc(:p_exception_date) AND htrev.te_subresource_id = paam.assignment_id group by papf.person_id) , p_assignment_id =>to_char(paam.assignment_id)) ) ds ),'YYYY-MM-DD') Absence_Start_Date
	
	,papf.person_number

	,ppnf.display_name employee_name
	,papf.person_number emp_person_number
	

	,NVL(peaEmp.email_address, 'employee.work@qatarsteel.com.qa')emp_email
	,pd.name as department_name		  
	,pu_emp.username emp_username
	

	/* ,apae.start_date mgr_abs */
	,(
	CASE
		WHEN apae.start_date IS NULL THEN (SELECT LISTAGG(PU.username,',') WITHIN GROUP (ORDER BY PU.username) FROM PER_USERS PU WHERE 1=1 AND papfMgr.PERSON_ID = PU.PERSON_ID )
		ELSE (SELECT LISTAGG(PU.username,',') WITHIN GROUP (ORDER BY PU.username) FROM PER_USERS PU WHERE 1=1 AND papfMgr.PERSON_ID = PU.PERSON_ID )|| ',' ||(select pu_del.username from per_all_people_F papfDel ,per_users pu_del WHERE 1=1 AND TRUNC(:p_exception_date) BETWEEN papfDel.EFFECTIVE_START_DATE AND papfDel.EFFECTIVE_END_DATE AND papfDel.person_id = pu_del.person_id AND APAE.ATTRIBUTE3 = papfDel.person_number)
	END
	)	 mgr_username
	
	,(
		CASE
			WHEN (SELECT LISTAGG(pu_del.username,',') WITHIN GROUP (ORDER BY pu_del.username) FROM PER_ASG_REPRESENTATIVES RESP ,per_all_people_F papfDel ,per_users pu_del ,ANC_PER_ABS_ENTRIES ApaeHR WHERE 1=1 AND RESP.WORKER_PERSON_ID = PAPF.PERSON_ID AND RESP.WORKER_ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID AND RESP.RESPONSIBILITY_TYPE = 'HR_REP' AND TRUNC(:p_exception_date) BETWEEN papfDel.EFFECTIVE_START_DATE AND papfDel.EFFECTIVE_END_DATE AND papfDel.person_id = pu_del.person_id AND ApaeHR.ATTRIBUTE3 = papfDel.person_number AND RESP.REPRESENTATIVE_PERSON_ID = ApaeHR.PERSON_ID AND TRUNC(:p_exception_date) BETWEEN APAE.start_date and APAE.end_date) IS NULL THEN (SELECT LISTAGG(PU.username,',') WITHIN GROUP (ORDER BY PU.username) FROM PER_ASG_REPRESENTATIVES RESP, PER_USERS PU WHERE 1=1 AND RESP.WORKER_PERSON_ID = PAPF.PERSON_ID AND RESP.WORKER_ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID AND RESP.RESPONSIBILITY_TYPE = 'HR_REP' AND RESP.REPRESENTATIVE_PERSON_ID = PU.PERSON_ID)
			ELSE (SELECT LISTAGG(PU.username,',') WITHIN GROUP (ORDER BY PU.username) FROM PER_ASG_REPRESENTATIVES RESP, PER_USERS PU WHERE 1=1 AND RESP.WORKER_PERSON_ID = PAPF.PERSON_ID AND RESP.WORKER_ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID AND RESP.RESPONSIBILITY_TYPE = 'HR_REP' AND RESP.REPRESENTATIVE_PERSON_ID = PU.PERSON_ID)|| ',' ||(SELECT LISTAGG(pu_del.username,',') WITHIN GROUP (ORDER BY pu_del.username) FROM PER_ASG_REPRESENTATIVES RESP ,per_all_people_F papfDel ,per_users pu_del ,ANC_PER_ABS_ENTRIES ApaeHR WHERE 1=1 AND RESP.WORKER_PERSON_ID = PAPF.PERSON_ID AND RESP.WORKER_ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID AND RESP.RESPONSIBILITY_TYPE = 'HR_REP' AND TRUNC(:p_exception_date) BETWEEN papfDel.EFFECTIVE_START_DATE AND papfDel.EFFECTIVE_END_DATE AND papfDel.person_id = pu_del.person_id AND ApaeHR.ATTRIBUTE3 = papfDel.person_number AND RESP.REPRESENTATIVE_PERSON_ID = ApaeHR.PERSON_ID AND TRUNC(:p_exception_date) BETWEEN APAE.start_date and APAE.end_date)
		END
	)	 HR_REP_username

	,(
		CASE
			WHEN (SELECT LISTAGG(pu_del.username,',') WITHIN GROUP (ORDER BY pu_del.username) FROM PER_ASG_REPRESENTATIVES RESP ,per_all_people_F papfDel ,per_users pu_del ,ANC_PER_ABS_ENTRIES ApaeHR WHERE 1=1 AND RESP.WORKER_PERSON_ID = PAPF.PERSON_ID AND RESP.WORKER_ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID AND RESP.RESPONSIBILITY_TYPE = 'DEPARTMENT_MANAGER' AND TRUNC(:p_exception_date) BETWEEN papfDel.EFFECTIVE_START_DATE AND papfDel.EFFECTIVE_END_DATE AND papfDel.person_id = pu_del.person_id AND ApaeHR.ATTRIBUTE3 = papfDel.person_number AND RESP.REPRESENTATIVE_PERSON_ID = ApaeHR.PERSON_ID AND TRUNC(:p_exception_date) BETWEEN APAE.start_date and APAE.end_date) IS NULL THEN (SELECT LISTAGG(PU.username,',') WITHIN GROUP (ORDER BY PU.username) FROM PER_ASG_REPRESENTATIVES RESP, PER_USERS PU WHERE 1=1 AND RESP.WORKER_PERSON_ID = PAPF.PERSON_ID AND RESP.WORKER_ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID AND RESP.RESPONSIBILITY_TYPE = 'DEPARTMENT_MANAGER' AND RESP.REPRESENTATIVE_PERSON_ID = PU.PERSON_ID)
			ELSE (SELECT LISTAGG(PU.username,',') WITHIN GROUP (ORDER BY PU.username) FROM PER_ASG_REPRESENTATIVES RESP, PER_USERS PU WHERE 1=1 AND RESP.WORKER_PERSON_ID = PAPF.PERSON_ID AND RESP.WORKER_ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID AND RESP.RESPONSIBILITY_TYPE = 'DEPARTMENT_MANAGER' AND RESP.REPRESENTATIVE_PERSON_ID = PU.PERSON_ID)|| ',' ||(SELECT LISTAGG(pu_del.username,',') WITHIN GROUP (ORDER BY pu_del.username) FROM PER_ASG_REPRESENTATIVES RESP ,per_all_people_F papfDel ,per_users pu_del ,ANC_PER_ABS_ENTRIES ApaeHR WHERE 1=1 AND RESP.WORKER_PERSON_ID = PAPF.PERSON_ID AND RESP.WORKER_ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID AND RESP.RESPONSIBILITY_TYPE = 'DEPARTMENT_MANAGER' AND TRUNC(:p_exception_date) BETWEEN papfDel.EFFECTIVE_START_DATE AND papfDel.EFFECTIVE_END_DATE AND papfDel.person_id = pu_del.person_id AND ApaeHR.ATTRIBUTE3 = papfDel.person_number AND RESP.REPRESENTATIVE_PERSON_ID = ApaeHR.PERSON_ID AND TRUNC(:p_exception_date) BETWEEN APAE.start_date and APAE.end_date)
		END
	)	 DeptMan_username

	,(
		CASE
			WHEN (SELECT LISTAGG(pu_del.username,',') WITHIN GROUP (ORDER BY pu_del.username) FROM PER_ASG_REPRESENTATIVES RESP ,per_all_people_F papfDel ,per_users pu_del ,ANC_PER_ABS_ENTRIES ApaeHR WHERE 1=1 AND RESP.WORKER_PERSON_ID = PAPF.PERSON_ID AND RESP.WORKER_ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID AND RESP.RESPONSIBILITY_TYPE = 'SECTION_HEAD' AND TRUNC(:p_exception_date) BETWEEN papfDel.EFFECTIVE_START_DATE AND papfDel.EFFECTIVE_END_DATE AND papfDel.person_id = pu_del.person_id AND ApaeHR.ATTRIBUTE3 = papfDel.person_number AND RESP.REPRESENTATIVE_PERSON_ID = ApaeHR.PERSON_ID AND TRUNC(:p_exception_date) BETWEEN APAE.start_date and APAE.end_date) IS NULL THEN (SELECT LISTAGG(PU.username,',') WITHIN GROUP (ORDER BY PU.username) FROM PER_ASG_REPRESENTATIVES RESP, PER_USERS PU WHERE 1=1 AND RESP.WORKER_PERSON_ID = PAPF.PERSON_ID AND RESP.WORKER_ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID AND RESP.RESPONSIBILITY_TYPE = 'SECTION_HEAD' AND RESP.REPRESENTATIVE_PERSON_ID = PU.PERSON_ID)
			ELSE (SELECT LISTAGG(PU.username,',') WITHIN GROUP (ORDER BY PU.username) FROM PER_ASG_REPRESENTATIVES RESP, PER_USERS PU WHERE 1=1 AND RESP.WORKER_PERSON_ID = PAPF.PERSON_ID AND RESP.WORKER_ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID AND RESP.RESPONSIBILITY_TYPE = 'SECTION_HEAD' AND RESP.REPRESENTATIVE_PERSON_ID = PU.PERSON_ID)|| ',' ||(SELECT LISTAGG(pu_del.username,',') WITHIN GROUP (ORDER BY pu_del.username) FROM PER_ASG_REPRESENTATIVES RESP ,per_all_people_F papfDel ,per_users pu_del ,ANC_PER_ABS_ENTRIES ApaeHR WHERE 1=1 AND RESP.WORKER_PERSON_ID = PAPF.PERSON_ID AND RESP.WORKER_ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID AND RESP.RESPONSIBILITY_TYPE = 'SECTION_HEAD' AND TRUNC(:p_exception_date) BETWEEN papfDel.EFFECTIVE_START_DATE AND papfDel.EFFECTIVE_END_DATE AND papfDel.person_id = pu_del.person_id AND ApaeHR.ATTRIBUTE3 = papfDel.person_number AND RESP.REPRESENTATIVE_PERSON_ID = ApaeHR.PERSON_ID AND TRUNC(:p_exception_date) BETWEEN APAE.start_date and APAE.end_date)
		END
	)	 SECTION_HEAD_username

	,(
		CASE
			WHEN (SELECT LISTAGG(pu_del.username,',') WITHIN GROUP (ORDER BY pu_del.username) FROM PER_ASG_REPRESENTATIVES RESP ,per_all_people_F papfDel ,per_users pu_del ,ANC_PER_ABS_ENTRIES ApaeHR WHERE 1=1 AND RESP.WORKER_PERSON_ID = PAPF.PERSON_ID AND RESP.WORKER_ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID AND RESP.RESPONSIBILITY_TYPE = 'QS_HC_MANAGER' AND TRUNC(:p_exception_date) BETWEEN papfDel.EFFECTIVE_START_DATE AND papfDel.EFFECTIVE_END_DATE AND papfDel.person_id = pu_del.person_id AND ApaeHR.ATTRIBUTE3 = papfDel.person_number AND RESP.REPRESENTATIVE_PERSON_ID = ApaeHR.PERSON_ID AND TRUNC(:p_exception_date) BETWEEN APAE.start_date and APAE.end_date) IS NULL THEN (SELECT LISTAGG(PU.username,',') WITHIN GROUP (ORDER BY PU.username) FROM PER_ASG_REPRESENTATIVES RESP, PER_USERS PU WHERE 1=1 AND RESP.WORKER_PERSON_ID = PAPF.PERSON_ID AND RESP.WORKER_ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID AND RESP.RESPONSIBILITY_TYPE = 'QS_HC_MANAGER' AND RESP.REPRESENTATIVE_PERSON_ID = PU.PERSON_ID)
			ELSE (SELECT LISTAGG(PU.username,',') WITHIN GROUP (ORDER BY PU.username) FROM PER_ASG_REPRESENTATIVES RESP, PER_USERS PU WHERE 1=1 AND RESP.WORKER_PERSON_ID = PAPF.PERSON_ID AND RESP.WORKER_ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID AND RESP.RESPONSIBILITY_TYPE = 'QS_HC_MANAGER' AND RESP.REPRESENTATIVE_PERSON_ID = PU.PERSON_ID)|| ',' ||(SELECT LISTAGG(pu_del.username,',') WITHIN GROUP (ORDER BY pu_del.username) FROM PER_ASG_REPRESENTATIVES RESP ,per_all_people_F papfDel ,per_users pu_del ,ANC_PER_ABS_ENTRIES ApaeHR WHERE 1=1 AND RESP.WORKER_PERSON_ID = PAPF.PERSON_ID AND RESP.WORKER_ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID AND RESP.RESPONSIBILITY_TYPE = 'QS_HC_MANAGER' AND TRUNC(:p_exception_date) BETWEEN papfDel.EFFECTIVE_START_DATE AND papfDel.EFFECTIVE_END_DATE AND papfDel.person_id = pu_del.person_id AND ApaeHR.ATTRIBUTE3 = papfDel.person_number AND RESP.REPRESENTATIVE_PERSON_ID = ApaeHR.PERSON_ID AND TRUNC(:p_exception_date) BETWEEN APAE.start_date and APAE.end_date)
		END
	)	 QS_HC_MANAGER_username

	,(
		CASE
			WHEN (SELECT LISTAGG(pu_del.username,',') WITHIN GROUP (ORDER BY pu_del.username) FROM PER_ASG_REPRESENTATIVES RESP ,per_all_people_F papfDel ,per_users pu_del ,ANC_PER_ABS_ENTRIES ApaeHR WHERE 1=1 AND RESP.WORKER_PERSON_ID = PAPF.PERSON_ID AND RESP.WORKER_ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID AND RESP.RESPONSIBILITY_TYPE = 'QS_EMP_ABS_LEGAL' AND TRUNC(:p_exception_date) BETWEEN papfDel.EFFECTIVE_START_DATE AND papfDel.EFFECTIVE_END_DATE AND papfDel.person_id = pu_del.person_id AND ApaeHR.ATTRIBUTE3 = papfDel.person_number AND RESP.REPRESENTATIVE_PERSON_ID = ApaeHR.PERSON_ID AND TRUNC(:p_exception_date) BETWEEN APAE.start_date and APAE.end_date) IS NULL THEN (SELECT LISTAGG(PU.username,',') WITHIN GROUP (ORDER BY PU.username) FROM PER_ASG_REPRESENTATIVES RESP, PER_USERS PU WHERE 1=1 AND RESP.WORKER_PERSON_ID = PAPF.PERSON_ID AND RESP.WORKER_ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID AND RESP.RESPONSIBILITY_TYPE = 'QS_EMP_ABS_LEGAL' AND RESP.REPRESENTATIVE_PERSON_ID = PU.PERSON_ID)
			ELSE (SELECT LISTAGG(PU.username,',') WITHIN GROUP (ORDER BY PU.username) FROM PER_ASG_REPRESENTATIVES RESP, PER_USERS PU WHERE 1=1 AND RESP.WORKER_PERSON_ID = PAPF.PERSON_ID AND RESP.WORKER_ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID AND RESP.RESPONSIBILITY_TYPE = 'QS_EMP_ABS_LEGAL' AND RESP.REPRESENTATIVE_PERSON_ID = PU.PERSON_ID)|| ',' ||(SELECT LISTAGG(pu_del.username,',') WITHIN GROUP (ORDER BY pu_del.username) FROM PER_ASG_REPRESENTATIVES RESP ,per_all_people_F papfDel ,per_users pu_del ,ANC_PER_ABS_ENTRIES ApaeHR WHERE 1=1 AND RESP.WORKER_PERSON_ID = PAPF.PERSON_ID AND RESP.WORKER_ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID AND RESP.RESPONSIBILITY_TYPE = 'QS_EMP_ABS_LEGAL' AND TRUNC(:p_exception_date) BETWEEN papfDel.EFFECTIVE_START_DATE AND papfDel.EFFECTIVE_END_DATE AND papfDel.person_id = pu_del.person_id AND ApaeHR.ATTRIBUTE3 = papfDel.person_number AND RESP.REPRESENTATIVE_PERSON_ID = ApaeHR.PERSON_ID AND TRUNC(:p_exception_date) BETWEEN APAE.start_date and APAE.end_date)
		END
	)	 QS_EMP_ABS_LEGAL_username

	,(
		CASE
			WHEN (SELECT LISTAGG(pu_del.username,',') WITHIN GROUP (ORDER BY pu_del.username) FROM PER_ASG_REPRESENTATIVES RESP ,per_all_people_F papfDel ,per_users pu_del ,ANC_PER_ABS_ENTRIES ApaeHR WHERE 1=1 AND RESP.WORKER_PERSON_ID = PAPF.PERSON_ID AND RESP.WORKER_ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID AND RESP.RESPONSIBILITY_TYPE = 'QS_EMP_ABS_PERSONAL' AND TRUNC(:p_exception_date) BETWEEN papfDel.EFFECTIVE_START_DATE AND papfDel.EFFECTIVE_END_DATE AND papfDel.person_id = pu_del.person_id AND ApaeHR.ATTRIBUTE3 = papfDel.person_number AND RESP.REPRESENTATIVE_PERSON_ID = ApaeHR.PERSON_ID AND TRUNC(:p_exception_date) BETWEEN APAE.start_date and APAE.end_date) IS NULL THEN (SELECT LISTAGG(PU.username,',') WITHIN GROUP (ORDER BY PU.username) FROM PER_ASG_REPRESENTATIVES RESP, PER_USERS PU WHERE 1=1 AND RESP.WORKER_PERSON_ID = PAPF.PERSON_ID AND RESP.WORKER_ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID AND RESP.RESPONSIBILITY_TYPE = 'QS_EMP_ABS_PERSONAL' AND RESP.REPRESENTATIVE_PERSON_ID = PU.PERSON_ID)
			ELSE (SELECT LISTAGG(PU.username,',') WITHIN GROUP (ORDER BY PU.username) FROM PER_ASG_REPRESENTATIVES RESP, PER_USERS PU WHERE 1=1 AND RESP.WORKER_PERSON_ID = PAPF.PERSON_ID AND RESP.WORKER_ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID AND RESP.RESPONSIBILITY_TYPE = 'QS_EMP_ABS_PERSONAL' AND RESP.REPRESENTATIVE_PERSON_ID = PU.PERSON_ID)|| ',' ||(SELECT LISTAGG(pu_del.username,',') WITHIN GROUP (ORDER BY pu_del.username) FROM PER_ASG_REPRESENTATIVES RESP ,per_all_people_F papfDel ,per_users pu_del ,ANC_PER_ABS_ENTRIES ApaeHR WHERE 1=1 AND RESP.WORKER_PERSON_ID = PAPF.PERSON_ID AND RESP.WORKER_ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID AND RESP.RESPONSIBILITY_TYPE = 'QS_EMP_ABS_PERSONAL' AND TRUNC(:p_exception_date) BETWEEN papfDel.EFFECTIVE_START_DATE AND papfDel.EFFECTIVE_END_DATE AND papfDel.person_id = pu_del.person_id AND ApaeHR.ATTRIBUTE3 = papfDel.person_number AND RESP.REPRESENTATIVE_PERSON_ID = ApaeHR.PERSON_ID AND TRUNC(:p_exception_date) BETWEEN APAE.start_date and APAE.end_date)
		END
	)	 QS_EMP_ABS_PERSONAL_username

FROM  
	per_all_assignments_m paam
	
	,per_person_names_f ppnf
	,per_person_names_f ppnfMgr
	
	,per_all_people_f papf
	,per_all_people_F papfMgr
	
	,per_email_addresses peaMgr
	,per_email_addresses peaEmp
		
	,per_assignment_supervisors_f pasf 
	,per_departments pd
	,per_users pu_emp
	,per_users pu_mgr
	
	,ANC_PER_ABS_ENTRIES APAE

WHERE
	1 = 1
	
	AND TRUNC(:p_exception_date) BETWEEN papf.effective_start_date
		AND papf.effective_end_date
	
	--Assignment
	AND papf.person_id = paam.person_id
	AND TRUNC(:p_exception_date) BETWEEN paam.effective_start_date AND paam.effective_end_date
		AND paam.Assignment_status_type = 'ACTIVE'
	AND paam.assignment_type = ('E')
	AND paam.primary_Flag = 'Y'
	AND paam.employment_category <> 'INT_PLANT'
	
	--Username
	AND papfMgr.PERSON_ID = pu_mgr.PERSON_ID
	AND PAPF.PERSON_ID = pu_emp.PERSON_ID
	
	--PersonName
	AND papf.person_id = ppnf.person_id
	AND TRUNC(:p_exception_date) BETWEEN ppnf.effective_StarT_Date AND ppnf.effective_End_Date
	AND ppnf.name_type = 'GLOBAL'
	
	--PersonName Manager
	AND papfMgr.person_id = ppnfMgr.person_id
	AND TRUNC(:p_exception_date) BETWEEN ppnfMgr.effective_StarT_Date AND ppnfMgr.effective_End_Date
	AND ppnfMgr.name_type = 'GLOBAL'
		
	-- supervisor Email join
	AND papfMgr.primary_email_id = peaMgr.email_address_id(+)
	AND peaMgr.EMAIL_TYPE(+) = 'W1'
	
	-- employee Email join
	AND papf.primary_email_id = peaEmp.email_address_id(+)
	AND peaEmp.EMAIL_TYPE(+) = 'W1'
	
	-- Supervisor
	AND paam.assignment_id = pasf.assignment_id(+)
	AND paam.person_id = pasf.person_id(+)
	AND TRUNC(:p_exception_date) BETWEEN pasf.effective_StarT_Date
		AND pasf.effective_End_Date
	AND pasf.manager_type = 'LINE_MANAGER'
	AND pasf.primary_Flag = 'Y'
	
	-- supervisor person join
	AND papfMgr.person_id = pasf.manager_id
	AND TRUNC(:p_exception_date) BETWEEN papfMgr.effective_StarT_Date
		AND papfMgr.effective_End_Date
	
	--Department Details
	AND PD.ORGANIZATION_ID (+) = paam.ORGANIZATION_ID
	AND TRUNC(:p_exception_date) BETWEEN PD.EFFECTIVE_START_DATE (+) AND PD.EFFECTIVE_END_DATE (+)
	
	/*Manager absence*/
	AND papfMgr.PERSON_ID = APAE.PERSON_ID(+)
	AND TRUNC(:p_exception_date) BETWEEN APAE.start_date(+) and APAE.end_date(+)
	AND apae.approval_status_cd(+) = 'APPROVED'
	AND apae.absence_status_cd(+) = 'SUBMITTED'
	
	/*Run date has at least one swipe in/out*/
	AND EXISTS(
			SELECT   1
			FROM  
				hwm_tm_rpt_entry_v htrev
				,hwm_tm_allow_exps_v htaev 
			WHERE
				 htrev.day_latest_version = 'Y' 
				AND htrev.tc_latest_version = 'Y' 
				AND htrev.te_latest_version = 'Y' 
				AND htrev.anc_latest_version = 'Y'
				AND nvl(htrev.TC_DELETE_FLAG,'N')='N' AND nvl(htrev.TE_DELETE_FLAG,'N')='N' AND nvl(htrev.ANC_DELETE_FLAG,'N')='N' AND nvl(htrev.DAY_DELETE_FLAG ,'N') = 'N'
				AND htrev.te_tm_rec_id = htaev.tm_bldg_blk_id(+) 
				AND htrev.te_tm_rec_version = htaev.tm_bldg_blk_version(+) 
				AND htrev.te_subresource_id = paam.assignment_id 
				AND trunc(htrev.te_start_time) = trunc(:p_exception_date)
	)