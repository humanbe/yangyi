package com.nantian.dply.controller;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.hibernate.exception.SQLGrammarException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.common.system.service.AppInfoService;
import com.nantian.component.log.Logger;
import com.nantian.dply.service.SysConfManageService;
import com.nantian.dply.vo.SysConfManageVo;
import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.jeda.util.RequestUtil;


/**
 * 服务器信息检索
 */


@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/sysconfmanage")
public class SysConfManageController {
	/** 日志输出 */
	private static Logger logger =  Logger.getLogger(SysConfManageController.class);
	/** 模板管理领域对象名称 */
	private static final String domain = "sys_conf_manage";
	/** 视图前缀 */
	private static final String viewPrefix = "dply/" + "sysconfmanage" + "/" + domain+"_";

	@Autowired
	private SysConfManageService sysConfManageService;
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	@Autowired
	AppInfoService appInfoService;
	@Autowired
	 private SecurityUtils securityUtils; 
	/**
	 * 返回管理页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index() throws JEDAException {
		return viewPrefix + "info";
	}

	/**
	 * 返回新建页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/create", method = RequestMethod.GET)
	public String create() {
		return viewPrefix + "create";
	}
	
	/**
	 * 返回编辑页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/view", method = RequestMethod.GET)
	public String view(){
		return viewPrefix + "view";
	}
	
	/**
	 * 返回新建页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/edit", method = RequestMethod.GET)
	public String edit() {
		return viewPrefix + "edit";
	}
	
	/**
	 *获取操作用户信息
	 * @param modelMap
	 * @return 
	 */
	@RequestMapping(value = "/view", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap view(@RequestParam("sys_conf_id") String sys_conf_id,
			ModelMap modelMap,
			HttpServletRequest request) throws JEDAException {
		try {
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("data",sysConfManageService.findById(sys_conf_id));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	

	
	/**
	 * 保存新建数据
	 * 
	 * @param vo 数据对象
	 * @return
	 */
	@RequestMapping(value = "/edit", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap edit(@ModelAttribute SysConfManageVo vo,
			ModelMap modelMap) throws JEDAException {
		modelMap.clear();
		Date startDate = new Date();
		Timestamp updateTime = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate));
		String modifier= securityUtils.getUser().getUsername();
		vo.setModifier(modifier);
		vo.setModifiled_time(updateTime);
		sysConfManageService.update(vo);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 保存新建数据
	 * 
	 * @param vo 数据对象
	 * @return
	 * @throws Exception 
	 */
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap create(@ModelAttribute SysConfManageVo vo,
			ModelMap modelMap) throws Exception {
		modelMap.clear();
		String sys_conf_id =sysConfManageService.findSys_conf_id();
		Date startDate = new Date();
		Timestamp updateTime = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate));
		String creator= securityUtils.getUser().getUsername();
		vo.setCreator(creator);
		vo.setCreated_time(updateTime);
		vo.setSys_conf_id(sys_conf_id);
		sysConfManageService.save(vo);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 批量删除用户标示
	 * 
	 * @param 
	 * @param 
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 * @throws SQLException 
	 */
	@RequestMapping(value = "/delete", method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap delete(
			@RequestParam(value = "sys_conf_ids", required = true) String[] sys_conf_ids,
			ModelMap modelMap) throws JEDAException, SQLException {
		
		sysConfManageService.deleteByIds(sys_conf_ids);
			modelMap.addAttribute("success", Boolean.TRUE);
		
		    return modelMap;
	}
	
	
	
	/**
	 * 查询服务器信息
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param request
	 * @param modelMap
	 * @param serverIp 服务器IP
	 * @param appsysCode 系统代码
	 * @param bsaAgentFlag BSA上线标示
	 * @return
	 */
	@RequestMapping(value = "/index", method = RequestMethod.POST)
	public @ResponseBody ModelMap queryAlllist(
			@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
			HttpServletRequest request, ModelMap modelMap) throws DataAccessException, SQLException,SQLGrammarException{
		Map<String, Object> params = RequestUtil.getQueryMap(request, sysConfManageService.fields);
		
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, 
					sysConfManageService.queryAll(start, limit, sort, dir, params));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, 
					sysConfManageService.count(params));
			modelMap.addAttribute("success", Boolean.TRUE);
		
		return modelMap;
	}


}
