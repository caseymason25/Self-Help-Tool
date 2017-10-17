/* SECTION REDACTED for GITHUB */
 
/********
How this works
 
The program will read through the following:
I Area/Org
J Stage
L Document
M Segment Grp
N Segment
O InputForm
  OnlineItem
 
Once it gets to Online Items, it calls 802105 for convenience
 
Along the way, it will pull preferences and further details as it's looping
 
It will also check things it's already retrieved to compare and look for issues
 
Example: when looping through segments, it will look for a case times meaning for the Ornurse document,
if one is found it'll store that in Reply, if more than 1 is found, it'll store that as well
 
checks are numbered for ease of javascript checking; 1 is a failure of the check
 
By the end of the program, all of the items have been error checked
 
The reply is converted to a JSON object for the MPage and returned
 
**********/
%i cclsource:mp_script_logging.inc
%i cclsource:mp_common.inc
 
declare PERSONNELID	= f8 with protect, constant(CNVTREAL($INPUTPERSONNELID))
declare BY_MEANING = c7 with public, constant("MEANING")
 
free set reply
declare setErrorFound(level=i2,item=i2) = i2 /* 1=inst,2=area,3=stage,4=doc,5=seggrp,6=seg,7=form,8=dta */
declare setWarnFound(level=i2,item=i2) = i2 /* 1=inst,2=area,3=stage,4=doc,5=seggrp,6=seg,7=form,8=dta */
 
/*Subs used to get data, first num in comment is the flag used to call this script*/
declare getInstitutions(flag=i2) = i2 /* 1 sub used to get institutions for drop-down, this calls getAreas*/
declare getAreas(flag=i2) = i2 /* sub used to get areas for drop-downs*/
declare getDocRefs(null) = i2 /* sub used to get sn doc ref ids for drop-downs */
declare getDocumentBuild(null) = i2 /* 2sub used to get Document build tab*/
 
record verify_reply
(
	1 RT_NUMERIC_CD = f8
	1 RT_INVENTORY_CD = f8
	1 RT_FREETEXT_CD = f8
	1 RT_PROVIDER_CD = f8
	1 RT_DATETIME_CD = f8
	1 RT_ORDCAT_CD = f8
	1 RT_YESNO_CD = f8
	1 institutions[*]
	   2 institution_name = vc
	   2 institution_cd = f8
	   2 organization_name = vc
	   2 organization_id = f8
	   2 areas_exist = i2
	   2 departments[*]
	       3 department_cd = f8
	       3 department_msg = vc
	       3 areas[*]
	           4 area_cd = f8
	           4 area_display = vc
	           4 docs[*]
	               5 display = vc
	               5 doc_ref_id = f8
	1 areas[*]
		2 area_cd = f8
		2 error_found = i2
		2 warn_found = i2
		2 area_display = vc
		2 area_prefix = vc
		2 area_check_001 = i2 /*1 area prefix null */
		2 AREA_TRACKING_SET = i2
		2 area_check_002 = i2 /*1 Tracking enabled, Loc not set */
		2 AREA_TRACKING_GRP_CD = f8
		2 AREA_TRACKING_GRP = vc
		2 AREA_TRACKING_LOC = vc
		2 area_check_003 = i2 /*1 Location set, tracking not enabled*/
		2 area_check_004 = i2 /*warn-level tracking not enabled, trk group not defined*/
		2 area_check_005 = i2 /*1 Does an ORNURSE exist, 1 = doesn't exist*/
		2 area_check_006 = i2 /*1 Is there more than 1 ORNURSE */
		2 area_check_007 = i2 /* sn_system_paramter contains more than 1 row for the area */
		2 area_check_008 = i2 /* is 802105 desktop cache turned on*/
		2 area_check_009 = i2 /* area shares a prefix with another area */
		2 stages[*]
			3 stage_cd = f8
			3 error_found = i2
			3 warn_found = i2
			3 stage_display = vc
			3 stage_meaning = vc
			3 stage_check_001 = i2 /*1 stage prefix null in sndbsystem... */
			3 stage_prefix = vc
			3 stage_check_002 = i2 /*1 triple postop in a stage */
			3 stage_check_003 = i2 /*1 dupe preop in a stage */
			3 documents[*]
				4 doc_type_cd = f8
				4 error_found = i2
				4 warn_found = i2
				4 doc_type_display = vc
				4 doc_type_meaning = vc
				4 doc_check_001 = i2 /* no cdf on document type */
				4 doc_check_002 = i2 /* does doc bill item have detail / clear */
				4 doc_type_pl_gen = i2 /*0 is pl by case, 1 is pl by proc*/
				4 doc_type_send_chg = i2 /*0 independ, 1 is synch*/
				4 doc_type_charges_pl = i2 /* document setup to charge for PL */
				4 doc_type_uses_pl = i2 /* is the doc even using the PL */
				4 doc_check_003 = i2 /*1 Only bad if using PL, charging PL, PL by proc and PL send Indepen all align */
				4 doc_check_004 = i2 /*1 bad event cd */
				4 check_004[*]
					5 item1 = f8 /*event code value*/
					5 item2 = vc /*event code display*/
				4 doc_check_005 = i2 /*doc has 1 case times segment */
				4 doc_check_006 = i2 /*doc does not have case times seg, but is ORNURSE */
				4 doc_check_007 = i2 /*CASE_MOD_ALLOWED_IND should be 0 */
				4 doc_check_008 = i2 /*doc has more than 1 case times seg*/
				4 doc_check_009 = i2 /* acuity charging missing */
				4 acuity_flag = i2 /*CHARGE_ACUITYLEVEL_IND*/
				4 check_009[*]
					5 item1 = i2 /*ACUITYLEVEL does the acuity segment exist in the document*/
					5 item2 = i2 /*ACUITYLEVEL does the acuity form exist in the document*/
					5 item3 = i2 /*SN-ACCU-LEV does the acuity DTA exist */
					5 item4 = i2 /*CT-PACUPTIN does the IN time exist*/
					5 item5 = i2 /*CT-PACUPTOUT does the OUT time exist*/
				4 doc_check_010 = i2 /*doc does not have gcd seg, but is ORNURSE */
				4 doc_check_011 = i2 /*doc has more than 1 gcd seg */
				4 doc_check_012 = i2 /*doc has 1 case attendee seg */
				4 doc_check_013 = i2 /*doc does not have case attend seg, but is ORNURSE */
				4 doc_check_014 = i2 /*doc has more than 1 case attendee seg */
				4 doc_check_015 = i2 /* unused */
				4 doc_check_016 = i2 /*doc does not have procedure seg, but is ORNURSE */
				4 doc_check_017 = i2 /*doc has more than 1 procedure seg */
				4 doc_check_018 = i2 /*doc does not have case times form, but is ORNURSE */
				4 doc_check_019 = i2 /*doc does not have gcd form, but is ORNURSE */
				4 doc_check_020 = i2 /*doc does not have case attend form, but is ORNURSE */
				4 doc_check_021 = i2 /*doc does not have procedure form, but is ORNURSE */
				4 doc_check_022 = i2 /*This document has no printable segments */
				4 doc_check_023 = i2 /*document has room charge enabled, but missing required fields */
				4 doc_room_charge_type = i2 /* CHARGE_ROOM_OPT_FLAG 1 Surg 2 Anes 3 patrm 4 preop 5 pacu1 6 pacu2 */
				4 check_023[*]
					5 item1 = i2 /*segment is casetimes (or acuity) */
					5 item2 = i2 /*input form is casetimes (or acuity) */
					5 item3 = i2 /* doc_room_start_exists */
					5 item4 = i2 /*doc_room_stop_exists */
					5 item5 = i2 /*CSD-OR is defined on GCD (for ORNURSE, otherwise STAGE CD is sent */
				4 doc_check_024 = i2 /*document has anesthesia charge, but missing required fields */
				4 doc_anes_charge = i2 /* CHARGE_ANESTH_OPT_FLAG 1 Surg 2 Anes 3 patrm */
				4 check_024[*]
					5 item1 = i2 /*segment is casetimes */
					5 item2 = i2 /*input form is casetimes */
					5 item3 = i2 /* doc_anes_start_exists */
					5 item4 = i2 /*doc_anes_stop_exists */
					5 item5 = i2 /*doc_anes_type_exists */
					5 item6 = i2 /*document is ORNURSE */
				4 doc_check_025 = i2 /*document has segments with duplicate CDF meanings */
				4 check_025[*]
					5 item1 = vc /*segment cdf */
					5 item2 = vc /*segment display*/
					5 dupe = i2 /*segment dupe, flag, 1 is dupe */
				4 doc_check_026 = i2 /*document has inventory controls with duplicate CDF meanings */
				4 check_026[*]
					5 item1 = vc /*CDF Meaning */
					5 item2 = vc /*Segment Display */
					5 item3 = vc /*form display*/
					5 item4 = vc /*DTA display */
					5 dupe = i2 /*flag 1 is dupe, 0 is valid */
				4 doc_check_027 = i2 /*document has a bill item created */
				4 check_027[*]
					5 item1 = f8 /*bill item id */
				4 segment_grp[*]
					5 segment_grp_id = f8
					5 segment_grp_display = vc
					5 error_found = i2
					5 warn_found = i2
					5 seggrp_check_001 = i2 /*1 segment grp sequence has inactive segments ahead of active ones */
					5 segments[*]
						6 seg_cd = f8
						6 segment_display = vc
						6 segment_active = i2
						6 segment_meaning = vc
						6 segment_grp_seq = f8
						6 segment_printable = i2 /*0 unchecked, 1 is printable*/
						6 error_found = i2
						6 warn_found = i2
						6 seg_check_001 = i2 /*no cdf meaning set */
						6 seg_check_002 = i2 /* bad or missing input form */
						6 seg_check_003 = i2 /*segment and form have different CDFs */
						6 check_003[*]
						  7 item1 = vc /*segment meaning */
						  7 item2 = vc /*form meaning */
						  7 item3 = vc /*form display */
						6 seg_check_004 = i2 /*segment contains more than 1 inventory control */
						6 seg_check_005 = i2 /*GCD seg, no OR Room field */
						6 seg_check_006 = i2 /*GCD seg, no ASA Class field */
						6 seg_check_007 = i2 /*GCD seg, no Specialty field */
						6 seg_check_008 = i2 /*GCD seg, no Case Level field */
						6 seg_check_009 = i2 /*GCD seg, no Wound Class field */
						6 seg_check_010 = i2 /*GCD seg, no PreOp Diag field */
						6 seg_check_011 = i2 /*GCD seg, no PostOp Diag field */
						6 seg_check_012 = i2 /*GCD seg, no PostOp same as Preop Diag field */
						6 seg_check_013 = i2 /*CaseTimes seg in ORNURSE, no Surg Start */
						6 seg_check_014 = i2 /*CaseTimes seg in ORNURSE, no Surg Stop */
						6 seg_check_015 = i2 /*CaseTimes seg, no Patient In Rm (this checks for any in-room time meanings) */
						6 seg_check_016 = i2 /*CaseTimes seg, no Patient Out Rm (this checks for any out-room time meanings) */
						6 seg_check_017 = i2 /*Procedure seg, no Procedure field */
						6 seg_check_018 = i2 /*Procedure seg, no Surgeon field */
						6 seg_check_019 = i2 /*Procedure seg, no Primary Ind field */
						6 seg_check_020 = i2 /*Case Attend seg, no Provider field */
						6 seg_check_021 = i2 /*Case Attend seg, no Role field */
						6 seg_check_022 = i2 /*Procedure seg, no proc start field */
						6 seg_check_023 = i2 /*Procedure seg, no proc stop field */
						6 segment_repeated = i2 /*This segment has more than 1 execution seq*/
						6 input_forms[*]
							7 input_form_cd = f8
							7 error_found = i2
							7 warn_found = i2
							7 input_form_display = vc
							7 input_form_meaning = vc
							7 input_form_multi = i2
							7 unprocessed_ind = i2
							7 input_form_ver = i4
							7 form_check_001 = i2 /*no cdf meaning set */
							7 form_check_002 = i2 /*form has an unprocessed version */
							7 form_check_003 = i2 /*linked input form contains no controls */
							7 form_check_004 = i2 /*multi-entry form contains repeating groups*/
							7 online_items[*]
								8 task_assay_cd = f8
								8 error_found = i2
								8 warn_found = i2
								8 description = vc
								8 accept_size = i4
								8 task_assay_mean = vc
								8 result_type_cd = f8
								8 event_cd = f8
								8 multi_select = i2
								8 dta_check_001 = i2 /* field set to repeat, but should not be */
								8 dta_check_002 = i2 /* field set is freetext, but does not have character limit set */
								8 dta_check_003 = i2 /* field is SN-EQ-DESC, but does not have char limit 200 */
								8 dta_check_004 = i2 /* field is SN-IMP-CAT, but does not have char limit 50 */
								8 dta_check_005 = i2 /* field is SN-IMP-HST, but does not have char limit 100 */
								8 dta_check_006 = i2 /* field is SN-IMP-LOT, but does not have char limit 50 */
								8 dta_check_007 = i2 /* field is SN-IMP-MAN, but does not have char limit 100 */
								8 dta_check_008 = i2 /* field is SN-EQ-SNBR, but does not have char limit 50 */
								8 dta_check_009 = i2 /* field is SN-IMP-SZ, but does not have char limit 50 */
								8 dta_check_010 = i2 /* invalid field in a repeating group */
								8 dta_check_011 = i2 /* this field has an invalid event code */
								8 dta_check_012 = i2 /* this field does not have a cdf meaning */
								8 dta_check_013 = i2 /* this is a repeating field in a repeating group  */
								8 dta_check_014 = i2 /* this dta has an unprocessed version */
	1 status_data
    2 status = c1
    2 subeventstatus[1]
      3 OperationName = c25
      3 OperationStatus = c1
      3 TargetObjectName = c25
      3 TargetObjectValue = vc
)
 
