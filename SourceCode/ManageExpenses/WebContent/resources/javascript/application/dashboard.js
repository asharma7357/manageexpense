/*
 *(#)dashboard.js - Copyright
 * All rights reserved.
 */
me = new Object();
me.application = new Object();

if (typeof me.application.dashboard == "undefined") {
	me.application.dashboard = function() {
		return {

			msgArray:[], // variable for  checking same message

			/**
			 * @author rahikhan
			 * @description Function to be called once the dashboard loaded.
			 */
			onload : function(){
				console.log("dashboard.js : onload..called without error");
				//me.application.dashboard.getDashboardDetails();
				me.application.dashboard.getRequirementTemplateData();
				me.application.dashboard.getDashboardData();
			},

			getDashboardDetails : function(){
				console.log("dashboard.js : getDashboardDetails...");

				var promise = $.ajax({
					async: true,
					url: "dashboard/getDashboardDetails.htm",
					type: "GET",
					datatype: "json",
				}).done(function(result) {
					result = JSON.parse(result);
					console.log("\tresult : " + result);
				}).fail(function(jqXHR, textStatus) {
//					console.log("getDashboardDetails : fail called);
					console.log("\tgetDashboardDetails : Application Exception Occured " );
				});
				return promise;
			},

			getRequirementTemplateData : function(){
				console.log("dashboard.js : getRequirementTemplateData");

				var promise = $.ajax({
					async: true,
					url: "dashboard/getRequirementTemplateData.htm",
					type: "GET",
					datatype: "json",
				}).done(function(result) {
					result = JSON.stringify(result);
					console.log("\tresult : " + result);
					dashboard = JSON.parse(result);
					console.log(dashboard);
				}).fail(function(jqXHR, textStatus) {
					console.log("\tgetRequirementTemplateData : Application Exception Occured");
				});
				return promise;
			},
			

			getDashboardData : function(){
				console.log("dashboard.js : getDashboardData");

				var promise = $.ajax({
					async: true,
					url: "dashboard/getDashboardData.htm",
					type: "GET",
					datatype: "json",
				}).done(function(result) {
					result = JSON.stringify(result);
					console.log("\tresult : " + result);
					dashboard = JSON.parse(result);
					console.log(dashboard);
				}).fail(function(jqXHR, textStatus) {
					console.log("\tgetDashboardData : Application Exception Occured ");
				});
				return promise;
			},
			
		}
	}();
}
