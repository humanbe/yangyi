package com.nantian.component.svn;

import java.util.ArrayList;
import java.util.List;

import org.tmatesoft.svn.core.SVNException;
import org.tmatesoft.svn.core.SVNURL;
import org.tmatesoft.svn.core.auth.ISVNAuthenticationManager;
import org.tmatesoft.svn.core.internal.io.dav.DAVRepositoryFactory;
import org.tmatesoft.svn.core.internal.io.fs.FSRepositoryFactory;
import org.tmatesoft.svn.core.internal.io.svn.SVNRepositoryFactoryImpl;
import org.tmatesoft.svn.core.io.SVNRepository;
import org.tmatesoft.svn.core.io.SVNRepositoryFactory;
import org.tmatesoft.svn.core.wc.SVNWCUtil;

import com.nantian.component.com.ComponentConst;
import com.nantian.component.com.ComponentException;
import com.nantian.component.com.ComponentProperties;
import com.nantian.component.log.Logger;

/**
 * SVN连接类
 * @author dong
 */
public class ComponentSvnConnection {

	/**
	 * Logger
	 */
	private static Logger logger =  Logger.getLogger(ComponentSvnConnection.class);

	/**
	 * 认证对象
	 */
	private ISVNAuthenticationManager _authenticationManager;

	/**
	 * 版本库
	 */
	private SVNRepository _repository = null;

	/**
	 * 用户名
	 */
	private String _username = null;


	/**
	 * 获取认证对象
	 *
	 * @return 认证对象
	 */
	public final ISVNAuthenticationManager getISVNAuthenticationManager() {
		return this._authenticationManager;
	}

	/**
	 * 获取版本库对象
	 *
	 * @return 版本库对象
	 */
	public final SVNRepository getRepository() {
		return this._repository;
	}

	/**
	 * 获取用户名
	 *
	 * @return 用户名
	 */
	public final String getUsername() {
		return this._username;
	}

	/**
	 * 获取版本库的URL
	 *
	 * @return 版本库的URL
	 */
	public final String getRootUrl() {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getRootUrl");
		}

		String rootUrl = null;
		if (this._repository != null) {
			rootUrl = this._repository.getLocation().toDecodedString();
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "getRootUrl");
		}

		return rootUrl;
	}

	/**
	 * Subversion连接方法
	 *
	 * <UL><B>异常No：异常内容</B>
	 * <LI>20000003：未指定连接用的URL
	 * <LI>20000052：资源文件中未设定用户名
	 * <LI>20000052：资源文件中未设定连接密码
	 * <LI>20009999：未知异常
	 * </UL>
	 *
	 * @param url URL地址（指定server名或者ip地址）
	 */
	public final void connect(final String url) {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "connect");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "url", url);
		}

		// 根据设定资源获取用户名和密码
		String svnUsername = ComponentProperties.getSvnUsername();
		String svnPassword = ComponentProperties.getSvnPassword();

		if (svnUsername == null || svnUsername.trim().equals("")) {
			if (logger.isEnableFor("Component0005")) {
				logger.log("Component0005",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						"svn.userName");
			}
			throw new ComponentException("未设定用户名",
				ComponentSvnConst.ERROR_INVALID_PROPERTIES);
		}
		if (svnPassword == null || svnPassword.trim().equals("")) {
			if (logger.isEnableFor("Component0005")) {
				logger.log("Component0005",
						ComponentConst.Component_PROPERTIES_FILE_NAME,
						"svn.passWord");
			}
			throw new ComponentException("未设定连接密码",
				ComponentSvnConst.ERROR_INVALID_PROPERTIES);
		}

		connect(url, svnUsername, svnPassword);

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "connect");
		}
	}

	/**
	 * Subversion连接方法
	 *
	 * <UL><B>>异常No：异常内容</B>
	 * <LI>20000003：未指定连接用的URL
	 * <LI>20000003：未指定连接用密码
	 * <LI>20009999：未知异常
	 * </UL>
	 *
	 * @param url URL地址（指定server名或者ip地址）
	 * @param username 用户名
	 * @param password 密码
	 */
	public final void connect(final String url, final String username, final String password) {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "connect(final String, final String, final String)");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "url;username", url + ";" + username);
		}

		if (url == null || url.trim().equals("")) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "URL");
			}
			throw new ComponentException("未指定URL",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}

		if (username != null && (password == null || password.trim().equals(""))) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "连接密码");
			}
			throw new ComponentException("未指定连接密码",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}

		this._username = username;

		if (this._repository == null) {
			// Subversion初始化
			DAVRepositoryFactory.setup();
			SVNRepositoryFactoryImpl.setup();
			FSRepositoryFactory.setup();

			this._repository = prepareSVNRepository(url, username, password);
			if (logger.isDebugEnable()) {
				logger.debug("repository path = " + this._repository.getLocation().toDecodedString());
			}
		}


		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "connect(final String, final String, final String)");
		}
	}

	/**
	 * 新建版本库
	 *
	 * <UL><B>异常No：异常内容</B>
	 * <LI>20009999：未知异常
	 * </UL>
	 *
	 * @param url 连接URL（server名或者IP地址）
	 * @param username 用户名
	 * @param password 密码
	 * @return 版本库对象
	 */
	private SVNRepository prepareSVNRepository(final String url,
			final String username, final String password) {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "prepareSVNRepository");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "url;username", url + ";" + username);
		}

		SVNRepository repository = null;
		try {
			repository = SVNRepositoryFactory.create(SVNURL.parseURIEncoded(url));

			if (username != null) {
				this._authenticationManager =
					SVNWCUtil.createDefaultAuthenticationManager(username, password);
			} else {
				this._authenticationManager =
					SVNWCUtil.createDefaultAuthenticationManager();
			}

			repository.setAuthenticationManager(this._authenticationManager);

		} catch (SVNException e) {
			if (logger.isEnableFor("Component2999")) {
				logger.log("Component2999", e, e.getMessage(),
						"url;username", url + ";" + username);
			}

			List<String> errorDetailList = new ArrayList<String>();
			errorDetailList.add("url=" + url);
			errorDetailList.add("username=" + username);
			throw new ComponentException("未知异常",
					ComponentSvnConst.ERROR_UNKNOWN, errorDetailList, e);
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "prepareSVNRepository");
		}

		return repository;
	}

	/**
	 * Subversion断开连接
	 */
	public final void disconnect() {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "disconnect");
		}

		if (this._repository != null) {
			this._repository.closeSession();
			this._repository = null;
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "disconnect");
		}
	}
}
