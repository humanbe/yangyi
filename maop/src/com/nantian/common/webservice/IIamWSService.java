package com.nantian.common.webservice;

/**
 * MAOP IAM web serive接口类X-fire
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 *
 */
public interface IIamWSService {
	
	/**
	 * 6.2.1.1.1.2.1	单个从帐号查询接口
	 * 根据从帐号ID获取从帐号信息
	 * @param userID 从帐号ID
	 * @return 从帐号信息
	 */
	public String findUser(String userID);
		
	/**
	 * 6.2.1.1.1.2.2	从帐号总数查询接口
	 * 获取应用系统从帐号总数
	 * @param 无
	 * @return 从帐号总数
	 */
	public String getUserAmount();
	
	/**
	 * 6.2.1.1.1.2.3	全部从帐号信息查询接口
	 * 获取应用系统的所有从帐号的信息列表
	 * @param 无
	 * @return 从帐号信息列表
	 */
	public String queryUsers();
	
	/**
	 * 6.2.1.1.1.2.4	分页查询从帐号接口
	 * 获取应用系统的所有从帐号的信息列表（分页查询）
	 * @param  pageSize 分页大小
	 * @param  pageNum 页数
	 * @return 从帐号信息列表
	 */
	public String queryUsersByPage(String pageSize,String pageNum);
	
	/**
	 * 6.2.1.1.1.2.5	全部组织机构查询接口
	 * 获取全部的组织机构
	 * @param  无
	 * @return 组织机构信息列表
	 */
	public String queryOrgs();
	
	/**
	 * 全部岗位查询接口
	 * 获取全部的岗位
	 * @param  无
	 * @return 岗位信息列表
	 */
	public String queryPositions();
	
	/**
	 * 6.2.1.1.2.2.1	从帐号添加接口
	 * 在应用系统中添加帐号
	 * @param  userInfos从帐号信息列表
	 * @return 操作结果信息
	 */
	public String addUserInfo(String userInfos);
	
	/**
	 * 6.2.1.1.3.2.1	从帐号修改接口
	 * 修改应用系统中的帐号信息
	 * @param  userInfos从帐号信息列表
	 * @return 操作结果信息
	 */
	public String modifyUserInfo(String userInfos);
	
	/**
	 * 6.2.1.1.4.2.1	从帐号删除接口
	 * 在应用系统中添加帐号
	 * @param 删除应用系统中的从帐号
	 * @return 操作结果信息
	 */
	public String delUser(String userIDs);
	
	/**
	 * 应急切换状态查询
	 * @return 正常状态返回字符串0 ，应急状态返回字符串1
	 */
	public String stateQuery();
	
	/**
	 * 应急切换
	 * @param 值为1 切换到应急状态，值为 0切换到正常状态
	 * @return 返回应用切换后的状态，正常状态返回字符串 0 ，应急状态返回 字符串1
	 */
	public String setState(String emergencyValue);

	
}///:~
