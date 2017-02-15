package com.nantian.rept.service;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.common.system.service.AppInfoService;
import com.nantian.component.com.DataException;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.rept.vo.RptItemAppVo;

/**
 * 三级科目配置service
 * @author linaWang
 */
@Service
@Repository
public class ItemConfService {
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(ItemConfService.class);

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();
	
	@Autowired
    private AppInfoService appInfoService;
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	@Autowired
    private RptItemConfService rptItemConfService;
	
	/** HIBERNATE Session Factory */
	@Autowired
	private SessionFactory sessionFactoryMaopRpt;
	@Autowired
	 private SecurityUtils securityUtils; 
	
	public Session getSession() {
		return sessionFactoryMaopRpt.getCurrentSession();
	}

	/**
	 * 构造方法	 */
	public ItemConfService() {
		fields.put("apl_code", FieldType.STRING);
		fields.put("item_cd_app", FieldType.STRING);
		fields.put("item_cd_lvl1", FieldType.STRING);
		fields.put("item_cd_lvl2", FieldType.STRING);
		fields.put("item_app_name", FieldType.INTEGER);
		fields.put("item_app_ststcs_peak_flag", FieldType.STRING);
		fields.put("expression", FieldType.STRING);
		fields.put("item_creator", FieldType.STRING);
		fields.put("item_created", FieldType.TIMESTAMP);
		fields.put("item_modifier", FieldType.STRING);
		fields.put("item_modified", FieldType.TIMESTAMP);
		
	}
	
	/**
	 * 保存.
	 * @param RptItemAppVo
	 */
	@Transactional(value="maoprpt")
	public void save(RptItemAppVo itemConfVo) {
		getSession().save(itemConfVo);
	}
	
