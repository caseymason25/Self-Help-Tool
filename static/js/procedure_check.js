function loadProcedureTab() {
  try{
    var procHTML = "";
    var procSec = _g("report_procedure");
    procSec.innerHTML = "";
    var procObj = mpObj.PROCEDURE.BLOB;
    procHTML += "<div class='check-container'>";
    procHTML += getStringForCheck(procObj,"PROCEDURE_CHECK_001");
    procHTML += getStringForCheck(procObj,"PROCEDURE_CHECK_002");
    procHTML += getStringForCheck(procObj,"PROCEDURE_CHECK_003");
    procHTML += getStringForCheck(procObj,"PROCEDURE_CHECK_004");
    procHTML += getStringForCheck(procObj,"PROCEDURE_CHECK_005");
    procHTML += getStringForCheck(procObj,"PROCEDURE_CHECK_006");
    procHTML += getStringForCheck(procObj,"PROCEDURE_CHECK_007");
    procHTML += getStringForCheck(procObj,"PROCEDURE_CHECK_008");
    procHTML += getStringForCheck(procObj,"PROCEDURE_CHECK_009");
    procHTML += getStringForCheck(procObj,"PROCEDURE_CHECK_010");
    procHTML += getStringForCheck(procObj,"PROCEDURE_CHECK_011");
    procHTML += getStringForCheck(procObj,"PROCEDURE_CHECK_012");
    procHTML += "</div>";
    procSec.innerHTML = procHTML;
    enableButtonsTabs(0);
    updateLoadingDiv(1);
    toggleErrorsOnly();
  } catch(err){
    printStackTrace(err,arguments.callee.caller.toString());
  }
};
