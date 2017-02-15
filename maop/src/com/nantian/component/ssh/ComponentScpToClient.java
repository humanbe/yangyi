package com.nantian.component.ssh;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;

import com.nantian.component.log.Logger;

import ch.ethz.ssh2.Connection;
import ch.ethz.ssh2.Session;

/**
 * 从本地主机往远程目标主机复制文件
 * @author dong
 */
public class ComponentScpToClient {

	/**
	 * Logger
	 */
	private static Logger logger = Logger.getLogger(ComponentScpToClient.class);

	/**
	 * 文件传送用的缓冲区大小
	 */
	public static final int FILE_BUFF_SIZE = 8192;

	/**
	 * 接受命令用的缓冲区大小
	 */
	public static final int RECV_BUFF_SIZE = 4096;

	/**
	 * 发送命令的缓冲区大小
	 */
	public static final int SEND_BUFF_SIZE = 512;

	/**
	 * 文件的默认权限
	 */
	public static final String DEFAULT_FILE_PERMISSION = "644";

	/**
	 * 目录的默认权限
	 */
	public static final String DEFAULT_DIR_PERMISSSION = "755";

	/**
	 * SSH连接对象
	 */
	private Connection _connection;

	/**
	 * 字符集
	 */
	private String _charsetName;

	/**
	 * 异常列表
	 */
	private List<String> _errorDetailList;

	/**
	 * 处理对象的本地路径
	 */
	private String _targetLocalPath;

	/**
	 * 处理对象的远程目标路径
	 */
	private StringBuilder _targetRemotePath;


	/**
	 * 返回详细异常列表信息
	 *
	 * @return 详细异常列表信息
	 */
	public final List<String> getErrorDetailList() {
		return this._errorDetailList;
	}

	/**
	 * 构造函数
	 *
	 * @param sshConnection SSH连接Object
	 */
	protected ComponentScpToClient(final ComponentSshConnection sshConnection) {
		this._connection = sshConnection.getConnection();
		this._charsetName = sshConnection.getCharsetName();
		this._errorDetailList = new ArrayList<String>();
		this._targetLocalPath = null;
		this._targetRemotePath = null;
	}

