package com.nantian.common.system.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.common.system.service.IamStatusService;
import com.nantian.jeda.Constants;

@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/iamstatus")
public class IamStatusController {
	
	@Autowired
	private IamStatusService iamStatusService;
	
	/**
	 * 获取iam运行状态标志位
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/getStatus", method = RequestMethod.GET)
	public @ResponseBody ModelMap getStatus (ModelMap modelMap) {
		int status = iamStatusService.queryState();
		modelMap.addAttribute("iamStatus", status);
		return modelMap;
	}
	
}
