window.onload = function () {
		var chart = new CanvasJS.Chart("CurrentMonthIncomeExpenseOwed",
		{
			title:{text: "Income vs Expense vs Owed"},
			animationEnabled: true,
			axisY: {title: "Amount"},
			legend: {verticalAlign: "bottom",horizontalAlign: "center"},
			theme: "theme2",
			data: [
					{
						type: "column",  
						showInLegend: true, 
						legendMarkerColor: "grey",
						dataPoints: [	{y: 10000, label: "Owed"},
										{y: 238000,  label: "Expenses" },
										{y: 480000,  label: "Income"}
									]
					}
				]
		});
		chart.render();
	}