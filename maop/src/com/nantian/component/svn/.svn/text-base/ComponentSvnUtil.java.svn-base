package com.nantian.component.svn;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;

import com.nantian.component.log.Logger;

/**
 * SVNUtil类
 * @author dong
 */
public class ComponentSvnUtil {

	/**
	 * Logger
	 */
	private static Logger logger = Logger.getLogger(ComponentSvnUtil.class);

	/**
	 * 文件复制
	 * @param srcPath 要复制的源文件路径
	 * @param destPath 目的地路径
	 * @throws IOException IO异常
	 */
	protected static void fileCopy(final String srcPath, final String destPath)
			throws IOException {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "fileCopy");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "srcPath;destPath", srcPath + ";" + destPath);
		}

		if (srcPath == null || srcPath.trim().equals("")) {
			throw new IOException("未指定要复制的源文件");
		}

		if (destPath == null || destPath.trim().equals("")) {
			throw new IOException("");
		}

		FileChannel srcChannel = new FileInputStream(srcPath).getChannel();
		FileChannel destChannel = new FileOutputStream(destPath).getChannel();
		try {
			srcChannel.transferTo(0, srcChannel.size(), destChannel);
		} finally {
			if(srcChannel !=null ){
				srcChannel.close();
			}
			if(destChannel !=null ){
				destChannel.close();
			}
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "fileCopy");
		}
	}

	/**
	 * 删除目录
	 * @param directory 删除对象的目录
	 * @throws IOException IO异常
	 */
	protected static void deleteDirectory(final File directory) throws IOException {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "deleteDirectory");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "directory", directory);
		}

		if (directory == null) {
			throw new IOException("未指定删除对象的目录");
		}

		if (!directory.exists()) {
			throw new IOException("目录[" + directory + "]不存在");
		}

		cleanDirectory(directory);
		if (!(directory.delete())) {
			throw new IOException("目录[" + directory + "]无法删除");
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "deleteDirectory");
		}
	}

	/**
	 * 递归删除指定目录下的文件
	 * @param directory 要删除的目录
	 * @throws IOException IO异常
	 */
	private static void cleanDirectory(final File directory) throws IOException {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "cleanDirectory");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "directory", directory);
		}

		if (!(directory.exists())) {
			throw new IOException("目录[" + directory + "]不存在");
		}

		if (!(directory.isDirectory())) {
			throw new IOException("[" + directory + "]不是目录");
		}

		File[] files = directory.listFiles();
		if (files == null) {
			throw new IOException("要删除目录下的详细文件列表无法获得");
		}

		for (int i = 0; i < files.length; i++) {
			forceDelete(files[i]);
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "cleanDirectory");
		}
	}

	/**
	 * 删除指定目录下的文件
	 * @param file 要删除的文件（全路径+文件名）
	 * @throws IOException IO异常
	 */
	private static void forceDelete(final File file) throws IOException {

		// 输出开始日志
		if (logger.isEnableFor("Component0001")) {
			logger.log("Component0001", "forceDelete");
		}

		if (logger.isEnableFor("Component0003")) {
			logger.log("Component0003", "file", file);
		}

		if (file.isDirectory()) {
			deleteDirectory(file);
		} else {
			if (!file.delete()) {
				if (!file.exists()) {
					throw new FileNotFoundException("文件[" + file + "]不存在");
				}

				throw new IOException("文件[" + file + "]无法删除");
			}
		}

		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", "forceDelete");
		}
	}
}
