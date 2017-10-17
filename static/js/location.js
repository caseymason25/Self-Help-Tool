function loadLocTab() {
  try{
    var locHTML = "";
    var locSec = _g("report_loc");
    locSec.innerHTML = "";
    var locObj = mpObj.LOCATION.BLOB;
    locHTML += "<div class='check-container'>";
    locHTML += getStringForCheck(locObj,"LOC_CHECK_001");
    locHTML += getStringForCheck(locObj,"LOC_CHECK_002");
    locHTML += getStringForCheck(locObj,"LOC_CHECK_003");
    locHTML += getStringForCheck(locObj,"LOC_CHECK_004");
    locHTML += "</div>";
    locSec.innerHTML = locHTML;
    enableButtonsTabs(0);
    updateLoadingDiv(1);
    toggleErrorsOnly();
  } catch(err){
    printStackTrace(err,arguments.callee.caller.toString());
  }
};
