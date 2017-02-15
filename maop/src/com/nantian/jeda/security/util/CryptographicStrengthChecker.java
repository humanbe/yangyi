/**
 * 
 */
package com.nantian.jeda.security.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.nantian.jeda.config.service.ConsoleService;

/**
 * 密码强度检查工具.
 * 
 * @author daizhenzhong
 * 
 */
public class CryptographicStrengthChecker {

	private final static Logger logger = LoggerFactory.getLogger(ConsoleService.class);

	public static final int MIN_LENGTH = 6;// 最小长度

	public static final int MAX_LENGTH = 10;// 最大长度

	public static boolean check(String password) {

		if (password.contains(" ")) {// 空格校验
			logger.debug("密码字符中不允许含有空格!");
			return false;
		} else if (password.length() < MIN_LENGTH || password.length() > MAX_LENGTH) {// 长度校验
			logger.debug("密码字符长度必须在" + MIN_LENGTH + "到" + MAX_LENGTH + "之间!");
			return false;
		}
		return true;
	}

	public static void main(String[] args) {
		CryptographicStrengthChecker.check("12 3");
	}
}
