package com.nantian.common.util;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

/**
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 * 
 */
public class DateFunction {
	
	/**
	 * 返回字符串形式的系统时刻
	 * <P>使用Calendar类，以yyyyMMddHHmmss格式返回系统时刻
	 * @return 字符串形式的系统时刻
	 */
	public static String getSystemTime() {
		Calendar cal = Calendar.getInstance();
		return new SimpleDateFormat("yyyyMMddHHmmss").format(cal.getTime());
	}
	/**
	 * 依据偏移量，返回字符串形式的系统时刻
	 * <P>使用Calendar类，以yyyyMMddHHmmss格式返回系统时刻
	 * @param offset
	 *            天数偏移量; 0表示当前,1表示下一天,-1表示上一天
	 * @return 字符串形式的系统时刻
	 */
	public static String getSystemTime(int offset) {
		Calendar cal = Calendar.getInstance();
		cal.add(Calendar.DAY_OF_MONTH, offset);
		return new SimpleDateFormat("yyyyMMddHHmmss").format(cal.getTime());
	}
	
	/**
	 * 返回字符串形式的系统时刻
	 * <P>使用Calendar类，以yyyyMMddHHmmssfff格式返回系统时刻
	 * @return 字符串形式的系统时刻
	 */
	public static String getSystemTimeMillSec() {
		Calendar cal = Calendar.getInstance();
		return new SimpleDateFormat("yyyyMMddHHmmssSSS").format(cal.getTime());
	}
	/**
	 * 依据偏移量，返回字符串形式的系统时刻
	 * <P>使用Calendar类，以yyyyMMddHHmmssfff格式返回系统时刻
	 * @param offset
	 *            天数偏移量; 0表示当前,1表示下一天,-1表示上一天
	 * @return 字符串形式的系统时刻
	 */
	public static String getSystemTimeMillSec(int offset) {
		Calendar cal = Calendar.getInstance();
		cal.add(Calendar.DAY_OF_MONTH, offset);
		return new SimpleDateFormat("yyyyMMddHHmmssSSS").format(cal.getTime());
	}

	/**
	 * 返回字符串形式的系统日期
	 * <P>使用Calendar类，以yyyyMMdd格式返回系统日期
	 * @return 字符串形式的系统日期
	 */
	public static String getSystemDate() {
		Calendar cal = Calendar.getInstance();
		return new SimpleDateFormat("yyyyMMdd").format(cal.getTime());
	}
	/**
	 * 依据偏移量，返回字符串形式的系统日期
	 * <P>使用Calendar类，以yyyyMMdd格式返回系统日期
	 * @param offset
	 *            天数偏移量; 0表示当前,1表示下一天,-1表示上一天
	 * @return 字符串形式的系统日期
	 */
	public static String getSystemDate(int offset) {
		Calendar cal = Calendar.getInstance();
		cal.add(Calendar.DAY_OF_MONTH, offset);
		return new SimpleDateFormat("yyyyMMdd").format(cal.getTime());
	}
	
	/**
	 * 依据所需格式返回字符串形式的系统时刻
	 * <P>使用Calendar类，按以下格式返回系统时刻
	 * @param 
	 *			0 	:	'yyyy-MM-dd',
	 *  		1  	:	'yyyy-MM-dd HH:mm:ss'
	 *  		2  	:	'yyyy-MM-dd HH:mm:ss.SSS'
	 *			3 	:	'yyyy/MM/dd',
	 *  		4  	:	'yyyy/MM/dd HH:mm:ss'
	 *  		5  	:	'yyyy/MM/dd HH:mm:ss.SSS'
	 * @return 字符串形式的系统时刻
	 */
	public static String getSystemTimeByFormat(int formatNum) {
		Calendar cal = Calendar.getInstance();
		String rtnTime = "";
		switch(formatNum){
			case 0:
				rtnTime =  new SimpleDateFormat("yyyy-MM-dd").format(cal.getTime());
				break;
			case 1:
				rtnTime =  new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(cal.getTime());
				break;
			case 2:
				rtnTime =  new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(cal.getTime());
				break;
			case 3:
				rtnTime =  new SimpleDateFormat("yyyy/MM/dd").format(cal.getTime());
				break;
			case 4:
				rtnTime =  new SimpleDateFormat("yyyy/MM/dd HH:mm:ss").format(cal.getTime());
				break;
			case 5:
				rtnTime =  new SimpleDateFormat("yyyy/MM/dd HH:mm:ss.SSS").format(cal.getTime());
				break;
		}
		return rtnTime;
	}
	
