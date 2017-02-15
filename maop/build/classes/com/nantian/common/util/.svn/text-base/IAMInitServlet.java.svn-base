package com.nantian.common.util;

import java.io.IOException;
import java.io.InputStream;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.ultrapower.casp.client.LoginUtil;

/**
 * 初始化iam的LoginUtil对象
 * 提取并过滤url中附加的iam票据参数, 并存放到session中
 * @author LJay
 *
 */
public class IAMInitServlet extends HttpServlet {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	protected Logger logger = LoggerFactory.getLogger(getClass());
	
	/**
	 * Validates the Init and Context parameters, configures authentication URL
	 * 
	 * @@throws ServletException if the init parameters are invalid or any other
	 *          problems occur during initialisation
	 */
	public void init() throws ServletException {
		logger.info("initialize IAM login config...");
		String caspConfigPath = this.getServletContext().getInitParameter("casConfigLocation");
		InputStream in = this.getServletContext().getResourceAsStream(caspConfigPath);
		//初始化配置文件,参数为上面配置文件路径
		LoginUtil.getInstance().init(in); 
	}
	
	public void doGet(HttpServletRequest request, HttpServletResponse response)
			throws IOException, ServletException {
		execute(request, response);
	}
	
	public void doPost(HttpServletRequest request, HttpServletResponse response)
			throws IOException, ServletException {
		execute(request, response);
	}
	
	public void execute(HttpServletRequest request, HttpServletResponse response)
			throws IOException, ServletException {
		String ticket = request.getParameter("iamcaspticket");
		if(ticket != null) {
			request.getSession().setAttribute("iamcaspticket", ticket);
		} else {
			request.getSession().removeAttribute("iamcaspticket");
		}
		response.sendRedirect(request.getContextPath());
	}

}
