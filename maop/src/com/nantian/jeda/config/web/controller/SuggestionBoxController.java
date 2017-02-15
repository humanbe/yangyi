package com.nantian.jeda.config.web.controller;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nantian.jeda.Constants;
import com.nantian.jeda.ErrorCode;
import com.nantian.jeda.JEDAException;
import com.nantian.jeda.common.model.Property;
import com.nantian.jeda.config.service.SBoxService;
import com.nantian.jeda.config.vo.sboxInfoVo;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.jeda.util.RequestUtil;

/**
 * @author zhanghui
 * 
 */
@Controller
@RequestMapping("/" + Constants.FRAMEWORK_REQUEST_PATH + "/config/sbox")
public class SuggestionBoxController {
	
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(SuggestionBoxController.class);

	/** 领域对象名称 */
	private String domain = Property.class.getSimpleName().toLowerCase();

	/** 视图前缀 */
	private String viewPrefix = Constants.FRAMEWORK_REQUEST_PATH + "/config/" + domain + "/sbox_";
	/** 服务 */
	@Autowired
	private SBoxService sboxService;

	@Autowired
    private SecurityUtils securityUtils; 
	
	
	/** 
	 * 返回意见箱信息主界面
	 * */
	@RequestMapping(value = "/sboxInfo", method = RequestMethod.GET)
	public String portlet_sbox(ModelMap modelMap) throws JEDAException {
		return viewPrefix + "showInfo";
	}
	
	/** 
	 * 返回添加意见主界面
	 * */
	@RequestMapping(value = "/addSuggestion", method = RequestMethod.GET)
	public String sbox_addSuggesion(ModelMap modelMap) throws JEDAException {
		return viewPrefix + "addSuggestion";
	}
	
	/** 
	 * 返回所选意见信息主界面
	 * */
	@RequestMapping(value = "/showSelectedSuggestion", method = RequestMethod.GET)
	public String sbox_showSelectedSuggesion(ModelMap modelMap) throws JEDAException {
		return viewPrefix + "view";
	}
	
	/**
	 * 根据分页、排序和其他条件查询记录.
	 * 
	 * @param start
	 *            起始记录行

	 * @param limit
	 *            查询记录数

	 * @param sort
	 *            排序字段
	 * @param dir
	 *            排序方向
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 * @throws SQLException 
	 */

	@RequestMapping(value = "/getSboxInfo", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap findServerIp(
			@RequestParam(value = "start", required = false, defaultValue = Constants.DEFAULT_PAGE_START) Integer start,
			@RequestParam(value = "limit", required = false, defaultValue = Constants.DEFAULT_PAGE_SIZE) Integer limit,
			@RequestParam(value = "sort", required = false, defaultValue = Constants.DEFAULT_SORT_FIELD) String sort,
			@RequestParam(value = "dir", required = false, defaultValue = Constants.DEFAULT_SORT_DIRECTION) String dir,
			HttpServletRequest request, ModelMap modelMap) throws JEDAException, SQLException {
		Map<String, Object> params = RequestUtil.getQueryMap(request,
				sboxService.fields);
		try {
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, sboxService.querySBoxInfo(start,
					limit, sort, dir, params,request));
			modelMap.addAttribute(Constants.DEFAULT_COUNT_MODEL_KEY, sboxService.count(params));
			modelMap.addAttribute("success", Boolean.TRUE);			
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
		}
		return modelMap;
	}
	
	/**
	 * 保存新建数据
	 * 
	 * @param sboxInfoVo 数据对象
	 * @return
	 * @throws Exception 
	 */
	@RequestMapping(value = "/suggestionAdd", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap fieldtypeEdit(@ModelAttribute  sboxInfoVo sboxInfo,
			ModelMap modelMap) throws Exception {
		modelMap.clear();
		try {
		String createUser =securityUtils.getUser().getUsername();
		Date startDate = new Date();
		Timestamp updateTime = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate));
		sboxInfo.setSbox_initiator(createUser);
		sboxInfo.setSbox_time(updateTime);
		sboxInfo.setSbox_statenum("1");
		sboxService.save(sboxInfo);
		modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success",Boolean.FALSE);
		}
		return modelMap;
	}
	/**
	 * 根据意见编号，获取相应信息列表
	 * @param sbox_id
	 *         意见编号
	 * @param modelMap
	 * @param request
	 * @return 
	 * @throws JEDAException 
	 */
	@RequestMapping(value = "/view", method = RequestMethod.GET)
	public @ResponseBody
	ModelMap view(@RequestParam("sbox_id") Integer sbox_id,
			ModelMap modelMap,
			HttpServletRequest request) throws JEDAException {
		try {
			modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY,sboxService.queryAllSBoxInfo(sbox_id));
			modelMap.addAttribute("success", Boolean.TRUE);
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("error", ErrorCode.UNCAUGHT_EXCEPTION);
		}
		return modelMap;
	}
	
	/**
	 * 批量修改意见状态
	 * 
	 * @param sbox_ids
	 * @param state_id
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 * @throws SQLException 
	 */
	@RequestMapping(value = "/editState", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap editState(
			@RequestParam(value = "sbox_ids", required = true) String[] sbox_ids,
			@RequestParam("state_id") String state_id,
			ModelMap modelMap1) throws JEDAException, SQLException {
		    String user =securityUtils.getUser().getUsername();
		    Date startDate = new Date();
		    Timestamp updateTime = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate));
		    sboxService.sboxState(sbox_ids,state_id,updateTime,user);
			modelMap1.addAttribute("success", Boolean.TRUE);
		    return modelMap1;
	}
	
	
	/**
	 * 导出查询服务器结果到excel文件
	 * @param request
	 * @param modelMap
	 * @return
	 * @throws JEDAException
	 */
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/sbox_excel", method = RequestMethod.GET)
	public String sbox_excel(HttpServletRequest request, ModelMap modelMap) throws JEDAException {
		// 定义列显示顺序以及列标题
		Map<String, String> columns = new LinkedHashMap<String, String>();
		columns.put("sbox_value", "意见内容");
		columns.put("sbox_initiator", "意见发起人");
		columns.put("sbox_time", "意见提出时间");
		columns.put("sbox_statenum", "意见状态");
		columns.put("sbox_confirm_user","意见确认人");
		columns.put("sbox_confirm_time", "意见确认时间");
		columns.put("sbox_reject_user","意见驳回人");
		columns.put("sbox_reject_time","意见驳回时间");
		
		modelMap.addAttribute(Constants.DEFAULT_EXCEL_COLUMNS_MODEL_KEY, columns);
		List<Map<String,String>> list= (List<Map<String, String>>) request.getSession().getAttribute("sboxInfoListExport");
		
		modelMap.addAttribute(Constants.DEFAULT_RECORD_MODEL_KEY, list);
		return "excelView";
	}
}
