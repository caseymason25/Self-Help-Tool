function loadSaTab() {
  try{
    var saHTML = "";
    var saSec = _g("report_sa");
    saSec.innerHTML = "";
    var saObj = mpObj.ANESTHESIA.BLOB;
    saHTML += "<div class='check-container'>";
    saHTML += getStringForCheck(saObj,"SA_CHECK_001");
    saHTML += getStringForCheck(saObj,"SA_CHECK_002");
    saHTML += "</div>";
    saSec.innerHTML = saHTML;
    enableButtonsTabs(0);
    updateLoadingDiv(1);
    toggleErrorsOnly();
  } catch(err){
    printStackTrace(err,arguments.callee.caller.toString());
  }
};
