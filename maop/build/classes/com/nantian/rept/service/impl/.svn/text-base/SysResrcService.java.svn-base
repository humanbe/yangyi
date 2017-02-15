package com.nantian.rept.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.ModelMap;

import com.nantian.common.util.ComUtil;
import com.nantian.common.util.CommonConst;
import com.nantian.common.util.DateFunction;
import com.nantian.common.util.NumberUtil;
import com.nantian.component.log.Logger;
import com.nantian.jeda.FieldType;
import com.nantian.rept.ReptConstants;
import com.nantian.rept.service.BaseService;
import com.nantian.rept.service.RptItemConfService;
import com.nantian.rept.service.SysDateService;
import com.nantian.rept.vo.RptChartConfVo;
import com.nantian.rept.vo.RptItemConfVo;
import com.nantian.rept.vo.SysDateVo;
import com.nantian.rept.vo.SysResrcVo;

@Service
@Repository
public class SysResrcService implements BaseService<RptItemConfVo, RptChartConfVo>{
	/** 日志输出 */
	final Logger logger = Logger.getLogger(SysResrcService.class);

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();

	@Autowired
	private SysDateService sysDateService;
	
	/** HIBERNATE Session Factory */
	@Autowired
	private SessionFactory sessionFactoryMaopRpt;
	@Autowired
	private RptItemConfService rptItemConfService;
	public Session getSession() {
		return sessionFactoryMaopRpt.getCurrentSession();
	}

	/**
	 * 构造方法

	 */
	public SysResrcService() {
		fields.put("srvCode", FieldType.STRING);
		fields.put("loadMode", FieldType.STRING);
		fields.put("aplCode", FieldType.STRING);
		fields.put("serClass", FieldType.STRING);
		fields.put("serName", FieldType.STRING);
		fields.put("memConf", FieldType.STRING);
		fields.put("cpuConf", FieldType.STRING);
		fields.put("diskConf", FieldType.STRING);
		fields.put("ipAddress", FieldType.STRING);
		fields.put("floatAddress", FieldType.STRING);
	}
	
	/**
	 * 保存.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void save(SysResrcVo sysResrcVo) {
		getSession().save(sysResrcVo);
	}
	
	/**
	 * 更新.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void update(SysResrcVo sysResrcVo) {
		getSession().update(sysResrcVo);
	}

	/**
	 * 批量保存.
	 * @param customer
	 */
	@Transactional(value="maoprpt")
	public void save(Set<SysResrcVo> sysResrcVos) {
		for (SysResrcVo sysResrcVo : sysResrcVos) {
			getSession().save(sysResrcVo);
		}
	}
	
	/**
	 * 批量保存或者更新


	 * @param sysResrcVos
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(List<SysResrcVo> sysResrcVos) {
		for (SysResrcVo sysResrcVo : sysResrcVos) {
			getSession().saveOrUpdate(sysResrcVo);
		}
	}
	
	/**
	 * 保存或者更新


	 * @param sysResrcVo
	 */
	@Transactional(value="maoprpt")
	public void saveOrUpdate(SysResrcVo sysResrcVo) {
			getSession().saveOrUpdate(sysResrcVo);
	}

	/**
	 * 通过主键查找唯一的一条记录

	 * @param srvCode 服务器编号


	 * @return SysResrcVo 实体
	 */
	@Transactional(value = "maoprpt", propagation=Propagation.NOT_SUPPORTED, readOnly = true)
	public SysResrcVo findByPrimaryKey(String aplCode,String transDate,String srvCode,String minPoint){
		return (SysResrcVo) getSession()
				.createQuery("from sysResrcVo sr where sr.aplCode=:aplCode and sr.transDate=:transDate and sr.srvCode=:srvCode and sr.minPoint=:minPoint")
				.setString("aplCode", aplCode)
				.setString("transDate", transDate)
				.setString("srvCode", srvCode)
				.setString("minPoint", minPoint)
				.uniqueResult();
	}

	/**
	 * 删除
	 * @param customer
	 */
	@Transactional("maoprpt")
	public void delete(SysResrcVo sysResrcVo) {
		getSession().delete(sysResrcVo);
	}
	
	/**
	 * 根据ID批量删除.
	 * @param primaryKeys
	 */
	@Transactional("maoprpt")
	public void deleteByIds(String primaryKey) {
		String[] arr = primaryKey.split(",");
		deleteById(arr[0],arr[1],arr[2],arr[3]);
	}
	
	/**
	 * 根据ID删除.
	 * @param id
	 */
	private void deleteById(String aplCode,String transDate,String srvCode,String minPoint) {
		getSession().createQuery("delete from SysResrcVo sr where sr.aplCode=? and sr.transDate=? and sr.srvCode=? and sr.minPoint=?")
			.setString(0, aplCode)
			.setString(1, transDate)
			.setString(2, srvCode)
			.setString(3, minPoint)
			.executeUpdate();
	}

