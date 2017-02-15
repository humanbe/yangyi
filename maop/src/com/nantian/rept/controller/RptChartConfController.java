package com.nantian.rept.controller;

import java.io.IOException;
import java.io.PrintWriter;
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
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.orm.hibernate3.HibernateOptimisticLockingFailureException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.component.log.Logger;
import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.util.RequestUtil;
import com.nantian.rept.ReptConstants;
import com.nantian.rept.service.RptChartConfService;
import com.nantian.rept.service.RptItemConfService;
import com.nantian.rept.vo.RptChartConfMultVo;
import com.nantian.rept.vo.RptChartConfVo;
import com.nantian.rept.vo.RptItemConfVo;

/**
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 * 
 */
@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/rptchartconf")
public class RptChartConfController {

	/** 日志输出 */
	final Logger logger = Logger.getLogger(RptChartConfController.class);

	/** 领域对象名称 */
	private static final String domain = "RptChartConf";

	/** 视图前缀 */
	private static final String viewPrefix = "rept/" + domain + "/" + domain;

	@Autowired
	private RptItemConfService rptItemConfService;
	
	@Autowired
	private RptChartConfService rptChartConfService;
	
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
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		Map<String, Object> params = RequestUtil.getQueryMap(request, rptChartConfService.fields);
		try {
			List<Map<String,Object>> list = rptChartConfService.queryAllOutMap(start, limit, sort, dir, params);
			 
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, list);
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, list.size());
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
	 * 更新编辑数据
	 * @param aplCodeParam 系统编号
	 * @param reportTypeParam 日报类型
	 * @param sheetNameParam 功能名称
	 * @param itemNameDataParam 科目列表
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/editRptChart", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap editForRpt(@RequestParam(value = "aplCodeParam", required = false) String aplCodeParam,
			@RequestParam(value = "reportTypeParam", required = false) String reportTypeParam,
			@RequestParam(value = "sheetNameParam", required = false) String sheetNameParam,
			@RequestParam(value = "itemNameDataParam", required = false) String[] itemNameDataParam,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		try {
			RptItemConfVo vo =  new RptItemConfVo();
			List<RptItemConfVo> vos = new ArrayList<RptItemConfVo>();
			String[] rtpItemConfArr = new String[ReptConstants.RPT_ITEM_CONF_COLUMNS];
			
			//del data
			rptItemConfService.deleteById(aplCodeParam, reportTypeParam, sheetNameParam);
			
			//set data and save
			for (String itemData : itemNameDataParam) {
				vo =  new RptItemConfVo();
				rtpItemConfArr = itemData.split(Constants.SPLIT_SEPARATEOR, -1);
				
				vo.setAplCode(aplCodeParam);
				vo.setReportType(reportTypeParam);
				vo.setSheetName(sheetNameParam);
				vo.setItemName(rtpItemConfArr[0]);
				vo.setItemSeq("".equals(rtpItemConfArr[1])?null:Integer.valueOf(rtpItemConfArr[1]));
				vo.setExpression(rtpItemConfArr[2]);
				vo.setExpressionUnit(rtpItemConfArr[3]);
				vo.setGroupParent(rtpItemConfArr[4]);
				vos.add(vo);
			}
			rptItemConfService.saveOrUpdate(vos);
			
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
	 * 删除.
	 * 
	 * @param primaryKeys 主键列表
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/delete", method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap delete(@RequestParam(value = "primaryKeys", required = true) String[] primaryKeys,
			ModelMap modelMap)
			throws JEDAException {
		try {
			//del data
			rptChartConfService.deleteByIds(primaryKeys);
			
			modelMap.addAttribute("success", Boolean.TRUE);
			//logger.info(messages.getMessage("log.info.delete", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain), StringUtils.arrayToDelimitedString((Object[]) tranids, "|") }));
		} catch (DataIntegrityViolationException e) {
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.DATA_INTEGRITY_VIOLATION);
			//logger.error(messages.getMessage("log.error.delete", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain), StringUtils.arrayToDelimitedString((Object[]) tranids, "|") }));
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", e.getMessage());
			//modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
			//logger.error(messages.getMessage("log.error.delete", new String[] { securityUtils.getUserFullName(), messages.getMessage(domain), StringUtils.arrayToDelimitedString((Object[]) tranids, "|") }));
		}
		return modelMap;
	}
	
	/**
	 * 保存新建数据
	 * 
	 * @param rptChartConfVo 数据对象
	 * @return
	 */
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap save(@ModelAttribute RptChartConfVo rptChartConfVo,
			@ModelAttribute RptChartConfMultVo rptChartConfMultVo) throws JEDAException {
		ModelMap modelMap = new ModelMap();
		try {
			//需要配置报表扩展表
			if(rptChartConfMultVo.getItemNameCol()!=null && !rptChartConfMultVo.getItemNameCol().equals("") 
					&& rptChartConfMultVo.getItemValCol()!=null && !rptChartConfMultVo.getItemValCol().equals("")){
				if(rptChartConfMultVo.getSeparate_condition().equals("1")){ //起始行号
					rptChartConfMultVo.setSeparateRowNum(Float.valueOf(rptChartConfMultVo.getSeparate_value()));
				}else if(rptChartConfMultVo.getSeparate_condition().equals("2")){ //阀值
					rptChartConfMultVo.setSeparateThreshold(Float.valueOf(rptChartConfMultVo.getSeparate_value()));
				}
				rptChartConfService.saveOrUpdateForMult(rptChartConfMultVo);
			}
			//保存或者更新			rptChartConfService.saveOrUpdate(rptChartConfVo);
			
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (DataIntegrityViolationException e) {
			e.printStackTrace();
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
	 * 通过系统代码、报表类型、功能名称查询科目配置列表
	 * @param aplCode 系统代码
	 * @param reportType 报表类型
	 * @param sheetName 报表类型
	 * @param response 
	 */
	@RequestMapping(value = "/browseItemNames", method = RequestMethod.GET)
	public @ResponseBody void browseCodeMap(
			@RequestParam(value = "aplCode", required = true) String aplCode,
			@RequestParam(value = "reportType", required = true) String reportType,
			@RequestParam(value = "sheetName", required = true) String sheetName,
			HttpServletResponse response){
		JSONArray json = new JSONArray();
		PrintWriter out = null;
		List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
		Map<String, Object> map = null;
		try{
			List<RptItemConfVo> itemList = (List<RptItemConfVo>) rptItemConfService.queryRptItemConf(aplCode, reportType, URLDecoder.decode(sheetName,"utf-8"));
			for (RptItemConfVo rptItemConfVo : itemList) {
				if(!"1".equals(rptItemConfVo.getItemSeq().toString())){
					map = new HashMap<String,Object>();
					map.put("displayField", rptItemConfVo.getItemName());
					map.put("valueField", rptItemConfVo.getItemCd());
					list.add(map);
				}
			}
			json = JSONArray.fromObject(list);
			out = response.getWriter();
			out.print(json);
		}catch(IOException e){
			e.printStackTrace();
		}finally{
			out.close();
		}	
	}
	
	/**
	 * 通过系统代码和报表类型查询科目配置的功能列表
	 * @param aplCode 系统代码
	 * @param reportType 报表类型
	 * @param response 
	 */
	@RequestMapping(value = "/browseSheetNames", method = RequestMethod.GET)
	public @ResponseBody void browseCodeMap(
			@RequestParam(value = "aplCode", required = true) String aplCode,
			@RequestParam(value = "reportType", required = true) String reportType,
			HttpServletResponse response){
		JSONArray json = new JSONArray();
		PrintWriter out = null;
		try{
			List<Map<String, Object>> list = (List<Map<String, Object>>) rptItemConfService.querySheetNames2(aplCode, reportType);
			
			json = JSONArray.fromObject(list);
			out = response.getWriter();
			out.print(json);
		}catch(IOException e){
			e.printStackTrace();
		}finally{
			out.close();
		}	
	}
	
	
	
	/**
	 * 通过系统代码和报表类型查询科目配置的功能列表
	 * @param itemList 科目列表
	 * @param countItemName 统计科目名称
	 * @param response 
	 */
	@RequestMapping(value = "/getItemColsForMul", method = RequestMethod.GET)
	public @ResponseBody void getItemColsForMul(
			@RequestParam(value = "aplCode", required = true) String aplCode,
			@RequestParam(value = "itemList", required = true) String itemList,
			@RequestParam(value = "countItemName", required = false) String countItemName,
			HttpServletResponse response){
		JSONArray json = new JSONArray();
		PrintWriter out = null;
		List<Map<String, String>> list = new ArrayList<Map<String, String>>();
		if(itemList!=null && !itemList.equals("")){
			try{
				itemList = java.net.URLDecoder.decode(itemList,"utf-8") ;
				String[] nameList = itemList.split(",");
				//统计科目值				if(countItemName!=null && !countItemName.equals("")){
					countItemName = java.net.URLDecoder.decode(countItemName,"utf-8") ;
					for(int t=0 ; t<nameList.length ; t++){
						int  size = 0 ;
						if(!nameList[t].equals(countItemName)){
							Map<String,String> map = new HashMap<String,String>();
							
							String name=rptChartConfService.get_itemname(aplCode,nameList[t]);
							map.put("valueField", nameList[t]);
							map.put("displayField",name);
							list.add(size, map);
							size++;
						}
					}
				}else{ //统计科目名称
					for(int t=0 ; t<nameList.length ; t++){
						Map<String,String> map = new HashMap<String,String>();
						String name=rptChartConfService.get_itemname(aplCode,nameList[t]);
						map.put("valueField", nameList[t]);
						map.put("displayField",name);
						list.add(t, map);
					}
				}
				json = JSONArray.fromObject(list);
				out = response.getWriter();
				out.print(json);
			}catch(IOException e){
				e.printStackTrace();
			}finally{
				out.close();
			}	
		}
	}
	
	/**
	 * 通过系统代码查询科目列表的功能列表
	 * @param aplCode 系统代码
	 * @param response 
	 */
	@RequestMapping(value = "/item_list", method = RequestMethod.GET)
	public @ResponseBody void item_list(
			@RequestParam(value = "aplCode", required = true) String aplCode,
			HttpServletResponse response){
		JSONArray json = new JSONArray();
		PrintWriter out = null;
		try{
			List<Map<String, Object>> list = (List<Map<String, Object>>) rptChartConfService.queryItem_list(aplCode);
			
			json = JSONArray.fromObject(list);
			out = response.getWriter();
			out.print(json);
		}catch(IOException e){
			e.printStackTrace();
		}finally{
			out.close();
		}
	}

}// /:~
