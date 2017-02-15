package com.nantian.component.ftp;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.net.ftp.FTP;
import org.apache.commons.net.ftp.FTPClient;
import org.apache.commons.net.ftp.FTPFile;
import org.apache.commons.net.ftp.FTPReply;

import com.nantian.common.util.CommonConst;
import com.nantian.component.com.ComponentException;
import com.nantian.component.com.FtpCmpException;
import com.nantian.component.log.Logger;

/**
 * FTP操作Class
 * @author dong
 */
public class ComponentFtp {

	/**
	 * Logger
	 */
	private static Logger logger = Logger.getLogger(ComponentFtp.class);

	/**
	 * FTPConnection
	 */
	private ComponentFtpConnection _ftpConnection;

	/**
	 * 
	 * @param ftpConnection ComponentFtpConnection
	 */
	public ComponentFtp(final ComponentFtpConnection ftpConnection) {
		this._ftpConnection = ftpConnection;
	}


	/**
	 * 上传文件
	 * <P>采用BIN模式传送<BR>
	 * 只能指定单一文件传送。不能使用通配符
	 *
	 * <UL><B>异常编码：异常内容</B>
	 * <LI>30000005：未指定上传的文件
	 * <LI>30000005：未指定远程主机上的文件名
	 * <LI>30000011：上传的文件不存在
	 * <LI>30000012：文件无法上传
	 * <LI>30009999：发生未知异常
	 * </UL>
	 *
	 * @param localFilename 上传的文件名
	 * @param remoteFilename 远程主机上的文件名

	 * @param replyString 应答信息存放的StringBuffer
	 * @throws UnsupportedEncodingException 
	 */
	public final void doPut(final String localFilename, final String remoteFilename,
			final StringBuffer replyString) {

		// 输出开始日志

		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doPut");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "localFilename;remoteFilename", localFilename + ";" + remoteFilename);
		}

