SELECT 
2000 KEY,
MAIN2.EMP_LIST,
MAIN2.PERIOD_LIST,
MAIN2.DIVISION,
MAIN2.DEPARTMENT,
MAIN2.SECTION,
MAIN2.EMPLOYEE,
MAIN2.NORMAL,
MAIN2.OTL_ABSENT AS OTL_ABSENT,	
MAIN2.OTL_LATENESS,	
MAIN2.OVERTIME_A,	
MAIN2.OVERTIME_B,	
MAIN2.ANNUAL_LEAVE,	
MAIN2.COMPASSIONATE_LEAVE,
MAIN2.PILGRIMAGE_LEAVE,
MAIN2.SICK_LEAVE,
MAIN2.SICK_LEAVE_NO_PAY,	
MAIN2.SICK_LEAVE_IA,
((MAIN2.NORMAL) + (MAIN2.OTL_ABSENT + MAIN2.OTL_LATENESS + MAIN2.OVERTIME_A + MAIN2.OVERTIME_B + MAIN2.ANNUAL_LEAVE + MAIN2.COMPASSIONATE_LEAVE + MAIN2.PILGRIMAGE_LEAVE + MAIN2.SICK_LEAVE + MAIN2.SICK_LEAVE_NO_PAY + MAIN2.SICK_LEAVE_IA)) AS ACTUAL 

FROM 

