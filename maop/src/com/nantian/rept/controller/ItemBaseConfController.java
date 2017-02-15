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
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;

import org.apache.axis2.AxisFault;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.orm.hibernate3.HibernateOptimisticLockingFailureException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.component.log.Logger;
import com.nantian.jeda.Constants;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.jeda.util.RequestUtil;
import com.nantian.rept.service.ItemBaseConfService;
import com.nantian.rept.service.ItemConfService;
import com.nantian.rept.vo.RptItemBaseVo;
import com.nantian.rept.vo.SysResrcTransVo;

/**
 * 三级科目配置
 * @author linaWang
 */
@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/itembaseconf")
public class ItemBaseConfController {

	/** 日志输出 */
	final Logger logger = Logger.getLogger(ItemBaseConfController.class);

	/** 领域对象名称 */
	private static final String domain = "ItemBase";

	/** 视图前缀 */
	private static final String viewPrefix = "rept/" + domain + "/" + domain;

	@Autowired
	private ItemBaseConfService itemBaseConfService;
	@Autowired
	private ItemConfService itemConfService;
	
	@Autowired
	private SecurityUtils securityUtils;


	/**
	 * 返回列表页面
	 * @return 列表页面视图名称
	 */
	@RequestMapping(value = "/base_index", method = RequestMethod.GET)
	public String index() {
		return viewPrefix + "_info";
	}

	/**
	 * 分页查询报表信息
	 * @throws Exception 
	 * @throws AxisFault 
	 */
	@RequestMapping(value = "/getItemBaseConfList", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getItemBaseConfList(@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit",  required = false) Integer limit,
			@RequestParam(value = "parent", required = false) String parent,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir, HttpServletRequest request, ModelMap modelMap)
			throws AxisFault, Exception{
		Map<String, Object> params = RequestUtil.getQueryMap(request, itemBaseConfService.fields);
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, itemBaseConfService.getItemBaseConfList(start, limit, sort, dir, params,request));
		modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, itemBaseConfService.countItemBaseConfList(params));
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 返回新建页面
	 */
	@RequestMapping(value = "/create", method  = RequestMethod.GET)
	public String createItemBaseConf(){
		return viewPrefix + "_create";
	}
	
