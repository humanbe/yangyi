package com.nantian.rept.controller;

import java.net.URLDecoder;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.orm.hibernate3.HibernateOptimisticLockingFailureException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.ServletRequestDataBinder;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.jeda.util.RequestUtil;
import com.nantian.rept.service.CapThresholdAcqService;
import com.nantian.rept.vo.CapThresholdAcqVo;

/**
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 * 
 */
@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/capthresholdacq")
public class CapThresholdAcqController {
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(CapThresholdAcqController.class);
	
	/** 领域对象名称 */
	private static final String domain = "CapThresholdAcq";
	
	/** 视图前缀 */
	private static final String viewPrefix = "rept/" + domain + "/" + domain;
	
	@Autowired
	private CapThresholdAcqService capThresholdAcqService;
	
	@Autowired
	private SecurityUtils securityUtils;
	
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
	/**
	 * 注册Editor
	 * 
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
	 * 返回应用阀值采集页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index() throws JEDAException {
		return viewPrefix + "Index";
	}
	
	/**
	 * 查询应用阀值采集信息集合	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param aplCode
	 * @param thresholdType
	 * @param thresholdItem
	 * @param request
	 * @param modelMap
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
			@RequestParam(value = "aplCode", required = false) String aplCode,
			@RequestParam(value = "thresholdType", required = false) String thresholdType,
			@RequestParam(value = "thresholdItem", required = false) String thresholdItem,
			@RequestParam(value = "thresholdItemName", required = false) String thresholdItemName,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException{
		Map<String, Object> params = RequestUtil.getQueryMap(request, capThresholdAcqService.fields);
		try{
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, 
					capThresholdAcqService.queryCapThresholdAcqList(start, limit, sort, dir, params, request));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, 
					((List<Map<String, String>>)request.getSession().getAttribute("capThresholdAcqList4Export")).size());
			modelMap.addAttribute("success", Boolean.TRUE);
		}catch(Exception e){
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		
		return modelMap;
	}
	
	/**
	 * 返回查看页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/view", method  = RequestMethod.GET)
	public String view() throws JEDAException{
		return viewPrefix + "View";
	}
	
	/**
	 * 根据系统编号、容量类型、阀值批量类型、阀值科目名称和阀值子科目名称查询
	 * @param aplCode 系统编号
	 * @param thresholdItem 阀值科目名称	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/view", method = RequestMethod.POST)
	public @ResponseBody ModelMap view(
			@RequestParam(value = "aplCode", required = true) String aplCode,
			@RequestParam(value = "thresholdItem", required = true) String thresholdItem,
			ModelMap modelMap) throws JEDAException{
		try {
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, 
					capThresholdAcqService.queryCapThresholdAcqInfo(aplCode, thresholdItem));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * 返回新建页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/create", method  = RequestMethod.GET)
	public String create() throws JEDAException{
		return viewPrefix + "Create";
	}
	
	/**
	 * 保存新建数据
	 * 
	 * @param capThresholdAcqVo 数据对象
	 * @return
	 */
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap save(@ModelAttribute CapThresholdAcqVo capThresholdAcqVo) throws JEDAException {
		ModelMap modelMap = new ModelMap();
		try {
		    //新建用户与新建时间
			capThresholdAcqVo.setThresholdCreator(securityUtils.getUser().getUsername());
			capThresholdAcqVo.setThresholdCreated(new Timestamp(Long.valueOf(new Date().getTime())));
		
			//新建
			capThresholdAcqService.save(capThresholdAcqVo);
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("aplCode", capThresholdAcqVo.getAplCode());
			modelMap.addAttribute("capacityType", capThresholdAcqVo.getCapacityType());
			modelMap.addAttribute("thresholdType", capThresholdAcqVo.getThresholdType());
			modelMap.addAttribute("thresholdItem", capThresholdAcqVo.getThresholdItem());
		} catch (DataIntegrityViolationException e) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.DATA_INTEGRITY_VIOLATION + "[" + messages.getMessage("error.record.exist") + "]");
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * 返回编辑页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/edit", method = RequestMethod.GET)
	public String edit() throws JEDAException {
		return viewPrefix + "Edit";
	}
	
	/**
	 * 编辑更新数据
	 * @param aplCode 系统编号
	 * @param thresholdItem 阀值科目名称	 * @param request 请求对象
	 * @param modelMap 响应对象
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/edit/{aplCode}/{thresholdItem}", method = RequestMethod.POST)
	public @ResponseBody ModelMap edit(
			@PathVariable("aplCode") String aplCode,
			@PathVariable("thresholdItem") String thresholdItem,
			HttpServletRequest request,
			ModelMap modelMap) throws JEDAException {
		try {
			thresholdItem = URLDecoder.decode(thresholdItem, "utf-8");
			CapThresholdAcqVo capThresholdAcqVo = (CapThresholdAcqVo) capThresholdAcqService.queryCapThresholdAcqInfo(
					aplCode, thresholdItem);
			ServletRequestDataBinder binder = new ServletRequestDataBinder(capThresholdAcqVo);
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
			
			dateFormat.setLenient(false);
			binder.registerCustomEditor(Date.class, new CustomDateEditor(dateFormat, true));
		    binder.bind(request);
		    
		    //修改用户与修改时间
		    capThresholdAcqVo.setThresholdModifier(securityUtils.getUser().getUsername());
		    capThresholdAcqVo.setThresholdModified(new Timestamp(Long.valueOf(new Date().getTime())));
		    
		    //更新
		    capThresholdAcqService.update(capThresholdAcqVo);
		    modelMap.addAttribute("success", Boolean.TRUE);
		} catch (HibernateOptimisticLockingFailureException e) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.OPTIMISTIC_LOCKING);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * 批量删除阀值采集信息	 * @param aplCodes 系统编号数组
	 * @param thresholdItem 阀值科目名称数组	 * @param modelMap 响应对象
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/delete", method = RequestMethod.DELETE)
	public @ResponseBody ModelMap delete(
			@RequestParam(value = "aplCodes", required = true) String [] aplCodes,
			@RequestParam(value = "thresholdItems", required = true) String[] thresholdItems,
			ModelMap modelMap) throws JEDAException{
		try {
			capThresholdAcqService.deleteByUnionKeys(aplCodes, thresholdItems);
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (DataIntegrityViolationException e) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.DATA_INTEGRITY_VIOLATION);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * 导出
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/export", method = RequestMethod.GET)
	public String export(HttpServletRequest request, ModelMap modelMap) throws JEDAException{
		List<Map<String, String>> data = capThresholdAcqService.queryCapThresholdAcqList();
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, data);
		List<String> columns = new ArrayList<String>();
		columns.add("capacityType");
		columns.add("thresholdType");
		columns.add("thresholdItem");
		columns.add("thresholdItemName");
		columns.add("busiDemand");
		columns.add("threshold");
		columns.add("thresholdDate");
		columns.add("thresholdFrom");
		columns.add("thresholdCheckFlag");
		columns.add("thresholdExplain");
		columns.add("thresholdCreator");
		columns.add("thresholdCreated");
		columns.add("thresholdModifier");
		columns.add("thresholdModified");
		columns.add("additionalExplain");
		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY, columns);
		
		return "excelView4Threshold";
	}
}
