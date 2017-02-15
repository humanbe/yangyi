package com.nantian.common.util;

import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.StringTokenizer;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;

import com.nantian.rept.ReptConstants;

/**
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 * 
 */
public class NumberUtil {
	
    /** 格式化样式 (###,###.##)
     * ‘#’该位不存在则不显示
     */
	public static final String FORMAT_PATTERN_1 = "###,###.##";
	
    /** 格式化样式 (###,###.###)
     * ‘#’该位不存在则不显示
     */
	public static final String FORMAT_PATTERN_10 = "###,###.###";
	
    /** 格式化样式 (###,###.####)
     * ‘#’该位不存在则不显示
     */
	public static final String FORMAT_PATTERN_11 = "###,###.####";
	
    /** 格式化样式 (#.######)
     * ‘#’该位不存在则不显示
     */
	public static final String FORMAT_PATTERN_12 = "#.######";
	
    /** 格式化样式 (#.##)
     * ‘#’该位不存在则不显示
     */
	public static final String FORMAT_PATTERN_13 = "#.##";
	
    /** 格式化样式 (000,000.000)
    * '0'该位不存在显示0
    */
	public static final String FORMAT_PATTERN_2 = "000,000.00";
    /** 格式化样式  (###,###.##￥)
     * ‘#’该位不存在则不显示
     **/
	public static final String FORMAT_PATTERN_3 = "###,###.##￥";
    /** 格式化样式  (000,000.0000￥) 
     * ‘'0'该位不存在显示0
     */
	public static final String FORMAT_PATTERN_4 = "000,000.00￥";
	
	/** 格式化样式  (##.##%) 
	 * ‘#’该位不存在则不显示;'%'乘以100并显示为百分数
	 */
	public static final String FORMAT_PATTERN_5 = "##.##%";
	
    /** 格式化样式  (##.###%) 
     * ‘#’该位不存在则不显示;'%'乘以100并显示为百分数
     */
	public static final String FORMAT_PATTERN_6 = "##.###%";
	
    /** 格式化样式  (##.####%) 
     * ‘#’该位不存在则不显示;'%'乘以100并显示为百分数
     */
	public static final String FORMAT_PATTERN_60 = "##.####%";
	
	/** 格式化样式  (00.###%) 
	 * ‘#’该位不存在则不显示;'0'该位不存在显示0;'%'乘以100并显示为百分数
	 */
	public static final String FORMAT_PATTERN_7 = "00.##%";
	
    /** 格式化样式  (00.###%) 
     * ‘#’该位不存在则不显示;'0'该位不存在显示0;'%'乘以100并显示为百分数
     */
	public static final String FORMAT_PATTERN_8 = "00.###%";
	
    /** 格式化样式  (##.###\u2030) 
     * ‘#’该位不存在则不显示;'\u2030'乘以100并显示为千分数
     */
	public static final String FORMAT_PATTERN_9 = "##.###\u2030";
	
	/**
	 * 格式化数字
	 * @param val 数值
	 * @param pattern 格式化样式（‘#’该位不存在则不显示;'0'该位不存在显示0;'%'乘以100并显示为百分数;'\u2030'乘以100并显示为千分数）
	 * @return 格式化后数值
	 */
	public static String format(double val, String pattern){
		DecimalFormat df = null;
		df = new DecimalFormat(pattern);
		
		return df.format(val);
		
	}
	
	/**
	 * 格式化数值
	 * @param val 数值
	 * @param 单位
	 * @return 格式化后数值
	 */
	public static String formatNumByUnit(String val, String unit){
		double rtnVal = 0;
		if(null != val && !"".equals(val)){
			switch(ReptConstants.yUnitEnum.getYUnitEnum(unit)){
			case 百: 
				rtnVal = Double.parseDouble(val) * 100;
				break;
			case 千: 
				rtnVal = Double.parseDouble(val) * 1000;
				break;
			case 万: 
				rtnVal = Double.parseDouble(val) * 10000;
				break;
			case 十万: 
				rtnVal = Double.parseDouble(val) * 100000;
				break;
			case 百万: 
				rtnVal = Double.parseDouble(val) * 1000000;
				break;
			default : 
				rtnVal = Double.parseDouble(val);
				break;
			}
			return String.valueOf(rtnVal);
		}else{
			return null;
		}
	}
	
	
	/**
	 * 正则表达式判断字符串是否为数字
	 * @param str 待判断的字符串
	 * @return true/false
	 */
	public static boolean isNumeric(String str){
		String reg = "^[-+]?(([0-9]+)([.]([0-9]+))?|([.]([0-9]+))?)$";
		return str.matches(reg);
	}
	
	/**
	 * 拆分计算式
	 * @param str 待拆分的字符串
	 * @return 拆分后的数组
	 */
	public static List<String> splitRegex(String str){
		//String[] sa = str.split("\\b");
		StringTokenizer st = new StringTokenizer(str,"+,-,*,/,(,（,）,)",false);
		List<String> items = new ArrayList<String>();
		while(st.hasMoreElements()){
			items.add(st.nextElement().toString());
		}
		st = null;
		return items;
	}
	
	/**
	 * 根据计算表达式参数进行计算
	 * @param expression 例如："(3+4)*5+2*3"
	 * @throws 
	 */
	public static String eval(String expression) throws Exception{
		
		ScriptEngineManager manager = new ScriptEngineManager();
		ScriptEngine engine = manager.getEngineByName("js");
		Object result = null;
		try {
			result = engine.eval(expression);
		} catch (ScriptException e) {
			e.printStackTrace();
			throw e;
		}
		if("NaN".equals(result.toString()) || ("Infinity").equals(result.toString())){
			//分母为0的返回值
			return "0";
		}else{
			return result.toString();
		}
	}
	
	/**
	 * 求最大值
	 * @param arr 数值列表
	 * @throws 
	 */
	public static double getMaxValue(List<Double> list){
		double maxVal = list.get(0);
		for (double i : list) {
			if(i>maxVal){
				maxVal = i;
			}
		}
		return maxVal;
	}
	/**
	 * 求最小值
	 * @param arr 数值列表
	 * @throws 
	 */
	public static double getMinValue(List<Double> list){
		double minVal = list.get(0);
		for (double i : list) {
			if(i<minVal){
				minVal = i;
			}
		}
		return minVal;
	}
	/**
	 * 求平均值
	 * @param arr 数值列表
	 * @throws 
	 */
	public static double getAvgValue(List<Double> list){
		double sumVal=0;
		for (double i : list) {
			sumVal += i;
		}
		return sumVal/list.size();
	}
	/**
	 * 求合计值
	 * @param arr 数值列表
	 * @throws 
	 */
	public static double getSumValue(List<Double> list){
		double sumVal=0;
		for (double i : list) {
			sumVal += i;
		}
		return sumVal;
	}
	
	
}///:~
