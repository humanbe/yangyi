package com.nantian.dply.vo;

import java.io.Serializable;

public class AppChangeSummaryVo implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	/**序列号*/
	private Long appChangeId;
	/**系统编号*/
	private String aplCode;
	/**变更日期*/
	private String changeDate;
	/**时间 YYYYMMDD HH:MM:SS*/
	private String time;
	/**类型*/
	private String type;
	/**现象*/
	private String phenomenon;
	/**原因*/
	private String cause;
	/**处理方法*/
	private String handleMethod;
	/**后续改进*/
	private String improveMethod;
	
	private AppChangeVo appChange;

	public Long getAppChangeId() {
		return appChangeId;
	}

	public void setAppChangeId(Long appChangeId) {
		this.appChangeId = appChangeId;
	}

	public String getAplCode() {
		return aplCode;
	}

	public void setAplCode(String aplCode) {
		this.aplCode = aplCode;
	}

	public String getChangeDate() {
		return changeDate;
	}

	public void setChangeDate(String changeDate) {
		this.changeDate = changeDate;
	}

	public String getTime() {
		return time;
	}

	public void setTime(String time) {
		this.time = time;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getPhenomenon() {
		return phenomenon;
	}

	public void setPhenomenon(String phenomenon) {
		this.phenomenon = phenomenon;
	}

	public String getCause() {
		return cause;
	}

	public void setCause(String cause) {
		this.cause = cause;
	}

	public String getHandleMethod() {
		return handleMethod;
	}

	public void setHandleMethod(String handleMethod) {
		this.handleMethod = handleMethod;
	}

	public String getImproveMethod() {
		return improveMethod;
	}

	public void setImproveMethod(String improveMethod) {
		this.improveMethod = improveMethod;
	}
	
	public AppChangeVo getAppChange() {
		return appChange;
	}

	public void setAppChange(AppChangeVo appChange) {
		this.appChange = appChange;
	}

	public boolean isValid(AppChangeSummaryVo vo){
		if((vo.getTime() == null || "".equals(vo.getTime()))
				&& (vo.getType() == null || "".equals(vo.getType()))
				&& (vo.getPhenomenon() == null || "".equals(vo.getPhenomenon()))
				&& (vo.getCause() == null || "".equals(vo.getCause()))
				&& (vo.getImproveMethod() == null || "".equals(vo.getImproveMethod()))
				&& (vo.getHandleMethod() == null || "".equals(vo.getHandleMethod()))){
			return false;
		}
		return true;
	}

}
