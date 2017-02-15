package com.nantian.rept.controller;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

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
import com.nantian.rept.service.TypicalCapaAnaService;
import com.nantian.rept.vo.TypicalCapaAnaVo;

/**
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 * 
 */
@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/typicalcapaana")
public class TypicalCapaAnaController {
	
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(TypicalCapaAnaController.class);

	/** 领域对象名称 */
	private static final String domain = "TypicalCapaAna";

	/** 视图前缀 */
	private static final String viewPrefix = "rept/" + domain + "/" + domain;
	
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
	@Autowired
	private TypicalCapaAnaService typicalCapaAnaService;
	
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
	 * @param sort           排序的字段	 * @param dir	  		   排序的方式	 * @param appSysCd   应用系统编号
	 * @param sysseqnum  流水号
	 * @param errorTime  故障发生时间
	 * @param riskType  风险等级
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
			@RequestParam(value = "appSysCd", required = false) String appSysCd,
			@RequestParam(value = "sysseqnum", required = false) String sysseqnum,
			@RequestParam(value = "errorTime", required = false) String errorTime,
			@RequestParam(value = "riskType", required = false) String riskType,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		Map<String, Object> params = RequestUtil.getQueryMap(request, typicalCapaAnaService.fields);
		
		try{
			
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, typicalCapaAnaService.queryAll(start, limit, sort, dir, params));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, typicalCapaAnaService.count(params));
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
	ModelMap save(@ModelAttribute TypicalCapaAnaVo typicalCapaAnaVo) throws JEDAException {
		ModelMap modelMap = new ModelMap();
		try {
			typicalCapaAnaService.save(typicalCapaAnaVo);
			modelMap.addAttribute("sysseqnum", typicalCapaAnaVo.getSysseqnum());
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
	 * @param sysseqnum 应用系统编号
	 * @param modelMap
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/edit/{sysseqnum}", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap edit(@PathVariable("sysseqnum") String sysseqnum, 
							ModelMap modelMap,HttpServletRequest request) throws JEDAException {
		try {
			TypicalCapaAnaVo vo = (TypicalCapaAnaVo) typicalCapaAnaService.findByPrimaryKey(sysseqnum);
			ServletRequestDataBinder binder = new ServletRequestDataBinder(vo);
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
			
			dateFormat.setLenient(false);
			binder.registerCustomEditor(Date.class, new CustomDateEditor(dateFormat, true));
		    binder.bind(request);
		    //更新
		    typicalCapaAnaService.update(vo);
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
	 * @param sysseqnums 流水号主键数组
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/delete", method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap delete(
			@RequestParam(value = "sysseqnums", required = true) String[] sysseqnums, 
			ModelMap modelMap)
			throws JEDAException {
		try {
			typicalCapaAnaService.deleteByIds(sysseqnums);
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
	@RequestMapping(value = "/view", method = RequestMethod.POST)
	public @ResponseBody ModelMap view(
			@RequestParam(value = "sysseqnum", required = true) String sysseqnum,
			ModelMap modelMap) throws JEDAException{
		try {
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,
					typicalCapaAnaService.findByPrimaryKey(sysseqnum));
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
	@RequestMapping(value = "/importTypicalCapaAnasByFile", method = RequestMethod.POST)
	public @ResponseBody 
	ModelMap importTypicalCapaAnasByFile(@RequestParam(value = "filePath", required = true) String filePath,
			ModelMap modelMap, HttpServletRequest request) {
		
		List<TypicalCapaAnaVo> inputFileList = new ArrayList<TypicalCapaAnaVo>();
		try {
			//读取文件信息
			inputFileList = typicalCapaAnaService.readTypicalCapaAnaFromFile(filePath, request);
			
		} catch (Exception e) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", e.getMessage());
			return modelMap;
		}finally{
			//文件使用完进行删除			ComUtil.deleteFile(filePath);
		}

		try{
			
			typicalCapaAnaService.saveOrUpdate(inputFileList);
			
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
		
		Map<String, Object> params = RequestUtil.getQueryMap(request, typicalCapaAnaService.fields);
		// 定义列显示顺序以及列标题
		Map<String, String> columns = new LinkedHashMap<String, String>();
		columns.put("sysseqnum", messages.getMessage("column.sysseqnum"));
		columns.put("appSysCd", messages.getMessage("column.appSysCd"));
		columns.put("errorTime", messages.getMessage("column.errorTime"));
		columns.put("riskType", messages.getMessage("column.riskType"));
		columns.put("workorderSubject", messages.getMessage("column.workorderSubject"));
		columns.put("caseCause", messages.getMessage("column.caseCause"));
		columns.put("handleMethod", messages.getMessage("column.handleMethod"));
		columns.put("optimizePlan", messages.getMessage("column.optimizePlan"));
		columns.put("caseAna", messages.getMessage("column.caseAna"));
		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY, columns);

		//设定导出用模板文件对应的sheet名字
		modelMap.addAttribute(Constants.SHEET_NAME,Constants.SHEET_NAME_TYPICALCAPAANA);
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,typicalCapaAnaService.queryAll(0, Constants.DEFAULT_EXCEL_ROW_LIMIT, "sysseqnum", Constants.DEFAULT_SORT_DIRECTION, params));
		
		//返回servletName
		return "excelViewExp";
	}
	
	/**
	 * 导出数据至excel文件.
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/excel", method = RequestMethod.GET)
	public String excel(HttpServletRequest request, ModelMap modelMap) throws JEDAException {
	
		Map<String, Object> params = RequestUtil.getQueryMap(request, typicalCapaAnaService.fields);
		
		// 定义列显示顺序以及列标题
		Map<String, String> columns = new LinkedHashMap<String, String>();
		
		//需要根据现实情况修改
		columns.put("sysseqnum", messages.getMessage("column.sysseqnum"));
		columns.put("appSysCd", messages.getMessage("column.appSysCd"));
		columns.put("errorTime", messages.getMessage("column.errorTime"));
		columns.put("riskType", messages.getMessage("column.riskType"));
		columns.put("workorderSubject", messages.getMessage("column.workorderSubject"));
		columns.put("caseCause", messages.getMessage("column.caseCause"));
		columns.put("handleMethod", messages.getMessage("column.handleMethod"));
		columns.put("optimizePlan", messages.getMessage("column.optimizePlan"));
		columns.put("caseAna", messages.getMessage("column.caseAna"));
		
		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY, columns);
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, typicalCapaAnaService.queryAll(0, Constants.DEFAULT_EXCEL_ROW_LIMIT, "sysseqnum", Constants.DEFAULT_SORT_DIRECTION, params));
		return "excelView";
	}
	
	
}///:~
