package com.nantian.rept.controller;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;

import org.apache.axis2.AxisFault;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.orm.hibernate3.HibernateOptimisticLockingFailureException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.component.log.Logger;
import com.nantian.jeda.Constants;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.jeda.util.RequestUtil;
import com.nantian.rept.service.ItemConfService;
import com.nantian.rept.vo.RptItemAppVo;
import com.nantian.rept.vo.RptItemBaseVo;

/**
 * 三级科目配置
 * @author linaWang
 */
@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/itemconf")
public class ItemConfController {

	/** 日志输出 */
	final Logger logger = Logger.getLogger(ItemConfController.class);

	/** 领域对象名称 */
	private static final String domain = "ItemConf";

	/** 视图前缀 */
	private static final String viewPrefix = "rept/" + domain + "/" + domain;

	@Autowired
	private ItemConfService itemConfService;
	
	@Autowired
	private SecurityUtils securityUtils;


	/**
	 * 返回列表页面
	 * @return 列表页面视图名称
	 */
	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public String index() {
		return viewPrefix + "Index";
	}

	/**
	 * 分页查询报表信息
	 * @throws Exception 
	 * @throws AxisFault 
	 */
	@RequestMapping(value = "/getItemConfList", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getItemConfList(@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit",  required = false) Integer limit,
			@RequestParam(value = "parent", required = false) String parent,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir, HttpServletRequest request, ModelMap modelMap)
			throws AxisFault, Exception{
		Map<String, Object> params = RequestUtil.getQueryMap(request, itemConfService.fields);
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, itemConfService.getItemConfList(start, limit, sort, dir, params,request));
		modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, itemConfService.countItemConfList(params));
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 返回新建页面
	 */
	@RequestMapping(value = "/create", method  = RequestMethod.GET)
	public String createItemConf(){
		return viewPrefix + "Create";
	}
	
	/**
	 * 保存科目配置数据
	 * @param 
	 * @throws Exception 
	 */
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap createItemConf(@ModelAttribute RptItemAppVo rptItemAppVo) throws Exception{
		ModelMap modelMap = new ModelMap();
		//获取当前登录用户编号
        String userCode = securityUtils.getUser().getUsername();
        //获取当前时间
        String curTime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());
		Timestamp ts = Timestamp.valueOf(curTime) ;
		//设置属性值
		rptItemAppVo.setItem_creator(userCode);
		rptItemAppVo.setItem_created(ts);
		if(null==rptItemAppVo.getItem_cd_app()||"".equals(rptItemAppVo.getItem_cd_app())){
			rptItemAppVo.setItem_cd_app(rptItemAppVo.getItem_cd_lvl1()+"_"+rptItemAppVo.getItem_cd_lvl2());
		}else{
			rptItemAppVo.setItem_cd_app(rptItemAppVo.getItem_cd_lvl1()+"_"+rptItemAppVo.getItem_cd_lvl2()+"_"+rptItemAppVo.getItem_cd_app());
		}
		//保存
		itemConfService.save(rptItemAppVo);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 返回查看页面
	 */
	@RequestMapping(value = "/view", method = RequestMethod.GET)
	public String viewItemConf() {
		return viewPrefix + "View";
	}