	/**
	 * 依据分钟偏移量，返回字符串形式的系统时刻
	 * <P>使用Calendar类，按以下格式返回系统时刻
	 * @param   baseTime	:	按以下格式的字符串(与formatNum一致)
	 *							'yyyy-MM-dd',
	 *  						'yyyy-MM-dd HH:mm:ss'
	 *  						'yyyy-MM-dd HH:mm:ss.SSS'
	 *							'yyyy/MM/dd',
	 *  						'yyyy/MM/dd HH:mm:ss'
	 *  						'yyyy/MM/dd HH:mm:ss.SSS'
	 * @param   formatNum
	 *			0 	:	'yyyy-MM-dd',
	 *  		1  	:	'yyyy-MM-dd HH:mm:ss'
	 *  		2  	:	'yyyy-MM-dd HH:mm:ss.SSS'
	 *			3 	:	'yyyy/MM/dd',
	 *  		4  	:	'yyyy/MM/dd HH:mm:ss'
	 *  		5  	:	'yyyy/MM/dd HH:mm:ss.SSS'
	 * @param   offset	:	分钟偏移量
	 * 			正数	：	未来的日期时刻
	 * 			负数	：	以前的日期时刻
	 * @return 字符串形式的系统时刻
	 */
	public static String getDateTimeByFormatAndOffset(String baseTime,int formatNum,int offset) {
		Calendar cal = Calendar.getInstance();
		SimpleDateFormat sdf = null;
		String rtnTime = "";
		switch(formatNum){
			case 0:
				sdf = new SimpleDateFormat("yyyy-MM-dd");
				cal = changeStrTimeToCalendar(baseTime,sdf);
				cal.add(Calendar.MINUTE, offset);
				rtnTime = sdf.format(cal.getTime());
				break;
			case 1:
				sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
				cal = changeStrTimeToCalendar(baseTime,sdf);
				cal.add(Calendar.MINUTE, offset);
				rtnTime = sdf.format(cal.getTime());
				break;
			case 2:
				sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
				cal = changeStrTimeToCalendar(baseTime,sdf);
				cal.add(Calendar.MINUTE, offset);
				rtnTime = sdf.format(cal.getTime());
				break;
			case 3:
				sdf = new SimpleDateFormat("yyyy/MM/dd");
				cal = changeStrTimeToCalendar(baseTime,sdf);
				cal.add(Calendar.MINUTE, offset);
				rtnTime = sdf.format(cal.getTime());
				break;
			case 4:
				sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
				cal = changeStrTimeToCalendar(baseTime,sdf);
				cal.add(Calendar.MINUTE, offset);
				rtnTime = sdf.format(cal.getTime());
				break;
			case 5:
				sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss.SSS");
				cal = changeStrTimeToCalendar(baseTime,sdf);
				cal.add(Calendar.MINUTE, offset);
				rtnTime = sdf.format(cal.getTime());
				break;
		}
		return rtnTime;
	}
	
	/**
	 * 依据日偏移量，返回字符串形式的系统日期
	 * <P>使用Calendar类，按以下格式返回系统日期
	 * @param   baseTime	:	按以下格式的字符串(与formatNum一致)
	 *							'yyyyMMdd',
	 *							'yyyy-MM-dd',
	 *							'yyyy/MM/dd',
	 * @param   formatNum
	 *			0 	:	'yyyyMMdd',
	 *			1 	:	'yyyy-MM-dd',
	 *			2 	:	'yyyy/MM/dd',
	 * @param   offset	:	日偏移量
	 * 			正数	：	未来的日期
	 * 			负数	：	以前的日期
	 * @return 字符串形式的系统日期
	 */
	public static String getDateByFormatAndOffset(String baseTime,int formatNum,int offset) {
		Calendar cal = Calendar.getInstance();
		SimpleDateFormat sdf = null;
		String rtnTime = "";
		switch(formatNum){
			case 0:
				sdf = new SimpleDateFormat("yyyyMMdd");
				cal = changeStrTimeToCalendar(baseTime,sdf);
				cal.add(Calendar.DAY_OF_MONTH, offset);
				rtnTime = sdf.format(cal.getTime());
			break;
			case 1:
				sdf = new SimpleDateFormat("yyyy-MM-dd");
				cal = changeStrTimeToCalendar(baseTime,sdf);
				cal.add(Calendar.DAY_OF_MONTH, offset);
				rtnTime = sdf.format(cal.getTime());
				break;
			case 2:
				sdf = new SimpleDateFormat("yyyy/MM/dd");
				cal = changeStrTimeToCalendar(baseTime,sdf);
				cal.add(Calendar.DAY_OF_MONTH, offset);
				rtnTime = sdf.format(cal.getTime());
				break;
		}
		return rtnTime;
	}
	
