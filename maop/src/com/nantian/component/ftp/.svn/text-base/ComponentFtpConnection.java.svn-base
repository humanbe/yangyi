package com.nantian.component.ftp;

import java.io.IOException;
import java.net.ConnectException;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.net.ftp.FTPClient;
import org.apache.commons.net.ftp.FTPClientConfig;
import org.apache.commons.net.ftp.FTPReply;

import com.nantian.component.com.ComponentException;
import com.nantian.component.com.FtpCmpException;
import com.nantian.component.log.Logger;

/**
 * FTP连接Class
 * @author dong
 */
public class ComponentFtpConnection {

	/**
	 * Logger
	 */
	private static Logger logger = Logger.getLogger(ComponentFtpConnection.class);

	/**
	 * FTPClient
	 */
	private FTPClient _ftpclient = null;

	/**
	 * 主机名或者IP地址ַ
	 */
	private String _host;

	/**
	 * 端口号
	 */
	private int _port;

	/**
	 * 用户名
	 */
	private String _user;

	/**
	 * 获取FTPClient
	 *
	 * @return FTPClient
	 */
	public final FTPClient getConnection() {
		return this._ftpclient;
	}

	/**
	 * 获取主机名或者IP地址ַ
	 *
	 * @return 主机名或者IP地址ַ
	 */
	public final String getHost() {
		return this._host;
	}

	/**
	 * 获取端口号
	 *
	 * @return 端口号
	 */
	public final int getPort() {
		return this._port;
	}

	/**
	 * 获取用户名
	 *
	 * @return 用户名
	 */
	public final String getUser() {
		return this._user;
	}

	/**
	 * FTP连接主机
	 *
	 * <UL><B>异常No：异常内容</B>
	 * <LI>30000001：主机连接失败
	 * <LI>30000002：未知主机
	 * <LI>30000003：返回错误的应答码
	 * <LI>30000004：认证失败
	 * <LI>30000005：未指定主机名
	 * <LI>30000005：未指定用户名
	 * <LI>30000005：未指定密码
	 * <LI>30009999：发生
	 * </UL>
	 *
	 * @param host 主机名或者IP地址ַ
	 * @param port 端口号
	 * @param user 用户名
	 * @param password 密码
	 */
	public final void connect(final String host, final int port, final String user,
			final String password) {

		// 输出开始日志־
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "connect");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "host;port;user", host + ";" + port + ";" + user);
		}

		if (host == null || host.trim().equals("")) {
			if (logger.isEnableFor("Component3005")) {
				logger.log("Component3005", "主机名");
			}
			throw new ComponentException("未指定主机名",
				ComponentFtpConst.ERROR_INVALID_PARAMETER);
		}

		if (user == null || user.trim().equals("")) {
			if (logger.isEnableFor("Component3005")) {
				logger.log("Component3005", "用户名");
			}
			throw new ComponentException("未指定用户名",
				ComponentFtpConst.ERROR_INVALID_PARAMETER);
		}

		if (password == null || password.trim().equals("")) {
			if (logger.isEnableFor("Component3005")) {
				logger.log("Component3005", "密码");
			}
			throw new ComponentException("未指定密码",
				ComponentFtpConst.ERROR_INVALID_PARAMETER);
		}

		this._host = host;
		this._port = port;
		this._user = user;

		if (this._ftpclient == null) {
			this._ftpclient = new FTPClient();
			try {
				// 连接
				this._ftpclient.connect(host, port);
				
			/*	this._ftpclient.setControlEncoding("GBK");
				FTPClientConfig conf=new FTPClientConfig(FTPClientConfig.SYST_NT);
				conf.setServerLanguageCode("zh");*/
				
				int reply = this._ftpclient.getReplyCode();
				if (!FTPReply.isPositiveCompletion(reply)) {
					if (logger.isEnableFor("Component3003")) {
						logger.log("Component3003", reply);
					}

					List<String> errorDetailList = createErrorDetailList(host, port, user, reply);
					throw new ComponentException("返回错误的应答码",
							ComponentFtpConst.ERROR_REPLY_CODE, errorDetailList);
				}

				if (!this._ftpclient.login(user, password)) {
					if (logger.isEnableFor("Component3004")) {
						logger.log("Component3004", host, user);
					}

					List<String> errorDetailList = createErrorDetailList(host, port, user, null);
					throw new FtpCmpException("认证失败",
							ComponentFtpConst.ERROR_AUTHENTICATION, errorDetailList);
				}

			} catch (UnknownHostException e) {
				if (logger.isEnableFor("Component3001")) {
					logger.log("Component3001", e, host, user, e.toString());
				}

				List<String> errorDetailList = createErrorDetailList(host, port, user, null);
				throw new ComponentException("未知主机",
						ComponentFtpConst.ERROR_UNKNOWN_HOST, errorDetailList, e);

			} catch (ConnectException e) {
				if (logger.isEnableFor("Component3002")) {
					logger.log("Component3002", e, host, user, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailList(host, port, user, null);
				throw new FtpCmpException("连接失败",
						ComponentFtpConst.ERROR_CONNECT, errorDetailList, e);

			} catch (IOException e) {
				if (logger.isEnableFor("Component3999")) {
					logger.log("Component3999", e, e.getMessage(), 
												  "host;port;user",
												  host + ";" + port + ";" + user);
				}

				List<String> errorDetailList = createErrorDetailList(host, port, user, null);
				throw new ComponentException("发生未知异常",
						ComponentFtpConst.ERROR_UNKNOWN, errorDetailList, e);
			}
		}

		// 输出结束日志־
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "connect");
		}
	}

	/**
	 * 编辑详细异常信息
	 *
	 * @param host 主机名或者IP地址
	 * @param port 端口号
	 * @param user 用户名
	 * @param reply 应答码
	 * @return 详细异常列表
	 */
	private List<String> createErrorDetailList(final String host, final int port, final String user, final Integer reply) {

		List<String> errorDetailList = new ArrayList<String>();
		errorDetailList.add("host=" + host);
		errorDetailList.add("port=" + port);
		errorDetailList.add("user=" + user);
		if (reply != null) {
			errorDetailList.add("reply=" + reply);
		}

		return errorDetailList;
	}

	/**
	 * 断开FTP连接
	 */
	public final void disconnect() {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "disconnect");
		}

		try {
			if (this._ftpclient != null) {
				this._ftpclient.disconnect();
				this._ftpclient = null;
			}

		} catch (Exception e) {
			if (logger.isEnableFor("Component3998")) {
				logger.log("Component3998", e, e.getMessage());
			}
			List<String> errorDetailList = createErrorDetailList(this._host, this._port, this._user, null);
			throw new ComponentException("发生未知异常",
					ComponentFtpConst.ERROR_UNKNOWN, errorDetailList, e);
		}
		
		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "disconnect");
		}
	}
}
