package com.nantian.component.ssh;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.EOFException;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;

import com.nantian.component.com.ComponentException;
import com.nantian.component.log.Logger;

import ch.ethz.ssh2.Connection;
import ch.ethz.ssh2.Session;

/**
 * 从远程目标主机递归获取文件
 * @author dong
 */
public class ComponentScpFromClient {

	/**
	 * Logger
	 */
	private static Logger logger = Logger.getLogger(ComponentScpFromClient.class);

	/**
	 * 接受文件的缓冲区大小
	 */
	private static final int BUFFER_SIZE = 8192;

	/**
	 * SSH连接Object
	 */
	private Connection _connection;

	/**
	 * �����Z�b�g
	 */
	private String _charsetName;

	/**
	 * 字符集
	 */
	private List<String> _errorDetailList;


	/**
	 * 返回异常信息
	 *
	 * @return 详细异常信息
	 */
	public final List<String> getErrorDetailList() {
		return this._errorDetailList;
	}


	/**
	 * 构造函数
	 *
	 * @param sshConnnection SSH连接Object
	 */
	protected ComponentScpFromClient(final ComponentSshConnection sshConnnection) {
		this._connection = sshConnnection.getConnection();
		this._charsetName = sshConnnection.getCharsetName();
		this._errorDetailList = new ArrayList<String>();
	}

