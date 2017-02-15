package com.nantian.rept.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.propertyeditors.CustomDateEditor;
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

import com.nantian.common.util.ComUtil;
import com.nantian.common.util.CommonConst;
import com.nantian.component.log.Logger;
import com.nantian.common.util.DateFunction;
import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.jeda.util.RequestUtil;
import com.nantian.rept.ReptConstants;
import com.nantian.rept.service.AplAnalyzeService;
import com.nantian.rept.vo.AplAnalyzeVo;
/**
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 * 
 */
@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/aplanalyze")
public class AplAnalyzeController {

	/** 日志输出 */
	final Logger logger = Logger.getLogger(AplAnalyzeController.class);
	
	/** 领域对象名称 */
	private static final String domain = "AplAnalyze";

	/** 视图前缀 */
	private static final String viewPrefix = "rept/" + domain + "/" + domain;

	/** 服务 */
	@Autowired
	private AplAnalyzeService aplAnalyzeService;
	
	@Autowired
	private SecurityUtils securityUtils;
	
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
	 * 返回列表页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index() throws JEDAException {
		return viewPrefix + "Index";
	}

	/**
	 * 根据分页、排序和其他条件查询记录.
	 * 
	 * @param start
	 * @param limit
	 * @param parent
	 * @param sort
	 * @param dir
	 * @param request
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/index", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap list(
			@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "parent", required = false) String parent,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
			@RequestParam(value = "aplCode", required = false) String aplCode,
			@RequestParam(value = "transDate", required = false) String transDate,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {

		Map<String,Object> dataMap = new HashMap<String,Object>(); 
		List<Map<String, Object>> dataList = new ArrayList<Map<String, Object>>();
		Map<String, Object> params = RequestUtil.getQueryMap(request, aplAnalyzeService.fields);
		
		try {
			List<AplAnalyzeVo> aplAnalyzeList = (List<AplAnalyzeVo>)aplAnalyzeService.queryAll(start, limit, sort, dir, params);
			for (AplAnalyzeVo aplAnalyzeVo : aplAnalyzeList) {
				dataMap = new HashMap<String,Object>(); 
				dataMap.put("aplCode", aplAnalyzeVo.getAplCode());
				dataMap.put("transDate", aplAnalyzeVo.getTransDate());
				dataMap.put("anaItem", aplAnalyzeVo.getAnaItem());
				dataMap.put("exeAnaDesc", aplAnalyzeVo.getExeAnaDesc());
				dataMap.put("status", aplAnalyzeVo.getStatus());
				dataMap.put("anaUser", aplAnalyzeVo.getAnaUser());
				dataMap.put("revUser", aplAnalyzeVo.getRevUser());
				dataMap.put("endDate", aplAnalyzeVo.getEndDate());
				dataMap.put("filePath", aplAnalyzeVo.getFilePath());
				dataList.add(dataMap);
			}
			
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, dataList);
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, aplAnalyzeList.size());
			modelMap.addAttribute("success", Boolean.TRUE);
			// logger.info(messages.getMessage("log.info.list", new String[] {
			// securityUtils.getUserFullName(), messages.getMessage(domain) }));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			// logger.error(messages.getMessage("log.error.list", new String[] {
			// securityUtils.getUserFullName(), messages.getMessage(domain) }));
		}
		return modelMap;
	}

	/**
	 * 返回新建页面
	 * 
	 * @return 新建页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/create", method = RequestMethod.GET)
	public String create() throws JEDAException {
		return viewPrefix + "Create";
	}

	/**
	 * 保存新建数据
	 * 
	 * @param customer
	 *            数据对象
	 * @return
	 */
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap save(@ModelAttribute AplAnalyzeVo aplAnalyzeVo, HttpServletRequest request) throws JEDAException {
		ModelMap modelMap = new ModelMap();
		try {
			// securityUtils.setCreateEntity(aplAnalyzeVo);// 设置新建数据的操作用户及时间信息
			aplAnalyzeService.save(aplAnalyzeVo);
			
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("aplCode", aplAnalyzeVo.getAplCode());
			modelMap.addAttribute("transDate", aplAnalyzeVo.getTransDate());
			modelMap.addAttribute("anaItem", aplAnalyzeVo.getAnaItem());
			// logger.info(messages.getMessage("log.info.create", new String[] {
			// securityUtils.getUserFullName(), messages.getMessage(domain),
			// traninfo.getTranid() }));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			// logger.error(messages.getMessage("log.error.create", new String[]
			// { securityUtils.getUserFullName(), messages.getMessage(domain)
			// }));
		}
		return modelMap;
	}

