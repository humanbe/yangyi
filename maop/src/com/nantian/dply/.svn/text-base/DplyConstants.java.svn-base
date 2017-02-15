/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.dply;


/**
 * @author <a href="mailto:@nantian.com.cn"></a>
 * 
 */
public class DplyConstants {
	/**BAS参数类路径前缀*/
	public static final String PARAMSMETER_CLASS_PREFIX = "Class://SystemObject/CLASS_";
	public static final String PARAMSMETER_SERVER_PREFIX ="Class://SystemObject/Server";
	/**请求状态列表*/
	public static enum requestStateItem {
		created,planned,started,problem,hold,cancelled,complete,deleted;
		public static String getRequestStateNum(String item){
			for (int i=0; i < requestStateItem.values().length; i++ ) {
				if(requestStateItem.values()[i].name().equals(item)){
					return String.valueOf(i+1);
				}
			}
			return "o";
		}
		
		public static requestStateItem getRequestState(String item){
			for (int i=0; i < requestStateItem.values().length; i++ ) {
				if(requestStateItem.values()[i].name().equals(item)){
					return requestStateItem.values()[i];
				}
			}
			return null;
		}
	}	
	/**步骤状态列表*/
	public static enum stepStateItem {
		locked, ready, in_process, blocked, problem,being_resolved,complete;
		public static String getStepStateNum(String item){
			for (int i=0; i < stepStateItem.values().length; i++ ) {
				if(stepStateItem.values()[i].name().equals(item)){
					return String.valueOf(i+1);
				}
			}
			return "o";
		}
		
		public static stepStateItem getStepState(String item){
			for (int i=0; i < stepStateItem.values().length; i++ ) {
				if(stepStateItem.values()[i].name().equals(item)){
					return stepStateItem.values()[i];
				}
			}
			return null;
		}
	}	
}