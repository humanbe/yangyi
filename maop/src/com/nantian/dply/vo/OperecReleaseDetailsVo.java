/**
 * Copyright 2012 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.dply.vo;

import java.io.Serializable;

/**
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 * 
 */
public class OperecReleaseDetailsVo  implements Serializable {
	private static final long serialVersionUID = 1L;
	
	/** 功能ID */
	private String functionId;
	/** 执行年月日时分毫秒 */
	private String execYmdhmsf;
	/** 处理完成输入文件 */
	private String procomInputFile;
	/** 任务编号 */
	private String jobCode;
	/** 执行步骤 */
	private String execStep;
	/** 资源ID */
	private String resourceId;
	/** 资源路径 */
	private String resourcePath;
	/** 操作对象IP地址 */
	private String targetIp;
	/** 操作对象环境ID */
	private String targetEnvId;
	/** 执行结果状态 */
	private String execResultStatus;
	/** 执行信息 */
	private String execMessage;
	/** 备用1 */
	private String reserve1;
	/** 备用2 */
	private String reserve2;
	/** 备用3 */
	private String reserve3;
	/** 备用4 */
	private String reserve4;
	/** 备用5 */
	private String reserve5;
	/** 删除标示 */
	private String deleteFlag;
	
	public String getFunctionId() {
		return functionId;
	}
	public void setFunctionId(String functionId) {
		this.functionId = functionId;
	}
	public String getExecYmdhmsf() {
		return execYmdhmsf;
	}
	public void setExecYmdhmsf(String execYmdhmsf) {
		this.execYmdhmsf = execYmdhmsf;
	}
	public String getProcomInputFile() {
		return procomInputFile;
	}
	public void setProcomInputFile(String procomInputFile) {
		this.procomInputFile = procomInputFile;
	}
	public String getJobCode() {
		return jobCode;
	}
	public void setJobCode(String jobCode) {
		this.jobCode = jobCode;
	}
	public String getExecStep() {
		return execStep;
	}
	public void setExecStep(String execStep) {
		this.execStep = execStep;
	}
	public String getResourceId() {
		return resourceId;
	}
	public void setResourceId(String resourceId) {
		this.resourceId = resourceId;
	}
	public String getResourcePath() {
		return resourcePath;
	}
	public void setResourcePath(String resourcePath) {
		this.resourcePath = resourcePath;
	}
	public String getTargetIp() {
		return targetIp;
	}
	public void setTargetIp(String targetIp) {
		this.targetIp = targetIp;
	}
	public String getTargetEnvId() {
		return targetEnvId;
	}
	public void setTargetEnvId(String targetEnvId) {
		this.targetEnvId = targetEnvId;
	}
	public String getExecResultStatus() {
		return execResultStatus;
	}
	public void setExecResultStatus(String execResultStatus) {
		this.execResultStatus = execResultStatus;
	}
	public String getExecMessage() {
		return execMessage;
	}
	public void setExecMessage(String execMessage) {
		this.execMessage = execMessage;
	}
	public String getReserve1() {
		return reserve1;
	}
	public void setReserve1(String reserve1) {
		this.reserve1 = reserve1;
	}
	public String getReserve2() {
		return reserve2;
	}
	public void setReserve2(String reserve2) {
		this.reserve2 = reserve2;
	}
	public String getReserve3() {
		return reserve3;
	}
	public void setReserve3(String reserve3) {
		this.reserve3 = reserve3;
	}
	public String getReserve4() {
		return reserve4;
	}
	public void setReserve4(String reserve4) {
		this.reserve4 = reserve4;
	}
	public String getReserve5() {
		return reserve5;
	}
	public void setReserve5(String reserve5) {
		this.reserve5 = reserve5;
	}
	public String getDeleteFlag() {
		return deleteFlag;
	}
	public void setDeleteFlag(String deleteFlag) {
		this.deleteFlag = deleteFlag;
	}
	
	
}///:~
