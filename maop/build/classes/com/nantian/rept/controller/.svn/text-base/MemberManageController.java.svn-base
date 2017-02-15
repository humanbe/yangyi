package com.nantian.rept.controller;

import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.orm.hibernate3.HibernateOptimisticLockingFailureException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.ServletRequestDataBinder;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.util.RequestUtil;
import com.nantian.rept.service.MemberManageService;
import com.nantian.rept.vo.MemberVo;

/**
 * @author <a href="mailto:fujunze@nantian.com.cn">LJay</a>
 * 
 */
@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/membermanage")
public class MemberManageController {
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(MemberManageController.class);
	
	/** 领域对象名称 */
	private static final String domain = "MemberManage";
	
	/** 视图前缀 */
	private static final String viewPrefix = "rept/" + domain + "/" + domain;
	
	@Autowired
	private MemberManageService memberManageService;
	
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
	/**
	 * 注册Editor
	 * @param binder
	 */
	@InitBinder
	public void initBinder(WebDataBinder binder) {
		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
		dateFormat.setLenient(false);
		binder.registerCustomEditor(Date.class, new CustomDateEditor(
				dateFormat, true));
	}
	
	/**
	 * 返回人员管理信息页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index() throws JEDAException {
		return viewPrefix + "Index";
	}

	/**
	 * 查询人员信息列表
	 * @param start 起始记录数
	 * @param limit 限制记录数
	 * @param sort 排序字段
	 * @param dir 升降序字符串
	 * @param userName 用户名
	 * @param serilNo 员工号
	 * @param flag 外包标识
	 * @param sex 性别
	 * @param groupName 团队组别
	 * @param request 请求对象
	 * @param modelMap 响应对象
	 * @return
	 * @throws JEDAException
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/index", method = RequestMethod.POST)
	public @ResponseBody ModelMap list(
			@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
			@RequestParam(value = "userName", required = false) String userName,
			@RequestParam(value = "serilNo", required = false) String serilNo,
			@RequestParam(value = "outSourcingFlag", required = false) String flag,
			@RequestParam(value = "sex", required = false) String sex,
			@RequestParam(value = "groupName", required = false) String groupName,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException{
		Map<String, Object> params = RequestUtil.getQueryMap(request, memberManageService.fields);
		try{
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, memberManageService.queryMemberList(start, limit, sort, dir, params, request));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, ((List<Map<String, String>>)request.getSession().getAttribute("memberList4Export")).size());
		}catch(Exception e){
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		
		return modelMap;
	}
	
	/**
	 * 返回人员编辑信息页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/edit", method = RequestMethod.GET)
	public String edit() throws JEDAException {
		return viewPrefix + "Edit";
	}

	/**
	 * 编辑人员信息
	 * @param userId
	 * @param modelMap
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/edit/{userId}", method = RequestMethod.POST)
	public @ResponseBody ModelMap edit(
			@PathVariable("userId") String userId, 
			ModelMap modelMap,
			HttpServletRequest request) throws JEDAException {
		try{
			MemberVo vo = (MemberVo) memberManageService.get(userId);
			ServletRequestDataBinder binder = new ServletRequestDataBinder(vo);
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
			dateFormat.setLenient(false);
			binder.registerCustomEditor(Date.class, new CustomDateEditor(dateFormat, true));
		    binder.bind(request);
		    memberManageService.update(vo);
		    modelMap.addAttribute("success", Boolean.TRUE);
		} catch (HibernateOptimisticLockingFailureException e) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.OPTIMISTIC_LOCKING);
		}catch(Exception e){
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * 返回查看页面
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/view", method = RequestMethod.GET)
	public String view() throws JEDAException {
		return viewPrefix + "View";
	}
	
	/**
	 * 根据ID查询.
	 * @param userId 主键
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/view", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap view(
			@RequestParam(value = "userId", required = true) String userId, 
			ModelMap modelMap) throws JEDAException {
		try {
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, memberManageService.queryMember(userId));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * 查询用户名及员工号
	 * @param response
	 */
	@RequestMapping(value = "/queryUsernameSerilNos", method = RequestMethod.GET)
	public @ResponseBody void queryUsernameSerilNos(HttpServletResponse response){
		PrintWriter out = null;
		try{
			Object map = memberManageService.queryUsernameSerilNos();
			response.setCharacterEncoding("utf-8");
			out = response.getWriter();
			out.print(JSONArray.fromObject(map));
		}catch(Exception e){
			e.printStackTrace();
		}finally{
			if(out != null){
				out.close();
			}
		}
	}
	
	/**
	 * 查询人员信息的所有组别
	 * @param response
	 */
	@RequestMapping(value = "/queryGroupNames", method = RequestMethod.GET)
	public @ResponseBody void queryGroupNames(HttpServletResponse response){
		PrintWriter out = null;
		try {
			Object groupNames = memberManageService.queryGroupNames();
			response.setCharacterEncoding("utf-8");
			out = response.getWriter();
			out.print(JSONArray.fromObject(groupNames));
		} catch (Exception e) {
			e.printStackTrace();
		}finally{
			if(out != null){
				out.close();
			}
		}
	}
	
	/**
	 * 导出查询结果到文件
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/excel", method = RequestMethod.GET)
	public String excel(HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		Map<String, String> columns = new LinkedHashMap<String, String>();
		columns.put("userId", messages.getMessage("property.userId"));
		columns.put("userName", messages.getMessage("property.userName"));
		columns.put("sex", messages.getMessage("property.sex"));
		columns.put("mobile", messages.getMessage("property.mobile"));
		columns.put("phone", messages.getMessage("property.phone"));
		columns.put("otherContact", messages.getMessage("property.otherContact"));
		columns.put("email", messages.getMessage("property.email"));
		columns.put("serilNo", messages.getMessage("property.serilNo"));
		columns.put("groupName", messages.getMessage("property.groupName"));
		columns.put("teamName", messages.getMessage("property.teamName"));
		columns.put("outSourcingFlag", messages.getMessage("property.isOutSourcing"));
		
		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY, columns);
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, request.getSession().getAttribute("memberList4Export"));
		
		return "excelView";
	}
}
