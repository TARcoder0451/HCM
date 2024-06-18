/*This report calculates the duration of employee absence between two time card entries. It uses the packages to determine whether a day is working or not and then returns the desired details*/
select 
main.duration
, main.Absence_End_Date
,main.Absence_Start_Date
,main.emp_person_number
,main.employee_name
,	('This is to inform you that '||main.emp_person_number||','||main.empn||' is absent for consecutive '||main.duration||' days from '||main.Absence_Start_Date||' to '||main.Absence_End_Date) as Abs_Report
,TO_CHAR(TRUNC(:p_exception_date),'YYYY-MM-DD') as AssignedDate
,main.person_id
,main.assignment_id
,decode ( main.duration , 9 , (
		SELECT checklist_id
		FROM PER_CHECKLISTS_VL
		WHERE UPPER(name) = 'OTL JOURNEY FOR 9 DAYS'
	),6,(SELECT checklist_id
		FROM PER_CHECKLISTS_VL
		WHERE UPPER(name) = 'OTL JOURNEY FOR 6 DAYS'),(SELECT checklist_id
		FROM PER_CHECKLISTS_VL
		WHERE UPPER(name) = 'OTL JOURNEY FOR 3 DAYS')) JourneyId
,(
CASE main.duration 
    WHEN 9 THEN 'Absence Report 3'
    WHEN 6 THEN 'Absence Report 2'
    WHEN 3 THEN 'Absence Report 1'
    ELSE 'Other' -- This is the default value if none of the conditions match
END
) Report 
from 
(

select 
	/*To count the number of days absence*/
	( SELECT count(*) 
	FROM TABLE (hts_ff_util.hts_get_scheduled_shifts( 
	p_resource_id => to_char(ur.person_id), 
	p_start_time => to_date(ur.regular_max_date) ,
	p_stop_time => to_date(to_char(:p_exception_date ,'DDMMYYYY'),'DDMMYYYY'),
	p_assignment_id =>to_char(ur.assignment_id)) 
	) ds ) DURATION
	/*To get the end date of the employee's is absence*/
	,to_char(( SELECT max(SCHEDULED_START_TIME) 
	FROM TABLE (hts_ff_util.hts_get_scheduled_shifts(
		p_resource_id => to_char(ur.person_id)
		, p_start_time => to_date(ur.regular_max_date) 
		, p_stop_time => :p_exception_date 
		, p_assignment_id =>to_char(ur.assignment_id)) 
		) ds ),'DD-Mon-YYYY','NLS_DATE_LANGUAGE=AMERICAN') as Absence_End_Date
	
	/* To get the starting date of the employee's absence*/
	,to_char(( SELECT min(SCHEDULED_START_TIME) 
	FROM TABLE (hts_ff_util.hts_get_scheduled_shifts( 
	p_resource_id => to_char(ur.person_id), 
	p_start_time => to_date(ur.regular_max_date) ,
	p_stop_time => :p_exception_date , 
	p_assignment_id =>to_char(ur.assignment_id)) 
	) ds ), 'DD-Mon-YYYY','NLS_DATE_LANGUAGE=AMERICAN') as Absence_Start_Date,
	ur.assignment_id,
	ur.person_id,
	ur.emp_person_number,
	ur.employee_name,
	ur.empn
	
	from 
	(select max(trunc(htrev.te_start_time)+1) regular_max_date
	,ppnf.display_name as employee_name,
	papf.person_number as emp_person_number,
	paam.assignment_id 
	,papf.person_id
	,ppnf.full_name empn
	
FROM  
	per_all_assignments_m paam
	,per_person_names_f ppnf
	,per_all_people_f papf
	,hwm_tm_rpt_entry_v htrev 
	,hwm_tm_rep_m_ptt_atrbs_v htrm
WHERE
	1 = 1
	--AND papf.person_number = '11042'
	AND TRUNC(:p_exception_date) BETWEEN papf.effective_start_date
		AND papf.effective_end_date
	
	--Assignment
	AND papf.person_id = paam.person_id
	AND TRUNC(:p_exception_date) BETWEEN paam.effective_start_date AND paam.effective_end_date
		AND paam.Assignment_status_type = 'ACTIVE'
	AND paam.assignment_type = ('E')
	AND paam.primary_Flag = 'Y'

	--PersonName
	AND papf.person_id = ppnf.person_id
	AND TRUNC(:p_exception_date) BETWEEN ppnf.effective_StarT_Date AND ppnf.effective_End_Date
	AND ppnf.name_type = 'GLOBAL'
AND htrev.day_latest_version='Y' 
AND htrev.tc_latest_version='Y'  AND htrev.te_latest_version='Y' AND htrev.anc_latest_version='Y'
					AND nvl(htrev.TC_DELETE_FLAG,'N')='N' AND nvl(htrev.TE_DELETE_FLAG,'N')='N' AND nvl(htrev.ANC_DELETE_FLAG,'N')='N' AND nvl(htrev.DAY_DELETE_FLAG ,'N') = 'N'
					AND trunc(htrev.te_start_time) < trunc(:p_exception_date) 
					AND htrev.te_subresource_id = paam.assignment_id 
					AND htrev.TE_TM_REC_ID = htrm.USAGES_SOURCE_ID
					AND htrev.TE_TM_REC_VERSION = htrm.USAGES_SOURCE_VERSION
					AND htrm.PAY_PAYROLL_TIME_TYPE = 'Regular Hours'
					group by ppnf.display_name,
	papf.person_number
	,paam.assignment_id 
	,papf.person_id
	,ppnf.full_name
	) ur
) main
where 1=1
and main.duration/*  >0 */ in (3,6,9)