set verify_reply->status_data->status = "Z"
 
declare count2 = i4 with noconstant(0)
declare count3 = i4 with noconstant(0)
 
CASE($INPUTMODE)
    of 1:
        call getInstitutions(0)
    of 2:
        call getDocumentBuild(null)
ENDCASE
 
/* SECTION REDACTED for GITHUB */
 
SUBROUTINE getAreas(flag)
    free set request
     free set reply
 
  IF (NOT(validate(request,0)))
    RECORD request (
      1 service_resource_cd = f8
      1 cdf_meaning = C12
      1 root_service_resource_cd = f8
      1 get_all_flag = I2
      1 get_master_flag = I2
      1 discipline_type_cd = F8
      1 activity_type_cd = F8
      1 activity_subtype_cd = F8
    )
  ENDIF
 
  if (not(validate(reply,0)))
    record reply
    ( 1 qual[*]
        2 child_service_resource_cd         = f8
        2 child_service_resource_disp       = c40
        2 child_service_resource_desc       = c60
        2 collation_seq                     = i4
        2 cv_updt_cnt                       = i4
        2 child_ind                         = i2
        2 active_ind                        = i2
        2 status_ind                        = i2
        2 rg_updt_cnt                       = i4
        2 sequence                          = i4
        2 service_resource_type_mean        = c12
        2 rg_active_ind                     = i2
        2 rg_status_ind                     = i2
        2 discipline_type_cd                = f8
        2 activity_type_cd                  = f8
        2 activity_subtype_cd               = f8
        2 pharmacy_type_cd                  = f8
        2 site_prefix                       = vc
        2 server_year                       = vc
%i cclsource:status_block.inc
    )
 /* SECTION REDACTED for GITHUB */
 