	/**
	 * 返回编辑页面
	 * 
	 * @return 编辑页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/edit", method = RequestMethod.GET)
	public String edit() throws JEDAException {
		return viewPrefix + "Edit";
	}

	/**
	 * 更新编辑数据
	 * 
	 * @param id
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/edit/{aplCode}/{transDate}/{anaItem}/{transTime}", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap edit(@PathVariable("aplCode") String aplCode,
			@PathVariable("transDate") String transDate,
			@PathVariable("transTime") String transTime,
			@PathVariable("anaItem") String anaItem,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		//解码
		String decodeAnaItem = null;
		try {
			decodeAnaItem = URLDecoder.decode(anaItem,"utf-8");
		} catch (UnsupportedEncodingException e1) {
			e1.printStackTrace();
			// 输出异常结束日志
			if (logger.isEnableFor("Component0099")) {
				logger.log("Component0099", ComUtil.getCurrentMethodName());
			}
		}
		//后去后台数据并绑定前台数据

		AplAnalyzeVo aplAnalyzeVo = (AplAnalyzeVo) aplAnalyzeService.findByPrimaryKey(aplCode,transDate,decodeAnaItem,transTime);
		ServletRequestDataBinder binder = new ServletRequestDataBinder(
				aplAnalyzeVo);
		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
		dateFormat.setLenient(false);
		binder.registerCustomEditor(Date.class, new CustomDateEditor(
				dateFormat, true));
		binder.bind(request);
		
		try {
			// securityUtils.setModifyEntity(traninfo);// 设置修改数据的操作用户及时间信息
			aplAnalyzeService.update(aplAnalyzeVo);
			modelMap.addAttribute("success", Boolean.TRUE);
			// logger.info(messages.getMessage("log.info.edit", new String[] {
			// securityUtils.getUserFullName(), messages.getMessage(domain),
			// tranid }));
		} catch (HibernateOptimisticLockingFailureException e) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.OPTIMISTIC_LOCKING);
			// logger.error(messages.getMessage("log.error.edit", new String[] {
			// securityUtils.getUserFullName(), messages.getMessage(domain),
			// tranid }));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			// logger.error(messages.getMessage("log.error.edit", new String[] {
			// securityUtils.getUserFullName(), messages.getMessage(domain),
			// tranid }));
		}
		return modelMap;
	}

	/**
	 * 返回查看页面
	 * 
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/view", method = RequestMethod.GET)
	public String view() throws JEDAException {
		return viewPrefix + "View";
	}

	/**
	 * 根据主键查询应用系统分析科目数据.
	 * 
	 * @param aplCode
	 * @param transDate
	 * @param anaItem
	 *            主键
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/view", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap view(@RequestParam(value = "aplCode", required = true) String aplCode,
			@RequestParam(value = "transDate", required = true) String transDate,
			@RequestParam(value = "transTime", required = true) String transTime,
			@RequestParam(value = "anaItem", required = true) String anaItem,
			ModelMap modelMap)
			throws JEDAException {
		try {
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("data", aplAnalyzeService.findByPrimaryKey(aplCode, transDate, anaItem,transTime));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}

	/**
	 * 批量删除.
	 * 
	 * @param ids
	 *            主键数组
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/delete", method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap delete(
			@RequestParam(value = "aplCodes", required = true) String[] aplCodes,
			@RequestParam(value = "transDates", required = true) String[] transDates,
			@RequestParam(value = "anaItems", required = true) String[] anaItems,
			ModelMap modelMap) throws JEDAException {
		try {
			aplAnalyzeService.deleteByIds(aplCodes,transDates,anaItems);
			modelMap.addAttribute("success", Boolean.TRUE);
			// logger.info(messages.getMessage("log.info.delete", new String[] {
			// securityUtils.getUserFullName(), messages.getMessage(domain),
			// StringUtils.arrayToDelimitedString((Object[]) tranids, "|") }));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", e.getMessage());
			//modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			// logger.error(messages.getMessage("log.error.delete", new String[]
			// { securityUtils.getUserFullName(), messages.getMessage(domain),
			// StringUtils.arrayToDelimitedString((Object[]) tranids, "|") }));
		}
		return modelMap;
	}
	
	/**
	 * 返回日报管理页面
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/forrpt", method = RequestMethod.GET)
	public String froPrt() throws JEDAException {
		return viewPrefix + "ForRpt";
	}
	
	/**
	 * 查询应用系统运行分析科目列表
	 * @param response 响应对象
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/browseAplAnalyzeItemList", method = RequestMethod.GET)
	public @ResponseBody void browseWeekRptAplCode(
			@RequestParam(value = "aplCode", required = true) String aplCode,
			@RequestParam(value = "transDate", required = true) String transDate,
			HttpServletResponse response) throws JEDAException{
		PrintWriter out = null;
		Object sheetNmMap = aplAnalyzeService.querySheetNmMapForAplAnalyze(aplCode,transDate);
		
		response.setCharacterEncoding("utf-8");
		try {
			out = response.getWriter();
			out.print(JSONArray.fromObject(sheetNmMap));
		} catch (IOException e) {
			e.printStackTrace();
		}finally{
			if(out != null)	out.close();
		}
		
	}
	
	/**
	 * 取得分析科目的数量

	 * @param aplCode 
	 * @param endDate
	 * @param request
	 * @param response
	 * @throws JEDAException
	 * @throws IOException
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/getAnaItemsNum", method = RequestMethod.POST)
	public @ResponseBody ModelMap getAnaItemsNum(@RequestParam(value = "aplCode", required = true) String aplCode,
																				@RequestParam(value = "reportType", required = true) String reportType,
																				@RequestParam(value = "endDate", required = true) String endDate,
																				HttpServletRequest request, ModelMap modelMap) throws JEDAException{
		try{
			List<Map<String, Object>> anaItems = (List<Map<String, Object>>) aplAnalyzeService.querySheetNmMapSumItems(aplCode, reportType, endDate, ReptConstants.SPECIAL_SHEETNAME_RUN_SUMMARY);
			
			modelMap.addAttribute("anaItemNum", anaItems.size());
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Throwable e) {
			e.printStackTrace();
			// 输出异常结束日志
			if (logger.isEnableFor("Component0099")) {
				logger.log("Component0099", ComUtil.getCurrentMethodName());
			}
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			modelMap.addAttribute("success", Boolean.FALSE);
		}
		
		// 输出结束日志
		if (logger.isEnableFor("Component0002")) {
			logger.log("Component0002", ComUtil.getCurrentMethodName());
		}
		return modelMap;
	}
	
	/**
	 * 根据主键查询应用系统分析科目数据.
	 * 
	 * @param aplCode
	 * @param transDate
	 * @param anaItem
	 *            主键
	 * @param modelMap
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/viewForAplAna", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap viewForRpt(@RequestParam(value = "aplCode", required = true) String aplCode,
									@RequestParam(value = "reportType", required = true) String reportType,
									@RequestParam(value = "endDate", required = true) String endDate,
									ModelMap modelMap)	throws JEDAException {
		try {
			Map<String,String> dataMap  = new HashMap<String,String>();
			//查询数据
			List<Map<String, Object>> anaItems = (List<Map<String, Object>>) aplAnalyzeService.querySheetNmMapSumItems(aplCode, reportType, endDate, ReptConstants.SPECIAL_SHEETNAME_RUN_SUMMARY);
			for (int i = 0; i < anaItems.size(); i++) {
				if(null != anaItems.get(i).get("anaItem")){
					dataMap.put("aplCode", null != anaItems.get(i).get("aplCode")?anaItems.get(i).get("aplCode").toString():CommonConst.EMPTY);
					dataMap.put("transDate", null != anaItems.get(i).get("transDate")?anaItems.get(i).get("transDate").toString():CommonConst.EMPTY);
					dataMap.put("anaUser", null != anaItems.get(i).get("anaUser")?anaItems.get(i).get("anaUser").toString():CommonConst.EMPTY);
					dataMap.put("revUser", null != anaItems.get(i).get("revUser")?anaItems.get(i).get("revUser").toString():CommonConst.EMPTY);
					dataMap.put("endDate", null != anaItems.get(i).get("endDate")?anaItems.get(i).get("endDate").toString():CommonConst.EMPTY);
				}
				dataMap.put("anaItem".concat(String.valueOf(i)), null != anaItems.get(i).get("sheetName")?anaItems.get(i).get("sheetName").toString():CommonConst.EMPTY);
				dataMap.put("status".concat(String.valueOf(i)), null != anaItems.get(i).get("status")?anaItems.get(i).get("status").toString():CommonConst.STRING_ZERO );
				dataMap.put("exeAnaDesc".concat(String.valueOf(i)), null != anaItems.get(i).get("exeAnaDesc")?anaItems.get(i).get("exeAnaDesc").toString():CommonConst.EMPTY);
			}
			if(anaItems.size() !=0 && (null == dataMap.get("aplCode"))){
				dataMap.put("aplCode", anaItems.get(0).get("aplCode").toString());
				dataMap.put("transDate", anaItems.get(0).get("rptDate").toString());
				dataMap.put("anaUser", securityUtils.getUser().getName());
				dataMap.put("endDate", DateFunction.getSystemDate());
			}
			
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,dataMap);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * 根据查询最近的应用系统分析科目数据.
	 * 
	 * @param aplCode
	 * @param endDate
	 * @param modelMap
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/loadLatest", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap loadLatest(@RequestParam(value = "aplCode", required = true) String aplCode,
									@RequestParam(value = "reportType", required = true) String reportType,
									@RequestParam(value = "endDate", required = true) String endDate,
									ModelMap modelMap)	throws JEDAException {
		try {
			Map<String,String> dataMap  = new HashMap<String,String>();
			//查询数据
			List<Map<String, Object>> anaItems = (List<Map<String, Object>>) aplAnalyzeService.querySheetNmMapSumItems(aplCode, reportType, endDate, ReptConstants.SPECIAL_SHEETNAME_RUN_SUMMARY);
			//查询数据
			List<Map<String, Object>> list = (List<Map<String, Object>>) aplAnalyzeService.queryLatestInfo(aplCode);
			for (int i = 0; i < list.size(); i++) {
				for (int j = 0; j < anaItems.size(); j++) {
					if(list.get(i).get("anaItem").toString().equals(null != anaItems.get(j).get("anaItem")?anaItems.get(j).get("anaItem").toString():anaItems.get(j).get("sheetName").toString())){
						dataMap.put("anaItem".concat(String.valueOf(j)), list.get(i).get("anaItem").toString());
						dataMap.put("exeAnaDesc".concat(String.valueOf(j)), null != list.get(i).get("exeAnaDesc")?list.get(i).get("exeAnaDesc").toString():CommonConst.EMPTY);
						dataMap.put("status".concat(String.valueOf(j)), list.get(i).get("status").toString());
					}
				}
//				dataMap.put("aplCode", list.get(i).get("aplCode").toString());
//				dataMap.put("transDate", list.get(i).get("transDate").toString());
//				dataMap.put("anaUser", null != list.get(i).get("anaUser")?list.get(i).get("anaUser").toString():CommonConst.EMPTY);
//				dataMap.put("revUser", null != list.get(i).get("revUser")?list.get(i).get("revUser").toString():CommonConst.EMPTY);
//				dataMap.put("endDate", null != list.get(i).get("endDate")?list.get(i).get("endDate").toString():CommonConst.EMPTY);
				dataMap.put("filePath", null != list.get(i).get("filePath")?list.get(i).get("filePath").toString():CommonConst.EMPTY);
			}
			
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, dataMap);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * 更新编辑数据
	 * @param aplCode
	 * @param endDate
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/editForAplAna", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap editForRpt(@RequestParam(value = "aplCodeParam", required = false) String aplCodeParam,
			@RequestParam(value = "transDateParam", required = false) String transDateParam,
			@RequestParam(value = "anaUserParam", required = false) String anaUserParam,
			@RequestParam(value = "revUserParam", required = false) String revUserParam,
			@RequestParam(value = "endDateParam", required = false) String endDateParam,
			@RequestParam(value = "anaInfoParam", required = false) String[] anaInfoParam,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		try {
			String[] anaInfoArr = new String[3];
			AplAnalyzeVo aplAnalyzeVo = null;
			
			//编辑数据
			for (String anaInfo : anaInfoParam) {
				aplAnalyzeVo = new AplAnalyzeVo();
				
				aplAnalyzeVo.setAplCode(aplCodeParam);
				aplAnalyzeVo.setTransDate(transDateParam);
				aplAnalyzeVo.setAnaUser(anaUserParam);
				aplAnalyzeVo.setRevUser(revUserParam);
				aplAnalyzeVo.setEndDate(endDateParam);
				
				anaInfoArr = anaInfo.split(Constants.SPLIT_SEPARATEOR);
				aplAnalyzeVo.setAnaItem(anaInfoArr[0]);
				aplAnalyzeVo.setStatus(anaInfoArr[1]);
				aplAnalyzeVo.setExeAnaDesc(anaInfoArr.length == 3?anaInfoArr[2]:null);
				//更新数据
				aplAnalyzeService.saveOrUpdate(aplAnalyzeVo);
			}
			
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
	
	
}///:~
