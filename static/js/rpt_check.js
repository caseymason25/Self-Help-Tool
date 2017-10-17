function loadRptTab() {
    var procHTML = "";
    var procSec = _g("report_rpt");
    procSec.innerHTML = "";
    var rptObj = mpObj.RPTBUILDER.BLOB;

    //procHTML = 

    procSec.innerHTML = procHTML;
    enableButtonsTabs(0);
    updateLoadingDiv(1);
};
