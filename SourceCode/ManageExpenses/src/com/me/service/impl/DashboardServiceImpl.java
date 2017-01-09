package com.me.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.me.dao.inf.DashboardDaoInf;
import com.me.service.inf.DashboardServiceInf;

@Service("dashboardService")
public class DashboardServiceImpl implements DashboardServiceInf{

	@Autowired
	@Resource(name = "dashboardDao")
	DashboardDaoInf dashboardDaoInf;
	
	@Override
	public List getDashBoardDetails(String userId) {
		System.out.println("DashboardServiceImpl");
		List dashboardList = dashboardDaoInf.getDashBoardDetails(userId);
		return dashboardList;
	}

	
}