		doPut(localFilename, remoteFilename, true, replyString);

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doPut");
		}
	}

	/**
	 *文件上传
	 * <P>可以选择上传模式<BR>
	 * 只能指定单一文件进行上传。不能使用通配符。
	 *
	 * <UL><B>异常编码：异常内容</B>
	 * <LI>30000005：未指定上传文件名

	 * <LI>30000005：未指定远程目标主机上的文件名

	 * <LI>30000011：上传的文件不存在

	 * <LI>30000012：文件无法上传

	 * <LI>30009999：发生未知异常

	 * </UL>
	 *
	 * @param localFilename 上传的文件名
	 * @param remoteFilename 远程目标主机的文件名
	 * @param binaryMode 文件传送模式(true:bin false:text)
	 * @param replyString 应答信息存放的StringBuffer
	 * @throws UnsupportedEncodingException 
	 */
	public final void doPut(final String localFilename, final String remoteFilename, final boolean binaryMode,
			final StringBuffer replyString) {

		// 输出开始日志		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doPut(final String, final String , final boolean , final StringBuffer)");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "localFilename;remoteFilename;binaryMode",
					localFilename + ";" + remoteFilename + ";" + binaryMode);
		}

		FileInputStream inputStream;

		if (localFilename == null || localFilename.trim().equals("")) {
			if (logger.isEnableFor("Component3005")) {
				logger.log("Component3005", "上传的文件名");
			}
			throw new ComponentException("未指定上传的文件名",
				ComponentFtpConst.ERROR_INVALID_PARAMETER);
		}

		if (remoteFilename == null || remoteFilename.trim().equals("")) {
			if (logger.isEnableFor("Component3005")) {
				logger.log("Component3005", "远程目标主机的文件名");
			}
			throw new ComponentException("未指定远程目标主机的文件名",
				ComponentFtpConst.ERROR_INVALID_PARAMETER);
		}

		if (replyString == null) {
			if (logger.isEnableFor("Component3005")) {
				logger.log("Component3005", "应答信息存放的StringBuffer");
			}
			throw new ComponentException("未指定应答信息存放的StringBuffer",
					ComponentFtpConst.ERROR_INVALID_PARAMETER);
		}

		try {
			inputStream = new FileInputStream(new File(localFilename));

		} catch (FileNotFoundException e) {
			if (logger.isEnableFor("Component3011")) {
				logger.log("Component3011", e, localFilename, e.getMessage());
			}
			throw new ComponentException("上传的文件不存在",
					ComponentFtpConst.ERROR_UPLOAD_FILE_NOT_FOUND, e);
		}

		FTPClient ftpclient = this._ftpConnection.getConnection();
		if (ftpclient == null){
			if (logger.isEnableFor("Component3018")) {
				logger.log("Component3018", "server", this._ftpConnection.getHost());
			}
			throw new ComponentException("未登录远程主机",
					ComponentFtpConst.ERROR_NOT_CONNECT);
		}

		try {
			if (binaryMode) {
				// 设定二进制传输模式

				ftpclient.setFileType(FTP.BINARY_FILE_TYPE);
			} else {
				// 设定文本传输模式
				ftpclient.setFileType(FTP.ASCII_FILE_TYPE);
			}

		} catch (IOException e) {
			if (logger.isEnableFor("Component3999")) {
				logger.log("Component3999", e, e.getMessage(),
											  "localFilename;remoteFilename;binaryMode",
											  localFilename + ";"
											  + remoteFilename + ";"
											  + binaryMode);
			}

			List<String> errorDetailList = createErrorDetailListForDoPut(localFilename, remoteFilename, binaryMode);
			throw new ComponentException("发生未知异常",
					ComponentFtpConst.ERROR_UNKNOWN, errorDetailList, e);
		}

		boolean result = false;
		try {
			result = ftpclient.storeFile(remoteFilename, inputStream);
			replyString.append(ftpclient.getReplyString());

		} catch (IOException e) {
			if (logger.isEnableFor("Component3999")) {
				logger.log("Component3999", e, e.getMessage(),
						  					  "localFilename;remoteFilename;binaryMode",
						  					  localFilename + ";"
						  					  + remoteFilename + ";"
						  					  + binaryMode);
			}

			List<String> errorDetailList = createErrorDetailListForDoPut(localFilename, remoteFilename, binaryMode);
			throw new ComponentException("发生未知异常",
					ComponentFtpConst.ERROR_UNKNOWN, errorDetailList, e);
		}

		// 上传文件
		if (!result) {
			if (logger.isEnableFor("Component3012")) {
				logger.log("Component3012", localFilename, ftpclient.getReplyCode());
			}

			List<String> errorDetailList = createErrorDetailListForDoPut(localFilename, remoteFilename, binaryMode);
			errorDetailList.add("reply=" + replyString.toString());
			throw new ComponentException("文件无法上传",
					ComponentFtpConst.ERROR_CANNOT_PUT, errorDetailList);
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doPut(final String, final String , final boolean , final StringBuffer)");
		}
	}

	/**
	 * 编辑详细异常列表
	 *
	 * @param localFilename 上传的文件名
	 * @param remoteFilename 远程目标主机上的文件名

	 * @param binaryMode 传送模式(true:bin false:text)
	 * @return 详细异常列表
	 */
	private List<String> createErrorDetailListForDoPut(final String localFilename, final String remoteFilename,
			final boolean binaryMode) {

		List<String> errorDetailList = new ArrayList<String>();
		errorDetailList.add("host=" + this._ftpConnection.getHost());
		errorDetailList.add("port=" + this._ftpConnection.getPort());
		errorDetailList.add("user=" + this._ftpConnection.getUser());
		errorDetailList.add("localFilename=" + localFilename);
		errorDetailList.add("remoteFilename=" + remoteFilename);
		errorDetailList.add("binaryMode=" + binaryMode);

		return errorDetailList;
	}

	/**
	 * 下载文件
	 * <P>传送模式采用二进制bin模式<BR>
	 * 只能指定单一文件进行下载，不能使用通配符。

	 *
	 * <UL><B>异常编码：异常内容</B>
	 * <LI>30000005：未指定要下载的文件名

	 * <LI>30000005：未指定本地的文件名
	 * <LI>30000016：要下载的文件不存在
	 * <LI>30000015：文件无法下载

	 * <LI>30009999：发生未知异常

	 * </UL>
	 *
	 * @param remoteFilename 要下载的文件名

	 * @param localFilename 本地的文件名
	 * @param replyString 应答信息存放的StringBuffer
	 */
	public final void doGet(final String remoteFilename, final String localFilename,
			final StringBuffer replyString) {

		// 输出开始日志

		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doGet");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "remoteFilename;localFilename", remoteFilename + ";" + localFilename);
		}

		doGet(remoteFilename, localFilename, true, replyString);

		// 输出结束日志־
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doGet");
		}
	}

	/**
	 * 下载文件
	 * <P>可以选择传送模式<BR>
	 * 只能指定单一文件进行下载，不能使用通配符。
	 *
	 * <UL><B>异常编码：异常内容</B>
	 * <LI>30000005：未指定要下载的文件名
	 * <LI>30000005：未指定本地文件名
	 * <LI>30000016：要下载的文件不存在
	 * <LI>30000015：文件无法下载
	 * <LI>30009999：发生未知异常
	 * </UL>
	 *
	 * @param remoteFilename 要下载的文件名
	 * @param localFilename 本地的文件名
	 * @param binaryMode 文件传送模式(true:bin false:text)
	 * @param replyString 应答信息存放的StringBuffer
	 */
	public final void doGet(final String remoteFilename, final String localFilename, final boolean binaryMode,
			final StringBuffer replyString) {

		// 输出开始日志

		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doGet(final String, final String, final boolean,final StringBuffer)");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "remoteFilename;localFilename;binaryMode",
					remoteFilename + ";" + localFilename + ";" + binaryMode);
		}

		FileOutputStream outputStream;

		if (remoteFilename == null || remoteFilename.trim().equals("")) {
			if (logger.isEnableFor("Component3005")) {
				logger.log("Component3005", "要下载的文件名");
			}
			throw new ComponentException("未指定要下载的文件名",
				ComponentFtpConst.ERROR_INVALID_PARAMETER);
		}

		if (localFilename == null || localFilename.trim().equals("")) {
			if (logger.isEnableFor("Component3005")) {
				logger.log("Component3005", "本地文件名");
			}
			throw new ComponentException("未指定本地文件名",
				ComponentFtpConst.ERROR_INVALID_PARAMETER);
		}

		if (replyString == null) {
			if (logger.isEnableFor("Component3005")) {
				logger.log("Component3005", "应答信息存放的StringBuffer");
			}
			throw new ComponentException("未指定应答信息存放的StringBuffer",
					ComponentFtpConst.ERROR_INVALID_PARAMETER);
		}

		try {
			outputStream = new FileOutputStream(new File(localFilename));

		} catch (FileNotFoundException e) {
			if (logger.isEnableFor("Component3016")) {
				logger.log("Component3016", e, remoteFilename, e.getMessage());
			}
			throw new ComponentException("本地无法创建要下载的文件",
					ComponentFtpConst.ERROR_DOWNLOAD_FILE_CANNOT_CREATE, e);
		}

		FTPClient ftpclient = this._ftpConnection.getConnection();
		if (ftpclient == null){
			if (logger.isEnableFor("Component3018")) {
				logger.log("Component3018", "server", this._ftpConnection.getHost());
			}
			throw new ComponentException("未登录远程主机",
					ComponentFtpConst.ERROR_NOT_CONNECT);
		}

		try {
			if (binaryMode) {
				// 设定二进制BIN传输模式
				ftpclient.setFileType(FTP.BINARY_FILE_TYPE);
			} else {
				// 设定ASCII文本传输模式
				ftpclient.setFileType(FTP.ASCII_FILE_TYPE);
			}
			
			//检查远程文件是否存在

			FTPFile[] files = ftpclient.listFiles(remoteFilename);
			if(files.length != 1){
				if (logger.isEnableFor("Component3019")) {
					logger.log("Component3019", remoteFilename, ftpclient.getReplyCode());
				}

				List<String> errorDetailList = createErrorDetailListForDoGet(remoteFilename, localFilename, binaryMode);
				errorDetailList.add("reply=" + replyString.toString());
				throw new FtpCmpException("要下载的文件不存在",
						ComponentFtpConst.ERROR_CANNOT_GET, errorDetailList);
			}

		} catch (IOException e) {
			if (logger.isEnableFor("Component3999")) {
				logger.log("Component3999", e, e.getMessage(), 
											  "remoteFilename;localFilename;binaryMode",
											  remoteFilename + ";"
											  + localFilename + ";"
											  + binaryMode);
			}

			List<String> errorDetailList = createErrorDetailListForDoGet(remoteFilename, localFilename, binaryMode);
			throw new ComponentException("发生未知异常",
					ComponentFtpConst.ERROR_UNKNOWN, errorDetailList, e);
		}
		
		boolean result = false;
		try {
			result = ftpclient.retrieveFile(remoteFilename, outputStream);
			replyString.append(ftpclient.getReplyString());

		} catch (IOException e) {
			if (logger.isEnableFor("Component3999")) {
				logger.log("Component3999", e, e.getMessage(), 
						  					  "remoteFilename;localFilename;binaryMode",
						  					  remoteFilename + ";"
						  					  + localFilename + ";"
						  					  + binaryMode);
			}

			List<String> errorDetailList = createErrorDetailListForDoGet(remoteFilename, localFilename, binaryMode);
			throw new ComponentException("发生未知异常",
					ComponentFtpConst.ERROR_UNKNOWN, errorDetailList, e);
		}

		// 下载文件
		if (!result) {
			if (logger.isEnableFor("Component3015")) {
				logger.log("Component3015", remoteFilename, ftpclient.getReplyCode());
			}

			List<String> errorDetailList = createErrorDetailListForDoGet(remoteFilename, localFilename, binaryMode);
			errorDetailList.add("reply=" + replyString.toString());
			throw new FtpCmpException("无法完成下载",
					ComponentFtpConst.ERROR_CANNOT_GET, errorDetailList);
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doGet(final String, final String, final boolean,final StringBuffer)");
		}
	}
	
	/**
	 * 下载指定目录下所有文件.
	 * <P>传送模式采用二进制bin模式<BR>
	 * 下载所有文件.
	 *
	 * <UL><B>异常编码：异常内容</B>
	 * <LI>30000005：未指定要下载的目录
	 * <LI>30000005：未指定本地的目录

	 * <LI>30000016：要下载的文件不存在
	 * <LI>30000015：文件无法下载

	 * <LI>30009999：发生未知异常

	 * </UL>
	 *
	 * @param remoteFilePath 要下载的文件目录
	 * @param localFilePath 本地的文件目录

	 * @param replyString 应答信息存放的StringBuffer
	 */
	public final void doGetFiles(final String remoteFilePath, final String localFilePath,
			final StringBuffer replyString) {

		// 输出开始日志

		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doGetFiles");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "remoteFilePath;localFilePath", remoteFilePath + ";" + localFilePath);
		}

		doGetFiles(remoteFilePath, localFilePath, true, replyString);

		// 输出结束日志־
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doGetFiles");
		}
	}

	/**
	 * 下载指定文件夹下的所有文件

	 * <P>可以选择传送模式<BR>
	 * 下载所有文件。

	 *
	 * <UL><B>异常编码：异常内容</B>
	 * <LI>30000005：未指定要下载的目录
	 * <LI>30000005：未指定本地文件目录
	 * <LI>30000016：要下载的文件不存在
	 * <LI>30000015：文件无法下载

	 * <LI>30009999：发生未知异常

	 * </UL>
	 *
	 * @param remoteFilename 要下载的文件目录
	 * @param localFilename 本地的文件目录

	 * @param binaryMode 文件传送模式(true:bin false:text)
	 * @param replyString 应答信息存放的StringBuffer
	 */
	public final void doGetFiles(final String remoteFilePath, final String localFilePath, final boolean binaryMode,
			final StringBuffer replyString) {
		// 输出开始日志.
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doGet(final String, final String, final boolean,final StringBuffer)");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "remoteFilePath;localFilePath;binaryMode",
					remoteFilePath + ";" + localFilePath + ";" + binaryMode);
		}

		FileOutputStream outputStream;
		if (remoteFilePath == null || localFilePath.trim().equals("")) {
			if (logger.isEnableFor("Component3005")) {
				logger.log("Component3005", "要下载的文件目录");
			}
			throw new ComponentException("未指定要下载的文件目录",
				ComponentFtpConst.ERROR_INVALID_PARAMETER);
		}

		if (remoteFilePath == null || localFilePath.trim().equals("")) {
			if (logger.isEnableFor("Component3005")) {
				logger.log("Component3005", "本地文件目录");
			}
			throw new ComponentException("未指定本地文件目录",
				ComponentFtpConst.ERROR_INVALID_PARAMETER);
		}

		if (replyString == null) {
			if (logger.isEnableFor("Component3005")) {
				logger.log("Component3005", "应答信息存放的StringBuffer");
			}
			throw new ComponentException("未指定应答信息存放的StringBuffer",
					ComponentFtpConst.ERROR_INVALID_PARAMETER);
		}
		
		FTPClient ftpclient = this._ftpConnection.getConnection();
		if (ftpclient == null){
			if (logger.isEnableFor("Component3018")) {
				logger.log("Component3018", "server", this._ftpConnection.getHost());
			}
			throw new ComponentException("未登录远程主机",
					ComponentFtpConst.ERROR_NOT_CONNECT);
		}

		String remoteFilename = null;
		String localFilename = null;
		try {
			//检查远程文件是否存在

			FTPFile[] files = ftpclient.listFiles(remoteFilePath);
			if(files.length == 0){
				if (logger.isEnableFor("Component3019")) {
					logger.log("Component3019", remoteFilePath, ftpclient.getReplyCode());
				}

				List<String> errorDetailList = createErrorDetailListForDoGet(remoteFilePath, localFilePath, binaryMode);
				errorDetailList.add("reply=" + replyString.toString());
				throw new FtpCmpException("要下载的目录下不存在文件",
						ComponentFtpConst.ERROR_CANNOT_GET, errorDetailList);
			}
			
			if (binaryMode) {
				// 设定二进制BIN传输模式
				ftpclient.setFileType(FTP.BINARY_FILE_TYPE);
			} else {
				// 设定ASCII文本传输模式
				ftpclient.setFileType(FTP.ASCII_FILE_TYPE);
			}
			
			boolean result = false;
			for (FTPFile ftpFile : files) {
				
				result = false;
				remoteFilename = remoteFilePath.concat(CommonConst.SLASH).concat(ftpFile.getName());
				localFilename = localFilePath.concat(File.separator).concat(ftpFile.getName());
				outputStream = new FileOutputStream(new File(localFilename));
				
				result = ftpclient.retrieveFile(remoteFilename, outputStream);
				replyString.append(ftpclient.getReplyString());

				// 下载文件
				if (!result) {
					if (logger.isEnableFor("Component3015")) {
						logger.log("Component3015", remoteFilename, ftpclient.getReplyCode());
					}
					List<String> errorDetailList = createErrorDetailListForDoGet(remoteFilename, localFilename, binaryMode);
					errorDetailList.add("reply=" + replyString.toString());
					throw new FtpCmpException("无法完成下载",
							ComponentFtpConst.ERROR_CANNOT_GET, errorDetailList);
				}
				
			}
		} catch (FileNotFoundException e) {
			if (logger.isEnableFor("Component3016")) {
				logger.log("Component3016", e, remoteFilename, e.getMessage());
			}
			throw new ComponentException("本地无法创建要下载的文件",
					ComponentFtpConst.ERROR_DOWNLOAD_FILE_CANNOT_CREATE, e);
			
		}catch (IOException e) {
			if (logger.isEnableFor("Component3999")) {
				logger.log("Component3999", e, e.getMessage(), 
											  "remoteFilename;localFilename;binaryMode",
											  remoteFilename + ";"
											  + localFilename + ";"
											  + binaryMode);
			}
			List<String> errorDetailList = createErrorDetailListForDoGet(remoteFilename, localFilename, binaryMode);
			throw new ComponentException("发生未知异常",
					ComponentFtpConst.ERROR_UNKNOWN, errorDetailList, e);
		}
		
		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doGet(final String, final String, final boolean,final StringBuffer)");
		}
	}

	/**
	 * 编辑异常信息
	 *
	 * @param remoteFilename 要下载的文件名

	 * @param localFilename 本地文件名

	 * @param binaryMode 文件传输模式(true:bin false:text)
	 * @return 详细异常列表
	 */
	private List<String> createErrorDetailListForDoGet(final String remoteFilename, final String localFilename,
			final boolean binaryMode) {

		List<String> errorDetailList = new ArrayList<String>();
		errorDetailList.add("host=" + this._ftpConnection.getHost());
		errorDetailList.add("port=" + this._ftpConnection.getPort());
		errorDetailList.add("user=" + this._ftpConnection.getUser());
		errorDetailList.add("remoteFilename=" + remoteFilename);
		errorDetailList.add("localFilename=" + localFilename);
		errorDetailList.add("binaryMode=" + binaryMode);

		return errorDetailList;
	}

	/**
	 * 新建目录
	 *
	 * <UL><B>异常编码：异常内容</B>
	 * <LI>30000005：未指定新建的目录名
	 * <LI>30000013：无法创建目录

	 * <LI>30009999：发生未知异常

	 * </UL>
	 *
	 * @param directoryName 新建的目录名
	 * @param replyString 应答信息存放的StringBuffer
	 * @return 处理结果 (0:正常/0以外:异常)
	 */
	public final int doMkdir(final String directoryName, final StringBuffer replyString) {

		// 输出开始日志

		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doMkdir");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "directoryName", directoryName);
		}

		if (directoryName == null || directoryName.trim().equals("")) {
			if (logger.isEnableFor("Component3005")) {
				logger.log("Component3005", "新建的目录名");
			}
			throw new ComponentException("未指定新建的目录名",
				ComponentFtpConst.ERROR_INVALID_PARAMETER);
		}

		if (replyString == null) {
			if (logger.isEnableFor("Component3005")) {
				logger.log("Component3005", "应答信息存放的StringBuffer");
			}
			throw new ComponentException("未指定应答信息存放的StringBuffer",
					ComponentFtpConst.ERROR_INVALID_PARAMETER);
		}

		FTPClient ftpclient = this._ftpConnection.getConnection();
		if (ftpclient == null){
			if (logger.isEnableFor("Component3018")) {
				logger.log("Component3018", "server", this._ftpConnection.getHost());
			}
			throw new ComponentException("未登录远程目标主机",
					ComponentFtpConst.ERROR_NOT_CONNECT);
		}

		boolean result = false;
		try {
			result = ftpclient.makeDirectory(directoryName);
			replyString.append(ftpclient.getReplyString());

			if (logger.isEnableFor("Component3006")) {
				logger.log("Component3006", "replyCode;replyString;host;user",
						ftpclient.getReplyCode() + ";"
						+ ftpclient.getReplyString() + ";"
						+ this._ftpConnection.getHost() + ";"
						+ this._ftpConnection.getUser());
			}

		} catch (IOException e) {
			if (logger.isEnableFor("Component3999")) {
				logger.log("Component3999", e, e.getMessage(), "directoryName", directoryName);
			}

			List<String> errorDetailList = createErrorDetailListForDoMkdir(directoryName);
			throw new ComponentException("发生未知异常",
					ComponentFtpConst.ERROR_UNKNOWN, errorDetailList, e);
		}

		int resultReply = 0;
		if (!result) {
			if (logger.isEnableFor("Component3013")) {
				logger.log("Component3013", directoryName, ftpclient.getReplyCode());
			}

			resultReply = ftpclient.getReplyCode();
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doMkdir");
		}

		return resultReply;
	}

	/**
	 * 编辑详细异常信息
	 *
	 * @param directoryName 新建的目录名
	 * @return 详细异常信息
	 */
	private List<String> createErrorDetailListForDoMkdir(final String directoryName) {

		List<String> errorDetailList = new ArrayList<String>();
		errorDetailList.add("host=" + this._ftpConnection.getHost());
		errorDetailList.add("port=" + this._ftpConnection.getPort());
		errorDetailList.add("user=" + this._ftpConnection.getUser());
		errorDetailList.add("directoryName=" + directoryName);

		return errorDetailList;
	}

	/**
	 * 变更工作目录
	 *
	 * <UL><B>异常编码：异常内容</B>
	 * <LI>30000005：未指定要变更的目录名

	 * <LI>30000013：未作成目录
	 * <LI>30009999：发生未知异常

	 * </UL>
	 *
	 * @param directoryName 要变更的目录名

	 * @param replyString 应答信息存放的StringBuffer
	 * @return 处理结果(0:正常/0以外:异常)
	 */
	public final int doChdir(final String directoryName, final StringBuffer replyString) {

		// 输出开始日志

		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doChdir");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "directoryName", directoryName);
		}

		if (directoryName == null || directoryName.trim().equals("")) {
			if (logger.isEnableFor("Component3005")) {
				logger.log("Component3005", "要变更的目录名");
			}
			throw new ComponentException("未指定要变更的目录名",
				ComponentFtpConst.ERROR_INVALID_PARAMETER);
		}

		if (replyString == null) {
			if (logger.isEnableFor("Component3005")) {
				logger.log("Component3005", "应答信息存放的StringBuffer");
			}
			throw new ComponentException("未指定应答信息存放的StringBuffer",
					ComponentFtpConst.ERROR_INVALID_PARAMETER);
		}

		FTPClient ftpclient = this._ftpConnection.getConnection();
		if (ftpclient == null){
			if (logger.isEnableFor("Component3018")) {
				logger.log("Component3018", "server", this._ftpConnection.getHost());
			}
			throw new ComponentException("未登录远程目标主机",
					ComponentFtpConst.ERROR_NOT_CONNECT);
		}

		boolean result = false;
		try {
			result = ftpclient.changeWorkingDirectory(directoryName);
			replyString.append(ftpclient.getReplyString());

			if (logger.isEnableFor("Component0003")) {
				logger.log("Component0003", "replyCode;replyString;host;user",
						ftpclient.getReplyCode() + ";"
						+ ftpclient.getReplyString() + ";"
						+ this._ftpConnection.getHost() + ";"
						+ this._ftpConnection.getUser());
			}

		} catch (IOException e) {
			if (logger.isEnableFor("Component3999")) {
				logger.log("Component3999", e, e.getMessage(), "directoryName", directoryName);
			}

			List<String> errorDetailList = createErrorDetailListForDoChdir(directoryName);
			throw new ComponentException("发生未知异常",
					ComponentFtpConst.ERROR_UNKNOWN, errorDetailList, e);
		}

		int resultReply = 0;
		if (!result) {
			if (logger.isEnableFor("Component3017")) {
				logger.log("Component3017", directoryName, ftpclient.getReplyCode());
			}

			resultReply = ftpclient.getReplyCode();
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doChdir");
		}

		return resultReply;
	}

	/**
	 * 编辑详细异常信息
	 *
	 * @param directoryName 要变更的目录名

	 * @return 详细异常列表
	 */
	private List<String> createErrorDetailListForDoChdir(final String directoryName) {

		List<String> errorDetailList = new ArrayList<String>();
		errorDetailList.add("host=" + this._ftpConnection.getHost());
		errorDetailList.add("port=" + this._ftpConnection.getPort());
		errorDetailList.add("user=" + this._ftpConnection.getUser());
		errorDetailList.add("directoryName=" + directoryName);

		return errorDetailList;
	}

	/**
	 * 执行命令
	 *
	 * <UL><B>异常编码：异常内容</B>
	 * <LI>30000005：未指定要执行的命令
	 * <LI>30009999：发生未知异常

	 * </UL>
	 *
	 * @param cmd 要执行的命令
	 * @param replyString 应答信息存放的StringBuffer
	 * @return 处理结果(0:正常/0以外:异常)
	 */
	public final int doCmdExec(final String cmd, final StringBuffer replyString) {

		// 输出开始日志

		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doCmdExec");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "cmd", cmd);
		}

		if (cmd == null || cmd.trim().equals("")) {
			if (logger.isEnableFor("Component3005")) {
				logger.log("Component3005", "要执行的命令");
			}
			throw new ComponentException("未指定要执行的命令",
				ComponentFtpConst.ERROR_INVALID_PARAMETER);
		}

		if (replyString == null) {
			if (logger.isEnableFor("Component3005")) {
				logger.log("Component3005", "应答信息存放的StringBuffer");
			}
			throw new ComponentException("未指定应答信息存放的StringBuffer",
					ComponentFtpConst.ERROR_INVALID_PARAMETER);
		}

		FTPClient ftpclient = this._ftpConnection.getConnection();
		if (ftpclient == null){
			if (logger.isEnableFor("Component3018")) {
				logger.log("Component3018", "server", this._ftpConnection.getHost());
			}
			throw new ComponentException("未登录远程目标主机",
					ComponentFtpConst.ERROR_NOT_CONNECT);
		}

		int reply = 0;
		try {
			reply = ftpclient.sendCommand(cmd);
			replyString.append(ftpclient.getReplyString());

			if (logger.isEnableFor("Component0003")) {
				logger.log("Component0003", "replyCode;replyString;host;user",
						ftpclient.getReplyCode() + ";"
						+ ftpclient.getReplyString() + ";"
						+ this._ftpConnection.getHost() + ";"
						+ this._ftpConnection.getUser());
			}

		} catch (IOException e) {
			if (logger.isEnableFor("Component3999")) {
				logger.log("Component3999", e, e.getMessage(), "cmd", cmd);
			}

			List<String> errorDetailList = createErrorDetailListForDoCmdExec(cmd);
			throw new ComponentException("发生未知异常",
					ComponentFtpConst.ERROR_UNKNOWN, errorDetailList, e);
		}

		int resultReply = 0;
		if (cmd.toUpperCase().startsWith("RNFR") && reply == 350) {
			// 若返回值为350，算正常处理

		} else if (!FTPReply.isPositiveCompletion(reply)) {
			if (logger.isEnableFor("Component3014")) {
				logger.log("Component3014", cmd, reply);
			}

			resultReply = reply;
		}

		//输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doCmdExec");
		}

		return resultReply;
	}

	/**
	 * 编辑详细异常信息
	 *
	 * @param cmd 要执行的命令
	 * @return 详细异常列表
	 */
	private List<String> createErrorDetailListForDoCmdExec(final String cmd) {

		List<String> errorDetailList = new ArrayList<String>();
		errorDetailList.add("host=" + this._ftpConnection.getHost());
		errorDetailList.add("port=" + this._ftpConnection.getPort());
		errorDetailList.add("user=" + this._ftpConnection.getUser());
		errorDetailList.add("cmd=" + cmd);

		return errorDetailList;
	}
	
	
	
	/**
	 * 下载指定文件夹下的所有文件

	 * <P>可以选择传送模式<BR>
	 * 下载所有文件。

	 *
	 * <UL><B>异常编码：异常内容</B>
	 * <LI>30000005：未指定要下载的目录
	 * <LI>30000005：未指定本地文件目录
	 * <LI>30000016：要下载的文件不存在
	 * <LI>30000015：文件无法下载

	 * <LI>30009999：发生未知异常

	 * </UL>
	 *
	 * @param remoteFilename 要下载的文件目录
	 * @param localFilename 本地的文件目录

	 * @param binaryMode 文件传送模式(true:bin false:text)
	 * @param replyString 应答信息存放的StringBuffer
	 * @throws IOException 
	 */
	public final String[] doGetFilesNamelist(final String remoteFilePath) throws IOException {
		
		// 输出开始日志.
		/*if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doGet(final String, final String, final boolean,final StringBuffer)");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "remoteFilePath;localFilePath;binaryMode",
					remoteFilePath + ";" + localFilePath + ";" + binaryMode);
		}*/

		//FileOutputStream outputStream;
		/*if (remoteFilePath == null || localFilePath.trim().equals("")) {
			if (logger.isEnableFor("Component3005")) {
				logger.log("Component3005", "要下载的文件目录");
			}
			throw new ComponentException("未指定要下载的文件目录",
				ComponentFtpConst.ERROR_INVALID_PARAMETER);
		}

		if (remoteFilePath == null || localFilePath.trim().equals("")) {
			if (logger.isEnableFor("Component3005")) {
				logger.log("Component3005", "本地文件目录");
			}
			throw new ComponentException("未指定本地文件目录",
				ComponentFtpConst.ERROR_INVALID_PARAMETER);
		}

		if (replyString == null) {
			if (logger.isEnableFor("Component3005")) {
				logger.log("Component3005", "应答信息存放的StringBuffer");
			}
			throw new ComponentException("未指定应答信息存放的StringBuffer",
					ComponentFtpConst.ERROR_INVALID_PARAMETER);
		}*/
		
		FTPClient ftpclient = this._ftpConnection.getConnection();
		if (ftpclient == null){
			if (logger.isEnableFor("Component3018")) {
				logger.log("Component3018", "server", this._ftpConnection.getHost());
			}
			throw new ComponentException("未登录远程主机",
					ComponentFtpConst.ERROR_NOT_CONNECT);
		}

		/*String remoteFilename = null;
		String localFilename = null;*/
	
		//检查远程文件是否存在

		FTPFile[] files = ftpclient.listFiles(remoteFilePath);
		String[] NameList = new String[files.length];
		/*if(files.length == 0){
			if (logger.isEnableFor("Component3019")) {
				logger.log("Component3019", remoteFilePath, ftpclient.getReplyCode());
			}

			List<String> errorDetailList = createErrorDetailListForDoGet(remoteFilePath, localFilePath, binaryMode);
			errorDetailList.add("reply=" + replyString.toString());
			throw new FtpCmpException("获取的目录下不存在文件",
					ComponentFtpConst.ERROR_CANNOT_GET, errorDetailList);
		}*/
		
		/*if (binaryMode) {
			// 设定二进制BIN传输模式
			ftpclient.setFileType(FTP.BINARY_FILE_TYPE);
		} else {
			// 设定ASCII文本传输模式
			ftpclient.setFileType(FTP.ASCII_FILE_TYPE);
		}*/
		
		//boolean result = false;
		int i=0;
		for (FTPFile ftpFile : files) {
			NameList[i]=ftpFile.getName();
			i++;
		}
		
		return NameList;

	}
	public final boolean deleteFile(final String FilePath) throws IOException {
	
		FTPClient ftpclient = this._ftpConnection.getConnection();
		
		boolean flag =ftpclient.deleteFile(FilePath);
		
		return flag;
	}
	
	public final boolean renamelFile(final String from,final String to ) throws IOException {
		
		FTPClient ftpclient = this._ftpConnection.getConnection();
		
		boolean flag =ftpclient.rename(from, to);
		return flag;
	}
	
	
	
	
public final void doMkdirs(final String directoryName ,final String  directory ) throws IOException {
	      
	       String [] directorys =directory.split("/");
	       
	       doChdir(directoryName, new StringBuffer());
			for(int i=0;i<directorys.length;i++){
				if(directorys[i].length()>0){
				doMkdir(directorys[i], new StringBuffer());
				doChdir(directorys[i], new StringBuffer());
				}
				}
			}
	
	
}///:~
