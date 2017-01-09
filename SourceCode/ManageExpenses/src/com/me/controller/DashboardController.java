package com.me.controller;

import java.util.List;

import javax.annotation.*;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;


import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.me.service.inf.DashboardServiceInf;


@RestController
@RequestMapping("/dashboard")
public class DashboardController {

	@Autowired
	@Resource(name ="dashboardService")
	DashboardServiceInf dashboardServiceInf; 
	
	/**
	 * This service returns Dashboard data details
	 * @return String
	 */
	@RequestMapping(value = "/getDashboardDetails", method = RequestMethod.GET)
	public @ResponseBody String getDashBoardDetails(@PathVariable(value ="userId") String userId ){
		System.out.println("DashboardController");
		List dashboardDetailsList = dashboardServiceInf.getDashBoardDetails(userId);
		return "hello";
	}

	
}
