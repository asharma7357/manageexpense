package com.me.bean;

//import org.codehaus.jackson.annotate.JsonIgnoreProperties;
//
//@JsonIgnoreProperties(ignoreUnknown = true)
public class DashboardBean {

	private String pageName;
	private String savingDetails;
	private String savingAmount;
	private String earningDetails;
	private String earningAmount;
	private String owedDetails;
	private String owedAmount;
	private String expensesDetails;
	private String expensesAmount;
	public String getPageName() {
		return pageName;
	}
	public void setPageName(String pageName) {
		this.pageName = pageName;
	}
	public String getSavingDetails() {
		return savingDetails;
	}
	public void setSavingDetails(String savingDetails) {
		this.savingDetails = savingDetails;
	}
	public String getSavingAmount() {
		return savingAmount;
	}
	public void setSavingAmount(String savingAmount) {
		this.savingAmount = savingAmount;
	}
	public String getEarningDetails() {
		return earningDetails;
	}
	public void setEarningDetails(String earningDetails) {
		this.earningDetails = earningDetails;
	}
	public String getEarningAmount() {
		return earningAmount;
	}
	public void setEarningAmount(String earningAmount) {
		this.earningAmount = earningAmount;
	}
	public String getOwedDetails() {
		return owedDetails;
	}
	public void setOwedDetails(String owedDetails) {
		this.owedDetails = owedDetails;
	}
	public String getOwedAmount() {
		return owedAmount;
	}
	public void setOwedAmount(String owedAmount) {
		this.owedAmount = owedAmount;
	}
	public String getExpensesDetails() {
		return expensesDetails;
	}
	public void setExpensesDetails(String expensesDetails) {
		this.expensesDetails = expensesDetails;
	}
	public String getExpensesAmount() {
		return expensesAmount;
	}
	public void setExpensesAmount(String expensesAmount) {
		this.expensesAmount = expensesAmount;
	}
	@Override
	public String toString() {
		return "DashboardBean [pageName=" + pageName + ", savingDetails=" + savingDetails + ", savingAmount="
				+ savingAmount + ", earningDetails=" + earningDetails + ", earningAmount=" + earningAmount
				+ ", owedDetails=" + owedDetails + ", owedAmount=" + owedAmount + ", expensesDetails=" + expensesDetails
				+ ", expensesAmount=" + expensesAmount + "]";
	}
	
	
	
	
}
