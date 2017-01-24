package com.me.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.*;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
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

import com.me.bean.DashboardBean;
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
	public @ResponseBody String  getDashBoardDetails(Model model){
		
		//Map<String,Object>
		String userId ="rahil";
		System.out.println("DashboardController");
		List dashboardDetailsList = dashboardServiceInf.getDashBoardDetails(userId);
		Map<String,Object> dashBoardMap = new HashMap<String, Object>();
		dashBoardMap.put("dashboard", dashboardDetailsList.get(0));
		model.addAttribute("dashboard", dashboardDetailsList.get(0));
		System.out.println("DashboardController : \n\tdashboardDetailsList.size() : " + dashboardDetailsList.size() + "\n\tdashboardDetailsList : " + dashboardDetailsList.get(0).toString());
		
		return "dashboard";
	}

	@RequestMapping(value="/getRequirementTemplateData" , method = RequestMethod.GET)
	public String getRequirementTemplateData(Model model){
        System.out.println("DashboardController.java : getRequirementTemplateData");

		String userId ="rahil";
		System.out.println("DashboardController");
		List dashboardDetailsList = dashboardServiceInf.getDashBoardDetails(userId);
		Map<String,Object> dashBoardMap = new HashMap<String, Object>();
		dashBoardMap.put("dashboard", dashboardDetailsList.get(0));
		System.out.println("DashboardController : \n\tdashboardDetailsList.size() : " + dashboardDetailsList.size() + "\n\tdashboardDetailsList : " + dashboardDetailsList.get(0).toString());

        return "dashboard";
	}

	@RequestMapping(value="/getDashboardData" , method = RequestMethod.GET)
	public DashboardBean getDashboardData(){
        System.out.println("DashboardController.java : getRequirementTemplateData");

		String userId ="rahil";
		System.out.println("DashboardController");
		List dashboardDetailsList = dashboardServiceInf.getDashBoardDetails(userId);
		Map<String,Object> dashBoardMap = new HashMap<String, Object>();
		dashBoardMap.put("dashboard", dashboardDetailsList.get(0));
		System.out.println("DashboardController : \n\tdashboardDetailsList.size() : " + dashboardDetailsList.size() + "\n\tdashboardDetailsList : " + dashboardDetailsList.get(0).toString());

        return (DashboardBean) dashboardDetailsList.get(0);
	}

	
	
	
}
