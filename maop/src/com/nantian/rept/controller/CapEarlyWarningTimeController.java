package com.nantian.rept.controller;

import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;

import org.hibernate.HibernateException;
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

import com.nantian.common.util.ComUtil;
import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.util.RequestUtil;
import com.nantian.rept.service.CapEarlyWarningTimeService;
import com.nantian.rept.vo.CapEarlyWarningTimeVo;

/**
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 * 
 */
@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/capearlywarningtime")
public class CapEarlyWarningTimeController {
	
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(CapEarlyWarningTimeController.class);

	/** 领域对象名称 */
	private static final String domain = "CapEarlyWarningTime";

	/** 视图前缀 */
	private static final String viewPrefix = "rept/" + domain + "/" + domain;
	
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
	@Autowired
	private CapEarlyWarningTimeService capEarlyWarningTimeService;
	
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
	 * 返回编码信息列表页面
	 * 
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index() throws JEDAException {
		return viewPrefix + "Index";
	}
	
	/**
	 * 根据分页、排序和其他条件查询编码信息记录
	 * @param start         起始索引
	 * @param limit          每页至多显示的记录数
	 * @param sort           排序的字段	 * @param dir	  		   排序的方式	 * @param aplCode   	  应用系统编号
	 * @param busiKeyDate  业务关键日期
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/index", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap list(
			@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit", required = false) Integer limit,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir,
			@RequestParam(value = "aplCode", required = false) String aplCode,
			@RequestParam(value = "busiKeyDate", required = false) String busiKeyDate,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		Map<String, Object> params = RequestUtil.getQueryMap(request, capEarlyWarningTimeService.fields);
		
		try{
			
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, capEarlyWarningTimeService.queryAll(start, limit, sort, dir, params));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, capEarlyWarningTimeService.count(params));
			modelMap.addAttribute("success", Boolean.TRUE);
			
		}catch(Exception e){
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			
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
	 * @param capEarlyWarningTimeVo 数据对象
	 * @return
	 */
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap save(@ModelAttribute CapEarlyWarningTimeVo capEarlyWarningTimeVo) throws JEDAException {
		ModelMap modelMap = new ModelMap();
		try {
			
			capEarlyWarningTimeService.save(capEarlyWarningTimeVo);
			
			modelMap.addAttribute("aplCode", capEarlyWarningTimeVo.getAplCode());
			modelMap.addAttribute("busiKeyDate", capEarlyWarningTimeVo.getBusiKeyDate());
			modelMap.addAttribute("success", Boolean.TRUE);
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
	 * 返回删除页面
	 * 
	 * @return 删除页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/delete", method = RequestMethod.GET)
	public String delete() throws JEDAException {
		return viewPrefix + "Delete";
	}
	
	/**
	 * 批量删除.
	 * 
	 * @param aplCodes 应用系统编号主键数组
	 * @param busiKeyDates 业务关键日期主键数组
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/delete", method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap delete(
			@RequestParam(value = "aplCodes", required = true) String[] aplCodes, 
			@RequestParam(value = "busiKeyDates", required = true) String[] busiKeyDates, 
			ModelMap modelMap)
			throws JEDAException {
		try {
			capEarlyWarningTimeService.deleteByUnionKeys(aplCodes, busiKeyDates);
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
	 * 编辑更新数据
	 * @param aplCode 应用系统编号
	 * @param busiKeyDate 业务关键日期
	 * @param modelMap
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/edit/{aplCode}/{busiKeyDate}", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap edit(@PathVariable("aplCode") String aplCode, 
							@PathVariable("busiKeyDate") String busiKeyDate, 
							ModelMap modelMap,HttpServletRequest request) throws JEDAException {
		try {
			CapEarlyWarningTimeVo vo = (CapEarlyWarningTimeVo) capEarlyWarningTimeService.findByPrimaryKey(aplCode, busiKeyDate);
			ServletRequestDataBinder binder = new ServletRequestDataBinder(vo);
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
			
			dateFormat.setLenient(false);
			binder.registerCustomEditor(Date.class, new CustomDateEditor(dateFormat, true));
		    binder.bind(request);
		    //更新
		    capEarlyWarningTimeService.update(vo);
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
	 * 返回查看页面
	 * 
	 * @return 查看页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/view", method = RequestMethod.GET)
	public String view() throws JEDAException {
		return viewPrefix + "View";
	}
	
	/**
	 * 返回查看数据
	 * 
	 * @return 查看页面视图数据
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/view/{aplCode}/{busiKeyDate}", method = RequestMethod.GET)
	public @ResponseBody
		ModelMap view(@PathVariable("aplCode") String aplCode, 
								@PathVariable("busiKeyDate") String busiKeyDate, 
								ModelMap modelMap) throws JEDAException {
		try {
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("data", capEarlyWarningTimeService.findByPrimaryKey(aplCode, busiKeyDate));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * 从文件导入编码信息	 * @param filePath 文件路径
	 * @param modelMap
	 * @param request
	 * @return
	 */
	@RequestMapping(value = "/importCapEarlyWarningTimesByFile", method = RequestMethod.POST)
	public @ResponseBody 
	ModelMap importCodeInfosByFile(@RequestParam(value = "filePath", required = true) String filePath,
			ModelMap modelMap, HttpServletRequest request) {
		
		List<CapEarlyWarningTimeVo> inputFileList = new ArrayList<CapEarlyWarningTimeVo>();
		try {
			//读取文件信息
			inputFileList = capEarlyWarningTimeService.readCapEarlyWarnFromFile(filePath, request);
			
		} catch (Exception e) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", e.getMessage());
			return modelMap;
		}finally{
			//文件使用完进行删除			ComUtil.deleteFile(filePath);
		}

		try{
			capEarlyWarningTimeService.saveOrUpdate(inputFileList);
			modelMap.addAttribute("success", Boolean.TRUE);
		}catch(HibernateException e){
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", e.getMessage());
		} catch (DataIntegrityViolationException e) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.DATA_INTEGRITY_VIOLATION + "[" + e.getMostSpecificCause().getMessage() + "]");
		} catch (Exception e) {
			e.printStackTrace();
			logger.error(e.getCause().getCause().toString());
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
	 */
	@RequestMapping(value = "/export", method = RequestMethod.GET)
	public String export(HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		
		Map<String, Object> params = RequestUtil.getQueryMap(request, capEarlyWarningTimeService.fields);
		// 定义列显示顺序以及列标题
		Map<String, String> columns = new LinkedHashMap<String, String>();
		columns.put("aplCode", messages.getMessage("column.aplCode"));
		columns.put("busiKeyDate", messages.getMessage("column.busiKeyDate"));
		columns.put("summaryDesc", messages.getMessage("column.summaryDesc"));
		columns.put("riskDesc", messages.getMessage("column.riskDesc"));
		columns.put("handleTactics", messages.getMessage("column.handleTactics"));
		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY, columns);

		//设定导出用模板文件对应的sheet名字
		modelMap.addAttribute(Constants.SHEET_NAME,Constants.SHEET_NAME_CAPEARLYWARNINGTIME);
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,capEarlyWarningTimeService.queryAll(0, Constants.DEFAULT_EXCEL_ROW_LIMIT, "aplCode", Constants.DEFAULT_SORT_DIRECTION, params));
		