	/**
	 * 依据月偏移量，返回字符串形式的系统日期
	 * <P>使用Calendar类，按以下格式返回系统日期
	 * @param   baseTime	:	按以下格式的字符串(与formatNum一致)
	 *							'yyyyMMdd',
	 *							'yyyy-MM-dd',
	 *							'yyyy/MM/dd',
	 * @param   formatNum
	 *			0 	:	'yyyyMMdd',
	 *			1 	:	'yyyy-MM-dd',
	 *			2 	:	'yyyy/MM/dd',
	 * @param   offset	:	月偏移量
	 * 			正数	：	未来的日期
	 * 			负数	：	以前的日期
	 * @return 字符串形式的系统日期
	 */
	public static String getDateMonthByFormatAndOffset(String baseTime,int formatNum,int offset) {
		Calendar cal = Calendar.getInstance();
		SimpleDateFormat sdf = null;
		String rtnTime = "";
		switch(formatNum){
			case 0:
				sdf = new SimpleDateFormat("yyyyMMdd");
				cal = changeStrTimeToCalendar(baseTime,sdf);
				cal.add(Calendar.MONTH, offset);
				rtnTime = sdf.format(cal.getTime());
			break;
			case 1:
				sdf = new SimpleDateFormat("yyyy-MM-dd");
				cal = changeStrTimeToCalendar(baseTime,sdf);
				cal.add(Calendar.MONTH, offset);
				rtnTime = sdf.format(cal.getTime());
				break;
			case 2:
				sdf = new SimpleDateFormat("yyyy/MM/dd");
				cal = changeStrTimeToCalendar(baseTime,sdf);
				cal.add(Calendar.MONTH, offset);
				rtnTime = sdf.format(cal.getTime());
				break;
		}
		return rtnTime;
	}
	
	
	public static Calendar changeStrTimeToCalendar(String baseTime,SimpleDateFormat sdf){
		Calendar cal = Calendar.getInstance();
		Date d = null;
		try {
			d = sdf.parse(baseTime);
			cal.setTime(d);
		} catch (ParseException e) {
			System.out.println("changeStrTimeToCalendar error");
			e.printStackTrace();
		}
		return cal;
	}
	
	/**
	 * 按指定格式返回字符串形式的时间
	 * <P>
	 * @param   baseTime	:	Date类型的时间
	 * @param   formatNum
	 *			0 	:	'yyyy-MM-dd',
	 *  		1  	:	'yyyy-MM-dd HH:mm:ss'
	 *  		2  	:	'yyyy-MM-dd HH:mm:ss.SSS'
	 *			3 	:	'yyyy/MM/dd',
	 *  		4  	:	'yyyy/MM/dd HH:mm:ss'
	 *  		5  	:	'yyyy/MM/dd HH:mm:ss.SSS'
	 * @return 字符串形式的时间
	 */
	public static String convertDateToStr(Date baseTime,int formatNum){
		SimpleDateFormat sdf;
		String rtnTime="";
		switch(formatNum){
		case 0:
			sdf = new SimpleDateFormat("yyyy-MM-dd");
			rtnTime = sdf.format(baseTime);
			break;
		case 1:
			sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			rtnTime = sdf.format(baseTime);
			break;
		case 2:
			sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
			rtnTime = sdf.format(baseTime);
			break;
		case 3:
			sdf = new SimpleDateFormat("yyyy/MM/dd");
			rtnTime = sdf.format(baseTime);
			break;
		case 4:
			sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
			rtnTime = sdf.format(baseTime);
			break;
		case 5:
			sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss.SSS");
			rtnTime = sdf.format(baseTime);
			break;
		case 6:
			sdf = new SimpleDateFormat("yyyyMMdd");
			rtnTime = sdf.format(baseTime);
			break;
		case 7:
			sdf = new SimpleDateFormat("yyyy-MM-ddTHH:mm:ss");
			rtnTime = sdf.format(baseTime);
			break;
		}
		return rtnTime;
	}
	
	/**
	 * 依据日期的格式参数，返回DATE形式的时间
	 * <P>
	 * @param   baseTime	:	字符串类型的时间
	 * @param   formatNum
	 *			0 	:	'yyyy-MM-dd',
	 *  		1  	:	'yyyy-MM-dd HH:mm:ss'
	 *  		2  	:	'yyyy-MM-dd HH:mm:ss.SSS'
	 *			3 	:	'yyyy/MM/dd',
	 *  		4  	:	'yyyy/MM/dd HH:mm:ss'
	 *  		5  	:	'yyyy/MM/dd HH:mm:ss.SSS'
	 * @return DATE形式的时间
	 */
	public static Date convertStrToDate(String baseTime,int formatNum){
		SimpleDateFormat sdf;
		Date date = null;
		try {
			switch(formatNum){
			case 0:
				sdf = new SimpleDateFormat("yyyy-MM-dd");
					date = sdf.parse(baseTime);
				break;
			case 1:
				sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
				date = sdf.parse(baseTime);
				break;
			case 2:
				sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
				date = sdf.parse(baseTime);
				break;
			case 3:
				sdf = new SimpleDateFormat("yyyy/MM/dd");
				date = sdf.parse(baseTime);
				break;
			case 4:
				sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
				date = sdf.parse(baseTime);
				break;
			case 5:
				sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss.SSS");
				date = sdf.parse(baseTime);
				break;
			case 6:
				sdf = new SimpleDateFormat("yyyyMMdd");
				date = sdf.parse(baseTime);
				break;
			case 7:
				sdf = new SimpleDateFormat("yyyy-MM-ddTHH:mm:ss");
				date = sdf.parse(baseTime);
				break;
			}
		} catch (ParseException e) {
			System.out.println("convertStrToDate error");
			e.printStackTrace();
		}
		return date;
	}
	
