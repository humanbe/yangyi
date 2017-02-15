package com.nantian.rept.vo;

import java.io.Serializable;

public class BatchOvertimeAnaVo implements Serializable{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	private String jobName;
	
	private String appSysCd;
	
	private String errorTime;
	
	private String jobDesc;
	
	private String overtimeFlag;

	private String capaRiskType;
	
	private String jobEffect;
	
	private String errorCauseAna;

	public String getJobName() {
		return jobName;
	}

	public void setJobName(String jobName) {
		this.jobName = jobName;
	}

	public String getAppSysCd() {
		return appSysCd;
	}

	public void setAppSysCd(String appSysCd) {
		this.appSysCd = appSysCd;
	}

	public String getErrorTime() {
		return errorTime;
	}

	public void setErrorTime(String errorTime) {
		this.errorTime = errorTime;
	}

	public String getJobDesc() {
		return jobDesc;
	}

	public void setJobDesc(String jobDesc) {
		this.jobDesc = jobDesc;
	}

	public String getOvertimeFlag() {
		return overtimeFlag;
	}

	public void setOvertimeFlag(String overtimeFlag) {
		this.overtimeFlag = overtimeFlag;
	}

	public String getCapaRiskType() {
		return capaRiskType;
	}

	public void setCapaRiskType(String capaRiskType) {
		this.capaRiskType = capaRiskType;
	}

	public String getJobEffect() {
		return jobEffect;
	}

	public void setJobEffect(String jobEffect) {
		this.jobEffect = jobEffect;
	}

	public String getErrorCauseAna() {
		return errorCauseAna;
	}

	public void setErrorCauseAna(String errorCauseAna) {
		this.errorCauseAna = errorCauseAna;
	}
	

}
