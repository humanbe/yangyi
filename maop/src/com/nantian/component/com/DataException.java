package com.nantian.component.com;

import java.util.List;

public class DataException extends ComponentException{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	/**
	 * 构造函数
	 * @param message 异常信息
	 * @param errorCode 异常编号
	 */
	public DataException(final String message, final int errorCode) {

		super(message, errorCode);
	}

	/**
	 * 构造函数
	 * @param message 异常信息
	 * @param errorCode 异常编号
	 * @param throwable Throwable
	 */
	public DataException(final String message, final int errorCode, final Throwable throwable) {

		super(message, errorCode, throwable);
	}

	/**
	 * 构造函数
	 * @param message 异常信息
	 * @param errorCode 异常编号
	 * @param errorDetail 详细异常信息
	 */
	public DataException(final String message, final int errorCode, final List<String> errorDetail) {

		super(message, errorCode, errorDetail);
	}

	/**
	 * 构造函数
	 * @param message 异常信息
	 * @param errorCode 异常编号
	 * @param errorDetail 详细异常信息
	 * @param throwable Throwable
	 */
	public DataException(final String message, final int errorCode, final List<String> errorDetail,
			final Throwable throwable) {
		super(message, errorCode, errorDetail, throwable);
	}
	
}
