function loadDocumentTab() {
  try{
    var pptSec = _g("report");
    var pptObj = mpObj.DOCUMENT.BLOB.AREAS;
    var instObj = mpObj.DOCUMENT.BLOB.INSTITUTIONS;
    pptLen = pptObj.length;
    instLen = instObj.length;
    var InstitutionIMG = "<IMG src=\"" + mpObj.ipath + "/images/institution.png\" class='surginet-icon' title='Institution level' />";
    var AreaIMG = "<IMG src=\"" + mpObj.ipath + "/images/area.png\" class='surginet-icon' title='Surgical Area level' />";
    var StageIMG = "<IMG src=\"" + mpObj.ipath + "/images/stage.png\" class='surginet-icon' title='Surgical Stage level' />";
    var DocumentIMG = "<IMG src=\"" + mpObj.ipath + "/images/document.png\" class='surginet-icon' title='Document level' />";
    var SegGroupIMG = "<IMG src=\"" + mpObj.ipath + "/images/seggroup.png\" class='surginet-icon' title='Segment Group level' />";
    var SegmentIMG = "<IMG src=\"" + mpObj.ipath + "/images/segment.png\" class='surginet-icon' title='Segment level' />";
    var inactSegmentIMG = "<IMG src=\"" + mpObj.ipath + "/images/inactive_segment.png\" class='surginet-icon' title='Inactive Segment level' />";
    var FormIMG = "<IMG src=\"" + mpObj.ipath + "/images/form_icon.png\" class='surginet-icon' title='Form Level' />";
    var FieldIMG = "<IMG src=\"" + mpObj.ipath + "/images/field.png\" class='surginet-icon' title='Field level' />";
    var currSegmentIMG = " "; /* Used to toggle active vs inactive segment image */
    var temp_display; /*used for displaying unique information in dialogs */
    var DTA_TYPE = ppt_strings.DTA_UNKNOWN;
    var OrganizationName = instObj[0].INSTITUTION_NAME;
    for (var i = 0; i < pptLen; i++) {
      var pptItem = pptObj[i];
      var formMulti;
      if (i === 0) {
        pptHTML = "<div class='org-block'><h1 id='org-header'>" + InstitutionIMG + ppt_strings.INTRO_DOC_TAB + OrganizationName + ppt_strings.ORGANIZATION+"</h1>";
      }
      pptHTML += "<div class='area-block'><h2 id='area-header'>" + AreaIMG + ppt_strings.SURGICAL_AREA+": "+ pptItem.AREA_DISPLAY + "</h2>";
      // Set the error class if needed
      if (pptItem.ERROR_FOUND === 1) {
        pptHTML += "<div class='area-container error-found'>";
      } else {
        pptHTML += "<div class='area-container'>";
      }
      temp_display = pptItem.AREA_PREFIX+" ";
      pptHTML += getStringForCheck(pptItem,"AREA_CHECK_001",temp_display);
      temp_display = " ";
      pptHTML += getStringForCheck(pptItem,"AREA_CHECK_002");
      pptHTML += getStringForCheck(pptItem,"AREA_CHECK_003");
      temp_display = ppt_strings.TRACKING_GROUP +": "+ pptItem.AREA_TRACKING_GRP +" / "+ ppt_strings.TRACKING_LOC +": "+ pptItem.AREA_TRACKING_LOC;
      pptHTML += getStringForCheck(pptItem,"AREA_CHECK_004",temp_display);
      temp_display = " ";
      pptHTML += getStringForCheck(pptItem,"AREA_CHECK_005");
      pptHTML += getStringForCheck(pptItem,"AREA_CHECK_006");
      pptHTML += getStringForCheck(pptItem,"AREA_CHECK_007");
      pptHTML += getStringForCheck(pptItem,"AREA_CHECK_008");
      pptHTML += getStringForCheck(pptItem,"AREA_CHECK_009");
      //===================== Surgical Staging Areas ===========================//
      var stageObj = pptObj[i].STAGES;
      stageLen = stageObj.length;
      for (var j = 0; j < stageLen; j++) {
        //create the div for the whole staging area section
        if (j === 0) {
          pptHTML += "<div class='stage-block'>";
        }
        var stageItem = stageObj[j];
        pptHTML += "<h3 id='stage-header'>" + StageIMG + ppt_strings.STAGING_AREA+": "+ stageItem.STAGE_DISPLAY + "</h3>";
        // Set the error class if needed
        if (stageItem.ERROR_FOUND === 1) {
          pptHTML += "<div class='stage-container error-found'>";
        } else {
          pptHTML += "<div class='stage-container'>";
        }
        temp_display = stageItem.STAGE_PREFIX+" ";
        pptHTML += getStringForCheck(stageItem,"STAGE_CHECK_001",temp_display);
        temp_display = " ";
        pptHTML += getStringForCheck(stageItem,"STAGE_CHECK_003");
        pptHTML += getStringForCheck(stageItem,"STAGE_CHECK_002");
        //======================= Documents =========================//
        var documentObj = stageObj[j].DOCUMENTS;
        docLen = documentObj.length;
        for (var k = 0; k < docLen; k++) {
          var documentItem = documentObj[k];
          pptHTML += "<div class='doc-block'><h4 id='doc-header'>" + DocumentIMG + ppt_strings.DOCUMENT+": "+ documentItem.DOC_TYPE_DISPLAY + "&nbsp&nbsp&ndash;&nbsp&nbsp<span title='Code Value'>" + documentItem.DOC_TYPE_CD + "</span></h4>";
          // Set the error class if needed
          if (documentItem.ERROR_FOUND === 1) {
            pptHTML += "<div class='doc-container error-found'>";
          } else {
            pptHTML += "<div class='doc-container'>";
          }
          temp_display = documentItem.DOC_TYPE_MEANING+" ";
          pptHTML += getStringForCheck(documentItem,"DOC_CHECK_001",temp_display);
          temp_display = " ";
          if (documentItem.DOC_TYPE_MEANING !== "INTRAANESTH") {
            pptHTML += getStringForCheck(documentItem,"DOC_CHECK_022");
            if (documentItem.DOC_ROOM_CHARGE_TYPE > 0) {
              if (documentItem.DOC_ROOM_CHARGE_TYPE === 1) {
                temp_display = ppt_strings.SURGERY_TIMES;
              } else if (documentItem.DOC_ROOM_CHARGE_TYPE === 2) {
                temp_display = ppt_strings.ANESTHESIA_TIMES;
              } else if (documentItem.DOC_ROOM_CHARGE_TYPE === 3) {
                temp_display = ppt_strings.OR_ROOM_TIMES;
              } else if (documentItem.DOC_ROOM_CHARGE_TYPE === 4) {
                temp_display = ppt_strings.PRE_ROOM_TIMES;
              } else if (documentItem.DOC_ROOM_CHARGE_TYPE === 5) {
                temp_display = ppt_strings.PACU_ROOM_TIMES;
              } else if (documentItem.DOC_ROOM_CHARGE_TYPE === 6) {
                temp_display = ppt_strings.PACUII_ROOM_TIMES;
              } else {
                temp_display = ppt_strings.UNKNOWN_CHARGE;
              }
              pptHTML += getStringForCheck(documentItem,"DOC_CHECK_023",temp_display);
            }
            if(documentItem.ACUITY_FLAG > 0) {
              pptHTML += getStringForCheck(documentItem,"DOC_CHECK_009");
            }
            if (documentItem.DOC_ANES_CHARGE > 0) {
              if (documentItem.DOC_ANES_CHARGE === 1) {
                temp_display = ppt_strings.SURGERY_TIMES;
              } else if (documentItem.DOC_ANES_CHARGE === 2) {
                temp_display = ppt_strings.ANESTHESIA_TIMES;
              } else if (documentItem.DOC_ANES_CHARGE === 3) {
                temp_display = ppt_strings.OR_ROOM_TIMES;
              } else {
                temp_display = ppt_strings.UNKNOWN_CHARGE;
              }
              pptHTML += getStringForCheck(documentItem,"DOC_CHECK_024",temp_display);
            }
            temp_display = " ";
            if (documentItem.DOC_CHECK_004 === 0) {
              temp_display = documentItem.CHECK_004[0].ITEM1+" - "+documentItem.CHECK_004[0].ITEM2;
            }
            pptHTML += getStringForCheck(documentItem,"DOC_CHECK_004",temp_display);
            temp_display = " ";
            /* do case times seg check outside of ornurse since it can apply to postop and preop*/
            pptHTML += getStringForCheck(documentItem,"DOC_CHECK_006");
            pptHTML += getStringForCheck(documentItem,"DOC_CHECK_007");
            pptHTML += getStringForCheck(documentItem,"DOC_CHECK_005");
            pptHTML += getStringForCheck(documentItem,"DOC_CHECK_008");
            pptHTML += getStringForCheck(documentItem,"DOC_CHECK_012");
            pptHTML += getStringForCheck(documentItem,"DOC_CHECK_013");
            pptHTML += getStringForCheck(documentItem,"DOC_CHECK_014");
            pptHTML += getStringForCheck(documentItem,"DOC_CHECK_026");
            pptHTML += getStringForCheck(documentItem,"DOC_CHECK_025");
            pptHTML += getStringForCheck(documentItem,"DOC_CHECK_027");
            pptHTML += getStringForCheck(documentItem,"DOC_CHECK_002");
            if (documentItem.DOC_TYPE_MEANING === "ORNURSE") {
              /*has a GCD, only 1 GCD, has a SURGPROCS, only 1 SURGPROCS segments*/
              pptHTML += getStringForCheck(documentItem,"DOC_CHECK_010");
              pptHTML += getStringForCheck(documentItem,"DOC_CHECK_011");
              pptHTML += getStringForCheck(documentItem,"DOC_CHECK_016");
              pptHTML += getStringForCheck(documentItem,"DOC_CHECK_017");
              /* Check for 4 required input forms */
              pptHTML += getStringForCheck(documentItem,"DOC_CHECK_018");
              pptHTML += getStringForCheck(documentItem,"DOC_CHECK_019");
              pptHTML += getStringForCheck(documentItem,"DOC_CHECK_020");
              pptHTML += getStringForCheck(documentItem,"DOC_CHECK_021");
            }
            pptHTML += getStringForCheck(documentItem,"DOC_CHECK_003");
          } //End NOT INTRAANES meaning
          //Segment Groups
          var seggrpObj = documentObj[k].SEGMENT_GRP;
          seggrpLen = seggrpObj.length;
          for (var l = 0; l < seggrpLen; l++) {
            var seggrpItem = seggrpObj[l];
            pptHTML += "<div class='seggrp-block'><h4 id='seggrp-header'>" + SegGroupIMG + ppt_strings.SEGGRP+": " + seggrpItem.SEGMENT_GRP_DISPLAY + " &nbsp;&nbsp;&ndash;&nbsp;&nbsp;<span title='Segment Group ID'>" + seggrpItem.SEGMENT_GRP_ID + "</span></h4>";
            pptHTML += "<div class='seg-form-block'>";
            pptHTML += getStringForCheck(seggrpItem,"SEGGRP_CHECK_001");
            //========================== Segments ===============================//
            var segObj = seggrpObj[l].SEGMENTS;
            segLen = segObj.length;
            for (var m = 0; m < segLen; m++) {
              var segItem = segObj[m];
              if (segItem.SEGMENT_ACTIVE === 1) {
                currSegmentIMG = SegmentIMG;
              } else {
                currSegmentIMG = inactSegmentIMG;
              }
              pptHTML += "<div class='segment-block'><h5 id='segment-header'>" + currSegmentIMG + ppt_strings.SEGMENT+": " + segItem.SEGMENT_DISPLAY + " &nbsp;&nbsp;&ndash;&nbsp;&nbsp;<span title='Code Value'>" + segItem.SEG_CD + "</span></h5>";
              // Set the error class if needed
              if (segItem.ERROR_FOUND === 1) {
                pptHTML += "<div class='segment-container error-found'>";
              } else {
                pptHTML += "<div class='segment-container'>";
              }
              /* Some segment checks only matter if the segment is active, meaning don't show 'good' build when it doesn't make sense */
              if (segItem.SEGMENT_ACTIVE === 1) {
                temp_display = segItem.SEGMENT_MEANING+" ";
                pptHTML += getStringForCheck(segItem,"SEG_CHECK_001",temp_display);
                temp_display = " ";
                pptHTML += getStringForCheck(segItem,"SEG_CHECK_003");
                pptHTML += getStringForCheck(segItem,"SEG_CHECK_002");
              }
              pptHTML += getStringForCheck(segItem,"SEG_CHECK_004");
              pptHTML += getStringForCheck(segItem,"SEG_CHECK_005");
              pptHTML += getStringForCheck(segItem,"SEG_CHECK_006");
              pptHTML += getStringForCheck(segItem,"SEG_CHECK_007");
              pptHTML += getStringForCheck(segItem,"SEG_CHECK_008");
              pptHTML += getStringForCheck(segItem,"SEG_CHECK_009");
              pptHTML += getStringForCheck(segItem,"SEG_CHECK_010");
              pptHTML += getStringForCheck(segItem,"SEG_CHECK_011");
              pptHTML += getStringForCheck(segItem,"SEG_CHECK_012");
              if (documentItem.DOC_TYPE_MEANING === "ORNURSE") {
                pptHTML += getStringForCheck(segItem,"SEG_CHECK_013");
                pptHTML += getStringForCheck(segItem,"SEG_CHECK_014");
              }
              pptHTML += getStringForCheck(segItem,"SEG_CHECK_015");
              pptHTML += getStringForCheck(segItem,"SEG_CHECK_016");
              pptHTML += getStringForCheck(segItem,"SEG_CHECK_017");
              pptHTML += getStringForCheck(segItem,"SEG_CHECK_018");
              pptHTML += getStringForCheck(segItem,"SEG_CHECK_019");
              pptHTML += getStringForCheck(segItem,"SEG_CHECK_022");
              pptHTML += getStringForCheck(segItem,"SEG_CHECK_023");
              pptHTML += getStringForCheck(segItem,"SEG_CHECK_020");
              pptHTML += getStringForCheck(segItem,"SEG_CHECK_021");
              //================================= Forms =======================================//
              var formObj = segObj[m].INPUT_FORMS;
              formLen = formObj.length;
              for (var n = 0; n < formLen; n++) {
                var formItem = formObj[n];
                if (formItem.INPUT_FORM_MULTI === 1) {
                  formMulti = "(M)";
                } else {
                  formMulti = " ";
                }
                pptHTML += "<div class='form-block'><h5 id='form-header'>" + FormIMG + ppt_strings.FORM+": " + formItem.INPUT_FORM_DISPLAY + " " + formMulti + "&nbsp;&nbsp;&ndash;&nbsp;&nbsp;<span title='Code Value'>" + formItem.INPUT_FORM_CD + "</span></h5>";
                // Set the error class if needed
                if (formItem.ERROR_FOUND === 1) {
                  pptHTML += "<div class='form-container error-found'>";
                } else {
                  pptHTML += "<div class='form-container'>";
                }
                temp_display = formItem.INPUT_FORM_MEANING;
                pptHTML += getStringForCheck(formItem,"FORM_CHECK_001",temp_display);
                temp_display = " ";
                pptHTML += getStringForCheck(formItem,"FORM_CHECK_002");
                pptHTML += getStringForCheck(formItem,"FORM_CHECK_003");
                /*we only need to warn if it's a multi-entry form */
                if (formItem.FORM_CHECK_004 === 1 & formItem.INPUT_FORM_MULTI === 1) {
                  pptHTML += getStringForCheck(formItem,"FORM_CHECK_004");
                }
                var onlineItemObj = formObj[n].ONLINE_ITEMS;
                onlineLen = onlineItemObj.length;
                var tableFormString = " ";
                //============================== Input Fields ================================//
                for (var o = 0; o < onlineLen; o++) {
                  var onlineItemItem = onlineItemObj[o];
                  pptHTML += "<div class='field-block'><h6 id='field-header'>" + FieldIMG + ppt_strings.DTA+": " + onlineItemItem.DESCRIPTION + "&nbsp;&nbsp;&ndash;&nbsp;&nbsp;<span title='Code Value'>" + onlineItemItem.TASK_ASSAY_CD + "</span></h5>";
                  // Set the error class if needed
                  if (onlineItemItem.ERROR_FOUND === 1) {
                    pptHTML += "<div class='field-container error-found'>";
                  } else {
                    pptHTML += "<div class='field-container'>";
                  }
                  /*this is needed for a couple of checks to clarify the DTA type*/
                  DTA_TYPE = ppt_strings.DTA_UNKNOWN;
                  switch (onlineItemItem.RESULT_TYPE_CD) {
                    case mpObj.DOCUMENT.BLOB.RT_DATETIME_CD:
                    DTA_TYPE = ppt_strings.DTA_DATETIME;
                    break;
                    case mpObj.DOCUMENT.BLOB.RT_INVENTORY_CD:
                    DTA_TYPE = ppt_strings.DTA_INVENTORY;
                    break;
                    case mpObj.DOCUMENT.BLOB.RT_PROVIDER_CD:
                    DTA_TYPE = ppt_strings.DTA_PROVIDER;
                    break;
                    case mpObj.DOCUMENT.BLOB.RT_FREETEXT_CD:
                    DTA_TYPE = ppt_strings.DTA_FREETEXT;
                    break;
                    case mpObj.DOCUMENT.BLOB.RT_ORDCAT_CD:
                    DTA_TYPE = ppt_strings.DTA_ORDCAT;
                    break;
                    case mpObj.DOCUMENT.BLOB.RT_YESNO_CD:
                    DTA_TYPE = ppt_strings.DTA_YESNO;
                    break;
                    case mpObj.DOCUMENT.BLOB.RT_NUMERIC_CD:
                    DTA_TYPE = ppt_strings.DTA_NUMUOM;
                    break;
                  }
                  temp_display = onlineItemItem.TASK_ASSAY_MEAN;
                  pptHTML += getStringForCheck(onlineItemItem,"DTA_CHECK_012",temp_display);
                  temp_display = " ";
                  temp_display = onlineItemItem.EVENT_CD;
                  pptHTML += getStringForCheck(onlineItemItem,"DTA_CHECK_011",temp_display);
                  temp_display = " ";
                  pptHTML += getStringForCheck(onlineItemItem,"DTA_CHECK_013");
                  temp_display = DTA_TYPE;
                  pptHTML += getStringForCheck(onlineItemItem,"DTA_CHECK_010",temp_display);
                  pptHTML += getStringForCheck(onlineItemItem,"DTA_CHECK_001",temp_display);
                  temp_display = " ";
                  pptHTML += getStringForCheck(onlineItemItem,"DTA_CHECK_003");
                  pptHTML += getStringForCheck(onlineItemItem,"DTA_CHECK_004");
                  pptHTML += getStringForCheck(onlineItemItem,"DTA_CHECK_005");
                  pptHTML += getStringForCheck(onlineItemItem,"DTA_CHECK_006");
                  pptHTML += getStringForCheck(onlineItemItem,"DTA_CHECK_007");
                  pptHTML += getStringForCheck(onlineItemItem,"DTA_CHECK_008");
                  pptHTML += getStringForCheck(onlineItemItem,"DTA_CHECK_009");
                  pptHTML += getStringForCheck(onlineItemItem,"DTA_CHECK_002");
                  pptHTML += "</div></div>";
                } //end of ONLINE_ITEMS for and .field-block and .field-container
                pptHTML += "</div></div>";
              } //end of INPUT_FORMS for - and .form-container and .form-block
              pptHTML += "</div></div>";
            } //end of SEGMENTS for and .segment-container and .segment-block and
            pptHTML += "</div></div>";
          } //end of SEGMENT_GRP for
          pptHTML += "</div></div>";
        }// end of DOCUMENTS for - also end doc-block and doc-container divs
        pptHTML += "</div>";
        if (j === stageLen - 1) {
          pptHTML += "</div>";
        }
      } //end of STAGES for - also end stage-container div
      pptHTML += "</div></div>";
    } //end of AREAS for - also end area-block and area-container divs
    pptHTML += "</div>"; //end org-block
    pptSec.innerHTML = pptHTML;
    $('#showErrorsOnly').show();
    enableButtonsTabs(0);
    toggleErrorsOnly();
    if (mpObj.mill === 1) {
      hideGoodBuild();
    }
    mpObj.disable_tabs = 0;
  } catch(err){
    printStackTrace(err,arguments.callee.caller.toString());
  }
}
/**
* Hides the good build so that only the errors are expanded
* if the children or grandchildren have an error then do not hide
*/
function hideGoodBuild() {
  $(".area-container").each(function () {
    //area-container
    var _stageCheck = 0;
    $(this).find(".stage-container").each(function () {
      //stage-container
      var _documentCheck = 0;
      $(this).find(".doc-container").each(function () {
        //doc-container
        var _segmentGroupCheck = 0;
        $(this).find(".seg-form-block").each(function () {
          //seg-form-block
          var _segmentCheck = 0;
          $(this).find(".segment-container").each(function () {
            //segment-container
            var _formCheck = 0;
            $(this).find(".form-container").each(function () {
              //form-containers
              var _fieldCheck = 0;
              $(this).find(".field-container").each(function () {
                //field-containers
                if ($(this).hasClass("error-found")) {
                  //error found set to 1 so the parent div isn't hidden
                  _fieldCheck = 1;
                } else {
                  // hide good build
                  $(this).hide();
                }
              });
              if ($(this).hasClass("error-found") || _fieldCheck === 1) {
                //error found or child div has error, set to 1 so the parent div isn't hidden
                _formCheck = 1;
              } else {
                // hide good build
                $(this).hide();
              }
            });
            if ($(this).hasClass("error-found") || _formCheck === 1) {
              //error found or child div has error, set to 1 so the parent div isn't hidden
              _segmentCheck = 1;
            } else {
              // hide good build
              $(this).hide();
            }
          });
          if ($(this).hasClass("error-found") || _segmentCheck === 1) {
            //error found or child div has error, set to 1 so the parent div isn't hidden
            _segmentGroupCheck = 1;
          } else {
            // hide good build
            $(this).hide();
          }
        });
        if ($(this).hasClass("error-found") || _segmentGroupCheck === 1) {
          //error found or child div has error, set to 1 so the parent div isn't hidden
          _documentCheck = 1;
        } else {
          // hide good build
          $(this).hide();
        }
      });
      if ($(this).hasClass("error-found") || _documentCheck === 1) {
        //error found or child div has error, set to 1 so the parent div isn't hidden
        _stageCheck = 1;
      } else {
        // hide good build
        $(this).hide();
      }
    });
    if ($(this).hasClass("error-found") || _stageCheck === 1) {
      //error found or child div has error, set to 1 so the parent div isn't hidden
      //no need for the area check since it has no parent (that matters)
    } else {
      // hide good build
      $(this).hide();
    }
  });
};