/*Loop Areas to Get Stages*/
set tmparea = 0
for (i = 1 to size(verify_reply->areas,5))
 
    set verify_reply->status_data->status = "S"
 
    /*get desktop cache from 802105*/
    select into "n1"
	from request r
	plan r
	where r.request_number=802105
	and r.cachetime > 0
	head report
	count3=0
	detail
		verify_reply->areas[i].area_check_008 = 1
    with nocounter
 
    select into "n1"
    area_cnt = count(sr.service_resource_cd)
    from service_resource sr,code_value cv
    where sr.accn_site_prefix=verify_reply->areas[i].area_prefix
    AND sr.service_resource_type_cd = cv.code_value
    and cv.cdf_meaning="SURGAREA"
    and cv.code_set=223
    and sr.active_ind=1
    and sr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
    detail
        if(area_cnt > 1)
		  verify_reply->areas[i].area_check_009 = 1
		endif
    with nocounter
 
    /*Get staging areas*/
	select into "n1"
	from resource_group rg
	,code_value cv
	plan rg
	where rg.parent_service_resource_cd=verify_reply->areas[i].area_cd
	join cv
	where cv.code_value=rg.child_service_resource_cd
	and cv.active_ind=1
	order by rg.sequence
 
	head report
	count3=0
 
	detail
		count3 = count3 +1
		stat = alterlist(verify_reply->areas[i]->stages,count3)
		verify_reply->areas[i]->stages[count3].stage_cd = cv.code_value
		verify_reply->areas[i]->stages[count3].stage_display = cv.display
		verify_reply->areas[i]->stages[count3].stage_meaning = cv.cdf_meaning
	with nocounter
 
	/* While looping areas, some prefs and do some checks*/
	/* Check surgical area prefix */
	if(trim(verify_reply->areas[i].area_prefix) = NULL)
		set verify_reply->areas[i].area_check_001 = 1
		set stat = setErrorFound(2,i)
	endif
	/* First see if tracking is enabled */
 
	select into "n1"
	from sn_name_value_prefs snvp
	plan snvp
	where snvp.parent_entity_id=verify_reply->areas[i].area_cd
	and snvp.parent_entity_name="SERVICE_RESOURCE"
	and snvp.pref_name="SNCASETRK"
 
	head report
	count3=0
 
	detail
		count3 = count3 +1
		verify_reply->areas[i].area_tracking_set = cnvtint(snvp.pref_value)
	with nocounter
 
	/* See if the area has a tracking group, retrieve it */
	select into "n1"
	from code_value cv2
	,track_group tg
	,service_resource sr
	,code_value cv
	plan sr where sr.service_resource_cd = verify_reply->areas[i].area_cd
	join cv2 where cv2.code_value = sr.location_cd
	join tg where tg.parent_value = sr.location_cd
	and tg.child_table = "TRACK_ASSOC"
	join cv where cv.code_value=tg.tracking_group_cd
	and cv.active_ind = 1
	and cv.code_value > 0
 
	head report
	count3=0
 
	detail
		count3 = count3 +1
		verify_reply->areas[i].area_tracking_loc = cv2.display /*Loc Disp*/
		verify_reply->areas[i].area_tracking_grp = cv.display /*Tracking Grp Disp*/
		verify_reply->areas[i].area_tracking_grp_cd = tg.tracking_group_cd /*Loc Disp*/
	with nocounter
	if(verify_reply->areas[i].area_tracking_set > 0 AND verify_reply->areas[i].area_tracking_loc = NULL)
		set verify_reply->areas[i].area_check_002 = 1
		set stat = setErrorFound(2,i)
	elseif(verify_reply->areas[i].area_tracking_set = 0 AND verify_reply->areas[i].area_tracking_loc != NULL)
		set verify_reply->areas[i].area_check_003 = 1
		set stat = setErrorFound(2,i)
	elseif(verify_reply->areas[i].area_tracking_set = 0 AND verify_reply->areas[i].area_tracking_loc = NULL)
	   set verify_reply->areas[i].area_check_004 = 1
	   set stat = setWarnFound(2,i)
	endif
 
	/*Loop Stages to Get Documents*/
	for(j = 1 to size(verify_reply->areas[i]->stages,5))
		set tmppreop = 0
		set tmppostop = 0
 
		select into "n1"
		from sn_doc_ref sdr
		,code_value cv
		,sn_name_value_prefs snv
		plan sdr
		where sdr.stage_cd=verify_reply->areas[i]->stages[j].stage_cd
		join cv
		where cv.code_value=sdr.doc_type_cd
		and cv.active_ind=1
		join snv
		where snv.parent_entity_id=sdr.doc_ref_id
		and snv.parent_entity_name="SN_DOC_REF"
		and snv.pref_name="BY_PROC_PICK_LIST_IND"
 
		head report
		count3=0
 
		detail
			count3 = count3 +1
			stat = alterlist(verify_reply->areas[i]->stages[j]->documents,count3)
			verify_reply->areas[i]->stages[j]->documents[count3].doc_type_cd=cv.code_value
			verify_reply->areas[i]->stages[j]->documents[count3].doc_type_display = cv.display
			verify_reply->areas[i]->stages[j]->documents[count3].doc_type_meaning = cv.cdf_meaning
			verify_reply->areas[i]->stages[j]->documents[count3].doc_type_pl_gen = cnvtint(snv.pref_value)
		foot report
			stat = alterlist(verify_reply->areas[i]->stages[j]->documents,count3)
		with nocounter
 
		/*  While we're looping through the staging areas, get some additional prefs */
		/*Get staging area prefix setting*/
		select into "n1"
		from SN_SYSTEM_PARAMETER ssp
		plan ssp
		where ssp.surg_stage_cd=verify_reply->areas[i]->stages[j].stage_cd
		or ssp.surg_area_cd=verify_reply->areas[i].area_cd
 
		head report
		count3=0
 
		detail
		count3 = count3 +1
		if(count3 = 1)
		  verify_reply->areas[i]->stages[j].stage_prefix = ssp.surg_area_name_key
		elseif(count3 > 1)
		  /*should only be 1 row on this table for each area, get first prefix, fail check*/
		  verify_reply->areas[i].area_check_007 = 1
		endif
		with nocounter
 
		if(trim(verify_reply->areas[i]->stages[j].stage_prefix) = NULL)
			set verify_reply->areas[i]->stages[j].stage_check_001 = 1
			set stat = setErrorFound(3,j)
		endif
 
 		/*Loop documents to Get segment groups*/
 		for(l = 1 to size(verify_reply->areas[i]->stages[j]->documents,5))
 			set temp_seg_printable =0
 
			select into "n1"
			from segment_grp_reference s,code_value cv
			plan s
			where s.doc_type_cd=verify_reply->areas[i]->stages[j].documents[l].doc_type_cd
			and s.surg_area_cd=verify_reply->areas[i].area_cd
			and s.active_ind=1
			join cv
			where cv.code_value=s.seg_grp_cd
			and cv.active_ind=1
			order by cv.active_ind desc
 
			head report
			count3=0
 
			detail
			count3 = count3 +1
			stat = alterlist(verify_reply->areas[i]->stages[j]->documents[l]->segment_grp,count3)
			verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[count3].segment_grp_id=s.seg_grp_cd
			verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[count3].segment_grp_display=cv.display
 
		foot report
			stat = alterlist(verify_reply->areas[i]->stages[j]->documents[l]->segment_grp,count3)
		with nocounter
 
		/* While we're looping through the document, get some additional prefs/settings */
		/* verify documents do not exceed limits of staging areas */
			if(verify_reply->areas[i].area_check_005 = 0 and verify_reply->areas[i]->stages[j]->documents[l].doc_type_meaning="ORNURSE")
		 		set verify_reply->areas[i].area_check_005=1
		 	elseif(verify_reply->areas[i].area_check_005 = 1 and verify_reply->areas[i]->stages[j]->documents[l].doc_type_meaning="ORNURSE")
		 		set verify_reply->areas[i].area_check_006=1
		 		set stat = setErrorFound(2,i)
		 	endif
		 	if(verify_reply->areas[i]->stages[j]->documents[l].doc_type_meaning = "PREOP" or
		 	verify_reply->areas[i]->stages[j]->documents[l].doc_type_meaning = "POSTOP" or
		 	verify_reply->areas[i]->stages[j]->documents[l].doc_type_meaning = "ORNURSE" or
		 	verify_reply->areas[i]->stages[j]->documents[l].doc_type_meaning = "INTRAANESTH")
		 	    set verify_reply->areas[i]->stages[j]->documents[l].doc_check_001 = 0
		 	else
				set verify_reply->areas[i]->stages[j]->documents[l].doc_check_001 = 1
				set stat = setErrorFound(4,l)
			endif
	 		if(tmppreop=1 and verify_reply->areas[i]->stages[j]->documents[l].doc_type_meaning="PREOP")
				set verify_reply->areas[i]->stages[j].stage_check_003 = 1
				set stat = setWarnFound(3,j)
			elseif(verify_reply->areas[i]->stages[j]->documents[l].doc_type_meaning="PREOP")
				set tmppreop=1
			endif
			if(tmppostop=2 and verify_reply->areas[i]->stages[j]->documents[l].doc_type_meaning="POSTOP")
				set verify_reply->areas[i]->stages[j].stage_check_002 = 1
				set stat = setWarnFound(3,j)
			elseif(verify_reply->areas[i]->stages[j]->documents[l].doc_type_meaning="POSTOP")
				set tmppostop=tmppostop +1
			endif
 
			/*Make sure the document has a bill item created */
			select into "n1"
			from bill_item b
            where b.ext_owner_cd=doc_ext_owner_cd
            and b.ext_parent_contributor_cd=doc_ext_contributor_cd
            and b.ext_parent_reference_id=verify_reply->areas[i]->stages[j].documents[l].doc_type_cd
            and b.active_ind=1
            and b.bill_item_id > 0
            detail
				count3 = count3 +1
				stat = alterlist(verify_reply->areas[i]->stages[j]->documents[l]->check_027,count3)
				verify_reply->areas[i]->stages[j]->documents[l]->check_027[1].item1 = b.bill_item_id
			with nocounter
			if(curqual = 0)
				set verify_reply->areas[i]->stages[j]->documents[l].doc_check_027=1
			endif
 
			/*Make sure the document has charge processing created if the bill item exists */
			if(verify_reply->areas[i]->stages[j]->documents[l].doc_check_027 = 0)
				select into "n1"
				from bill_item_modifier b
	            where b.bill_item_id=verify_reply->areas[i]->stages[j]->documents[l]->check_027[1].item1
	            and b.active_ind=1
	            and b.key4_id = value(uar_get_code_by("MEANING", 13020, "DETAIL")) /*charge level set*/
	            detail
					count3 = count3 +1
				with nocounter
				if(curqual = 0)
					set verify_reply->areas[i]->stages[j]->documents[l].doc_check_002=1
				endif
			endif
