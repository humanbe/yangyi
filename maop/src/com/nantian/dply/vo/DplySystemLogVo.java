 package com.nantian.dply.vo;

import java.io.Serializable;

/**
 * @author <a href="mailto:donghui@nantian.com.cn">dong</a>
 * 
 */
public class DplySystemLogVo implements Serializable{

        /**
     * 
     */
    private static final long serialVersionUID = 1L;
        private String appsysCode;
        private int reqId;
        private String reqName;
        private int stepId;
        private String reqStep;
        private String exeTime;
        private String startTime;
        private String finishTime;
        private String estimateTime;
        private String exeResult;
        private String runLog;
        
        public static long getSerialversionuid() {
            return serialVersionUID;
        }
        public String getAppsysCode() {
            return appsysCode;
        }
        public void setAppsysCode(String appsysCode) {
            this.appsysCode = appsysCode;
        }
        public String getReqStep() {
            return reqStep;
        }
        public void setReqStep(String reqStep) {
            this.reqStep = reqStep;
        }
        public int getReqId() {
			return reqId;
		}
		public void setReqId(int reqId) {
			this.reqId = reqId;
		}
		public int getStepId() {
			return stepId;
		}
		public void setStepId(int stepId) {
			this.stepId = stepId;
		}
		public String getExeTime() {
            return exeTime;
        }
        public void setExeTime(String exeTime) {
            this.exeTime = exeTime;
        }
        public String getStartTime() {
            return startTime;
        }
        public void setStartTime(String startTime) {
            this.startTime = startTime;
        }
        public String getFinishTime() {
            return finishTime;
        }
        public void setFinishTime(String finishTime) {
            this.finishTime = finishTime;
        }
        public String getEstimateTime() {
            return estimateTime;
        }
        public void setEstimateTime(String estimateTime) {
            this.estimateTime = estimateTime;
        }
        public String getExeResult() {
            return exeResult;
        }
        public void setExeResult(String exeResult) {
            this.exeResult = exeResult;
        }
        public String getRunLog() {
            return runLog;
        }
        public void setRunLog(String runLog) {
            this.runLog = runLog;
        }
		public String getReqName() {
			return reqName;
		}
		public void setReqName(String reqName) {
			this.reqName = reqName;
		}
}