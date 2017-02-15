package com.nantian.component.com;

/**
 * 共通的timeout异常类
 * <P>抛出TIMEOUT异常
 * @author dong
 */
public class ComponentTimeOutException extends ComponentException {

	/** serialVersionUID */
	private static final long serialVersionUID = 1L;

	/**
	 * 构造函数
	 * @param message 异常信息
	 * @param errorCode 异常编码
	 * @param throwable Throwable
	 */
	public ComponentTimeOutException(String message, int errorCode, Throwable throwable) {
		super(message, errorCode, throwable);
	}
}