/* SECTION REDACTED for GITHUB */
 
 			/* See if Pick List is charging */
 			select into "n1"
 			from sn_doc_ref sd, sn_prefs sp
			plan sd
			where sd.doc_type_cd=verify_reply->areas[i]->stages[j].documents[l].doc_type_cd
			join sp
			where sd.doc_ref_id=sp.parent_entity_id
			and sp.pref_name="CHARGE_PICK_LIST_IND"
			head report
			count3=0
 
			detail
				count3 = count3 +1
				verify_reply->areas[i]->stages[j]->documents[l].doc_type_charges_pl = cnvtint(sp.pref_value_nbr)
			with nocounter
			if(curqual = 0)
				set verify_reply->areas[i]->stages[j]->documents[l].doc_type_charges_pl=0
			endif
 
		  if(verify_reply->areas[i]->stages[j]->documents[l].doc_type_uses_pl=1 AND
		  verify_reply->areas[i]->stages[j]->documents[l].doc_type_charges_pl=1)
 
				/*Get charge sync setting*/
				select into "n1"
				from sn_doc_ref sdr,sn_prefs sp
				plan sdr
				where sdr.doc_type_cd=verify_reply->areas[i]->stages[j].documents[l].doc_type_cd
				join sp
				where sp.parent_entity_id=sdr.doc_ref_id
				and sp.parent_entity_name="SN_DOC_REF"
				and sp.pref_name="CHARGE_SYNC_FLAG"
 
				head report
				count3=0
 
				detail
					count3 = count3 +1
					verify_reply->areas[i]->stages[j]->documents[l].doc_type_send_chg = cnvtint(sp.pref_value_nbr)
				with nocounter
 
				if(verify_reply->areas[i]->stages[j]->documents[l].doc_type_pl_gen=1)
					if(curqual = 0) /* this pref defaults to not defined on new doctypes and assumes Independently */
						set verify_reply->areas[i]->stages[j]->documents[l].doc_check_003=1
						set stat = setErrorFound(4,l)
					elseif(verify_reply->areas[i]->stages[j]->documents[l].doc_type_send_chg = 0)
						set verify_reply->areas[i]->stages[j]->documents[l].doc_check_003=1
						set stat = setErrorFound(4,l)
					endif
				endif
			else
				set verify_reply->areas[i]->stages[j]->documents[l].doc_check_003=0
			endif
 
			/*Get document event code*/
			/*fail it and prove it correct below in the next 2 queries */
			set verify_reply->areas[i]->stages[j]->documents[l].doc_check_004 = 1
 
			select into "n1"
			from sn_name_value_prefs snvp,sn_doc_ref sdr
			plan sdr
			where sdr.doc_type_cd=verify_reply->areas[i]->stages[j].documents[l].doc_type_cd
			join snvp
			where snvp.parent_entity_id = sdr.doc_ref_id
			and snvp.parent_entity_name="SN_DOC_REF"
			and snvp.pref_name = "EVENT_CD"
			head report
			count3=0
			detail
				stat = alterlist(verify_reply->areas[i]->stages[j]->documents[l]->check_004,1)
				verify_reply->areas[i]->stages[j]->documents[l].check_004[1].item1 = cnvtreal(snvp.pref_value)
			with nocounter
 
 			/* validate the event code is active and from code set 72 (aka not a typo) */
			if(size(verify_reply->areas[i]->stages[j]->documents[l]->check_004,5) > 0)
				select into "n1"
				from code_value cv,v500_event_code vec
				where cv.code_value=verify_reply->areas[i]->stages[j]->documents[l].check_004[1].item1
				and cv.code_set=72
				and cv.active_ind=1
				and cv.code_value > 0
				and vec.event_cd=cv.code_value
				head report
				count3=0
				detail
					count3 = count3 +1
					verify_reply->areas[i]->stages[j]->documents[l].check_004[count3].item2 = cv.display
					verify_reply->areas[i]->stages[j]->documents[l].doc_check_004 = 0
				with nocounter
			endif
			/*if we're still failing the doc_check 004 AND it's not an ANES doc, mark it failed*/
			if(verify_reply->areas[i]->stages[j]->documents[l].doc_check_004 = 1
			and verify_reply->areas[i]->stages[j]->documents[l].doc_type_meaning != "INTRAANESTH")
				set stat = setErrorFound(4,l)
			else
				/*it's an SA doc OR we've already passed it, make sure it's passed*/
				set verify_reply->areas[i]->stages[j]->documents[l].doc_check_004 = 0
			endif
 
			set checkseqinactive=0
 
			/*Loop segment groups to Get segments*/
	 		for(m = 1 to size(verify_reply->areas[i]->stages[j]->documents[l]->segment_grp,5))
				select into "n1"
				from segment_reference s,code_value cv;,seg_grp_seq_r sr
				plan s
				where s.seg_grp_cd=verify_reply->areas[i]->stages[j].documents[l]->segment_grp[m].segment_grp_id
				and s.surg_area_cd=verify_reply->areas[i].area_cd
				join cv
				where cv.code_value=s.seg_cd
	 			order by s.print_seq,s.active_ind
				head report
				count3=0
 
				detail
				count3 = count3 +1
				stat = alterlist(verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments,count3)
				verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[count3].seg_cd=cv.code_value
				verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[count3].segment_display=trim(cv.display)
				verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[count3].segment_meaning=trim(cv.
				cdf_meaning)
				verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[count3].segment_printable=s.printable_ind
				verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[count3].segment_active=s.active_ind
				verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[count3].segment_grp_seq=s.print_seq
			with nocounter
	set temp_seg_mean = " "
/* Loop segments to Get Input Forms*/
for(n = 1 to size(verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments,5))
set temp_seg_mean = " "
set temp_seg_mean = verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].segment_meaning
set temp_seg_disp = " "
set temp_seg_active = verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].segment_active
set temp_seg_disp = verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].segment_display
		if(verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].segment_printable = 1
		and verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].segment_active = 1)
			set temp_seg_printable = 1
		endif
		if(temp_seg_active = 1 AND checkseqinactive = 1)
			set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m].seggrp_check_001 = 1
			set stat = setErrorFound(5,m)
		elseif(verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].segment_active = 0)
			set checkseqinactive = 1
		endif
		/*Check that seg has a meaning  */
		if(temp_seg_active = 1 and (trim(temp_seg_mean) = "USER" or trim(temp_seg_mean) = NULL))
			set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].seg_check_001 = 1
			set stat = setWarnFound(6,n)
		elseif(temp_seg_active = 1)
			/* If it's not USER or NULL Store segment CDF to ensure it's not re-used*/
			set add_dupe_segment = 0
			set seg_cdf_size = size(verify_reply->areas[i]->stages[j]->documents[l].check_025,5)
			for(a = 1 to seg_cdf_size)
			/*loop all existing meanings in structure, if we find a dupe, mark that one a dupe, mark our 'add' as a dupe*/
				if(verify_reply->areas[i]->stages[j]->documents[l].check_025[a].item1 = temp_seg_mean)
					set verify_reply->areas[i]->stages[j]->documents[l].doc_check_025 = 1
					set verify_reply->areas[i]->stages[j]->documents[l].check_025[a].dupe = 1
					set add_dupe_segment = 1
					set a = seg_cdf_size
				endif
			endfor
			/* add our new segment cdf to the structure  */
			set seg_cdf_size = size(verify_reply->areas[i]->stages[j]->documents[l].check_025,5) +1
			set stat = alterlist(verify_reply->areas[i]->stages[j]->documents[l].check_025,seg_cdf_size)
			set verify_reply->areas[i]->stages[j]->documents[l].check_025[seg_cdf_size].item1 = temp_seg_mean
			set verify_reply->areas[i]->stages[j]->documents[l].check_025[seg_cdf_size].item2 = temp_seg_disp
			set verify_reply->areas[i]->stages[j]->documents[l].check_025[seg_cdf_size].dupe = 0
			/*if it was found to be a dupe in the above loop, mark it*/
			if(add_dupe_segment = 1)
				set verify_reply->areas[i]->stages[j]->documents[l].check_025[seg_cdf_size].dupe = 1
				set stat = setErrorFound(4,l)
			endif
		endif
		if(temp_seg_active = 1 and temp_seg_mean="CASETIMES")
			set verify_reply->areas[i]->stages[j]->documents[l].doc_check_005 = verify_reply->areas[i]->stages[j]->
			documents[l].doc_check_005 +1
			if(verify_reply->areas[i]->stages[j]->documents[l].doc_check_005 > 1)
				set verify_reply->areas[i]->stages[j]->documents[l].doc_check_008 = 1
				set stat = setErrorFound(4,l)
			endif
			if(verify_reply->areas[i]->stages[j]->documents[l].doc_type_meaning = "ORNURSE")
				set verify_reply->areas[i]->stages[j]->documents[l].doc_check_006 = 1
			endif
		elseif(temp_seg_active = 1 and temp_seg_mean="CASEOVERVW")
			set verify_reply->areas[i]->stages[j]->documents[l].doc_check_011 = verify_reply->areas[i]->stages[j]->
			documents[l].doc_check_011 +1
			if(verify_reply->areas[i]->stages[j]->documents[l].doc_check_011 > 1)
				set verify_reply->areas[i]->stages[j]->documents[l].doc_check_011 = 1
				set stat = setErrorFound(4,l)
			endif
			if(verify_reply->areas[i]->stages[j]->documents[l].doc_type_meaning = "ORNURSE")
				set verify_reply->areas[i]->stages[j]->documents[l].doc_check_010 = 1
			endif
		elseif(temp_seg_active = 1 and temp_seg_mean="CASEATTEND")
			set verify_reply->areas[i]->stages[j]->documents[l].doc_check_012 = verify_reply->areas[i]->stages[j]->
			documents[l].doc_check_012 +1
			if(verify_reply->areas[i]->stages[j]->documents[l].doc_check_012 > 1)
				set verify_reply->areas[i]->stages[j]->documents[l].doc_check_014 = 1
				set stat = setErrorFound(4,l)
			endif
			if(verify_reply->areas[i]->stages[j]->documents[l].doc_type_meaning = "ORNURSE")
				set verify_reply->areas[i]->stages[j]->documents[l].doc_check_013 = 1
			endif
		elseif(temp_seg_active = 1 and temp_seg_mean="SURGPROCS")
			set verify_reply->areas[i]->stages[j]->documents[l].doc_check_017 = verify_reply->areas[i]->stages[j]->
			documents[l].doc_check_017 +1
			if(verify_reply->areas[i]->stages[j]->documents[l].doc_check_017 > 1)
				set verify_reply->areas[i]->stages[j]->documents[l].doc_check_017 = 1
				set stat = setErrorFound(4,l)
			endif
			if(verify_reply->areas[i]->stages[j]->documents[l].doc_type_meaning = "ORNURSE")
				set verify_reply->areas[i]->stages[j]->documents[l].doc_check_016 = 1
			endif
		endif
 
set latestver=1
set has_inv = 0
 
/* SECTION REDACTED for GITHUB */
 
 	/*moving reverse check from here because if a doc has NO segment grps, this will never hit*/
 
/* free set form_reply */
if(form_request->input_form_cd > 0)
		set dta_cnt = 0
		set d1seq = 0
 
