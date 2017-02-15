package com.nantian.rept.service;

import java.util.Date;

public interface ITransService {
	/**
	 * 查询昨天的交易量, 历史峰值, 阀值等
	 */
	public String queryTransData();
	/**
	 * 查询指定日期的交易量, 历史峰值, 阀值等
	 * @param date
	 * @return
	 */
	public String queryTransData(Date date);
}
