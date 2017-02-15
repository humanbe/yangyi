package com.nantian.rept.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.orm.hibernate3.HibernateOptimisticLockingFailureException;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.common.util.ComUtil;
import com.nantian.common.util.CommonConst;
import com.nantian.common.util.NumberUtil;
import com.nantian.component.log.Logger;
import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.rept.ReptConstants;
import com.nantian.rept.service.RptItemConfService;
import com.nantian.rept.vo.RptItemConfVo;

/**
 * @author <a href="mailto:donghui@nantian.com.cn">donghui</a>
 * 
 */
@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/rptitemconf")
public class RptItemConfController {

	/** 日志输出 */
	final Logger logger = Logger.getLogger(RptItemConfController.class);

	/** 领域对象名称 */
	private static final String domain = "RptItemConf";

	/** 视图前缀 */
	private static final String viewPrefix = "rept/" + domain + "/" + domain;

	@Autowired
	private RptItemConfService rptItemConfService;

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
			@RequestParam(value = "aplCode", required = true) String aplCode,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		try {
			Map<String, Object> Level1Map = new HashMap<String, Object>();//系统
			Map<String, Object> Level2Map = new HashMap<String, Object>();//报表类型
			Map<String, Object> Level3Map = new HashMap<String, Object>();//功能
			Map<String, Object> Level4Map = new HashMap<String, Object>();//科目
			List<Map<String, Object>> dataList = new ArrayList<Map<String, Object>>();
			StringBuilder aplCodes = new StringBuilder();
			StringBuilder reportTypes = new StringBuilder();
			
			List<Map<String, Object>> sheetNames = rptItemConfService.querySheetNames(aplCode,null);
			List<Map<String,Object>> list  = rptItemConfService.queryRptItemConfList2(aplCode, null, null);
	     	int count = 0;
	     	for(Map<String,Object> _map : sheetNames){
	     		Level3Map = new HashMap<String, Object>();
	     		Level4Map = new HashMap<String, Object>();
	     		
	     		if(aplCodes.toString().indexOf(_map.get("aplCode").toString()) == -1){
	     			reportTypes.delete(0, reportTypes.length());
	     			Level1Map = new HashMap<String, Object>();
	     			Level1Map.put("combine", _map.get("aplCode").toString().concat(CommonConst.LEFT_SMALL_BRACKETS_NOESCAPE).concat(_map.get("aplAllName").toString()).concat(CommonConst.RIGHT_SMALL_BRACKETS_NOESCAPE));
	     			Level1Map.put("_id", ++count);
	     			Level1Map.put("_parent", null);
	     			Level1Map.put("_is_leaf", false);
	     			Level1Map.put("sheetSeq", null);
	     			Level1Map.put("itemSeq", null);
	     			Level1Map.put("expression", null);
	     			Level1Map.put("expressionUnit", null);
	     			Level1Map.put("groupParent", null);
	     			
	     			dataList.add(Level1Map);
		     		aplCodes.append(_map.get("aplCode").toString());
	     		}
	     		if(reportTypes.toString().indexOf(_map.get("reportType").toString()) == -1){
	     			Level2Map = new HashMap<String, Object>();
	     			switch(ComUtil.changeToChar(_map.get("reportType").toString())){
	     			case '1' : 
	     				Level2Map.put("combine", "日报");
	     				break;
	     			case '2':
	     				Level2Map.put("combine", "周报");
	     				break;
	     			case '3':
	     				Level2Map.put("combine", "月报");
	     				break;
	     			}
		     		Level2Map.put("_id", ++count);
		     		Level2Map.put("_parent", Level1Map.get("_id"));
		     		Level2Map.put("_is_leaf", false);
		     		Level2Map.put("sheetName", null);
		     		Level2Map.put("sheetSeq", null);
		     		Level2Map.put("itemSeq", null);
		     		Level2Map.put("expression", null);
		     		Level2Map.put("expressionUnit", null);
		     		Level2Map.put("groupParent", null);
	     			dataList.add(Level2Map);
		     		reportTypes.append(_map.get("reportType").toString());
	     		}
	     		Level3Map.put("combine", _map.get("sheetName"));
	     		Level3Map.put("_id", ++count);
	     		Level3Map.put("_parent", Level2Map.get("_id"));
	     		Level3Map.put("_is_leaf", true);
	     		Level3Map.put("sheetName", _map.get("sheetName"));
	     		Level3Map.put("sheetSeq", _map.get("sheetSeq"));
	     		Level3Map.put("itemSeq", null);
	     		Level3Map.put("expression", null);
	     		Level3Map.put("expressionUnit", null);
	     		Level3Map.put("groupParent", null);
	     		Level3Map.put("dataGroupFlag", count);
	     		dataList.add(Level3Map);
	     		
	     		for(Map<String,Object> _map2 : list){
	     			Level4Map = new HashMap<String, Object>();
	     			
	     			if(_map.get("aplCode").equals(_map2.get("APL_CODE")) && _map.get("sheetName").equals(_map2.get("SHEET_NAME")) && _map.get("reportType").toString().equals(_map2.get("REPORT_TYPE").toString())){
	     				Level3Map.put("_is_leaf", false);
	    	     		
	     				if(null!=_map2.get("ITEM_APP_NAME")){
	     					Level4Map.put("combine", _map2.get("ITEM_APP_NAME"));
	     				}else{
	     					Level4Map.put("combine", _map2.get("ITEM_CD"));
	     				}
	     				Level4Map.put("_id", ++count);
	     				Level4Map.put("_parent", Level3Map.get("_id"));
	     				Level4Map.put("_is_leaf", true);
	     				Level4Map.put("sheetSeq", null);
	     				Level4Map.put("sheetSeqForSetVal", Level3Map.get("sheetSeq"));
	     				Level4Map.put("itemSeq", _map2.get("ITEM_SEQ"));
	     				Level4Map.put("expression", _map2.get("EXPRESSION"));
	     				Level4Map.put("expressionUnit", _map2.get("EXPRESSION_UNIT"));
	     				Level4Map.put("groupParent", _map2.get("GROUP_PARENT"));
	     				Level4Map.put("dataGroupFlag", Level3Map.get("dataGroupFlag"));
	     				Level4Map.put("aplCode", _map2.get("APL_CODE"));
	     				Level4Map.put("reportType", _map2.get("REPORT_TYPE"));
	     				Level4Map.put("sheetName", _map2.get("SHEET_NAME"));
	     				String item_cd = _map2.get("ITEM_CD").toString();
	     				String item_cd_lvl1 = (null==_map2.get("ITEM_CD_LVL1"))?"":_map2.get("ITEM_CD_LVL1").toString();
	     				String item_cd_lvl2 = (null==_map2.get("ITEM_CD_LVL2"))?"":_map2.get("ITEM_CD_LVL2").toString();
	     				Level4Map.put("itemNameOne",item_cd_lvl1);
	     				Level4Map.put("itemNameTwo", item_cd_lvl2);
	     				Level4Map.put("itemName",item_cd);
	     				String item_cd_lvl1_name=(null==_map2.get("ITEM_CD_LVL1"))?"":rptItemConfService.getItemName("1", item_cd_lvl1, null);
	     				String item_cd_lvl2_name=(null==_map2.get("ITEM_CD_LVL2"))?"":rptItemConfService.getItemName("2", item_cd_lvl2, item_cd_lvl1);
	     				Level4Map.put("itemNameOneNAME",item_cd_lvl1_name);
	     				Level4Map.put("itemNameTwoNAME", item_cd_lvl2_name);
	     				
	     			//	Level4Map.put("itemNameOne", level.substring(0, level.indexOf(CommonConst.LEVEL_SEPARATOR)));
	     			//	Level4Map.put("itemNameTwo", level.substring(level.indexOf(CommonConst.LEVEL_SEPARATOR)+2,level.lastIndexOf(CommonConst.LEVEL_SEPARATOR)));
	     			//	Level4Map.put("itemName", level.substring(level.lastIndexOf(CommonConst.LEVEL_SEPARATOR)+2));
	    	     		dataList.add(Level4Map);
	     			}
	     		}
			}
			
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, dataList);
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, dataList.size());
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
	@RequestMapping(value = "/editRptItem", method = RequestMethod.POST)
	@Transactional(rollbackFor = SQLException.class, propagation = Propagation.REQUIRED, value = "maoprpt")
	public @ResponseBody
	ModelMap editForRpt(@RequestParam(value = "aplCodeParam", required = true) String aplCodeParam,
			@RequestParam(value = "reportTypeParam", required = true) String reportTypeParam,
			@RequestParam(value = "sheetNameParam", required = true) String sheetNameParam,
			@RequestParam(value = "sheetSeqParam", required = true) String sheetSeqParam,
			@RequestParam(value = "itemNameDataParam", required = true) String[] itemNameDataParam,
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
				vo.setItemCd(rtpItemConfArr[2]);
				vo.setSheetSeq("".equals(sheetSeqParam)?null:Integer.valueOf(sheetSeqParam));
				vo.setItemSeq("".equals(rtpItemConfArr[3])?null:Integer.valueOf(rtpItemConfArr[3]));
				vo.setExpression(rtpItemConfArr[4]); 
				vo.setExpressionUnit(rtpItemConfArr[5]);
				vo.setGroupParent(rtpItemConfArr[6]);
				//List l=rptItemConfService.getCountItemLevelType(aplCodeParam,rtpItemConfArr[0],rtpItemConfArr[1],rtpItemConfArr[2]);
				/*if(l.size()>0){
					vo.setCountItemLevelType(Integer.valueOf(l.get(0).toString()));
				}else{
					vo.setCountItemLevelType(3);
				}*/
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
	 * 更新编辑数据
	 * @param aplCodeParam 系统编号
	 * @param reportTypeParam 日报类型
	 * @param sheetNameParam 功能名称
	 * @param itemNameDataParam 科目列表
	 * @param request
	 * @return
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/editRptItemWeblogic", method = RequestMethod.POST)
	@Transactional(rollbackFor = SQLException.class, propagation = Propagation.REQUIRED, value = "maoprpt")
	public @ResponseBody
	ModelMap editRptItemWeblogic(@RequestParam(value = "aplCodeParam", required = true) String aplCodeParam,
			@RequestParam(value = "reportTypeParam", required = true) String reportTypeParam,
			@RequestParam(value = "sheetNameParam", required = true) String sheetNameParam,
			@RequestParam(value = "sheetSeqParam", required = true) String sheetSeqParam,
			@RequestParam(value = "itemNameDataParam", required = true) String[] itemNameDataParam,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		try {
			RptItemConfVo vo =  new RptItemConfVo();
			List<RptItemConfVo> vos = new ArrayList<RptItemConfVo>();
			String[] rtpItemConfArr = new String[3];
			Set<String> itemcds=new HashSet<String>();
			int seq=1;
			
			List<Map<String,Object>> list=new ArrayList<Map<String,Object>>();
			//del data
			rptItemConfService.deleteById(aplCodeParam, reportTypeParam, sheetNameParam);
			
			//set data and save
			for (String itemData : itemNameDataParam) {
				
				rtpItemConfArr = itemData.split(Constants.SPLIT_SEPARATEOR, -1);
				String[] servernames =rtpItemConfArr[3].split(",",-1);
				for(int i=0;i<servernames.length;i++){
					Map<String,Object> map =new HashMap<String, Object>();
					map.put("groupParent", rtpItemConfArr[2]);
					map.put("itemCd", servernames[i]);
					list.add(map);
				}
			}
			
			for(Map<String,Object> map2 :list){
				String GroupParent="";
				if(null==map2.get("itemCd")||"".equals(map2.get("itemCd").toString())){
					vo =  new RptItemConfVo();
					vo.setAplCode(aplCodeParam);
					vo.setReportType(reportTypeParam);
					vo.setSheetName(sheetNameParam);
					vo.setSheetSeq("".equals(sheetSeqParam)?null:Integer.valueOf(sheetSeqParam));
					vo.setItemSeq(seq);
					vo.setItemCd(map2.get("groupParent").toString());
					seq++;
					vos.add(vo);
				}else{
					if(!itemcds.contains(map2.get("itemCd").toString())){
						itemcds.add(map2.get("itemCd").toString());
						vo =  new RptItemConfVo();
						vo.setAplCode(aplCodeParam);
						vo.setReportType(reportTypeParam);
						vo.setSheetName(sheetNameParam);
						vo.setSheetSeq("".equals(sheetSeqParam)?null:Integer.valueOf(sheetSeqParam));
						vo.setItemSeq(seq);
						vo.setItemCd(map2.get("itemCd").toString());
						for(int j=0;j<list.size();j++){
							if(map2.get("itemCd").toString().equals(list.get(j).get("itemCd").toString())){
								GroupParent=GroupParent+","+list.get(j).get("groupParent").toString();
								
							}
						}
						vo.setGroupParent("".equals(GroupParent)?null:GroupParent.substring(1));
						seq++;
						
						vos.add(vo);
					}
				}
				
				
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
	 * @param aplCodeParam 系统编号
	 * @param reportTypeParam 日报类型
	 * @param sheetNameParam 功能名称
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/delete", method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap delete(@RequestParam(value = "aplCodeParam", required = false) String aplCodeParam,
			@RequestParam(value = "reportTypeParam", required = false) String reportTypeParam,
			@RequestParam(value = "sheetNameParam", required = false) String sheetNameParam,ModelMap modelMap)
			throws JEDAException {
		try {
			
			//del data
			rptItemConfService.deleteById(aplCodeParam, reportTypeParam, sheetNameParam);
			
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
	

	public static void main(String[] args) throws NumberFormatException, Exception{
		System.out.println(Double.valueOf(NumberUtil.eval("合计/SUM(合计)")));
	}
	
	/**
	 * 返回配置编辑页面
	 * 最近31天日网络资源使用情况
	 * 最近31天日weblogic使用情况
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/Network_Days_Use_Conf", method = RequestMethod.GET)
	public String Network_Days_Use_Conf() throws JEDAException {
		return "rept/RptItemConf/Network_Days_Use_Conf"; 
	}
	
	/**
	 * 返回配置编辑页面
	 * 最近31天日weblogic使用情况
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/Weblogic_Days_Use_Conf", method = RequestMethod.GET)
	public String Weblogic_Days_Use_Conf() throws JEDAException {
		return "rept/RptItemConf/Weblogic_Days_Use_Conf"; 
	}
	
	
	/**
	 * 返回配置编辑页面
	 * 当日weblogic使用情况
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/Weblogic_ToDay_Use_Conf", method = RequestMethod.GET)
	public String Weblogic_ToDay_Use_Conf() throws JEDAException {
		return "rept/RptItemConf/Weblogic_ToDay_Use_Conf"; 
	}
	
	/**
	 * 返回配置编辑页面
	 * 当日网络资源使用情况
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/Network_ToDay_Use_Conf", method = RequestMethod.GET)
	public String Network_ToDay_Use_Conf() throws JEDAException {
		return "rept/RptItemConf/Network_ToDay_Use_Conf"; 
	}
	
	/**
	 * 返回配置编辑页面
	 * 最近31天分钟和秒交易情况
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/Minute_Second_Trans_Conf", method = RequestMethod.GET)
	public String Minute_Second_Trans_Conf() throws JEDAException {
		return "rept/RptItemConf/Minute_Second_Trans_Conf"; 
	}
	
	/**
	 * 返回配置编辑页面
	 * 系统资源使用率图表
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/System_resource_Conf", method = RequestMethod.GET)
	public String System_resource_Conf() throws JEDAException {
		return "rept/RptItemConf/System_resource_Conf"; 
	}
	
	
	/**
	 * 返回配置编辑页面
	 * 最近7天日批量执行情况
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/Day_Batch_Conf", method = RequestMethod.GET)
	public String Day_Batch_Conf() throws JEDAException {
		return "rept/RptItemConf/Day_Batch_Conf"; 
	}
	
	/**
	 * 返回配置编辑页面
	 * 最近7天分小时交易情况
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/Hour_Minute_Trans_Conf", method = RequestMethod.GET)
	public String Hour_Minute_Trans_Conf() throws JEDAException {
		return "rept/RptItemConf/Hour_Minute_Trans_Conf"; 
	}
	
	/**
	 * 返回配置编辑页面
	 * 当日情况统计
	 * 最近31天日交易情况
	 * 最近31天日批量执行情况
	 * @return 列表页面视图名称
	 * @throws JEDAException
	 */
	@RequestMapping(value = "/Day_Trans_Conf", method = RequestMethod.GET)
	public String Day_Trans_Conf() throws JEDAException {
		return "rept/RptItemConf/Day_Trans_Conf"; 
	}
	
	
	
	
	/**
	 * 通过系统代码和报表类型查询科目配置的功能列表
	 * @param aplCode 系统代码
	 * @param reportType 报表类型
	 * @param response 
	 * @throws UnsupportedEncodingException 
	 */
	@RequestMapping(value = "/WeblogicDataList", method = RequestMethod.GET)
	public @ResponseBody void WeblogicDataList(
			@RequestParam(value = "aplCode", required = true) String aplCode,
			@RequestParam(value = "reportType", required = true) String reportType,
			@RequestParam(value = "sheetName", required = true) String sheetName,
			HttpServletResponse response) throws UnsupportedEncodingException{
		JSONArray json = new JSONArray();
		PrintWriter out = null;
		sheetName=java.net.URLDecoder.decode(sheetName,"utf-8") ;
		try{
			List<Map<String, Object>> list = (List<Map<String, Object>>) rptItemConfService.WeblogicDataList(aplCode, reportType,sheetName);
			List<Map<String, Object>> list2 =new ArrayList<Map<String,Object>>();
			List<Map<String, Object>> list3=new ArrayList<Map<String,Object>>();
			Map<String, Object> map1= new HashMap<String, Object>();
			Set<String> itemCds=new HashSet<String>();
			for(Map<String, Object> map:list){
				
				if(null==map.get("groupParent")||"".equals(map.get("groupParent").toString())){
					map1.put("itemCd", map.get("itemCd"));
					map1.put("servername","");
					map1.put("item_cd_lvl1","ALL");
					map1.put("item_cd_lvl2","ALL");
					map1.put("itemName",  map.get("itemCd"));
					map1.put("item_cd_lvl1_name", "ALL");
					map1.put("item_cd_lvl2_name","ALL");
     				
				}else{
					String[] s= map.get("groupParent").toString().split(",");
					for(int i=0;i<s.length;i++){
						Map<String, Object> map2= new HashMap<String, Object>();
						map2.put("itemCd", s[i]);
						map2.put("servername", map.get("itemCd"));
						list2.add(map2);
					}
				}
			}
				list3.add(map1);
				for(Map<String, Object> map3:list2){
					
					Map<String, Object> map5= new HashMap<String, Object>();
					String servernames="";
					if(!itemCds.contains(map3.get("itemCd"))){
						itemCds.add(map3.get("itemCd").toString());
						for(Map<String, Object> map4:list2){
							if(map3.get("itemCd").toString().equals(map4.get("itemCd").toString())){
								servernames=servernames+"#"+map4.get("servername").toString();
							}
						}
						
						List<Map<String,Object>> l=rptItemConfService.WeblogicDataLVL(aplCode,  map3.get("itemCd").toString());
						
						String lvl1=l.get(0).get("item_cd_lvl1").toString();
						String lvl2=l.get(0).get("item_cd_lvl2").toString();
						String itemName=l.get(0).get("item_app_name").toString();
						
						String item_cd_lvl1_name=rptItemConfService.getItemName("1", lvl1, null);
	     				String item_cd_lvl2_name=rptItemConfService.getItemName("2", lvl2, lvl1);
	     			
	     				
	     				map5.put("item_cd_lvl1",lvl1);
	     				map5.put("item_cd_lvl2",lvl2);
	     				map5.put("itemName", itemName);
	     				map5.put("item_cd_lvl1_name", item_cd_lvl1_name);
	     				map5.put("item_cd_lvl2_name",item_cd_lvl2_name);
	     				
						map5.put("itemCd", map3.get("itemCd"));
						map5.put("servername", servernames.substring(1));
						list3.add(map5);
					}
				}
				
			
			
			json = JSONArray.fromObject(list3);
			out = response.getWriter();
			out.print(json);
		}catch(IOException e){
			e.printStackTrace();
		}finally{
			out.close();
		}	
	}
	
	
	
	
}// /:~
