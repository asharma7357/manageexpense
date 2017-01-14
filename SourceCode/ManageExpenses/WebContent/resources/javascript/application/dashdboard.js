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
				console.log("dashboard.js : onload");
				me.application.dashboard.getDashboardDetails();


			},

			getDashboardDetails : function(){
				console.log("dashboard.js : getDashboardDetails");

				var promise = $.ajax({
					async: true,
					url: "dashboard/getDashboardDetails.htm",
					type: "GET",
					datatype: "json",
				}).done(function(result) {
					result = JSON.parse(result);
					if (result.sessionMessage != null && result.sessionMessage != "") {
						console.log("\t" + result.sessionMessage);
					} else if (result != null && result.errorMessage != null) {
						if (result.errorCode == 1000) {
							console.log("\t" + result.errorMessage);
						}
						console.log("\tfailure : " + result.errorMessage);
					} else {
						console.log("getDashboardDetails : \n\tresult : " + result);
					}
				}).fail(function(jqXHR, textStatus) {
					console.log("Application Exception Occured \n\tjqXHR : " + JSON.stringify(jqXHR) + "\n\ttextStatus : " + textStatus);
				});
				return promise;
			},

		}
	}();
}
