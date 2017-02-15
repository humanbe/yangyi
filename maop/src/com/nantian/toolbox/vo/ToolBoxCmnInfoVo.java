/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.toolbox.vo;

import java.io.Serializable;

/**
 * @author ky
 * 
 */
public class ToolBoxCmnInfoVo implements Serializable {
	private static final long serialVersionUID = 1L;


	/**应用系统编号*/
	private String appsys_code;
	/**服务器分组*/
	private String  server_group;
	/**服务器Ip*/
	private String server_ip;
	
	public String getAppsys_code() {
		return appsys_code;
	}
	public void setAppsys_code(String appsys_code) {
		this.appsys_code = appsys_code;
	}
	public String getServer_group() {
		return server_group;
	}
	public void setServer_group(String server_group) {
		this.server_group = server_group;
	}
	public String getServer_ip() {
		return server_ip;
	}
	public void setServer_ip(String server_ip) {
		this.server_ip = server_ip;
	}

	
	

}
