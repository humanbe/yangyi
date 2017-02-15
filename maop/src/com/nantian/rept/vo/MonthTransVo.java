package com.nantian.rept.vo;

import java.io.Serializable;

public class MonthTransVo implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	/**系统编号*/
	private String aplCode;
	
	/**统计月份*/
	private String countMonth;
	
	/**日均交易量*/
	private String dayAvgTrans;
	
	/**工作日日均交易量*/
	private String workdayAvgTrans;
	
	/**休息日日均交易量*/
	private String holidayAvgTrans;
	
	/**月峰值交易量*/
	private String monthPeakTrans;
	
	/**月总交易量*/
	private String monthTotalTrans;

	public String getAplCode() {
		return aplCode;
	}

	public void setAplCode(String aplCode) {
		this.aplCode = aplCode;
	}

	public String getCountMonth() {
		return countMonth;
	}

	public void setCountMonth(String countMonth) {
		this.countMonth = countMonth;
	}

	public String getDayAvgTrans() {
		return dayAvgTrans;
	}

	public void setDayAvgTrans(String dayAvgTrans) {
		this.dayAvgTrans = dayAvgTrans;
	}

	public String getWorkdayAvgTrans() {
		return workdayAvgTrans;
	}

	public void setWorkdayAvgTrans(String workdayAvgTrans) {
		this.workdayAvgTrans = workdayAvgTrans;
	}

	public String getHolidayAvgTrans() {
		return holidayAvgTrans;
	}

	public void setHolidayAvgTrans(String holidayAvgTrans) {
		this.holidayAvgTrans = holidayAvgTrans;
	}

	public String getMonthPeakTrans() {
		return monthPeakTrans;
	}

	public void setMonthPeakTrans(String monthPeakTrans) {
		this.monthPeakTrans = monthPeakTrans;
	}

	public String getMonthTotalTrans() {
		return monthTotalTrans;
	}

	public void setMonthTotalTrans(String monthTotalTrans) {
		this.monthTotalTrans = monthTotalTrans;
	}

}