	/**
	 * 查询数据
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(value = "maoprpt", readOnly = true)
	public List<SysResrcVo> queryAll(Integer start, Integer limit, String sort, String dir, Map<String, Object> params) {

		StringBuilder hql = new StringBuilder();
		hql.append("from SysResrcVo sr where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
					if (fields.get(key).equals(FieldType.STRING)) {
						hql.append(" and s." + key + " like :" + key);
					} else {
						hql.append(" and sr." + key + " = :" + key);
					}
			}
		}
		hql.append(" order by sr." + sort + " " + dir);
		 
		Query query = getSession().createQuery(hql.toString());

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		
		return query.setFirstResult(start).setMaxResults(limit).list();
	}
	
	/**
	 * 查询五分钟系统资源统计表数据（有交易量）
	 * @param aplCode 应用系统编号
	 * @param srvCode 服务器编号


	 * @param tranName 交易名称
	 * @param endDate 日报日期
	 * @param endDatePlus1 日报日期下一日


	 * @param holidayFlag 节假日标示


	 * @param transMonthMinus1 基于日报日期的前一月份
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(value = "maoprpt", readOnly = true)
	public List<Map<String, Object>> findRptSysResrc(String aplCode, String srvCode, String tranName, String endDate, String endDatePlus1, String holidayFlag, String transMonthMinus1){
		StringBuilder sql = new StringBuilder();
		
		sql.append("select D.MIN_POINT as \"minPoint\", ")
			.append(" to_char(to_date(D.TRANS_DATE,'yyyymmdd'),'yyyymmdd') as \"transDate\", ")
			.append("to_char(D.CPU_PERCENT,'fm990.09') AS \"XTZY_CPUU\", ")
			.append("to_char(D.MEM_PERCENT,'fm990.09') AS \"XTZY_NCCC\", ")
			.append("to_char(D.DISK_PERCENT,'fm990.09') AS \"XTZY_CPIO\", ")
			.append("nvl(C.COUNT_AMOUNT,0) AS \"WFJY_HZZZ\", ")
			.append("nvl(E.BATCH_TIME,0) AS \"PLTJ_PLSD\", ")
			.append("nvl(H.COUNT_AMOUNT,0) AS \"WFJY_QYHZPJ\" ")
			.append("FROM SYS_RESRC D, ")
				.append("(select A.APL_CODE AS APL_CODE, A.TRANS_DATE AS TRANS_DATE, A.TRANS_NAME AS TRANS_NAME, A.MIN_POINT AS MIN_POINT, A.COUNT_AMOUNT AS COUNT_AMOUNT, B.SRV_CODE AS SRV_CODE ")
				.append("from FIVE_MIN_TRANS A, SYS_RESRC_TRANS B ")
				.append("WHERE   A.APL_CODE = :aplCode AND ")
				.append("A.APL_CODE = B.APL_CODE AND ")
				.append("B.SRV_CODE = :srvCode AND ")
				.append("A.TRANS_NAME = B.TRAN_NAME AND ")
				.append("((A.TRANS_DATE = :endDate AND to_date(A.MIN_POINT,'hh24:mi') >= to_date('7:05','hh24:mi') AND ")
				.append("to_date(A.MIN_POINT,'hh24:mi') <= to_date('23:59','hh24:mi')) OR ")
				.append("(A.TRANS_DATE = :endDatePlus1 AND to_date(A.MIN_POINT,'hh24:mi') <= to_date('7:05','hh24:mi') AND ")
				.append("to_date(A.MIN_POINT,'hh24:mi') >= to_date('0:00','hh24:mi'))) ")
				.append("AND B.TRAN_NAME=:transName) C, ") //交易名（ALL,CSR...）


				.append("(select distinct F.MIN_POINT, decode(G.END_FLG, 0,10000) as BATCH_TIME ")
				.append("from SYS_RESRC F, batch_trans G ")
				.append("where G.APL_CODE=F.APL_CODE AND ")
				.append("G.BATCH_DATE = :endDate AND ")
				.append("G.BATCH_DATE = F.TRANS_DATE AND ")
				.append("F.SRV_CODE = :srvCode AND ")
				.append("F.APL_CODE = :aplCode AND ")
				.append("TO_DATE(F.MIN_POINT,'hh24:mi') >= to_date(substr(G.batch_start_time,10,5),'hh24:mi')-5/(24*60) AND ")
				.append("TO_DATE(F.MIN_POINT,'hh24:mi') <= to_date(substr(G.BATCH_END_TIME,10,5),'hh24:mi')+5/(24*60)) E, ")
				.append("(select K.MIN_POINT, K.COUNT_AMOUNT ")
				.append("from FIVE_MIN_TRANS_AVE_MON K ")
				.append("where K.APL_CODE = :aplCode AND ")
				.append("K.TRANS_MONTH = :transMonthMinus1 AND ")
				.append("K.HOLIDAY_FLAG = :holidayFlag ")
				.append("AND K.TRANS_NAME=:transName) H ")//交易名（ALL,CSR...）


			.append("WHERE   D.APL_CODE =  :aplCode ")
			.append("AND D.SRV_CODE =  :srvCode ")
			.append("AND ((D.TRANS_DATE = :endDate AND to_date(D.MIN_POINT,'hh24:mi') >= to_date('7:05','hh24:mi') ")
			.append("AND to_date(D.MIN_POINT,'hh24:mi') <= to_date('23:59','hh24:mi')) ")
			.append("OR (D.TRANS_DATE = :endDatePlus1 AND to_date(D.MIN_POINT,'hh24:mi') <= to_date('7:05','hh24:mi') ")
			.append("AND   to_date(D.MIN_POINT,'hh24:mi') >= to_date('0:00','hh24:mi'))) ")
			.append("AND   D.MIN_POINT = C.MIN_POINT(+) ")
			.append("AND   D.MIN_POINT = E.MIN_POINT(+) ")
			.append("AND   D.MIN_POINT = H.MIN_POINT(+) ")
			.append("ORDER BY D.TRANS_DATE, to_date(D.MIN_POINT,'hh24:mi') ");
				
		
		return getSession().createSQLQuery(sql.toString())
									 .setString("aplCode", aplCode)
									 .setString("srvCode", srvCode)
									 .setString("endDate", endDate)
									 .setString("endDatePlus1", endDatePlus1)
									 .setString("transName", tranName)
									 .setString("transMonthMinus1", transMonthMinus1)
									 .setString("holidayFlag", holidayFlag)
									 .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
									 .list();
	}
	
	/**
	 * 查询五分钟系统资源统计表数据(无交易量、批量时间段、前月每5分钟平均交易量)
	 * @param aplCode 应用系统编号
	 * @param endDate 日报日期
	 * @param srvCode 服务器编号


	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(value = "maoprpt", readOnly = true)
	public List<Map<String, Object>> findRptSysResrc(String aplCode, List<String> srvCodes, String endDate, String endDatePlus1){
		StringBuilder sql = new StringBuilder();
		
		sql.append("select ")
		.append(" sr.apl_code as \"aplCode\", ")
		.append(" to_char(to_date(sr.trans_date,'yyyymmdd'),'yyyymmdd') as \"transDate\", ")
		.append(" sr.srv_code as \"srvCode\", ")
		.append(" sr.min_point as \"minPoint\", ")
		.append(" sr.cpu_percent as \"XTZY_CPUU\", ")
		.append(" sr.mem_percent as \"XTZY_NCCC\", ")
		.append(" sr.disk_percent as \"XTZY_CPIO\" ")
		.append(" from sys_resrc sr ")
		.append(" where sr.apl_code = :aplCode ")
		.append(" and sr.srv_code in (:srvCodes) ")
		.append(" and ( ")
		.append("(sr.trans_date = :endDate and to_date(sr.min_point,'hh24:mi') >= to_date('7:05','hh24:mi') and to_date(sr.min_point,'hh24:mi') <= to_date('23:59','hh24:mi')) ")
		.append(" or ")
		.append("(sr.trans_date = :endDatePlus1 and to_date(sr.min_point,'hh24:mi') <= to_date('7:05','hh24:mi') and to_date(sr.min_point,'hh24:mi') >= to_date('0:00','hh24:mi')) ")
		.append(" ) ")
		.append("order by sr.srv_code, sr.trans_date, to_date(sr.min_point,'hh24:mi')");
		
		return getSession().createSQLQuery(sql.toString())
									 .setString("aplCode", aplCode)
									 .setParameterList("srvCodes", srvCodes)
									 .setString("endDate", endDate)
									 .setString("endDatePlus1", endDatePlus1)
									 .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
									 .list();
	}
	
	
	@Override
	public void getColumns(List<RptItemConfVo> itemList, ModelMap modelMap,
			Object... options) {
		StringBuilder fieldsNames = new StringBuilder();
		StringBuilder columnModels = new StringBuilder();
		List<String> columnHeaderGroupList = new ArrayList<String>();
		String field = "unkown";
		
		if(options.length > 0 && ((String) options[0]).split(CommonConst.STRING_COMMA).length > 1){
			String subSheetName = (String) options[0];
			Map<String, String> fieldsNmMap = new HashMap<String, String>();
			/*fieldsNmMap.put("cpu使用率"), "XTZY_CPUU");
			fieldsNmMap.put("内存使用率"), "XTZY_NCCC");
			fieldsNmMap.put("磁盘IO使用率"), "XTZY_CPIO");
			*/
			fieldsNmMap.put("cpu使用率", "XTZY_CPUU");
			fieldsNmMap.put("内存使用率", "XTZY_NCCC");
			fieldsNmMap.put("磁盘IO使用率", "XTZY_CPIO");
			
