package com.nantian.component.com;

import java.util.ArrayList;
import java.util.List;

/**
 * 共通异常类
 * <P>异常发生时，抛出异常
 * @author dong
 */
public class ComponentException extends RuntimeException {

	/** 异常编号 */
	private int _errorCode;

	/** 详细异常列表 */
	private List<String> _errorDetailList = new ArrayList<String>();

	/** serialVersionUID */
	private static final long serialVersionUID = 1L;


	/**
	 * 获取异常编号
	 * @return 异常编号
	 */
	public final int getErrorCode() {
		return this._errorCode;
	}

	/**
	 * 获取详细异常列表
	 * @return 详细异常列表
	 */
	public final List<String> getErrorDetail() {
		return this._errorDetailList;
	}

	/**
	 * 设定详细异常列表
	 * @param errorDetailList 异常列表
	 */
	public final void setErrorDetailList(final List<String> errorDetailList) {
		this._errorDetailList = errorDetailList;
	}

	/**
	 * 详细异常列表中追加异常信息
	 * @param errorDetail 详细异常信息
	 */
	public final void addErrorDetail(final String errorDetail) {
		if (this._errorDetailList != null) {
			this._errorDetailList.add(errorDetail);
		}
	}


	/**
	 * 获取异常信息
	 * @return 异常信息
	 */
	public final String getMessage() {
		String message = "[" + this._errorCode + "] " + super.getMessage();
		if (this._errorDetailList != null && this._errorDetailList.size() != 0) {
			message += ";" + this._errorDetailList.toString();
		}
		return message;
	}

	/**
	 * 构造函数
	 * @param message 异常信息
	 * @param errorCode 异常编号
	 */
	public ComponentException(final String message, final int errorCode) {

		super(message);
		this._errorCode = errorCode;
	}

	/**
	 * 构造函数
	 * @param message 异常信息
	 * @param errorCode 异常编号
	 * @param throwable Throwable
	 */
	public ComponentException(final String message, final int errorCode, final Throwable throwable) {

		super(message, throwable);
		this._errorCode = errorCode;
	}

	/**
	 * 构造函数
	 * @param message 异常信息
	 * @param errorCode 异常编号
	 * @param errorDetail 详细异常信息
	 */
	public ComponentException(final String message, final int errorCode, final List<String> errorDetail) {

		super(message);
		this._errorCode = errorCode;
		this._errorDetailList = errorDetail;
	}

	/**
	 * 构造函数
	 * @param message 异常信息
	 * @param errorCode 异常编号
	 * @param errorDetail 详细异常信息
	 * @param throwable Throwable
	 */
	public ComponentException(final String message, final int errorCode, final List<String> errorDetail,
			final Throwable throwable) {

		super(message, throwable);
		this._errorCode = errorCode;
		this._errorDetailList = errorDetail;
	}
}
