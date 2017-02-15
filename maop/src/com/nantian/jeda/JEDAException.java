/**
 * Copyright 2010 Beijing Nantian Software Co.,Ltd.
 */
package com.nantian.jeda;

/**
 * @author daizhenzhong
 * 
 */
public class JEDAException extends Exception {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * 
	 */
	public JEDAException() {
		super();
	}

	/**
	 * @param message
	 * @param cause
	 */
	public JEDAException(String message, Throwable cause) {
		super(message, cause);
	}

	/**
	 * @param message
	 */
	public JEDAException(String message) {
		super(message);
	}

	/**
	 * @param cause
	 */
	public JEDAException(Throwable cause) {
		super(cause);
	}

}