			for (String mapKey : fieldsNmMap.keySet()) {
				columnHeaderGroupList.add(mapKey);
			}
			fieldsNames.append("[");
			columnModels.append("[new Ext.grid.RowNumberer(),");
			fieldsNames.append("{name:'")
							.append("minPoint")
							.append("'},");
			columnModels.append("{header:'")
							.append("监控时间点")
							.append("',")
							.append("dataIndex:'")
							.append("minPoint")
							.append("',")
							.append(" sortable : true},");
			for (String groupKey : fieldsNmMap.keySet()) {
				for (String _subSheetName : subSheetName.split(CommonConst.STRING_COMMA)) {
					if(_subSheetName.split(" ").length ==3){
						fieldsNames.append("{name:'")
							.append(fieldsNmMap.get(groupKey).concat(_subSheetName.split(" ")[2]))
							.append("'}");
						
						columnModels.append("{header:'")
							.append(_subSheetName.split(" ")[2])
							.append("',")
							.append("dataIndex:'")
							.append(fieldsNmMap.get(groupKey).concat(_subSheetName.split(" ")[2]))
							.append("',")
							.append(" sortable : true,")
							.append("width : 150}");
					}else if(_subSheetName.split(" ").length ==2){
						fieldsNames.append("{name:'")
							.append(fieldsNmMap.get(groupKey).concat(_subSheetName.split(" ")[1]))
							.append("'}");
						columnModels.append("{header:'")
							.append(_subSheetName.split(" ")[1])
							.append("',")
							.append("dataIndex:'")
							.append(fieldsNmMap.get(groupKey).concat(_subSheetName.split(" ")[1]))
							.append("',")
							.append(" sortable : true,")
							.append("width : 150}");
					}
					
					fieldsNames.append(",");
					columnModels.append(",");
				}
			}
			fieldsNames.append("{name : 'statisticalFlag'}");	 //统计值标识


			columnModels.append("{header : '").append("统计值标识").append("',")
								.append("dataIndex : '").append("statisticalFlag").append("',")
								.append("sortable : true").append(",")
								.append("hidden : true")
								.append("}");		//统计值标识


			fieldsNames.append("]");
			columnModels.append("]");
			
