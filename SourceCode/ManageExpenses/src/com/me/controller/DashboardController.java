package com.me.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.*;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
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
//	@RequestMapping(value = "/getRequirementTemplateData", method = RequestMethod.GET)
	@RequestMapping(value = "/getDashboardDetails", method = RequestMethod.GET)
	public @ResponseBody Map<String,Object>  getDashBoardDetails(){
		
		//Map<String,Object>
		String userId ="rahil";
		System.out.println("DashboardController");
		List dashboardDetailsList = dashboardServiceInf.getDashBoardDetails(userId);
		Map<String,Object> dashBoardMap = new HashMap<String, Object>();
		dashBoardMap.put("dashboard", dashboardDetailsList.get(0));
		System.out.println("DashboardController : \n\tdashboardDetailsList.size() : " + dashboardDetailsList.size() + "\n\tdashboardDetailsList : " + dashboardDetailsList.get(0).toString());
		
		return dashBoardMap;
	}

	@RequestMapping(value="/getRequirementTemplateData" , method = RequestMethod.GET)
	public @ResponseBody String getRequirementTemplateData(){
        System.out.println("DashboardController.java : getRequirementTemplateData");
		return "dashBoardMap";
	}
	
	
}