(SELECT 
listagg(DISTINCT MAIN.PERSON_NUMBER,', ') within GROUP (Order By MAIN.PERSON_NUMBER ) as EMP_LIST,
listagg(DISTINCT MAIN.PERIOD_NAME,', ') within GROUP (Order By MAIN.PERIOD_NAME ) as PERIOD_LIST,
MAIN.DIVISION,
MAIN.DEPARTMENT,
MAIN.SECTION,
COUNT(DISTINCT MAIN.PERSON_NUMBER) AS EMPLOYEE,
(COUNT(DISTINCT MAIN.PERSON_NUMBER)*8*24) AS NORMAL,
NVL((NVL(SUM(MAIN.OTL_ABSENT_RESULTS),0)+NVL(SUM(MAIN.OTL_ABSENT_RETRO),0)),0)*(-1) AS OTL_ABSENT,	
--NVL(SUM(OTL_ABSENT_RETRO),0) AS OTL_ABSENT_RETRO , 	

NVL((NVL(SUM(MAIN.OTL_LATENESS_RESULTS),0) + NVL(SUM(MAIN.OTL_LATENESS_RETRO),0) + NVL(SUM(MAIN.LATENESS_RESULTS),0)),0)*(-1) AS OTL_LATENESS,	
--NVL(SUM(OTL_LATENESS_RETRO),0) AS OTL_LATENESS_RETRO,
--NVL(SUM(LATENESS_RESULTS),0) AS LATENESS_RESULTS,	

NVL((NVL(SUM(MAIN.OVERTIME_A_RESULTS),0) + NVL(SUM(MAIN.OVERTIME_A_RETRO),0)),0) AS OVERTIME_A,	
--SUM(MAIN.OVERTIME_A_RESULTS) AS OVERTIME_A,
--NVL(SUM(OVERTIME_A_RETRO),0) AS OVERTIME_A_RETRO,

NVL((NVL(SUM(MAIN.OVERTIME_B_RESULTS),0) + NVL(SUM(MAIN.OVERTIME_B_RETRO),0)),0) AS OVERTIME_B,	
--NVL(SUM(OVERTIME_B_RETRO),0) AS OVERTIME_B_RETRO,

NVL(SUM(MAIN.ANNUAL_LEAVE_RESULT)*(-8),0) AS ANNUAL_LEAVE,	
NVL(SUM(MAIN.COMPASSIONATE_LEAVE_RESULTS)*(-8),0) AS COMPASSIONATE_LEAVE,
NVL(SUM(MAIN.PILGRIMAGE_LEAVE_RESULTS)*(-8),0) AS PILGRIMAGE_LEAVE,
NVL(SUM(MAIN.SICK_LEAVE_RESULTS)*(-8),0) AS SICK_LEAVE,
NVL(SUM(MAIN.SICK_LEAVE_NO_PAY_RESULTS)*(-8),0) AS SICK_LEAVE_NO_PAY,	
NVL(SUM(MAIN.SICK_LEAVE_IA_RESULTS)*(-8),0) AS SICK_LEAVE_IA


FROM  
	(SELECT *FROM

			(	SELECT 
			
			(SELECT DISTINCT PDS.NAME
				FROM PER_ORG_TREE_NODE_CF CF,
				HR_ALL_ORGANIZATION_UNITS PDS
				WHERE PDS.ORGANIZATION_ID = CF.DEP28_PK1_VALUE
				AND CF.TREE_CODE IN ('QS_ORG_TREE','QSFZE_ORG_TREE','QCOAT_ORG_TREE')
				AND DEP25_PK1_VALUE = TREE.PK1_START_VALUE
				AND DISTANCE >= 3
				--and rownum=1
				) as DIVISION,

				(SELECT DISTINCT PDS.NAME
				FROM PER_ORG_TREE_NODE_CF CF,
				HR_ALL_ORGANIZATION_UNITS PDS
				WHERE PDS.ORGANIZATION_ID = CF.DEP27_PK1_VALUE
				AND CF.TREE_CODE IN ('QS_ORG_TREE','QSFZE_ORG_TREE','QCOAT_ORG_TREE')
				AND DEP25_PK1_VALUE = TREE.PK1_START_VALUE
				AND DISTANCE >= 4
				--and rownum=1
				) as DEPARTMENT,

				(SELECT DISTINCT PDS.NAME
				FROM PER_ORG_TREE_NODE_CF CF,
				HR_ALL_ORGANIZATION_UNITS PDS
				WHERE PDS.ORGANIZATION_ID = CF.DEP26_PK1_VALUE
				AND CF.TREE_CODE IN ('QS_ORG_TREE','QSFZE_ORG_TREE','QCOAT_ORG_TREE')
				AND DEP25_PK1_VALUE = TREE.PK1_START_VALUE
				AND DISTANCE >= 5
			--	and rownum=1
				) as SECTION,
		papf.person_number ,
		PTP.PERIOD_NAME ,
		petf.element_name ,
		ppa.EFFECTIVE_DATE,
		PRRV.RESULT_VALUE,
		/* CASE WHEN petf.element_name = 'Basic Salary' THEN 0 
		     WHEN (petf.element_name IN ('Overtime A Results','Overtime A Retroactive','Overtime B Results','Overtime B Retroactive') AND piv.name= 'Pay Value') THEN 0
		ELSE TO_NUMBER(PRRV.RESULT_VALUE) END AS RESULT_VALUE, */
		
		ppa.action_type,
	   piv.name As Input_value

		FROM 
		

		per_all_people_f_v papf,
		per_all_assignments_m paam,
		
		-- org tree tables 
		PER_PERSON_NAMES_F PPNF,
		PER_PERIODS_OF_SERVICE PPS,
		HR_ALL_ORGANIZATION_UNITS HAOU,
		HR_ALL_ORGANIZATION_UNITS PD,
		PER_ORG_TREE_NODE TREE,
		FND_TREE_VERSION FTV,

		pay_rel_groups_dn prg,
		pay_payroll_rel_actions pra,
		pay_payroll_assignments paa,
		pay_pay_relationships_dn prd,
		pay_payroll_actions ppa,
		pay_all_payrolls_f pap,

		pay_assigned_payrolls_dn papd,
		pay_run_result_values prrv,
		PAY_INPUT_VALUES_VL piv,
		pay_run_results prr,

		pay_element_types_vl petf,
		pay_ele_classifications_vl PEC ,
		pay_time_periods ptp

		WHERE 1 = 1
		--AND PAPF.person_number IN ('10364','12807')
		--and ptp.PERIOD_NAME = '4 2024 Monthly Calendar'
		AND PAPF.PERSON_ID = PAAM.PERSON_ID 
		AND PAAM.ASSIGNMENT_TYPE = 'E'
		AND PAAM.PRIMARY_FLAG = 'Y'
		AND PAAM.EFFECTIVE_LATEST_CHANGE = 'Y'
		AND ppa.effective_date BETWEEN papf.effective_start_date AND papf.effective_end_date
		AND TRUNC(PPA.EFFECTIVE_DATE) BETWEEN TRUNC(PAAM.EFFECTIVE_START_DATE) AND TRUNC(PAAM.EFFECTIVE_END_DATE)
				
		-- org tree joins 
		AND PAPF.PERSON_ID = PPNF.PERSON_ID
		AND PAPF.PERSON_ID = PPS.PERSON_ID
		AND PAAM.PERIOD_OF_SERVICE_ID = PPS.PERIOD_OF_SERVICE_ID
		AND PD.ORGANIZATION_ID(+) = PAAM.ORGANIZATION_ID
		AND PAAM.LEGAL_ENTITY_ID =HAOU.ORGANIZATION_ID(+)
		AND TREE.PK1_START_VALUE = PD.ORGANIZATION_ID
		AND TREE.TREE_VERSION_ID = FTV.TREE_VERSION_ID
		AND TRUNC(SYSDATE) BETWEEN PPNF.EFFECTIVE_START_DATE AND PPNF.EFFECTIVE_END_DATE
		AND TRIM(TREE.TREE_CODE) IN ('QS_ORG_TREE','QSFZE_ORG_TREE','QCOAT_ORG_TREE')
		AND PPNF.NAME_TYPE='GLOBAL'
		AND FTV.STATUS = 'ACTIVE'
		AND FTV.EFFECTIVE_START_DATE = (SELECT MAX(EFFECTIVE_START_DATE)
												FROM FND_TREE_VERSION
												WHERE TRIM(TREE_CODE) IN ('QS_ORG_TREE','QSFZE_ORG_TREE','QCOAT_ORG_TREE')
												AND STATUS = 'ACTIVE')
		
		AND PAAM.ASSIGNMENT_ID = PRG.ASSIGNMENT_ID
		AND PRG.PAYROLL_RELATIONSHIP_ID = pra.PAYROLL_RELATIONSHIP_ID

		AND prd.PAYROLL_RELATIONSHIP_ID = pra.PAYROLL_RELATIONSHIP_ID
		AND prd.person_id = papf.person_id
		AND pra.RETRO_COMPONENT_ID IS NULL
		--AND ppa.action_type IN ('R') 
		AND ppa.payroll_action_id = pra.payroll_action_id
		AND ppa.payroll_id = pap.payroll_id
		AND prr.PAYROLL_REL_ACTION_ID = pra.PAYROLL_REL_ACTION_ID

		AND prr.RUN_RESULT_ID = prrv.RUN_RESULT_ID
		AND prr.ELEMENT_TYPE_ID = petf.ELEMENT_TYPE_ID
		
		AND petf.CLASSIFICATION_ID   = PEC.CLASSIFICATION_ID
		AND ppa.effective_date BETWEEN NVL(PEC.date_from,ppa.effective_date) AND   NVL(PEC.date_to,ppa.effective_date)
		
	--	AND petf.element_name IN ('Absence','Annual Leave Taken','Compassionate leave','Lateness Deduction Results','Overtime A Results','Overtime B Results','Pilgrimage Leave', 'Sick Leave','Sick Leave IA Deduction', 'Basic Salary')
		
		AND petf.element_name IN ('OTL Absent Results',	'OTL Absent Retroactive',	'OTL Lateness Results',	'OTL Lateness Retroactive',	'Lateness OTL Results',	'Overtime A Results',	'Overtime A Retroactive',	'Overtime B Results',	'Overtime B Retroactive',	'Annual Leave Entitlement Result',	'Compassionate leave Entitlement Result',	'Pilgrimage Leave Entitlement Result',	'Sick Leave Entitlement Result',	'Sick Leave No Pay Deduction Results',	'Sick Leave IA Deduction Results')
		
		AND paa.payroll_relationship_id = pra.payroll_relationship_id
		AND paa.hr_assignment_id = paam.assignment_id
		AND paa.payroll_term_id = papd.payroll_term_id
		AND pap.payroll_id = papd.payroll_id

		AND ppa.earn_time_period_id = ptp.time_period_id

		AND ptp.period_category = 'E'
		AND ptp.payroll_id = pap.payroll_id
		AND TRUNC(PPA.EFFECTIVE_DATE) BETWEEN TRUNC(PTP.START_DATE) AND TRUNC(PTP.END_DATE)
		AND TRUNC(PTP.END_DATE) = TRUNC(:P_PROCESS_DATE)

		AND piv.name IN ('Hours', 'Unit (Days)')
		and piv.input_value_id=prrv.input_value_id
		AND PPA.DATE_EARNED BETWEEN piv.EFFECTIVE_START_DATE AND piv.EFFECTIVE_END_DATE

		--AND PB_MTD.BALANCE_NAME = 'Net Pay'

		AND ppa.effective_date BETWEEN pap.effective_start_date AND pap.effective_end_date
		AND ppa.effective_date BETWEEN petf.effective_start_date AND petf.effective_end_date
		
		ORDER BY PAPF.PERSON_NUMBER, petf.element_name

) 
pivot (SUM(RESULT_VALUE) for (ELEMENT_NAME) in (		'OTL Absent Results' AS OTL_ABSENT_RESULTS,	
													   'OTL Absent Retroactive' AS OTL_ABSENT_RETRO,	
													   'OTL Lateness Results' AS OTL_LATENESS_RESULTS,	
													   'OTL Lateness Retroactive' AS OTL_LATENESS_RETRO,	
													   'Lateness OTL Results' AS LATENESS_RESULTS,	
													   'Overtime A Results' AS OVERTIME_A_RESULTS,	
													   'Overtime A Retroactive' AS OVERTIME_A_RETRO,	
													   'Overtime B Results' AS OVERTIME_B_RESULTS,	
													   'Overtime B Retroactive' AS OVERTIME_B_RETRO,	
													   'Annual Leave Entitlement Result' AS ANNUAL_LEAVE_RESULT,	
													   'Compassionate leave Entitlement Result' AS Compassionate_LEAVE_RESULTS,
													   'Pilgrimage Leave Entitlement Result' AS Pilgrimage_LEAVE_RESULTS,	
													   'Sick Leave Entitlement Result' AS SICK_LEAVE_RESULTS,	
													   'Sick Leave No Pay Deduction Results' AS SICK_LEAVE_NO_PAY_RESULTS,	
													   'Sick Leave IA Deduction Results' AS SICK_LEAVE_IA_RESULTS ))

) MAIN

WHERE 1=1 
GROUP BY MAIN.DIVISION, MAIN.DEPARTMENT, MAIN.SECTION

) MAIN2