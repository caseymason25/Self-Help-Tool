function loadCompareTab(){
	try{
		if(mpObj.COMPARE.DOCI18NVALID === 0) {
			update_i18n_code_values();
		}
		var prefHTML = "";
		var sect_colspan=4;
		if(mpObj.TAB === mpObj.COMPARE_DOC.TAB) {
			var pptSec = _g("report_doc_compare");
			var doc1CDF = mpObj.COMPARE_DOC.COMPARE_DOC1.DocCDF;
			var doc2CDF = mpObj.COMPARE_DOC.COMPARE_DOC2.DocCDF;
			prefHTML = "<table class='compare-table'><tr class='areaCompName'><th class='compare-preference-name'>Preference Name</th><th>"+mpObj.COMPARE_DOC.COMPARE_DOC1.DocDisp+" <span title='CDF Meaning'>"+doc1CDF+"</span></th>";
			prefHTML += "<th>"+mpObj.COMPARE_DOC.COMPARE_DOC2.DocDisp+" <span title='CDF Meaning'>"+doc2CDF+"</span></th><th>Recommended Preop</th><th>Recommended ORNURSE</th><th>Recommended Postop</th></tr>";
			if(mpObj.COMPARE_DOC.COMPARE_DOC1.DocDisp.length > 1) {
				var prefObj1 = mpObj.COMPARE_DOC.COMPARE_DOC1.DOC_PREFS[0].PREFS;
				var doc1_freetext = mpObj.COMPARE_DOC.COMPARE_DOC1.DOC_PREFS[0].FREE_TEXT_ITEM_DISP;
			} else {
				if(mpObj.debug === 1) {
					log.debug("Compare Doc Column 1 empty");
				}
			}
			if(mpObj.COMPARE_DOC.COMPARE_DOC2.DocDisp.length > 1) {
				var prefObj2 = mpObj.COMPARE_DOC.COMPARE_DOC2.DOC_PREFS[0].PREFS;
				var doc2_freetext = mpObj.COMPARE_DOC.COMPARE_DOC2.DOC_PREFS[0].FREE_TEXT_ITEM_DISP;
			} else{
				if(mpObj.debug === 1) {
					log.debug("Compare Doc Column 2 empty");
				}
			}
			var prefObj = PREFERENCES.SURGERY.DOCUMENT;
			sect_colspan=6;
		} else {
			var pptSec = _g("report_area_compare");
			prefHTML = "<table class='compare-table'><tr class='areaCompName'><th class='compare-preference-name'>Preference Name</th><th>"+mpObj.COMPARE_AREA.COMPARE_AREA1.AreaDisp+"</th>";
			prefHTML += "<th>"+mpObj.COMPARE_AREA.COMPARE_AREA2.AreaDisp+"</th><th>Model Recommendation <br/> <a id='ref_sys_ucern' href='"+URLS.REF_CONF_SYSTEM+"' target='_blank'>More Info</a></th></tr>";
			var prefObj1 = mpObj.COMPARE_AREA.COMPARE_AREA1.AREA_PREFS;
			var prefObj2 = mpObj.COMPARE_AREA.COMPARE_AREA2.AREA_PREFS;
			var prefObj = PREFERENCES.SURGERY.AREA;
			sect_colspan=6;
		}
		var skip1 = 1
		var skip2 = 1;
		if(typeof prefObj1 !== 'undefined' && prefObj1 !== null) {
			var prefLen1 = prefObj1.length;
			skip1 = 0;
		}
		if(typeof prefObj2 !== 'undefined' && prefObj2 !== null) {
			skip2 = 0;
			var prefLen2 = prefObj2.length;
		}
		var match1 = 0;
		var match2 = 0;
		var lastSection = "";
		var prefLen = prefObj.length;
		for(var x=0;x < prefLen; x++) {
			var prefItem = prefObj[x];
			if(prefItem.SECTION !== lastSection){
				prefHTML += "<tr class='compare-section-header'><td colspan='"+sect_colspan+"' class='comparePrefHeader'>"+prefItem.SECTION+"</td></tr>";
				lastSection = prefItem.SECTION;
			}
			prefHTML += "<tr><td class='compare-preference-name compare-pref-field'>"+prefItem.DISPLAY+"</td>";
			/*if obj is null, skip and put empty <td> tags*/
			if(skip1 === 0){
				match1 = 0;
				for (var j = 0; j < prefLen1; j++) {
					var prefItem1 = prefObj1[j];
					if(prefItem1.PREF_NAME === prefItem.PREF_KEY){
						if(prefItem.PREF_KEY === "CHARGE_FREE_TEXT_ITEM") {
							prefHTML += buildTD(doc1_freetext,prefItem,doc1CDF);
						} else {
							prefHTML += buildTD(prefItem1.PREF_VALUE,prefItem,doc1CDF);
						}
						match1 = 1;
					}
				}
				if(match1 === 0) {
					prefHTML += buildTD(prefItem.DEFAULT,prefItem,doc1CDF);
				}
			} else {
				prefHTML += "<td> </td>";
			}
			/*if obj is null, skip and put empty <td> tags*/
			if(skip2 === 0){
				match2 = 0;
				for (var k = 0; k < prefLen2; k++) {
					var prefItem2 = prefObj2[k];
					if(prefItem2.PREF_NAME === prefItem.PREF_KEY){
						if(prefItem2.PREF_KEY === "CHARGE_FREE_TEXT_ITEM") {
							prefHTML += buildTD(doc2_freetext,prefItem,doc2CDF);
						} else {
							prefHTML += buildTD(prefItem2.PREF_VALUE,prefItem,doc2CDF);
						}
						match2 = 1;
					}
				}
				if(match2 === 0) {
					prefHTML += buildTD(prefItem.DEFAULT,prefItem,doc2CDF);
				}
			} else {
				prefHTML += "<td> </td>";
			}
			/*Populate Model Recommendation column*/
			if(mpObj.TAB === mpObj.COMPARE_DOC.TAB) { /*Doc Prefs*/
				prefHTML += buildTD(prefItem.PREOP,prefItem,"PREOP");
				prefHTML += buildTD(prefItem.ORNURSE,prefItem,"ORNURSE");
				prefHTML += buildTD(prefItem.POSTOP,prefItem,"POSTOP");
			} else { /*Area Prefs*/
				prefHTML += buildTD(prefItem.RECOMMENDATION,prefItem,"1");
			}
		}
		prefHTML += "</table>";
		enableButtonsTabs(0);
    updateLoadingDiv(1);
		pptSec.innerHTML = prefHTML;
	} catch(err){
		printStackTrace(err,arguments.callee.caller.toString());
	}
};
function buildTD(value,prefItem,incdf){
	try{
		var cdf = defaultFor(incdf,"1");
		var opsObj = "";
		var tdString = "";
		if(prefItem.hasOwnProperty('UNIQUE')){
			if(prefItem.PREF_KEY === "CHARGE_FREE_TEXT_ITEM") {
				tdString += "<td class='compare-pref-field'>"+value+"</td>";
			} else {
				tdString += "<td class='compare-pref-field'>"+value+"</td>";
			}
		} else {
			if(prefItem.hasOwnProperty('OPTIONS')){
				opsObj = prefItem.OPTIONS;
				if(comparePref(prefItem,value,cdf) === 0) {
					tdString += "<td style='color:red' class='compare-pref-field'>";
				} else {
					tdString += "<td class='compare-pref-field'>";
				}
				/*Sometimes the default values won't be in the options*/
				tdString += defaultFor(opsObj[value],value)+"</td>";
			} else {
				if(comparePref(prefItem,value,cdf) === 0) {
					tdString += "<td style='color:red' class='compare-pref-field'>"+value+"</td>";
				} else {
					tdString += "<td class='compare-pref-field'>"+value+"</td>";
				}
			}
		}
	} catch(err){
		printStackTrace(err,arguments.callee.caller.toString());
	}
	return tdString;
};
function comparePref(prefObj,value,incdf) {
	try{
		var cdf = defaultFor(incdf,"1");
		/*Area*/
		if(cdf === "1"){
			/*if(prefObj.hasOwnProperty('ALLOW_NULL')) {
				if(typeof value === NULL){
					return 1;
				}
			}*/
			if(prefObj.RECOMMENDATION === value) {
				return 1;
			}
		} else {
			/*Doc*/
			//log.debug("Pref Key:"+prefObj['PREF_KEY']);
			if(prefObj['PREF_KEY'] === "CHARGE_PROCEDURE_FLAG") {
				//log.debug("Found Proc Charge "+prefObj['PREF_KEY']);
				//log.debug("Value:"+value+"|End Value");
				if(value === " ") {
					value = "0";
				}
			}
			if(prefObj[cdf]===value){
				return 1;
			}
		}
	} catch(err){
		printStackTrace(err,arguments.callee.caller.toString());
		return 0;
	}
	return 0;
};
function update_i18n_code_values() {
	try{
		var compObj = mpObj.COMPARE.DOCI18N_BLOB[0];
		prefLen = PREFERENCES.SURGERY.DOCUMENT.length;
		var code = "";
		var disp = "";
		var newObj = {};
		var codeLen = 0;
		var codeItem;
		for(var h=0;h<prefLen;h++) {
			prefItem = PREFERENCES.SURGERY.DOCUMENT[h];
			newObj = {}; /*Reset our obj for the next pref*/
			if(prefItem.PREF_KEY === "COST_TYPE_CD") {
				codeLen = compObj.COST_TYPE.length;
				for(var i=0;i<codeLen;i++) {
					codeItem = compObj.COST_TYPE[i];
					code = codeItem.COST_CD.toString();
					disp = codeItem.COST_DISP;
					/*If we find a cdf meaning that matches our recommendation, swap it out with the code value that we're putting in Options*/
					if(codeItem.COST_MEAN === prefItem.DEFAULT) {
						prefItem.DEFAULT = code;
					}
					if(codeItem.COST_MEAN === prefItem.PREOP) {
						prefItem.PREOP = code;
					}
					if(codeItem.COST_MEAN === prefItem.ORNURSE) {
						prefItem.ORNURSE = code;
					}
					if(codeItem.COST_MEAN === prefItem.POSTOP) {
						prefItem.POSTOP = code;
					}
					newObj[code] = disp;
					$.extend(prefItem.OPTIONS,newObj);
				}
			}
			if(prefItem.PREF_KEY === "ROOT_LOC_CD") {
				codeLen = compObj.INV_VIEW.length;
				for(var i=0;i<codeLen;i++) {
					codeItem = compObj.INV_VIEW[i];
					code = codeItem.VIEW_CD.toString();
					disp = codeItem.VIEW_DISP;
					/*If we find a cdf meaning that matches our recommendation, swap it out with the code value that we're putting in Options*/
					if(codeItem.VIEW_DISP === prefItem.DEFAULT) {
						prefItem.DEFAULT = code;
					}
					if(codeItem.VIEW_DISP === prefItem.PREOP) {
						prefItem.PREOP = code;
					}
					if(codeItem.VIEW_DISP === prefItem.ORNURSE) {
						prefItem.ORNURSE = code;
					}
					if(codeItem.VIEW_DISP === prefItem.POSTOP) {
						prefItem.POSTOP = code;
					}
					newObj[code] = disp;
					$.extend(prefItem.OPTIONS,newObj);
				}
			}
			if(prefItem.PREF_KEY === "REPORT_CLASS_INSTANCE_CD") {
				codeLen = compObj.CLASS_INSTANCE.length;
				for(var i=0;i<codeLen;i++) {
					codeItem = compObj.CLASS_INSTANCE[i];
					code = codeItem.CLASS_CD.toString();
					disp = codeItem.CLASS_DISP;
					/*If we find a cdf meaning that matches our recommendation, swap it out with the code value that we're putting in Options*/
					if(codeItem.CLASS_MEAN === prefItem.DEFAULT) {
						prefItem.DEFAULT = code;
					}
					if(codeItem.CLASS_MEAN === prefItem.PREOP) {
						prefItem.PREOP = code;
					}
					if(codeItem.CLASS_MEAN === prefItem.ORNURSE) {
						prefItem.ORNURSE = code;
					}
					if(codeItem.CLASS_MEAN === prefItem.POSTOP) {
						prefItem.POSTOP = code;
					}
					newObj[code] = disp;
					$.extend(prefItem.OPTIONS,newObj);
				}
			}
		}
		mpObj.COMPARE.DOCI18NVALID = 1;
	} catch(err) {
		printStackTrace(err,arguments.callee.caller.toString());
		return 0;
	}
	return 0;
};
/*0 is doc, 1 is area, whatever it's set to, do the opposite to change*/
function toggleCompare(flag){
	try{
		$("#loading_compare").hide();
		//if(mpObj.TAB === mpObj.COMPARE_DOC.TAB) {
		if(flag===0) {
			$("#doc_buttons").hide();
			$("#docfilters").hide();
			$("#area_buttons").show();
			$("#report_doc_compare").hide();
			$("#report_area_compare").show();
			$("#toggleCompare-area").addClass("compare-button-active");
			$("#toggleCompare-area").removeClass("compare-button-inactive");
			$("#toggleCompare-document").addClass("compare-button-inactive");
			$("#toggleCompare-document").removeClass("compare-button-active");
			$("#toggleCompare-area").prop("disabled");
			$("#toggleCompare-document").removeProp("disabled");
			mpObj.TAB=mpObj.COMPARE_AREA.TAB;  /*change 'tab' to compare area*/
			mpObj.COMPARE.LASTTAB = mpObj.COMPARE_AREA.TAB
		}
		//} else {
		if(flag===1) {
			$("#area_buttons").hide();
			$("#docfilters").show();
			$("#doc_buttons").show();
			$("#report_area_compare").hide();
			$("#report_doc_compare").show();
			$("#toggleCompare-area").removeClass("compare-button-active");
			$("#toggleCompare-area").addClass("compare-button-inactive");
			$("#toggleCompare-document").removeClass("compare-button-inactive");
			$("#toggleCompare-document").addClass("compare-button-active");
			$("#toggleCompare-area").removeProp("disabled");
			$("#toggleCompare-document").prop("disabled");
			mpObj.TAB=mpObj.COMPARE_DOC.TAB; /*change 'tab' to compare doc*/
			mpObj.COMPARE.LASTTAB = mpObj.COMPARE_DOC.TAB
			//docCompareLoad();
		}
	} catch(err){
		printStackTrace(err,arguments.callee.caller.toString());
	}
};