		//返回servletName
		return "excelViewExp";
	}
	
	/**
	 * 导出数据至excel文件.
	 * 
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/excel", method = RequestMethod.GET)
	public String excel(HttpServletRequest request, ModelMap modelMap) throws JEDAException {
	
		Map<String, Object> params = RequestUtil.getQueryMap(request, capEarlyWarningTimeService.fields);
		
		// 定义列显示顺序以及列标题
		Map<String, String> columns = new LinkedHashMap<String, String>();
		
		//需要根据现实情况修改
		columns.put("aplCode", messages.getMessage("column.aplCode"));
		columns.put("sysName", messages.getMessage("column.appSystemName"));
		columns.put("busiKeyDate", messages.getMessage("column.busiKeyDate"));
		columns.put("summaryDesc", messages.getMessage("column.summaryDesc"));
		columns.put("riskDesc", messages.getMessage("column.riskDesc"));
		columns.put("handleTactics", messages.getMessage("column.handleTactics"));
		
		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY, columns);
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, capEarlyWarningTimeService.queryAll(0, Constants.DEFAULT_EXCEL_ROW_LIMIT, "aplCode", Constants.DEFAULT_SORT_DIRECTION, params));
		return "excelView";
	}

	/**
	 * 查询应用系统所有编号
	 * @param response
	 */
	@RequestMapping(value = "/querySystemIDAndNames", method = RequestMethod.GET)
	public @ResponseBody void querySystemIDAndNames(HttpServletResponse response){
		PrintWriter out = null;
		try {
			Object sysIDs = capEarlyWarningTimeService.querySystemIDAndNames();
			response.setCharacterEncoding("utf-8");
			out = response.getWriter();
			out.print(JSONArray.fromObject(sysIDs));
		} catch (Exception e) {
			e.printStackTrace();
		}finally{
			if(out != null){
				out.close();
			}
		}
	}
	
	
}///:~
