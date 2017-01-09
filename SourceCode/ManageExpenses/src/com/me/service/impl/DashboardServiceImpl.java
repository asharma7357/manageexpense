package com.me.service.impl;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.me.bean.DashboardBean;
import com.me.dao.inf.DashboardDaoInf;
import com.me.service.inf.DashboardServiceInf;
import com.me.bean.DashboardBean;

@Service("dashboardService")
public class DashboardServiceImpl implements DashboardServiceInf{

	@Autowired
	@Resource(name = "dashboardDao")
	DashboardDaoInf dashboardDaoInf;
	
	@Override
	public List getDashBoardDetails(String userId) {
		System.out.println("DashboardServiceImpl");
		List<DashboardBean> dashboardList = dashboardDaoInf.getDashBoardDetails(userId);
		
		DashboardBean dashboardBean = new DashboardBean();
		dashboardBean.setPageName("DashBoard");
		dashboardBean.setSavingDetails("Current Month Saving");
		dashboardBean.setSavingAmount("50000.00");
		dashboardBean.setEarningDetails("Curren Month earning");
		dashboardBean.setEarningDetails("80000.00");
		dashboardBean.setOwedDetails("Total owed");
		dashboardBean.setOwedAmount("0.00");
		dashboardBean.setExpensesDetails("Current Month Expenses");
		dashboardBean.setExpensesAmount("18000.00");
		
		dashboardList = new ArrayList<DashboardBean>();
		dashboardList.add(dashboardBean);
		
		System.out.println("dashboardList.size() : " + dashboardList.size() + "\n\tdashboardList : " + dashboardList.get(0).toString());
		
		
		return dashboardList;
	}

	
}