	/**
	 * 保存.更新
	 * @param RptItemAppVo
	 */
	@Transactional(value="maoprpt")
	public void saveOrupdate(RptItemAppVo itemConfVo) {
		getSession().saveOrUpdate(itemConfVo);
	}
	
	
	/**
	 * 通过主键查找唯一的一条记录	 * @param apl_code 系统编号
	 * @param item_cd_lvl1  一级科目
	 * @param item_cd_lvl2  二级科目
	 * @param item_cd_app  三级科目
	 * @return RptItemAppVo 三级科目实体
	 */
	@SuppressWarnings("unchecked")
	@Transactional(value = "maoprpt", propagation=Propagation.NOT_SUPPORTED, readOnly = true)
	public Map<String,Object> getItemConfById(String apl_code, String item_cd_app){
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(");
 		hql.append(" e.apl_code as apl_code,");
 		hql.append(" e.item_cd_lvl1 as item_cd_lvl1,");
 		hql.append(" e.item_cd_lvl2 as item_cd_lvl2,");
 		hql.append(" e.item_cd_app as item_cd_app,");
 		hql.append(" e.item_app_name as item_app_name,");
 		hql.append("e.item_app_ststcs_peak_flag as item_app_ststcs_peak_flag,");
 		hql.append(" e.expression as expression,");
 		hql.append(" e.item_creator as item_creator,");
 		hql.append(" to_char(e.item_created,'yyyy-MM-dd hh24:mi:ss') as item_created,");
 		hql.append("e.item_modifier as item_modifier,");
 		hql.append("to_char(e.item_modified,'yyyy-MM-dd hh24:mi:ss') as item_modified ");
		hql.append(" ) from RptItemAppVo e where e.apl_code=:apl_code ");
		hql.append(" and e.item_cd_app=:item_cd_app ");
		Query query = getSession().createQuery(hql.toString())
				.setString("apl_code", apl_code)
				.setString("item_cd_app", item_cd_app);
		return (Map<String, Object>) query.uniqueResult();
	}
	
	/**
	 * 根据ID批量删除.
	 * @param primaryKeys 主键数组[系统编号,一级科目,二级科目,三级科目]
	 */
	@Transactional("maoprpt")
	public void deleteByIds(String[] primaryKeys) {
		String[] keyArr = new String[4];
		for (String key : primaryKeys) {
			keyArr = key.split("#");
			deleteById(keyArr[0],keyArr[3]);
		}
	}
	
	/**
	 * 根据ID删除.
	 * @param apl_code 系统编号
	 * @param item_cd_lvl1  一级科目
	 * @param item_cd_lvl2  二级科目
	 * @param item_cd_app  三级科目
	 */
	@Transactional("maoprpt")
	public void deleteById(String apl_code, String item_cd_app) {
		getSession().createQuery("delete from RptItemAppVo ic where ic.apl_code=:apl_code  and ic.item_cd_app=:item_cd_app ")
			.setString("apl_code", apl_code)
			.setString("item_cd_app", item_cd_app)
			.executeUpdate();
	}

	/**
	 * 分页查询
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked"})
	public List<Map<String, Object>> getItemConfList(Integer start, Integer limit, String sort, String dir,
			Map<String, Object> params,HttpServletRequest request) {
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(");
 		hql.append("e.apl_code as apl_code,");
 		hql.append("e.item_cd_lvl1 as item_cd_lvl1,");
 		hql.append("e.item_cd_lvl2 as item_cd_lvl2,");
 		hql.append("e.item_cd_app as item_cd_app,");
 		hql.append("e.item_app_name as item_app_name,");
 		hql.append("e.expression as expression,");
 		hql.append("e.item_app_ststcs_peak_flag as item_app_ststcs_peak_flag,");
 		hql.append("e.item_creator as item_creator,");
 		hql.append("to_char(e.item_created,'yyyy-MM-dd hh24:mi:ss') as item_created,");
 	//	hql.append("to_char(e.item_created,'yyyy-MM-dd hh24:mi:ss') as item_created,");
 		hql.append("e.item_modifier as item_modifier,");
 		hql.append("to_char(e.item_modified,'yyyy-MM-dd hh24:mi:ss') as item_modified ");
		hql.append(") from RptItemAppVo e where e.apl_code in :sysList ");
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and e." + key + " like :" + key);
				} else {
					hql.append(" and e." + key + " = :" + key);
				}
			}
		}
		if(sort!=null && !sort.equals("")){
			hql.append(" order by e." + sort );
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
		query.setParameterList("sysList", appInfoService.getPersonalSysListForCheck());
		 List<Map<String, Object>> list =query.list();
		 
		 for(Map<String, Object> map :list){
			String item_cd_lvl1= rptItemConfService.getItemName("1",map.get("item_cd_lvl1").toString(),"");
			String item_cd_lvl2= rptItemConfService.getItemName("2",map.get("item_cd_lvl2").toString(),map.get("item_cd_lvl1").toString());
		 map.put("item_cd_lvl1_name", item_cd_lvl1);
		 map.put("item_cd_lvl2_name", item_cd_lvl2);
		 }
		 request.getSession().setAttribute("ItemConfList",list );
		 return list;
	}
	
	/**
	 * 获取总记录数
	 */
	@Transactional(readOnly = true)
	public Long countItemConfList(Map<String, Object> params) {
		StringBuilder hql = new StringBuilder();
		hql.append("select count(*) from RptItemAppVo e where e.apl_code in :sysList ");
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and e." + key + " like :" + key);
				} else {
					hql.append(" and e." + key + " = :" + key);
				}
			}
		}
		logger.info(hql.toString());
		Query query = getSession().createQuery(hql.toString());
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		query.setParameterList("sysList", appInfoService.getPersonalSysListForCheck());
		return Long.valueOf(query.uniqueResult().toString());
	}
	
	
	/**
	 * 查询   一级
	 * @param params
	 * @return
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(value = "maoprpt", readOnly = true)
	public List<Map<String,Object>> getLvl1Store(String aplCode) {

		StringBuilder hql = new StringBuilder();
		hql.append(" select distinct new map( ")
			.append(" rt.item_cd_lvl1 as value )")
			.append(" from RptItemAppVo rt" )
			.append("  where  rt.apl_code = :aplCode ");
		 
		Query query = getSession().createQuery(hql.toString());
		 query.setString("aplCode", aplCode);
 List<Map<String, Object>> list =query.list();
		 
		 for(Map<String, Object> map :list){
			String item_cd_lvl1= rptItemConfService.getItemName("1",map.get("value").toString(),"");
		   map.put("name", item_cd_lvl1);
		 }
		return  list;
	}
	
	/**
	 * 查询  二级
	 * @param params
	 * @return
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(value = "maoprpt", readOnly = true)
	public List<Map<String,Object>> getLvl2Store(String aplCode,String item_cd_lvl1) {

		StringBuilder hql = new StringBuilder();
		hql.append(" select distinct new map( ")
		    .append(" rt.item_cd_lvl2 as value  )")
			.append(" from RptItemAppVo rt" )
			.append("  where  rt.apl_code = :aplCode ")
		    .append("   and rt.item_cd_lvl1 = :item_cd_lvl1 ");
		Query query = getSession().createQuery(hql.toString());
		 query.setString("aplCode", aplCode);
		 query.setString("item_cd_lvl1", item_cd_lvl1);
 List<Map<String, Object>> list =query.list();
		 
		 for(Map<String, Object> map :list){
			String item_cd_lvl2= rptItemConfService.getItemName("2",map.get("value").toString(),item_cd_lvl1);
		   map.put("name", item_cd_lvl2);
		 }
		return  list;
	}
	
	/**
	 * 查询  科目
	 * @param params
	 * @return
	 */
	@SuppressWarnings({ "unchecked" })
	@Transactional(value = "maoprpt", readOnly = true)
	public List<Map<String,Object>> getLvl3Store(String aplCode,String item_cd_lvl1,String item_cd_lvl2) {

		StringBuilder hql = new StringBuilder();
		hql.append(" select distinct new map( ")
		    .append(" rt.item_cd_app as value,  ")
		    .append(" rt.item_app_name as name)  ")
			.append(" from RptItemAppVo rt" )
			.append("  where  rt.apl_code = :aplCode ")
		    .append("   and rt.item_cd_lvl1 = :item_cd_lvl1 ")
		    .append("   and rt.item_cd_lvl2 = :item_cd_lvl2 ");
		Query query = getSession().createQuery(hql.toString());
		 query.setString("aplCode", aplCode);
		 query.setString("item_cd_lvl1", item_cd_lvl1);
		 query.setString("item_cd_lvl2", item_cd_lvl2);
 List<Map<String, Object>> list =query.list();
		 
		return  list;
	}

	
	/**
	 * 查询  二级科目
	 * @param params
	 * @return
	 */	
	@SuppressWarnings("unchecked")
	@Transactional(value = "maoprpt", readOnly = true)
	public List<Map<String, Object>> getLvl2StoreCreate(String parent_item_cd) {
		StringBuilder hql = new StringBuilder();
		hql.append(" select distinct new map( ")
		    .append(" rt.item_cd as value,  ")
		    .append(" rt.item_name as name)  ")
			.append(" from RptItemBaseVo rt" )
			.append("  where    rt.parent_item_cd =:parent_item_cd ");
		Query query = getSession().createQuery(hql.toString());
		 query.setString("parent_item_cd", parent_item_cd);
		 List<Map<String, Object>> list =query.list(); 
		 return list;
	}
	
	
	/**
	 * 查询  科目
	 * @param params
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(value = "maoprpt", readOnly = true)
	public List<Map<String, Object>> getLvl1StoreCreate() {
		StringBuilder hql = new StringBuilder();
		hql.append(" select distinct new map( ")
		    .append(" rt.item_cd as value,  ")
		    .append(" rt.item_name as name )  ")
			.append(" from RptItemBaseVo rt" )
			.append("  where   rt.parent_item_cd ='NULL' ");
		Query query = getSession().createQuery(hql.toString());
        List<Map<String, Object>> list =query.list(); 
         return list;
	}
	
	
	
	/**
	 * 导入  科目信息
	 * @param params
	 * @return
	 */
