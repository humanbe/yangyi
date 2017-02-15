package com.nantian.component.ssh;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import com.nantian.component.log.Logger;


/**
 * SSH共通类
 * @author dong
 */
public class ComponentSshUtil {

	/**
	 * Logger
	 */
	private static Logger logger = Logger.getLogger(ComponentSshUtil.class);

	/**
	 * 获取响应，若状态为error，则发生异常。
	 *
	 * 取得1byte的状态返回值，若为0则正常，若为1则异常，若为2则发生致命的异常。
	 *
	 * @param in 输入流
	 * @throws IOException 不能读取输入流时，抛出IO异常
	 */
	public static void waitForAck(final InputStream in) throws IOException {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "waitForAck");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "in", in);
		}

		int b = in.read();

		if (b == -1) {
			// didn't receive any response
			throw new IOException("No response from server");

		} else if (b != 0) {
			StringBuffer sb = new StringBuffer();

			int c = in.read();
			while (c > 0 && c != '\n') {
				sb.append((char) c);
				c = in.read();
			}

			if (b == 1) {
				throw new IOException("server indicated an error: "
										 + sb.toString());
			} else if (b == 2) {
				throw new IOException("server indicated a fatal error: "
										 + sb.toString());
			} else {
				throw new IOException("unknown response, code " + b
										 + " message: " + sb.toString());
			}
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "waitForAck");
		}
	}

	/**
	 * 输出流中
	 *
	 * @param out 输出流
	 * @throws IOException 发生异常
	 */
	public static void sendAck(final OutputStream out) throws IOException {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "sendAck");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "out", out);
		}

		out.write(0);
		out.flush();

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "sendAck");
		}
	}

	/**
	 * 若路径的开始存在【~】则替换为【$HOME】
	 *
	 * @param path 路径
	 * @return 替换后的路径
	 */
	public static String replaceHomeDirChar(final String path) {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "replaceHomeDirChar");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "path", path);
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "replaceHomeDirChar");
		}

		return path.replaceFirst("^~", "\\$HOME");
	}

	/**
	 * 从SERVER往客户端进行SCP传送时，变换路径
	 * <ol>
	 * 	<li>传送包含$HOME的路径，$HOME后面的路径按分隔符'/'分割
	 * 	<li>传送不包含$HOME的路径，路径按分隔符'/'分割
	 * </ol>
	 *
	 * @param tmp 路径
	 * @return 变换后的路径
	 */
	public static String convertScpPassphrase(final String tmp) {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "convertScpPassphrase");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "tmp", tmp);
		}

		String path = "";
		// 【~】替换为【$HOME】以【/】分割
		String[] tmpPath = (replaceHomeDirChar(tmp)).split("/");

		if (tmpPath.length > 0) {
			String homePath = tmpPath[0];

			// 若路径的开始为【~】或者【$HOME】
			if ("$HOME".equals(homePath) || "~".equals(homePath)) {
				StringBuilder dirPath = new StringBuilder();

				// 连接$HOME后面的路径
				for (int i = 0; i < tmpPath.length - 1; i++) {
					dirPath.append("/");
					dirPath.append(tmpPath[i + 1]);
				}
				path = "\"" + homePath + "\"\'" + dirPath.toString() + "\'";
			} else {
				path = "\'" + replaceHomeDirChar(tmp) + "\'";
			}
		} else {
			/*
			 * tmpPath.length 即时不存在"/",tmpPath[0]也存在，所以无法跑到ELSE逻辑，
			 * 只是保留代码
			 */
			// 分割符不存在时
			path = "\'" + replaceHomeDirChar(tmp) + "\'";
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "convertScpPassphrase");
		}

		return path;
	}
}
