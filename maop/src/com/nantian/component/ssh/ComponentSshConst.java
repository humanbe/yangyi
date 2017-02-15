package com.nantian.component.ssh;

/**
 * SSH常量类
 * @author dong
 */
public class ComponentSshConst {

	/** 异常编码：连接失败 */
	public static final int ERROR_CONNECT = 10000001;

	/** 异常编码：未知主机*/
	public static final int ERROR_UNKNOWN_HOST = 10000002;

	/** 异常编码： 认证失败*/
	public static final int ERROR_AUTHENTICATION = 10000003;

	/** 异常编码： 参数错误*/
	public static final int ERROR_INVALID_PARAMETER = 10000004;

	/** 异常编码： 执行命令失败*/
	public static final int ERROR_BAD_COMMAND = 10000005;

	/**异常编码： SCP处理发生异常*/
	public static final int ERROR_SCP = 10000006;

	/** 异常编码： 未进行连接*/
	public static final int ERROR_NOT_CONNECT = 10000008;

	/** 异常编码： 文件不存在*/
	public static final int ERROR_FILE_NOT_FOUND = 10000011;

	/** 异常编码：未知异常 */
	public static final int ERROR_UNKNOWN = 10009999;
}
