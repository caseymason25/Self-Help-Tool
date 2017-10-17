/*global mpage object to store values used in subroutines */
var mpObj = {
  "TAB":0, /*tab that the user is on:
  0 - locations
  1 - document build
  2 - procedures
  3 - pref cards
  4 - ops jobs
  5 - rpt blder
  6 - anesthesia
  7 - compare area
  8 - compare doc
  */
  debug_pass: 0,
  debug:0, /*this can be 1 or 0 for blackbird logging*/
  userId: "",
  userName: "",
  mill:0,
  disable_tabs: 1,
  ipath: "",
  "DROPDOWNS":
  {
    "SCRIPT":"mp_appsrv_periop_build",
    "LOADED":0,
    "BLOB":"",
    "TAB":0
  },
  "DOCUMENT":
  {
    "SCRIPT":"mp_appsrv_periop_build",
    "LOADED":0,
    "BLOB":"",
    "NUMERIC_RT":0.0,
    "INVENTORY_RT":0.0,
    "FREETEXT_RT":0.0,
    "PROVIDER_RT":0.0,
    "DATETIME_RT":0.0,
    "TAB":1
  },
  "PROCEDURE":
  {
    "SCRIPT":"mp_appsrv_sn_proc",
    "LOADED":0,
    "BLOB":"",
    "TAB":2
  },
  "LOCATION":
  {
    "SCRIPT":"mp_appsrv_sn_location",
    "LOADED":0,
    "BLOB":"",
    "TAB":3
  },
  "PREFCARD":
  {
    "SCRIPT":"mp_appsrv_sn_prefcards",
    "LOADED":0,
    "BLOB":"",
    "TAB":4
  },
  "OPSJOB":
  {
    "SCRIPT":"mp_appsrv_sn_ops",
    "LOADED":0,
    "BLOB":"",
    "OPS_FILTER":"All",
    "TAB":5
  },
  "RPTBUILDER":
  {
    "SCRIPT":"mp_appsrv_sn_rptbld",
    "LOADED":0,
    "BLOB":"",
    "TAB":6
  },
  "ANESTHESIA":
  {
    "SCRIPT":"mp_appsrv_sa_build",
    "LOADED":0,
    "BLOB":"",
    "TAB":9
  },
  "COMPARE":
  {
    "DOCI18NVALID":0, /*Used to load the client code values into the i18n once*/
    "DOCI18N_BLOB":"",
    "LOADED":0,
    "SCRIPT":"mp_appsrv_sn_prefs",
    "LASTTAB":7
  },
  "COMPARE_AREA":
  {
    "COMPARE_AREA":0, /*first or second column*/
    "COMPARE_AREA1":{"AreaDisp":" "},
    "COMPARE_AREA2":{"AreaDisp":" "},
    "TAB":7
  },
  "COMPARE_DOC":
  {
    "COMPARE_DOC":0, /*first or second column*/
    "COMPARE_DOC1":{"DocDisp":" ",DocCDF:" "},
    "COMPARE_DOC2":{"DocDisp":" ",DocCDF:" "},
    "TAB":8
  },
  /*some checks have the potential to be displayed multiple times on the page,
  such as 2 documents failing the same check (or 2 ops jobs),
  if the dialog needs to have unique information, then
  we keep them separate using the 'EXTRA' array in the i18n file,
  otherwise all checks with unique info just reside at spot 0
  this is the 'AFFECTED' section seen in the dialogs */
  "NUM":
  {
    "DOC_CHECK_009":0,
    "DOC_CHECK_023":0,
    "DOC_CHECK_024":0,
    "DOC_CHECK_025":0,
    "DOC_CHECK_026":0,
    "SEG_CHECK_003":0
  }
};
/*Script used to check Document, Procedure, PrefCard and Compare tabs*/
var errorIMG = " ";
var warnIMG = " ";
var goodIMG = " ";
var chargeIMG = " ";
var finalizeIMG = " ";
var reportIMG = " ";
var scheduleIMG = " ";
window.onerror = function(message, url, lineNumber) {
  log.error(url +" "+ lineNumber +" "+ message);
  //save error and send to server for example.
  return true;
};
//init function onload
window.onload = function () {
  try {
    mpObj.mill = parseInt(_g('millennium').firstChild.data);
    var orgParams = "";
    $("#showFailureOnly").hide();
    i18n_strings();
    enableButtonsTabs(1);
    if (mpObj.mill === 1) {
      if(mpObj.debug === 1) {
        log.info("Millennium mode enabled");
      }
      mpObj.ipath = _g('file_path').firstChild.data;
      mpObj.userId = _g("user_id").firstChild.data;
      mpObj.userName = _g("userName").firstChild.data;
      $(".dropzone").hide();
      processForm();
    } else {
      if(mpObj.debug === 1) {
        log.info("Local mode enabled");
      }
      mpObj.ipath = "../mp_appsrv_periop";
      $(".dropzone").show();
      mpObj.DROPDOWNS.BLOB = {"INSTITUTIONS": [{"INSTITUTION_NAME": "Local Only", "INSTITUTION_CD": 1, "AREAS_EXIST": 1, "DEPARTMENTS": [{"DEPARTMENT_CD": 1, "AREAS": [{"AREA_CD": 1, "AREA_DISPLAY": "Local Only"}]}]}]};
      updateDropDowns(0,0);
      var dropZone = _g('drop_zone');
      dropZone.addEventListener('dragover', handleDragOver, false);
      dropZone.addEventListener('drop', handleFileSelect, false);
    }
    errorIMG = "<IMG src=\"" + mpObj.ipath + "/images/5278_16.gif\" class='status-img' title='Not Recommended' />";
    warnIMG = "<IMG src=\"" + mpObj.ipath + "/images/4017_24.png\" class='status-img' title='Not Recommended,supported' />";
    goodIMG = "<IMG src=\"" + mpObj.ipath + "/images/4022_16.png\" class='status-img' title='Recommended' />";
    chargeIMG = "<IMG src=\"" + mpObj.ipath + "/images/5458.ico\" class='status-img' title='Charges impacted' />";
    finalizeIMG = "<IMG src=\"" + mpObj.ipath + "/images/finalize.JPG\" class='status-img' title='Finalizing impacted' />";
    reportIMG = "<IMG src=\"" + mpObj.ipath + "/images/6937_48.png\" class='status-img' title='Reporting impacted' />";
    scheduleIMG = "<IMG src=\"" + mpObj.ipath + "/images/4257.ico\" class='status-img' title='Scheduling impacted' />";
    OpsGrpIMG = "<IMG src=\"" + mpObj.ipath + "/images/ops_grp.JPG\" class='status-img' title='Operations Control Group' />";
    OpsIMG = "<IMG src=\"" + mpObj.ipath + "/images/ops_job.JPG\" class='status-img' title='Operations Job' />";
    StepIMG = "<IMG src=\"" + mpObj.ipath + "/images/ops_step.JPG\" class='status-img' title='Operations Job Step' />";
    BatchIMG = "<IMG src=\"" + mpObj.ipath + "/images/ops_batch.JPG\" class='status-img' title='Operations Job Step Batch Selection' />";
  } catch(err) {
    log.error(err);
  }
};  //end init section
function handleFileSelect(evt) {
  if(mpObj.debug === 1) {
    log.debug("Local mode file drop detected");
  }
  evt.stopPropagation();
  evt.preventDefault();
  var files = evt.dataTransfer.files; // FileList object.
  var reader = new FileReader();
  reader.onload = function (e) {
    var contents = reader.result;
    if (contents.length > 0) {
      var thing = jQuery.parseJSON(contents);
      mpObj.mill = 0;
      var inst = thing.inst_disp;
      var area = thing.area_disp;
      mpObj.DROPDOWNS.BLOB = {"INSTITUTIONS": [{"INSTITUTION_NAME": inst, "INSTITUTION_CD": 1, "AREAS_EXIST": 1, "DEPARTMENTS": [{"DEPARTMENT_CD": 1, "AREAS": [{"AREA_CD": 1, "AREA_DISPLAY": area,"DOCS":[{"DISPLAY":thing.doc_disp,"DOC_REF_ID":1}]}]}]}]};
      mpObj.DOCUMENT.BLOB = thing.doc_blob.RECORD_DATA;
      mpObj.PROCEDURE.BLOB = thing.procedure_blob.RECORD_DATA;
      mpObj.PREFCARD.BLOB = thing.prefcard_blob.RECORD_DATA;
      mpObj.OPSJOB.BLOB = thing.ops_data.RECORD_DATA;
      mpObj.RPTBUILDER.BLOB = thing.rpt_blob;
      mpObj.ANESTHESIA.BLOB = thing.sa_blob.RECORD_DATA;
      mpObj.COMPARE.DOCI18N_BLOB = thing.i18nvalues.RECORD_DATA.CODE_VALUES;
      mpObj.COMPARE_AREA.COMPARE_AREA1.AreaDisp = area;
      mpObj.COMPARE_AREA.COMPARE_AREA2.AreaDisp = area;
      mpObj.COMPARE_DOC.COMPARE_DOC1.DocDisp = thing.doc_disp;
      mpObj.COMPARE_DOC.COMPARE_DOC1.DocCDF = thing.doc_cdf;
      mpObj.COMPARE_DOC.COMPARE_DOC2.DocDisp = thing.doc_disp2;
      mpObj.COMPARE_DOC.COMPARE_DOC2.DocCDF = thing.doc_cdf2;
      $.extend(mpObj.COMPARE_AREA.COMPARE_AREA1,thing.COMPARE_AREA1.RECORD_DATA);
      $.extend(mpObj.COMPARE_AREA.COMPARE_AREA2,thing.COMPARE_AREA1.RECORD_DATA);
      $.extend(mpObj.COMPARE_DOC.COMPARE_DOC1,thing.COMPARE_DOC1.RECORD_DATA);
      $.extend(mpObj.COMPARE_DOC.COMPARE_DOC2,thing.COMPARE_DOC2.RECORD_DATA);
      updateDropDowns(0,0);
    }
  };
  reader.readAsText(files[0]);
}
function handleDragOver(evt) {
  evt.stopPropagation();
  evt.preventDefault();
  evt.dataTransfer.dropEffect = 'copy'; // Explicitly show this is a copy.
}
/* Load Debug Mode*/
function loadDebugMode() {
  if(mpObj.debug === 1) {
    log.warn("Loading Testing Mode)");
  }
  clearAllTabs();
  $("#showFailureOnly").show();
  enableButtonsTabs(1);
  mpObj.mill = 0;
  if (mpObj.debug_pass === 1) {
    var debug_blob = debug_blob_pass;
  } else {
    var debug_blob = debug_blob_fail;
  }
  mpObj.DROPDOWNS.BLOB = "";
  var inst = debug_blob.inst_disp;
  var area = debug_blob.area_disp;
  mpObj.DROPDOWNS.BLOB = {"INSTITUTIONS": [{"INSTITUTION_NAME": inst, "INSTITUTION_CD": 1, "AREAS_EXIST": 1, "DEPARTMENTS": [{"DEPARTMENT_CD": 1, "AREAS": [{"AREA_CD": 1, "AREA_DISPLAY": area}]}]}]};
  mpObj.DOCUMENT.BLOB = debug_blob.document_blob;
  mpObj.PROCEDURE.BLOB = debug_blob.procedure_blob;
  mpObj.PREFCARD.BLOB = debug_blob.prefcard_blob;
  mpObj.OPSJOB.BLOB = debug_blob.ops_blob;
  mpObj.RPTBUILDER.BLOB = debug_blob.rpt_blob;
  mpObj.ANESTHESIA.BLOB = debug_blob.sa_blob;
  mpObj.COMPARE_AREA1 = debug_blob.compare_blob1;
  mpObj.COMPARE_AREA2 = debug_blob.compare_blob1;
  $(".dropzone").hide();
  $("#hide-build-checkbox-doc").attr('checked', false);
  $("#hide-build-checkbox-proc").attr('checked', false);
  $("#hide-build-checkbox-pref").attr('checked', false);
  $("#hide-build-checkbox-loc").attr('checked', false);
  $("#hide-build-checkbox-sa").attr('checked', false);
  $("#hide-build-checkbox-ops").attr('checked', false);
  toggleErrorsOnly();
  updateDropDowns(0,0);
};
/*enable blackbird additional logging
by default only error-level items will show in blackbird
this will allow 'info' and 'default' levels to show*/
function enableBlackbirdDebug(){
  mpObj.debug = 1;
  log.warn("Blackbird Logging Enabled");
}
/*Change debug from fail to pass*/
function toggleDebug() {
  if (mpObj.debug_pass === 1) {
    mpObj.debug_pass = 0;
    log.warn("Debug Error enabled");
  } else {
    mpObj.debug_pass = 1;
    log.warn("Debug Pass enabled");
  }
  clearAllTabs();
  loadDebugMode();
};
/**
* jQuery functions
*/
$(document).ready(function () {
  $(document).keyup(function (e) {
    if (e.keyCode === 221 && e.ctrlKey && e.shiftKey) {
      log.warn("Debug Mode triggered");
      loadDebugMode();
    }
    if (e.keyCode === 220 && e.ctrlKey) {
      enableBlackbirdDebug();
    }
  });
  // Slide Effects
  $("body").on("click", "#area-header", function () {
    $(this).next(".area-container").slideToggle("fast");
  });
  $("body").on("click", "#stage-header", function () {
    $(this).next(".stage-container").slideToggle("fast");
  });
  $("body").on("click", "#doc-header", function () {
    $(this).next(".doc-container").slideToggle("fast");
  });
  $("body").on("click", "#seggrp-header", function () {
    $(this).next(".seg-form-block").slideToggle("fast");
  });
  $("body").on("click", "#segment-header", function () {
    $(this).next(".segment-container").slideToggle("fast");
  });
  $("body").on("click", "#form-header", function () {
    $(this).next(".form-container").slideToggle("fast");
  });
  $("body").on("click", "#field-header", function () {
    $(this).next(".field-container").slideToggle("fast");
  });
  $("body").on("click", ".compare-section-header", function () {
    $(this).nextUntil(".compare-section-header").slideToggle("fast");
  });
  // Tab switching
  $("body").on("click", "#tab-document", function () {
    if (mpObj.disable_tabs === 0) {
      mpObj.TAB=mpObj.DOCUMENT.TAB;
      inactivateTabs($(this));
      hide_all_tabs();
      if(mpObj.DOCUMENT.LOADED === 0){
        enableButtonsTabs(1);
        updateDropDowns(0,0);
        mpObj.DOCUMENT.LOADED = 1;
      }
      $("#wrapper-document").show();
    }
  });
  $("body").on("click", "#tab-procedure", function () {
    if (mpObj.disable_tabs === 0) {
      inactivateTabs($(this));
      mpObj.TAB=mpObj.PROCEDURE.TAB;
      hide_all_tabs();
      if(mpObj.PROCEDURE.LOADED === 0){
        enableButtonsTabs(1);
        updateDropDowns(0,0);
        mpObj.PROCEDURE.LOADED = 1;
      }
      $("#wrapper-procedure").show();
    }
  });
  $("body").on("click", "#tab-prefcard", function () {
    if (mpObj.disable_tabs === 0) {
      inactivateTabs($(this));
      mpObj.TAB=mpObj.PREFCARD.TAB;
      hide_all_tabs();
      if(mpObj.PREFCARD.LOADED === 0){
        enableButtonsTabs(1);
        updateDropDowns(0,0);
        mpObj.PREFCARD.LOADED = 1;
      }
      $("#wrapper-prefcard").show();
    }
  });
  $("body").on("click", "#tab-loc", function () {
    if (mpObj.disable_tabs === 0) {
      inactivateTabs($(this));
      mpObj.TAB=mpObj.LOCATION.TAB;
      hide_all_tabs();
      if(mpObj.LOCATION.LOADED === 0){
        enableButtonsTabs(1);
        updateDropDowns(0,0);
        mpObj.LOCATION.LOADED = 1;
      }
      $("#wrapper-loc").show();
    }
  });
  $("body").on("click", "#tab-ops", function () {
    if (mpObj.disable_tabs === 0) {
      mpObj.TAB=mpObj.OPSJOB.TAB;
      inactivateTabs($(this));
      hide_all_tabs();
      if(mpObj.OPSJOB.LOADED === 0){
        enableButtonsTabs(1);
        updateDropDowns(0,0);
        mpObj.OPSJOB.LOADED = 1;
      }
      $("#wrapper-ops").show();
    }
  });
  $("body").on("click", "#tab-rpt", function () {
    if (mpObj.disable_tabs === 0) {
      mpObj.TAB=mpObj.RPTBUILDER.TAB;
      inactivateTabs($(this));
      hide_all_tabs();
      if(mpObj.RPTBUILDER.LOADED === 0){
        enableButtonsTabs(1);
        updateDropDowns(0,0);
        mpObj.RPTBUILDER.LOADED = 1;
      }
      $("#wrapper-rpt").show();
    }
  });
  $("body").on("click", "#tab-sa", function () {
    if (mpObj.disable_tabs === 0) {
      mpObj.TAB=mpObj.ANESTHESIA.TAB;
      inactivateTabs($(this));
      hide_all_tabs();
      if(mpObj.ANESTHESIA.LOADED === 0){
        enableButtonsTabs(1);
        updateDropDowns(0,0);
        mpObj.ANESTHESIA.LOADED = 1;
      }
      $("#wrapper-sa").show();
    }
  });
  $("body").on("click", "#tab-compare", function () {
    if (mpObj.disable_tabs === 0) {
      inactivateTabs($(this));
      hide_all_tabs();
      if(mpObj.COMPARE.LOADED === 0) {
        mpObj.COMPARE.LASTTAB = mpObj.COMPARE_AREA.TAB; /*set the last tab to area the first time through, it'll get updated from the compare tab as they toggle*/
        mpObj.TAB=mpObj.COMPARE.LASTTAB;
        enableButtonsTabs(1);
        updateDropDowns(0,0);
        mpObj.COMPARE.LOADED = 1;
      }
      mpObj.TAB=mpObj.COMPARE.LASTTAB;
      $("#wrapper-compare").show();
    }
  });
});