	/**
	 * 从本地主机往远程目标主机复制文件
	 *
	 * @param localFile 本地文件
	 * @param remotePath 远程目标路径
	 * @param permission 权限
	 * @return 处理结果(true:正常 / false:SCP操作发生异常)
	 */
	public final boolean putFile(final File localFile, final String remotePath, final String permission) {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "putFile");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "localFile;remotePath;permission", localFile + ";" + remotePath + ";" + permission);
		}

		// 初始化处理结果及异常详细列表
		boolean result = true;
		this._errorDetailList.clear();

		String cmd = "scp -t ";
		cmd += ComponentSshUtil.convertScpPassphrase(remotePath);

		if (logger.isDebugEnable()) {
			logger.debug("localFile : " + localFile.getPath());
			logger.debug("remotePath : " + remotePath);
			logger.debug("cmd : " + cmd);
		}

		// 更新处理对象路径
		this._targetLocalPath = localFile.getPath();
		this._targetRemotePath = new StringBuilder(ComponentSshUtil.convertScpPassphrase(remotePath));
		this._targetRemotePath.append("/");
		this._targetRemotePath.append(localFile.getName());

		Session session = null;
		try {
			session = this._connection.openSession();
			session.execCommand(cmd);

			OutputStream out = new BufferedOutputStream(session.getStdin(), SEND_BUFF_SIZE);
			InputStream in = new BufferedInputStream(session.getStdout(), RECV_BUFF_SIZE);
			ComponentSshUtil.waitForAck(in);

			sendFile(localFile, permission, in, out);

		} catch (IOException e) {
			// 添加异常信息，但不抛出异常
			addErrorDetail(e);
			if (logger.isEnableFor("Component1031")) {
				logger.log("Component1031", e.toString());
			}

		} finally {
			if (session != null) {
				session.close();
			}
		}
		
		// 若存在异常信息则返回false
		if ( getErrorDetailList().size() > 0 ){
			result = false;
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "putFile");
		}

		return result;
	}

	/**
	 * 复制本地目录到远程目标主机
	 *
	 * @param localDir 本地目录
	 * @param remotePath 远程目标主机路径
	 * @param permission 权限
	 * @return 处理结果(true:正常 / false:SCP处理发生异常)
	 */
	public final boolean putDir(final File localDir, final String remotePath, final String permission) {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "putDir");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "localDir;remotePath;permission", localDir + ";" + remotePath + ";" + permission);
		}

		// 初始化处理结果及异常详细列表
		boolean result = true;
		this._errorDetailList.clear();

		String cmd = "scp -t -r -d ";
		cmd += ComponentSshUtil.convertScpPassphrase(remotePath);

		if (logger.isDebugEnable()) {
			logger.debug("localDir : " + localDir.getPath());
			logger.debug("remotePath : " + remotePath);
			logger.debug("cmd : " + cmd);
		}

		// 更新处理对象路径
		this._targetLocalPath = localDir.getPath();
		this._targetRemotePath = new StringBuilder(ComponentSshUtil.convertScpPassphrase(remotePath));

		Session session = null;
		try {
			session = this._connection.openSession();
			session.execCommand(cmd);

			OutputStream out = new BufferedOutputStream(session.getStdin(), SEND_BUFF_SIZE);
			InputStream in = new BufferedInputStream(session.getStdout(), RECV_BUFF_SIZE);
			ComponentSshUtil.waitForAck(in);

			sendDir(localDir, permission, in, out);

		} catch (IOException e) {
			// 添加异常信息，但不抛出异常
			addErrorDetail(e);
			if (logger.isEnableFor("Component1031")) {
				logger.log("Component1031", e.toString());
			}
		} finally {
			if (session != null) {
				session.close();
			}
		}
		
		// 若详细异常列表存在信息则返回false
		if ( getErrorDetailList().size() > 0 ){
			result = false;
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "putDir");
		}

		return result;
	}

	/**
	 * 设定复制的文件、目录的时间
	 *
	 * @param file 复制的文件、目录
	 * @param in 输入流
	 * @param out 输出流
	 * @throws IOException 发生异常
	 */
	private void sendTime(final File file, final InputStream in, final OutputStream out) throws IOException {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "sendTime");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "file;in;out", file + ";" + in + ";" + out);
		}

		long mtime = file.lastModified() / 1000;
		long atime = System.currentTimeMillis() / 1000;
		String timestamp = "T " + mtime + " 0 " + atime + " 0\n";
		out.write(timestamp.getBytes());
		out.flush();
		ComponentSshUtil.waitForAck(in);

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "sendTime");
		}
	}

	/**
	 * 指定文件权限复制
	 *
	 * @param localFile 复制的文件
	 * @param permission 权限
	 * @param in 输入流
	 * @param out 输出流
	 * @throws IOException 发生异常
	 */
	private void sendFile(final File localFile, final String permission, final InputStream in,
			final OutputStream out) throws IOException {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "sendFile");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "localFile;permission;in;out",
					   localFile + ";" + permission + ";" + in + ";" + out);
		}

		String filePermission = permission;
		if (filePermission == null) {
			filePermission = DEFAULT_FILE_PERMISSION;
		}

		sendTime(localFile, in, out);

		String cmd = "C0" + filePermission + " " + localFile.length() + " " + localFile.getName() + "\n";
		out.write(cmd.getBytes(this._charsetName));
		out.flush();
		ComponentSshUtil.waitForAck(in);

		FileInputStream fis = new FileInputStream(localFile);
		byte[] buf = new byte[FILE_BUFF_SIZE];
		int len;
		try {
			while ((len = fis.read(buf, 0, FILE_BUFF_SIZE)) >= 0) {
				out.write(buf, 0, len);
			}
			out.flush();
			ComponentSshUtil.sendAck(out);
			ComponentSshUtil.waitForAck(in);
		} finally {
			fis.close();
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "sendFile");
		}
	}

	/**
	 * 指定目录权限复制
	 *
	 * @param localDir 执行复制操作的本地目录
	 * @param permission 权限
	 * @param in 输入流
	 * @param out 输出流
	 */
	private void sendDir(final File localDir, final String permission, final InputStream in, final OutputStream out) {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "sendDir");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "localDir;permission;in;out",
					   localDir + ";" + permission + ";" + in + ";" + out);
		}

		File[] files = localDir.listFiles(new FileFilter() {
			public boolean accept(final File pathname) {
				return pathname.isFile();
			}
		});

		String remotePathWork = this._targetRemotePath.toString();
		if (files != null) {
			for (int i = 0; i < files.length; i++) {
				File file = files[i];

				// 更新处理对象的路径
				this._targetLocalPath = file.getPath();
				this._targetRemotePath = new StringBuilder(remotePathWork);
				this._targetRemotePath.append("/");
				this._targetRemotePath.append(file.getName());
				try {
					sendFile(file, permission, in, out);

				} catch (IOException e) {
					// 添加异常信息到异常信息列表后继续执行
					addErrorDetail(e);
					if (logger.isEnableFor("Component1031")) {
						logger.log("Component1031", e.toString());
					}
					continue;
				}
			}
		}

		File[] dirs = localDir.listFiles(new FileFilter() {
			public boolean accept(final File pathname) {
				return pathname.isDirectory();
			}
		});
		if (dirs != null) {
			for (int i = 0; i < dirs.length; i++) {
				File dir = dirs[i];

				// 更新处理对象的路径
				this._targetLocalPath = dir.getPath();
				this._targetRemotePath = new StringBuilder(remotePathWork);
				this._targetRemotePath.append("/");
				this._targetRemotePath.append(dir.getName());
				try {
					sendDirectoryEntry(dir, permission, in, out);

				} catch (IOException e) {
					// 添加异常信息到异常信息列表后继续执行
					addErrorDetail(e);
					if (logger.isEnableFor("Component1031")) {
						logger.log("Component1031", e.toString());
					}
					continue;
				}
			}
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "sendDir");
		}
	}

	/**
	 * 发送目录信息
	 *
	 * @param dir 发送的目录信息
	 * @param permission 权限
	 * @param in 输入流
	 * @param out 输出流
	 * @throws IOException 发生异常
	 */
	private void sendDirectoryEntry(final File dir, final String permission, final InputStream in,
			final OutputStream out) throws IOException {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "sendDirectoryEntry");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "dir;permission;in;out",
					   dir + ";" + permission + ";" + in + ";" + out);
		}

		String filePermission = permission;
		if (filePermission == null) {
			filePermission = DEFAULT_DIR_PERMISSSION;
		}

		String cmd = "D0" + filePermission + " 0 " + dir.getName() + "\n";
		out.write(cmd.getBytes(this._charsetName));
		out.flush();

		ComponentSshUtil.waitForAck(in);
		sendDir(dir, filePermission, in, out);
		out.write("E\n".getBytes());
		out.flush();
		ComponentSshUtil.waitForAck(in);

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "sendDirectoryEntry");
		}
	}

	/**
	 * 异常信息添加到异常详细列表中
	 *
	 * @param t Throwable对象
	 */
	private void addErrorDetail(final Throwable t) {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "addErrorDetail");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "t", t);
		}

		String errorDetail = "HostName=" + this._connection.getHostname()
				+ " LocalPath=" + this._targetLocalPath
				+ " RemotePath=" + this._targetRemotePath.toString()
				+ " Message=" + t.getMessage();

		if (!this._errorDetailList.contains(errorDetail)) {
			this._errorDetailList.add(errorDetail);
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "addErrorDetail");
		}
	}
}
