package com.nantian.jedarpt.service;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.Serializable;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import net.sf.json.JSONArray;

import org.apache.log4j.Logger;
import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.support.DefaultMultipartHttpServletRequest;

import com.nantian.common.util.ComUtil;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.common.model.Menu;
import com.nantian.jeda.common.model.User;
import com.nantian.jeda.security.service.MenuService;
import com.nantian.jeda.security.service.UserService;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.jedarpt.vo.JedaColumnVo;
import com.nantian.jedarpt.vo.JedaExcelTemplateVo;
import com.nantian.jedarpt.vo.JedaReportColumnVo;
import com.nantian.jedarpt.vo.JedaReportMenuVo;
import com.nantian.jedarpt.vo.JedaReportParamVo;
import com.nantian.jedarpt.vo.JedaReportRoleVo;
import com.nantian.jedarpt.vo.JedaReportRuleVo;
import com.nantian.jedarpt.vo.JedaReportVo;
import com.nantian.jedarpt.vo.JedaRuleVo;

/**
 * 报表定制service
 * @author linaWang
 *
 */
@Service
@Repository
@Transactional
public class ReportDesignService {
	/** 日志输出 */
	final Logger logger = Logger.getLogger(ReportShowService.class);

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();

	/** HIBERNATE Session Factory */
	@Autowired
	private SessionFactory sessionFactoryMaopRpt;
	@Autowired
	private MessageSourceAccessor messages;
	
	@Autowired
	private SecurityUtils securityUtils; 
	@Autowired
	private MenuService menuService; 
	@Autowired
	private UserService userService; 
	@Autowired
	private ReportShowService reportShowService;
	
	public Session getSession() {
		return sessionFactoryMaopRpt.getCurrentSession();
	}
	
	private static boolean isWindows = false;
	private static String osName = null;
	static {
		osName = System.getProperty("os.name");
		System.getProperty("sun.jnu.encoding");
		if (osName.toUpperCase().startsWith("WINDOWS")) {
			isWindows = true;
		}
	}
	
	/**
	 * 构造方法	 */
	public ReportDesignService() {
		fields.put("report_code", FieldType.INTEGER);
		fields.put("report_type", FieldType.STRING);
		fields.put("report_name", FieldType.STRING);
		fields.put("report_desc", FieldType.STRING);
		fields.put("report_sql", FieldType.STRING);
		fields.put("creator", FieldType.STRING);
		fields.put("created", FieldType.DATE);
		fields.put("modifier", FieldType.STRING);
		fields.put("modified", FieldType.DATE);
	}
	
	
	/**
	 * 获取未删除的报表规则
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<Map<String, Object>> getRules(String reportCode){
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(");
 		hql.append(" t.rule_code as rule_code,");
 		hql.append(" t.rule_en_name as rule_en_name,");
 		hql.append(" t.rule_ch_name as rule_ch_name,");
 		hql.append(" t.rule_desc as rule_desc,");
 		hql.append(" t.rule_content as rule_content,");
 		hql.append(" t.creator as creator,");
 		hql.append(" to_char(t.created,'yyyy-MM-dd hh24:mi:ss') as created,");
 		hql.append(" t.modifier as modifier,");
 		hql.append(" to_char(t.modified,'yyyy-MM-dd hh24:mi:ss') as modified,");
 		hql.append(" t.delete_flag as delete_flag");
 		if(reportCode!=null && !reportCode.equals("")){
 			hql.append(",");
 			hql.append(" (case when (select count(*)");
 			hql.append(" from JedaReportRuleVo rr");
 			hql.append(" where t.rule_code = rr.rule_code and rr.report_code=?) > 0 then true else false end) as checked ");
		}
		hql.append(" ) from JedaRuleVo t ");
		hql.append(" where t.delete_flag='0'");
		hql.append(" order by t.rule_code desc ");
 		logger.info(hql.toString());
 		Query query = getSession().createQuery(hql.toString());
 		if(reportCode!=null && !reportCode.equals("")){
			query = query.setInteger(0, Integer.valueOf(reportCode));
		}
 		return query.list();
	}
	
	
	/**
	 * 获取所有报表编号
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<String> getReportCodes(){
		StringBuilder sql = new StringBuilder();
		sql.append("select distinct t.report_code from jeda_report t ");
		return getSession().createSQLQuery(sql.toString()).list();
	}
	
	/**
	 * 保存报表基本信息
	 * @return 
	 */
	@Transactional
	public int saveJedaReport(JedaReportVo jedaReport) {
		return (Integer) getSession().save(jedaReport);
	}
	
	/**
	 * 修改报表基本信息
	 */
	@Transactional
	public void updateJedaRptInfo(JedaReportVo jedaReportVo) {
		getSession().update(jedaReportVo);
	}
	
