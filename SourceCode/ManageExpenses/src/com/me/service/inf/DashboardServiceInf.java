package com.me.service.inf;

import java.util.List;

import org.springframework.stereotype.Service;


public interface DashboardServiceInf {

	/**
	 * This service gets dashboard details based on user id
	 * @param userId
	 * @return
	 */
	public List getDashBoardDetails(String userId);
}
