function loadPrefCardTab() {
  try{
    var prefHTML = "";
    var prefSec = _g("report_prefcard");
    prefSec.innerHTML = " ";
    prefHTML += "<div class='check-container'>";
    var prefCardObj = mpObj.PREFCARD.BLOB;
    prefHTML += "<h3>"+ppt_strings.PREFCARD_INVVIEW+prefCardObj.INVENTORY_VIEW+"<h3>";
    prefHTML += getStringForCheck(prefCardObj,"PREFCARD_CHECK_001");
    prefHTML += getStringForCheck(prefCardObj,"PREFCARD_CHECK_002");
    prefHTML += getStringForCheck(prefCardObj,"PREFCARD_CHECK_003");
    prefHTML += getStringForCheck(prefCardObj,"PREFCARD_CHECK_004");
    prefHTML += getStringForCheck(prefCardObj,"PREFCARD_CHECK_005");
    prefHTML += getStringForCheck(prefCardObj,"PREFCARD_CHECK_006");
    prefHTML += getStringForCheck(prefCardObj,"PREFCARD_CHECK_007");
    prefHTML += getStringForCheck(prefCardObj,"PREFCARD_CHECK_008");
    prefHTML += "</div>";
    prefSec.innerHTML = prefHTML;
    enableButtonsTabs(0);
    updateLoadingDiv(1);
    toggleErrorsOnly();
  } catch(err){
    printStackTrace(err,arguments.callee.caller.toString());
  }
}