	/**
	 * 判断数字是否为日期
	 * @param str 待判断的字符串
	 * @return true/false
	 */
	public static boolean isDate(String numStr){
		try {
			SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
			//设置成false，否则SimpleDateFormat会比较宽松的验证日期，比如12345678，会被认可为日期
			sdf.setLenient(false);
			sdf.parse(numStr);
			
		} catch (Exception e) {
			return false;
		}
		return true;
	}
	
	/**
	 * 判断日期为星期几
	 * @param dateStr 待判断的日期
	 * @return 星期几
	 */
	public static String getWeekOfDate(String dateStr){
		String[] weekDays = {"星期日","星期一","星期二","星期三","星期四","星期五","星期六"};
		Calendar cal2 = Calendar.getInstance();
		SimpleDateFormat sdf2 = null;
		sdf2 = new SimpleDateFormat("yyyyMMdd");
		Date d2 = null;
		int w = 0;
		try {
			d2 = sdf2.parse(dateStr);
			cal2.setTime(d2);
			w = cal2.get(Calendar.DAY_OF_WEEK) -1;
			if (w < 0) w = 0;
		} catch (ParseException e) {
			e.printStackTrace();
		}
		
		return weekDays[w];
	}
	
	/**
	 * 将日期类型转化成对应格式的时间字符串
	 * @param date 日期
	 * @param pattern 格式 例如"yyyy-MM-dd"
	 * @return String 格式化后的时间字符串
	 */
	public static String getFormatDateStr(Date date, String pattern) {
		SimpleDateFormat sdf = new SimpleDateFormat(pattern);
		return sdf.format(date);
	}
	
	/**
	 * 将日期类型转化成对应格式的时间字符串
	 * @param date 日期
	 * @param pattern 格式 例如"yyyy-MM-dd"
	 * @return String 格式化后的时间字符串
	 * @throws ParseException 
	 */
	public static Date convertStr2Date(String date, String pattern) throws ParseException {
		SimpleDateFormat sdf = new SimpleDateFormat(pattern);
		return sdf.parse(date);
	}
	
	/**
	 * 将日期字符串转化成对应格式的时间字符串
	 * @param date 时间字符串
	 * @param oldPattern 原来的格式 例如"yyyy-MM-dd"
	 * @param newPattern 要转成的格式 例如"yyyy-MM-dd"
	 * @return String 格式化后的时间字符串
	 */
	public static String getFormatDateStr(String date, String oldPattern, String newPattern){
		Date dt = null;
		SimpleDateFormat sdf = new SimpleDateFormat(oldPattern);
		SimpleDateFormat newFormat = new SimpleDateFormat(newPattern);
		
		try {
			dt = sdf.parse(date);
		} catch (ParseException e) {
			return "";
		}
		
		return newFormat.format(dt);
		
	}
	
	public static String getNewFormatDateStr(String date, String oldFormat, String newFormat){
		SimpleDateFormat oldSdf = new SimpleDateFormat(oldFormat);
		SimpleDateFormat newSdf = new SimpleDateFormat(newFormat);
		String result = "";
		try {
			Date newDate = oldSdf.parse(date);
			result = newSdf.format(newDate);
		} catch (ParseException e) {
			e.printStackTrace();
		}
		
		return result;
	}
	
	/**
	 * 返回两个日期的相差的天数
	 * @param early
	 * @param late
	 * @return
	 */
	public static final int daysBetween(Date early, Date late){
		Calendar calst = Calendar.getInstance();
		Calendar caled = Calendar.getInstance();
		calst.setTime(early);
		caled.setTime(late);
		calst.set(Calendar.HOUR_OF_DAY, 0);
		calst.set(Calendar.MINUTE, 0);
		calst.set(Calendar.SECOND, 0);
		caled.set(Calendar.HOUR_OF_DAY, 0);
		caled.set(Calendar.MINUTE, 0);
		caled.set(Calendar.SECOND, 0);
		int days = ((int)(caled.getTime().getTime() / 1000) - (int)(calst.getTime().getTime() / 1000)) / 3600 /24;
		return days;
	}
}///~:
