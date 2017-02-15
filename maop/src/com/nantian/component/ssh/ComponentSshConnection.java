package com.nantian.component.ssh;

import java.io.IOException;
import java.net.ConnectException;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.List;

import com.nantian.component.com.ComponentException;
import com.nantian.component.com.ComponentProperties;
import com.nantian.component.log.Logger;

import ch.ethz.ssh2.Connection;
import ch.ethz.ssh2.ConnectionInfo;

/**
 * SSH连接类
 * @author dong
 */
public class ComponentSshConnection {

	/**
	 * Logger
	 */
	private static Logger logger = Logger.getLogger(ComponentSshConnection.class);

	/**
	 * SSH连接
	 */
	private Connection _connection = null;

	/**
	 * SSH连接信息
	 */
	private ConnectionInfo _info = null;

	/**
	 * 主机名
	 */
	private String _serverName;

	/**
	 * SSH用户
	 */
	private String _userId;

	/**
	 * 字符集
	 */
	private String _charsetName;

	/**
	 * 获取SSH连接
	 *
	 * @return SSH连接
	 */
	public final Connection getConnection() {
		return this._connection;
	}

	/**
	 * 获取SSH连接信息
	 *
	 * @return SSH连接信息
	 */
	public final ConnectionInfo getInfo() {
		return this._info;
	}

	/**
	 * 获取主机名
	 *
	 * @return 主机名
	 */
	public final String getServerName() {
		return this._serverName;
	}

	/**
	 * 获取SSH用户名
	 *
	 * @return SSH用户名
	 */
	public final String getUserId() {
		return this._userId;
	}

	/**
	 * 获取字符集
	 *
	 * @return 字符集
	 */
	public final String getCharsetName() {
		return this._charsetName;
	}


	/**
	 * 确定连接，登录主机 <BR>
	 * 登录主机后的目录: /home/(登录用户名)
	 *
	 * <UL><B>异常编码：异常原因</B>
	 * <LI>10000001：连接失败
	 * <LI>10000002：未知主机
	 * <LI>10000003：认证失败
	 * <LI>10000004：为指定主机名
	 * <LI>10000004：未指定SSH用户名
	 * <LI>10000004：未指定SSH用户的密码
	 * <LI>10009999：未知异常
	 * </UL>
	 *
	 * @param serverName 主机名或者IP地址
	 * @param userId SSH用户名
	 * @param password SSH密码
	 */
	public final void connect(final String serverName, final String userId, final String password) {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "connect");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "serverName;userId", serverName + ";" + userId);
		}

		if (serverName == null || serverName.trim().equals("")) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "主机名");
			}

			throw new ComponentException("未指定主机",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		if (userId == null || userId.trim().equals("")) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "SSH���[�U��");
			}

			throw new ComponentException("未指定SSH用户名",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		if (password == null || password.trim().equals("")) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "SSH用户的密码");
			}

			throw new ComponentException("未指定SSH用户的密码",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		this._serverName = serverName;
		this._userId = userId;

		// 取得charsetName
		this._charsetName = ComponentProperties.getSshCharsetName();

		if (this._connection == null) {
			// 建立连接
			this._connection = new Connection(serverName);
			if (logger.isDebugEnable()) {
				logger.debug("connection=" + this._connection);
			}

			// 登录主机
			try {
				// 获取连接信息
				this._info = this._connection.connect();

			} catch (IOException e) {
				if (e.getCause() instanceof UnknownHostException) {
					if (logger.isEnableFor("Component1002")) {
						logger.log("Component1002", e, serverName, userId, e.getMessage());
					}

					List<String> errorDetailList = createErrorDetailListForConnect(serverName, userId);
					throw new ComponentException("未知主机",
							ComponentSshConst.ERROR_UNKNOWN_HOST, errorDetailList, e);

				} else if (e.getCause() instanceof ConnectException) {
					if (logger.isEnableFor("Component1001")) {
						logger.log("Component1001", e, serverName, userId, e.getMessage());
					}

					List<String> errorDetailList = createErrorDetailListForConnect(serverName, userId);
					throw new ComponentException("连接失败",
							ComponentSshConst.ERROR_CONNECT, errorDetailList, e);

				} else {
					if (logger.isEnableFor("Component1999")) {
						logger.log("Component1999", e, e.getMessage(), 
													  "serverName;userId",
													  serverName + ";" + userId );
					}

					List<String> errorDetailList = createErrorDetailListForConnect(serverName, userId);
					throw new ComponentException("未知异常",
							ComponentSshConst.ERROR_UNKNOWN, errorDetailList, e);
				}
			}

			boolean result = false;
			try {
				result = this._connection.authenticateWithPassword(userId, password);

			} catch (IOException e) {
				if (logger.isEnableFor("Component1999")) {
					logger.log("Component1999", e, e.getMessage(),
												  "serverName;userId",
												  serverName + ";" + userId );
				}

				List<String> errorDetailList = createErrorDetailListForConnect(serverName, userId);
				throw new ComponentException("未知异常",
						ComponentSshConst.ERROR_UNKNOWN, errorDetailList, e);
			}

			if (!result) {
				disconnect();
				if (logger.isEnableFor("Component1003")) {
					logger.log("Component1003", serverName, userId);
				}

				List<String> errorDetailList = createErrorDetailListForConnect(serverName, userId);
				throw new ComponentException("认证失败",
						ComponentSshConst.ERROR_AUTHENTICATION, errorDetailList);
			}
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "connect");
		}
	}

	/**
	 * 输出详细异常信息
	 *
	 * @param serverName 主机名或者IP地址
	 * @param userId SSH用户名
	 * @return 详细异常列表
	 */
	private List<String> createErrorDetailListForConnect(final String serverName, final String userId) {

		List<String> errorDetailList = new ArrayList<String>();
		errorDetailList.add("serverName=" + serverName);
		errorDetailList.add("userId=" + userId);

		return errorDetailList;
	}

	/**
	 * 断开连接
	 */
	public final void disconnect() {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "disconnect");
		}

		if (this._connection != null) {
			this._connection.close();
			this._connection = null;
			this._info = null;
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "disconnect");
		}
	}
}
