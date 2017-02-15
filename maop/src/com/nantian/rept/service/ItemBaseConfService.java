package com.nantian.rept.service;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
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
import org.hibernate.Criteria;
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

import com.nantian.component.com.DataException;
import com.nantian.jeda.FieldType;
import com.nantian.jeda.security.util.SecurityUtils;
import com.nantian.rept.vo.RptItemBaseVo;
import com.nantian.rept.vo.SysResrcTransVo;

/**
 * 三级科目配置service
 * @author linaWang
 */
@Service
@Repository
public class ItemBaseConfService{
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(ItemBaseConfService.class);

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();
	
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
	/** HIBERNATE Session Factory */
	@Autowired
	private SessionFactory sessionFactoryMaopRpt;

	public Session getSession() {
		return sessionFactoryMaopRpt.getCurrentSession();
	}
	@Autowired
	 private SecurityUtils securityUtils; 

	/**
	 * 构造方法	 */
	public ItemBaseConfService() {
		fields.put("item_cd", FieldType.STRING);
		fields.put("parent_item_cd", FieldType.STRING);
		fields.put("item_name", FieldType.STRING);
		fields.put("relation_tablename", FieldType.STRING);
		fields.put("item_creator", FieldType.STRING);
		fields.put("item_created", FieldType.TIMESTAMP);
		fields.put("item_modifier", FieldType.STRING);
		fields.put("item_modified", FieldType.TIMESTAMP);
		
		fields.put("APL_CODE", FieldType.STRING);
		fields.put("TRAN_NAME", FieldType.STRING);
		fields.put("SRV_TYPE", FieldType.STRING);
		fields.put("SRV_CODE", FieldType.STRING);
		
	}
	
	/**
	 * 保存.
	 * @param RptItemBaseVo
	 */
	@Transactional(value="maoprpt")
	public void save(RptItemBaseVo rptItemBaseVo) {
		getSession().save(rptItemBaseVo);
	}
	
	/**
	 * 保存.
	 * @param RptItemBaseVo
	 */
	@Transactional(value="maoprpt")
	public void saveOrupdate(RptItemBaseVo rptItemBaseVo) {
		getSession().saveOrUpdate(rptItemBaseVo);
	}
	