/*Add new tabs here, this will hide all when users click between them*/
function hide_all_tabs(){
  $("#wrapper-document").hide();
  $("#wrapper-procedure").hide();
  $("#wrapper-prefcard").hide();
  $("#wrapper-loc").hide();
  $("#wrapper-rpt").hide();
  $("#wrapper-ops").hide();
  $("#wrapper-sa").hide();
  $("#wrapper-compare").hide();
};
/*This function clears the contents of the Document, Procedure and Pref Card tabs*/
function clearAllTabs() {
  var pptSecd = _g("report");
  pptSecd.innerHTML = "";
  var pptSecp = _g("report_procedure");
  pptSecp.innerHTML = "";
  var pptSecc = _g("report_prefcard");
  pptSecc.innerHTML = "";
  var pptSeco = _g("report_ops");
  pptSeco.innerHTML = "";
  var pptSecr = _g("report_rpt");
  pptSecr.innerHTML = "";
  var pptSeca = _g("report_sa");
  pptSeca.innerHTML = "";
};
/**
* Opens a guide for how to fix an error.
* The html files need to be named identically to the ID on the element clicked on.
* We use the error check name from the CCL script, e.g. AREA_CHECK_001
*/
function openDialog() {
  var horizontal_space = $(window).width();
  var vertical_space = $(window).height();
  var error_id = $(this).attr('id');
  if (error_id != null) {
    // Only launch dialog if an error id exists
    var guide_path = mpObj.ipath + "/guides/document_check/" + error_id + ".html";

    $("#error-guide-dialog").load(guide_path);
    $("#error-guide-dialog").dialog(
      {
        create: function (event, ui) {
          $(event.target).parent().css('position', 'fixed');
        },
        resizeStop: function (event, ui) {
          var position = [(Math.floor(ui.position.left) - $(window).scrollLeft()),
            (Math.floor(ui.position.top) - $(window).scrollTop())];
            $(event.target).parent().css('position', 'fixed');
            $(dlg).dialog('option', 'position', position);
          },
          resizable: false,
          modal: true,
          title: error_id,
          height: vertical_space,
          width: horizontal_space,
          sticky: true,
          buttons:
          {
            "Close": function () {
              $(this).dialog('close');
            }
          }
        }
      );
    }
  }
  /**
  * Overloaded method - Opens a guide for how to fix an error.
  * pass in the HTML to be displayed in the dialog
  */
  function openDialogHTML(html) {
    var horizontal_space = $(window).width();
    var vertical_space = $(window).height();
    var error_id = $(this).attr('id');

    $("#error-guide-dialog").html(html);
    $("#error-guide-dialog").dialog({
      create: function (event, ui) {
        $(event.target).parent().css('position', 'fixed');
      },
      resizeStop: function (event, ui) {
        var position = [(Math.floor(ui.position.left) - $(window).scrollLeft()),
          (Math.floor(ui.position.top) - $(window).scrollTop())];
          $(event.target).parent().css('position', 'fixed');
          $(dlg).dialog('option', 'position', position);
        },
        resizable: false,
        modal: true,
        title: error_id,
        height: vertical_space,
        width: horizontal_space,
        sticky: true,
        buttons: {
          "Close": function () {
            $(this).dialog('close');
          }
        }
      });
    }
    /**
    * removes the active class from all tabs. Used when any tab is
    * clicked
    */
    function inactivateTabs($node) {
      $("#tabs").find(".tab").each(function () {
        $(this).removeClass("tab-active");
        $(this).addClass("tab-inactive");
      });
      $node.parent(".tab").addClass("tab-active");
      $node.parent(".tab").removeClass("tab-inactive");
    }
    function build_more_info(check, num) {
      var myObj = ppt_strings.DIALOG_ERROR[check];
      var dialog_text = "<div class='dialog-guide-wrapper'><div class='dialog-guide-title'><h3>" + myObj.TITLE + "</h3><p>" + myObj.BODY + "</p></div><div class='dialog-guide-applications'><h3>" + ppt_strings.APPLICATIONS_USED + "</h3><ul>" + myObj.TOOLS + "</ul></div><div class='dialog-guide-links'><h3>" + ppt_strings.LEARN_MORE + "</h3><p><a href='" + myObj.UCERN + "' target='_blank'>" + myObj.UCERN_TEXT + "</a></p></div><div class='dialog-guide-extra'>" + myObj.EXTRA[num] + "</div>";
      openDialogHTML(dialog_text);
    }
    ;
    function toggleLegend() {
      if($("#legend-icon-list").is(':hidden')) {
        $("#legend-icon-list").show();
        $("#legend-toggle").html("[ &#45; ]");
      } else {
        $("#legend-icon-list").hide();
        $("#legend-toggle").html("[ &#43; ]");
      }
    }
    ;
    /*This function will swap out the default strings in the mp_appsrv_periop.html file to be i18n*/
    function i18n_strings(){
      $("a#help_page_a").attr("href",URLS.REF_CONF_HELPPAGE);
      $("#help-text").attr("href",ppt_strings.HELP);
      $("#toggleCompare-area").attr('value',ppt_strings.VIEW_AREA);
      $("#toggleCompare-document").attr('value',ppt_strings.VIEW_DOCUMENTS);
      $("a#ref_sys_ucern").attr("href",URLS.REF_CONF_SYSTEM);
    }
    function getLoadingInfoString(string,param1,param2,param3) {
      var new_string = string;
      new_string = new_string.replace("param1",param1);
      new_string = new_string.replace("param2",param2);
      new_string = new_string.replace("param3",param3);
      return new_string;
    };
    /**
    * Hides the good build descriptors.
    * activated when clicking check box
    * each tab has it's own checkbox
    */
    function toggleErrorsOnly() {
      if($("#hide-build-checkbox-doc").prop("checked")) {
        $("#wrapper-document .goodBuild").hide();
      } else {
        $("#wrapper-document .goodBuild").show();
      }
      if($("#hide-build-checkbox-proc").prop("checked")) {
        $("#wrapper-procedure .goodBuild").hide();
      } else {
        $("#wrapper-procedure .goodBuild").show();
      }
      if($("#hide-build-checkbox-pref").prop("checked")) {
        $("#wrapper-prefcard .goodBuild").hide();
      } else {
        $("#wrapper-prefcard .goodBuild").show();
      }
      if($("#hide-build-checkbox-loc").prop("checked")) {
        $("#wrapper-loc .goodBuild").hide();
      } else {
        $("#wrapper-loc .goodBuild").show();
      }
      if($("#hide-build-checkbox-ops").prop("checked")) {
        $("#wrapper-ops .goodBuild").hide();
      } else {
        $("#wrapper-ops .goodBuild").show();
      }
      if($("#hide-build-checkbox-sa").prop("checked")) {
        $("#wrapper-sa .goodBuild").hide();
      } else {
        $("#wrapper-sa .goodBuild").show();
      }
    };
    /*enableButtonsTabs
    toggle = 0 means enable

    this will disable users from clicking anything while stuff is loading

    this should be called after loading regardless of failure
    */
    function enableButtonsTabs(toggle) {
      try{
        if(toggle === 0){
          var myToggle = false;
          mpObj.disable_tabs = 0;
        } else {
          var myToggle = true;
          mpObj.disable_tabs = 1;
        }
        /*buttons*/
        $("#loadReport").prop("disabled", myToggle); /*document*/
        $("#loadProcedure").prop("disabled", myToggle); /*proc */
        $("#loadPrefCardReport").prop("disabled", myToggle); /*prefcard */
        $("#loadLocReport").prop("disabled", myToggle); /*location */
        $("#loadOpsReport").prop("disabled", myToggle); /*ops jobs */
        $("#loadRptReport").prop("disabled", myToggle); /*rpt blder*/
        $("#loadSaReport").prop("disabled", myToggle); /*Anesthesia */
        $("#toggleCompare").prop("disabled", myToggle); /*Toggle Doc / Area button */
        $("#loadCompareReport1").prop("disabled", myToggle); /*compare area 1*/
        $("#loadCompareReport2").prop("disabled", myToggle); /*compare area 2*/
        $("#loadCompareDReport1").prop("disabled", myToggle); /*compare doc 1*/
        $("#loadCompareDReport2").prop("disabled", myToggle); /*compare doc 2*/
        /*dropdowns*/
        $("#specFilter").prop("disabled", myToggle); /*org doc tab*/
        $("#areaFilter").prop("disabled", myToggle); /*area doc tab*/
        $("#orgProcFilter").prop("disabled", myToggle); /*org proc tab*/
        $("#areaProcFilter").prop("disabled", myToggle); /*area proc tab*/
        $("#orgPrefCardFilter").prop("disabled", myToggle); /*org prefcard tab*/
        $("#areaPrefCardFilter").prop("disabled", myToggle); /*area prefcard tab*/
        $("#opsFilter").prop("disabled", myToggle); /*ops filter*/
        $("#orgSaFilter").prop("disabled", myToggle); /*org sa tab*/
        $("#areaSaFilter").prop("disabled", myToggle); /*area sa tab*/
        $("#orgCompFilter").prop("disabled", myToggle); /*org compare tab*/
        $("#areaCompFilter").prop("disabled", myToggle); /*area compare tab*/
        $("#docCompFilter").prop("disabled", myToggle); /*doc compare tab*/
        /*checkboxes*/
        $("#hide-build-checkbox-doc").prop("disabled", myToggle); /*hide good build - doc tab*/
        $("#hide-build-checkbox-proc").prop("disabled", myToggle); /*hide good build - proc tab*/
        $("#hide-build-checkbox-pref").prop("disabled", myToggle); /*hide good build - pref tab*/
        $("#hide-build-checkbox-loc").prop("disabled", myToggle); /*hide good build - loc tab*/
        $("#hide-build-checkbox-sa").prop("disabled", myToggle); /*hide good build - sa tab*/
        $("#hide-build-checkbox-ops").prop("disabled", myToggle); /*hide good build - ops tab*/
        $("#pass-build-checkbox").prop("disabled", myToggle); /*hide good build - doc tab - for debug mode*/
      } catch(err){
        printStackTrace(err,arguments.callee.caller.toString());
      }
    }
    function defaultFor(arg, val) {
      return typeof arg !== 'undefined' ? arg : val;
    };
    /*getErrorIcons

    check - check that needs to be pulled from the i18n file

    returns a string of the icon images for use in the check

    */
    function getErrorIcons(check){
      try{
        var icons = " ";
        var dialog = ppt_strings.DIALOG_ERROR[check].IMGS;
        if(dialog.ERROR === 1) {
          icons += errorIMG;
        }
        if(dialog.WARN === 1) {
          icons += warnIMG;
        }
        if(dialog.CHARGE === 1) {
          icons += chargeIMG;
        }
        if(dialog.FINALIZE === 1) {
          icons += finalizeIMG;
        }
        if(dialog.SCHEDULE === 1) {
          icons += scheduleIMG;
        }
        if(dialog.REPORT === 1) {
          icons += reportIMG;
        }
        return icons;
      } catch(err) {
        printStackTrace(err,arguments.callee.caller.toString());
      }
    }
    /*getStringForCheck
    obj is the obj that contains our check

    check is the check number we're on

    icons is a string of icons that affect this check

    param1 will be a unique piece of information you want displayed in the GOOD check such as 'you have a valid event code: param1'

    param2 is the same, but gives 1 additional option if needed

    if the check contains extra items, those are looped, it could contain 2 items, that is also checked
    ITEM1, ITEM2,etc must be defined in the i18n file for it read the items in the CCL script
    */
    function getStringForCheck(obj,check,param1,param2) {
      try{
        var numCheck = 0;
        if(mpObj.NUM.hasOwnProperty(check)) {
          numCheck = mpObj.NUM[check];
          mpObj.NUM[check]++; /*increment for next usage*/
        }
        var string = "";
        var icons = goodIMG;
        var tempString = "";
        var myItem = 'ITEM';
        var noDisp = false;
        var dialog = ppt_strings.DIALOG_ERROR[check];
        var n = check.indexOf("_");
        if(dialog.hasOwnProperty('SHOW_CHECKMARK')) {
          var showChecks = 1;
        }
        var check_sub = check.substr(n+1,check.length);
        if(obj[check] === 1) {
          icons = getErrorIcons(check); /*this builds the list of 'affects' icons based on the i18n file */
          string += "<p class='badBuild build-block'>" + icons + dialog.MAIN_BAD + "<a onclick='build_more_info(\""+check+"\","+numCheck+")' class='more-info'> [ " + ppt_strings.MORE_INFO + " ] </a></p>";
          if(dialog.hasOwnProperty('AFFECTED')) { /*see if this check contains a sub array of all affected items, as defined in the i18n file and CCL script*/
            var itemObj = obj[check_sub];
            var tempString = "<h3>"+dialog.AFFECTED+"</h3>";
            var itemLen = itemObj.length;
            var itemItem;
            for (var f = 0; f < itemLen; f++) {
              itemItem = itemObj[f];
              tempString += "<div class='dialog-guide-affected'><p>"; /*start the list of items since we have 'AFFECTED' defined in our i18n'*/
              var z = true;
              var y = 1;
              while(z === true) {
                myItem = 'ITEM'+y;
                if(y>1){
                  tempString += "<br />";
                }
                if(dialog.hasOwnProperty(myItem)) { /*if there are additional item displays*/
                  tempString += dialog[myItem]; /*if we have a display for the items, put that in each row*/
                  if(showChecks) {
                    if(itemItem[myItem] === 0) {
                      tempString += goodIMG+" ";
                    } else if(itemItem[myItem] === 1) {
                      tempString += errorIMG+" ";
                    } else {
                      tempString += itemItem[myItem]; //if show checks is being used, but the option isn't 0 or 1, just show the item instead
                    }
                  } else {
                    tempString += itemItem[myItem];
                  }
                } else {
                  if(y === 1) { // if a check has at least 1 'ITEM' then we want to skip the items only if we have none
                  noDisp = true;
                }
                z = false;
              }
              y++;
            }
            if(noDisp === true) {
              tempString += itemItem[myItem]; /*print each item coming back in the script*/
            }
            tempString += "</p></div>";
          }
          ppt_strings.DIALOG_ERROR[check].EXTRA[numCheck] = tempString;
          tempString = "";
        }
      } else {
        /*not all checks have a 'good' display because other checks complete it for them (they multi-checks)*/
        if(dialog.hasOwnProperty("MAIN_GOOD")) {
          string += "<p class='goodBuild build-block'>" + icons + dialog.MAIN_GOOD+"</p>";
        }
      }
      //replace any extra params passed in
      string = getLoadingInfoString(string,param1,param2);
      return string;
    } catch(err) {
      printStackTrace(err,arguments.callee.caller.toString());
    }
  }
  /*get stack of where error occured, echo to blackbird*/
  function printStackTrace(e,myname) {
    try{
      myname = myname.substr('function '.length);
      myname = myname.substr(0, myname.indexOf('('));
      log.error("function: "+ myname);
      log.error(e);
    } catch(err){
      log.error("function: printStackTrace");
      log.error(err);
    }
  }
