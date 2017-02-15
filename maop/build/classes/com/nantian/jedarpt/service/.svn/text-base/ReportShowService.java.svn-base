package com.nantian.jedarpt.service;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;
import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.type.StringType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.ServletRequestBindingException;
import org.springframework.web.bind.ServletRequestUtils;

import com.nantian.check.service.JobDesignService;
import com.nantian.common.system.service.AppInfoService;
import com.nantian.common.util.CommonConst;
import com.nantian.jeda.FieldType;

/**
 * 报表展现service
 * @author linaWang
 *
 */
@Service
@Repository
@Transactional
public class ReportShowService {
	/** 日志输出 */
	final Logger logger = Logger.getLogger(ReportShowService.class);

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();

	/** HIBERNATE Session Factory */
	@Autowired
	private SessionFactory sessionFactoryMaopRpt;
	@Autowired
	private JobDesignService jobDesignService;
	@Autowired
	private AppInfoService appInfoService;

	public Session getSession() {
		return sessionFactoryMaopRpt.getCurrentSession();
	}

	//应用系统编号（与jeda_column表中的column_en_name对应）
	private String APPSYSCODE = "appsys_code";
	//应用系统名称（与appInfoService.querySystemIDAndNames4NoDelHasAop()中的系统名称别名对应）
	private String APPSYS_CODE = "appsysCode";
	private String APPSYS_NAME = "appsysName";
	
	/**
	 * 构造方法
	 */
	public ReportShowService() {
	}
	
