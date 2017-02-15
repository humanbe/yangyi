package com.nantian.component.com;

import java.text.SimpleDateFormat;
import java.util.Calendar;


/**
 * 日期共通类
 * @author dong
 *
 */
public class ComponentDateFunc {

	/**
	 * 返回字符串类型的系统时刻
	 * <P>利用Calendar类，返回字符串类型【yyyyMMddHHmmss】的系统时刻
	 * @return 字符串类型的系统时刻
	 */
	public static String getSystemTime() {
		Calendar cal = Calendar.getInstance();
		return new SimpleDateFormat("yyyyMMddHHmmss").format(cal.getTime());
	}

	/**
	 * 返回字符串类型的系统时刻（带毫秒）
	 * <P>利用Calendar类，返回字符串类型【yyyyMMddHHmmssfff】的系统时刻
	 * @return 字符串类型的系统时刻（带毫秒）
	 */
	public static String getSystemTimeMillSec() {
		Calendar cal = Calendar.getInstance();
		return new SimpleDateFormat("yyyyMMddHHmmssSSS").format(cal.getTime());
	}

	/**
	 * 返回字符串类型的系统日期
	 * <P>利用Calendar类，返回字符串类型【yyyyMMdd】的系统日期
	 * @return 字符串类型的系统日期
	 */
	public static String getSystemDate() {
		Calendar cal = Calendar.getInstance();
		return new SimpleDateFormat("yyyyMMdd").format(cal.getTime());
	}
}