record form_reply
(
 1 input_form_cd                = f8
 1 input_form_disp              = c40
 1 input_form_desc              = c60
 1 input_form_mean              = c12
 
 1 description                  = vc
 1 display                      = vc
 1 repeat_ind                   = i2 /* form is set to repeat */
 1 column_sort_ind              = i2
 1 auto_layout_ind              = i2
 1 calc_result_ind              = i2
 1 one_column_ind               = i2
 1 event_cd                     = f8
 1 qual[*]
     2 group_cd                 = f8
     2 group_disp               = c40
     2 group_desc               = c60
     2 group_mean               = c12
     2 group_description        = vc
     2 group_version_nbr        = i4
     2 repeat_ind               = i2 /* group is set to repeat */
     2 updt_cnt                 = i4
     2 cmpnt_height             = i4
     2 cmpnt_width              = i4
     2 task_assay_cd              = f8
     2 task_assay_disp            = c40
     2 task_assay_desc            = c60
     2 task_assay_mean            = c12
     2 online_item_version_nbr    = i4
     2 event_cd                   = f8
     2 activity_type_cd           = f8
     2 default_result_type_cd     = f8
     2 description                = vc
     2 def_column_heading         = vc
     2 result_type_cd             = f8
     2 result_type_disp           = c40
     2 result_type_desc           = c60
     2 result_type_mean           = c12
     2 field_prompt               = vc
     2 accept_size                = i4
     2 multi_result_allowed_ind   = i2 /* field is set to repeat */
     2 increment_value            = i4
     2 min_value                  = i4
     2 max_value                  = i4
     2 override_control_type_flag = i2
     2 validation_script          = f8
     2 validation_codeset         = f8
     2 unit_meas_ind              = i2
     2 def_unit_meas_cd           = f8
     2 static_unit_ind            = i2
     2 required_flag              = i2
     2 restricted_ind             = i2
     2 prompt_location_ind        = i2
     2 unprocessed_ind            = i2
     2 cmpnt_repeat_ind           = i2
     2 cmpnt_left                 = i4
     2 cmpnt_top                  = i4
     2 group_cmpnt_left           = i4
     2 group_cmpnt_top            = i4
     2 column_heading             = vc
      2 ref_range_script           = vc
      2 mins_back                  = f8
      2 default_result             = f8
     2 option_border_ind          = i2
     2 provider_phys_ind          = i2
     2 field_size_flag            = i2
     2 decimal_digits             = i4
     2 catalog_type_meaning       = vc
     2 mnemonic_type_meaning      = vc
     2 system_defined_flag        = i4
     2 alpha_responses[*]
        3 nomenclature_id       = f8
        3 description           = vc
        3 result_value          = f8
        3 default_ind           = i2
     2 item_classes[*]
        3 item_class_node_id    = f8
     2 conditional_behaviors[*]
        3 condition_id           = f8
        3 input_form_cd          = f8
        3 input_form_version_nbr = i4
        3 condition_control_cd   = f8
        3 effected_control_cd    = f8
        3 condition_flag         = i2
        3 behavior_flag          = i2
        3 range_value_1          = vc
        3 range_value_2          = vc
        3 active_ind             = i2
        3 updt_cnt               = i2
     2 prompt_height             = i4
     2 prompt_width              = i4
     2 backcolor                 = i4
     2 facename                  = c50
     2 fonteffects               = i4
     2 forecolor                 = i4
     2 pointsize                 = i4
     2 reference_ranges[*]
        3 rrf_id                = f8
        3 critical_high         = f8
        3 critical_low          = f8
        3 normal_high           = f8
        3 normal_low            = f8
        3 feasible_high         = f8
        3 feasible_low          = f8
        3 sex_cd                = f8
        3 age_from_minutes      = i4
        3 age_to_minutes        = i4
        3 units_cd              = f8
     2 signature_flag           = i4
     2 io_flag                  = i2
     2 group_prompt_height       = i4
     2 group_prompt_width        = i4
     2 group_backcolor           = i4
     2 group_facename            = vc
     2 group_fonteffects         = i4
     2 group_forecolor           = i4
     2 group_pointsize           = i4
%i CCLSOURCE:status_block.inc
)
		execute fb_get_form_ic with replace("REQUEST", "FORM_REQUEST"), replace("REPLY", "FORM_REPLY")
 		set dta_cnt = value(size(FORM_REPLY->qual,5))
 		set temp_dta_mean=" "
 		set temp_acccept_size = 0
if(dta_cnt > 0)
	set stat = alterlist(verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->
		input_forms[o]->online_items,dta_cnt)
 
	for(d1seq = 1 to dta_cnt)
	set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
		online_items[d1seq].task_assay_cd=form_reply->qual[d1seq].task_assay_cd
	set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
		online_items[d1seq].result_type_cd=form_reply->qual[d1seq].result_type_cd
	set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
		online_items[d1seq].multi_select=form_reply->qual[d1seq].MULTI_RESULT_ALLOWED_IND
	set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
		online_items[d1seq].event_cd=form_reply->qual[d1seq].event_cd
	set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
		online_items[d1seq].description=form_reply->qual[d1seq].DESCRIPTION
	set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
		online_items[d1seq].accept_size=form_reply->qual[d1seq].accept_size
 
	select into "n1"
	from code_value cv
	where cv.code_value=form_reply->qual[d1seq].task_assay_cd
	detail
 	temp_dta_mean=cv.cdf_meaning
 	verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
	online_items[d1seq].task_assay_mean = temp_dta_mean
 	with nocounter
 
        /*Check for repeating controls*/
        if(temp_seg_active = 1 and form_reply->qual[d1seq].MULTI_RESULT_ALLOWED_IND = 1)
    		if(form_reply->qual[d1seq].result_type_cd = verify_reply->RT_INVENTORY_CD)
    			set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
    		online_items[d1seq].dta_check_001=1
    		set stat = setErrorFound(8,d1seq)
    		elseif(form_reply->qual[d1seq].result_type_cd = verify_reply->RT_PROVIDER_CD)
    			set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
    		online_items[d1seq].dta_check_001=1
    		set stat = setErrorFound(8,d1seq)
    		elseif(form_reply->qual[d1seq].result_type_cd = verify_reply->RT_FREETEXT_CD)
    			set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
    		online_items[d1seq].dta_check_001=1
    		set stat = setErrorFound(8,d1seq)
            elseif(form_reply->qual[d1seq].result_type_cd = verify_reply->RT_ORDCAT_CD)
    			set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
    		online_items[d1seq].dta_check_001=1
    		set stat = setErrorFound(8,d1seq)
    		elseif(form_reply->qual[d1seq].result_type_cd = verify_reply->RT_YESNO_CD)
    			set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
    		online_items[d1seq].dta_check_001=1
    		set stat = setErrorFound(8,d1seq)
    		elseif(form_reply->qual[d1seq].result_type_cd = verify_reply->RT_NUMERIC_CD
    		AND form_reply->qual[d1seq].unit_meas_ind=1)
    			set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
    		online_items[d1seq].dta_check_001=1
    		set stat = setErrorFound(8,d1seq)
    		endif
    		/* This is a repeating control in a repeating group */
    		if(form_reply->qual[d1seq].repeat_ind = 1)
    		  set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
    		online_items[d1seq].dta_check_013=1
    		set stat = setErrorFound(8,d1seq)
    		endif
    	endif
    	/*Check to see if dta had unprocessed versions*/
    	select into "n1"
    	from online_item_definition oid
        where oid.unprocessed_ind=1
        and oid.task_assay_cd=verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
        online_items[d1seq].task_assay_cd
        head report
        count3=0
        detail
        count3 = count3 +1
        with counter
        if(temp_seg_active = 1 and curqual > 0)
            set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
        online_items[d1seq].dta_check_014=1
            set stat = setWarnFound(8,d1seq)
        endif
 
    	/* Check for repeating group with fields that shouldn't be in a repeating group*/
    	if(temp_seg_active = 1 and form_reply->qual[d1seq].repeat_ind=1)
    	   /* Ord Catalog controls */
    	   if(form_reply->qual[d1seq].result_type_cd = verify_reply->RT_ORDCAT_CD)
    			set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
    		online_items[d1seq].dta_check_010=1
    		set stat = setErrorFound(8,d1seq)
    		/* Numeric with a UOM defined */
    		elseif(form_reply->qual[d1seq].result_type_cd = verify_reply->RT_NUMERIC_CD
    		AND form_reply->qual[d1seq].unit_meas_ind=1)
    			set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
    		online_items[d1seq].dta_check_010=1
    		set stat = setErrorFound(8,d1seq)
    		;Inv controls
    		elseif(form_reply->qual[d1seq].result_type_cd = verify_reply->RT_INVENTORY_CD)
    			set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
    		online_items[d1seq].dta_check_010=1
    		set stat = setErrorFound(8,d1seq)
    		;Freetext fields that allow over 80 characters
    		elseif(form_reply->qual[d1seq].result_type_cd = verify_reply->RT_FREETEXT_CD
    		and (form_reply->qual[d1seq].accept_size = 0 or form_reply->qual[d1seq].accept_size > 80))
    			set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
    		online_items[d1seq].dta_check_010=1
    		set stat = setErrorFound(8,d1seq)
    		endif
    	endif
		;Check for repeating groups in repeating form
		if(temp_seg_active = 1 and form_reply->repeat_ind=1 AND form_reply->qual[d1seq].repeat_ind=1)
			set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o].form_check_004=1
			set stat = setErrorFound(7,o)
		endif
	;Verify event code is real
 	set temp_dta_event_cd = verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->
 	input_forms[o]->online_items[d1seq].event_cd
 	if(temp_seg_active = 1 and temp_dta_event_cd > 0)
		select into "n1"
		from code_value cv,v500_event_code vec
		where cv.code_value=temp_dta_event_cd
		and cv.code_set=72
		and cv.active_ind=1
		and vec.event_cd=cv.code_value
 
		head report
		count3=0
 		detail
		count3 = count3 +1
    	with nocounter
		if(curqual = 0)
			set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
    		online_items[d1seq].DTA_CHECK_011 = 1
			set stat = setErrorFound(8,d1seq)
		else
			set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
    		online_items[d1seq].DTA_CHECK_011 = 0
		endif
    endif
		;Check for form with 2 inv controls
		if(temp_seg_active = 1 and (form_reply->qual[d1seq].result_type_cd = verify_reply->RT_INVENTORY_CD) and (has_inv = 1))
			set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].seg_check_004 = 1
			set stat = setErrorFound(6,n)
		elseif(form_reply->qual[d1seq].result_type_cd = RT_INVENTORY_CD)
			set has_inv = 1
		endif
		;check freetext control with no limit defined
		if(temp_seg_active = 1 and
		(form_reply->qual[d1seq].result_type_cd = verify_reply->RT_FREETEXT_CD) and verify_reply->areas[i]->stages[j]->documents[l]->
		segment_grp[m]->segments[n]->input_forms[o]->online_items[d1seq].accept_size=form_reply->qual[d1seq].accept_size = 0)
			set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
    		online_items[d1seq].dta_check_002 = 1
			set stat = setErrorFound(8,d1seq)
		endif
		if(temp_seg_active = 1)
    		;Check character limits on Implant segment freetext fields only if they're in an active segment
    		if(temp_dta_mean="SN-IMP-CAT" and form_reply->qual[d1seq].accept_size != 50)
                set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
        		online_items[d1seq].dta_check_004 = 1
    			set stat = setErrorFound(8,d1seq)
    		elseif(temp_dta_mean="SN-IMP-HST" and form_reply->qual[d1seq].accept_size != 100)
                set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
        		online_items[d1seq].dta_check_005 = 1
    			set stat = setErrorFound(8,d1seq)
    		elseif(temp_dta_mean="SN-IMP-LOT" and form_reply->qual[d1seq].accept_size != 50)
                set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
        		online_items[d1seq].dta_check_006 = 1
    			set stat = setErrorFound(8,d1seq)
    		elseif(temp_dta_mean="SN-IMP-MAN" and form_reply->qual[d1seq].accept_size != 100)
                set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
        		online_items[d1seq].dta_check_007 = 1
    			set stat = setErrorFound(8,d1seq)
    		elseif(temp_dta_mean="SN-EQ-SNBR" and form_reply->qual[d1seq].accept_size != 50)
                set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
        		online_items[d1seq].dta_check_008 = 1
    			set stat = setErrorFound(8,d1seq)
    		elseif(temp_dta_mean="SN-IMP-SZ" and form_reply->qual[d1seq].accept_size != 50)
                set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
        		online_items[d1seq].dta_check_009 = 1
    			set stat = setErrorFound(8,d1seq)
    		elseif(temp_dta_mean="SN-EQ-DESC" and form_reply->qual[d1seq].accept_size != 200)
                set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
        		online_items[d1seq].dta_check_003 = 1
    			set stat = setErrorFound(8,d1seq)
    		endif
    	endif
	;Fail CDF Meaning check, then unset if it passes
    set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
    	online_items[d1seq].dta_check_012 = 1
	;Check that INV has a unique meaning
	if(temp_seg_active = 1 and temp_dta_mean != "USER" and trim(temp_dta_mean) != NULL)
            set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->
    		online_items[d1seq].dta_check_012 = 0
		if(form_reply->qual[d1seq].result_type_cd = verify_reply->RT_INVENTORY_CD)
			;If it's not USER or NULL Store INV CDF to ensure it's not re-used
			set inv_cdf_size = size(verify_reply->areas[i]->stages[j]->documents[l].check_026,5)
			for(b = 1 to inv_cdf_size)
				if(verify_reply->areas[i]->stages[j]->documents[l].check_026[b].item1 = temp_dta_mean)
				set verify_reply->areas[i]->stages[j]->documents[l].check_026[b].dupe = 1
				set verify_reply->areas[i]->stages[j]->documents[l].doc_check_026 = 1
				set inv_cdf_size = inv_cdf_size +1
				set stat = alterlist(verify_reply->areas[i]->stages[j]->documents[l].check_026,inv_cdf_size)
				set verify_reply->areas[i]->stages[j]->documents[l].check_026[inv_cdf_size].dupe = 1
				set verify_reply->areas[i]->stages[j]->documents[l].check_026[inv_cdf_size].item1 = temp_dta_mean
				set verify_reply->areas[i]->stages[j]->documents[l].check_026[inv_cdf_size].item2 = temp_seg_disp
				set verify_reply->areas[i]->stages[j]->documents[l].check_026[inv_cdf_size].item3 =
verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o].input_form_display
				set verify_reply->areas[i]->stages[j]->documents[l].check_026[inv_cdf_size].item4 =
verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->online_items[d1seq].description
				set stat = setErrorFound(4,l)
				set b = inv_cdf_size
				endif
			endfor
			set inv_cdf_size = size(verify_reply->areas[i]->stages[j]->documents[l].check_026,5)
			;if the above loop did not include our cdf, then it's not a dupe, add it to the structure
			if(verify_reply->areas[i]->stages[j]->documents[l].check_026[inv_cdf_size].dupe = 0)
				set inv_cdf_size = inv_cdf_size +1
				set stat = alterlist(verify_reply->areas[i]->stages[j]->documents[l].check_026,inv_cdf_size)
				set verify_reply->areas[i]->stages[j]->documents[l].check_026[inv_cdf_size].item1 = temp_dta_mean
				set verify_reply->areas[i]->stages[j]->documents[l].check_026[inv_cdf_size].item2 = temp_seg_disp
				set verify_reply->areas[i]->stages[j]->documents[l].check_026[inv_cdf_size].item3 =
verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o].input_form_display
				set verify_reply->areas[i]->stages[j]->documents[l].check_026[inv_cdf_size].item4 =
verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->online_items[d1seq].description
				set verify_reply->areas[i]->stages[j]->documents[l].check_026[inv_cdf_size].dupe = 0
			endif
		endif
	endif
    ;See if patient in/out room fields are defined
    if(temp_seg_active = 1 AND temp_seg_mean="CASETIMES")
        if(temp_dta_mean = "CT-PATINRM")
			set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].seg_check_015 = 1
		elseif(temp_dta_mean = "CT-PATOUTRM")
			set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].seg_check_016 = 1
		elseif(temp_dta_mean = "CT-PACIPIN")
			set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].seg_check_015 = 1
		elseif(temp_dta_mean = "CT-PACIPOUT")
			set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].seg_check_016 = 1
		elseif(temp_dta_mean = "CT-PACIIPIN")
			set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].seg_check_015 = 1
		elseif(temp_dta_mean = "CT-PACIIPDIS")
			set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].seg_check_016 = 1
		elseif(temp_dta_mean = "CT-PREPTIN")
			set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].seg_check_015 = 1
        elseif(temp_dta_mean = "CT-PREPTOUT")
			set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].seg_check_016 = 1
		elseif(verify_reply->areas[i]->stages[j]->documents[l].acuity_flag = 1 AND temp_dta_mean = "CT-PACUPTIN")
            set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].seg_check_015 = 1
        elseif(verify_reply->areas[i]->stages[j]->documents[l].acuity_flag = 1 AND temp_dta_mean = "CT-PACUPTOUT")
            set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].seg_check_016 = 1
		endif
 
    endif
	if(temp_seg_active = 1 and verify_reply->areas[i]->stages[j]->documents[l].doc_type_meaning="ORNURSE")
		if(temp_seg_mean="CASEOVERVW")
			if(temp_dta_mean = "CSD-OR")
				set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].seg_check_005 = 1
			elseif(temp_dta_mean = "CSD-ASACLASS")
				set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].seg_check_006 = 1
			elseif(temp_dta_mean = "CSD_SPECIAL")
				set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].seg_check_007 = 1
			elseif(temp_dta_mean = "CSD-CASELEVE")
				set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].seg_check_008 = 1
			elseif(temp_dta_mean = "CSD-WOUND")
				set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].seg_check_009 = 1
			elseif(temp_dta_mean = "CSD-PREDESC")
				set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].seg_check_010 = 1
			elseif(temp_dta_mean = "CSD-POSTDESC")
				set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].seg_check_011 = 1
			elseif(temp_dta_mean = "CSD-POSTSAME")
				set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].seg_check_012 = 1
			endif
		elseif(temp_seg_mean="SURGPROCS")
			if(temp_dta_mean = "PROC-PROCEDU")
				set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].seg_check_017 = 1
			elseif(temp_dta_mean = "PROC-SURGEON")
				set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].seg_check_018 = 1
			elseif(temp_dta_mean = "PROC-PRIMARY")
				set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].SEG_CHECK_019 = 1
			elseif(temp_dta_mean = "PROC-START")
				set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].SEG_CHECK_022 = 1
			elseif(temp_dta_mean = "PROC-STOP")
				set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].SEG_CHECK_023 = 1
			endif
		elseif(temp_seg_mean="CASETIMES")
			if(temp_dta_mean = "CT-SURGSTART")
				set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].seg_check_013 = 1
			elseif(temp_dta_mean = "CT-SURGSTOP")
				set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].seg_check_014 = 1
			endif
		elseif(temp_seg_mean="CASEATTEND")
			if(temp_dta_mean = "SN-ATT-ATTEN")
				set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].seg_check_020 = 1
			elseif(temp_dta_mean = "SN-ATT-ROLE")
				set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].seg_check_021 = 1
			endif
		endif
	endif
	if(temp_seg_active = 1)
		 	/*if we're trying to prove the ACUITY check passed, check each piece to see if we got them */
		 	if(verify_reply->areas[i]->stages[j]->documents[l].doc_check_009 = 1)
		 	/* This is a tree structure, so the segment must be correct, then the form, then the DTAs
 			if something at the start fails, the rest fail the check			*/
		 	 if(temp_seg_mean="ACUITYLEVEL")
		 			set verify_reply->areas[i]->stages[j]->documents[l].check_009[1].item1 = 0
		 	  if(tempformmean = "ACUITYLEVEL")
		 			set verify_reply->areas[i]->stages[j]->documents[l].check_009[1].item2 = 0
		 		if(temp_dta_mean = "CT-PACUPTIN")
		 			set verify_reply->areas[i]->stages[j]->documents[l].check_009[1].item3 = 0
		 		endif
		 		if(temp_dta_mean = "CT-PACUPTOUT")
		 			set verify_reply->areas[i]->stages[j]->documents[l].check_009[1].item4 = 0
		 		endif
		 		if(temp_dta_mean = "SN-ACCU-LEV")
		 			set verify_reply->areas[i]->stages[j]->documents[l].check_009[1].item5 = 0
		 		endif
		 	  endif /*end form*/
		 	 endif/*end seg*/
		 	    if(verify_reply->areas[i]->stages[j]->documents[l].check_009[1].item1 = 0
		 		and verify_reply->areas[i]->stages[j]->documents[l].check_009[1].item2 = 0
		 		and verify_reply->areas[i]->stages[j]->documents[l].check_009[1].item3 = 0
		 		and verify_reply->areas[i]->stages[j]->documents[l].check_009[1].item4 = 0
		 		and verify_reply->areas[i]->stages[j]->documents[l].check_009[1].item5 = 0)
		 			set verify_reply->areas[i]->stages[j]->documents[l].doc_check_009 = 0
		 		endif
		 	endif /*end doc_check_009*/
		 	/* if we're trying to prove the ROOM CHARGE check passed, check each piece */
		 	if(verify_reply->areas[i]->stages[j]->documents[l].doc_check_023 = 1)
			 	/*if charging using ACUITY, then ACUITY DTAs can be valid for in/out room times starting with 2012.01.18 code
		 		but they must be the acuity segment and form
		 		they could also use the pacu1 or pacu2 room time fields*/
		 	/* 1 segment meaning, 2 form meaning, 3 start time, 4 stop time, 5 room field if ORNURSE doc */
		 	  if(verify_reply->areas[i]->stages[j]->documents[l].acuity_flag = 1
		 		AND temp_seg_mean = "ACUITYLEVEL" and tempformmean = "ACUITYLEVEL")
		 		set verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item1 = 0
		 		set verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item2 = 0
		 			if(temp_dta_mean = "CT-PACUPTIN")
						set verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item3 = 0
					elseif(temp_dta_mean = "CT-PACUPTOUT")
						set verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item4 = 0
					endif
				if(verify_reply->areas[i]->stages[j]->documents[l].doc_room_charge_type = 5)
					if(temp_dta_mean = "CT-PACIPIN")
						set verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item3 = 0
					elseif(temp_dta_mean = "CT-PACIPOUT")
						set verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item4 = 0
					endif
				elseif(verify_reply->areas[i]->stages[j]->documents[l].doc_room_charge_type = 6)
					if(temp_dta_mean = "CT-PACIIPIN")
						set verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item3 = 0
					elseif(temp_dta_mean = "CT-PACIIPDIS")
						set verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item4 = 0
					endif
		 		endif
 			  endif
 			/* This is a tree structure, so the segment must be correct, then the form, then the DTAs
 			if something at the start fails, the rest fail the check			*/
		 	 if(temp_seg_mean="CASETIMES")
		 	   set verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item1 = 0
		 	  if(tempformmean = "CASETIMES")
		 		   set verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item2 = 0
			 	if(verify_reply->areas[i]->stages[j]->documents[l].doc_room_charge_type = 1)
		 			if(temp_dta_mean = "CT-SURGSTART")
						set verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item3 = 0
					elseif(temp_dta_mean = "CT-SURGSTOP")
						set verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item4 = 0
					endif
		 		elseif(verify_reply->areas[i]->stages[j]->documents[l].doc_room_charge_type = 2)
					if(temp_dta_mean = "CT-ANESSTART")
						set verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item3 = 0
					elseif(temp_dta_mean = "CT-ANESSTOP")
						set verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item4 = 0
					endif
		 		elseif(verify_reply->areas[i]->stages[j]->documents[l].doc_room_charge_type = 3)
					if(temp_dta_mean = "CT-PATINRM")
						set verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item3 = 0
					elseif(temp_dta_mean = "CT-PATOUTRM")
						set verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item4 = 0
					endif
				elseif(verify_reply->areas[i]->stages[j]->documents[l].doc_room_charge_type = 4)
					if(temp_dta_mean = "CT-PREPTIN")
						set verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item3 = 0
					elseif(temp_dta_mean = "CT-PREPTOUT")
						set verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item4 = 0
					endif
				elseif(verify_reply->areas[i]->stages[j]->documents[l].doc_room_charge_type = 5)
					if(temp_dta_mean = "CT-PACIPIN")
						set verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item3 = 0
					elseif(temp_dta_mean = "CT-PACIPOUT")
						set verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item4 = 0
					endif
				elseif(verify_reply->areas[i]->stages[j]->documents[l].doc_room_charge_type = 6)
					if(temp_dta_mean = "CT-PACIIPIN")
						set verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item3 = 0
					elseif(temp_dta_mean = "CT-PACIIPDIS")
						set verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item4 = 0
					endif
		 		endif /*end dta checks*/
		 	  endif /*end form check*/
		 	 endif /*end seg check*/
		 		/*the ROOM is required for ORNURSE document room charges, otherwise we use the STAGE CODE, so auto-pass it */
		 		if(verify_reply->areas[i]->stages[j]->documents[l].doc_type_meaning = "ORNURSE")
			 		if(temp_dta_mean = "CSD-OR")
			 			set verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item5 = 0
			 		endif
			 	else
			 		set verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item5 = 0
		 		endif
		 		if(verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item1 = 0
		 		and verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item2 = 0
		 		and verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item3 = 0
		 		and verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item4 = 0
		 		and verify_reply->areas[i]->stages[j]->documents[l].check_023[1].item5 = 0)
		 			set verify_reply->areas[i]->stages[j]->documents[l].doc_check_023 = 0
		 		endif
		 	endif
		 	;Charging for ANES, validate build
		 /* 1 segment meaning, 2 form meaning, 3 start time, 4 stop time, 5 anes type field, 6 ornurse doc */
		 /* This is a tree structure, so the document must be correct,
		 then the segment must be correct,
		 then the form,
		 then the DTAs
		 exception for the ANES type, those just need to exist in the correct segment / document
 		 if something at the start fails, the rest fail the check
 		 */
		 	if(verify_reply->areas[i]->stages[j]->documents[l].doc_check_024 = 1)
		 	 if(verify_reply->areas[i]->stages[j]->documents[l].doc_type_meaning = "ORNURSE")
			 		set verify_reply->areas[i]->stages[j]->documents[l].check_024[1].item6 = 0
			 	if(tempformmean = "SURGPROCS")
				    if(temp_dta_mean = "PROC-ANES")
						set verify_reply->areas[i]->stages[j]->documents[l].check_024[1].item5 = 0
					endif
				endif
				if(tempformmean = "CASEOVERVW" )
					if(temp_dta_mean = "CSD-ANES")
						set verify_reply->areas[i]->stages[j]->documents[l].check_024[1].item5 = 0
					endif
			    endif
			  if(temp_seg_mean="CASETIMES")
			 	   set verify_reply->areas[i]->stages[j]->documents[l].check_024[1].item1 = 0
			 	if(tempformmean = "CASETIMES")
			 	   set verify_reply->areas[i]->stages[j]->documents[l].check_024[1].item2 = 0
 
		 		if(verify_reply->areas[i]->stages[j]->documents[l].doc_anes_charge = 1)
			 		if(temp_dta_mean = "CT-SURGSTART")
						set verify_reply->areas[i]->stages[j]->documents[l].check_024[1].item3 = 0
					elseif(temp_dta_mean = "CT-SURGSTOP")
						set verify_reply->areas[i]->stages[j]->documents[l].check_024[1].item4 = 0
					endif
			 	elseif(verify_reply->areas[i]->stages[j]->documents[l].doc_anes_charge = 2)
					if(temp_dta_mean = "CT-ANESSTART")
						set verify_reply->areas[i]->stages[j]->documents[l].check_024[1].item3 = 0
					elseif(temp_dta_mean = "CT-ANESSTOP")
						set verify_reply->areas[i]->stages[j]->documents[l].check_024[1].item4 = 0
					endif
			 	elseif(verify_reply->areas[i]->stages[j]->documents[l].doc_anes_charge = 3)
					if(temp_dta_mean = "CT-PATINRM")
						set verify_reply->areas[i]->stages[j]->documents[l].check_024[1].item3 = 0
					elseif(temp_dta_mean = "CT-PATOUTRM")
						set verify_reply->areas[i]->stages[j]->documents[l].check_024[1].item4 = 0
					endif
			 	endif
		 	   endif /*end form*/
		 	  endif /*end seg*/
		 	 endif /*end ornurse*/
		 	    if(verify_reply->areas[i]->stages[j]->documents[l].check_024[1].item1 = 0
		 		and verify_reply->areas[i]->stages[j]->documents[l].check_024[1].item2 = 0
		 		and verify_reply->areas[i]->stages[j]->documents[l].check_024[1].item3 = 0
		 		and verify_reply->areas[i]->stages[j]->documents[l].check_024[1].item4 = 0
		 		and verify_reply->areas[i]->stages[j]->documents[l].check_024[1].item5 = 0)
		 			set verify_reply->areas[i]->stages[j]->documents[l].doc_check_024 = 0
		 	    endif
		 	endif /*end doc_check_024*/
		 ;Reverse the checks on the DTAs once we gone through them all on the form
 /* SECTION REDACTED for GITHUB */
	endfor /*DTA*/
	else /* dta_cnt > 0 */
        if(temp_seg_active = 1)
		  set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o].form_check_003 = 1
		  set stat = setErrorFound(7,o)
		endif
	endif /* dta_cnt > 0 */
