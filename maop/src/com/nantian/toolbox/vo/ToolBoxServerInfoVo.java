/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.toolbox.vo;

import java.io.Serializable;

/**
 * @author ky
 * 
 */
public class ToolBoxServerInfoVo implements Serializable {
	private static final long serialVersionUID = 1L;
	/**工具编号*/
	private String tool_code;
	/**应用系统*/
	private String appsys_code;
	/**服务器IP*/
	private String server_ip;
	/**服务器绝对路径*/
	private String server_route;
	/**操作用户*/
	private String os_user;
	
	public String getOs_user() {
		return os_user;
	}
	public void setOs_user(String os_user) {
		this.os_user = os_user;
	}
	public String getTool_code() {
		return tool_code;
	}
	public void setTool_code(String tool_code) {
		this.tool_code = tool_code;
	}
	public String getAppsys_code() {
		return appsys_code;
	}
	public void setAppsys_code(String appsys_code) {
		this.appsys_code = appsys_code;
	}
	public String getServer_ip() {
		return server_ip;
	}
	public void setServer_ip(String server_ip) {
		this.server_ip = server_ip;
	}
	public String getServer_route() {
		return server_route;
	}
	public void setServer_route(String server_route) {
		this.server_route = server_route;
	}
	
	
	public boolean isValid(ToolBoxServerInfoVo vo){
		if((vo.getTool_code() == null || "".equals(vo.getTool_code()))
				&& (vo.getServer_ip() == null || "".equals(vo.getServer_ip()))
				&& (vo.getAppsys_code()== null || "".equals(vo.getAppsys_code()))
			    
				
				){
			return false;
		}
		return true;
	}
	
}