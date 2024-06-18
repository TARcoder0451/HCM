SELECT
ppnf.display_name fullname
,papf.person_number employee_number
,to_char(ppei.PEI_INFORMATION_DATE1,'DD-Mon-YYYY','NLS_DATE_LANGUAGE=AMERICAN')Issue_Date
,ppei.PEI_INFORMATION1 WarningType
,ppei.PEI_INFORMATION2  Reason
,ppei.PEI_INFORMATION3  Comments
,ppei.PEI_INFORMATION4  Warning_Ref_Num
,ppei.PEI_INFORMATION5  Absence_Type
,ppei.PEI_INFORMATION6  AuthorizedSignatory
,to_char(ppei.PEI_INFORMATION_DATE2,'DD-Mon-YYYY','NLS_DATE_LANGUAGE=AMERICAN')  Absence_Start_Date
,to_char(ppei.PEI_INFORMATION_DATE3,'DD-Mon-YYYY','NLS_DATE_LANGUAGE=AMERICAN')  Absence_End_Date
,ppnf.NAM_INFORMATION1  person_arabic_name
,(SELECT PDS.NAME FROM PER_ORG_TREE_NODE_CF CF, HR_ALL_ORGANIZATION_UNITS PDS, PER_ORG_TREE_NODE TREE, FND_TREE_VERSION FTV WHERE PDS.ORGANIZATION_ID = CF.DEP26_PK1_VALUE AND DEP25_PK1_VALUE = TREE.PK1_START_VALUE AND CF.TREE_CODE IN ('QS_ORG_TREE','QSFZE_ORG_TREE','QCOAT_ORG_TREE') AND DISTANCE >= 4 AND TREE.PK1_START_VALUE = PD2.ORGANIZATION_ID AND TREE.TREE_VERSION_ID = FTV.TREE_VERSION_ID AND TRIM(TREE.TREE_CODE)IN ('QS_ORG_TREE','QSFZE_ORG_TREE','QCOAT_ORG_TREE') AND FTV.EFFECTIVE_START_DATE = (SELECT MAX(EFFECTIVE_START_DATE) FROM FND_TREE_VERSION WHERE TRIM(TREE_CODE)IN ('QS_ORG_TREE','QSFZE_ORG_TREE','QCOAT_ORG_TREE') AND STATUS = 'ACTIVE') 
) Dept
,pd2.name
,pos.name as Dept_AuthorizedSignatory
FROM  
	per_all_assignments_m paaf
	,per_all_people_f papf
	,per_person_names_f ppnf
	,per_people_extra_info_f ppei
	,per_departments pd2
	,HR_ALL_POSITIONS_F_TL POS
WHERE
	TRUNC(SYSDATE) BETWEEN paaf.effective_start_date AND paaf.effective_end_date

	
	AND paaf.primary_Flag = 'Y'
	AND papf.person_id=paaf.person_id
	AND ppnf.person_id = papf.person_id
	AND TRUNC(SYSDATE) BETWEEN ppnf.effective_start_date AND ppnf.effective_end_date
	AND ppnf.name_type = 'GLOBAL'
	AND ppei.person_id(+) = papf.person_id
	AND PD2.ORGANIZATION_ID (+) = paaf.ORGANIZATION_ID
	AND TRUNC(SYSDATE) BETWEEN PD2.EFFECTIVE_START_DATE (+) AND PD2.EFFECTIVE_END_DATE (+)
	/* AND ppei.INFORMATION_TYPE = 'Discplinary SIT' */
	AND ppei.PEI_INFORMATION4 = (:p_warning_ref_num)
	AND TRUNC(SYSDATE) BETWEEN POS.EFFECTIVE_START_DATE(+)  AND POS.EFFECTIVE_END_DATE(+) 
AND  POS.POSITION_ID(+) = paaf.POSITION_ID