@Transactional(value = "maoprpt")
public List<RptItemAppVo> getItemAPPList(String filePath) throws Exception  {
		
		File f = new File(filePath);
		InputStream in = null;
		StringBuilder stdErr = new StringBuilder();
		List<String> primaryKeyCheckList = new ArrayList<String>();
		try {
			in = new FileInputStream(f);
			HSSFWorkbook workbook = new HSSFWorkbook(in);
			HSSFRow cells;
			HSSFCell cell;
			int rowstop=1;
			HSSFSheet sheet = workbook.getSheetAt(0);
			int rowNumber = 1;
			//exl的行数
			 // 确定工作表起始行号
			  for (int k = 0; k < 500; k++) {
			  cells = sheet.getRow(k);
			   
			   if(cells == null){
				   rowstop = k;
				    break;
			   }else{
				   cell = cells.getCell(0);
				   if (cell == null || cell.getStringCellValue() == null
				     ||"".equals(cell.getStringCellValue().trim())) {
				    rowstop = k;
				    break;
				   }
			   }
			  }
            int rows =rowstop;
            for(int i = 1; i <rows; i++) {
				//行号计数
				++rowNumber;
				if(sheet.getRow(i).getCell(0)==null||"".equals(sheet.getRow(i).getCell(0).toString())
						||sheet.getRow(i).getCell(1)==null||"".equals(sheet.getRow(i).getCell(1).toString())
						||sheet.getRow(i).getCell(2)==null||"".equals(sheet.getRow(i).getCell(2).toString())
						||sheet.getRow(i).getCell(4)==null||"".equals(sheet.getRow(i).getCell(4).toString())
						||sheet.getRow(i).getCell(5)==null||"".equals(sheet.getRow(i).getCell(5).toString())){
					 stdErr.append(">><span style=\"color:red\">" + messages.getMessage("check.error.line", new Object[]{rowNumber}) + "</span>");
						stdErr.append(" 有空值");
						stdErr.append("<br>");
						continue;
				 }
				 int cols=sheet.getRow(0).getPhysicalNumberOfCells();
				//行的长度Check
					if(cols != 7){
						stdErr.append(">><span style=\"color:red\">" + messages.getMessage("check.error.line", new Object[]{rowNumber}) + "</span>");
						stdErr.append(messages.getMessage("check.data.coulmus.length.not.match", new String[] {String.valueOf(7)}));
						stdErr.append("<br>");
						continue;
					}
					
						String key="";
					 if(sheet.getRow(i).getCell(1)==null||"".equals(sheet.getRow(i).getCell(1).toString())
						||sheet.getRow(i).getCell(2)==null||"".equals(sheet.getRow(i).getCell(2).toString())){
						 
					 }else{
							 
						if(null!= sheet.getRow(i).getCell(3)&&!"".equals(sheet.getRow(i).getCell(3).toString())){
							key =sheet.getRow(i).getCell(1).toString()+"_"+sheet.getRow(i).getCell(2).toString()+"_"+sheet.getRow(i).getCell(3).toString();
						}else{
							key =sheet.getRow(i).getCell(1).toString()+"_"+sheet.getRow(i).getCell(2).toString();
						}
						 String apl_code=(null!= sheet.getRow(i).getCell(0)?sheet.getRow(i).getCell(0).toString():"");
				         CheckDataitemConfinfo(apl_code,key, stdErr, rowNumber,primaryKeyCheckList);
				         
				        	  CheckDataitemConfBaseinfo(sheet.getRow(i).getCell(1).toString(),sheet.getRow(i).getCell(2).toString(), stdErr, rowNumber,primaryKeyCheckList);
				         }
				       
					
					
				}
            if(stdErr.length() > 0 ){
        		//更新脚步执行结束时间
	        	throw new DataException("<br>"+messages.getMessage("check.data.error")+":<br>"+stdErr.toString(), rowNumber);
	        }
			
		    List<RptItemAppVo> list = new ArrayList<RptItemAppVo>();
		    RptItemAppVo vo=null;
			for(int i = 1; i <rows; i++) {
				
				 vo = new RptItemAppVo();
										 
				String apl_code=(null!= sheet.getRow(i).getCell(0)?sheet.getRow(i).getCell(0).toString():"");
				String item_cd_lvl1=(null!= sheet.getRow(i).getCell(1)?sheet.getRow(i).getCell(1).toString():"");
				String item_cd_lvl2=(null!= sheet.getRow(i).getCell(2)?sheet.getRow(i).getCell(2).toString():"");
				String item_cd_app="";
				if(null!= sheet.getRow(i).getCell(3)&&!"".equals(sheet.getRow(i).getCell(3).toString())){
					item_cd_app=item_cd_lvl1+"_"+item_cd_lvl2+"_"+sheet.getRow(i).getCell(3);
				}else{
					item_cd_app=item_cd_lvl1+"_"+item_cd_lvl2;
				}
				String item_app_name=(null!= sheet.getRow(i).getCell(4)?sheet.getRow(i).getCell(4).toString():"");
				String falg=(null!= sheet.getRow(i).getCell(5)?sheet.getRow(i).getCell(5).toString():"");
				String expression=(null!= sheet.getRow(i).getCell(6)?sheet.getRow(i).getCell(6).toString():"");
				vo.setApl_code(apl_code);
				vo.setItem_cd_lvl1(item_cd_lvl1);
				vo.setItem_cd_lvl2(item_cd_lvl2);
				vo.setItem_app_name(item_app_name);
				vo.setItem_cd_app(item_cd_app);
				vo.setItem_app_ststcs_peak_flag(falg);
				vo.setExpression(expression);
				
				list.add(vo);
				}
				
			return list;
		
		} catch (Exception e) {
			if(e instanceof NullPointerException) {
				throw new Exception(messages.getMessage("message.file.format.error"));
			}
			throw e;
		} finally {
			if(in != null) {
				try {
					in.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
			if(f.exists()) {
				f.delete();
			}
		}
		
	}
	

/**
 * 主键检查
 * @param params
 * @return
 */
	public void CheckDataitemConfinfo(String apl_code,String item_cd_app, StringBuilder stdErr, int rowNumber, List<String> primaryKeyCheckList) {
		StringBuilder errMsg = new StringBuilder();
		String ziDuan=apl_code+","+item_cd_app;
		if(!primaryKeyCheckList.contains(ziDuan)){
			primaryKeyCheckList.add(ziDuan);
		}else{
			errMsg.append("存在主键重复数据,主键=[" + apl_code + "|+|"+item_cd_app+"]");
		}
		
		//结束
		if(errMsg.length() != 0){
			if(rowNumber > 0){
				stdErr.append(">><span style=\"color:red\">" + messages.getMessage("check.error.line", new Object[]{rowNumber}) + "</span>");
			}
			stdErr.append(errMsg.toString());
			stdErr.append("<br>");
		}
	}
	
	
	/**
	 * 一二级基础配置检查
	 * @param params
	 * @return
	 */
	@Transactional(value = "maoprpt")
	public void CheckDataitemConfBaseinfo(String lvl1,String lvl2, StringBuilder stdErr, int rowNumber, List<String> primaryKeyCheckList) {
		StringBuilder errMsg = new StringBuilder();
		StringBuilder sql = new StringBuilder();
		sql.append(" select  count(*)    ")
			.append(" from RPT_ITEM_BASE t" )
		    .append("   where t.PARENT_ITEM_CD = '"+lvl1+"'")
		    .append("   and  t.ITEM_CD = '"+lvl2 +"'");
		String num=  getSession().createSQLQuery(sql.toString()).uniqueResult().toString();

		if(num.equals("0")){
			errMsg.append("科目基础信息配置数据,没有  一级 = [" + lvl1 + "] ,二级 = ["+lvl2+"] 数据");
		}
		
		//结束
		if(errMsg.length() != 0){
			if(rowNumber > 0){
				stdErr.append(">><span style=\"color:red\">" + messages.getMessage("check.error.line", new Object[]{rowNumber}) + "</span>");
			}
			stdErr.append(errMsg.toString());
			stdErr.append("<br>");
		}
	}
	
	@Transactional(value = "maoprpt")
	public void importItemAPPs(List<RptItemAppVo> list) {
		String uname =securityUtils.getUser().getUsername();
		Date startDate = new Date();
		String created_time = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate) ;
		for(RptItemAppVo vo :list){
			vo.setItem_created(Timestamp.valueOf(created_time.concat(".000").toString()));
			vo.setItem_creator(uname);
			this.saveOrupdate(vo);
		}
	}
	
}