			modelMap.addAttribute("columnHeaderGroupColspan", subSheetName.split(CommonConst.STRING_COMMA).length);
			modelMap.addAttribute("columnHeaderGroupList", columnHeaderGroupList);
			modelMap.addAttribute("fieldsNames", fieldsNames.toString());
			modelMap.addAttribute("columnModel", columnModels.toString());
		}else{
			Map<String, String> fieldsNmMap = new HashMap<String, String>();
			fieldsNmMap.put("监控时间点", "minPoint");
			fieldsNmMap.put("cpu使用率", "XTZY_CPUU");
			fieldsNmMap.put("内存使用率", "XTZY_NCCC");
			fieldsNmMap.put("磁盘IO使用率", "XTZY_CPIO");
			fieldsNmMap.put("批量时段", "PLTJ_PLSD");
			fieldsNmMap.put("五分钟交易量汇总", "WFJY_HZZZ");
			fieldsNmMap.put("前月每五分钟平均交易量", "WFJY_QYHZPJ");
			
			for(int i = 0; i < itemList.size(); i++){
				if(i == 0){
					fieldsNames.append("[");
					columnModels.append("[new Ext.grid.RowNumberer(),");
				}
				if(itemList.get(i).getItemCd().equals("监控时间点")){
					if(fieldsNmMap.get(itemList.get(i).getItemCd()) != null){
						field = fieldsNmMap.get(itemList.get(i).getItemCd());
					}
					fieldsNames.append("{name:'")
									  .append(field)
									  .append("'}");
				
					columnModels.append("{header:'")
					.append(itemList.get(i).getItemCd())
					.append("',")
					.append("dataIndex:'")
					.append(field)
					.append("',")
					.append(" sortable : true,")
					.append("width : 150}");
				}else{
					if(fieldsNmMap.get(itemList.get(i).getItemName()) != null){
						field = fieldsNmMap.get(itemList.get(i).getItemName());
					}
					fieldsNames.append("{name:'")
									  .append(field)
									  .append("'}");
					columnModels.append("{header:'")
					.append(itemList.get(i).getItemName())
					.append("',")
					.append("dataIndex:'")
					.append(field)
					.append("',")
					.append(" sortable : true,")
					.append("width : 150}");
				}
				
				if(i == itemList.size() - 1){
					fieldsNames.append(",{name : 'statisticalFlag'}");	 //统计值标识


					columnModels.append(",{header : '").append("统计值标识").append("',")
										.append("dataIndex : '").append("statisticalFlag").append("',")
										.append("sortable : true").append(",")
										.append("hidden : true")
										.append("}");		//统计值标识


					fieldsNames.append("]");
					columnModels.append("]");
				}else{
					fieldsNames.append(",");
					columnModels.append(",");
				}
			}
			modelMap.addAttribute("fieldsNames", fieldsNames.toString());
			modelMap.addAttribute("columnModel", columnModels.toString());
		}
		
	}

	@Transactional(value = "maoprpt", readOnly = true)
	@Override
	public Map<String, Object> getRptData(List<RptItemConfVo> itemList,
			String sheetName, String aplCode, String startDate, String endDate,
			Object... options) throws Exception {
		Map<String,Object> dateTransData = null;
		if(options.length > 0){
			String subSheetName = (String) options[0];
			if(subSheetName.split(CommonConst.STRING_COMMA).length > 1){
				dateTransData = getSysresrcForMoreSrvCode(itemList, aplCode, startDate, endDate, sheetName, subSheetName);
			}else{
				dateTransData = getSysresrc(itemList, aplCode, startDate, endDate, sheetName, subSheetName);
			}
		}
		return dateTransData;
	}

	@Override
	public Map<String, String> getChart(List<RptItemConfVo> itemList,
			List<RptChartConfVo> chartsList,
			List<Map<String, Object>> metedataMapList, Object...options)
			throws Exception {
		Map<String, String> chartMap = null;
		String subSheetName = "";
		if(options.length > 0){
			subSheetName = (String) options[0];
		}
		if(subSheetName.split(CommonConst.STRING_COMMA).length > 1){
			chartMap = getSysresrcChartForMoreSrvCode(itemList, chartsList, metedataMapList, subSheetName);
		}else{
			chartMap = getSysresrcChart(itemList, chartsList, metedataMapList);
		}
		
		return chartMap;
	}

	@Override
	public Map<String, String> getConfigurableXlsColumns(
			List<RptItemConfVo> elist, Object... options) {
		String subSheetName = "";
		if(options.length > 0){
			subSheetName = (String) options[0];
		}
		
		Map<String, String> columns = new LinkedHashMap<String, String>();
		if(subSheetName.split(CommonConst.STRING_COMMA).length > 1){
			LinkedHashMap<String,Object> colsMap = new LinkedHashMap<String,Object>();
			colsMap.put("XTZY_CPUU", "cpu使用率");
			colsMap.put("XTZY_NCCC", "内存使用率");
			colsMap.put("XTZY_CPIO", "磁盘IO使用率");
			
			columns.put("rows", "2");
			columns.put("minPoint", "监控时间点");
			//diskPercentCEB-IVR-8=磁盘IO使用率_CEB-IVR-8
			for (String colKey : colsMap.keySet()) {
				for (String _subSheetName : subSheetName.split(CommonConst.STRING_COMMA)) {
					if(_subSheetName.split(" ").length == 3){
						columns.put(colKey.concat(_subSheetName.split(" ")[2]),colsMap.get(colKey).toString().concat(CommonConst.UNDERLINE).concat(_subSheetName.split(" ")[2]));
					}else if(_subSheetName.split(" ").length == 2){
						columns.put(colKey.concat(_subSheetName.split(" ")[1]),colsMap.get(colKey).toString().concat(CommonConst.UNDERLINE).concat(_subSheetName.split(" ")[1]));
					}
				}
			}
		}else{
			columns.put("minPoint", "监控时间点");
			columns.put("XTZY_CPUU","cpu使用率");
			columns.put("XTZY_NCCC","内存使用率");
			columns.put("XTZY_CPIO","磁盘IO使用率");
			columns.put("PLTJ_PLSD","批量时段");
			columns.put("WFJY_HZZZ","五分钟交易量汇总");
			columns.put("WFJY_QYHZPJ","前月每五分钟平均交易量");
		}
		
		return columns;
	}
	
	/**
	 * 通过访问系统资源表动态获取数据(系统资源使用率图表—查询比较多个主机系统资源)
	 * @param itemList 报表科目配置表科目列表

	 * @param aplCode 系统编号
	 * @param startDate 起始日期
	 * @param endDate 日报日期
	 * @param sheetName 功能名

	 * @param subSheetName 子功能名称

	 * @return
	 * @throws Exception 
	 * @throws NumberFormatException 
	 */
	private Map<String, Object> getSysresrcForMoreSrvCode(List<RptItemConfVo> itemList, 
																							String aplCode, 
																							String startDate,
																							String endDate, 
																							String sheetName,
																							String subSheetName) throws NumberFormatException, Exception {
		Map<String, Object> returnDataMap = new HashMap<String, Object>();
		List<Map<String, Object>> dataList = new ArrayList<Map<String,Object>>();
		LinkedHashMap<String,Map<String,Object>> groupDataMap = new LinkedHashMap<String, Map<String,Object>>();
		List<Map<String, Object>> returnDataList = new ArrayList<Map<String,Object>>();
		List<String> srvCodes = new ArrayList<String>();
		String _srvCode = null;
		String _endDatePlus1 = null;
		try{
			//查询多个主机的系统资源

			for (String _subName : subSheetName.split(CommonConst.STRING_COMMA)) {
				String tranNameAndSrvCodes[] = _subName.split(" ");
				if (tranNameAndSrvCodes.length == 3) {
					// 服务器类型、交易名称、服务器编码组合（WEB IVR CEB-IVR-8）


					_srvCode = tranNameAndSrvCodes[2];
				}else if (tranNameAndSrvCodes.length == 2){
					//服务器类型、服务器编码组合（WEB CEB-IVR-8）


					_srvCode = tranNameAndSrvCodes[1];
				}
				srvCodes.add(_srvCode);
			}
			//基于日报日期的下一日


			_endDatePlus1 = DateFunction.getDateByFormatAndOffset(endDate, 0, 1);
			// 查询数据
			dataList = findRptSysResrc(aplCode, srvCodes, endDate, _endDatePlus1);
			//增加分组系统资源数据
			Map<String, String> columns = new HashMap<String, String>();
			columns.put("XTZY_CPUU","cpu使用率");
			columns.put("XTZY_NCCC","内存使用率");
			columns.put("XTZY_CPIO","磁盘IO使用率");
			for (String colKey : columns.keySet()) {
				for (Map<String, Object> dMap : dataList) {
					if(null != groupDataMap.get(dMap.get("minPoint"))){
						groupDataMap.get(dMap.get("minPoint")).put(colKey.concat(dMap.get("srvCode").toString()), dMap.get(colKey));
					}else{
						dMap.put(colKey.concat(dMap.get("srvCode").toString()), dMap.get(colKey));
						groupDataMap.put(dMap.get("minPoint").toString(), dMap);
					}
				}
			}
			for (String groupKey : groupDataMap.keySet()) {
				groupDataMap.get(groupKey).put("minPoint", groupKey);
				returnDataList.add(groupDataMap.get(groupKey));
			}
			
			// 元数据

			returnDataMap.put("metadata", returnDataList);
			return returnDataMap;
		} catch (Exception ex) {
			throw ex;
		}
	}
	
	/**
	 * 通过访问系统资源表动态获取数据(系统资源使用率图表)
	 * @param itemList 报表科目配置表科目列表

	 * @param aplCode 系统编号
	 * @param startDate 起始日期
	 * @param endDate 日报日期
	 * @param sheetName 功能名

	 * @param subSheetName 子功能名称

	 * @return
	 * @throws Exception 
	 * @throws NumberFormatException 
	 */
	private Map<String, Object> getSysresrc(List<RptItemConfVo> itemList, 
																	String aplCode, 
																	String startDate,
																	String endDate, 
																	String sheetName,
																	String subSheetName) throws NumberFormatException, Exception {
		Map<String, Object> returnDataMap = new HashMap<String, Object>();
		List<Map<String, Object>> dataList = new ArrayList<Map<String,Object>>();
		List<String> srvCodes = new ArrayList<String>();
		String holidayFlag = null;
		String _srvCode = null;
		String _tranName = null;
		String _endDatePlus1 = null;
		String transMonthMinus1 = null;
		boolean hasTranAmount = false;
		try{
			//节假日判断

			SysDateVo sysDateVo = sysDateService.findByPrimaryKey(endDate);
			if(null != sysDateVo){
				holidayFlag = "2"; //休日
			}else{
				holidayFlag = "1"; //工作日

			}
			String tranNameAndSrvCodes[] = subSheetName.split(" ");
			if (tranNameAndSrvCodes.length == 3) {
				// 服务器类型、交易名称、服务器编码组合（WEB IVR CEB-IVR-8）

				_tranName = tranNameAndSrvCodes[1];
				_srvCode = tranNameAndSrvCodes[2];
			}else if (tranNameAndSrvCodes.length == 2){
				//服务器类型、服务器编码组合（WEB CEB-IVR-8）

				_srvCode = tranNameAndSrvCodes[1];
			}
			//基于日报日期的下一日

			_endDatePlus1 = DateFunction.getDateByFormatAndOffset(endDate, 0, 1);
			//基于日报日期的前一月份
			transMonthMinus1 = DateFunction.getDateMonthByFormatAndOffset(endDate, 0, -1).substring(0, 6);
			//判断是否存在统计交易量信息字段

			for (RptItemConfVo ivo :  itemList) {
				if("WFJY_HZZZ".equals(ivo.getItemCd())){
					hasTranAmount = true;
					break;
				}
			}
			if(hasTranAmount){
				dataList = findRptSysResrc(aplCode, _srvCode, _tranName, endDate, _endDatePlus1, holidayFlag,transMonthMinus1);
			}else{
				srvCodes.add(_srvCode);
				dataList = findRptSysResrc(aplCode, srvCodes, endDate, _endDatePlus1);
			}
			//编辑最大最小平均值

			List<Double> statisticalValList  = null;
			Map<String,Object> dataMap = null;
			// 存储合计值map对象
			LinkedHashMap<String,Map<String,Object>> statisticalKeyMap = new LinkedHashMap<String, Map<String,Object>>();
			// 存储合计值数据列表

			List<Map<String,Object>> statisticalDataList  = new ArrayList<Map<String,Object>>();
			Map<String, String> statisticalMap = new LinkedHashMap<String, String>();
			statisticalMap.put("XTZY_CPUU",  "cpu使用率");
			statisticalMap.put("XTZY_NCCC", "内存使用率");
			statisticalMap.put("XTZY_CPIO", "磁盘IO使用率");
			statisticalMap.put("WFJY_HZZZ", "五分钟交易量汇总");
			statisticalMap.put("PLTJ_PLSD", "批量时段");
			statisticalMap.put("WFJY_QYHZPJ", "前月每五分钟平均交易量");


			/*yAxisMap.put("minPoint", "监控时间点");
			yAxisMap.put("PLTJ_PLSD", "批量时段");
			yAxisMap.put("WFJY_QYHZPJ", "前月每五分钟平均交易量");*/
			
			for (String key : statisticalMap.keySet()) {
				statisticalValList  = new ArrayList<Double>();
				for (Map<String, Object> dMap : dataList) {
					if(null != dMap.get(key)){
						statisticalValList.add(Double.valueOf(dMap.get(key).toString()));
					}
				}
				if(statisticalValList.size() != 0){
					// 最大值

					if(null == statisticalKeyMap.get("最大值")){
						dataMap = new HashMap<String, Object>();
						dataMap.put(key, NumberUtil.getMaxValue(statisticalValList));
						dataMap.put("statisticalFlag", CommonConst.STATISTICAL_FLAG);
						statisticalKeyMap.put("最大值", dataMap);
					}else{
						statisticalKeyMap.get("最大值").put(key, NumberUtil.getMaxValue(statisticalValList));
					}
					// 最小值

					if(null == statisticalKeyMap.get("最小值")){
						dataMap = new HashMap<String, Object>();
						dataMap.put(key, NumberUtil.getMinValue(statisticalValList));
						dataMap.put("statisticalFlag", CommonConst.STATISTICAL_FLAG);
						statisticalKeyMap.put("最小值", dataMap);
					}else{
						statisticalKeyMap.get("最小值").put(key, NumberUtil.getMinValue(statisticalValList));
					}
					// 平均值

					if(null == statisticalKeyMap.get("平均值")){
						dataMap = new HashMap<String, Object>();
						dataMap.put(key, NumberUtil.getAvgValue(statisticalValList));
						dataMap.put("statisticalFlag", CommonConst.STATISTICAL_FLAG);
						statisticalKeyMap.put("平均值", dataMap);
					}else{
						statisticalKeyMap.get("平均值").put(key, NumberUtil.getAvgValue(statisticalValList));
					}
				}
			}
			for (String key : statisticalKeyMap.keySet()) {
				statisticalKeyMap.get(key).put("minPoint", key);
				statisticalDataList.add(statisticalKeyMap.get(key));
			}
			
			// 元数据

			returnDataMap.put("metadata", dataList);
			// 统计值数据

			returnDataMap.put("statisticalData", statisticalDataList);
			return returnDataMap;
		} catch (Exception ex) {
			throw ex;
		}
	}
	
	/**
	* 创建图表配置数据(系统资源使用率图表—查询比较多个主机系统资源)
	 * @param itemList 报表科目配置表数据

	 * @param chartsList 报表图表配置表数据

	 * @param metedataMapList 图表元数据

	 * @param endDate 日报日期
	 * @return
	 * @throws Exception
	 */
	private Map<String, String> getSysresrcChartForMoreSrvCode(List<RptItemConfVo> itemList,
																									List<RptChartConfVo> chartsList,
																									List<Map<String, Object>> metedataMapList,
																									String subSheetName) throws Exception{
		//动态列
		Map<String, String> yAxisMap = new LinkedHashMap<String, String>();
		yAxisMap.put("XTZY_CPUU",  "cpu使用率");
		yAxisMap.put("XTZY_NCCC", "内存使用率");
		yAxisMap.put("XTZY_CPIO", "磁盘IO使用率");
		StringBuilder charOptions = null;
		StringBuilder titleOption = null;
		StringBuilder yAxisOptions = null;
		StringBuilder xCategoriesOptions = null;
		StringBuilder toolTipUnit = null;
		StringBuilder seriesOptions = null;
		Map<String, String> chartMap = new HashMap<String,String>();
		List<List<RptChartConfVo>> mutipleDataChartList = new ArrayList<List<RptChartConfVo>>();//存储存在左右Y轴的两条数据
		List<RptChartConfVo> dataChartList = null;//new ArrayList<RptChartConfVo>();
		try{
			for(int i = 0; i < chartsList.size(); i++){
				RptChartConfVo vo1 = chartsList.get(i);
				dataChartList = new ArrayList<RptChartConfVo>();
				dataChartList.add(vo1);
				chartsList.remove(i);
				i--;
				for(int j = i + 1; j < chartsList.size(); j++){
					RptChartConfVo vo2 = chartsList.get(j);
					if(vo1.getAplCode().equals(vo2.getAplCode()) 
							&& vo1.getReportType().equals(vo2.getReportType())
							&& vo1.getSheetName().equals(vo2.getSheetName())
							&& vo1.getChartName().equals(vo2.getChartName())
							&& vo1.getChartType().equals(vo2.getChartType())
							&& vo1.getChartSeq() == vo2.getChartSeq()){
						dataChartList.add(vo2);
						chartsList.remove(vo2);
						j--;
					}
					
				}
				mutipleDataChartList.add(dataChartList);
			}
			
			int chartCount = 0;
			for(String mapKey : yAxisMap.keySet()){
				charOptions = new StringBuilder();
				titleOption = new StringBuilder();
				yAxisOptions = new StringBuilder();
				xCategoriesOptions = new StringBuilder();
				toolTipUnit = new StringBuilder();
				seriesOptions = new StringBuilder();
				for(int i = 0; i < mutipleDataChartList.size(); i++){
					List<RptChartConfVo> multiChartList = mutipleDataChartList.get(i);
					
					//标题
					titleOption.append("资源使用率对比图（每五分钟一次）").append(CommonConst.UNDERLINE).append(yAxisMap.get(mapKey));
					// Y轴信息(左&右)
					yAxisOptions.append("{\"yAxis\":[");
					boolean checkFlag = false;
					for(int j = 0; j < multiChartList.size(); j++){
						for(String key : yAxisMap.keySet()){
							String getItemCdApp = rptItemConfService.getItemCdApp(multiChartList.get(j).getAplCode(), yAxisMap.get(key));
							if(multiChartList.get(j).getItemList().indexOf(getItemCdApp) != -1){
								checkFlag = true;
							}
						}
						if(checkFlag){
							yAxisOptions.append("{\"yAxisTitle\":").append("\"").append(ComUtil.checkNull(multiChartList.get(j).getChartYaxisTitle())).append("\"").append(CommonConst.COMMA)
							.append("\"yAxisMinval\":").append(NumberUtil.formatNumByUnit(multiChartList.get(j).getChartYaxisMinval(), ComUtil.checkNull(multiChartList.get(j).getChartYaxisUnit()))).append(CommonConst.COMMA)
							.append("\"yAxisMaxval\":").append(NumberUtil.formatNumByUnit(multiChartList.get(j).getChartYaxisMaxval(), ComUtil.checkNull(multiChartList.get(j).getChartYaxisUnit()))).append(CommonConst.COMMA)
							.append("\"yAxisInterval\":").append(NumberUtil.formatNumByUnit(multiChartList.get(j).getChartYaxisInterval(), ComUtil.checkNull(multiChartList.get(j).getChartYaxisUnit()))).append(CommonConst.COMMA)
							.append("\"yAxisUnit\":").append("\"").append(ComUtil.checkNull(multiChartList.get(j).getChartYaxisUnit())).append("\"").append(CommonConst.COMMA)
							.append("\"yAxisPosition\":").append(multiChartList.get(j).getChartYaxisPosition())
							.append("}");
							if(j != multiChartList.size() - 1){
								yAxisOptions.append(",");
							}
						}
						checkFlag = false;
					}
					if(CommonConst.STRING_COMMA.equals(yAxisOptions.toString().substring(yAxisOptions.length()-1))){
						yAxisOptions.deleteCharAt(yAxisOptions.length()-1);
					}
					yAxisOptions.append("]}");
					// X轴科目信息


					for (Map<String, Object> _map : metedataMapList) {
						xCategoriesOptions.append(_map.get("minPoint")).append(CommonConst.COMMA);
					}
					if(xCategoriesOptions.length() != 0){
						xCategoriesOptions.deleteCharAt(xCategoriesOptions.length() -1);
					}
					//坐标tip提示信息数组
					toolTipUnit.append("{");
					int count = 0;
					for(int j = 0; j < itemList.size(); j++){
						RptItemConfVo vo = itemList.get(j);
						if(vo.getExpressionUnit() != null){
							count ++;
							toolTipUnit.append("\\'" + vo.getItemName() + "\\':\\'" + vo.getExpressionUnit() + "\\',");
						}
						if(count > 0 && j == itemList.size() - 1){
							toolTipUnit.deleteCharAt(toolTipUnit.length() - 1);
						}
					}
					toolTipUnit.append("}");
					// 图表统计科目信息
					seriesOptions.append("[");
					for(String subName : subSheetName.split(CommonConst.STRING_COMMA)){
						seriesOptions.append("{name:\"").append(yAxisMap.get(mapKey).concat("(").concat(subName).concat(")")).append("\",").append("data:[");
						for (Map<String,Object> meteMap : metedataMapList) {
							if(subName.split(" ").length ==3){
								seriesOptions.append(meteMap.get(mapKey.concat(subName.split(" ")[2])));
							}else if(subName.split(" ").length ==2){
								seriesOptions.append(meteMap.get(mapKey.concat(subName.split(" ")[1])));
							}
							seriesOptions.append(CommonConst.COMMA);
						}
						if(metedataMapList.size() != 0){
							seriesOptions.deleteCharAt(seriesOptions.length()-1);
						}
						seriesOptions.append("]");
						seriesOptions.append(", yAxis :  "+ 0 +"},");
					}
					// 删除最后一个多余逗号
					seriesOptions.deleteCharAt(seriesOptions.length() - 1);
					seriesOptions.append("]");
					
					// 编辑返回JSON数据
					charOptions.append("{")
					.append("\"chartType\":").append("\"").append(multiChartList.get(0).getChartType()).append("\"").append(CommonConst.COMMA)
					.append("\"titleOption\":").append("\"").append(titleOption.toString()).append("\"").append(CommonConst.COMMA)
					.append("\"yAxisOptions\":").append(yAxisOptions.toString()).append(CommonConst.COMMA)
					.append("\"xCategoriesOptions\":").append("\"").append(xCategoriesOptions).append("\"").append(CommonConst.COMMA)
					.append("\"toolTipUnit\":").append("\"").append(toolTipUnit).append("\"").append(CommonConst.COMMA)
					.append("\"seriesOptions\":").append(seriesOptions.toString().replaceAll(CommonConst.PERCENT_SYMBOL, ""))
					.append("}");
				}
				chartMap.put("rptChart" + chartCount, charOptions.toString());
				chartCount++;
			}
			
			return chartMap;
		} catch (Exception ex) {
			throw ex;
		}
	}
	
	/**
	* 创建图表配置数据(系统资源使用率图表)
	 * @param itemList 报表科目配置表数据

	 * @param chartsList 报表图表配置表数据

	 * @param metedataMapList 图表元数据

	 * @return
	 * @throws Exception
	 */
	private Map<String, String> getSysresrcChart(List<RptItemConfVo> itemList,
																		List<RptChartConfVo> chartsList,
																		List<Map<String, Object>> metedataMapList) throws Exception{
		//动态列
		Map<String, String> yAxisMap = new LinkedHashMap<String, String>();
		yAxisMap.put("minPoint", "监控时间点");
		yAxisMap.put("XTZY_CPUU",  "cpu使用率");
		yAxisMap.put("XTZY_NCCC", "内存使用率");
		yAxisMap.put("XTZY_CPIO", "磁盘IO使用率");
		yAxisMap.put("PLTJ_PLSD", "批量时段");
		yAxisMap.put("WFJY_HZZZ", "五分钟交易量汇总");
		yAxisMap.put("WFJY_QYHZPJ", "前月每五分钟平均交易量");
		StringBuilder charOptions = null ;
		StringBuilder titleOption = null ;
		StringBuilder yAxisOptions = null ;
		StringBuilder xCategoriesOptions = null ;
		StringBuilder toolTipUnit = null ;
		StringBuilder seriesOptions = null ;
		Map<String, String> chartMap = new HashMap<String,String>();
		List<List<RptChartConfVo>> mutipleDataChartList = new ArrayList<List<RptChartConfVo>>();//存储存在左右Y轴的两条数据
		List<RptChartConfVo> dataChartList = null;//new ArrayList<RptChartConfVo>();
		Integer countItemLevelType = 1;
		try{
			for(int i = 0; i < chartsList.size(); i++){
				RptChartConfVo vo1 = chartsList.get(i);
				dataChartList = new ArrayList<RptChartConfVo>();
				dataChartList.add(vo1);
				chartsList.remove(i);
				i--;
				for(int j = i + 1; j < chartsList.size(); j++){
					RptChartConfVo vo2 = chartsList.get(j);
					if(vo1.getAplCode().equals(vo2.getAplCode()) 
							&& vo1.getReportType().equals(vo2.getReportType())
							&& vo1.getSheetName().equals(vo2.getSheetName())
							&& vo1.getChartName().equals(vo2.getChartName())
							&& vo1.getChartType().equals(vo2.getChartType())
							&& vo1.getChartSeq() == vo2.getChartSeq()){
						dataChartList.add(vo2);
						chartsList.remove(vo2);
						j--;
					}
					
				}
				mutipleDataChartList.add(dataChartList);
			}
			
			for(int i = 0; i < mutipleDataChartList.size(); i++){
				charOptions = new StringBuilder();
				titleOption = new StringBuilder();
				yAxisOptions = new StringBuilder();
				xCategoriesOptions = new StringBuilder();
				toolTipUnit = new StringBuilder();
				seriesOptions = new StringBuilder();
				List<RptChartConfVo> multiChartList = mutipleDataChartList.get(i);
				titleOption.append(multiChartList.get(0).getChartName());
				// Y轴信息(左&右)
				yAxisOptions.append("{\"yAxis\":[");
				for(int j = 0; j < multiChartList.size(); j++){
					yAxisOptions.append("{\"yAxisTitle\":").append("\"").append(ComUtil.checkNull(multiChartList.get(j).getChartYaxisTitle())).append("\"").append(CommonConst.COMMA)
						.append("\"yAxisMinval\":").append(NumberUtil.formatNumByUnit(multiChartList.get(j).getChartYaxisMinval(), ComUtil.checkNull(multiChartList.get(j).getChartYaxisUnit()))).append(CommonConst.COMMA)
						.append("\"yAxisMaxval\":").append(NumberUtil.formatNumByUnit(multiChartList.get(j).getChartYaxisMaxval(), ComUtil.checkNull(multiChartList.get(j).getChartYaxisUnit()))).append(CommonConst.COMMA)
						.append("\"yAxisInterval\":").append(NumberUtil.formatNumByUnit(multiChartList.get(j).getChartYaxisInterval(), ComUtil.checkNull(multiChartList.get(j).getChartYaxisUnit()))).append(CommonConst.COMMA)
						.append("\"yAxisUnit\":").append("\"").append(ComUtil.checkNull(multiChartList.get(j).getChartYaxisUnit())).append("\"").append(CommonConst.COMMA)
						.append("\"yAxisPosition\":").append(multiChartList.get(j).getChartYaxisPosition())
						.append("}");
					if(j != multiChartList.size() - 1){
						yAxisOptions.append(",");
					}
				}
				yAxisOptions.append("]}");
				
				// X轴科目信息

				for (Map<String, Object> _map : metedataMapList) {
					xCategoriesOptions.append(_map.get("minPoint")).append(CommonConst.COMMA);
				}
				if(xCategoriesOptions.length() != 0){
					xCategoriesOptions.deleteCharAt(xCategoriesOptions.length() -1);
				}
				//坐标tip提示信息数组
				toolTipUnit.append("{");
				int count = 0;
				for(int j = 0; j < itemList.size(); j++){
					RptItemConfVo vo = itemList.get(j);
					if(vo.getExpressionUnit() != null){
						count ++;
						toolTipUnit.append("\\'" + vo.getItemName() + "\\':\\'" + vo.getExpressionUnit() + "\\',");
					}
					if(count > 0 && j == itemList.size() - 1){
						toolTipUnit.deleteCharAt(toolTipUnit.length() - 1);
					}
				}
				toolTipUnit.append("}");
				// 图表统计科目信息
				
				 Map<String,String>  checkmap=new HashMap<String, String>();
				if(multiChartList.size()>0){
			
				  List<Map<String,String>>  list= rptItemConfService.getItemMap(multiChartList.get(0).getAplCode());
				  for(Map<String,String> map:list){
					  checkmap.put(map.get("item_cd_app"), map.get("item_app_name"));
				  }
				}
				
				seriesOptions.append("[");
				for(int j = 0; j < multiChartList.size(); j++){
					for (String itemName : multiChartList.get(j).getItemList().split(",")) {
						/*for (RptItemConfVo iVo : itemList) {
							if(itemName.equals(iVo.getItemName())) countItemLevelType = iVo.getCountItemLevelType();
						}*/
					//	String getItemAppName1 = rptItemConfService.getItemAppName(multiChartList.get(j).getAplCode(),itemName);
						String getItemAppName1 =checkmap.get(itemName);
						seriesOptions.append("{name:\"").append(getItemAppName1).append("\",").append("data:[");
						if(ReptConstants.DEFAULT_COLUMN_KEY_BATCH_TIME.equals(itemName)){
							for(int k = 0; k < metedataMapList.size(); k++){
								for(String key : yAxisMap.keySet()){
									if(key.equals(itemName)){
										if(!"0".equals(metedataMapList.get(k).get(key).toString())){
											seriesOptions.append(metedataMapList.get(k).get(key));
										}else{
											seriesOptions.append("null");
										}
										break;
									}
								}
								if(k != metedataMapList.size() - 1){
									seriesOptions.append(CommonConst.COMMA);
								}
							}
						}else{
							for(int k = 0; k < metedataMapList.size(); k++){
								for(String key : yAxisMap.keySet()){
									//String getItemAppName2 = rptItemConfService.getItemAppName(multiChartList.get(j).getAplCode(),itemName);
									if(key.equals(itemName)){
										seriesOptions.append(metedataMapList.get(k).get(key));
										break;
									}
								}
								if(k != metedataMapList.size() - 1){
									seriesOptions.append(CommonConst.COMMA);
								}
							}
						}
						seriesOptions.append("]");
						seriesOptions.append(", yAxis :  "+ j +"},");
					}
				}
				// 删除最后一个多余逗号
				seriesOptions.deleteCharAt(seriesOptions.length() - 1);
				seriesOptions.append("]");
				
				// 编辑返回JSON数据
				charOptions.append("{")
								.append("\"chartType\":").append("\"").append(multiChartList.get(0).getChartType()).append("\"").append(CommonConst.COMMA)
								.append("\"titleOption\":").append("\"").append(titleOption.toString()).append("\"").append(CommonConst.COMMA)
								.append("\"yAxisOptions\":").append(yAxisOptions.toString()).append(CommonConst.COMMA)
								.append("\"xCategoriesOptions\":").append("\"").append(xCategoriesOptions).append("\"").append(CommonConst.COMMA)
								.append("\"toolTipUnit\":").append("\"").append(toolTipUnit).append("\"").append(CommonConst.COMMA)
								.append("\"seriesOptions\":").append(seriesOptions.toString().replaceAll(CommonConst.PERCENT_SYMBOL, ""))
								.append("}");
				chartMap.put("rptChart"+i, charOptions.toString());
			}
			
			return chartMap;
		} catch (Exception ex) {
			throw ex;
		}
	}

}