	/**
	 * 根据菜单编号获取报表编号
	 * @param menuCode 菜单编号
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public String getReportCodeByMenuCode(String menuCode){
		StringBuilder sql = new StringBuilder();
		sql.append("select t.report_code from jeda_report_menu t where t.menu_code = '"+menuCode+"'");
		Query query = getSession().createSQLQuery(sql.toString());
		List<String> list = query.list();
		if(list!=null && list.size()>0){
			return list.get(0).toString();
		}else{
			return "";
		}
	}
	
	/**
	 * 根据报表编号获取报表关联字段
	 * @param reportCode 报表编号
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<Map<String, String>> getReportColumnsByReportCode(int reportCode){
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(");
 		hql.append(" t.column_code as column_code,");
 		hql.append(" t.column_en_name as column_en_name,");
 		hql.append(" t.column_ch_name as column_ch_name,");
 		hql.append(" t.column_desc as column_desc,");
 		hql.append(" t.delete_flag as delete_flag,");
 		hql.append(" t.is_trans as is_trans,");
 		hql.append(" t.dic_code as dic_code,");
 		hql.append(" e.default_value as default_value,");
 		hql.append(" e.column_width as column_width,");
 		hql.append(" e.column_sort as column_sort,");
 		hql.append(" e.is_visible as is_visible");
		hql.append(" ) from JedaColumnVo t,JedaReportColumnVo e");
		hql.append(" where t.column_code=e.column_code ");
		hql.append(" and e.report_code=? and t.delete_flag='0'");
		hql.append(" order by cast(e.column_sort as int) asc ");
		//hql.append(" order by e.column_sort asc ");
 		logger.info(hql.toString());
 		Query query = getSession().createQuery(hql.toString()).setInteger(0, reportCode);
 		return query.list();
	}
	
	/**
	 * 根据报表编号获取报表关联字段_图表数据字典
	 * @param reportCode 报表编号
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<Map<String, String>> getRepColsStoreByReportCode(int reportCode){
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(");
 		hql.append(" t.column_en_name as value,");
 		hql.append(" t.column_ch_name as name");
		hql.append(" ) from JedaColumnVo t,JedaReportColumnVo e");
		hql.append(" where t.column_code=e.column_code ");
		hql.append(" and e.report_code=? and t.delete_flag='0'");
 		logger.info(hql.toString());
 		Query query = getSession().createQuery(hql.toString()).setInteger(0, reportCode);
 		return query.list();
	}
	
	/**
	 * 根据报表编号获取报表关联参数
	 * @param reportCode 报表编号
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<Map<String, String>> getReportParamsByReportCode(int reportCode){
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(");
 		hql.append(" t.param_code as param_code,");
 		hql.append(" t.param_en_name as param_en_name,");
 		hql.append(" t.param_ch_name as param_ch_name,");
 		hql.append(" t.param_type as param_type,");
 		hql.append(" t.default_value as default_value,");
 		hql.append(" t.dic_code as dic_code");
		hql.append(" ) from JedaReportParamVo t");
		hql.append(" where t.report_code=? and t.delete_flag='0'");
 		logger.info(hql.toString());
 		Query query = getSession().createQuery(hql.toString()).setInteger(0, reportCode);
 		return query.list();
	}
	
	/**
	 * 根据报表编号获取报表详细信息 (未删除报表)
	 * @param reportCode 报表编号
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public Map<String, String> getReportInfoByReportCode(int reportCode){
		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
 		hql.append(" t.report_type as report_type,");
 		hql.append(" t.report_name as report_name,");
 		hql.append(" t.report_desc as report_desc,");
 		hql.append(" t.report_sql as report_sql,");
 		hql.append(" t.creator as creator,");
 		hql.append(" to_char(t.created,'yyyy-MM-dd hh24:mi:ss') as created,");
 		hql.append(" t.modifier as modifier,");
 		hql.append(" to_char(t.modified,'yyyy-MM-dd hh24:mi:ss') as modified,");
 		hql.append(" t.delete_flag as delete_flag");
		hql.append(" ) from JedaReportVo t");
		hql.append(" where t.report_code=? and t.delete_flag='0'");
 		logger.info(hql.toString());
 		Query query = getSession().createQuery(hql.toString()).setInteger(0, reportCode);
 		return (Map<String,String>)query.uniqueResult();
	}
	
	/**
	 * 分页查询报表数据
	 * @param reportCode 报表编号
	 * @param params 查询参数
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked"})
	public List<Map<String, Object>> getReportList(Integer start, Integer limit, String sort, String dir,
			String reportCode , Map<String, Object> params) {
		String sql = "";
		//获取报表参数信息
		List<Map<String, String>> reportParams = getReportParamsByReportCode(Integer.valueOf(reportCode));
		//获取报表信息
		Map<String, String> reportInfo = getReportInfoByReportCode(Integer.valueOf(reportCode));
		if(reportInfo!=null){
			sql = (String)reportInfo.get("report_sql");
			//sql语句全部转为小写字母(导致查询参数传值有问题，舍弃)
			//sql = sql.toLowerCase();
			if(sql!=null && !sql.equals("")){
				int fromIndex = 0;
				int fromIndex1 = sql.indexOf("from");
				int fromIndex2 = sql.indexOf("FROM");
				if(fromIndex1==-1 && fromIndex2!=-1){
					fromIndex = fromIndex2;
				}else if(fromIndex2==-1 && fromIndex1!=-1 ){
					fromIndex = fromIndex1;
				}else if(fromIndex2!=-1 && fromIndex1!=-1){
					if(fromIndex1 <= fromIndex2){
						fromIndex = fromIndex1;
					}else{
						fromIndex = fromIndex2;
					}
				}else{
					logger.info("报表SQL语法错误：未找到FROM关键字！");
					logger.info("错误SQL："+sql);
				}
				//获取所有查询字段
				String str = (sql.substring(sql.indexOf("select")+6,fromIndex)).trim();
				String[] cols = str.split("#,#");
				List<String> showCols = new ArrayList<String>();
				for(int t=0 ; t<cols.length ; t++){
					//查询字段
					String col = cols[t]; 
					col = (col.substring(col.lastIndexOf(" as ")+4)).trim();
					showCols.add(col);
				}
				//查询条件为空的参数
				List<Map<String, String>> removes = new ArrayList<Map<String, String>>() ;
				for(Map<String, String> map : reportParams){
					String paramNameEn = (String) map.get("param_en_name");
					Boolean b = false ; 
					for (String key : params.keySet()) {
						if (paramNameEn!=null && paramNameEn.equals(key)) {
							b = true ;
						}
					}
					if(b){
						removes.add(map);
					}
				}
				if(removes!=null){
					reportParams.removeAll(removes);
				}
				for(String key : params.keySet()) {
					sql = sql.replaceAll("#"+key+"#","'"+params.get(key)+"'");
				}
				for(Map<String, String> map : reportParams){
					String paramNameEn = (String) map.get("param_en_name");
					sql = sql.replace("#"+paramNameEn+"#" ,"'%%'");
				}
				sql = sql.replace("#,#",",");
				
				//排序
				if(sql.indexOf("order by") == -1 && sql.indexOf("ORDER BY") == -1){ //sql语句中不包含排序字段
					if(sort!=null && !sort.equals("")){
						sql = sql + " order by " + sort ;
						if(dir!=null && !dir.equals("")){
							sql = sql + " " + dir ;
						}else{
							sql = sql + " desc";
						}
					}
				}
				
				logger.info("报表展现SQL："+sql);
				Query query = getSession().createSQLQuery(sql)
								.setFirstResult(start)
								.setMaxResults(limit)
								.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
				if(showCols!=null && showCols.size()>0){
					for(int t=0 ; t<showCols.size() ; t++){
						query = ((SQLQuery) query).addScalar(showCols.get(t).toString(), StringType.INSTANCE);
					}
				}
				return query.list();
			}
		}
		return null ;
	}
	
	/**
	 * 查询所有报表数据_用于Excel导出
	 * @param reportCode 报表编号
	 * @param params 查询参数
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked"})
	public List<Map<String, Object>> getReportListForExp(String reportCode , Map<String, Object> params) {
		String sql = "";
		//获取报表参数信息
		List<Map<String, String>> reportParams = getReportParamsByReportCode(Integer.valueOf(reportCode));
		//获取报表信息
		Map<String, String> reportInfo = getReportInfoByReportCode(Integer.valueOf(reportCode));
		if(reportInfo!=null){
			sql = (String)reportInfo.get("report_sql");
			if(sql!=null && !sql.equals("")){
				int fromIndex = 0;
				int fromIndex1 = sql.indexOf("from");
				int fromIndex2 = sql.indexOf("FROM");
				if(fromIndex1==-1 && fromIndex2!=-1){
					fromIndex = fromIndex2;
				}else if(fromIndex2==-1 && fromIndex1!=-1 ){
					fromIndex = fromIndex1;
				}else if(fromIndex2!=-1 && fromIndex1!=-1){
					if(fromIndex1 <= fromIndex2){
						fromIndex = fromIndex1;
					}else{
						fromIndex = fromIndex2;
					}
				}else{
					logger.info("报表SQL语法错误：未找到FROM关键字！");
					logger.info("错误SQL："+sql);
				}
				//获取所有查询字段
				String str = (sql.substring(sql.indexOf("select")+6, fromIndex)).trim();
				String[] cols = str.split("#,#");
				List<String> showCols = new ArrayList<String>();
				for(int t=0 ; t<cols.length ; t++){
					//查询字段
					String col = cols[t]; 
					col = (col.substring(col.lastIndexOf(" as ")+4)).trim();
					showCols.add(col);
				}
				//查询条件为空的参数
				List<Map<String, String>> removes = new ArrayList<Map<String, String>>() ;
				for(Map<String, String> map : reportParams){
					String paramNameEn = (String) map.get("param_en_name");
					Boolean b = false ; 
					for (String key : params.keySet()) {
						if (paramNameEn!=null && paramNameEn.equals(key)) {
							b = true ;
						}
					}
					if(b){
						removes.add(map);
					}
				}
				if(removes!=null){
					reportParams.removeAll(removes);
				}
				for(String key : params.keySet()) {
					sql = sql.replace("#"+key+"#","'"+params.get(key)+"'");
				}
				for(Map<String, String> map : reportParams){
					String paramNameEn = (String) map.get("param_en_name");
					sql = sql.replace("#"+paramNameEn+"#" ,"'%%'");
				}
				sql = sql.replace("#,#",",");
				logger.info("报表展现SQL："+sql);
				Query query = getSession().createSQLQuery(sql)
								.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
				if(showCols!=null && showCols.size()>0){
					for(int t=0 ; t<showCols.size() ; t++){
						query = ((SQLQuery) query).addScalar(showCols.get(t).toString(), StringType.INSTANCE);
					}
				}
				return query.list();
			}
		}
		return null ;
	}
	
	
	/**
	 * 查询字段及其值的处理
	 * @param request
	 * @param fields
	 * @return
	 */
	public Map<String, Object> getQueryMap(HttpServletRequest request, Map<String, String> fields) {
		Map<String, Object> map = new HashMap<String, Object>();
		try{
			for(String field : fields.keySet()) {
				String value = ServletRequestUtils.getStringParameter(request, field);
				if(null != value && !value.isEmpty()) {
					if(fields.get(field).equals(FieldType.STRING)) {
						map.put(field, "%" + value + "%");
					}else if (fields.get(field).equals(FieldType.INTEGER)) {
						map.put(field, Integer.valueOf(value));
					}else if (fields.get(field).equals(FieldType.LONG)) {
						map.put(field, Long.valueOf(value));
					}else if (fields.get(field).equals(FieldType.DOUBLE)) {
						map.put(field, Double.valueOf(value));
					}else if (fields.get(field).equals(FieldType.DATE)) {
						/* 字符串先转日期，再转字符串。存在日期错乱问题
						 * SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd");
						 * map.put(field,format.format(format.parse(value)));
						 */
						//eg: 传值2014-05-31T00:00:00  转化值20140531
						map.put(field,value.substring(0,10).replaceAll("-", ""));
					}else{  //时间等直接传字符串
						map.put(field, value);
					}
				}
			}
		}catch (ServletRequestBindingException e) {
			e.printStackTrace();
		}
		return map;
	}
	