endif /* input code > 0*/
	endfor /*Form*/
		free set form_reply
	 	free set individual_fields
	 	free set group_fields
endfor /*Seg*/
			endfor /*SegGrp*/
			/*if we have no segments, but trying to charge for room/Anes, we need to flag it here*/
			if(verify_reply->areas[i]->stages[j]->documents[l].doc_check_023 = 1)
			 set stat = setErrorFound(4,l)
			endif
			if(verify_reply->areas[i]->stages[j]->documents[l].doc_check_024 = 1)
			 set stat = setErrorFound(4,l)
			endif
	/*At end of each document loop, reverse check these
	on the last seg of the document for the last seg grp, check some things
	*Reverse the check, if no segment/form found, set to 1 for error found
	*check for any ACTIVE and PRINTABLE segments
	 */
 	;if(m = size(verify_reply->areas[i]->stages[j]->documents[l]->segment_grp,5))
		;if(n = size(verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments,5))
			/*CT*/
		 	if(verify_reply->areas[i]->stages[j]->documents[l].doc_check_005 = 0)
		 		set verify_reply->areas[i]->stages[j]->documents[l].doc_check_005 = 1
		 		set stat = setErrorFound(4,l)
		 	elseif(verify_reply->areas[i]->stages[j]->documents[l].doc_check_005 >= 1)
		 		set verify_reply->areas[i]->stages[j]->documents[l].doc_check_005 = 0
		 	endif
		;this is an ornurse only check
        if(verify_reply->areas[i]->stages[j]->documents[l].doc_type_meaning="ORNURSE")
		 	if(verify_reply->areas[i]->stages[j]->documents[l].doc_check_006 = 0)
		 		set verify_reply->areas[i]->stages[j]->documents[l].doc_check_006 = 1
		 		set stat = setErrorFound(4,l)
		 	elseif(verify_reply->areas[i]->stages[j]->documents[l].doc_check_006 >= 1)
		 		set verify_reply->areas[i]->stages[j]->documents[l].doc_check_006 = 0
		 	endif
		 	if(verify_reply->areas[i]->stages[j]->documents[l].doc_check_018 = 0)
		 		set verify_reply->areas[i]->stages[j]->documents[l].doc_check_018 = 1
		 		set stat = setErrorFound(4,l)
		 	elseif(verify_reply->areas[i]->stages[j]->documents[l].doc_check_018 >= 1)
		 		set verify_reply->areas[i]->stages[j]->documents[l].doc_check_018 = 0
		 	endif
		 	/*GCD*/
		 	if(verify_reply->areas[i]->stages[j]->documents[l].doc_check_010 = 0)
		 		set verify_reply->areas[i]->stages[j]->documents[l].doc_check_010 = 1
		 		set stat = setErrorFound(4,l)
		 	elseif(verify_reply->areas[i]->stages[j]->documents[l].doc_check_010 >= 1)
		 		set verify_reply->areas[i]->stages[j]->documents[l].doc_check_010 = 0
		 	endif
		 	if(verify_reply->areas[i]->stages[j]->documents[l].doc_check_011 = 0)
		 		set verify_reply->areas[i]->stages[j]->documents[l].doc_check_011 = 1
		 		set stat = setErrorFound(4,l)
		 	elseif(verify_reply->areas[i]->stages[j]->documents[l].doc_check_011 >= 1)
		 		set verify_reply->areas[i]->stages[j]->documents[l].doc_check_011 = 0
		 	endif
		 	if(verify_reply->areas[i]->stages[j]->documents[l].doc_check_019 = 0)
		 		set verify_reply->areas[i]->stages[j]->documents[l].doc_check_019 = 1
		 		set stat = setErrorFound(4,l)
		 	elseif(verify_reply->areas[i]->stages[j]->documents[l].doc_check_019 >= 1)
		 		set verify_reply->areas[i]->stages[j]->documents[l].doc_check_019 = 0
		 	endif
        endif
		 	/*ATTE*/
		 	if(verify_reply->areas[i]->stages[j]->documents[l].doc_check_012 = 0)
		 		set verify_reply->areas[i]->stages[j]->documents[l].doc_check_012 = 1
		 		set stat = setErrorFound(4,l)
		 	elseif(verify_reply->areas[i]->stages[j]->documents[l].doc_check_012 >= 1)
		 		set verify_reply->areas[i]->stages[j]->documents[l].doc_check_012 = 0
		 	endif
