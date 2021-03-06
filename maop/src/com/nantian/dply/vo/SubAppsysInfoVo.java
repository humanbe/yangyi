/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.dply.vo;

import java.io.Serializable;

/**
 * @author ky
 *
 */
public class SubAppsysInfoVo implements Serializable {
	private static final long serialVersionUID = 1L;

	private String appsysCode;
	private String subAppsysCode;
	private String subAppsysName;
	private String reserve1;
	private String reserve2;
	private String reserve3;
	private String reserve4;
	private String reserve5;
	private String deleteFlag;
	
	public SubAppsysInfoVo(){
		super();
	}

	/**
	 * @return the appsysCode
	 */
	public String getAppsysCode() {
		return appsysCode;
	}

	/**
	 * @param appsysCode the appsysCode to set
	 */
	public void setAppsysCode(String appsysCode) {
		this.appsysCode = appsysCode;
	}

	/**
	 * @return the subAppsysCode
	 */
	public String getSubAppsysCode() {
		return subAppsysCode;
	}

	/**
	 * @param subAppsysCode the subAppsysCode to set
	 */
	public void setSubAppsysCode(String subAppsysCode) {
		this.subAppsysCode = subAppsysCode;
	}

	/**
	 * @return the subAppsysName
	 */
	public String getSubAppsysName() {
		return subAppsysName;
	}

	/**
	 * @param subAppsysName the subAppsysName to set
	 */
	public void setSubAppsysName(String subAppsysName) {
		this.subAppsysName = subAppsysName;
	}

	/**
	 * @return the reserve1
	 */
	public String getReserve1() {
		return reserve1;
	}

	/**
	 * @param reserve1 the reserve1 to set
	 */
	public void setReserve1(String reserve1) {
		this.reserve1 = reserve1;
	}

	/**
	 * @return the reserve2
	 */
	public String getReserve2() {
		return reserve2;
	}

	/**
	 * @param reserve2 the reserve2 to set
	 */
	public void setReserve2(String reserve2) {
		this.reserve2 = reserve2;
	}

	/**
	 * @return the reserve3
	 */
	public String getReserve3() {
		return reserve3;
	}

	/**
	 * @param reserve3 the reserve3 to set
	 */
	public void setReserve3(String reserve3) {
		this.reserve3 = reserve3;
	}

	/**
	 * @return the reserve4
	 */
	public String getReserve4() {
		return reserve4;
	}

	/**
	 * @param reserve4 the reserve4 to set
	 */
	public void setReserve4(String reserve4) {
		this.reserve4 = reserve4;
	}

	/**
	 * @return the reserve5
	 */
	public String getReserve5() {
		return reserve5;
	}

	/**
	 * @param reserve5 the reserve5 to set
	 */
	public void setReserve5(String reserve5) {
		this.reserve5 = reserve5;
	}

	/**
	 * @return the deleteFlag
	 */
	public String getDeleteFlag() {
		return deleteFlag;
	}

	/**
	 * @param deleteFlag the deleteFlag to set
	 */
	public void setDeleteFlag(String deleteFlag) {
		this.deleteFlag = deleteFlag;
	}
	
}
