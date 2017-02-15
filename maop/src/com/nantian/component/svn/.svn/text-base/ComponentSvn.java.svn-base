package com.nantian.component.svn;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Properties;

import org.tmatesoft.svn.core.SVNAuthenticationException;
import org.tmatesoft.svn.core.SVNCommitInfo;
import org.tmatesoft.svn.core.SVNDepth;
import org.tmatesoft.svn.core.SVNDirEntry;
import org.tmatesoft.svn.core.SVNException;
import org.tmatesoft.svn.core.SVNNodeKind;
import org.tmatesoft.svn.core.SVNURL;
import org.tmatesoft.svn.core.io.SVNRepository;
import org.tmatesoft.svn.core.wc.ISVNOptions;
import org.tmatesoft.svn.core.wc.SVNCommitClient;
import org.tmatesoft.svn.core.wc.SVNCopyClient;
import org.tmatesoft.svn.core.wc.SVNCopySource;
import org.tmatesoft.svn.core.wc.SVNDiffClient;
import org.tmatesoft.svn.core.wc.SVNRevision;
import org.tmatesoft.svn.core.wc.SVNStatus;
import org.tmatesoft.svn.core.wc.SVNStatusClient;
import org.tmatesoft.svn.core.wc.SVNUpdateClient;
import org.tmatesoft.svn.core.wc.SVNWCClient;
import org.tmatesoft.svn.core.wc.SVNWCUtil;
import org.tmatesoft.svn.core.wc.admin.SVNAdminClient;

import com.nantian.component.com.ComponentConst;
import com.nantian.component.com.ComponentException;
import com.nantian.component.com.ComponentObject;
import com.nantian.component.com.ComponentProperties;
import com.nantian.component.log.Logger;


/**
 * SVN操作类
 * @author dong
 */
public class ComponentSvn {

	/**
	 * Logger
	 */
	private static Logger logger =  Logger.getLogger(ComponentSvn.class);
	
	/**
	 * Subversion连接类
	 */
	private ComponentSvnConnection _svnConnection;

	/**
	 * 构造
	 * @param svnConnection SvnConnection
	 */
	public ComponentSvn(final ComponentSvnConnection svnConnection) {
		this._svnConnection = svnConnection;
	}

	/**
	 * 作成版本库
	 *
	 * <UL><B>异常No：异常内容</B>
	 * <LI>20000004：未指定版本库路径
	 * <LI>20000005：版本库的路径中含有空格
	 * <LI>20000061：作成版本库失败
	 * <LI>20009999：发生未知异常
	 * </UL>
	 *
	 * @param path 版本库路径
	 */
	public final void doCreateRepository(final String path) {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doCreateRepository");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "path", path);
		}