	/**
	 * 获取报表关联字段
	 * @param reportCode 报表编号
	 * @return Map<param_en_name,dic_code> 
	 */
	public Map<String,String> getReportColumnDicItemsMap(int reportCode){
		Map<String,String> dicItemsMap = new HashMap<String,String>();
		List<Map<String, String>> columns = getReportColumnsByReportCode(reportCode);
		for(Map<String, String> column : columns){
			String nameEn = (String) column.get("column_en_name");
			String dicCode = (String) column.get("dic_code");
			if(dicCode!=null && !dicCode.equals("")){
				dicItemsMap.put(nameEn, dicCode);
			}
		}
		return dicItemsMap ;
	}
	
	/**
	 * 根据报表编号获取报表关联模板信息
	 * @param reportCode 报表编号
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public Map<String, String> getTemplateByReportCode(int reportCode){
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct");
 		hql.append(" t.template_code as template_code,");
 		hql.append(" t.report_code as report_code,");
 		hql.append(" t.template_en_name as template_en_name,");
 		hql.append(" t.template_ch_name as template_ch_name,");
 		hql.append(" t.start_row_num as start_row_num,");
 		hql.append(" t.start_col_num as start_col_num,");
 		hql.append(" t.delete_flag as delete_flag");
		hql.append(" from JedaExcelTemplateVo t");
		hql.append(" where t.report_code=? and t.delete_flag='0'");
 		logger.info(hql.toString());
 		Query query = getSession().createQuery(hql.toString())
 				.setInteger(0, reportCode)
 				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
 		return (Map<String, String>)query.uniqueResult();
	}
	
	
	/**
	 * 将查询结果转化为数据字典对应显示值
	 * @param reportId 报表编号
	 * @param queryList sql查询结果数据
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> changeItemToDicValue(String reportId,List<Map<String, Object>> queryList){
		List<Map<String, Object>> showList = new ArrayList<Map<String,Object>>();
		//获取数据字典显示值与数据库存储值的映射关系
		Map<String, String> itemMap = jobDesignService.findMap();
		//获取报表字段关联数据字典
		Map<String,String> dicItems = getReportColumnDicItemsMap(Integer.valueOf(reportId));
		//获取未删除、已上线的所有应用系统编号及名称
		List<Map<String, String>> appsyss = (List<Map<String, String>>)appInfoService.querySystemIDAndNames4NoDelHasAop();
		//处理列表中的数据字典显示字段及应用系统名称
		if(queryList!=null && queryList.size()>0){
			for (Map<String,Object> map : queryList) {
				for(String nameEn : dicItems.keySet()){
					String dicItemValue = String.valueOf(map.get(nameEn));
					String dicItemName = dicItems.get(nameEn);
					if(dicItemValue!=null && !dicItemValue.equals("")){
						String showValue = itemMap.get(dicItemName.concat(dicItemValue));
						if(showValue!=null && !showValue.equals("")){
							map.put(nameEn,showValue);
						}
					}
				}
				//应用系统编号
				String appsysCode = (String) map.get(APPSYSCODE);
				if(appsysCode!=null && !appsysCode.equals("")){
					for(Map<String, String> appsys : appsyss){
						if(appsys.get(APPSYS_CODE).equals(appsysCode)){
							String showValue = appsys.get(APPSYS_NAME);
							if(showValue!=null && !showValue.equals("")){
								map.put(APPSYSCODE,showValue);
							}
						}
					}
				}
				showList.add(map);
			}
		}
		return showList ;
	}
	
	/**
	 * 获取报表柱形图数据
	 * @param reportId 报表编号
	 * @param xItem x轴数据
	 * @param yItem y轴数据
	 * @return
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	public String getRptColumnChart(String reportId,String groupItem,String xItem,String yItem,HttpServletRequest request) throws Exception {
		StringBuilder charOptions = new StringBuilder();
		Set<String> groupSet = new HashSet<String>();  //x轴分组数据
		Set<String> xItemSet = new HashSet<String>();  //x轴统计科目数据
		StringBuilder chartTitle = new StringBuilder(); //图表标题
		StringBuilder yAxisTitle = new StringBuilder(); //y轴科目名称
		StringBuilder xCategories = new StringBuilder(); //x轴每组内的科目名称
		StringBuilder seriesOptions = new StringBuilder(); //柱形图数据

		//报表基本信息
		Map<String, String> reportInfo = getReportInfoByReportCode(Integer.valueOf(reportId));
		//获取查询列表数据
		List<Map<String, Object>> reportlist = (List<Map<String, Object>>) request.getSession().getAttribute("jedaReportShowList"+reportId);
		//数据字典显示值转换
		List<Map<String, Object>> reportshowList = changeItemToDicValue(reportId,reportlist);
		//获取x轴分组数据
		for(Map<String, Object> reportShow : reportshowList){
			groupSet.add((String) reportShow.get(groupItem));
		}
		//获取统计科目名称数据
		for(Map<String, Object> reportShow : reportshowList){
			xItemSet.add((String) reportShow.get(xItem));
		}
		
		try{
			//标题（报表名称） eg:"Monthly Average Rainfall"
			chartTitle.append("\""+(String)reportInfo.get("report_name")+"\"");
			//Y轴title eg:"Rainfall (mm)"
			yAxisTitle.append("\""+yItem+"\"");
			//X轴数据  eg:['Jan','Feb']
			xCategories.append("\"");
			for(String group : groupSet){
				xCategories.append(group).append(CommonConst.COMMA); //逗号分隔
			}
			if(!xCategories.equals("\"")){
				xCategories.deleteCharAt(xCategories.length()-1); //删除最后多余的逗号
			}
			xCategories.append("\"");
			
			//图表统计科目信息
			Boolean a = false ;
			Boolean b = false ;
			seriesOptions.append("[");
			for(String xItemValue : xItemSet){
				seriesOptions.append("{ ");
				seriesOptions.append("name:\""+xItemValue+"\"").append(CommonConst.COMMA);
				seriesOptions.append("data:[");
				for(String groupValue : groupSet){
					for(Map<String, Object> reportShow : reportshowList){
						if(reportShow.get(groupItem).equals(groupValue) 
								&& reportShow.get(xItem).equals(xItemValue)){
							seriesOptions.append(reportShow.get(yItem)).append(CommonConst.COMMA);
							a = true ;
							b = true ;
							break ;
						}
					}
					if(!b){
						seriesOptions.append("null").append(CommonConst.COMMA); //某日无数据时设置为null，否则图表无法展示data数据异常
						a = true ;
					}
					b = false ;
				}
				if(a){
					seriesOptions.deleteCharAt(seriesOptions.length()-1); //删除最后多余的逗号
				}
				a = false ;
				seriesOptions.append("]");
				seriesOptions.append("}").append(CommonConst.COMMA);
			}
			if(!seriesOptions.equals("[")){
				seriesOptions.deleteCharAt(seriesOptions.length()-1); //删除最后多余的逗号
			}
			seriesOptions.append("]");
			
			//编辑返回JSON数据
			charOptions.append("{")
							.append("\"chartTitle\":").append(chartTitle.toString()).append(CommonConst.COMMA)
							.append("\"yAxisTitle\":").append(yAxisTitle.toString()).append(CommonConst.COMMA)
							.append("\"xCategories\":").append(xCategories.toString()).append(CommonConst.COMMA)
							.append("\"seriesOptions\":").append(seriesOptions.toString().replaceAll(CommonConst.PERCENT_SYMBOL, ""))
							.append("}");
			logger.info("柱形图图表信息：" + charOptions.toString());
			return charOptions.toString();	
		} catch (Exception ex) {
			throw ex;
		}
	}
	
	
	/**
	 * 获取报表饼状图数据
	 * @param reportId 报表编号
	 * @param nameItem 统计科目名称
	 * @param valueItem 统计科目值
	 * @return
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	public String getRptPieChart(String reportId,String nameItem,String valueItem,HttpServletRequest request) throws Exception {
		StringBuilder charOptions = new StringBuilder();
		StringBuilder chartTitle = new StringBuilder(); //图表标题
		StringBuilder seriesName = new StringBuilder(); //图表数据标识
		StringBuilder seriesData = new StringBuilder(); //图表数据

		//报表基本信息
		Map<String, String> reportInfo = getReportInfoByReportCode(Integer.valueOf(reportId));
		//获取查询列表数据
		List<Map<String, Object>> reportlist = (List<Map<String, Object>>) request.getSession().getAttribute("jedaReportShowList"+reportId);
		//数据字典显示值转换
		List<Map<String, Object>> reportshowList = changeItemToDicValue(reportId,reportlist);
		
		//删除统计值为0的数据
		List<Map<String,Object>> delList = new ArrayList<Map<String,Object>>();
		for(Map<String, Object> reportShow : reportshowList){
			if(reportShow.get(valueItem)!=null && !reportShow.get(valueItem).equals("") && !reportShow.get(valueItem).equals("0")){
			}else{
				delList.add(reportShow);
			}
		}
		if(delList!=null && delList.size()>0){
			reportshowList.removeAll(delList);
		}
		/*注意：饼状图不需要要计算百分比，直接传值即可。HighCharts后台计算*/
		try{	
			//标题（报表名称） eg:"Monthly Average Rainfall"
			chartTitle.append("\""+(String)reportInfo.get("report_name")+"\"");
			//统计科目值对应的属性名称
			seriesName.append("\""+valueItem+"\"");
			//饼状图各区域信息
			seriesData.append("[");
			for(int t=0 ; t<reportshowList.size() ; t++){
				Map<String, Object> reportshow = reportshowList.get(t) ;
				Double value = Double.valueOf((String)reportshow.get(valueItem)) ;
				if(t == 0){
					seriesData.append("{");
					seriesData.append(" name:\"").append(reportshow.get(nameItem)).append("\"").append(CommonConst.COMMA);
					seriesData.append(" y:"+value).append(CommonConst.PERCENT_SYMBOL).append(CommonConst.COMMA);
					seriesData.append(" sliced: true").append(CommonConst.COMMA);
                    seriesData.append(" selected: true");
                    seriesData.append(" }").append(CommonConst.COMMA);
				}else{
					seriesData.append("[");
					seriesData.append("\"").append(reportshow.get(nameItem)).append("\"").append(CommonConst.COMMA);
					seriesData.append(value).append(CommonConst.PERCENT_SYMBOL);
					seriesData.append("]").append(CommonConst.COMMA);
				}
			}
			if(!seriesData.equals("[")){
				seriesData.deleteCharAt(seriesData.length()-1); //删除最后多余的逗号
			}
			seriesData.append("]");
			
			//编辑返回JSON数据
			charOptions.append("{")
							.append("\"chartTitle\":").append(chartTitle.toString()).append(CommonConst.COMMA)
							.append("\"seriesName\":").append(seriesName.toString()).append(CommonConst.COMMA)
							.append("\"seriesData\":").append(seriesData.toString().replaceAll(CommonConst.PERCENT_SYMBOL, ""))
							.append("}");
			logger.info("饼状图图表信息：" + charOptions.toString());
			return charOptions.toString();	
		} catch (Exception ex) {
			throw ex;
		}
	}
	
}
