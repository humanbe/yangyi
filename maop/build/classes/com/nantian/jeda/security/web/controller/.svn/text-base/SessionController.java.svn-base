/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda.security.web.controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import com.nantian.jeda.JEDAException;

/**
 * @author <a href="mailto:daizhenzhong@nantian.com.cn">daizhenzhong</a>
 * 
 */
@Controller
public class SessionController {

	@RequestMapping(value = "/invalid-session", method = RequestMethod.GET)
	public String invalidSession(HttpServletRequest request, HttpServletResponse response) throws JEDAException {
		response.addHeader("session_timeout", "true");
		return "common/invalid-session";
	}
}