	/**
	 * 通过主键查找唯一的一条记录	 * @param item_cd  科目id
	 * @param parent_item_cd  父科目id
	 */
	@SuppressWarnings("unchecked")
	@Transactional(value = "maoprpt", propagation=Propagation.NOT_SUPPORTED, readOnly = true)
	public Map<String,Object> getItemBaseConfById(String item_cd, String parent_item_cd){
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(");
 		hql.append(" e.item_cd as item_cd,");
 		hql.append(" e.parent_item_cd as parent_item_cd,");
 		hql.append(" e.item_name as item_name,");
 		hql.append(" e.relation_tablename as relation_tablename,");
 		hql.append(" e.item_creator as item_creator,");
 		hql.append("to_char(e.item_created,'yyyy-MM-dd hh24:mi:ss') as item_created,");
 		hql.append("e.item_modifier as item_modifier,");
 		hql.append("to_char(e.item_modified,'yyyy-MM-dd hh24:mi:ss') as item_modified");
		hql.append(" ) from RptItemBaseVo e where e.item_cd=:item_cd ");
		hql.append(" and e.parent_item_cd=:parent_item_cd ");
		Query query = getSession().createQuery(hql.toString())
				.setString("item_cd", item_cd)
				.setString("parent_item_cd", parent_item_cd);
		return (Map<String, Object>) query.uniqueResult();
	}
	
	/**
	 * 根据ID批量删除.
	 * @param primaryKeys主键数组[科目,父科目 ] 
	 */
	@Transactional("maoprpt")
	public void deleteByIds(String[] Ids,String[] parent_Ids) {
		for(int i=0;i<Ids.length;i++){
			this.deleteById(Ids[i],parent_Ids[i]);
		}
	}
	
	/**
	 * 根据ID删除.
	 * @param item_cd  科目id
	 * @param parent_item_cd  父科目id

	 */
	@Transactional("maoprpt")
	public void deleteById(String item_cd, String parent_item_cd) {
		getSession().createQuery("delete from RptItemBaseVo ic where ic.item_cd=:item_cd  and ic.parent_item_cd=:parent_item_cd ")
			.setString("item_cd", item_cd)
			.setString("parent_item_cd", parent_item_cd)
			.executeUpdate();
	}

	/**
	 * 分页查询
	 */
	@Transactional(value = "maoprpt", propagation=Propagation.NOT_SUPPORTED, readOnly = true)
	@SuppressWarnings({ "unchecked"})
	
	public List<Map<String, Object>> getItemBaseConfList(Integer start, Integer limit, String sort, String dir,
			Map<String, Object> params,	HttpServletRequest request) {
		StringBuilder hql = new StringBuilder();
		hql.append("select distinct new map(");
 		hql.append("e.item_cd as item_cd,");
 		hql.append("e.parent_item_cd as parent_item_cd,");
 		hql.append("e.item_name as item_name,");
 		hql.append("e.relation_tablename as relation_tablename,");
 		hql.append("e.item_creator as item_creator,");
 		hql.append("to_char(e.item_created,'yyyy-MM-dd hh24:mi:ss') as item_created,");
 		hql.append("e.item_modifier as item_modifier,");
 		hql.append("to_char(e.item_modified,'yyyy-MM-dd hh24:mi:ss') as item_modified ");
		hql.append(") from RptItemBaseVo e where 1=1 ");
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
		
		Query query = getSession().createQuery(hql.toString());
		
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		 List<Map<String, Object>> list =query.list();
		 
		request.getSession().setAttribute("ItemBaseConfList",list );
		 query.setFirstResult(start).setMaxResults(limit);
		 List<Map<String, Object>> list2 =query.list();
		 
		 return list2;
	}
	
	/**
	 * 获取总记录数
	 */
	@Transactional(value = "maoprpt", propagation=Propagation.NOT_SUPPORTED, readOnly = true)
	public Long countItemBaseConfList(Map<String, Object> params) {
		StringBuilder hql = new StringBuilder();
		hql.append("select count(*) from RptItemBaseVo e  where 1=1 ");
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
		return Long.valueOf(query.uniqueResult().toString());
	}

	
	@Transactional(value = "maoprpt")
public List<RptItemBaseVo> getItemBaseConfList(String filePath) throws Exception  {
		
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
				if(sheet.getRow(i).getCell(0)==null||sheet.getRow(i).getCell(1)==null){
					 stdErr.append(">><span style=\"color:red\">" + messages.getMessage("check.error.line", new Object[]{rowNumber}) + "</span>");
						stdErr.append("主键有空值");
						stdErr.append("<br>");
						continue;
				 }
				 int cols=sheet.getRow(0).getPhysicalNumberOfCells();
				//行的长度Check
					if(cols != 4){
						stdErr.append(">><span style=\"color:red\">" + messages.getMessage("check.error.line", new Object[]{rowNumber}) + "</span>");
						stdErr.append(messages.getMessage("check.data.coulmus.length.not.match", new String[] {String.valueOf(4)}));
						stdErr.append("<br>");
						continue;
					}
					 String parent_item_cd=(null!= sheet.getRow(i).getCell(0)?sheet.getRow(i).getCell(0).toString():"");
			         String item_cd=(null!= sheet.getRow(i).getCell(1)?sheet.getRow(i).getCell(1).toString():"");
			         CheckDataServerinfo(parent_item_cd,item_cd, stdErr, rowNumber,primaryKeyCheckList);
				}
            if(stdErr.length() > 0 ){
        		//更新脚步执行结束时间
	        	throw new DataException("<br>"+messages.getMessage("check.data.error")+":<br>"+stdErr.toString(), rowNumber);
	        }
			
		    List<RptItemBaseVo> list = new ArrayList<RptItemBaseVo>();
		    RptItemBaseVo vo=null;
			for(int i = 1; i <rows; i++) {
				
				 vo = new RptItemBaseVo();
										 
				String parent_item_cd=(null!= sheet.getRow(i).getCell(0)?sheet.getRow(i).getCell(0).toString():"");
				String item_cd=(null!= sheet.getRow(i).getCell(1)?sheet.getRow(i).getCell(1).toString():"");
				String item_name=(null!= sheet.getRow(i).getCell(2)?sheet.getRow(i).getCell(2).toString():"");
				String relation_tablename=(null!= sheet.getRow(i).getCell(3)?sheet.getRow(i).getCell(3).toString():"");
				
				vo.setItem_cd(item_cd);
				vo.setParent_item_cd(parent_item_cd);
				vo.setItem_name(item_name);
				vo.setRelation_tablename(relation_tablename);
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
	
	public void CheckDataServerinfo(String parent_item_cd,String item_cd, StringBuilder stdErr, int rowNumber, List<String> primaryKeyCheckList) {
		StringBuilder errMsg = new StringBuilder();
		String ziDuan=parent_item_cd+","+item_cd;
		if(!primaryKeyCheckList.contains(ziDuan)){
			primaryKeyCheckList.add(ziDuan);
		}else{
			errMsg.append("存在主键重复数据,主键=[" + parent_item_cd + "|+|"+item_cd+"]");
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
	public void importItemBaseConfs(List<RptItemBaseVo> list) {
		String uname =securityUtils.getUser().getUsername();
		Date startDate = new Date();
		String created_time = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(startDate) ;
		for(RptItemBaseVo vo :list){
			vo.setItem_created(Timestamp.valueOf(created_time.concat(".000").toString()));
			vo.setItem_creator(uname);
			this.saveOrupdate(vo);
		}
	}
	
	//五分钟交易配置------------------------------------------------------------------------------------
	
	
	
	/**
	 * 分页查询
	 */
	@Transactional(value = "maoprpt", propagation=Propagation.NOT_SUPPORTED, readOnly = true)
	@SuppressWarnings({ "unchecked"})
	public List<Map<String, Object>> getResrcTransConfList(Integer start, Integer limit, String sort, String dir,
			Map<String, Object> params) {
		StringBuilder sql = new StringBuilder();
		sql.append("select  ");
 		sql.append("e.APL_CODE as APL_CODE,");
 		sql.append("e.TRAN_NAME as TRAN_NAME,");
 		sql.append("e.SRV_TYPE as SRV_TYPE,");
 		sql.append("e.SRV_CODE as SRV_CODE ");
		sql.append(" from SYS_RESRC_TRANS e where 1=1 ");
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					sql.append(" and e." + key + " like :" + key);
				} else {
					sql.append(" and e." + key + " = :" + key);
				}
			}
		}
		if(sort!=null && !sort.equals("")){
			sql.append(" order by e." + sort );
			if(dir!=null && !dir.equals("")){
				sql.append(" " + dir );
			}else{
				sql.append(" desc");
			}
		}
		logger.info(sql.toString());
		Query query = getSession().createSQLQuery(sql.toString()).setFirstResult(start).setMaxResults(limit);
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		query.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
		 List<Map<String, Object>> list =query.list();
		 
		 
		 return list;
	}
	
	/**
	 * 获取总记录数
	 */
	@Transactional(value = "maoprpt", propagation=Propagation.NOT_SUPPORTED, readOnly = true)
	public Long countResrcTransConfList(Map<String, Object> params) {
		StringBuilder sql = new StringBuilder();
		sql.append("select count(*) from SYS_RESRC_TRANS e  where 1=1 ");
		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					sql.append(" and e." + key + " like :" + key);
				} else {
					sql.append(" and e." + key + " = :" + key);
				}
			}
		}
		logger.info(sql.toString());
		Query query = getSession().createSQLQuery(sql.toString());
		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return Long.valueOf(query.uniqueResult().toString());
	}

	
		/**
		 * 查询  交易名称
		 * @param params
		 * @return
		 */
		@SuppressWarnings({ "unchecked" })
		@Transactional(value = "maoprpt", readOnly = true)
		public List<Map<String, Object>> getTransName(String aplCode) {

			StringBuilder sql = new StringBuilder();
			sql.append(" select   ")
			    .append(" rt.TRANS_NAME as \"value\",  ")
			    .append(" rt.TRANS_NAME as \"name\"  ")
				.append(" from  five_min_trans rt" )
				.append("  where  rt.apl_code = :aplCode ")
			    .append("   and substr( rt.TRANS_DATE,0,6) = to_char( sysdate ,'yyyyMM')  ");
			Query query = getSession().createSQLQuery(sql.toString())
					.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
			 query.setString("aplCode", aplCode);
	 List<Map<String, Object>> list =query.list();
			 
			return  list;
		}
		
		/**
		 * 查询  交易名称
		 * @param params
		 * @return
		 */
		@SuppressWarnings({ "unchecked" })
		@Transactional(value = "maoprpt", readOnly = true)
		public List<Map<String, Object>> getsrvCode(String aplCode,String srvType) {

			StringBuilder sql = new StringBuilder();
			sql.append(" select   ")
			    .append(" rt.SRV_CODE as \"value\",  ")
			    .append(" rt.SRV_CODE as \"name\"  ")
				.append(" from  SERVER_CONF rt" )
				.append("  where  rt.APL_CODE = :aplCode ")
			    .append("   and  rt.SER_CLASS = :srvType    ");
			Query query = getSession().createSQLQuery(sql.toString())
					.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);
			 query.setString("aplCode", aplCode);
			 query.setString("srvType", srvType);
	 List<Map<String, Object>> list =query.list();
			 
			return  list;
		}
		
		/**
		 * 根据ID批量删除.
		 * @param primaryKeys主键数组[科目,父科目 ] 
		 * @throws UnsupportedEncodingException 
		 */
		@Transactional("maoprpt")
		public void deleteBySysResrcTrans(String[] APL_CODES,
				String[] TRAN_NAMES, String[] SRV_TYPES, String[] SRV_CODES) throws UnsupportedEncodingException {
			
					for(int i=0;i<APL_CODES.length;i++){
					  String TRAN_NAME= java.net.URLDecoder.decode(TRAN_NAMES[i],"utf-8") ;
					this.deleteBySysResrcTransId(APL_CODES[i],TRAN_NAME,SRV_TYPES[i],SRV_CODES[i]);
				}
			}
		
		
		/**
		 * 根据ID删除.
		
		 */
		@Transactional("maoprpt")
		public void deleteBySysResrcTransId(String APL_CODE, String TRAN_NAME, String SRV_TYPE, String SRV_CODE) {
			getSession().createSQLQuery("delete from SYS_RESRC_TRANS ic where ic.APL_CODE=:APL_CODE  and ic.TRAN_NAME=:TRAN_NAME and  ic.SRV_TYPE=:SRV_TYPE  and ic.SRV_CODE=:SRV_CODE ")
				.setString("SRV_TYPE", SRV_TYPE)
				.setString("SRV_CODE", SRV_CODE)
				.setString("APL_CODE", APL_CODE)
				.setString("TRAN_NAME", TRAN_NAME)
				.executeUpdate();
		}
		
		/**
		 * 保存.
		 * @param RptItemBaseVo
		 */
		@Transactional(value="maoprpt")
		public void saveUpdate(SysResrcTransVo sysResrcTransVo) {
			getSession().saveOrUpdate(sysResrcTransVo);
		}

		@Transactional(value = "maoprpt")
		public void saveSysResrcTrans(List<SysResrcTransVo> list) {
			
			for(SysResrcTransVo vo :list){
				this.saveUpdate(vo);
			}
		}
}
