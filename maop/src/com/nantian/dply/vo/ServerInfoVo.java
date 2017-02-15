package com.nantian.dply.vo;

import java.io.Serializable;

/**
 * @author <a href="mailto:donghui@nantian.com.cn">dong</a>
 * 
 */
public class ServerInfoVo implements Serializable{

		private static final long serialVersionUID = 1L;
		
		/**  */
		private java.lang.String hostIp;
		
		/**  */
		private java.lang.String hostName;
		
		/**  */
		private java.lang.String osType;
		
		/**  */
		private java.lang.String osVersion;
		
		/**  */
		private java.lang.String environType;
		
		/**  */
		private java.lang.String fileTransferType;
		
		/**  */
		private java.lang.String fileTransferUser;
		
		/**  */
		private java.lang.String fileTransferPswd;
		
		/**  */
		private java.lang.String deleteFlag;

		public java.lang.String getHostName() {
			return hostName;
		}

		public void setHostName(java.lang.String hostName) {
			this.hostName = hostName;
		}

		public java.lang.String getHostIp() {
			return hostIp;
		}

		public void setHostIp(java.lang.String hostIp) {
			this.hostIp = hostIp;
		}

		public java.lang.String getOsType() {
			return osType;
		}

		public void setOsType(java.lang.String osType) {
			this.osType = osType;
		}

		public java.lang.String getOsVersion() {
			return osVersion;
		}

		public void setOsVersion(java.lang.String osVersion) {
			this.osVersion = osVersion;
		}

		public java.lang.String getEnvironType() {
			return environType;
		}

		public void setEnvironType(java.lang.String environType) {
			this.environType = environType;
		}

		public java.lang.String getFileTransferType() {
			return fileTransferType;
		}

		public void setFileTransferType(java.lang.String fileTransferType) {
			this.fileTransferType = fileTransferType;
		}

		public java.lang.String getFileTransferUser() {
			return fileTransferUser;
		}

		public void setFileTransferUser(java.lang.String fileTransferUser) {
			this.fileTransferUser = fileTransferUser;
		}

		public java.lang.String getFileTransferPswd() {
			return fileTransferPswd;
		}

		public void setFileTransferPswd(java.lang.String fileTransferPswd) {
			this.fileTransferPswd = fileTransferPswd;
		}

		public java.lang.String getDeleteFlag() {
			return deleteFlag;
		}

		public void setDeleteFlag(java.lang.String deleteFlag) {
			this.deleteFlag = deleteFlag;
		}
		
		
	
}