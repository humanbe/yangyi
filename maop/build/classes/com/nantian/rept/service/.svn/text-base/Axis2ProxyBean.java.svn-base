package com.nantian.rept.service;

import java.sql.SQLException;
import java.util.Date;

import org.springframework.beans.factory.annotation.Autowired;

/**
 * Axis2事务处理代理类
 * @author user
 *
 */
public class Axis2ProxyBean  {
	@Autowired
	private ITransService transService;
	
	public String queryTransData() throws SQLException {
		return transService.queryTransData();
	}
	
	public String queryTransData(Date date) throws SQLException {
		return transService.queryTransData(date);
	}
}