	/**
	 * 根据ID查询作业相关信息
	 * @param keys联合主键     字符串格式：系统编号,一级科目, 二级科目,三级科目
	 */
	@RequestMapping(value = "/view/{keys}", method = RequestMethod.GET)
	public @ResponseBody
	ModelMap viewItemConf(@PathVariable("keys") String keys, ModelMap modelMap) throws Exception {
		Map<String,Object> map = new HashMap<String,Object>();
		keys = java.net.URLDecoder.decode(keys,"utf-8") ;
		String[] params = keys.split(",");
		map = itemConfService.getItemConfById(params[0],params[3]);
		modelMap.addAttribute("data", map);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 返回编辑页面
	 */
	@RequestMapping(value = "/edit", method = RequestMethod.GET)
	public String editItemConf() {
		return viewPrefix + "Edit";
	}

	/**
	 * 更新修改数据
     * @param keys联合主键     字符串格式：系统编号,一级科目, 二级科目,三级科目
	 */
	@RequestMapping(value = "/edit/{keys}", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap editItemConf(@PathVariable("keys") String keys, @ModelAttribute RptItemAppVo rptItemAppVo
			) throws HibernateOptimisticLockingFailureException,Exception {
		ModelMap modelMap = new ModelMap();
		keys = java.net.URLDecoder.decode(keys,"utf-8") ;
		String[] params = keys.split(",");
		//删除原有数据
		itemConfService.deleteById(params[0],params[3]);
		//保存新配置数据
        String userCode = securityUtils.getUser().getUsername();
        String curTime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());
		Timestamp ts = Timestamp.valueOf(curTime) ;
		rptItemAppVo.setItem_modifier(userCode);
		rptItemAppVo.setItem_modified(ts);
		itemConfService.save(rptItemAppVo);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 批量删除
	 * @param primaryKeys 主键数组[系统编号,一级科目,二级科目,三级科目] 
	 */
	@RequestMapping(value = "/delete", method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap deleteJobs(@RequestParam(value = "keys", required = true) String[] keys, ModelMap modelMap){
		itemConfService.deleteByIds(keys);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	

	/**
	 * 获取lvl3store
	 * @param aplCode 系统代码
	 * @param response 
	 * @throws UnsupportedEncodingException 
	 */
	@RequestMapping(value = "/getLvl3Store", method = RequestMethod.POST)
	public @ResponseBody void getLvl3Store(
			@RequestParam(value = "aplCode", required = true) String aplCode,
			@RequestParam(value = "item_cd_lvl1", required = true) String item_cd_lvl1,
			@RequestParam(value = "item_cd_lvl2", required = true) String item_cd_lvl2,
			HttpServletResponse response) throws UnsupportedEncodingException{
		JSONArray json = new JSONArray();
		PrintWriter out = null;
		
		try{
			List<Map<String, Object>> list = itemConfService.getLvl3Store(aplCode,item_cd_lvl1,item_cd_lvl2);
			
			
			
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
	 * 获取lvl2store
	 * @param aplCode 系统代码
	 * @param response 
	 * @throws UnsupportedEncodingException 
	 */
	@RequestMapping(value = "/getLvl2Store", method = RequestMethod.POST)
	public @ResponseBody void getLvl2Store(
			@RequestParam(value = "aplCode", required = true) String aplCode,
			@RequestParam(value = "item_cd_lvl1", required = true) String item_cd_lvl1,
			HttpServletResponse response) throws UnsupportedEncodingException{
		JSONArray json = new JSONArray();
		PrintWriter out = null;
		
		try{
			List<Map<String, Object>> list = itemConfService.getLvl2Store(aplCode,item_cd_lvl1);
			
			
			
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
	 * 获取lv1store
	 * @param aplCode 系统代码
	 * @param response 
	 * @throws UnsupportedEncodingException 
	 */
	@RequestMapping(value = "/getLvl1Store", method = RequestMethod.POST)
	public @ResponseBody void getLvl1Store(
			@RequestParam(value = "aplCode", required = true) String aplCode,
			HttpServletResponse response) throws UnsupportedEncodingException{
		JSONArray json = new JSONArray();
		PrintWriter out = null;
		
		try{
			List<Map<String, Object>> list = itemConfService.getLvl1Store(aplCode);
			
			
			
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
	 * 获取lv1store
	 * @param aplCode 系统代码
	 * @param response 
	 * @throws UnsupportedEncodingException 
	 */
	@RequestMapping(value = "/getLvl1StoreCreate", method = RequestMethod.POST)
	public @ResponseBody void getLvl1StoreCreate(
			HttpServletResponse response) throws UnsupportedEncodingException{
		JSONArray json = new JSONArray();
		PrintWriter out = null;
		
		try{
			List<Map<String, Object>> list = itemConfService.getLvl1StoreCreate();
			
			
			
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
	 * 获取lv2store
	 * @param aplCode 系统代码
	 * @param response 
	 * @throws UnsupportedEncodingException 
	 */
	@RequestMapping(value = "/getLvl2StoreCreate", method = RequestMethod.POST)
	public @ResponseBody void getLvl2StoreCreate(
			@RequestParam(value = "item_cd_lvl1", required = true) String item_cd_lvl1,
			HttpServletResponse response) throws UnsupportedEncodingException{
		JSONArray json = new JSONArray();
		PrintWriter out = null;
		
		try{
			List<Map<String, Object>> list = itemConfService.getLvl2StoreCreate(item_cd_lvl1);
			
			
			
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
	 * 下载模板文件
	 * @param request
	 * @param modelMap+
	 * @return
	 */
	@RequestMapping(value = "/downloadxls", method = RequestMethod.GET)
	public String downloadxls(HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		String downpath = System.getProperty("maop.root")+ File.separatorChar+"file"+ File.separatorChar+"itemConf.xls";
		
		modelMap.addAttribute("PATH", downpath);
		//返回servletName
		return "fileView";
	}
	
	/**
	 * 导出查询服务器结果到excel文件
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/excel", method = RequestMethod.GET)
	public String itemConf_excel(HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		// 定义列显示顺序以及列标题
		Map<String, String> columns = new LinkedHashMap<String, String>();
		columns.put("apl_code", "应用系统");
		columns.put("item_cd_lvl1", "一级分类");
		columns.put("item_cd_lvl2", "二级分类");
		columns.put("item_cd_app","科目编码");
		columns.put("item_app_name", "科目名称");
		columns.put("item_app_ststcs_peak_flag", "巡检指标是否统计峰值标识");
		columns.put("expression","计算式");
		columns.put("item_creator", "创建人");
		columns.put("item_created", "创建时间");
		columns.put("item_modifier","修改人");
		columns.put("item_modified","修改时间");
		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY, columns);
		List<Map<String,String>> list= (List<Map<String, String>>) request.getSession().getAttribute("ItemConfList");
		
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, list);
		return "excelView";
	}
	
	/**
	 * 导入 信息

	 * @param request
	 * @param modelMap
	 * @return
	 * @throws Exception 
	 */
	@RequestMapping(value = "/importItemAPP", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap importItemConf(
			@RequestParam(value = "filePath", required = true) String filePath,
			HttpServletRequest request, ModelMap modelMap) throws Exception {
		  
		   List<RptItemAppVo> list= itemConfService.getItemAPPList(filePath);
		 
			try {
				
				itemConfService.importItemAPPs(list);
				
				modelMap.addAttribute("success", Boolean.TRUE);
			} catch (Exception e) {
				modelMap.addAttribute("success", Boolean.FALSE);
				modelMap.addAttribute("error", e.getMessage());
			}
		 
		return modelMap;
}
	
}


