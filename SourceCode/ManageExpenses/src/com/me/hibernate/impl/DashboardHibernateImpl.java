package com.me.hibernate.impl;

import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.springframework.stereotype.Service;

import com.me.hibernate.inf.DashboardHibernateInf;

@Service("dashboardHibernate")
public class DashboardHibernateImpl implements DashboardHibernateInf{

	  private static DashboardHibernateImpl dashboardHibernateImpl = null;
	   
	   /* A private Constructor prevents any other 
	    * class from instantiating.
	    */
	   private DashboardHibernateImpl(){ }
	   
	   /* Static 'instance' method */
	   public static DashboardHibernateImpl getOperations() {
		      if(dashboardHibernateImpl == null) {
		    	  dashboardHibernateImpl = new DashboardHibernateImpl();
		      }
		      return dashboardHibernateImpl;
		   }
	
	/**
	 * This method returns result list of get query.
	 * @param userId 
	 * @return List
	 */
	   /*
	public static List readAll(String beanName) {

		Session session = HibernateAnnotationConfiguration.getConfiguration().getSession();
		Transaction tx = session.beginTransaction();
		Query query = session.createQuery("from " + beanName);
		List queryList = query.list();
		tx.commit();
		session.close();
		return queryList;

	}
	*/
	   
	@Override
	public String getDashBoardDetailQuery(String userId) {
		System.out.println("DashboardHibernateImpl");
		String getDashBoardquery="Select * from UserDetailBean ud where ud.userId = :userId";
		return getDashBoardquery;
	}

}
