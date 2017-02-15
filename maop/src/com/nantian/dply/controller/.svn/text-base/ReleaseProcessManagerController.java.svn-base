package com.nantian.dply.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import com.nantian.jeda.Constants;
import com.nantian.jeda.JEDAException;
/**
 * 发布过程管理BRPMController
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 * 
 */
@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/releaseprocessmanager")
public class ReleaseProcessManagerController {
	
	/** 模板管理领域对象名称 */
	private static final String domain = "release";
	
	/** 视图前缀 */
	private static final String viewPrefix = "dply/" + domain + "/" + domain;

	/**
	 * 返回上传管理页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String upload() throws JEDAException {
		return viewPrefix + "_processmanager_index";
	}

    
}///:~
