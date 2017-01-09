package com.me.dao.impl;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.me.dao.inf.DashboardDaoInf;
import com.me.hibernate.inf.DashboardHibernateInf;

@Repository("dashboardDao")
public class DashboardDaoImpl implements DashboardDaoInf{

	@Autowired
	@Resource(name = "dashboardHibernate")
	DashboardHibernateInf dashboardHibernateInf;

	@Override
	public List getDashBoardDetails(String userId) {
		System.out.println("DashboardDaoImpl");
		String getDashBoardQuery = dashboardHibernateInf.getDashBoardDetailQuery(userId);
		List dasboardDetailsList = new ArrayList();	
		return dasboardDetailsList;
	}

}