	/**
	 * 保存科目配置数据
	 * @param 
	 * @throws Exception 
	 */
	@RequestMapping(value = "/create", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap createItemBaseConf(@ModelAttribute RptItemBaseVo rptItemBaseVo,ModelMap modelMap) throws Exception{
		 modelMap.clear();
		//获取当前登录用户编号
        String userCode = securityUtils.getUser().getUsername();
        //获取当前时间
        String curTime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());
		Timestamp ts = Timestamp.valueOf(curTime) ;
		//设置属性值
		if(null==rptItemBaseVo.getParent_item_cd()||"".equals(rptItemBaseVo.getParent_item_cd())){
			rptItemBaseVo.setParent_item_cd("NULL");
		}
		rptItemBaseVo.setItem_creator(userCode);
		rptItemBaseVo.setItem_created(ts);
		//保存
		itemBaseConfService.save(rptItemBaseVo);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 返回查看页面
	 */
	@RequestMapping(value = "/view", method = RequestMethod.GET)
	public String viewItemBaseConf() {
		return viewPrefix + "_view";
	}

	/**
	 * 根据ID查询作业相关信息
	 */
	@RequestMapping(value = "/view", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap viewItemBaseConf(@RequestParam(value = "parent_item_cd", required = true) String parent_item_cd, 
			@RequestParam(value = "item_cd", required = true) String item_cd, 
			ModelMap modelMap) throws Exception {
		Map<String,Object> map = new HashMap<String,Object>();
		
		map = itemBaseConfService.getItemBaseConfById(item_cd,parent_item_cd);
		modelMap.addAttribute("data", map);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 返回编辑页面
	 */
	@RequestMapping(value = "/edit", method = RequestMethod.GET)
	public String editItemBaseConf() {
		return viewPrefix + "_edit";
	}

	/**
	 * 更新修改数据
     * @param keys联合主键    主键数组[科目,父科目 ] 
	 */
	@RequestMapping(value = "/edit", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap editItemBaseConf(
			@RequestParam(value = "parent_item_cd", required = true) String parent_item_cd, 
			@RequestParam(value = "item_cd", required = true) String item_cd, 
			@ModelAttribute RptItemBaseVo rptItemBaseVo
			) throws HibernateOptimisticLockingFailureException,Exception {
		ModelMap modelMap = new ModelMap();
		//删除原有数据
		//itemBaseConfService.deleteById(item_cd,parent_item_cd);
		//保存新配置数据        String userCode = securityUtils.getUser().getUsername();
        String curTime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());
		Timestamp ts = Timestamp.valueOf(curTime) ;
		rptItemBaseVo.setItem_modifier(userCode);
		rptItemBaseVo.setItem_modified(ts);
		itemBaseConfService.saveOrupdate(rptItemBaseVo);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 批量删除
	 * @param primaryKeys 主键数组[科目,父科目 ] 
	 */
	@RequestMapping(value = "/delete", method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap deleteJobs(
			@RequestParam(value = "item_cds", required = true) String[] item_cds, 
			@RequestParam(value = "parent_Ids", required = true) String[] parent_Ids,
			ModelMap modelMap){
		itemBaseConfService.deleteByIds(item_cds,parent_Ids);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	

	

	
	/**
	 * 获取lv1store
	 * @param response 
	 * @throws UnsupportedEncodingException 
	 */
	@RequestMapping(value = "/getItemparentCd", method = RequestMethod.POST)
	public @ResponseBody void getItemparentCd(
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
	 * 下载模板文件
	 * @param request
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/downloadxls", method = RequestMethod.GET)
	public String downloadxls(HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		String downpath = System.getProperty("maop.root")+ File.separatorChar+"file"+ File.separatorChar+"itemBaseConf.xls";
		
		modelMap.addAttribute("PATH", downpath);
		//返回servletName
		return "fileView";
	}
	
	/**
	 * 导入 信息

	 * @param request
	 * @param modelMap
	 * @return
	 * @throws Exception 
	 */
	@RequestMapping(value = "/importItemBaseConf", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap importItemBaseConf(
			@RequestParam(value = "filePath", required = true) String filePath,
			HttpServletRequest request, ModelMap modelMap) throws Exception {
		  
		   List<RptItemBaseVo> list= itemBaseConfService.getItemBaseConfList(filePath);
		 
			try {
				
				itemBaseConfService.importItemBaseConfs(list);
				
				modelMap.addAttribute("success", Boolean.TRUE);
			} catch (Exception e) {
				modelMap.addAttribute("success", Boolean.FALSE);
				modelMap.addAttribute("error", e.getMessage());
			}
		 
		return modelMap;
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
	public String servers_excel(HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		// 定义列显示顺序以及列标题
		Map<String, String> columns = new LinkedHashMap<String, String>();
		columns.put("parent_item_cd", "父科目编码");
		columns.put("item_cd", "科目编码");
		columns.put("item_name", "科目名称");
		columns.put("relation_tablename","关联表名");
		columns.put("item_creator", "创建人");
		columns.put("item_created", "创建时间");
		columns.put("item_modifier","修改人");
		columns.put("item_modified","修改时间");
		
		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY, columns);
		List<Map<String,String>> list= (List<Map<String, String>>) request.getSession().getAttribute("ItemBaseConfList");
		
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, list);
		return "excelView";
	}
	//五分钟交易配置------------------------------------------------------------------------------------

	/**
	 * 返回列表页面
	 * @return 列表页面视图名称
	 */
	@RequestMapping(value = "/sysresrctrans_index", method = RequestMethod.GET)
	public String sysresrctrans_index() {
		return  "rept/SysResrcTrans/SysResrcTrans_info";
	}

	

	/**
	 * 返回列表页面
	 * @return 列表页面视图名称
	 */
	@RequestMapping(value = "/SysResrcTrans_create", method = RequestMethod.GET)
	public String sysresrctrans_create() {
		return  "rept/SysResrcTrans/SysResrcTrans_create";
	}
	
	
	/**
	 * 分页查询报表信息
	 * @throws Exception 
	 * @throws AxisFault 
	 */
	@RequestMapping(value = "/getSysResrcTransConfList", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getSysResrcTransConfList(@RequestParam(value = "start", required = false) Integer start,
			@RequestParam(value = "limit",  required = false) Integer limit,
			@RequestParam(value = "parent", required = false) String parent,
			@RequestParam(value = "sort", required = false) String sort,
			@RequestParam(value = "dir", required = false) String dir, HttpServletRequest request, ModelMap modelMap)
			throws AxisFault, Exception{
		Map<String, Object> params = RequestUtil.getQueryMap(request, itemBaseConfService.fields);
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, itemBaseConfService.getResrcTransConfList(start, limit, sort, dir, params));
		modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, itemBaseConfService.countResrcTransConfList(params));
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	
	
	/**
	 * 获取交易名称
	 * @param aplCode 系统代码
	 * @param response 
	 * @throws UnsupportedEncodingException 
	 */
	@RequestMapping(value = "/getTransName", method = RequestMethod.GET)
	public @ResponseBody void getTransName(
			@RequestParam(value = "aplCode", required = true) String aplCode,
			HttpServletResponse response) throws UnsupportedEncodingException{
		JSONArray json = new JSONArray();
		PrintWriter out = null;
		
		try{
			List<Map<String, Object>> list = itemBaseConfService.getTransName(aplCode);
			
			
			
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
	 * 获取服务器编码
	 * @param aplCode 系统代码
	 *  * @param srvType 系统代码
	 * @param response 
	 * @throws UnsupportedEncodingException 
	 */
	@RequestMapping(value = "/getsrvCode", method = RequestMethod.GET)
	public @ResponseBody void getsrvCode(
			@RequestParam(value = "aplCode", required = true) String aplCode,
			@RequestParam(value = "srvType", required = true) String srvType,
			
			HttpServletResponse response) throws UnsupportedEncodingException{
		JSONArray json = new JSONArray();
		PrintWriter out = null;
		
		try{
			List<Map<String, Object>> list = itemBaseConfService.getsrvCode(aplCode,srvType);
			
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
	 * 批量删除
	 * @throws UnsupportedEncodingException 
	 *  
	 */
	@RequestMapping(value = "/SysResrcTrans_delete", method = RequestMethod.DELETE)
	public @ResponseBody
	ModelMap SysResrcTrans_delete(
			@RequestParam(value = "APL_CODES", required = true) String[] APL_CODES, 
			@RequestParam(value = "TRAN_NAMES", required = true) String[] TRAN_NAMES,
			@RequestParam(value = "SRV_TYPES", required = true) String[] SRV_TYPES,
			@RequestParam(value = "SRV_CODES", required = true) String[] SRV_CODES,
			ModelMap modelMap) throws UnsupportedEncodingException{
		
		itemBaseConfService.deleteBySysResrcTrans(APL_CODES,TRAN_NAMES,SRV_TYPES,SRV_CODES);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	
	/**
	 * 保存科目配置数据
	 * @param 
	 * @throws Exception 
	 */
	@RequestMapping(value = "/SysResrcTransConf_create", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap SysResrcTransConf_create(@ModelAttribute SysResrcTransVo sysResrcTransVo) throws Exception{
		ModelMap modelMap = new ModelMap();
		String [] srv_codes= sysResrcTransVo.getSrvCode().toString().split(",");
		List <SysResrcTransVo> list= new ArrayList<SysResrcTransVo>();
		for(int i=0;i<srv_codes.length;i++){
			SysResrcTransVo vo =new SysResrcTransVo();
			vo.setAplCode(sysResrcTransVo.getAplCode());
			vo.setSrvCode(srv_codes[i]);
			vo.setSrvType(sysResrcTransVo.getSrvType());
			vo.setTranName(sysResrcTransVo.getTranName());
			list.add(vo);
		}
		//设置属性值
		itemBaseConfService.saveSysResrcTrans(list);
		modelMap.addAttribute("success", Boolean.TRUE);
		return modelMap;
	}
	



}