	/**
	 * 从远程目标主机下载文件
	 *
	 * <UL><B>异常编码：异常原因</B>
	 * <LI>10000004：未指定要复制的源文件或者目录的路径
	 * <LI>10000004：未指定目标目录的路径
	 * </UL>
	 *
	 * @param remoteFiles 要复制的远程主机文件
	 * @param localPath 保存下载文件的本地目录
	 * @return 处理结果(true:正常 / false:SCP操作异常)
	 */
	public final boolean getRecursive(final String[] remoteFiles, final String localPath) {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "getRecursive");
		}

		StringBuffer params = new StringBuffer();
		StringBuffer values = new StringBuffer();
		if (logger.isEnableFor("Component0003")) {
			if (remoteFiles != null) {
				for (int i = 0; i < remoteFiles.length; i++) {
					params.append("remoteFiles;");
					values.append(remoteFiles[i]);
					values.append(";");
				}
			}
			params.append("localPath");
			values.append(localPath);
			logger.log("Component0003", params.toString(), values.toString());
		}

		boolean result = true;
		Session sess = null;

		if (remoteFiles == null) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "要复制的源文件或者目录的路径");
			}

			throw new ComponentException("未指定要复制的源文件或者目录的路径",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		if (localPath == null || localPath.trim().equals("")) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "要复制的目标目录的路径");
			}

			throw new ComponentException("未指定目标目录的路径",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		String cmd = "scp -f -r -p ";

		StringBuffer cmdBuf = new StringBuffer(cmd);
		for (int i = 0; i < remoteFiles.length; i++) {
			if (remoteFiles[i] == null || remoteFiles[i].trim().equals("")) {
				if (logger.isEnableFor("Component1004")) {
					logger.log("Component1004", "要复制的源文件或者目录的路径");
				}

				throw new ComponentException("未指定要复制的源文件或者目录的路径",
						ComponentSshConst.ERROR_INVALID_PARAMETER);
			}

			cmdBuf.append(ComponentSshUtil.convertScpPassphrase(remoteFiles[i].trim()));
		}

		if (logger.isDebugEnable()) {
			logger.debug("getRecursive cmd : " + cmdBuf.toString());
		}

		try {
			sess = this._connection.openSession();
			sess.execCommand(cmdBuf.toString());
			execute(sess, localPath);

		} catch (ComponentException e) {
			// 添加详细异常信息
			addErrorDetail(remoteFiles, localPath, e);
			if (logger.isDebugEnable()) {
				logger.debug("发生未知异常", e.toString());
			}
			result = false;

		} catch (IOException e) {
			// 添加详细异常信息
			addErrorDetail(remoteFiles, localPath, e);
			if (logger.isDebugEnable()) {
				logger.debug("发生未知异常", e.toString());
			}
			result = false;

		} finally {
			if (sess != null) {
				sess.close();
			}
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "getRecursive");
		}

		return result;
	}

	/**
	 * 执行处理
	 *
	 * @param session Object
	 * @param localToDir 保存文件的本地目录
	 * @throws IOException 发生异常
	 */
	private void execute(final Session session, final String localToDir) throws IOException, ComponentException {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "execute");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "session;localToDir", session + ";" + localToDir);
		}

		File toDir = new File(localToDir);
		long lastModified = -1;

		OutputStream out = new BufferedOutputStream(session.getStdin(), 512);
		InputStream in = new BufferedInputStream(session.getStdout(), 40000);

		ComponentSshUtil.sendAck(out);

		int start, end;
		while (true) {
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			while (true) {
				int ch = in.read();
				if (ch < 0) {
					// 输出执行完成结果
					if (logger.isEnableFor("Component0002")) {
						logger.log("Component0002", "execute");
					}
					return;
				}
				if (ch == 0x0a) {
					break;
				}
				baos.write((byte) ch);
			}
			String line = baos.toString(this._charsetName);

			char c = line.charAt(0);

			switch (c) {
			case 'T':
				end = line.indexOf(' ');
				lastModified = 1000L * Long.parseLong(line.substring(1, end));

				ComponentSshUtil.sendAck(out);
				break;

			case 'C':
				parseAndRecieveFile(line, toDir, out, in, lastModified);
				lastModified = -1;

				ComponentSshUtil.waitForAck(in);
				ComponentSshUtil.sendAck(out);
				break;

			case 'D':
				start = line.indexOf(' ');
				start = line.indexOf(' ', start + 1);
				String dirName = line.substring(start + 1);
				toDir = new File(toDir, dirName);
				if (!toDir.exists()) {
					if (!toDir.mkdir()) {
						if (logger.isEnableFor("Component1007")) {
							logger.log("Component1007", "mkdir");
						}
						throw new ComponentException("SCP处理(mkdir)发生异常",
								ComponentSshConst.ERROR_SCP);
					}
				}
				if (lastModified >= 0) {
					if (!toDir.setLastModified(lastModified)) {
						if (logger.isEnableFor("Component1007")) {
							logger.log("Component1007", "setLastModified");
						}
						throw new ComponentException("SCP处理(setLastModified)发生异常",
								ComponentSshConst.ERROR_SCP);					
					}
					lastModified = -1;
				}

				ComponentSshUtil.sendAck(out);
				break;

			case 'E':
				toDir = toDir.getParentFile();

				ComponentSshUtil.sendAck(out);
				break;

			case 0x01:
			case 0x02:
				throw new IOException("Remote SCP error: " + line);
			}
		}
	}

	/**
	 * 解析文件情报信息，然后开始接受文件
	 *
	 * @param line 文件情报信息
	 * @param baseDir 保存接受文件的基本目录
	 * @param out 输出流
	 * @param in 输入流
	 * @param lastModified 最后的更新时间
	 * @throws IOException 发生异常
	 */
	private void parseAndRecieveFile(final String line, final File baseDir, final OutputStream out,
			final InputStream in, final long lastModified) throws IOException {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "parseAndRecieveFile");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003",
					"line;baseDir;out;in;lastModified",
					line + ";"
					+ baseDir + ";"
					+ out + ";"
					+ in + ";"
					+ Long.toString(lastModified)
					);
		}

		int start = line.indexOf(' ');
		int end = line.indexOf(' ', start + 1);
		long fileSize = Long.parseLong(line.substring(start + 1, end));
		String fileName = line.substring(end + 1);
		File file = new File(baseDir, fileName);

		recieveFile(file, fileSize, out, in);
		if (lastModified >= 0) {
			if (!file.setLastModified(lastModified)) {
				if (logger.isEnableFor("Component1007")) {
					logger.log("Component1007", "setLastModified");
				}
			}
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "parseAndRecieveFile");
		}
	}

	/**
	 * 开始接受文件
	 *
	 * @param localFile 本地文件
	 * @param fileSize 文件大小
	 * @param out 输出流
	 * @param in 输入流
	 * @throws IOException 发生异常
	 */
	private void recieveFile(final File localFile, final long fileSize, final OutputStream out, final InputStream in)
			throws IOException {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "recieveFile");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003",
					"localFile;fileSize;out;in",
					localFile + ";"
					+ Long.toString(fileSize) + ";"
					+ out + ";"
					+ in
					);
		}

		byte[] buf = new byte[BUFFER_SIZE];
		ComponentSshUtil.sendAck(out);

		// read a content of lfile
		FileOutputStream fos = new FileOutputStream(localFile);

		try {
			int length;
			long totalLength = 0;
			long remainLength = fileSize;
			while (true) {
				length = in.read(buf, 0, (BUFFER_SIZE < remainLength) ? BUFFER_SIZE
						: (int) remainLength);
				if (length < 0) {
					/*
					 * length 一定是大于0的，所以此处逻辑无法执行到，只是作为代码的一部分保留
					 */
					throw new EOFException("Unexpected end of stream.");
				}
				fos.write(buf, 0, length);
				remainLength -= length;
				totalLength += length;
				if (remainLength == 0) {
					break;
				}
			}
		} finally {
			fos.flush();
			fos.close();
		}
		
		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "recieveFile");
		}
	}

	/**
	 * 追加异常信息到详细异常列表
	 *
	 * @param remoteFiles 远程源文件
	 * @param localPath 下载文件后要保存的本地路径
	 * @param t Throwable Object
	 */
	private void addErrorDetail(final String[] remoteFiles, final String localPath, final Throwable t) {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "addErrorDetail");
		}

		StringBuffer params = new StringBuffer();
		StringBuffer values = new StringBuffer();
		if (logger.isEnableFor("Component0003")) {
			if (remoteFiles != null) {
				for (int i = 0; i < remoteFiles.length; i++) {
					params.append("remoteFiles;");
					values.append(remoteFiles[i]);
					values.append(";");
				}
			}
			params.append("localPath;");
			values.append(localPath + ";");

			params.append("t");
			values.append(t.toString());

			logger.log("Component0003", params.toString(), values.toString());
		}

		StringBuilder sb = new StringBuilder();
		sb.append("HostName=" + this._connection.getHostname() + " RemoteFiles=");

		if (remoteFiles != null) {
			for (int i = 0; i < remoteFiles.length; i++) {
				if (i > 0) {
					sb.append(", ");
				}
				sb.append(remoteFiles[i]);
			}
		}
		sb.append(" LocalPath=" + localPath);
		sb.append(" Message=" + t.getMessage());

		String errorDetail = sb.toString();
		if (!this._errorDetailList.contains(errorDetail)) {
			this._errorDetailList.add(errorDetail);
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "addErrorDetail");
		}
	}
}
