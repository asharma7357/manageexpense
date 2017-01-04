package com.me.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

@Controller
public class ManageExpensesController {
	@RequestMapping("/index")
	public ModelAndView manageExpense(){
		String strMessage = "Welcome Bro..";
		return new ModelAndView("hello", "message", strMessage);
	}
}