	/**
	 * 删除报表，删除标示置1
	 */
	@Transactional
	public void deleteJedaRptById(int reportCode) {
		//获取当前登录用户编号
        String userCode = securityUtils.getUser().getUsername();
        String curTime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());
		Timestamp ts = Timestamp.valueOf(curTime) ;
		StringBuilder hql = new StringBuilder();
		hql.append("update JedaReportVo t set t.delete_flag='1', t.modifier=?, t.modified=? where t.report_code=? ");
		Query query = getSession().createQuery(hql.toString())
				.setString(0, userCode)
				.setTimestamp(1, ts)
				.setInteger(2, reportCode);
		query.executeUpdate();
	}
	
	/**
	 * 根据主键查询报表信息
	 * @param reportCode 报表编号
	 * @return
	 */
	public Object getJedaReportById(Serializable reportCode) {
		return getSession().get(JedaReportVo.class, reportCode);
	}
	
	/**
	 * 保存报表模板信息
	 */
	@Transactional
	public int saveExcelTemplate(JedaExcelTemplateVo jedaExcelTemplate) {
		return (Integer) getSession().save(jedaExcelTemplate);
	}
	
	/**
	 * 修改报表模板信息
	 */
	@Transactional
	public void updateExcelTemplate(JedaExcelTemplateVo jedaExcelTemplateVo) {
		getSession().update(jedaExcelTemplateVo);
	}
	
	/**
	 * 删除报表关联模板
	 */
	@Transactional
	public void deleteExcelTemplate(int reportCode) {
		StringBuilder hql = new StringBuilder();
		hql.append("delete from JedaExcelTemplateVo t where t.report_code=? ");
		Query query = getSession().createQuery(hql.toString()).setInteger(0, reportCode);
		query.executeUpdate();
	}
	
	/**
	 * 保存报表菜单信息
	 */
	@Transactional
	public void saveReportMenu(JedaReportMenuVo jedaReportMenu) {
		getSession().save(jedaReportMenu);
	}
	
	/**
	 * 删除报表菜单信息
	 */
	@Transactional
	public void deleteReportMenuByReportCode(int reportCode) {
		StringBuilder hql = new StringBuilder();
		hql.append("delete from JedaReportMenuVo t where t.report_code=? ");
		Query query = getSession().createQuery(hql.toString()).setInteger(0, reportCode);
		query.executeUpdate();
	}
	
	/**
	 * 保存字段信息
	 */
	@Transactional
	public int saveJedaColumn(JedaColumnVo jedaColumn) {
		return (Integer) getSession().save(jedaColumn);
	}
	
	/**
	 * 根据主键查询字段信息
	 * @param reportCode 报表编号
	 * @return
	 */
	public Object getJedaColumnById(Serializable columnCode) {
		return getSession().get(JedaColumnVo.class, columnCode);
	}
	
	/**
	 * 修改字段信息
	 */
	@Transactional
	public void updateJedaColumn(JedaColumnVo jedaColumn) {
		getSession().update(jedaColumn);
	}
	
	/**
	 * 保存报表关联字段信息
	 */
	@Transactional
	public void saveReportColumn(JedaReportColumnVo jedaReportColumn) {
		getSession().save(jedaReportColumn);
	}
	
	/**
	 * 删除报表关联字段信息
	 */
	@Transactional
	public void deleteReportColumnByReportCode(int reportCode) {
		StringBuilder hql = new StringBuilder();
		hql.append("delete from JedaReportColumnVo t where t.report_code=? ");
		Query query = getSession().createQuery(hql.toString()).setInteger(0, reportCode);
		query.executeUpdate();
	}
	
	/**
	 * 保存报表关联参数信息
	 */
	@Transactional
	public void saveRepportParam(JedaReportParamVo jedaReportParam) {
		getSession().save(jedaReportParam);
	}
	
	/**
	 * 删除报表关联参数(删除标示置1)
	 */
	@Transactional
	public void updateRepportParamByReportCode(int reportCode) {
		StringBuilder hql = new StringBuilder();
		hql.append("update JedaReportParamVo t set t.delete_flag='1' where t.report_code=? ");
		Query query = getSession().createQuery(hql.toString()).setInteger(0, reportCode);
		query.executeUpdate();
	}
	
	/**
	 * 删除报表关联参数
	 */
	@Transactional
	public void deleteRepportParamByReportCode(int reportCode) {
		StringBuilder hql = new StringBuilder();
		hql.append("delete from JedaReportParamVo t where t.report_code=? ");
		Query query = getSession().createQuery(hql.toString()).setInteger(0, reportCode);
		query.executeUpdate();
	}
	
	/**
	 * 保存报表关联角色信息
	 */
	@Transactional
	public void saveReportRole(JedaReportRoleVo jedaReportRole) {
		getSession().save(jedaReportRole);
	}
	
	/**
	 * 删除报表关联角色
	 */
	@Transactional
	public void deleteReportRoleByReportCode(int reportCode) {
		StringBuilder hql = new StringBuilder();
		hql.append("delete from JedaReportRoleVo t where t.report_code=? ");
		Query query = getSession().createQuery(hql.toString()).setInteger(0, reportCode);
		query.executeUpdate();
	}
	
	/**
	 * 保存规则信息
	 */
	@Transactional
	public void saveJedaRule(JedaRuleVo jedaRule) {
		getSession().save(jedaRule);
	}
	
	/**
	 * 保存报表关联规则信息
	 */
	@Transactional
	public void saveReportRule(JedaReportRuleVo jedaReportRule) {
		getSession().save(jedaReportRule);
	}
	
	/**
	 * 删除报表关联规则
	 */
	@Transactional
	public void deleteReportRuleByReportCode(int reportCode) {
		StringBuilder hql = new StringBuilder();
		hql.append("delete from JedaReportRuleVo t where t.report_code=? ");
		Query query = getSession().createQuery(hql.toString()).setInteger(0, reportCode);
		query.executeUpdate();
	}
	
	/**
	 * 保存新定制报表信息
	 * @param jedaReportVo 报表实例
	 * @param jedaExcelTemplateVo 报表模板关联实例
	 * @param jedaReportMenuVo 报表菜单关联实例
	 * @param params 报表参数对象
	 * @param columns 报表字段对象
	 * @param rules 报表关联的规则编号数组
	 * @param roles 报表关联的角色编码数组
	 * @return
	 * @throws IOException 
	 */
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = SQLException.class, propagation = Propagation.REQUIRED, value = "maoprpt")
	public void createJedaRpt(JedaReportVo jedaReportVo,JedaExcelTemplateVo jedaExcelTemplateVo,JedaReportMenuVo jedaReportMenuVo,
			String params,String columns,String rules,String roles,HttpServletRequest request) throws IOException{
		//获取当前登录用户编号
        String userCode = securityUtils.getUser().getUsername();
        String curTime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());
		Timestamp ts = Timestamp.valueOf(curTime) ;
		
		//报表参数实体列表
		List<Map<String, Object>> listParams = null ;
		JedaReportParamVo jedaReportParamVo = null;
		//报表字段实体列表
		List<Map<String, Object>> listColumns = null ;
		JedaReportColumnVo jedaReportColumnVo = null;
		
        //保存报表基本信息
        jedaReportVo.setDelete_flag("0") ; //未删除
        jedaReportVo.setCreator(userCode);
        jedaReportVo.setCreated(ts);
        jedaReportVo.setModifier(userCode);
        jedaReportVo.setModified(ts);
        int reportCode= saveJedaReport(jedaReportVo); //报表编号
        //保存报表参数信息
        if(params!=null && !params.equals("")){
			JSONArray arrayParams = JSONArray.fromObject(params);
			//将json格式的数据转换成list对象
			listParams = (List<Map<String, Object>>) JSONArray.toCollection(arrayParams, Map.class);
			for(int t=0 ; t<listParams.size() ; t++){
				Map<String, Object> map = listParams.get(t);
				jedaReportParamVo = new JedaReportParamVo();
				jedaReportParamVo.setReport_code(reportCode);
				jedaReportParamVo.setParam_en_name(ComUtil.checkJSONNull(map.get("param_en_name")));
				jedaReportParamVo.setParam_ch_name(ComUtil.checkJSONNull(map.get("param_ch_name")));
				jedaReportParamVo.setParam_type(ComUtil.checkJSONNull(map.get("param_type")));
				if(map.get("default_value")!=null && !map.get("default_value").equals("")){
					jedaReportParamVo.setDefault_value(ComUtil.checkJSONNull(map.get("default_value")));
				}else{
					jedaReportParamVo.setDefault_value("");
				}
				if(map.get("dic_code")!=null && !map.get("dic_code").equals("")){
					jedaReportParamVo.setDic_code(ComUtil.checkJSONNull(map.get("dic_code")));
				}else{
					jedaReportParamVo.setDic_code("");
				}
				jedaReportParamVo.setDelete_flag("0");
				saveRepportParam(jedaReportParamVo);
			}
		}
        //保存报表字段信息
        if(columns!=null && !columns.equals("")){
			JSONArray arrayColumns = JSONArray.fromObject(columns);
			//将json格式的数据转换成list对象
			listColumns = (List<Map<String, Object>>) JSONArray.toCollection(arrayColumns, Map.class);
			for(int t=0 ; t<listColumns.size() ; t++){
				Map<String, Object> map = listColumns.get(t);
				String columnName = ComUtil.checkJSONNull(map.get("column_en_name")); //字段名称
				//保存字段公共信息
				int columnCode = saveOrUpdateJedaColumn(columnName,map);
				//保存报表字段关联信息
				jedaReportColumnVo = new JedaReportColumnVo();
				jedaReportColumnVo.setReport_code(reportCode);
				jedaReportColumnVo.setColumn_code(columnCode);
				if(map.get("column_width")!=null && !map.get("column_width").equals("") && !map.get("column_width").equals("自动")){
					jedaReportColumnVo.setColumn_width(ComUtil.checkJSONNull(map.get("column_width")));
				}else{
					jedaReportColumnVo.setColumn_width("");
				}
				jedaReportColumnVo.setIs_visible(ComUtil.checkJSONNull(map.get("is_visible")));
				if(map.get("column_sort")!=null && !map.get("column_sort").equals("")){
					jedaReportColumnVo.setColumn_sort(ComUtil.checkJSONNull(map.get("column_sort")));
				}else{
					jedaReportColumnVo.setColumn_sort("");
				}
				saveReportColumn(jedaReportColumnVo);
			}
		}
        //保存报表模板信息
        if(jedaExcelTemplateVo.getTemplate_en_name()!=null && !jedaExcelTemplateVo.getTemplate_en_name().equals("")){
        	jedaExcelTemplateVo.setReport_code(reportCode);
            jedaExcelTemplateVo.setDelete_flag("0");
            int templateCode = saveExcelTemplate(jedaExcelTemplateVo);
            //上传报表模板文件
            fileUpload(templateCode,request);
        }
        
        //保存报表规则信息
        String[] ruleCodes = null;
        if(rules!=null && !rules.equals("")){
        	JedaReportRuleVo JedaReportRuleVo = null ;
        	ruleCodes = rules.split(",");
        	for(int t=0 ; t<ruleCodes.length ; t++){
        		JedaReportRuleVo = new JedaReportRuleVo();
        		JedaReportRuleVo.setReport_code(reportCode);
        		JedaReportRuleVo.setRule_code(Integer.valueOf(ruleCodes[t]));
        		saveReportRule(JedaReportRuleVo);
        	}
        }
        
        //新建功能菜单
        Menu menu = new Menu();
        menu.setId(String.valueOf(reportCode));
        menu.setParent((Menu) menuService.get(jedaReportMenuVo.getParent_menu()));
        menu.setName(jedaReportVo.getReport_name());
        String url = "flash/jedarptshow/index?ID=";
        menu.setUrl(url.concat(String.valueOf(reportCode)));
        menu.setIcon("checkReport");
        menu.setCreator((User) userService.get(userCode));
        menu.setCreated(ts);
        menu.setModifier((User) userService.get(userCode));
        menu.setModified(ts);
        menuService.save(menu);
        
        //保存报表菜单与父级菜单关系
        if(jedaReportMenuVo.getParent_menu()!=null && !jedaReportMenuVo.getParent_menu().equals("")){
	        jedaReportMenuVo.setReport_code(reportCode);
	        saveReportMenu(jedaReportMenuVo);
        }
        
        //保存报表角色信息
        String[] roleCodes = null;
        if(roles!=null && !roles.equals("")){
        	JedaReportRoleVo JedaReportRoleVo = null ;
        	roleCodes = roles.split(",");
        	for(int t=0 ; t<roleCodes.length ; t++){
        		JedaReportRoleVo = new JedaReportRoleVo();
        		JedaReportRoleVo.setReport_code(reportCode);
        		JedaReportRoleVo.setRole_code(roleCodes[t]);
        		saveReportRole(JedaReportRoleVo);
        		//报表授权
        		menuService.addRoleMenu(roleCodes[t],String.valueOf(reportCode));
        	}
        }
	}
	
	
	/**
	 * 保存新定制报表信息
	 * @param jedaReportVo 报表实例
	 * @param jedaExcelTemplateVo 报表模板关联实例
	 * @param jedaReportMenuVo 报表菜单关联实例
	 * @param params 报表参数对象
	 * @param columns 报表字段对象
	 * @param rules 报表关联的规则编号数组
	 * @param roles 报表关联的角色编码数组
	 * @return
	 * @throws IOException 
	 */
	@SuppressWarnings("unchecked")
	@Transactional(rollbackFor = SQLException.class, propagation = Propagation.REQUIRED, value = "maoprpt")
	public void editJedaRpt(JedaReportVo jedaReportVo,JedaExcelTemplateVo jedaExcelTemplateVo,JedaReportMenuVo jedaReportMenuVo,
			String params,String columns,String rules,String roles,HttpServletRequest request) throws IOException{
		//获取当前登录用户编号
        String userCode = securityUtils.getUser().getUsername();
        String curTime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());
		Timestamp ts = Timestamp.valueOf(curTime) ;
		
		//报表参数实体列表
		List<Map<String, Object>> listParams = null ;
		JedaReportParamVo jedaReportParamVo = null;
		//报表字段实体列表
		List<Map<String, Object>> listColumns = null ;
		JedaReportColumnVo jedaReportColumnVo = null;
		
		//修改报表基本信息
		JedaReportVo jedaReport  = (JedaReportVo) getJedaReportById(jedaReportVo.getReport_code());
		jedaReport.setReport_name(jedaReportVo.getReport_name());
		jedaReport.setReport_desc(jedaReportVo.getReport_desc());
		jedaReport.setReport_type(jedaReportVo.getReport_type());
		jedaReport.setReport_sql(jedaReportVo.getReport_sql());
		jedaReport.setModifier(userCode);
		jedaReport.setModified(ts);
        updateJedaRptInfo(jedaReport); 
        int reportCode = jedaReportVo.getReport_code();
        //删除报表关联参数（删除）
        this.deleteRepportParamByReportCode(reportCode);
        //保存报表参数信息
        if(params!=null && !params.equals("")){
			JSONArray arrayParams = JSONArray.fromObject(params);
			//将json格式的数据转换成list对象
			listParams = (List<Map<String, Object>>) JSONArray.toCollection(arrayParams, Map.class);
			for(int t=0 ; t<listParams.size() ; t++){
				Map<String, Object> map = listParams.get(t);
				jedaReportParamVo = new JedaReportParamVo();
				jedaReportParamVo.setReport_code(reportCode);
				jedaReportParamVo.setParam_en_name(ComUtil.checkJSONNull(map.get("param_en_name")));
				jedaReportParamVo.setParam_ch_name(ComUtil.checkJSONNull(map.get("param_ch_name")));
				jedaReportParamVo.setParam_type(ComUtil.checkJSONNull(map.get("param_type")));
				if(map.get("default_value")!=null && !map.get("default_value").equals("")){
					jedaReportParamVo.setDefault_value(ComUtil.checkJSONNull(map.get("default_value")));
				}else{
					jedaReportParamVo.setDefault_value("");
				}
				if(map.get("dic_code")!=null && !map.get("dic_code").equals("")){
					jedaReportParamVo.setDic_code(ComUtil.checkJSONNull(map.get("dic_code")));
				}else{
					jedaReportParamVo.setDic_code("");
				}
				jedaReportParamVo.setDelete_flag("0");
				saveRepportParam(jedaReportParamVo);
			}
		}
        //删除报表关联字段
        this.deleteReportColumnByReportCode(reportCode);
        //保存报表字段信息
        if(columns!=null && !columns.equals("")){
			JSONArray arrayColumns = JSONArray.fromObject(columns);
			//将json格式的数据转换成list对象
			listColumns = (List<Map<String, Object>>) JSONArray.toCollection(arrayColumns, Map.class);
			for(int t=0 ; t<listColumns.size() ; t++){
				Map<String, Object> map = listColumns.get(t);
				//字段名称
				String columnName = ComUtil.checkJSONNull(map.get("column_en_name")); 
				//保存字段公共信息
				int columnCode = saveOrUpdateJedaColumn(columnName,map);
				//保存报表字段关联信息
				jedaReportColumnVo = new JedaReportColumnVo();
				jedaReportColumnVo.setReport_code(reportCode);
				jedaReportColumnVo.setColumn_code(columnCode);
				if(map.get("column_width")!=null && !map.get("column_width").equals("") && !map.get("column_width").equals("自动")){
					jedaReportColumnVo.setColumn_width(ComUtil.checkJSONNull(map.get("column_width")));
				}else{
					jedaReportColumnVo.setColumn_width("");
				}
				jedaReportColumnVo.setIs_visible(ComUtil.checkJSONNull(map.get("is_visible")));
				if(map.get("column_sort")!=null && !map.get("column_sort").equals("")){
					jedaReportColumnVo.setColumn_sort(ComUtil.checkJSONNull(map.get("column_sort")));
				}else{
					jedaReportColumnVo.setColumn_sort("");
				}
				saveReportColumn(jedaReportColumnVo);
			}
		}
        
        //修改报表模板信息
        Map<String, String> template = reportShowService.getTemplateByReportCode(reportCode);
        if(template!=null){
        	if(jedaExcelTemplateVo.getTemplate_en_name()!=null && !jedaExcelTemplateVo.getTemplate_en_name().equals("")){
            	String templateCode = String.valueOf(template.get("template_code"));
            	jedaExcelTemplateVo.setReport_code(reportCode);
            	jedaExcelTemplateVo.setTemplate_code(Integer.valueOf(templateCode));
                jedaExcelTemplateVo.setDelete_flag("0");
                updateExcelTemplate(jedaExcelTemplateVo);
            	//上传报表模板文件
                fileUpload(Integer.valueOf(templateCode),request);
            }
        }else{ //保存报表模板信息
            if(jedaExcelTemplateVo.getTemplate_en_name()!=null && !jedaExcelTemplateVo.getTemplate_en_name().equals("")){
            	jedaExcelTemplateVo.setReport_code(reportCode);
                jedaExcelTemplateVo.setDelete_flag("0");
                int templateCode = saveExcelTemplate(jedaExcelTemplateVo);
                //上传报表模板文件
                fileUpload(templateCode,request);
            }
        }
        //删除报表关联规则
        this.deleteReportRuleByReportCode(reportCode);
        //保存报表规则信息
        String[] ruleCodes = null;
        if(rules!=null && !rules.equals("")){
        	JedaReportRuleVo JedaReportRuleVo = null ;
        	ruleCodes = rules.split(",");
        	for(int t=0 ; t<ruleCodes.length ; t++){
        		JedaReportRuleVo = new JedaReportRuleVo();
        		JedaReportRuleVo.setReport_code(reportCode);
        		JedaReportRuleVo.setRule_code(Integer.valueOf(ruleCodes[t]));
        		saveReportRule(JedaReportRuleVo);
        	}
        }
        
        //修改功能菜单
        Menu menu = (Menu)menuService.get(String.valueOf(reportCode));
        menu.setName(jedaReportVo.getReport_name());
        menu.setParent((Menu) menuService.get(jedaReportMenuVo.getParent_menu()));
        menu.setModifier((User) userService.get(userCode));
        menu.setModified(ts);
        menuService.update(menu);
        
        //修改报表菜单与父级菜单关系
        this.deleteReportMenuByReportCode(reportCode);
        if(jedaReportMenuVo.getParent_menu()!=null && !jedaReportMenuVo.getParent_menu().equals("")){
	        jedaReportMenuVo.setReport_code(reportCode);
	        saveReportMenu(jedaReportMenuVo);
        }
        
        //删除报表关联角色
        this.deleteReportRoleByReportCode(reportCode);
        //删除jeda角色菜单关联信息
        menuService.deleteRoleMenu(String.valueOf(reportCode));
        //保存报表角色信息
        String[] roleCodes = null;
        if(roles!=null && !roles.equals("")){
        	JedaReportRoleVo JedaReportRoleVo = null ;
        	roleCodes = roles.split(",");
        	for(int t=0 ; t<roleCodes.length ; t++){
        		JedaReportRoleVo = new JedaReportRoleVo();
        		JedaReportRoleVo.setReport_code(reportCode);
        		JedaReportRoleVo.setRole_code(roleCodes[t]);
        		saveReportRole(JedaReportRoleVo);
        		//报表授权
        		menuService.addRoleMenu(roleCodes[t],String.valueOf(reportCode));
        	}
        }
	}
	
	/**
	 * 上传报表模板
	 * @param templateCode 模板编号
	 * @param request
	 * @throws IOException
	 */
	public void fileUpload(int templateCode,HttpServletRequest request) throws IOException{
		//上传路径
		String path = null;
		//包含文件名称的全路径
		String uploadPath = null;
		if(isWindows){
			path=messages.getMessage("jedarpt.templatePathForWin").concat(File.separator);
		}else{
			path=messages.getMessage("jedarpt.templatePathForLinux").concat(File.separator);
		}
		DefaultMultipartHttpServletRequest multipartRequest = (DefaultMultipartHttpServletRequest) request;
		Iterator<?> fileNames = multipartRequest.getFileNames();
		String fileTxt = ""; //上传文件名称
		MultipartFile multiFile = null;
		if (fileNames.hasNext()) {
			String fileName = (String) fileNames.next();
			multiFile = multipartRequest.getFile(fileName);
			if ("UTF-8".equalsIgnoreCase(ComUtil.charset)) {
				fileTxt = multiFile.getOriginalFilename();
			} else {
				fileTxt = new String(multiFile.getOriginalFilename().getBytes("GBK"), ComUtil.charset);
			}
			if (fileTxt.length() > 0) {
				String[] nameAndType = fileTxt.split("\\.");
				//文件重命名： 上传文件名称_模板编号
				//uploadPath = path + File.separatorChar+ nameAndType[0] + "_" + String.valueOf(templateCode)+ "." + nameAndType[1];*/
				//文件重命名： 模板编号
				uploadPath = path + File.separatorChar+ String.valueOf(templateCode)+ "." + nameAndType[1];
				
				InputStream in = null;
				FileOutputStream out = null;
				int len = 0;
				File outDir = new File(path);
				logger.info("Template Path : "+outDir);
				if (!outDir.exists()) {
					outDir.mkdirs();
				}
				/*//删除目录下的所有文件
				 for (File tmpFile : outDir.listFiles()) {
					tmpFile.delete();
				}*/
				in = multiFile.getInputStream();
				out = new FileOutputStream(uploadPath);
				byte[] buf = new byte[1024];
				while ((len = in.read(buf)) != -1) {
					out.write(buf, 0, len);
				}
				if (in != null) {
					in.close();
				}
				if (out != null) {
					out.flush();
					out.close();
				}
			}
		}
	}
	
	/**
	 * 获取报表详细信息 (未删除报表)
	 * @param reportCode 报表编号
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<Map<String, String>> getReportInfoList(Integer start, Integer limit, String sort, String dir,
			Map<String, Object> params){
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
 		hql.append(" t.report_code as report_code,");
 		hql.append(" t.report_type as report_type,");
 		hql.append(" t.report_name as report_name,");
 		hql.append(" t.report_desc as report_desc,");
 		hql.append(" t.report_sql as report_sql,");
 		hql.append(" t.creator as creator,");
 		hql.append(" to_char(t.created,'yyyy-MM-dd') as created,");
 		hql.append(" t.modifier as modifier,");
 		hql.append(" to_char(t.modified,'yyyy-MM-dd') as modified,");
 		hql.append(" t.delete_flag as delete_flag");
		hql.append(" ) from JedaReportVo t");
		hql.append(" where t.delete_flag='0'");
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and t." + key + " like :" + key);
				} else {
					hql.append(" and t." + key + " = :" + key);
				}
			}
		}
		if(sort!=null && !sort.equals("")){
			hql.append(" order by t." + sort );
			if(dir!=null && !dir.equals("")){
				hql.append(" " + dir );
			}else{
				hql.append(" desc");
			}
		}
 		logger.info(hql.toString());
 		Query query = getSession().createQuery(hql.toString()).setFirstResult(start).setMaxResults(limit);
 		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
 		return query.list();
	}
	
	/**
	 * 统计报表总记录数 (未删除报表)
	 */
	@Transactional(readOnly = true)
	public Long countReportInfoList(Map<String, Object> params){
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
 		hql.append(" t.report_code as report_code,");
 		hql.append(" t.report_type as report_type,");
 		hql.append(" t.report_name as report_name,");
 		hql.append(" t.report_desc as report_desc,");
 		hql.append(" t.report_sql as report_sql,");
 		hql.append(" t.creator as creator,");
 		hql.append(" to_char(t.created,'yyyy-MM-dd') as created,");
 		hql.append(" t.modifier as modifier,");
 		hql.append(" to_char(t.modified,'yyyy-MM-dd') as modified,");
 		hql.append(" t.delete_flag as delete_flag");
		hql.append(" ) from JedaReportVo t");
		hql.append(" where t.delete_flag='0'");
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and t." + key + " like :" + key);
				} else {
					hql.append(" and t." + key + " = :" + key);
				}
			}
		}
 		logger.info(hql.toString());
 		Query query = getSession().createQuery(hql.toString());
 		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
 		return Long.valueOf(query.list().size());
	}
	
	/**
	 * 根据报表编号获取报表关联规则
	 * @param reportCode 报表编号
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<Map<String, String>> getReportRulesByReportCode(int reportCode){
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(");
 		hql.append(" t.report_code as report_code,");
 		hql.append(" t.rule_code as rule_code");
		hql.append(" ) from JedaReportRuleVo t");
		hql.append(" where t.report_code=?");
 		logger.info(hql.toString());
 		Query query = getSession().createQuery(hql.toString()).setInteger(0, reportCode);
 		return query.list();
	}
	
	/**
	 * 根据报表编号获取报表关联角色
	 * @param reportCode 报表编号
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<Map<String, String>> getReportRolesByReportCode(int reportCode){
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(");
 		hql.append(" t.report_code as report_code,");
 		hql.append(" t.role_code as role_code");
		hql.append(" ) from JedaReportRoleVo t");
		hql.append(" where t.report_code=?");
 		logger.info(hql.toString());
 		Query query = getSession().createQuery(hql.toString()).setInteger(0, reportCode);
 		return query.list();
	}
	
	/**
	 * 根据报表编号获取报表关联菜单
	 * @param reportCode 报表编号
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public Map<String, String> getReportMenuByReportCode(int reportCode){
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
 		hql.append(" t.report_code as report_code,");
 		hql.append(" t.parent_menu as parent_menu");
		hql.append(" ) from JedaReportMenuVo t");
		hql.append(" where t.report_code=?");
 		logger.info(hql.toString());
 		Query query = getSession().createQuery(hql.toString()).setInteger(0, reportCode);
 		return (Map<String,String>)query.uniqueResult();
	}
	
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public List<Map<String, String>> getRoleList(String reportCode) {
		StringBuffer sql = new StringBuffer();
		sql = sql.append(" select r.ROLE_ID as \"role_code\",");
		sql = sql.append(" r.ROLE_NAME as \"role_name\",");
		sql = sql.append(" r.ROLE_TYPE as \"role_type\",");
		sql = sql.append(" r.ROLE_DESCRIPTION as \"role_desc\",");
		sql = sql.append(" r.ROLE_ORDER as \"role_order\" ");
		if(reportCode!=null && !reportCode.equals("")){
			sql = sql.append(",");
			sql = sql.append(" (case when (select count(*)");
			sql = sql.append(" from JEDA_REPORT_ROLE rr");
			sql = sql.append(" where r.ROLE_ID = rr.ROLE_CODE and rr.REPORT_CODE=?) > 0 then 'true' else 'false' end) as \"checked\" ");
		}
		sql = sql.append(" from JEDA_ROLE@DB_JEDA_LINK r");
		sql = sql.append(" order by r.ROLE_ORDER asc");
		Query query =getSession().createSQLQuery(sql.toString());
		if(reportCode!=null && !reportCode.equals("")){
			query = query.setInteger(0, Integer.valueOf(reportCode));
		}
		return query.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();
	}
	
	/**
	 * 根据编号批量删除报表相关数据
	 * @param reportCodes 报表编号数组
	 * @throws Exception 
	 */
	@Transactional(rollbackFor = SQLException.class, propagation = Propagation.REQUIRED, value = "maoprpt")
	public void deleteJedaRptByIds(Integer[] reportCodes) throws Exception {
		for(int t=0;t<reportCodes.length;t++) {
			deleteJedaRptById(reportCodes[t]);
			deleteRepportParamByReportCode(reportCodes[t]);
			deleteExcelTemplate(reportCodes[t]);
			deleteReportColumnByReportCode(reportCodes[t]);
			deleteReportMenuByReportCode(reportCodes[t]);
			deleteReportRuleByReportCode(reportCodes[t]);
			deleteReportRoleByReportCode(reportCodes[t]);
			//删除报表菜单配置信息
	        menuService.delete((Menu)menuService.get(String.valueOf(reportCodes[t])));
	        //删除jeda角色菜单关联信息
	        menuService.deleteRoleMenu(String.valueOf(reportCodes[t]));
		}
	}
	
	
	/**
	 * 根据字段名称获取字段信息
	 * @param columnName 字段名称
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<Map<String, String>> getColumnByName(String columnName){
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(");
 		hql.append(" t.column_code as column_code,");
 		hql.append(" t.column_en_name as column_en_name,");
 		hql.append(" t.column_ch_name as column_ch_name,");
 		hql.append(" t.column_desc as column_desc,");
 		hql.append(" t.delete_flag as delete_flag,");
 		hql.append(" t.is_trans as is_trans,");
 		hql.append(" t.dic_code as dic_code");
		hql.append(" ) from JedaColumnVo t");
		hql.append(" where t.column_en_name=? and t.delete_flag='0' ");
 		logger.info(hql.toString());
 		Query query = getSession().createQuery(hql.toString()).setString(0, columnName);
 		return query.list();
	}
	
	/**
	 * 保存或修改字段基本信息
	 * @param columnName 字段名称
	 * @param map 页面传递的字段属性值
	 * @return
	 */
	public int saveOrUpdateJedaColumn(String columnName,Map<String, Object> map){
		int columnCode = 0 ;
		JedaColumnVo jedaColumnVo = null;
		List<Map<String,String>> list = getColumnByName(columnName);
		if(list!=null && list.size()>0){ //该字段已存在，则修改
			String colCode = String.valueOf(list.get(0).get("column_code"));
			jedaColumnVo = (JedaColumnVo)getJedaColumnById(Integer.valueOf(colCode));
			jedaColumnVo.setColumn_ch_name(ComUtil.checkJSONNull(map.get("column_ch_name")));
			if(map.get("column_desc")!=null && !map.get("column_desc").equals("")){
				jedaColumnVo.setColumn_desc(ComUtil.checkJSONNull(map.get("column_desc")));
			}else{
				jedaColumnVo.setColumn_desc("");
			}
			if(map.get("is_trans")!=null && !map.get("is_trans").equals("")){
				jedaColumnVo.setIs_trans(ComUtil.checkJSONNull(map.get("is_trans")));
			}else{
				jedaColumnVo.setIs_trans("");
			}
			if(map.get("dic_code")!=null && !map.get("dic_code").equals("")){
				jedaColumnVo.setDic_code(ComUtil.checkJSONNull(map.get("dic_code")));
			}else{
				jedaColumnVo.setDic_code("");
			}
			updateJedaColumn(jedaColumnVo);
			columnCode = Integer.valueOf(colCode);
		}else{ //该字段不存在，则新建
			jedaColumnVo = new JedaColumnVo();
			jedaColumnVo.setColumn_en_name(columnName);
			jedaColumnVo.setColumn_ch_name(ComUtil.checkJSONNull(map.get("column_ch_name")));
			if(map.get("column_desc")!=null && !map.get("column_desc").equals("")){
				jedaColumnVo.setColumn_desc(ComUtil.checkJSONNull(map.get("column_desc")));
			}else{
				jedaColumnVo.setColumn_desc("");
			}
			if(map.get("is_trans")!=null && !map.get("is_trans").equals("")){
				jedaColumnVo.setIs_trans(ComUtil.checkJSONNull(map.get("is_trans")));
			}else{
				jedaColumnVo.setIs_trans("");
			}
			if(map.get("dic_code")!=null && !map.get("dic_code").equals("")){
				jedaColumnVo.setDic_code(ComUtil.checkJSONNull(map.get("dic_code")));
			}else{
				jedaColumnVo.setDic_code("");
			}
			jedaColumnVo.setDelete_flag("0");
			columnCode = saveJedaColumn(jedaColumnVo);
		}
		return columnCode;
	}
	
}
