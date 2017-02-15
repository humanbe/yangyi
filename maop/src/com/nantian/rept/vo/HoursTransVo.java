package com.nantian.rept.vo;

import java.io.Serializable;

/**
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 * 
 */
public class HoursTransVo implements Serializable{

		private static final long serialVersionUID = 1L;
		
		/** 应用系统编号 */
		private String aplCode;
		
		/** 交易日期 */
		private String transDate;
		
		/** 统计小时 */
		private String countHourTime;
		
		/** 统计科目 */
		private String countItem;
		
		/** 统计数值 */
		private int countAmount;

		public String getAplCode() {
			return aplCode;
		}

		public void setAplCode(String aplCode) {
			this.aplCode = aplCode;
		}

		public String getTransDate() {
			return transDate;
		}

		public void setTransDate(String transDate) {
			this.transDate = transDate;
		}

		public String getCountHourTime() {
			return countHourTime;
		}

		public void setCountHourTime(String countHourTime) {
			this.countHourTime = countHourTime;
		}

		public String getCountItem() {
			return countItem;
		}

		public void setCountItem(String countItem) {
			this.countItem = countItem;
		}

		public int getCountAmount() {
			return countAmount;
		}

		public void setCountAmount(int countAmount) {
			this.countAmount = countAmount;
		}
		
	
}///:~