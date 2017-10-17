function filter_ops_load(){
  mpObj.OPSJOB.OPS_FILTER = $("#opsFilter option:selected").val();
  loadOpsTab();
}
function loadOpsTab() {
  try{
    var procHTML = "";
    var filter_options = ["All"];
    var filter_found = 0;
    var procSec = _g("report_ops");
    procSec.innerHTML = "";
    var grpObj = mpObj.OPSJOB.BLOB.OPS_GROUP;
    var grpLen = grpObj.length;
    for (var h = 0; h < grpLen; h++) {
      var grpItem = grpObj[h];
      procHTML += "<div class='grp-block'><h1 id='grp-header'>"+ OpsGrpIMG +" "+grpItem.OPS_JOB_GROUP+" - " + "Node: "+grpItem.NODE+"</h1>";
      procHTML += "<div class='grp-container'>";
      var opsObj = grpItem.OPS_JOBS;
      var opsLen = opsObj.length;
      for (var i = 0; i < opsLen; i++) {
        var opsItem = opsObj[i];
        procHTML += "<div class='job-block'><h1 id='job-header'>"+ OpsIMG + "  "+opsItem.OPS_START_TIME+"  "+opsItem.OPS_JOB_DESC+"</h1>";
        procHTML += "<div class='job-container'>";
        var stepObj = opsItem.STEPS;
        var stepsLen = stepObj.length;
        var stepTblLen = stepsLen-1;
        for (var j = 0; j < stepsLen; j++) {
          var stepsItem = stepObj[j];
          /*build array of jobs for drop-down*/
          for(var k = 0;k < filter_options.length;k++) {
            if(filter_options[k] === stepsItem.STEP_NAME) {
              filter_found = 1;
              break;
            }
          }
          if(filter_found === 0) {
            filter_options.push(stepsItem.STEP_NAME);
            filter_options.sort();
          }
          filter_found = 0;
          if(mpObj.OPSJOB.OPS_FILTER === "All") {
            procHTML += build_ops_html(stepsItem);
            opsFilter(filter_options);
          } else if(mpObj.OPSJOB.OPS_FILTER === stepsItem.STEP_NAME){
            procHTML += build_ops_html(stepsItem);
          }
        }
        procHTML += "</div></div>"; /*End job-container and job-block divs*/
      }
      procHTML += "</div></div>"; /*End grp-container and grp-block divs*/
    }
    procSec.innerHTML = procHTML;
    enableButtonsTabs(0);
    updateLoadingDiv(1);
    toggleErrorsOnly();
  } catch(err){
    printStackTrace(err,arguments.callee.caller.toString());
  }
};
function build_ops_html(stepsItem) {
  try{
    var string="";
    string += "<div class='step-block'><h2 id='step-header'>"+ StepIMG + " Step#: "+stepsItem.STEP_NUMBER+" - Step: "+stepsItem.STEP_NAME+"</h2>";
    string += "<p>"+ BatchIMG + "Step Batch: "+stepsItem.STEP_BATCH+"</p>";
    /*only certain checks apply to certain jobs, limit the checks by the jobs that apply, otherwise this looks weird (CCL is doing this already, so mimic in the JS)*/
    //if(stepsItem.STEP_NAME === "sn_run_pl_ops_qtys" || stepsItem.STEP_NAME === "sn_run_pl_ops_gen" ||) {
    string += getStringForCheck(stepsItem,"OPS_CHECK_001");
    string += getStringForCheck(stepsItem,"OPS_CHECK_002");
    string += getStringForCheck(stepsItem,"OPS_CHECK_003");
    //}
    string += "</div>"; /*end step block*/
    return string;
  } catch(err){
    printStackTrace(err,arguments.callee.caller.toString());
  }
}
function opsFilter(filter_options) {
  try{
    var opsFilter = _g("opsFilter");
    if (filter_options.length > 0) {
      for (var m = 0; m < filter_options.length; m++) {
        var filterItem = filter_options[m];
        opsFilter.options[m] = new Option(filterItem,filterItem);
      }
    }
    Util.addEvent(opsFilter, "change", filter_ops_load);
  } catch(err){
    printStackTrace(err,arguments.callee.caller.toString());
  }
};
