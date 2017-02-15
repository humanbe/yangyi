package com.nantian.component.ssh;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import com.nantian.component.com.ComponentException;
import com.nantian.component.log.Logger;

import ch.ethz.ssh2.Session;
import ch.ethz.ssh2.Connection;

/**
 * SSH操作类
 * @author dong
 */
public class ComponentSsh {

	/**
	 * 输出信息用的缓冲区大小
	 */
	private static final int BUFFER_SIZE = 4096;

	/**
	 * Logger
	 */
	private static Logger logger = Logger.getLogger(ComponentSsh.class);

	/**
	 * SSH连接
	 */
	private ComponentSshConnection _SshConnection;

	/**
	 * 构造函数
	 * @param sshConnection ComponentSshConnection
	 */
	public ComponentSsh(final ComponentSshConnection sshConnection) {
		this._SshConnection = sshConnection;
	}

	/**
	 * 利用SCP操作，把本地文件复制到远程目标主机
	 *
	 * <UL><B>异常编码：异常原因</B>
	 * <LI>10000004：未指定要复制的源文件或者目录的路径
	 * <LI>10000004：未指定要复制的目标目录的路径
	 * <LI>10000004：未指定复制文件的权限
	 * <LI>10000005：mkdir命令不存在
	 * <LI>10000006：SCP处理发生异常
	 * <LI>10000011：要复制源文件或者目录的路径不存在
	 * <LI>10009999：发生未知异常
	 * </UL>
	 *
	 * @param localPath 要复制的源文件或者目录的路径
	 * @param remotePath 要复制的目标目录的路径
	 * @param permission 复制文件的权限
	 */
	public final void doPut(final String localPath, final String remotePath, final String permission) {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doPut");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "localPath;remotePath;permission",
						localPath + ";" + remotePath + ";" + permission);
		}

		if (localPath == null || localPath.trim().equals("")) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "要复制源的文件或者目录的路径");
			}

			throw new ComponentException("未指定要复制的源文件或者目录的路径",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		if (remotePath == null || remotePath.trim().equals("")) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "要复制的目标目录的路径");
			}

			throw new ComponentException("未指定要复制的目标目录的路径",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		if (permission == null || permission.trim().equals("")) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "复制文件的权限");
			}

			throw new ComponentException("未指定复制文件的权限",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}
		
		Connection connection = this._SshConnection.getConnection();
		if (connection == null){
			if (logger.isEnableFor("Component1008")) {
				logger.log("Component1008", "server", this._SshConnection.getServerName());
			}
			throw new ComponentException("未登录主机",
					ComponentSshConst.ERROR_NOT_CONNECT);
		}

		File localFile = new File(localPath);
		if (logger.isDebugEnable()) {
			logger.debug("doPut scp " + localFile.getAbsolutePath() + " "
				+ connection.getHostname() + ":" + remotePath);
		}

		StringBuffer stdOut = new StringBuffer();
		StringBuffer stdErr = new StringBuffer();
		if (doMkdir(remotePath, stdOut, stdErr) != 0) {
			List<String> errorDetailList = new ArrayList<String>();
			errorDetailList.add("server=" + this._SshConnection.getServerName());
			errorDetailList.add("userId=" + this._SshConnection.getUserId());
			errorDetailList.add("charsetName=" + this._SshConnection.getCharsetName());
			errorDetailList.add("remotePath=" + remotePath);
			errorDetailList.add("stdOut=" + stdOut.toString());
			errorDetailList.add("stdErr=" + stdErr.toString());

			throw new ComponentException("命令执行失败", ComponentSshConst.ERROR_BAD_COMMAND, errorDetailList);
		}

		// ScpToClient的实例
		ComponentScpToClient client = new ComponentScpToClient(this._SshConnection);
		boolean result = false;
		if (localFile.isDirectory()) {
			result = client.putDir(localFile, remotePath, permission);
		} else if (localFile.isFile()) {
			result = client.putFile(localFile, remotePath, permission);
		} else {
			if (logger.isEnableFor("Component1011")) {
				logger.log("Component1011", localFile);
			}

			throw new ComponentException("要复制源的文件或者目录的路径不存在",
					ComponentSshConst.ERROR_FILE_NOT_FOUND);
		}

		if (!result) {
			if (logger.isEnableFor("Component1006")) {
				logger.log("Component1006", client.getErrorDetailList());
			}

			List<String> errorDetailList = client.getErrorDetailList();
			errorDetailList.add("server=" + this._SshConnection.getServerName());
			errorDetailList.add("userId=" + this._SshConnection.getUserId());
			errorDetailList.add("charsetName=" + this._SshConnection.getCharsetName());

			throw new ComponentException("SCP处理发生异常",
					ComponentSshConst.ERROR_SCP, errorDetailList);
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doPut");
		}
	}

	/**
	 * 利用SCP操作，把远程主机文件递归的复制到本地
	 *
	 * <code>remotePath</code>下指定的文件复制到<code>localPath</code>指定的目录
	 * <code>remotePath</code>如果是目录，则整个目录包括子目录全部复制
	 *
	 * <UL><B>异常编码：异常原因</B>
	 * <LI>10000004：未指定要复制的源文件或者目录的路径
	 * <LI>10000004：未指定要复制到的目标目录的路径
	 * <LI>10000006：SCP处理发生异常
	 * <LI>10009999：发生未知异常
	 * </UL>
	 *
	 * @param remotePath 要复制的源文件路径。若要进行递归处理，则路径的最后要加<code>/*</code>
	 * @param localPath 要复制到的目标目录的路径
	 */
	public final void doGet(final String remotePath, final String localPath) {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doGet");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "remotePath;localPath", remotePath + ";" + localPath);
		}

		if (remotePath == null || remotePath.trim().equals("")) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "要复制的源文件或者目录的路径");
			}

			throw new ComponentException("未指定要复制的源文件或者目录的路径",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		if (localPath == null || localPath.trim().equals("")) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "要复制到的目标目录的路径");
			}

			throw new ComponentException("未指定要复制到的目标目录的路径",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		Connection connection = this._SshConnection.getConnection();
		if (connection == null){
			if (logger.isEnableFor("Component1008")) {
				logger.log("Component1008", "server", this._SshConnection.getServerName());
			}
			throw new ComponentException("未登录主机",
					ComponentSshConst.ERROR_NOT_CONNECT);
		}

		// ScpFromClient实例
		ComponentScpFromClient client = new ComponentScpFromClient(this._SshConnection);
		// 复制文件
		if (!client.getRecursive(new String[]{remotePath}, localPath)) {
			if (logger.isEnableFor("Component1006")) {
				logger.log("Component1006", client.getErrorDetailList());
			}

			List<String> errorDetailList = client.getErrorDetailList();
			errorDetailList.add("server=" + this._SshConnection.getServerName());
			errorDetailList.add("userId=" + this._SshConnection.getUserId());
			errorDetailList.add("charsetName=" + this._SshConnection.getCharsetName());

			throw new ComponentException("SCP处理发生异常",
					ComponentSshConst.ERROR_SCP, errorDetailList);
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doGet");
		}
	}

	/**
	 * 利用SSH连接SESSION，在远程主机递归的创建目录<BR>
	 * 若上级父目录不存在，则也被创建
	 *
	 * <UL><B>异常编码：异常原因</B>
	 * <LI>10000004：未指定要复制到的目标主机目录的路径
	 * <LI>10000004：未指定标准输出
	 * <LI>10000004：未指定标准异常输出
	 * <LI>10000005：命令执行失败
	 * <LI>10009999：发生未知异常
	 * </UL>
	 *
	 * @param dirPath 要复制到的目标主机目录的路径
	 * @param stdOut 标准输出
	 * @param stdErr 标准异常输出
	 * @return 处理结果 (0:正常 / 0以外:异常)
	 */
	public final int doMkdir(final String dirPath, final StringBuffer stdOut, final StringBuffer stdErr) {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doMkdir");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "dirPath", dirPath);
		}

		if (dirPath == null || dirPath.trim().equals("")) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "要复制到的目标主机目录的路径");
			}

			throw new ComponentException("未指定要复制到的目标主机目录的路径",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		if (stdOut == null) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "标准输出");
			}

			throw new ComponentException("未指定标准输出",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		if (stdErr == null) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "标准异常输出");
			}

			throw new ComponentException("未指定标准异常输出",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		StringBuffer cmd = new StringBuffer();
		cmd.append("mkdir -p ");
		cmd.append(ComponentSshUtil.convertScpPassphrase(dirPath.toString()));

		int ret = doCmdExec(cmd.toString(), stdOut, stdErr);

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doMkdir");
		}

		return ret;
	}

	/**
	 * 利用SSH SESSION，递归变更指定目录的权限
	 *
	 * <UL><B>异常编码：异常原因</B>
	 * <LI>10000004：未指定权限变更的目录
	 * <LI>10000004：未指定变更的权限值
	 * <LI>10000004：未指定标准输出
	 * <LI>10000004：未指定标准异常输出
	 * <LI>10000005：命令执行失败
	 * <LI>10009999：发生未知异常
	 * </UL>
	 *
	 * @param filePath 进行权限变更的目录
	 * @param perm 变更的权限值
	 * @param stdOut 标准输出
	 * @param stdErr 标准异常输出
	 * @return 处理结果 (0:正常 / 0以外:异常)
	 */
	public final int doChmodR(final String filePath, final String perm,
			final StringBuffer stdOut, final StringBuffer stdErr) {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doChmodR");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "filePath;perm", filePath + ";" + perm);
		}

		if (filePath == null || filePath.trim().equals("")) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "进行权限变更的目录");
			}

			throw new ComponentException("未指定进行权限变更的目录",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		if (perm == null || perm.trim().equals("")) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "变更的权限值");
			}

			throw new ComponentException("未指定变更的权限值",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		if (stdOut == null) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "标准输出");
			}

			throw new ComponentException("未指定标准输出",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		if (stdErr == null) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "标准异常输出");
			}

			throw new ComponentException("未指定标准异常输出",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		StringBuffer cmd = new StringBuffer();
		cmd.append("chmod -R ");
		cmd.append(perm).append(" ");
		cmd.append(ComponentSshUtil.convertScpPassphrase(filePath.toString()));

		int ret = doCmdExec(cmd.toString(), stdOut, stdErr);

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doChmodR");
		}

		return ret;
	}

	/**
	 * 利用SSH SESSION，变更指定的文件的权限
	 * 
	 * <UL><B>异常编码：异常原因</B>
	 * <LI>10000004：未指定权限变更的文件
	 * <LI>10000004：未指定变更的权限值
	 * <LI>10000004：未指定标准输出
	 * <LI>10000004：未指定标准异常输出
	 * <LI>10000005：命令执行失败
	 * <LI>10009999：发生未知异常
	 * </UL>
	 *
	 * @param filePath 变更权限的文件
	 * @param perm 变更的权限值
	 * @param stdOut 标准输出
	 * @param stdErr 标准异常输出
	 * @return 处理结果 (0:正常 / 0以外:异常)
	 */
	public final int doChmod(final String filePath, final String perm,
			final StringBuffer stdOut, final StringBuffer stdErr) {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doChmod");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "filePath;perm", filePath + ";" + perm);
		}

		if (filePath == null || filePath.trim().equals("")) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "变更权限的文件");
			}

			throw new ComponentException("未指定变更权限的文件",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		if (perm == null || perm.trim().equals("")) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "变更的权限值");
			}

			throw new ComponentException("未指定变更的权限值",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		if (stdOut == null) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "标准输出");
			}

			throw new ComponentException("未指定标准输出",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		if (stdErr == null) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "标准异常输出");
			}

			throw new ComponentException("未指定标准异常输出",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		StringBuffer cmd = new StringBuffer();
		cmd.append("chmod ");
		cmd.append(perm).append(" ");
		cmd.append(ComponentSshUtil.convertScpPassphrase(filePath.toString()));

		int ret = doCmdExec(cmd.toString(), stdOut, stdErr);

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doChmod");
		}

		return ret;
	}

	/**
	 * 利用SSH SESSION，递归的删除指定的目录
	 *
	 * <UL><B>异常编码：异常原因</B>
	 * <LI>10000004：未指定要删除的目录的路径
	 * <LI>10000004：未指定标准输出
	 * <LI>10000004：未指定标准异常输出
	 * <LI>10000005：命令执行失败
	 * <LI>10009999：发生未知异常
	 * </UL>
	 *
	 * @param filePath 要删除的目录路径
	 * @param stdOut 标准输出
	 * @param stdErr 标准异常输出
	 * @return 处理结果 (0:正常 / 0以外:异常)
	 */
	public final int doRm(final String filePath, final StringBuffer stdOut, final StringBuffer stdErr) {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doRm");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "filePath", filePath);
		}

		if (filePath == null || filePath.trim().equals("")) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "要删除的目录的路径");
			}

			throw new ComponentException("未指定要删除的目录的路径",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		if (stdOut == null) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "标准输出");
			}

			throw new ComponentException("未指定标准输出",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		if (stdErr == null) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "标准异常输出");
			}

			throw new ComponentException("未指定标准异常输出",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		StringBuffer cmd = new StringBuffer();
		cmd.append("rm -rf ");
		cmd.append(ComponentSshUtil.convertScpPassphrase(filePath.toString()));

		int ret = doCmdExec(cmd.toString(), stdOut, stdErr);

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doRm");
		}

		return ret;
	}

	/**
	 * 利用SSH SESSION，对指定的文件移动或者修改名字<BR>
	 * 若要移动的目标位置存在同名文件则不进行提示,直接覆盖
	 * 若指定的不存在的目录，则抛出ComponentException异常
	 *
	 * <UL><B>异常编码：异常原因</B>
	 * <LI>10000004：未指定要删除目录的路径
	 * <LI>10000004：未指定标准输出
	 * <LI>10000004：未指定标准异常输出
	 * <LI>10000005：命令执行失败
	 * <LI>10009999：发生未知异常
	 * </UL>
	 *
	 * @param filePathTarget 文件对象路径
	 * @param filePathDest 移动或者改名后的文件路径
	 * @param stdOut 标准输出
	 * @param stdErr 标准异常输出
	 * @return 处理结果 (0:正常 / 0以外:异常)
	 */
	public final int doMv(final String filePathTarget, final String filePathDest,
			final StringBuffer stdOut, final StringBuffer stdErr) {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doMv");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "filePathTarget;filePathDest",
						filePathTarget + ";" + filePathDest);
		}

		if (filePathTarget == null || filePathTarget.trim().equals("")) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "要移动的源文件");
			}

			throw new ComponentException("未指定要移动的源文件",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		if (filePathDest == null || filePathDest.trim().equals("")) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "移动后的目标文件");
			}

			throw new ComponentException("未指定移动后的目标文件",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		if (stdOut == null) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "标准输出");
			}

			throw new ComponentException("未指定标准输出",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		if (stdErr == null) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "标准异常输出");
			}

			throw new ComponentException("未指定标准异常输出",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		StringBuffer cmd = new StringBuffer();
		cmd.append("mv -f ");
		cmd.append(ComponentSshUtil.convertScpPassphrase(filePathTarget.toString()));
		cmd.append(" ");
		cmd.append(ComponentSshUtil.convertScpPassphrase(filePathDest.toString()));

		int ret = doCmdExec(cmd.toString(), stdOut, stdErr);

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doMv");
		}

		return ret;
	}

	/**
	 * 利用SSH SESSION，在远程主机执行命令
	 *
	 * <UL><B>异常编码：异常原因</B>
	 * <LI>10000004：未指定命令
	 * <LI>10000004：未指定标准输出
	 * <LI>10000004：未指定标准异常输出
	 * <LI>10000005：命令执行失败
	 * <LI>10009999：发生未知异常
	 * </UL>
	 *
	 * @param cmd 命令
	 * @param stdOut 标准输出
	 * @param stdErr 标准异常输出
	 * @return 处理结果 (0:正常 / 0以外:异常)
	 */
	public final int doCmdExec(final String cmd, final StringBuffer stdOut, final StringBuffer stdErr) {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "doCmdExec");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "cmd", cmd);
		}

		if (cmd == null || cmd.trim().equals("")) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "命令");
			}

			throw new ComponentException("未指定命令",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		if (stdOut == null) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "标准输出");
			}

			throw new ComponentException("未指定标准输出",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		if (stdErr == null) {
			if (logger.isEnableFor("Component1004")) {
				logger.log("Component1004", "标准异常输出");
			}

			throw new ComponentException("未指定标准异常输出",
					ComponentSshConst.ERROR_INVALID_PARAMETER);
		}

		// 创建SSH SESSION
		Session session;
		try {
			Connection connection = this._SshConnection.getConnection();
			if (connection == null){
				if (logger.isEnableFor("Component1008")) {
					logger.log("Component1008", "server", this._SshConnection.getServerName());
				}
				throw new ComponentException("未登录主机",
						ComponentSshConst.ERROR_NOT_CONNECT);
			}
			session = connection.openSession();
			// 执行命令
			session.execCommand(cmd);

			// 获取异常输出
			stdErr.append(streamToString(session.getStderr()));
			stdOut.append(streamToString(session.getStdout()));

		} catch (IOException e) {
			if (logger.isEnableFor("Component1999")) {
				logger.log("Component1999", e, e.getMessage(), "cmd", cmd );
			}

			List<String> errorDetailList = new ArrayList<String>();
			errorDetailList.add("server=" + this._SshConnection.getServerName());
			errorDetailList.add("userId=" + this._SshConnection.getUserId());
			errorDetailList.add("charsetName=" + this._SshConnection.getCharsetName());
			errorDetailList.add("cmd=" + cmd);
			errorDetailList.add("stdOut=" + stdOut.toString());
			errorDetailList.add("stdErr=" + stdErr.toString());

			throw new ComponentException("发生未知异常", ComponentSshConst.ERROR_UNKNOWN, errorDetailList, e);
		}

		Integer ret	= null;
		try {
			ret	= session.getExitStatus();

		} catch (Exception e) {
			if (logger.isEnableFor("Component1999")) {
				logger.log("Component1999", e, e.getMessage(), "cmd", cmd);
			}

			List<String> errorDetailList = new ArrayList<String>();
			errorDetailList.add("server=" + this._SshConnection.getServerName());
			errorDetailList.add("userId=" + this._SshConnection.getUserId());
			errorDetailList.add("charsetName=" + this._SshConnection.getCharsetName());
			errorDetailList.add("cmd=" + cmd);
			errorDetailList.add("stdOut=" + stdOut.toString());
			errorDetailList.add("stdErr=" + stdErr.toString());

			throw new ComponentException("发生未知异常", ComponentSshConst.ERROR_UNKNOWN, errorDetailList, e);
		} finally {
			// 关闭SSH SESSION
			session.close();
		}

		if (ret == null) {
			ret = stdErr.toString().trim().equals("") ? 0 : -1;
		}

		if (ret != 0) {
			if (logger.isEnableFor("Component1005")) {
				logger.log("Component1005", cmd.toString(), stdOut.toString(), stdErr.toString());
			}
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "doCmdExec");
		}

		return ret;
	}

	/**
	 * 从标准输出获取命令执行结果
	 *
	 * @param in 执行命令的标准输出
	 * @return 标准输出的内容
	 * @throws IOException 发生异常
	 */
	private String streamToString(final InputStream in) throws IOException {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "streamToString");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "in", in);
		}

		byte[] buf = new byte[BUFFER_SIZE];
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		int len;
		len = in.read(buf, 0, BUFFER_SIZE);
		while (len > 0) {
			out.write(buf, 0, len);
			len = in.read(buf, 0, BUFFER_SIZE);
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "streamToString");
		}

		return out.toString(this._SshConnection.getCharsetName());
	}
}
