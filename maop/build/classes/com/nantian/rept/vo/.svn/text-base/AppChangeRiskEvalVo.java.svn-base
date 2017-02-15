package com.nantian.rept.vo;

import java.io.Serializable;

public class AppChangeRiskEvalVo implements Serializable {
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
	/**变更风险评估.1:低,2：中,3：高*/
	private String changeRiskEval;
	/**服务停止时间*/
	private String stopServiceTime;
	/**主要变更风险*/
	private String primaryChangeRisk;
	/**风险应对措施*/
	private String riskHandleMethod;
	/**其他注意事项*/
	private String other;
	
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

	public String getChangeRiskEval() {
		return changeRiskEval;
	}

	public void setChangeRiskEval(String changeRiskEval) {
		this.changeRiskEval = changeRiskEval;
	}

	public String getStopServiceTime() {
		return stopServiceTime;
	}

	public void setStopServiceTime(String stopServiceTime) {
		this.stopServiceTime = stopServiceTime;
	}

	public String getPrimaryChangeRisk() {
		return primaryChangeRisk;
	}

	public void setPrimaryChangeRisk(String primaryChangeRisk) {
		this.primaryChangeRisk = primaryChangeRisk;
	}

	public String getRiskHandleMethod() {
		return riskHandleMethod;
	}

	public void setRiskHandleMethod(String riskHandleMethod) {
		this.riskHandleMethod = riskHandleMethod;
	}

	public String getOther() {
		return other;
	}

	public void setOther(String other) {
		this.other = other;
	}
	
	public AppChangeVo getAppChange() {
		return appChange;
	}

	public void setAppChange(AppChangeVo appChange) {
		this.appChange = appChange;
	}

	public boolean isValid(AppChangeRiskEvalVo vo){
		if ((vo.getChangeRiskEval() == null || "".equals(vo.getChangeRiskEval()))
				&& (vo.getStopServiceTime() == null || "".equals(vo.getStopServiceTime()))
				&& (vo.getPrimaryChangeRisk() == null || "".equals(vo.getPrimaryChangeRisk()))
				&& (vo.getRiskHandleMethod() == null || "".equals(vo.getRiskHandleMethod()))
				&& (vo.getOther() == null || "".equals(vo.getOther()))) {
			return false;
		}
		return true;
	}
	
}