		if (path == null || path.trim().equals("")) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "版本库的路径");
			}
			throw new ComponentException("没有指定版本库的路径",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}

		try {
			File repositoryPath = new File(path);
			ISVNOptions options = SVNWCUtil.createDefaultOptions(true);
			SVNAdminClient client =
				new SVNAdminClient(this._svnConnection.getISVNAuthenticationManager(), options);
			SVNURL svnURL = client.doCreateRepository(repositoryPath, null, true, true);

			// copy指定的文件
			String svnRoot = null;
			
			String svnHonbanPath = ComponentProperties.getSvnHonbanPath();
			if(!svnHonbanPath.equals("")) {
				// 复制文件的版本库路径若已经设定，则取得app_conf资源文件的hon_rep_edano关键字的值
				Properties properties =	
					(Properties) ComponentObject.getInstance(ComponentConst.APP_PROPERTIES_FILE_NAME);
				String edaban = properties.getProperty(ComponentConst.SVN_APP_CONF_EDABAN_KEY);
				if(edaban==null || edaban.trim().equals("")) {
					if (logger.isEnableFor("Component2065")) {
						logger.log("Component2065", 
								path,
								ComponentConst.APP_PROPERTIES_FILE_NAME,
								ComponentConst.SVN_APP_CONF_EDABAN_KEY);
					}
					
					List<String> errorDetailList = createErrorDetailListForDoCreateRepository(path);
					throw new ComponentException("不能做成版本库",
							ComponentSvnConst.ERROR_CAN_NOT_CREATE_DIRECTORY, errorDetailList);
				}
				svnRoot = svnHonbanPath+edaban;
				
			} else {
				// 复制文件的版本库路径若已经设定，使用svn.root的路径
				svnRoot = ComponentProperties.getSvnRoot();
			}
			
			String repositoryRoot = svnURL.getPath();
			ComponentSvnUtil.fileCopy(svnRoot + "/conf/authz", repositoryRoot + "/conf/authz");
			ComponentSvnUtil.fileCopy(svnRoot + "/conf/passwd", repositoryRoot + "/conf/passwd");
			ComponentSvnUtil.fileCopy(svnRoot + "/conf/svnserve.conf", repositoryRoot + "/conf/svnserve.conf");

		} catch (SVNAuthenticationException e) {
			if (logger.isEnableFor("Component2003")) {
				logger.log("Component2003", e, this._svnConnection.getRootUrl(),
						this._svnConnection.getUsername(), e.getMessage());
			}

			List<String> errorDetailList = createErrorDetailListForDoCreateRepository(path);
			throw new ComponentException("连接认证失败",
					ComponentSvnConst.ERROR_AUTHENTICATION, errorDetailList, e);

		} catch (IOException e) {
			if (logger.isEnableFor("Component2061")) {
				logger.log("Component2061", e, path, e.getMessage());
			}

			List<String> errorDetailList = createErrorDetailListForDoCreateRepository(path);
			throw new ComponentException("版本库的设定更新失败",
					ComponentSvnConst.ERROR_CAN_NOT_CREATE_DIRECTORY, errorDetailList, e);

		} catch (SVNException e) {
			if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONTAINS_INVALID_ELEMENT) != -1) {
				if (logger.isEnableFor("Component2005")) {
					logger.log("Component2005", e, path, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCreateRepository(path);
				throw new ComponentException("版本库的路径错误，含有非法对象",
						ComponentSvnConst.ERROR_CONTAINS_INVALID_ELEMENT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CAN_NOT_CREATE_DIRECTORY) != -1) {
				if (logger.isEnableFor("Component2062")) {
					logger.log("Component2062", e, path, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCreateRepository(path);
				throw new ComponentException("不能作成版本库",
						ComponentSvnConst.ERROR_CAN_NOT_CREATE_DIRECTORY, errorDetailList, e);
			} else {
				if (logger.isEnableFor("Component2999")) {
					logger.log("Component2999", e, e.getMessage(), "path", path);
				}

				List<String> errorDetailList = createErrorDetailListForDoCreateRepository(path);
				throw new ComponentException("未知异常错误",
						ComponentSvnConst.ERROR_UNKNOWN, errorDetailList, e);
			}
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doCreateRepository");
		}
	}

	/**
	 * 作成异常详细信息
	 *
	 * @param path 版本库的路径
	 * @return 详细异常信息列表
	 */
	private List<String> createErrorDetailListForDoCreateRepository(final String path) {

		List<String> errorDetailList = new ArrayList<String>();
		errorDetailList.add("url=" + this._svnConnection.getRootUrl());
		errorDetailList.add("username=" + this._svnConnection.getUsername());
		errorDetailList.add("path=" + path);

		return errorDetailList;
	}

	/**
	 * 删除版本库
	 *
	 * <UL><B>异常No：异常内容</B>
	 * <LI>20000004：未指定版本库路径
	 * <LI>20000005：版本库路径中存在空格
	 * <LI>20000062：无法删除版本库	 * <LI>20009999：未知异常	 * </UL>
	 *
	 * @param path 版本库路径
	 */
	public final void doDeleteRepository(final String path) {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doDeleteRepository");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "path", path);
		}

		if (path == null || path.trim().equals("")) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "版本库路径");
			}
			throw new ComponentException("未指定版本库路径",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}

		File repositoryPath = new File(path);
		try {
			ComponentSvnUtil.deleteDirectory(repositoryPath);
		} catch (IOException e) {
			if (logger.isEnableFor("Component2063")) {
				logger.log("Component2063", e, path, e.getMessage());
			}

			List<String> errorDetailList = createErrorDetailListForDoDeleteRepository(path);
			throw new ComponentException("无法删除版本库",
					ComponentSvnConst.ERROR_CAN_NOT_DELETE_DIRECTORY, errorDetailList, e);
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doDeleteRepository");
		}
	}

	/**
	 * 输出详细异常信息
	 *
	 * @param path 版本库路径
	 * @return 详细异常列表
	 */
	private List<String> createErrorDetailListForDoDeleteRepository(final String path) {

		List<String> errorDetailList = new ArrayList<String>();
		errorDetailList.add("url=" + this._svnConnection.getRootUrl());
		errorDetailList.add("username=" + this._svnConnection.getUsername());
		errorDetailList.add("path=" + path);

		return errorDetailList;
	}

	/**
	 * 上传文件至SVN
	 *
	 * <UL><B>异常No：异常内容</B>
	 * <LI>20000001：连接SVN失败
	 * <LI>20000002：无法访问SERVER
	 * <LI>20000003：连接认证失败	 * <LI>20000004：未指定上传文件目的地路径	 * <LI>20000004：未指定上传文件或者路径	 * <LI>20000005：SVN路径中存在空格	 * <LI>20000006：指定文件夹名	 * <LI>20000018：上传的文件在指定路径下已经存在
	 * <LI>20000031：版本库中文件或者路径存在	 * <LI>20009999：未知异常	 * </UL>
	 *
	 * @param path 版本库的路径	 * @param importPath 要输入的文件或者目录的路径
	 * @param commitMessage 提交的注释信息	 * @param isRecursive 若为true递归处理
	 * @return 输入成功后返回最新的修订版本号
	 */
	public final long doImport(final String path, final String importPath, final String commitMessage,
			final boolean isRecursive) {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doImport");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "path;importPath;commitMessage;isRecursive",
						path + ";" + importPath + ";" + commitMessage + ";" + isRecursive);
		}

		if (path == null || path.trim().equals("")) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "上传至SVN的路径");
			}
			throw new ComponentException("未指定上传至SVN的路径",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}
		if (importPath == null || importPath.trim().equals("")) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "上传文件或者路径");
			}
			throw new ComponentException("未指定上传的文件或者路径",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}

		long revision = 0;
		try {
			String checkPath = URLDecoder.decode(path, "UTF8");
			SVNNodeKind nodeKind = this._svnConnection.getRepository().checkPath(checkPath, -1);

			if (nodeKind == SVNNodeKind.FILE
					|| nodeKind == SVNNodeKind.DIR) {
				if (logger.isEnableFor("Component2031")) {
					logger.log("Component2031", path);
				}
				throw new ComponentException("svn中文件或者路径已经存在",
						ComponentSvnConst.ERROR_ALREADY_EXISTS);
			}

			SVNDepth depth;
			if (isRecursive) {
				depth = SVNDepth.INFINITY;
			} else {
				depth = SVNDepth.FILES;
			}

			SVNURL svnUrl = SVNURL.parseURIEncoded(this._svnConnection.getRootUrl() + path);
			ISVNOptions options = SVNWCUtil.createDefaultOptions(true);
			SVNCommitClient client =
				new SVNCommitClient(this._svnConnection.getISVNAuthenticationManager(), options);
			SVNCommitInfo commitInfo =
				client.doImport(new File(importPath), svnUrl, commitMessage, null, false, false, depth);

			revision = commitInfo.getNewRevision();

		} catch (SVNAuthenticationException e) {
			if (logger.isEnableFor("Component2003")) {
				logger.log("Component2003", e, this._svnConnection.getRootUrl(),
						this._svnConnection.getUsername(), e.getMessage());
			}

			List<String> errorDetailList = createErrorDetailListForDoImport(path, importPath, commitMessage, isRecursive);
			throw new ComponentException("认证失败",
					ComponentSvnConst.ERROR_AUTHENTICATION, errorDetailList, e);

		} catch (SVNException e) {
			if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONNECTION_REFUSED) != -1) {
				if (logger.isEnableFor("Component2001")) {
					logger.log("Component2001", e, this._svnConnection.getRootUrl(),
						this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoImport(path, importPath, commitMessage, isRecursive);
				throw new ComponentException("连接失败",
						ComponentSvnConst.ERROR_CONNECT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.UNKNOWN_HOST) != -1) {
				if (logger.isEnableFor("Component2002")) {
					logger.log("Component2002", e, this._svnConnection.getRootUrl(),
						this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoImport(path, importPath, commitMessage, isRecursive);
				throw new ComponentException("未知的主机",
						ComponentSvnConst.ERROR_UNKNOWN_HOST, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONTAINS_INVALID_ELEMENT) != -1) {
				if (logger.isEnableFor("Component2005")) {
					logger.log("Component2005", e, path, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoImport(path, importPath, commitMessage, isRecursive);
				throw new ComponentException("版本库路径错误，含有非法对象",
						ComponentSvnConst.ERROR_CONTAINS_INVALID_ELEMENT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.NOT_EXIST) != -1) {
				if (logger.isEnableFor("Component2018")) {
					logger.log("Component2018", e, importPath, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoImport(path, importPath, commitMessage, isRecursive);
				throw new ComponentException("上传的文件或者路径不存在",
						ComponentSvnConst.ERROR_PATH_DOES_NOT_EXIST, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.ALREADY_EXISTS) != -1) {
				if (logger.isEnableFor("Component2031")) {
					logger.log("Component2031", e, path);
				}

				List<String> errorDetailList = createErrorDetailListForDoImport(path, importPath, commitMessage, isRecursive);
				throw new ComponentException("SVN中该文件已经存在",
						ComponentSvnConst.ERROR_ALREADY_EXISTS, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.RESERVED_NAME) != -1) {
				if (logger.isEnableFor("Component2006")) {
					logger.log("Component2006", e, path, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoImport(path, importPath, commitMessage, isRecursive);
				throw new ComponentException("指定了保留字的文件名",
						ComponentSvnConst.ERROR_RESERVED_NAME, errorDetailList, e);
			} else {
				if (logger.isEnableFor("Component2999")) {
					logger.log("Component2999", e, e.getMessage(),
												  "path;importPath;commitMessage;isRecursive",
												  path + ";" 
												  + importPath + ";"
												  + commitMessage + ";"
												  + isRecursive);
				}

				List<String> errorDetailList = createErrorDetailListForDoImport(path, importPath, commitMessage, isRecursive);
				throw new ComponentException("未知异常",
						ComponentSvnConst.ERROR_UNKNOWN, errorDetailList, e);
			}

		} catch (UnsupportedEncodingException e) {
			if (logger.isEnableFor("Component2999")) {
				logger.log("Component2999", e, e.getMessage(),
											  "path;importPath;commitMessage;isRecursive",
											  path + ";"
											  + importPath + ";"
											  + commitMessage + ";"
											  + isRecursive);
			}

			List<String> errorDetailList = createErrorDetailListForDoImport(path, importPath, commitMessage, isRecursive);
			throw new ComponentException("未知异常",
					ComponentSvnConst.ERROR_UNKNOWN, errorDetailList, e);
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doImport");
		}

		return revision;
	}

	/**
	 * 输出详细异常信息
	 *
	 * @param path 上传的目的路径	 * @param importPath 上传的文件或目录的路径名
	 * @param commitMessage 提交信息
	 * @param isRecursive 若为true则递归处理
	 * @return 详细异常列表
	 */
	private List<String> createErrorDetailListForDoImport(final String path, final String importPath, final String commitMessage,
			final boolean isRecursive) {

		List<String> errorDetailList = new ArrayList<String>();
		errorDetailList.add("url=" + this._svnConnection.getRootUrl());
		errorDetailList.add("username=" + this._svnConnection.getUsername());
		errorDetailList.add("path=" + path);
		errorDetailList.add("importPath=" + importPath);
		errorDetailList.add("commitMessage=" + commitMessage);
		errorDetailList.add("isRecursive=" + isRecursive);

		return errorDetailList;
	}

	/**
	 * 提交checkout后编辑后的文件<BR>
	 * 若提交的文件已经存在，则文件版本号+1<BR>
	 * 若提交的文件不存在，则返回-1
	 *
	 * <UL><B>异常No：异常内容</B>
	 * <LI>20000001：Subversion连接失败
	 * <LI>20000002：无法访问Server
	 * <LI>20000003：认证失败	 * <LI>20000004：未指定提交文件的文件名或者路径	 * <LI>20000005：SVN的路径中存在空格
	 * <LI>20000011：SVN不存在	 * <LI>20000041：指定的文件没有进行版本控制	 * <LI>20000043：指定的目录禁止复制
	 * <LI>20000051：资源被其他用户锁住
	 * <LI>20009999：未知异常	 * </UL>
	 *
	 * @param wcPath 提交的文件名或者路径名
	 * @param commitMessage 提交的信息
	 * @param isRecursive 若为true则递归处理
	 * @return 提交后的最新的历史版本号
	 */
	public final long doCommit(final String wcPath, final String commitMessage, final boolean isRecursive) {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doCommit");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "wcPath;commitMessage;isRecursive", wcPath + ";" + commitMessage + ";" + isRecursive);
		}

		if (wcPath == null || wcPath.trim().equals("")) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "提交的文件名或者路径名");
			}
			throw new ComponentException("未指定提交的文件名或者路径名",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}

		String[] paths = {wcPath};
		long revision = doCommit(paths, commitMessage, isRecursive);

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doCommit");
		}

		return revision;
	}

	/**
	 * 提交checkout后编辑后的文件<BR>
	 * 若提交的文件已经存在，则文件版本号+1<BR>
	 * 若提交的文件不存在，则返回-1
	 *
	 * <UL><B>异常No：异常内容</B>
	 * <LI>20000001：Subversion连接失败
	 * <LI>20000002：无法访问Server
	 * <LI>20000003：认证失败	 * <LI>20000004：未指定提交文件的文件名或者路径	 * <LI>20000005：SVN的路径中存在空格
	 * <LI>20000011：SVN不存在	 * <LI>20000041：指定的文件没有进行版本控制	 * <LI>20000043：指定的目录禁止复制
	 * <LI>20000051：资源被其他用户锁住
	 * <LI>20009999：未知异常	 * </UL>
	 *
	 * @param wcPaths 提交的文件名或者路径名
	 * @param commitMessage 提交的信息	 * @param isRecursive 若为true则递归处理
	 * @return 提交后的最新的历史版本号
	 */
	public final long doCommit(final String[] wcPaths, final String commitMessage, final boolean isRecursive) {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doCommit(final String[], final String, final boolean)");
		}

		if (logger.isEnableFor("Component0003")) {
			StringBuffer params = new StringBuffer();
			StringBuffer values = new StringBuffer();

			if (wcPaths != null) {
				for (int i = 0; i < wcPaths.length; i++) {
					params.append("wcPaths;");
					values.append(wcPaths[i]);
					values.append(";");
				}
			}
			params.append("commitMessage;");
			values.append(commitMessage);
			values.append(";");
			params.append("isRecursive");
			values.append(isRecursive);

			logger.log("Component0003", params.toString(), values.toString());
		}

		if (wcPaths == null || wcPaths.length == 0) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "提交的文件名或者路径名");
			}
			throw new ComponentException("未指定提交的文件名或者路径名",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}

		long revision = 0;
		try {
			File[] wcFiles = new File[wcPaths.length];
			for (int i = 0; i < wcPaths.length; i++) {
				wcFiles[i] = new File(wcPaths[i]);
			}

			SVNDepth depth;
			if (isRecursive) {
				depth = SVNDepth.INFINITY;
			} else {
				depth = SVNDepth.FILES;
			}

			ISVNOptions options = SVNWCUtil.createDefaultOptions(true);
			SVNCommitInfo cInfo = null;
			SVNCommitClient client =
				new SVNCommitClient(this._svnConnection.getISVNAuthenticationManager(), options);
			cInfo = client.doCommit(wcFiles, false, commitMessage, null, null, false, false, depth);
			revision = cInfo.getNewRevision();

		} catch (SVNAuthenticationException e) {
			if (logger.isEnableFor("Component2003")) {
				logger.log("Component2003", e, this._svnConnection.getRootUrl(),
					this._svnConnection.getUsername(), e.getMessage());
			}

			List<String> errorDetailList = createErrorDetailListForDoCommit(wcPaths, commitMessage, isRecursive);
			throw new ComponentException("认证失败",
					ComponentSvnConst.ERROR_AUTHENTICATION, errorDetailList, e);

		} catch (SVNException e) {
			if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONNECTION_REFUSED) != -1) {
				if (logger.isEnableFor("Component2001")) {
					logger.log("Component2001", e, this._svnConnection.getRootUrl(),
						this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCommit(wcPaths, commitMessage, isRecursive);
				throw new ComponentException("连接失败",
						ComponentSvnConst.ERROR_CONNECT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.UNKNOWN_HOST) != -1) {
				if (logger.isEnableFor("Component2002")) {
					logger.log("Component2002", e, this._svnConnection.getRootUrl(),
						this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCommit(wcPaths, commitMessage, isRecursive);
				throw new ComponentException("未知的主机",
						ComponentSvnConst.ERROR_UNKNOWN_HOST, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONTAINS_INVALID_ELEMENT) != -1) {
				if (logger.isEnableFor("Component2005")) {
					logger.log("Component2005", e, Arrays.toString(wcPaths), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCommit(wcPaths, commitMessage, isRecursive);
				throw new ComponentException("版本库路径错误，含有非法对象",
						ComponentSvnConst.ERROR_CONTAINS_INVALID_ELEMENT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.FILE_NOT_FOUND) != -1) {
				if (logger.isEnableFor("Component2011")) {
					logger.log("Component2011", e, Arrays.toString(wcPaths));
				}

				List<String> errorDetailList = createErrorDetailListForDoCommit(wcPaths, commitMessage, isRecursive);
				throw new ComponentException("SVN的资源库不存在",
						ComponentSvnConst.ERROR_DOES_NOT_EXIST, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.NOT_WORKING_COPY) != -1) {
				if (logger.isEnableFor("Component2043")) {
					logger.log("Component2043", e, Arrays.toString(wcPaths), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCommit(wcPaths, commitMessage, isRecursive);
				throw new ComponentException("指定的目录不是一个工作副本目录",
						ComponentSvnConst.ERROR_NOT_WORKING_COPY, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.NOT_VERSION_CONTROL) != -1) {
				if (logger.isEnableFor("Component2041")) {
					logger.log("Component2041", e, Arrays.toString(wcPaths), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCommit(wcPaths, commitMessage, isRecursive);
				throw new ComponentException("指定的文件没有进行版本控制",
						ComponentSvnConst.ERROR_NOT_VERSION_CONTROL, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.LOCKED) != -1) {
				if (logger.isEnableFor("Component2051")) {
					logger.log("Component2051", e, Arrays.toString(wcPaths), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCommit(wcPaths, commitMessage, isRecursive);
				throw new ComponentException("资源正被其他用户锁住",
						ComponentSvnConst.ERROR_LOCKED, errorDetailList, e);
			} else {
				if (logger.isEnableFor("Component2999")) {

					StringBuffer params = new StringBuffer();
					StringBuffer values = new StringBuffer();

					if (wcPaths != null) {
						for (int i = 0; i < wcPaths.length; i++) {
							params.append("wcPaths;");
							values.append(wcPaths[i]);
							values.append(";");
						}
					}
					params.append("commitMessage;");
					values.append(commitMessage);
					values.append(";");
					params.append("isRecursive;");
					values.append(isRecursive);

					logger.log("Component2999", e, e.getMessage(), params.toString(), values.toString());
				}

				List<String> errorDetailList = createErrorDetailListForDoCommit(wcPaths, commitMessage, isRecursive);
				throw new ComponentException("未知异常",
						ComponentSvnConst.ERROR_UNKNOWN, errorDetailList, e);
			}
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doCommit(final String[], final String, final boolean)");
		}

		return revision;
	}

	/**
	 * 输出详细的异常信息	 *
	 * @param wcPaths 提交的文件名或者路径名
	 * @param commitMessage 提交的信息	 * @param isRecursive 若为true则递归处理
	 * @return 详细的异常列表	 */
	private List<String> createErrorDetailListForDoCommit(final String[] wcPaths, final String commitMessage,
			final boolean isRecursive) {

		List<String> errorDetailList = new ArrayList<String>();
		errorDetailList.add("url=" + this._svnConnection.getRootUrl());
		errorDetailList.add("username=" + this._svnConnection.getUsername());

		if (wcPaths != null) {
			for (int i = 0; i < wcPaths.length; i++) {
				errorDetailList.add("wcPaths=" + wcPaths[i]);
			}
		}

		errorDetailList.add("commitMessage=" + commitMessage);
		errorDetailList.add("isRecursive=" + isRecursive);

		return errorDetailList;
	}

	/**
	 * 在指定的历史版本上进行更新	 *
	 * <UL><B>异常No：异常内容</B>
	 * <LI>20000001：Subversion连接失败
	 * <LI>20000002：无法访问Server
	 * <LI>20000003：认证失败	 * <LI>20000004：未指定提交文件的文件名或者路径	 * <LI>20000005：SVN的路径中存在空格
	 * <LI>20000011：SVN不存在	 * <LI>20000041：指定的文件没有进行版本控制	 * <LI>20000043：指定的目录禁止复制
	 * <LI>20000051：资源被其他用户锁住
	 * <LI>20009999：未知异常	 * </UL>
	 *
	 * @param wcPath 要更新的文件路径
	 * @param revision ���r�W���� -1��w�肵���ꍇ�ŐV���r�W����
	 * @param isRecursive true��w�肵���ꍇ�ċA�I�ɏ������܂�
	 * @return revision��-1�̏ꍇ�́A���|�W�g���̍ŐV���r�W�����ԍ���Ԃ��܂��B�@revision��1�ȏ�̏ꍇ�́Arevision�Ɠ������r�W�����ԍ���Ԃ��܂��B
	 */
	public final long[] doUpdate(final String wcPath, final long revision, final boolean isRecursive) {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doUpdate");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "wcPath;revision;isRecursive", wcPath + ";" + revision + ";" + isRecursive);
		}

		if (wcPath == null || wcPath.trim().equals("")) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "要更新的文件路径");
			}
			throw new ComponentException("未指定要更新文件的路径",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}
		
		long[] retRevision = {};
		String[] paths = {wcPath};
		retRevision = doUpdate(paths, revision, isRecursive);

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doUpdate");
		}
		
		return retRevision;
	}

	/**
	 * 在指定的历史版本上进行更新	 *
	 * <UL><B>异常No：异常内容</B>
	 * <LI>20000001：Subversion连接失败
	 * <LI>20000002：无法访问Server
	 * <LI>20000003：认证失败	 * <LI>20000004：未指定提交文件的文件名或者路径	 * <LI>20000005：SVN的路径中存在空格
	 * <LI>20000011：SVN不存在	 * <LI>20000041：指定的文件没有进行版本控制	 * <LI>20000043：指定的目录禁止复制
	 * <LI>20000051：资源被其他用户锁住
	 * <LI>20009999：未知异常	 * </UL>
	 *
	 * @param wcPaths 要更新的文件路径
	 * @param revision ���r�W���� -1��w�肵���ꍇ�ŐV���r�W����
	 * @param isRecursive true��w�肵���ꍇ�ċA�I�ɏ������܂�
	 * @return revision��-1�̏ꍇ�́A���|�W�g���̍ŐV���r�W�����ԍ���Ԃ��܂��B�@revision��1�ȏ�̏ꍇ�́Arevision�Ɠ������r�W�����ԍ���Ԃ��܂��B
	 */
	public final long[] doUpdate(final String[] wcPaths, final long revision, final boolean isRecursive) {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doUpdate(final String[], final long, final boolean)");
		}

		if (logger.isEnableFor("Component0003")) {
			StringBuffer params = new StringBuffer();
			StringBuffer values = new StringBuffer();

			if (wcPaths != null) {
				for (int i = 0; i < wcPaths.length; i++) {
					params.append("wcPaths;");
					values.append(wcPaths[i]);
					values.append(";");
				}
			}
			params.append("revision;");
			values.append(revision);
			values.append(";");
			params.append("isRecursive");
			values.append(isRecursive);

			logger.log("Component0003", params.toString(), values.toString());
		}

		if (wcPaths == null || wcPaths.length == 0) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "要更新文件的路径");
			}
			throw new ComponentException("未指定要更新文件的路径",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}

		long retRevision[] = {};
		try {
			if (this._svnConnection.getRepository().getLatestRevision() < revision) {
				throw new ComponentException("不存在最新版本",
						ComponentSvnConst.ERROR_NO_SUCH_REVISION);
			}

			File[] wcFiles = new File[wcPaths.length];
			for (int i = 0; i < wcPaths.length; i++) {
				wcFiles[i] = new File(wcPaths[i]);
			}

			SVNRevision svnRevision;
			if (revision < 0) {
				svnRevision = SVNRevision.HEAD;
			} else {
				svnRevision = SVNRevision.create(revision);
			}

			SVNDepth depth;
			if (isRecursive) {
				depth = SVNDepth.INFINITY;
			} else {
				depth = SVNDepth.FILES;
			}

			ISVNOptions options = SVNWCUtil.createDefaultOptions(true);
			SVNUpdateClient client =
				new SVNUpdateClient(this._svnConnection.getISVNAuthenticationManager(), options);

			retRevision = client.doUpdate(wcFiles, svnRevision, depth, false, false);
			for (int i = 0; i < retRevision.length; i++) {
				if (retRevision[i] < 0) {
					if (logger.isEnableFor("Component2044")) {
						logger.log("Component2044", wcPaths[i]);
					}

					List<String> errorDetailList = createErrorDetailListForDoUpdate(wcPaths, revision, isRecursive);
					throw new ComponentException("指定的路径下禁止复制",
							ComponentSvnConst.ERROR_NOT_WORKING_COPY_FOR_UPDATE, errorDetailList);
				}
			}

			for (int i = 0; i < wcPaths.length; i++) {
				if (!wcFiles[i].exists()) {
					if (logger.isEnableFor("Component2021")) {
						logger.log("Component2021", wcPaths[i]);
					}

					List<String> errorDetailList = createErrorDetailListForDoUpdate(wcPaths, revision, isRecursive);
					throw new ComponentException("指定的文件不存在",
							ComponentSvnConst.ERROR_PATH_DOES_NOT_FOUND, errorDetailList);
				}
			}

		} catch (SVNAuthenticationException e) {
			if (logger.isEnableFor("Component2003")) {
				logger.log("Component2003", e, this._svnConnection.getRootUrl(),
					this._svnConnection.getUsername(), e.getMessage());
			}

			List<String> errorDetailList = createErrorDetailListForDoUpdate(wcPaths, revision, isRecursive);
			throw new ComponentException("认证失败",
					ComponentSvnConst.ERROR_AUTHENTICATION, errorDetailList, e);

		} catch (SVNException e) {
			if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONNECTION_REFUSED) != -1) {
				if (logger.isEnableFor("Component2001")) {
					logger.log("Component2001", e, this._svnConnection.getRootUrl(),
						this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoUpdate(wcPaths, revision, isRecursive);
				throw new ComponentException("连接失败",
						ComponentSvnConst.ERROR_CONNECT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.UNKNOWN_HOST) != -1) {
				if (logger.isEnableFor("Component2002")) {
					logger.log("Component2002", e, this._svnConnection.getRootUrl(),
						this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoUpdate(wcPaths, revision, isRecursive);
				throw new ComponentException("未知的主机",
						ComponentSvnConst.ERROR_UNKNOWN_HOST, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONTAINS_INVALID_ELEMENT) != -1) {
				if (logger.isEnableFor("Component2005")) {
					logger.log("Component2005", e, Arrays.toString(wcPaths), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoUpdate(wcPaths, revision, isRecursive);
				throw new ComponentException("版本库路径错误，含有非法对象",
						ComponentSvnConst.ERROR_CONTAINS_INVALID_ELEMENT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.EXIST_UNVERSIONED_FILE) != -1) {
				if (logger.isEnableFor("Component2048")) {
					logger.log("Component2048", e, Arrays.toString(wcPaths), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoUpdate(wcPaths, revision, isRecursive);
				throw new ComponentException("未进行版本管理的文件已经存在",
						ComponentSvnConst.ERROR_EXIST_UNVERSIONED_FILE, errorDetailList, e);
			} else {
				if (logger.isEnableFor("Component2999")) {

					StringBuffer params = new StringBuffer();
					StringBuffer values = new StringBuffer();

					if (wcPaths != null) {
						for (int i = 0; i < wcPaths.length; i++) {
							params.append("wcPaths;");
							values.append(wcPaths[i]);
							values.append(";");
						}
					}
					params.append("revision;");
					values.append(revision);
					values.append(";");
					params.append("isRecursive");
					values.append(isRecursive);

					logger.log("Component2999", e, e.getMessage(), params.toString(), values.toString());
				}

				List<String> errorDetailList = createErrorDetailListForDoUpdate(wcPaths, revision, isRecursive);
				throw new ComponentException("未知异常",
						ComponentSvnConst.ERROR_UNKNOWN, errorDetailList, e);
			}
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doUpdate(final String[], final long, final boolean)");
		}
		
		return retRevision;
	}

	/**
	 * 输出详细错误信息
	 *
	 * @param wcPaths 要更新的文件路径
	 * @param revision 最新的版本号：版本号-1
	 * @param isRecursive 若为true则递归处理
	 * @return 详细错误列表
	 */
	private List<String> createErrorDetailListForDoUpdate(final String[] wcPaths, final long revision, final boolean isRecursive) {

		List<String> errorDetailList = new ArrayList<String>();
		errorDetailList.add("url=" + this._svnConnection.getRootUrl());
		errorDetailList.add("username=" + this._svnConnection.getUsername());

		if (wcPaths != null) {
			for (int i = 0; i < wcPaths.length; i++) {
				errorDetailList.add("wcPaths=" + wcPaths[i]);
			}
		}

		errorDetailList.add("revision=" + revision);
		errorDetailList.add("isRecursive=" + isRecursive);

		return errorDetailList;
	}

	/**
	 * 删除版本库中的文件或者目录
	 *
	 * <UL><B>异常编号：异常内容</B>
	 * <LI>20000001：Subversion连接失败
	 * <LI>20000002：未知主机	 * <LI>20000003：认证失败
	 * <LI>20000004：未指定要删除的文件或者目录的版本库路径	 * <LI>20000005：版本库路径中含有空格
	 * <LI>20000012：要删除的版本不存在
	 * <LI>20000051：被其他用户LOCK
	 * <LI>20009999：未知异常
	 * </UL>
	 *
	 * @param path 要删除的文件或者目录的版本库路径
	 * @param commitMessage 提交的日志信息
	 * @return 删除后的版本库的最新版本号
	 */
	public final long doDelete(final String path, final String commitMessage) {

		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doDelete");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "path;commitMessage", path + ";" + commitMessage);
		}

		if (path == null || path.trim().equals("")) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "要删除的文件或者目录的版本库路径");
			}
			throw new ComponentException("未指定要删除的文件或者目录的版本库路径",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}

		String[] svnUrl = {path};
		long revision = doDelete(svnUrl, commitMessage);

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doDelete");
		}
		
		return revision;
	}

	/**
	 * 删除版本库中的文件或者目录
	 *
	 * <UL><B>异常编号：异常内容</B>
	 * <LI>20000001：Subversion连接失败
	 * <LI>20000002：未知主机
	 * <LI>20000003：认证失败
	 * <LI>20000004：未指定要删除的文件或者目录的版本库路径
	 * <LI>20000005：版本库路径中含有空格
	 * <LI>20000012：要删除的版本不存在
	 * <LI>20000051：被其他用户LOCK
	 * <LI>20009999：未知异常
	 * </UL>
	 *
	 * @param paths 要删除的文件或者目录的版本库路径
	 * @param commitMessage 提交的日志信息
	 * @return 删除后的版本库的最新版本号
	 */
	public final long doDelete(final String[] paths, final String commitMessage) {

		// 输出结束日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doDelete(final String[], final String)");
		}

		if (logger.isEnableFor("Component0003")) {
			StringBuffer params = new StringBuffer();
			StringBuffer values = new StringBuffer();

			if (paths != null) {
				for (int i = 0; i < paths.length; i++) {
					params.append("paths;");
					values.append(paths[i]);
					values.append(";");
				}
			}
			params.append("commitMessage");
			values.append(commitMessage);

			logger.log("Component0003", params.toString(), values.toString());
		}

		if (paths == null || paths.length == 0) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "要删除的文件或者目录的版本库路径");
			}
			throw new ComponentException("未指定要删除的文件或者目录的版本库路径",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}

		long revision = 0;
		try {
			SVNURL[] svnUrl = new SVNURL[paths.length];
			for (int i = 0; i < paths.length; i++) {
				svnUrl[i] = SVNURL.parseURIEncoded(this._svnConnection.getRootUrl() + paths[i]);
			}

			ISVNOptions options = SVNWCUtil.createDefaultOptions(true);
			SVNCommitInfo cInfo = null;
			SVNCommitClient client =
				new SVNCommitClient(this._svnConnection.getISVNAuthenticationManager(), options);
			cInfo = client.doDelete(svnUrl, commitMessage);
			revision = cInfo.getNewRevision();
			
		} catch (SVNAuthenticationException e) {
			if (logger.isEnableFor("Component2003")) {
				logger.log("Component2003", e, this._svnConnection.getRootUrl(),
						this._svnConnection.getUsername(), e.getMessage());
			}

			List<String> errorDetailList = createErrorDetailListForDoDelete(paths, commitMessage);
			throw new ComponentException("认证失败",
					ComponentSvnConst.ERROR_AUTHENTICATION, errorDetailList, e);

		} catch (SVNException e) {
			if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONNECTION_REFUSED) != -1) {
				if (logger.isEnableFor("Component2001")) {
					logger.log("Component2001", e, this._svnConnection.getRootUrl(),
							this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoDelete(paths, commitMessage);
				throw new ComponentException("连接失败",
						ComponentSvnConst.ERROR_CONNECT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.UNKNOWN_HOST) != -1) {
				if (logger.isEnableFor("Component2002")) {
					logger.log("Component2002", e, this._svnConnection.getRootUrl(),
							this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoDelete(paths, commitMessage);
				throw new ComponentException("未知的主机",
						ComponentSvnConst.ERROR_UNKNOWN_HOST, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONTAINS_INVALID_ELEMENT) != -1) {
				if (logger.isEnableFor("Component2005")) {
					logger.log("Component2005", e, Arrays.toString(paths), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoDelete(paths, commitMessage);
				throw new ComponentException("版本库路径错误，含有非法对象",
						ComponentSvnConst.ERROR_CONTAINS_INVALID_ELEMENT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.NOT_EXIST) != -1) {
				if (logger.isEnableFor("Component2012")) {
					logger.log("Component2012", e, Arrays.toString(paths), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoDelete(paths, commitMessage);
				throw new ComponentException("删除的版本库不存在",
						ComponentSvnConst.ERROR_DOES_NOT_EXIST_FOR_DELETE, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.LOCKED) != -1) {
				if (logger.isEnableFor("Component2051")) {
					logger.log("Component2051", e, Arrays.toString(paths), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoDelete(paths, commitMessage);
				throw new ComponentException("资源被其他用户锁住",
						ComponentSvnConst.ERROR_LOCKED, errorDetailList, e);
			} else {
				if (logger.isEnableFor("Component2999")) {

					StringBuffer params = new StringBuffer();
					StringBuffer values = new StringBuffer();

					if (paths != null) {
						for (int i = 0; i < paths.length; i++) {
							params.append("paths;");
							values.append(paths[i]);
							values.append(";");
						}
					}
					params.append("commitMessage");
					values.append(commitMessage);

					logger.log("Component2999", e, e.getMessage(), params.toString(), values.toString());
				}

				List<String> errorDetailList = createErrorDetailListForDoDelete(paths, commitMessage);
				throw new ComponentException("未知异常",
						ComponentSvnConst.ERROR_UNKNOWN, errorDetailList, e);
			}
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doDelete(final String[], final String)");
		}
		
		return revision;
	}

	/**
	 * 输出详细错误信息
	 *
	 * @param paths 要删除的文件或者目录的版本库路径
	 * @param commitMessage 提交的信息	 * @return 详细错误列表
	 */
	private List<String> createErrorDetailListForDoDelete(final String[] paths, final String commitMessage) {

		List<String> errorDetailList = new ArrayList<String>();
		errorDetailList.add("url=" + this._svnConnection.getRootUrl());
		errorDetailList.add("username=" + this._svnConnection.getUsername());

		if (paths != null) {
			for (int i = 0; i < paths.length; i++) {
				errorDetailList.add("paths=" + paths[i]);
			}
		}

		errorDetailList.add("commitMessage=" + commitMessage);

		return errorDetailList;
	}

	/**
	 * 把作业环境复制过来的未受控的文件设置成准备登录状态<BR>
	 * 只能指定一个文件<BR>
	 * 设置成准备登录状态后，执行提交命令，把文件IMPORT到版本库中
	 *
	 * <UL><B>异常编号：异常内容</B>
	 * <LI>20000004：未指定要设置成准备登录状态文件路径	 * <LI>20000019：要设置成准备登录状态文件不存在
	 * <LI>20000042：要设置成准备登录状态文件已经是受控状态
	 * <LI>20000046：指定的目录不是一个工作副本目录
	 * <LI>20009999：未知异常
	 * </UL>
	 *
	 * @param wcPath 要设置成准备登录状态文件路径
	 */
	public final void doAddScheduling(final String wcPath) {

		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doAddScheduling");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "wcPath", wcPath);
		}

		if (wcPath == null || wcPath.trim().equals("")) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "要设置成准备登录状态文件路径");
			}
			throw new ComponentException("未指定要设置成准备登录状态文件路径",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}

		try {
			File wcFile = new File(wcPath);
			ISVNOptions options = SVNWCUtil.createDefaultOptions(true);

			SVNWCClient wcClient =
				new SVNWCClient(this._svnConnection.getISVNAuthenticationManager(), options);
			wcClient.doAdd(wcFile, false, false, false, SVNDepth.INFINITY, true, true);

		} catch (SVNException e) {
			if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.NOT_FOUND) != -1) {
				if (logger.isEnableFor("Component2019")) {
					logger.log("Component2019", e, wcPath, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoAddScheduling(wcPath);
				throw new ComponentException("要设置成准备登录状态文件不存在",
						ComponentSvnConst.ERROR_FILE_NOT_FOUND, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.NOT_WORKING_COPY) != -1) {
				// makeParents = false
				if (logger.isEnableFor("Component2043")) {
					logger.log("Component2043", e, wcPath, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoAddScheduling(wcPath);
				throw new ComponentException("指定的目录不是一个工作副本目录",
						ComponentSvnConst.ERROR_NOT_WORKING_COPY, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.NO_VERSIONED_PARENT_DIRECTORIES) != -1) {
				// makeParents = true
				if (logger.isEnableFor("Component2046")) {
					logger.log("Component2046", e, wcPath, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoAddScheduling(wcPath);
				throw new ComponentException("准备登录时该目录还处于未管理状态",
						ComponentSvnConst.ERROR_NO_VERSIONED_PARENT_DIRECTORIES, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.UNDER_VERSION_CONTROL) != -1) {
				if (logger.isEnableFor("Component2042")) {
					logger.log("Component2042", e, wcPath, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoAddScheduling(wcPath);
				throw new ComponentException("指定的文件已经处于版本管理的受控状态",
						ComponentSvnConst.ERROR_UNDER_VERSION_CONTROL, errorDetailList, e);
			} else {
				if (logger.isEnableFor("Component2999")) {
					logger.log("Component2999", e, e.getMessage(), "wcPath", wcPath);
				}

				List<String> errorDetailList = createErrorDetailListForDoAddScheduling(wcPath);
				throw new ComponentException("未知异常",
						ComponentSvnConst.ERROR_UNKNOWN, errorDetailList, e);
			}
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doAddScheduling");
		}
	}

	/**
	 * 输出详细错误信息
	 *
	 * @param wcPath 添加到准备状态的文件路径
	 * @return 详细错误列表
	 */
	private List<String> createErrorDetailListForDoAddScheduling(final String wcPath) {

		List<String> errorDetailList = new ArrayList<String>();
		errorDetailList.add("url=" + this._svnConnection.getRootUrl());
		errorDetailList.add("username=" + this._svnConnection.getUsername());
		errorDetailList.add("wcPath=" + wcPath);

		return errorDetailList;
	}

	/**
	 * 把工作副本目录下版本库中准备删除的文件设置成提交前的删除状态<BR>
	 * 只能指定一个文件<BR>
	 * 设置成删除状态后，进行提交操作，然后从版本库中删除
	 *
	 * <UL><B>异常编号：异常内容</B>
	 * <LI>20000004：未指定要设置成删除状态的文件路径	 * <LI>20000020：要删除的文件不存在
	 * <LI>20000043：指定的目录不是工作副本目录
	 * <LI>20009999：未知异常
	 * </UL>
	 *
	 * @param wcPath 删除准备状态的文件路径
	 */
	public final void doDeleteScheduling(final String wcPath) {

		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doDeleteScheduling");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "wcPath", wcPath);
		}

		if (wcPath == null || wcPath.trim().equals("")) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "要设置成删除状态的文件路径");
			}
			throw new ComponentException("未指定要设置成删除状态的文件路径",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}

		try {
			File wcFile = new File(wcPath);
			ISVNOptions options = SVNWCUtil.createDefaultOptions(true);
			SVNWCClient wcClient =
				new SVNWCClient(this._svnConnection.getISVNAuthenticationManager(), options);
			wcClient.doDelete(wcFile, true, true, false);

		} catch (SVNException e) {
			if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.NOT_WORKING_COPY) != -1) {
				if (logger.isEnableFor("Component2043")) {
					logger.log("Component2043", e, wcPath, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoDeleteScheduling(wcPath);
				throw new ComponentException("指定的目录不是一个工作副本目录",
						ComponentSvnConst.ERROR_NOT_WORKING_COPY, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.NOT_EXIST) != -1) {
				if (logger.isEnableFor("Component2020")) {
					logger.log("Component2020", e, wcPath, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoDeleteScheduling(wcPath);
				throw new ComponentException("要删除的文件不存在",
						ComponentSvnConst.ERROR_FILE_DOES_NOT_EXIST, errorDetailList, e);
			} else {
				if (logger.isEnableFor("Component2999")) {
					logger.log("Component2999", e, e.getMessage(), "wcPath", wcPath);
				}

				List<String> errorDetailList = createErrorDetailListForDoDeleteScheduling(wcPath);
				throw new ComponentException("未知异常",
						ComponentSvnConst.ERROR_UNKNOWN, errorDetailList, e);
			}
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doDeleteScheduling");
		}
	}

	/**
	 * 输出详细错误信息
	 *
	 * @param wcPath 要设置成删除状态的文件路径
	 * @return 详细错误信息
	 */
	private List<String> createErrorDetailListForDoDeleteScheduling(final String wcPath) {

		List<String> errorDetailList = new ArrayList<String>();
		errorDetailList.add("url=" + this._svnConnection.getRootUrl());
		errorDetailList.add("username=" + this._svnConnection.getUsername());
		errorDetailList.add("wcPath=" + wcPath);

		return errorDetailList;
	}

	/**
	 * Checkout版本库的目录
	 *
	 * <UL><B>异常编号：异常内容</B>
	 * <LI>20000001：Subversion连接失败
	 * <LI>20000002：未知主机	 * <LI>20000003：认证失败
	 * <LI>20000004：未指定要进行checkout的版本库路径	 * <LI>20000004：未指定checkout保存的目录名	 * <LI>20000005：版本库的路径中含有空格
	 * <LI>20000007：指定的是一个文件名不是一个路径
	 * <LI>20000013：要进行checkout的版本库资源不存在
	 * <LI>20000026：要进行checkout的版本库资源版本号不存在
	 * <LI>20000047：该目录资源被其他用户的工作副本目录LOCK
	 * <LI>20000048：工作副本目录中存在版本未受控的文件	 * <LI>20009999：未知异常
	 * </UL>
	 *
	 * @param path 要进行checkout的版本库路径
	 * @param revision 要进行checkout的版本号为-1时，则作为最新的版本号
	 * @param wcPath checkout保存的目录名
	 * @param isRecursive true则递归导出处理
	 * @return revision=-1则返回版本库最新的版本号，revision>1则返回与revision相同的版本号
	 */
	public final long doCheckout(final String path, final long revision, final String wcPath,
			final boolean isRecursive) {

		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doCheckout");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "path;revision;wcPath;isRecursive",
						path + ";" + revision + ";" + wcPath + ";" + isRecursive);
		}

		if (path == null || path.trim().equals("")) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "checkOut的版本库的路径");
			}
			throw new ComponentException("未指定checkOut的版本库的路径",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}
		if (wcPath == null || wcPath.trim().equals("")) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "checkout保存的目录名");
			}
			throw new ComponentException("未指定checkout保存的目录名",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}

		long retRevision = 0;
		try {
			SVNRevision svnRevision;
			if (revision < 0) {
				svnRevision = SVNRevision.HEAD;
			} else {
				svnRevision = SVNRevision.create(revision);
			}

			SVNDepth depth;
			if (isRecursive) {
				depth = SVNDepth.INFINITY;
			} else {
				depth = SVNDepth.FILES;
			}

			SVNURL svnUrl = SVNURL.parseURIEncoded(this._svnConnection.getRootUrl() + path);
			ISVNOptions options = SVNWCUtil.createDefaultOptions(true);
			SVNUpdateClient client =
				new SVNUpdateClient(this._svnConnection.getISVNAuthenticationManager(), options);
			retRevision = client.doCheckout(svnUrl, new File(wcPath), svnRevision, svnRevision, depth, false);

		} catch (SVNAuthenticationException e) {
			if (logger.isEnableFor("Component2003")) {
				logger.log("Component2003", e, this._svnConnection.getRootUrl(),
						this._svnConnection.getUsername(), e.getMessage());
			}

			List<String> errorDetailList = createErrorDetailListForDoCheckout(path, revision, wcPath, isRecursive);
			throw new ComponentException("认证失败",
					ComponentSvnConst.ERROR_AUTHENTICATION, errorDetailList, e);

		} catch (SVNException e) {
			if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONNECTION_REFUSED) != -1) {
				if (logger.isEnableFor("Component2001")) {
					logger.log("Component2001", e, this._svnConnection.getRootUrl(),
							this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCheckout(path, revision, wcPath, isRecursive);
				throw new ComponentException("连接失败",
						ComponentSvnConst.ERROR_CONNECT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.UNKNOWN_HOST) != -1) {
				if (logger.isEnableFor("Component2002")) {
					logger.log("Component2002", e, this._svnConnection.getRootUrl(),
							this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCheckout(path, revision, wcPath, isRecursive);
				throw new ComponentException("未知的主机",
						ComponentSvnConst.ERROR_UNKNOWN_HOST, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONTAINS_INVALID_ELEMENT) != -1) {
				if (logger.isEnableFor("Component2005")) {
					logger.log("Component2005", e, path, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCheckout(path, revision, wcPath, isRecursive);
				throw new ComponentException("版本库路径错误，含有非法对象",
						ComponentSvnConst.ERROR_CONTAINS_INVALID_ELEMENT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.NOT_DIRECTORY) != -1) {
				if (logger.isEnableFor("Component2007")) {
					logger.log("Component2007", e, path, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCheckout(path, revision, wcPath, isRecursive);
				throw new ComponentException("指定的是一个文件而不是一个目录",
						ComponentSvnConst.ERROR_NOT_DIRECTORY, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.NOT_EXIST2) != -1) {
				if (logger.isEnableFor("Component2013")) {
					logger.log("Component2013", e, path, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCheckout(path, revision, wcPath, isRecursive);
				throw new ComponentException("checkOut的版本库不存在",
						ComponentSvnConst.ERROR_DOES_NOT_EXIST_FOR_CHECKOUT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.NO_SUCH_REVISION) != -1) {
				if (logger.isEnableFor("Component2026")) {
					logger.log("Component2026", e, path, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCheckout(path, revision, wcPath, isRecursive);
				throw new ComponentException("要checkout的版本不存在",
						ComponentSvnConst.ERROR_NO_SUCH_REVISION, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.ALREADY_WORKING_COPY) != -1) {
				if (logger.isEnableFor("Component2047")) {
					logger.log("Component2047", e, path, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCheckout(path, revision, wcPath, isRecursive);
				throw new ComponentException("该目录正在被其他URL的复制作业使用",
						ComponentSvnConst.ERROR_ALREADY_WORKING_COPY, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.EXIST_UNVERSIONED_FILE) != -1) {
				if (logger.isEnableFor("Component2048")) {
					logger.log("Component2048", e, path, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCheckout(path, revision, wcPath, isRecursive);
				throw new ComponentException("相同文件名的未进行版本管理的文件已经存在",
						ComponentSvnConst.ERROR_EXIST_UNVERSIONED_FILE, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CANNOT_CREATE_NEW_FILE) != -1) {
				if (logger.isEnableFor("Component2064")) {
					logger.log("Component2064", e, path, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCheckout(path, revision, wcPath, isRecursive);
				throw new ComponentException("不能新建文件",
						ComponentSvnConst.ERROR_CANNOT_CREATE_NEW_FILE, errorDetailList, e);
			} else {
				if (logger.isEnableFor("Component2999")) {
					logger.log("Component2999", e, e.getMessage(),
							"path;revision;wcPath;isRecursive",
							path + ";" + revision + ";" + wcPath + ";" + isRecursive);
				}

				List<String> errorDetailList = createErrorDetailListForDoCheckout(path, revision, wcPath, isRecursive);
				throw new ComponentException("未知异常",
						ComponentSvnConst.ERROR_UNKNOWN, errorDetailList, e);
			}
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doCheckout");
		}
		
		return retRevision;
	}

	/**
	 * 输出详细错误信息
	 *
	 * @param path CHECKOUT的版本库的路径
	 * @param revision 修订版本号-1作为最新修订号
	 * @param wcPath 存放checkout后文件的路径
	 * @param isRecursive 若为true则递归处理
	 * @return 详细错误列表
	 */
	private List<String> createErrorDetailListForDoCheckout(final String path, final long revision, final String wcPath,
			final boolean isRecursive) {

		List<String> errorDetailList = new ArrayList<String>();
		errorDetailList.add("url=" + this._svnConnection.getRootUrl());
		errorDetailList.add("username=" + this._svnConnection.getUsername());
		errorDetailList.add("path=" + path);
		errorDetailList.add("revision=" + revision);
		errorDetailList.add("wcPath=" + wcPath);
		errorDetailList.add("isRecursive=" + isRecursive);

		return errorDetailList;
	}
	
	/**
	 * Checkout版本库的文件
	 *
	 * <UL><B>异常编号：异常内容</B>
	 * <LI>20000001：Subversion连接失败
	 * <LI>20000002：未知主机
	 * <LI>20000003：认证失败
	 * <LI>20000004：未指定要进行checkout的版本库路径
	 * <LI>20000004：未指定checkout保存的文件名
	 * <LI>20000005：版本库的路径中含有空格
	 * <LI>20000007：指定的是一个文件名不是一个路径
	 * <LI>20000013：要进行checkout的版本库资源不存在
	 * <LI>20000026：要进行checkout的版本库资源版本号不存在
	 * <LI>20000045：指定的目录不是工作副本目录
	 * <LI>20000047：该目录资源被其他用户的工作副本目录LOCK
	 * <LI>20000048：工作副本目录中存在版本未受控的文件
	 * <LI>20009999：未知异常
	 * </UL>
	 *
	 * @param path 要进行checkout的版本库路径
	 * @param revision 要进行checkout的版本号为-1时，则作为最新的版本号
	 * @param wcPath checkout保存的文件名
	 * @return revision=-1则返回版本库最新的版本号，revision>1则返回与revision相同的版本号
	 */
	public final long doCheckoutFile(final String path, final long revision, final String wcPath) {

		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doCheckoutFile");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "path;revision;wcPath", path + ";" + revision + ";" + wcPath);
		}

		if (path == null || path.trim().equals("")) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "要checkout的文件路径");
			}
			throw new ComponentException("未指定要checkout的文件路径",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}

		if (wcPath == null || wcPath.trim().equals("")) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "checkout后的文件名");
			}
			throw new ComponentException("未指定checkout后的文件名",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}

		long retRevision = 0;
		try {
			SVNRevision svnRevision;
			if (revision < 0) {
				svnRevision = SVNRevision.HEAD;
			} else {
				svnRevision = SVNRevision.create(revision);
			}
			
			ISVNOptions options = SVNWCUtil.createDefaultOptions(true);
			SVNUpdateClient client =
				new SVNUpdateClient(this._svnConnection.getISVNAuthenticationManager(), options);

			String repositoryPath = null;
			int index = path.lastIndexOf("/");
			if (index != -1) {
				repositoryPath = this._svnConnection.getRootUrl() + path.substring(0, index);
			} else {
				if (logger.isEnableFor("Component2017")) {
					logger.log("Component2017", path);
				}
				throw new ComponentException("checkout的资源版本库路径错误，不存在【/】",
						ComponentSvnConst.ERROR_INVALID_REPOSITORY);
			}

			// 只checkout目录
			client.doCheckout(SVNURL.parseURIEncoded(repositoryPath),
					new File(wcPath), svnRevision, svnRevision, SVNDepth.EMPTY, false);

			String[] wcPaths = new String[1];
			wcPaths[0] = wcPath + path.substring(index);
			retRevision = doUpdate(wcPaths, revision, false)[0];

		} catch (SVNAuthenticationException e) {
			if (logger.isEnableFor("Component2003")) {
				logger.log("Component2003", e, this._svnConnection.getRootUrl(),
						this._svnConnection.getUsername(), e.getMessage());
			}

			List<String> errorDetailList = createErrorDetailListForDoCheckoutFile(path, revision, wcPath);
			throw new ComponentException("认证失败",
					ComponentSvnConst.ERROR_AUTHENTICATION, errorDetailList, e);

		} catch (SVNException e) {
			if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONNECTION_REFUSED) != -1) {
				if (logger.isEnableFor("Component2001")) {
					logger.log("Component2001", e, this._svnConnection.getRootUrl(),
							this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCheckoutFile(path, revision, wcPath);
				throw new ComponentException("连接失败",
						ComponentSvnConst.ERROR_CONNECT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.UNKNOWN_HOST) != -1) {
				if (logger.isEnableFor("Component2002")) {
					logger.log("Component2002", e, this._svnConnection.getRootUrl(),
							this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCheckoutFile(path, revision, wcPath);
				throw new ComponentException("未知的主机",
						ComponentSvnConst.ERROR_UNKNOWN_HOST, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONTAINS_INVALID_ELEMENT) != -1) {
				if (logger.isEnableFor("Component2005")) {
					logger.log("Component2005", e, path, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCheckoutFile(path, revision, wcPath);
				throw new ComponentException("版本库路径错误，含有非法对象",
						ComponentSvnConst.ERROR_CONTAINS_INVALID_ELEMENT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.NOT_EXIST2) != -1) {
				if (logger.isEnableFor("Component2013")) {
					logger.log("Component2013", e, path, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCheckoutFile(path, revision, wcPath);
				throw new ComponentException("要checkout的资源不存在",
						ComponentSvnConst.ERROR_DOES_NOT_EXIST_FOR_CHECKOUT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.NO_SUCH_REVISION) != -1) {
				if (logger.isEnableFor("Component2026")) {
					logger.log("Component2026", e, path, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCheckoutFile(path, revision, wcPath);
				throw new ComponentException("要checkout的版本不存在",
						ComponentSvnConst.ERROR_NO_SUCH_REVISION, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.ALREADY_WORKING_COPY) != -1) {
				if (logger.isEnableFor("Component2047")) {
					logger.log("Component2047", e, path, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCheckoutFile(path, revision, wcPath);
				throw new ComponentException("该目录正在被其他URL的工作目录使用",
						ComponentSvnConst.ERROR_ALREADY_WORKING_COPY, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CANNOT_CREATE_NEW_FILE) != -1) {
				if (logger.isEnableFor("Component2064")) {
					logger.log("Component2064", e, path, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCheckoutFile(path, revision, wcPath);
				throw new ComponentException("不能新建文件",
						ComponentSvnConst.ERROR_CANNOT_CREATE_NEW_FILE, errorDetailList, e);
			} else {
				if (logger.isEnableFor("Component2999")) {
					logger.log("Component2999", e, e.getMessage(), "path;revision;wcPath", path + ";" + revision + ";" + wcPath);
				}

				List<String> errorDetailList = createErrorDetailListForDoCheckoutFile(path, revision, wcPath);
				throw new ComponentException("未知异常",
						ComponentSvnConst.ERROR_UNKNOWN, errorDetailList, e);
			}
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doCheckoutFile");
		}
		
		return retRevision;
	}
	
	/**
	 * 输出详细错误信息
	 *
	 * @param path CHECKOUT的版本库的路径
	 * @param revision 修订版本号-1作为最新修订号
	 * @param wcPath 存放checkout后文件的路径
	 * @return 详细错误列表
	 */
	private List<String> createErrorDetailListForDoCheckoutFile(final String path, final long revision, final String wcPath) {

		List<String> errorDetailList = new ArrayList<String>();
		errorDetailList.add("url=" + this._svnConnection.getRootUrl());
		errorDetailList.add("username=" + this._svnConnection.getUsername());
		errorDetailList.add("path=" + path);
		errorDetailList.add("revision=" + revision);
		errorDetailList.add("wcPath=" + wcPath);

		return errorDetailList;
	}

	/**
	 * 导出版本库的文件和目录
	 *
	 * <UL><B>异常编号：异常内容</B>
	 * <LI>20000001：Subversion连接失败
	 * <LI>20000002：未知主机	 * <LI>20000003：认证失败
	 * <LI>20000004：未指定要导出对象的版本库路径	 * <LI>20000004：未指定导出对象保存的地址路径	 * <LI>20000005：版本库路径中含有空格
	 * <LI>20000014：要导出的版本库资源不存在
	 * <LI>20000026：要导出指定版本号的资源不存在
	 * <LI>20009999：未知异常
	 * </UL>
	 *
	 * @param path 要导出对象的版本库路径
	 * @param revision为-1时，导出最新版本的对象
	 * @param exportPath 导出对象保存的地址路径
	 * @param isRecursive true则进行递归导出
	 * @return 导出时的版本号
	 */
	public final long doExport(final String path, final long revision, final String exportPath,
			final boolean isRecursive) {

		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doExport");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "path;revision;exportPath;isRecursive",
						path + ";" + revision + ";" + exportPath + ";" + isRecursive);
		}

		if (path == null || path.trim().equals("")) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "要导出对象的版本库路径");
			}
			throw new ComponentException("未指定要导出对象的版本库路径",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}
		if (exportPath == null || exportPath.trim().equals("")) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "导出对象保存的地址路径");
			}
			throw new ComponentException("未指定导出对象保存的地址路径",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}

		long exportRevision = 0;
		try {
			SVNRevision svnRevision;
			if (revision < 0) {
				svnRevision = SVNRevision.HEAD;
			} else {
				svnRevision = SVNRevision.create(revision);
			}

			SVNDepth depth;
			if (isRecursive) {
				depth = SVNDepth.INFINITY;
			} else {
				depth = SVNDepth.FILES;
			}

			SVNURL svnUrl = SVNURL.parseURIEncoded(this._svnConnection.getRootUrl() + path);
			ISVNOptions options = SVNWCUtil.createDefaultOptions(true);
			SVNUpdateClient client =
				new SVNUpdateClient(this._svnConnection.getISVNAuthenticationManager(), options);

			exportRevision = client.doExport(svnUrl, new File(exportPath), svnRevision, svnRevision, null, true, depth);

		} catch (SVNAuthenticationException e) {
			if (logger.isEnableFor("Component2003")) {
				logger.log("Component2003", e, this._svnConnection.getRootUrl(),
						this._svnConnection.getUsername(), e.getMessage());
			}
			
			List<String> errorDetailList = createErrorDetailListForDoExport(path, revision, exportPath, isRecursive);
			throw new ComponentException("认证失败",
					ComponentSvnConst.ERROR_AUTHENTICATION, errorDetailList, e);

		} catch (SVNException e) {
			if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONNECTION_REFUSED) != -1) {
				if (logger.isEnableFor("Component2001")) {
					logger.log("Component2001", e, this._svnConnection.getRootUrl(),
							this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoExport(path, revision, exportPath, isRecursive);
				throw new ComponentException("连接失败",
						ComponentSvnConst.ERROR_CONNECT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.UNKNOWN_HOST) != -1) {
				if (logger.isEnableFor("Component2002")) {
					logger.log("Component2002", e, this._svnConnection.getRootUrl(),
							this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoExport(path, revision, exportPath, isRecursive);
				throw new ComponentException("未知主机",
						ComponentSvnConst.ERROR_UNKNOWN_HOST, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONTAINS_INVALID_ELEMENT) != -1) {
				if (logger.isEnableFor("Component2005")) {
					logger.log("Component2005", e, path, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoExport(path, revision, exportPath, isRecursive);
				throw new ComponentException("版本库路径错误，含有非法对象",
						ComponentSvnConst.ERROR_CONTAINS_INVALID_ELEMENT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.DOESNT_EXIST) != -1) {
				if (logger.isEnableFor("Component2014")) {
					logger.log("Component2014", e, path, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoExport(path, revision, exportPath, isRecursive);
				throw new ComponentException("要导出的对象不存在",
						ComponentSvnConst.ERROR_DOES_NOT_EXIST_FOR_EXPORT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.NO_SUCH_REVISION) != -1) {
				if (logger.isEnableFor("Component2027")) {
					logger.log("Component2027", e, path, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoExport(path, revision, exportPath, isRecursive);
				throw new ComponentException("要导出的指定版本的对象不存在",
						ComponentSvnConst.ERROR_NO_SUCH_REVISION, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CANNOT_CREATE_DIRECTORY) != -1) {
				if (logger.isEnableFor("Component2033")) {
					logger.log("Component2033", e, path, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoExport(path, revision, exportPath, isRecursive);
				throw new ComponentException("不能新建目录",
						ComponentSvnConst.ERROR_CAN_NOT_CREATE_DIRECTORY, errorDetailList, e);
			} else {
				if (logger.isEnableFor("Component2999")) {
					logger.log("Component2999", e, e.getMessage(),
												  "path;revision;exportPath;isRecursive",
												  path + ";"
												  + revision + ";"
												  + exportPath + ";"
												  + isRecursive);
				}

				List<String> errorDetailList = createErrorDetailListForDoExport(path, revision, exportPath, isRecursive);
				throw new ComponentException("未知异常",
						ComponentSvnConst.ERROR_UNKNOWN, errorDetailList, e);
			}
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doExport");
		}

		return exportRevision;
	}
	
	/**
	 * 输出异常详细列表
	 *
	 * @param path 要导出对象的版本库路径
	 * @param revision为-1时，导出最新版本的对象
	 * @param exportPath 导出对象保存的地址路径
	 * @param isRecursive true则进行递归导出
	 * @return 详细异常列表
	 */
	private List<String> createErrorDetailListForDoExport(final String path, final long revision, final String exportPath,
			final boolean isRecursive) {

		List<String> errorDetailList = new ArrayList<String>();
		errorDetailList.add("url=" + this._svnConnection.getRootUrl());
		errorDetailList.add("username=" + this._svnConnection.getUsername());
		errorDetailList.add("path=" + path);
		errorDetailList.add("revision=" + revision);
		errorDetailList.add("exportPath=" + exportPath);
		errorDetailList.add("isRecursive=" + isRecursive);

		return errorDetailList;
	}

	/**
	 * 建立标记副本
	 *
	 * <UL><B>异常编号：异常内容</B>
	 * <LI>20000001：Subversion连接失败
	 * <LI>20000002：未知主机	 * <LI>20000003：认证失败
	 * <LI>20000004：未指定复制源对象的版本库路径	 * <LI>20000004：未指定复制对象保存的版本库地址路径	 * <LI>20000005：版本库路径中含有空格
	 * <LI>20000015：版本库资源不存在
	 * <LI>20000028：指定的复制源对象的版本不存在
	 * <LI>20000032：复制对象保存的版本库地址路径已经存在
	 * <LI>20009999：未知异常
	 * </UL>
	 *
	 * @param sourcePath 复制源对象的版本库路径
	 * @param copyRevision 复制源对象的版本号，为-1时代表最新的版本号
	 * @param dstPath 复制对象保存的版本库地址路径
	 * @param makeParents true则同时创建上级父目录	 * @param commitMessage 提交的描述信息
	 * @return 地址版本的版本号
	 */
	public final long doCopy(final String sourcePath, final long copyRevision, final String dstPath, final boolean makeParents,
			final String commitMessage) {

		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doCopy");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "sourcePath;copyRevision;dstPath;makeParents;commitMessage",
						sourcePath + ";" + copyRevision + ";" + dstPath + ";" + makeParents + ";" + commitMessage);
		}

		if (sourcePath == null || sourcePath.trim().equals("")) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "要复制的源文件的版本库路径");
			}
			throw new ComponentException("未指定要复制的源文件的版本库路径",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}

		if (dstPath == null || dstPath.trim().equals("")) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "要复制的文件的目的地路径");
			}
			throw new ComponentException("未指定要复制的文件的目的地路径",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}

		long revision = 0;
		try {
			SVNRevision svnRevision;
			if (copyRevision < 0) {
				svnRevision = SVNRevision.HEAD;
			} else {
				svnRevision = SVNRevision.create(copyRevision);
			}

			SVNURL svnSourceUrl = SVNURL.parseURIEncoded(this._svnConnection.getRootUrl() + sourcePath);
			SVNURL svnDstUrl = SVNURL.parseURIEncoded(this._svnConnection.getRootUrl() + dstPath);

			SVNCopySource[] sources =
					{new SVNCopySource(svnRevision, svnRevision, svnSourceUrl)};

			ISVNOptions options = SVNWCUtil.createDefaultOptions(true);
			SVNCopyClient client =
				new SVNCopyClient(this._svnConnection.getISVNAuthenticationManager(), options);
			SVNCommitInfo svnCommitInfo = client.doCopy(sources, svnDstUrl, false, makeParents,
					true, commitMessage, null);

			revision = svnCommitInfo.getNewRevision();

		} catch (SVNAuthenticationException e) {
			if (logger.isEnableFor("Component2003")) {
				logger.log("Component2003", e, this._svnConnection.getRootUrl(),
						this._svnConnection.getUsername(), e.getMessage());
			}

			List<String> errorDetailList = createErrorDetailListForDoCopy(sourcePath, copyRevision, dstPath, makeParents, commitMessage);
			throw new ComponentException("认证失败",
					ComponentSvnConst.ERROR_AUTHENTICATION, errorDetailList, e);

		} catch (SVNException e) {
			if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONNECTION_REFUSED) != -1) {
				if (logger.isEnableFor("Component2001")) {
					logger.log("Component2001", e, this._svnConnection.getRootUrl(),
							this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCopy(sourcePath, copyRevision, dstPath, makeParents, commitMessage);
				throw new ComponentException("连接失败",
						ComponentSvnConst.ERROR_CONNECT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.UNKNOWN_HOST) != -1) {
				if (logger.isEnableFor("Component2002")) {
					logger.log("Component2002", e, this._svnConnection.getRootUrl(),
							this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCopy(sourcePath, copyRevision, dstPath, makeParents, commitMessage);
				throw new ComponentException("未知主机",
						ComponentSvnConst.ERROR_UNKNOWN_HOST, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONTAINS_INVALID_ELEMENT) != -1) {
				if (logger.isEnableFor("Component2005")) {
					logger.log("Component2005", e, sourcePath, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCopy(sourcePath, copyRevision, dstPath, makeParents, commitMessage);
				throw new ComponentException("版本库路径错误，含有非法对象",
						ComponentSvnConst.ERROR_CONTAINS_INVALID_ELEMENT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.DOES_NOT_EXIST_IN_REVISION) != -1) {
				if (logger.isEnableFor("Component2015")) {
					logger.log("Component2015", e, sourcePath, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCopy(sourcePath, copyRevision, dstPath, makeParents, commitMessage);
				throw new ComponentException("版本不存在",
						ComponentSvnConst.ERROR_DOES_NOT_EXIST_FOR_COPY, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.NO_SUCH_REVISION) != -1) {
				if (logger.isEnableFor("Component2028")) {
					logger.log("Component2028", e, sourcePath, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCopy(sourcePath, copyRevision, dstPath, makeParents, commitMessage);
				throw new ComponentException("要复制的源文件的指定版本不存在",
						ComponentSvnConst.ERROR_NO_SUCH_REVISION, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.ALREADY_EXISTS) != -1) {
				if (logger.isEnableFor("Component2032")) {
					logger.log("Component2032", e, dstPath, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoCopy(sourcePath, copyRevision, dstPath, makeParents, commitMessage);
				throw new ComponentException("要复制的文件在要保存的地址地路径中已经存在",
						ComponentSvnConst.ERROR_PATH_ALREADY_EXISTS, errorDetailList, e);
			} else {
				if (logger.isEnableFor("Component2999")) {
					logger.log("Component2999", e, e.getMessage(),
												  "sourcePath;dstPath;makeParents;commitMessage",
												  sourcePath + ";"
												  + dstPath + ";"
												  + makeParents + ";"
												  + commitMessage);
				}

				List<String> errorDetailList = createErrorDetailListForDoCopy(sourcePath, copyRevision, dstPath, makeParents, commitMessage);
				throw new ComponentException("未知异常",
						ComponentSvnConst.ERROR_UNKNOWN, errorDetailList, e);
			}
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doCopy");
		}

		return revision;
	}
	
	/**
	 * 输出详细异常列表
	 *
	 * @param sourcePath 复制源对象的版本库路径
	 * @param copyRevision 复制源对象的版本号，为-1时代表最新的版本号
	 * @param dstPath 复制对象保存的版本库地址路径
	 * @param makeParents true则同时创建上级父目录	 * @param commitMessage 提交的描述信息
	 * @return 详细异常信息
	 */
	private List<String> createErrorDetailListForDoCopy(final String sourcePath, final long copyRevision, 
			final String dstPath, final boolean makeParents, final String commitMessage) {

		List<String> errorDetailList = new ArrayList<String>();
		errorDetailList.add("url=" + this._svnConnection.getRootUrl());
		errorDetailList.add("username=" + this._svnConnection.getUsername());
		errorDetailList.add("sourcePath=" + sourcePath);
		errorDetailList.add("copyRevision=" + copyRevision);
		errorDetailList.add("dstPath=" + dstPath);
		errorDetailList.add("makeParents=" + makeParents);
		errorDetailList.add("commitMessage=" + commitMessage);

		return errorDetailList;
	}
	
	/**
	 * SVN上的文件或者目录复制的时候变更名称
	 *
	 * <UL><B>异常编号：异常内容</B>
	 * <LI>20000001：Subversion连接失败
	 * <LI>20000002：未知主机	 * <LI>20000003：认证失败
	 * <LI>20000004：未指定复制源对象的版本库路径	 * <LI>20000004：未指定复制对象保存的版本库地址路径	 * <LI>20000005：版本库路径中含有空格
	 * <LI>20000015：版本库资源不存在
	 * <LI>20000028：指定的复制源对象的版本不存在
	 * <LI>20000032：复制对象保存的版本库地址路径已经存在
	 * <LI>20009999：未知异常
	 * </UL>
	 *
	 * @param sourcePath 复制源对象的版本库路径
	 * @param copyRevision 复制源对象的版本号，为-1时代表最新的版本号
	 * @param dstPath 复制对象保存的版本库地址路径
	 * @param commitMessage 提交的描述信息
	 * @return 地址版本的版本号
	 */
	
	public final long doRenameCopy(final String sourcePath, final long copyRevision, final String dstPath, final String commitMessage) {

		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doRenameCopy");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "sourcePath;copyRevision;dstPath;commitMessage",
						sourcePath + ";" + copyRevision + ";" + dstPath + ";" + commitMessage);
		}

		long revision = doCopy(sourcePath, copyRevision, dstPath, true, commitMessage);

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doRenameCopy");
		}

		return revision;
	}

	/**
	 * 版本库中新建目录
	 *
	 * <UL><B>异常编号：异常内容</B>
	 * <LI>20000001：Subversion连接失败
	 * <LI>20000002：未知主机	 * <LI>20000003：认证失败
	 * <LI>20000004：未指定要新建的目录路径	 * <LI>20000005：版本库路径中含有空格
	 * <LI>20000011：版本库的上级父目录不存在(makeParents=false)
	 * <LI>20000031：版本库中地址路径已经存在	 * <LI>20009999：未知异常
	 * </UL>
	 *
	 * @param path 要新建的目录路径
	 * @param commitMessage 提交的描述信息
	 * @param makeParents 指定true则递归作成目录	 * @return 新建目录后版本库的最新版本号
	 */
	public final long doMkdir(final String path, final String commitMessage, final boolean makeParents) {

		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doMkdir");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "path;commitMessage;makeParents",
						path + ";" + commitMessage + ";" + makeParents);
		}

		if (path == null || path.trim().equals("")) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "新建目录的路径");
			}
			throw new ComponentException("未指定新建目录的路径",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}

		if (isExistDir(path)) {
			if (logger.isEnableFor("Component2031")) {
				logger.log("Component2031", path);
			}
			throw new ComponentException("版本库中目录已经存在",
					ComponentSvnConst.ERROR_ALREADY_EXISTS);
		}

		if (path.indexOf("..") > 0) {
			if (logger.isEnableFor("Component2005")) {
				logger.log("Component2005", path, "");
			}
			throw new ComponentException("版本库路径错误，含有非法对象",
					ComponentSvnConst.ERROR_CONTAINS_INVALID_ELEMENT);
		}

		long revision = 0;
		try {
			// 没有建立上层父目录时
			if (!makeParents) {
				int index = 0;
				if (path.endsWith("/")) {
					index = path.substring(0, path.length() - 1).lastIndexOf("/");
				} else {
					index = path.lastIndexOf("/");
				}
				if (index != -1) {
					String parentPath = path.substring(0, index);

					if (!parentPath.equals("") && !isExistDir(parentPath)) {
						if (logger.isEnableFor("Component2011")) {
							logger.log("Component2011", path);
						}

						List<String> errorDetailList = createErrorDetailListForDoMkdir(path, commitMessage, makeParents);
						throw new ComponentException("版本库中上层父目录不存在",
								ComponentSvnConst.ERROR_DOES_NOT_EXIST, errorDetailList);
					}
				}
			}

			SVNURL[] svnUrl = {SVNURL.parseURIEncoded(this._svnConnection.getRootUrl() + path)};

			ISVNOptions options = SVNWCUtil.createDefaultOptions(true);
			SVNCommitInfo cInfo = null;
			SVNCommitClient client =
				new SVNCommitClient(this._svnConnection.getISVNAuthenticationManager(), options);
			cInfo = client.doMkDir(svnUrl, commitMessage, null, makeParents);			
			revision = cInfo.getNewRevision();

		} catch (SVNAuthenticationException e) {
			if (logger.isEnableFor("Component2003")) {
				logger.log("Component2003", e, this._svnConnection.getRootUrl(),
						this._svnConnection.getUsername(), e.getMessage());
			}

			List<String> errorDetailList = createErrorDetailListForDoMkdir(path, commitMessage, makeParents);
			throw new ComponentException("认证失败",
					ComponentSvnConst.ERROR_AUTHENTICATION, errorDetailList, e);

		} catch (SVNException e) {
			if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONNECTION_REFUSED) != -1) {
				if (logger.isEnableFor("Component2001")) {
					logger.log("Component2001", e, this._svnConnection.getRootUrl(),
							this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoMkdir(path, commitMessage, makeParents);
				throw new ComponentException("连接失败",
						ComponentSvnConst.ERROR_CONNECT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.UNKNOWN_HOST) != -1) {
				if (logger.isEnableFor("Component2002")) {
					logger.log("Component2002", e, this._svnConnection.getRootUrl(),
							this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoMkdir(path, commitMessage, makeParents);
				throw new ComponentException("未知的主机",
						ComponentSvnConst.ERROR_UNKNOWN_HOST, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.FILE_NOT_FOUND) != -1) {
				if (logger.isEnableFor("Component2011")) {
					logger.log("Component2011", e, path);
				}

				List<String> errorDetailList = createErrorDetailListForDoMkdir(path, commitMessage, makeParents);
				throw new ComponentException("版本库中上层父目录不存在",
						ComponentSvnConst.ERROR_DOES_NOT_EXIST, errorDetailList, e);
			} else {
				if (logger.isEnableFor("Component2999")) {
					logger.log("Component2999", e, e.getMessage(),
												  "path;commitMessage;makeParents",
												  path + ";"
												  + commitMessage + ";"
												  + makeParents);
				}

				List<String> errorDetailList = createErrorDetailListForDoMkdir(path, commitMessage, makeParents);
				throw new ComponentException("未知异常",
						ComponentSvnConst.ERROR_UNKNOWN, errorDetailList, e);
			}
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doMkdir");
		}
		
		return revision;
	}

	/**
	 * 输出详细异常信息
	 *
	 * @param path 要新建的目录路径
	 * @param commitMessage 提交的描述信息
	 * @param makeParents 指定true则递归作成	 * @return 详细异常信息列表
	 */
	private List<String> createErrorDetailListForDoMkdir(final String path, final String commitMessage, final boolean makeParents) {

		List<String> errorDetailList = new ArrayList<String>();
		errorDetailList.add("url=" + this._svnConnection.getRootUrl());
		errorDetailList.add("username=" + this._svnConnection.getUsername());
		errorDetailList.add("path=" + path);
		errorDetailList.add("commitMessage=" + commitMessage);
		errorDetailList.add("makeParents=" + makeParents);

		return errorDetailList;
	}

	/**
	 * 判断指定的目录在项目文件库中是否存在
	 *
	 * <UL><B>异常编号：异常内容</B>
	 * <LI>20000001：Subversion连接失败
	 * <LI>20000002：未知主机	 * <LI>20000003：认证失败	 * <LI>20000004：未指定需要判断是否存在的路径
	 * <LI>20009999：发生未知异常	 * </UL>
	 *
	 * @param path 要确认是否存在的路径
	 * @return 若存在返回ture
	 */
	public final boolean isExistDir(final String path) {

		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "isExistDir");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "path", path);
		}

		if (path == null || path.trim().equals("")) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "检查目录存在的目录路径");
			}
			throw new ComponentException("未指定检查目录存在的目录路径",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}

		boolean isExist = false;
		try {
			String checkPath = URLDecoder.decode(path, "UTF8");
			SVNNodeKind nodeKind = this._svnConnection.getRepository().checkPath(checkPath, -1);

			isExist = (nodeKind == SVNNodeKind.DIR);

		} catch (SVNAuthenticationException e) {
			if (logger.isEnableFor("Component2003")) {
				logger.log("Component2003", e, this._svnConnection.getRootUrl(),
						this._svnConnection.getUsername(), e.getMessage());
			}

			List<String> errorDetailList = createErrorDetailListForIsExistDir(path);
			throw new ComponentException("认证失败",
					ComponentSvnConst.ERROR_AUTHENTICATION, errorDetailList, e);

		} catch (SVNException e) {
			if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONNECTION_REFUSED) != -1) {
				if (logger.isEnableFor("Component2001")) {
					logger.log("Component2001", e, this._svnConnection.getRootUrl(),
							this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForIsExistDir(path);
				throw new ComponentException("连接失败",
						ComponentSvnConst.ERROR_CONNECT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.UNKNOWN_HOST) != -1) {
				if (logger.isEnableFor("Component2002")) {
					logger.log("Component2002", e, this._svnConnection.getRootUrl(),
							this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForIsExistDir(path);
				throw new ComponentException("未知的主机",
						ComponentSvnConst.ERROR_UNKNOWN_HOST, errorDetailList, e);
			} else {
				if (logger.isEnableFor("Component2999")) {
					logger.log("Component2999", e, e.getMessage(), "path", path);
				}

				List<String> errorDetailList = createErrorDetailListForIsExistDir(path);
				throw new ComponentException("未知异常",
						ComponentSvnConst.ERROR_UNKNOWN, errorDetailList, e);
			}

		} catch (UnsupportedEncodingException e) {
			if (logger.isEnableFor("Component2999")) {
				logger.log("Component2999", e, e.getMessage(), "path", path);
			}

			List<String> errorDetailList = createErrorDetailListForIsExistDir(path);
			throw new ComponentException("未知异常",
					ComponentSvnConst.ERROR_UNKNOWN, errorDetailList, e);
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "isExistDir");
		}

		return isExist;
	}

	/**
	 * 输出详细异常信息
	 *
	 * @param path 检查目录存在的目录路径
	 * @return 详细异常列表
	 */
	private List<String> createErrorDetailListForIsExistDir(final String path) {

		List<String> errorDetailList = new ArrayList<String>();
		errorDetailList.add("url=" + this._svnConnection.getRootUrl());
		errorDetailList.add("username=" + this._svnConnection.getUsername());
		errorDetailList.add("path=" + path);

		return errorDetailList;
	}

	/**
	 * 判断指定的文件在项目文件库中是否存在
	 *
	 * <UL><B>异常编码：异常内容</B>
	 * <LI>20000001：Subversion连接失败
	 * <LI>20000002：未知主机	 * <LI>20000003：认证失败	 * <LI>20000004：未指定需要判断是否存在的文件
	 * <LI>20009999：发生未知异常	 * </UL>
	 *
	 * @param path 要确认文件是否存在的文件路径
	 * @return 若存在返回true
	 */
	public final boolean isExistFile(final String path) {

		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "isExistFile");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "path", path);
		}

		if (path == null || path.trim().equals("")) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "检查文件是否存在的文件路径");
			}
			throw new ComponentException("未指定检查文件是否存在的文件路径",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}

		boolean isExist = false;
		try {
			String checkPath = URLDecoder.decode(path, "UTF8");
			SVNNodeKind nodeKind = this._svnConnection.getRepository().checkPath(checkPath, -1);

			isExist = (nodeKind == SVNNodeKind.FILE);

		} catch (SVNAuthenticationException e) {
			if (logger.isEnableFor("Component2003")) {
				logger.log("Component2003", e, this._svnConnection.getRootUrl(),
						this._svnConnection.getUsername(), e.getMessage());
			}

			List<String> errorDetailList = createErrorDetailListForIsExistFile(path);
			throw new ComponentException("认证失败",
					ComponentSvnConst.ERROR_AUTHENTICATION, errorDetailList, e);

		} catch (SVNException e) {
			if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONNECTION_REFUSED) != -1) {
				if (logger.isEnableFor("Component2001")) {
					logger.log("Component2001", e, this._svnConnection.getRootUrl(),
							this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForIsExistFile(path);
				throw new ComponentException("连接失败",
						ComponentSvnConst.ERROR_CONNECT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.UNKNOWN_HOST) != -1) {
				if (logger.isEnableFor("Component2002")) {
					logger.log("Component2002", e, this._svnConnection.getRootUrl(),
							this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForIsExistFile(path);
				throw new ComponentException("未知的主机",
						ComponentSvnConst.ERROR_UNKNOWN_HOST, errorDetailList, e);
			} else {
				if (logger.isEnableFor("Component2999")) {
					logger.log("Component2999", e, e.getMessage(), "path", path);
				}

				List<String> errorDetailList = createErrorDetailListForIsExistFile(path);
				throw new ComponentException("未知异常",
						ComponentSvnConst.ERROR_UNKNOWN, errorDetailList, e);
			}

		} catch (UnsupportedEncodingException e) {
			if (logger.isEnableFor("Component2999")) {
				logger.log("Component2999", e, e.getMessage(), "path", path);
			}

			List<String> errorDetailList = createErrorDetailListForIsExistFile(path);
			throw new ComponentException("未知异常",
					ComponentSvnConst.ERROR_UNKNOWN, errorDetailList, e);
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "isExistFile");
		}

		return isExist;
	}

	/**
	 * 输出详细异常信息
	 *
	 * @param path 检查文件存在的文件路径
	 * @return 详细异常列表
	 */
	private List<String> createErrorDetailListForIsExistFile(final String path) {

		List<String> errorDetailList = new ArrayList<String>();
		errorDetailList.add("url=" + this._svnConnection.getRootUrl());
		errorDetailList.add("username=" + this._svnConnection.getUsername());
		errorDetailList.add("path=" + path);

		return errorDetailList;
	}

	/**
	 * 取得指定版本库的最新版本号
	 *
	 * <UL><B>异常编码：异常内容</B>
	 * <LI>20000001：Subversion连接失败
	 * <LI>20000002：未知主机	 * <LI>20000003：认证失败
	 * <LI>20000004：未指定要取得最新版本号的版本库路径	 * <LI>20000005：版本库路径中含有空格
	 * <LI>20000016：要取得最新版本号的版本库不存在
	 * <LI>20009999：未知异常
	 * </UL>
	 *
	 * @param path 要取得最新版本号的路径	 * @return 版本库的最新的历史版本号	 */
	public final long getLatestRevision(final String path) {

		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getLatestRevision");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "path", path);
		}

		if (path == null || path.trim().equals("")) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "要取得最新版本号的资源路径");
			}
			throw new ComponentException("未指定要取得最新版本号的资源路径",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}

		long revision = 0;
		try {
			String checkPath = URLDecoder.decode(path, "UTF8");
			SVNRepository repository = this._svnConnection.getRepository();

			// 取得版本库的信息			SVNDirEntry dirEntry = repository.info(checkPath, -1);

			// 取得版本库的种别			SVNNodeKind nodeKind = repository.checkPath(checkPath, -1);

			if (nodeKind == SVNNodeKind.NONE) {
				if (logger.isEnableFor("Component2016")) {
					logger.log("Component2016", path);
				}

				List<String> errorDetailList = createErrorDetailListForGetLatestRevision(path);
				throw new ComponentException("要取得最新版本号的资源不存在",
						ComponentSvnConst.ERROR_DOES_NOT_EXIST_FOR_REVISION, errorDetailList);
			}

			revision = dirEntry.getRevision();

		} catch (SVNAuthenticationException e) {
			if (logger.isEnableFor("Component2003")) {
				logger.log("Component2003", e, this._svnConnection.getRootUrl(),
						this._svnConnection.getUsername(), e.getMessage());
			}

			List<String> errorDetailList = createErrorDetailListForGetLatestRevision(path);
			throw new ComponentException("认证失败",
					ComponentSvnConst.ERROR_AUTHENTICATION, errorDetailList, e);

		} catch (SVNException e) {
			if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONNECTION_REFUSED) != -1) {
				if (logger.isEnableFor("Component2001")) {
					logger.log("Component2001", e, this._svnConnection.getRootUrl(),
							this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForGetLatestRevision(path);
				throw new ComponentException("连接失败",
						ComponentSvnConst.ERROR_CONNECT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.UNKNOWN_HOST) != -1) {
				if (logger.isEnableFor("Component2002")) {
					logger.log("Component2002", e, this._svnConnection.getRootUrl(),
							this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForGetLatestRevision(path);
				throw new ComponentException("未知的主机",
						ComponentSvnConst.ERROR_UNKNOWN_HOST, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONTAINS_INVALID_ELEMENT) != -1) {
				if (logger.isEnableFor("Component2005")) {
					logger.log("Component2005", e, path, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForGetLatestRevision(path);
				throw new ComponentException("版本库路径错误，含有非法对象",
						ComponentSvnConst.ERROR_CONTAINS_INVALID_ELEMENT, errorDetailList, e);
			} else {
				if (logger.isEnableFor("Component2999")) {
					logger.log("Component2999", e, e.getMessage(), "path", path);
				}

				List<String> errorDetailList = createErrorDetailListForGetLatestRevision(path);
				throw new ComponentException("未知异常",
						ComponentSvnConst.ERROR_UNKNOWN, errorDetailList, e);
			}

		} catch (UnsupportedEncodingException e) {
			if (logger.isEnableFor("Component2999")) {
				logger.log("Component2999", e, e.getMessage(), "path", path);
			}

			List<String> errorDetailList = createErrorDetailListForGetLatestRevision(path);
			throw new ComponentException("未知异常",
					ComponentSvnConst.ERROR_UNKNOWN, errorDetailList, e);
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "getLatestRevision");
		}

		return revision;
	}

	/**
	 * 输出详细异常信息
	 *
	 * @param path 要取得最新版本号的资源路径	 * @return 详细异常列表
	 */
	private List<String> createErrorDetailListForGetLatestRevision(final String path) {

		List<String> errorDetailList = new ArrayList<String>();
		errorDetailList.add("url=" + this._svnConnection.getRootUrl());
		errorDetailList.add("username=" + this._svnConnection.getUsername());
		errorDetailList.add("path=" + path);

		return errorDetailList;
	}

	/**
	 * 取得工作副本目录下文件的最新版本号
	 *
	 * <UL><B>异常编号：异常内容</B>
	 * <LI>20000001：Subversion连接失败
	 * <LI>20000002：未知主机	 * <LI>20000003：认证失败
	 * <LI>20000004：未指定工作副本目录上的文件	 * <LI>20000005：版本库路径中含有空格
	 * <LI>20000022：无法获得文件信息
	 * <LI>20000043：指定文件在工作副本目录下不存在
	 * <LI>20009999：未知异常
	 * </UL>
	 *
	 * @param wcPath 工作副本目录上的文件路径
	 * @return 工作副本目录下文件的最新版本号
	 */
	public final long getLatestWCRevision(final String wcPath) {

		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getLatestWCRevision");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "wcPath", wcPath);
		}

		SVNStatus status = getWCStatus(wcPath, false);
		long revision = status.getCommittedRevision().getNumber();

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "getLatestWCRevision");
		}

		return revision;
	}

	/**
	 * 取得指定的版本库的信息
	 *
	 * <UL><B>异常编号：异常内容</B>
	 * <LI>20000001：Subversion连接失败
	 * <LI>20000002：未知主机	 * <LI>20000003：认证失败
	 * <LI>20000004：未指定要取得文件信息的版本库路径	 * <LI>20000005：版本库路径中含有空格
	 * <LI>20009999：未知异常
	 * </UL>
	 *
	 * @param path 要取得文件信息的版本库路径
	 * @return SVNDirEntry对象
	 */
	public final SVNDirEntry getStatus(final String path) {

		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getStatus");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "path", path);
		}

		if (path == null || path.trim().equals("")) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "要取得文件信息的版本库路径");
			}
			throw new ComponentException("未指定要取得文件信息的版本库路径",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}

		SVNDirEntry dirEntry = null;
		try {
			String checkPath = URLDecoder.decode(path, "UTF8");
			dirEntry = this._svnConnection.getRepository().info(checkPath, -1);

		} catch (SVNAuthenticationException e) {
			if (logger.isEnableFor("Component2003")) {
				logger.log("Component2003", e, this._svnConnection.getRootUrl(),
						this._svnConnection.getUsername(), e.getMessage());
			}

			List<String> errorDetailList = createErrorDetailListForGetStatus(path);
			throw new ComponentException("认证失败",
					ComponentSvnConst.ERROR_AUTHENTICATION, errorDetailList, e);

		} catch (SVNException e) {
			if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONNECTION_REFUSED) != -1) {
				if (logger.isEnableFor("Component2001")) {
					logger.log("Component2001", e, this._svnConnection.getRootUrl(),
							this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForGetStatus(path);
				throw new ComponentException("连接失败",
						ComponentSvnConst.ERROR_CONNECT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.UNKNOWN_HOST) != -1) {
				if (logger.isEnableFor("Component2002")) {
					logger.log("Component2002", e, this._svnConnection.getRootUrl(),
							this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForGetStatus(path);
				throw new ComponentException("未知的主机",
						ComponentSvnConst.ERROR_UNKNOWN_HOST, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONTAINS_INVALID_ELEMENT) != -1) {
				if (logger.isEnableFor("Component2005")) {
					logger.log("Component2005", e, path, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForGetStatus(path);
				throw new ComponentException("版本库路径错误，含有非法对象",
						ComponentSvnConst.ERROR_CONTAINS_INVALID_ELEMENT, errorDetailList, e);
			} else {
				if (logger.isEnableFor("Component2999")) {
					logger.log("Component2999", e, e.getMessage(), "path", path);
				}

				List<String> errorDetailList = createErrorDetailListForGetStatus(path);
				throw new ComponentException("未知异常",
						ComponentSvnConst.ERROR_UNKNOWN, errorDetailList, e);
			}

		} catch (UnsupportedEncodingException e) {
			if (logger.isEnableFor("Component2999")) {
				logger.log("Component2999", e, e.getMessage(), "path", path);
			}

			List<String> errorDetailList = createErrorDetailListForGetStatus(path);
			throw new ComponentException("未知异常",
					ComponentSvnConst.ERROR_UNKNOWN, errorDetailList, e);
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "getStatus");
		}

		return dirEntry;
	}

	/**
	 * 输出详细异常列表
	 *
	 * @param path 要取得文件信息的版本库路径
	 * @return 详细异常列表
	 */
	private List<String> createErrorDetailListForGetStatus(final String path) {

		List<String> errorDetailList = new ArrayList<String>();
		errorDetailList.add("url=" + this._svnConnection.getRootUrl());
		errorDetailList.add("username=" + this._svnConnection.getUsername());
		errorDetailList.add("path=" + path);

		return errorDetailList;
	}

	/**
	 * 取得工作副本目录下文件的信息
	 *
	 * <UL><B>异常编号：异常内容</B>
	 * <LI>20000001：Subversion连接失败
	 * <LI>20000002：未知主机	 * <LI>20000003：认证失败
	 * <LI>20000004：未指定工作副本目下的文件路径	 * <LI>20000005：版本库路径中含有空格
	 * <LI>20000022：无法取得文件信息
	 * <LI>20000043：指定的工作副本目下的文件不存在
	 * <LI>20009999：未知异常
	 * </UL>
	 *
	 * @param wcPath 工作副本目下的文件路径	 * @param remote 若为true则获取文件信息	 * @return SVNStatus对象
	 */
	public final SVNStatus getWCStatus(final String wcPath, final boolean remote) {

		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getWCStatus");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "wcPath;remote", wcPath + ";" + remote);
		}

		if (wcPath == null || wcPath.equals("")) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "工作副本目下的文件路径");
			}
			throw new ComponentException("未指定工作副本目下的文件路径",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}

		SVNStatus status = null;
		try {
			ISVNOptions options = SVNWCUtil.createDefaultOptions(true);
			SVNStatusClient statusClient =
				new SVNStatusClient(this._svnConnection.getISVNAuthenticationManager(), options);

			File wcFile = new File(wcPath);
			status = statusClient.doStatus(wcFile, remote);
			if (status == null) {
				// 文件不存在				if (logger.isEnableFor("Component2022")) {
					logger.log("Component2022", wcPath);
				}

				List<String> errorDetailList = createErrorDetailListForGetWCStatus(wcPath, remote);
				throw new ComponentException("无法得到文件信息",
						ComponentSvnConst.ERROR_FILE_DOES_NOT_FOUND, errorDetailList);
			}

		} catch (SVNAuthenticationException e) {
			if (logger.isEnableFor("Component2003")) {
				logger.log("Component2003", e, this._svnConnection.getRootUrl(),
						this._svnConnection.getUsername(), e.getMessage());
			}

			List<String> errorDetailList = createErrorDetailListForGetWCStatus(wcPath, remote);
			throw new ComponentException("认证失败",
					ComponentSvnConst.ERROR_AUTHENTICATION, errorDetailList, e);

		} catch (SVNException e) {
			if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONNECTION_REFUSED) != -1) {
				if (logger.isEnableFor("Component2001")) {
					logger.log("Component2001", e, this._svnConnection.getRootUrl(),
							this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForGetWCStatus(wcPath, remote);
				throw new ComponentException("连接失败",
						ComponentSvnConst.ERROR_CONNECT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.UNKNOWN_HOST) != -1) {
				if (logger.isEnableFor("Component2002")) {
					logger.log("Component2002", e, this._svnConnection.getRootUrl(),
							this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForGetWCStatus(wcPath, remote);
				throw new ComponentException("未知的主机",
						ComponentSvnConst.ERROR_UNKNOWN_HOST, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONTAINS_INVALID_ELEMENT) != -1) {
				if (logger.isEnableFor("Component2005")) {
					logger.log("Component2005", e, wcPath, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForGetWCStatus(wcPath, remote);
				throw new ComponentException("版本库路径错误，含有非法对象",
						ComponentSvnConst.ERROR_CONTAINS_INVALID_ELEMENT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.NOT_WORKING_COPY) != -1) {
				// 若上层父目录不存在，不能进行CHECKOUT
				if (logger.isEnableFor("Component2049")) {
					logger.log("Component2049", e, wcPath, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForGetWCStatus(wcPath, remote);
				throw new ComponentException("指定的目录不是一个工作副本目录",
						ComponentSvnConst.ERROR_NOT_WORKING_COPY_FOR_WCSTATUS, errorDetailList, e);
			} else {
				if (logger.isEnableFor("Component2999")) {
					logger.log("Component2999", e, e.getMessage(),
												  "wcPath;remote",
												  wcPath + ";" + remote);
				}

				List<String> errorDetailList = createErrorDetailListForGetWCStatus(wcPath, remote);
				throw new ComponentException("未知异常",
						ComponentSvnConst.ERROR_UNKNOWN, errorDetailList, e);
			}
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "getWCStatus");
		}

		return status;
	}

	/**
	 * 输出详细异常信息
	 *
	 * @param wcPath 工作副本目下的文件路径	 * @param remote 若为true则获取文件信息	 * @return 详细异常列表
	 */
	private List<String> createErrorDetailListForGetWCStatus(final String wcPath, final boolean remote) {

		List<String> errorDetailList = new ArrayList<String>();
		errorDetailList.add("url=" + this._svnConnection.getRootUrl());
		errorDetailList.add("username=" + this._svnConnection.getUsername());
		errorDetailList.add("wcPath=" + wcPath);
		errorDetailList.add("remote=" + remote);

		return errorDetailList;
	}

	/**
	 * 取得版本库中指定路径下的目录及文件列表
	 *
	 * @param path 需要获取所有文件信息的SVN根目录
	 * @return dirEntries 文件列表
	 * @throws SVNException 未知异常
	 */
	public List<HashMap<String, String>> getListEntriesForPath(final String path){
		
		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getListEntriesForPath");
		}
		
		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "path", path);
		}

		if (path == null || path.trim().equals("")) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "需要获取所有文件信息的SVN根目录");
			}
			throw new ComponentException("未指定需要获取所有文件信息的SVN根目录",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}
		
		List<HashMap<String, String>> dirEntries = new ArrayList<HashMap<String,String>>();
		try{
			// 获取指定路径下的所有文件信息
			listEntries(this._svnConnection.getRepository(), path, dirEntries);
		
		}catch (SVNAuthenticationException e) {
			if (logger.isEnableFor("Component2003")) {
				logger.log("Component2003", e, this._svnConnection.getRootUrl(),
						this._svnConnection.getUsername(), e.getMessage());
			}

			List<String> errorDetailList = createErrorDetailListForGetlistEntries(path);
			throw new ComponentException("认证失败",
					ComponentSvnConst.ERROR_AUTHENTICATION, errorDetailList, e);

		} catch (SVNException e) {
			if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONNECTION_REFUSED) != -1) {
				if (logger.isEnableFor("Component2001")) {
					logger.log("Component2001", e, this._svnConnection.getRootUrl(),
						this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForGetlistEntries(path);
				throw new ComponentException("连接失败",
						ComponentSvnConst.ERROR_CONNECT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.UNKNOWN_HOST) != -1) {
				if (logger.isEnableFor("Component2002")) {
					logger.log("Component2002", e, this._svnConnection.getRootUrl(),
						this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForGetlistEntries(path);
				throw new ComponentException("未知的主机",
						ComponentSvnConst.ERROR_UNKNOWN_HOST, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONTAINS_INVALID_ELEMENT) != -1) {
				if (logger.isEnableFor("Component2005")) {
					logger.log("Component2005", e, path, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForGetlistEntries(path);
				throw new ComponentException("版本库路径错误，含有非法对象",
						ComponentSvnConst.ERROR_CONTAINS_INVALID_ELEMENT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.NOT_EXIST) != -1) {
				if (logger.isEnableFor("Component2066")) {
					logger.log("Component2066", e, path, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForGetlistEntries(path);
				throw new ComponentException("SVN上的文件路径不存在",
						ComponentSvnConst.ERROR_PATH_DOES_NOT_EXIST, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.RESERVED_NAME) != -1) {
				if (logger.isEnableFor("Component2006")) {
					logger.log("Component2006", e, path, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForGetlistEntries(path);
				throw new ComponentException("指定了保留字的文件名",
						ComponentSvnConst.ERROR_RESERVED_NAME, errorDetailList, e);
			} else {
				if (logger.isEnableFor("Component2999")) {
					logger.log("Component2999", e, e.getMessage(), "path", path);
				}

				List<String> errorDetailList = createErrorDetailListForGetlistEntries(path);
				throw new ComponentException("未知异常",
						ComponentSvnConst.ERROR_UNKNOWN, errorDetailList, e);
			}

		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "getListEntriesForPath");
		}
		
		return dirEntries;
	}

	/**
	 * 输出详细异常信息
	 *
	 * @param path 版本库的路径	 * @return 详细异常列表
	 */
	private List<String> createErrorDetailListForGetlistEntries(final String path) {

		List<String> errorDetailList = new ArrayList<String>();
		errorDetailList.add("url=" + this._svnConnection.getRootUrl());
		errorDetailList.add("username=" + this._svnConnection.getUsername());
		errorDetailList.add("path=" + path);

		return errorDetailList;
	}
	
	/**
	 * 取得版本库中指定路径下的目录及文件列表
	 *
	 * @param repository 库	 * @param path 路径
	 * @param dirEntries 文件列表
	 * @throws SVNException 未知异常
	 */
	private void listEntries(final SVNRepository repository, final String path,
			final List<HashMap<String, String>> dirEntries) throws SVNException {

		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "listEntries");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "path", path);
		}

		List<SVNDirEntry> entries = new ArrayList<SVNDirEntry>();
		repository.getDir(path, -1, null, entries);
		for (SVNDirEntry entry : entries) {
			HashMap<String, String> map = new HashMap<String, String>();
			map.put("path", "/" + (path.equals("") ? "" : path + "/"));
			map.put("name", entry.getName());
			map.put("author", entry.getAuthor());
			map.put("revision", String.valueOf(entry.getRevision()));
			map.put("date", entry.getDate().toString());
			dirEntries.add(map);

			if (entry.getKind() == SVNNodeKind.DIR) {
				listEntries(repository, (path.equals("")) ? entry.getName() : path + "/" + entry.getName(), dirEntries);
			}
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "listEntries");
		}
	}
	
	/**
	 * 文件比较：工作目录版本与SVN上的最新版本	 *
	 * <UL><B>异常No：异常内容</B>
	 * <LI>20000001：连接SVN失败
	 * <LI>20000002：无法访问SERVER
	 * <LI>20000003：连接认证失败	 * <LI>20000004：未指定用于比较的工作目录文件路径	 * <LI>20000004：未指定用于比较的SVN文件路径
	 * <LI>20000031：SVN中该文件不存在	 * <LI>2000999：未知异常	 * </UL>
	 *
	 * @param wcPath 用于比较的工作目录文件	 * @param svnPath SVN上的文件路径
	 * @param result 比较的结果输出到指定文件（无变化文件大小为0）	 * @param useAncestry true：文件的路径也作为比较对象 false：只比较文件内容
	 * @param isRecursive 若为true递归处理
	 * @param changeLists collection with changelist names	 * @return 比较结果文件大小	 */
	public final long doDiff(final String wcPath, final String svnPath, File result, boolean useAncestry, 
			final boolean isRecursive, List<String> changeLists) {
		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doDiff");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "wcPath;svnPath;result;useAncestry;isRecursive;changeLists",
					wcPath + ";" + svnPath + ";" + result + ";" + useAncestry + ";" + isRecursive + ";" + changeLists);
		}

		if (wcPath == null || wcPath.trim().equals("")) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "用于比较的工作目录文件路径");
			}
			throw new ComponentException("未指定用于比较的工作目录文件路径",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}
		if (svnPath == null || svnPath.trim().equals("")) {
			if (logger.isEnableFor("Component2004")) {
				logger.log("Component2004", "用于比较的SVN上的文件路径");
			}
			throw new ComponentException("未指定用于比较的SVN上的文件路径",
					ComponentSvnConst.ERROR_INVALID_PARAMETER);
		}

		try {
			String checkPath = URLDecoder.decode(svnPath, "UTF8");
			SVNNodeKind nodeKind = this._svnConnection.getRepository().checkPath(checkPath, -1);

			if (!(nodeKind == SVNNodeKind.FILE)) {
				if (logger.isEnableFor("Component2031")) {
					logger.log("Component2031", svnPath);
				}
				throw new ComponentException("svn中该文件不存在",
						ComponentSvnConst.ERROR_ALREADY_EXISTS);
			}

			SVNDepth depth;
			if (isRecursive) {
				depth = SVNDepth.INFINITY;
			} else {
				depth = SVNDepth.FILES;
			}

			SVNURL svnUrl = SVNURL.parseURIEncoded(this._svnConnection.getRootUrl() + svnPath);
			
			ISVNOptions options = SVNWCUtil.createDefaultOptions(true);
			SVNDiffClient client = new SVNDiffClient(this._svnConnection.getISVNAuthenticationManager(), options);
			client.doDiff(new File(wcPath), SVNRevision.WORKING, svnUrl, SVNRevision.HEAD, depth, useAncestry, new FileOutputStream(result), changeLists);
//		    client.doDiff(new File(wcPath), SVNRevision.WORKING, svnUrl, SVNRevision.HEAD, false, useAncestry, result);
			
		} catch (SVNAuthenticationException e) {
			if (logger.isEnableFor("Component2003")) {
				logger.log("Component2003", e, this._svnConnection.getRootUrl(),
						this._svnConnection.getUsername(), e.getMessage());
			}

			List<String> errorDetailList = createErrorDetailListForDoDiff(wcPath, svnPath, useAncestry, isRecursive);
			throw new ComponentException("认证失败",
					ComponentSvnConst.ERROR_AUTHENTICATION, errorDetailList, e);

		} catch (SVNException e) {
			if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONNECTION_REFUSED) != -1) {
				if (logger.isEnableFor("Component2001")) {
					logger.log("Component2001", e, this._svnConnection.getRootUrl(),
						this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoDiff(wcPath, svnPath, useAncestry, isRecursive);
				throw new ComponentException("连接失败",
						ComponentSvnConst.ERROR_CONNECT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.UNKNOWN_HOST) != -1) {
				if (logger.isEnableFor("Component2002")) {
					logger.log("Component2002", e, this._svnConnection.getRootUrl(),
						this._svnConnection.getUsername(), e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoDiff(wcPath, svnPath, useAncestry, isRecursive);
				throw new ComponentException("未知的主机",
						ComponentSvnConst.ERROR_UNKNOWN_HOST, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CONTAINS_INVALID_ELEMENT) != -1) {
				if (logger.isEnableFor("Component2005")) {
					logger.log("Component2005", e, svnPath, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoDiff(wcPath, svnPath, useAncestry, isRecursive);
				throw new ComponentException("版本库路径错误，含有非法对象",
						ComponentSvnConst.ERROR_CONTAINS_INVALID_ELEMENT, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.NOT_EXIST) != -1) {
				if (logger.isEnableFor("Component2066")) {
					logger.log("Component2066", e, svnPath, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoDiff(wcPath, svnPath, useAncestry, isRecursive);
				throw new ComponentException("用于比较的SVN上的文件路径不存在",
						ComponentSvnConst.ERROR_PATH_DOES_NOT_EXIST, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.ALREADY_EXISTS) != -1) {
				if (logger.isEnableFor("Component2031")) {
					logger.log("Component2031", e, svnPath);
				}

				List<String> errorDetailList = createErrorDetailListForDoDiff(wcPath, svnPath, useAncestry, isRecursive);
				throw new ComponentException("SVN中该文件已经存在",
						ComponentSvnConst.ERROR_ALREADY_EXISTS, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.RESERVED_NAME) != -1) {
				if (logger.isEnableFor("Component2006")) {
					logger.log("Component2006", e, svnPath, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoDiff(wcPath, svnPath, useAncestry, isRecursive);
				throw new ComponentException("指定了保留字的文件名",
						ComponentSvnConst.ERROR_RESERVED_NAME, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.NOT_WORKING_COPY) != -1) {
				if (logger.isEnableFor("Component2043")) {
					logger.log("Component2043", e, wcPath, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoDiff(wcPath, svnPath, useAncestry, isRecursive);
				throw new ComponentException("指定的文件不是工作副本，无法进行比较",
						ComponentSvnConst.ERROR_NOT_WORKING_COPY, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.PATH_UNDER_VRRSION_CONTROL_NEEDED_FOR_OPERATION) != -1) {
				if (logger.isEnableFor("Component2043")) {
					logger.log("Component2043", e, wcPath, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoDiff(wcPath, svnPath, useAncestry, isRecursive);
				throw new ComponentException("只能对纳入版本控制的路径执行此操作",
						ComponentSvnConst.ERROR_PATH_UNDER_VERSION_CONTROL_IS_NEEDED, errorDetailList, e);
			} else if (e.getMessage() != null
					&& e.getMessage().indexOf(ComponentSvnConst.CANNOT_REPLACE_DIRECTORY_FROM_WITHIN) != -1) {
				if (logger.isEnableFor("Component2043")) {
					logger.log("Component2043", e, wcPath, e.getMessage());
				}

				List<String> errorDetailList = createErrorDetailListForDoDiff(wcPath, svnPath, useAncestry, isRecursive);
				throw new ComponentException("不能在子目录中替换目录",
						ComponentSvnConst.ERROR_CANNOT_REPLACE_DIRECTORY_FROM_WITHIN, errorDetailList, e);
			}else {
				if (logger.isEnableFor("Component2999")) {
					logger.log("Component2999", e, e.getMessage(),
												  "wcPath;svnPath;useAncestry;isRecursive",
												  wcPath + ";" 
												  + svnPath + ";"
												  + useAncestry + ";"
												  + isRecursive);
				}

				List<String> errorDetailList = createErrorDetailListForDoDiff(wcPath, svnPath, useAncestry, isRecursive);
				throw new ComponentException("未知异常",
						ComponentSvnConst.ERROR_UNKNOWN, errorDetailList, e);
			}

		} catch (FileNotFoundException e) {
			if (logger.isEnableFor("Component2021")) {
				logger.log("Component2021", e, result.getAbsolutePath(), e.getMessage());
			}

			List<String> errorDetailList = createErrorDetailListForDoCreateRepository(result.getAbsolutePath());
			throw new ComponentException("指定的SVN比较结果文件不存在",
					ComponentSvnConst.ERROR_FILE_DOES_NOT_FOUND, errorDetailList, e);

	}catch (UnsupportedEncodingException e) {
			if (logger.isEnableFor("Component2999")) {
				logger.log("Component2999", e, e.getMessage(),
											"wcPath;svnPath;useAncestry;isRecursive",
											wcPath + ";"
											+ svnPath + ";"
											+ useAncestry + ";"
											+ isRecursive);
			}

			List<String> errorDetailList = createErrorDetailListForDoDiff(wcPath, svnPath, useAncestry, isRecursive);
			throw new ComponentException("未知异常",
					ComponentSvnConst.ERROR_UNKNOWN, errorDetailList, e);
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doDiff");
		}

		return result.length();
	}

	/**
	 * 输出详细异常信息
	 *
	 * @param wcPath 用于比较的工作目录文件	 * @param svnPath SVN上的文件路径
	 * @param useAncestry true：文件的路径也作为比较对象 false：只比较文件内容
	 * @param isRecursive 若为true则递归处理
	 * @return 详细异常列表
	 */
	private List<String> createErrorDetailListForDoDiff(final String wcPath, final String svnPath, final boolean useAncestry,
			final boolean isRecursive) {

		List<String> errorDetailList = new ArrayList<String>();
		errorDetailList.add("url=" + this._svnConnection.getRootUrl());
		errorDetailList.add("username=" + this._svnConnection.getUsername());
		errorDetailList.add("wcPath=" + wcPath);
		errorDetailList.add("svnPath=" + svnPath);
		errorDetailList.add("useAncestry=" + useAncestry);
		errorDetailList.add("isRecursive=" + isRecursive);

		return errorDetailList;
	}

}///:~