/* SECTION REDACTED for GITHUB */
		 	/*printable segment*/
		 	if(temp_seg_printable = 0)
		 		set verify_reply->areas[i]->stages[j]->documents[l].doc_check_022 = 1
		 		set stat = setErrorFound(4,l)
		 	endif
 		;endif
 	;endif /* end reverse checks for last seggrp / last segment */
 		endfor /*Doc*/
	endfor /*Stage*/
	/* Reverse the check, if no ORNURSE found, set to 1 for error found, but only after all documents have been reviewed */
	if(verify_reply->areas[i].area_check_005 = 0)
		set verify_reply->areas[i].area_check_005 = 1
		set stat = setErrorFound(2,i)
	elseif(verify_reply->areas[i].area_check_005 = 1)
		set verify_reply->areas[i].area_check_005 = 0
	endif
endfor /*Area*/
 
end /*End get Document Build*/
 
/* this subroutine marks error_found on specific level and up
 
it takes the level you want to set the lowest error found
 
it takes the variable for the count3 incase you are finding errors in the loop
Example:
if you just failed stage_check_003, then expect to call setErrorFound(3,count3)
the error found level should align with the *_check failed
 
*/
subroutine setErrorFound(level,item)
	if(level = 2) /* area */
		set verify_reply->areas[item].error_found = 1
	elseif(level = 3) /* stage */
		set verify_reply->areas[i].error_found = 1
		set verify_reply->areas[i]->stages[item].error_found = 1
	elseif(level = 4) /* doc */
		set verify_reply->areas[i].error_found = 1
		set verify_reply->areas[i]->stages[j].error_found = 1
		set verify_reply->areas[i]->stages[j]->documents[item].error_found = 1
	elseif(level = 5) /* seg grp */
		set verify_reply->areas[i].error_found = 1
		set verify_reply->areas[i]->stages[j].error_found = 1
		set verify_reply->areas[i]->stages[j]->documents[l].error_found = 1
		set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[item].error_found = 1
	elseif(level = 6) /* seg */
		set verify_reply->areas[i].error_found = 1
		set verify_reply->areas[i]->stages[j].error_found = 1
		set verify_reply->areas[i]->stages[j]->documents[l].error_found = 1
		set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m].error_found = 1
		set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[item].error_found = 1
	elseif(level = 7) /* form */
		set verify_reply->areas[i].error_found = 1
		set verify_reply->areas[i]->stages[j].error_found = 1
		set verify_reply->areas[i]->stages[j]->documents[l].error_found = 1
		set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m].error_found = 1
		set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].error_found = 1
		set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[item].error_found = 1
	elseif(level = 8) /* dta */
		set verify_reply->areas[i].error_found = 1
		set verify_reply->areas[i]->stages[j].error_found = 1
		set verify_reply->areas[i]->stages[j]->documents[l].error_found = 1
		set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m].error_found = 1
		set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].error_found = 1
		set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o].error_found = 1
set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->online_items[item].error_found = 1
	endif
end /* end errorFound sub */
subroutine setWarnFound(level,item)
	if(level = 2) /* area */
		set verify_reply->areas[item].warn_found = 1
	elseif(level = 3) /* stage */
		set verify_reply->areas[i].warn_found = 1
		set verify_reply->areas[i]->stages[item].warn_found = 1
	elseif(level = 4) /* doc */
		set verify_reply->areas[i].warn_found = 1
		set verify_reply->areas[i]->stages[j].warn_found = 1
		set verify_reply->areas[i]->stages[j]->documents[item].warn_found = 1
	elseif(level = 5) /* seg grp */
		set verify_reply->areas[i].warn_found = 1
		set verify_reply->areas[i]->stages[j].warn_found = 1
		set verify_reply->areas[i]->stages[j]->documents[l].warn_found = 1
		set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[item].warn_found = 1
	elseif(level = 6) /* seg */
		set verify_reply->areas[i].warn_found = 1
		set verify_reply->areas[i]->stages[j].warn_found = 1
		set verify_reply->areas[i]->stages[j]->documents[l].warn_found = 1
		set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m].warn_found = 1
		set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[item].warn_found = 1
	elseif(level = 7) /* form */
		set verify_reply->areas[i].warn_found = 1
		set verify_reply->areas[i]->stages[j].warn_found = 1
		set verify_reply->areas[i]->stages[j]->documents[l].warn_found = 1
		set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m].warn_found = 1
		set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].warn_found = 1
		set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[item].warn_found = 1
	elseif(level = 8) /* dta */
		set verify_reply->areas[i].warn_found = 1
		set verify_reply->areas[i]->stages[j].warn_found = 1
		set verify_reply->areas[i]->stages[j]->documents[l].warn_found = 1
		set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m].warn_found = 1
		set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n].warn_found = 1
		set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o].warn_found = 1
set verify_reply->areas[i]->stages[j]->documents[l]->segment_grp[m]->segments[n]->input_forms[o]->online_items[item].warn_found = 1
	endif
end /* end warnFound sub */
 
 
call PutJSONRecordToFile(verify_reply)
end go
SET TRACE NOTRANSLATELOCK GO