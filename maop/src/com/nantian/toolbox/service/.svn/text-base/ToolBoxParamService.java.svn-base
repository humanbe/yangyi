package com.nantian.toolbox.service;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.NoSuchMessageException;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.common.util.Constants;
import com.nantian.component.com.DataException;
import com.nantian.jeda.FieldType;
import com.nantian.toolbox.vo.ToolBoxParamInfoVo;

/**
 * @author <a href="mailto:name@nantian.com.cn">donghui</a>
 * 
 */
@Service
@Repository
@Transactional
public class ToolBoxParamService {

	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(ToolBoxParamService.class);

	/** 查询字段及类型 */
	public Map<String, String> fields = new HashMap<String, String>();
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	

	/** HIBERNATE Session Factory */
	@Autowired
	private SessionFactory sessionFactory;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}

	/**
	 * 构造方法
	 */
	public ToolBoxParamService() {
		fields.put("tool_code", FieldType.STRING);
		fields.put("appsys_code", FieldType.STRING);
		fields.put("param_name", FieldType.STRING);		
		fields.put("param_desc", FieldType.STRING);
		fields.put("param_type", FieldType.STRING);
		fields.put("param_length", FieldType.LONG);
		fields.put("param_format", FieldType.STRING);	
		fields.put("param_default_value", FieldType.STRING);
		
	}

	/**
	 * 保存.
	 * 
	 * @param customer
	 */
	@Transactional
	public void save(ToolBoxParamInfoVo vo) {	
		getSession().saveOrUpdate(vo);
		
	}
	
	/**
	 * 保存信息
	 * @return
	 */
	private void saveOrUpdate(ToolBoxParamInfoVo toolBoxparaminfo) {
		getSession().saveOrUpdate(toolBoxparaminfo);
		
	}
	
	/**
	 * 查询数据库中所有toolboxparaminfo信息
	 * @return
	 */
	
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public List<ToolBoxParamInfoVo> queryAlltoolboxparaminfo() throws SQLException{
		return getSession().createQuery("from ToolBoxParamInfoVo t").list();
	}

	/**
	 * 根据ID查询
	 * 
	 * @param hostip
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(readOnly = true)
	public Object findById(String tool_code, String appsys_code)throws SQLException  {

		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
		hql.append("tp.tool_code as tool_code,");
		hql.append("tp.appsys_code as appsys_code,");
		hql.append("tp.param_name as param_name,");
		hql.append("tp.param_desc as param_desc,");
		hql.append("tp.param_type as param_type,");
		
		hql.append("tp.param_length as param_length,");
		hql.append("tp.param_format as param_format, ");
		hql.append("tp.param_default_value as param_value,");
		hql.append("tp.param_default_value as param_default_value");
		hql.append(") from ToolBoxParamInfoVo tp where tp.tool_code =? and tp.appsys_code= ?  ");
		hql.append(" order by tp.param_name asc");
		List<Map<String, Object>> list=getSession().createQuery(hql.toString())
				.setString(0, tool_code).setString(1, appsys_code).list();
		for(int i=0;i<list.size();i++){
			String param_type=(String) (null!=list.get(i).get("param_type")?list.get(i).get("param_type"):"");
			if(param_type.equals("6")){
				if(null!=list.get(i).get("param_value")?true:false){
				list.get(i).put("param_value", "******");
				}
			}
		}
		 return list;

	}

	/**
	 * 查询数据数量.
	 * 
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long countParam(String tool_code, String appsys_code)throws SQLException  {
		StringBuilder hql = new StringBuilder();
		hql.append("select count(*) from ToolBoxParamInfoVo tp  where tp.tool_code = ? and tp.appsys_code= ? ");
		Query query = getSession().createQuery(hql.toString()).setString(0, tool_code).setString(1, appsys_code);
		return Long.valueOf(query.uniqueResult().toString());
	}
	
	
	/**  批量删除
	 * @param tool_codes
	 * @param appsys_codes
	 *  @param param_codes
	 * @throws SQLException 
	 */
	@Transactional
	public void deleteByIds(String[] tool_codes, String[] appsys_codes,  String[] param_names) throws SQLException {
		for(int i = 0; i < tool_codes.length && i < appsys_codes.length && i<param_names.length;i++){
			deleteById(tool_codes[i], appsys_codes[i],param_names[i]);
		}
	}
	
	/**
	 * 删除
	 * @param tool_code
	 * @param appsys_code
	 * * @param param_code
	 */
	public void deleteById(String tool_code ,String appsys_code,String param_code)throws SQLException  {
		getSession()
				.createQuery("delete from ToolBoxParamInfoVo tp where tp.tool_code = ? and tp.appsys_code= ? and tp.param_name=?")
				.setString(0, tool_code).setString(1, appsys_code).setString(2, param_code).executeUpdate();
	}
	/**
	 * 删除
	 * @param tool_code
	 * @param appsys_code
	 */
	public void delete(String tool_code ,String appsys_code)throws SQLException  {
		getSession()
				.createQuery("delete from ToolBoxParamInfoVo tp where tp.tool_code = ? and tp.appsys_code= ? ")
				.setString(0, tool_code).setString(1, appsys_code).executeUpdate();
	}
	

	/**
	 * 查询数据.
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> queryCreateParam(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params)throws SQLException  {

		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
		hql.append("tp.tool_code as tool_code,");
		hql.append("tp.appsys_code as appsys_code,");
		hql.append("tp.param_name as param_name,");
		hql.append("tp.param_desc as param_desc,");
		hql.append("tp.param_type as param_type,");
		
		hql.append("tp.param_length as param_length,");
		hql.append("tp.param_format as param_format, ");
		
		hql.append("tp.param_default_value as param_default_value");		
		hql.append(") from ToolBoxParamInfoVo tp where tp.tool_code ='' ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and tp." + key + " like :" + key);
				} else {
					hql.append(" and tp." + key + " = :" + key);
				}
			}
		}
		
		 
		Query query = getSession().createQuery(hql.toString())
				.setFirstResult(start).setMaxResults(limit);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return query.list();
	}

	/**
	 * 查询数据.
	 * 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings({ "unchecked" })
	public List<Map<String, Object>> queryAllparam(Integer start, Integer limit,
			String sort, String dir, Map<String, Object> params)throws SQLException  {

		StringBuilder hql = new StringBuilder();
		hql.append("select new map(");
		hql.append("tp.tool_code as tool_code,");
		hql.append("tp.appsys_code as appsys_code,");
		hql.append("tp.param_name as param_name,");
		hql.append("tp.param_desc as param_desc,");
		hql.append("tp.param_type as param_type,");
		
		hql.append("tp.param_length as param_length,");
		hql.append("tp.param_format as param_format, ");
		
		hql.append("tp.param_default_value as param_default_value");		
		hql.append(") from ToolBoxParamInfoVo tp where 1=1 ");

		if (params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and tp." + key + " like :" + key);
				} else {
					hql.append(" and tp." + key + " = :" + key);
				}
			}
		}
		hql.append(" order by tp.param_name asc");
		 
		Query query = getSession().createQuery(hql.toString())
				.setFirstResult(start).setMaxResults(limit);

		if (params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return query.list();
	}

	
	
	
	/**
	 * 查询数据数量.
	 * 
	 * @param params
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long count(Map<String, Object> params)throws SQLException  {
		StringBuilder hql = new StringBuilder();
		hql.append("select count(*) from ToolBoxParamInfoVo tp  where 1=1 ");
		if (null != params && params.keySet().size() > 0) {
			for (String key : params.keySet()) {
				if (fields.get(key).equals(FieldType.STRING)) {
					hql.append(" and tp." + key + " like :" + key);
				} else {
					hql.append(" and tp." + key + " = :" + key);
				}
			}
		}
		Query query = getSession().createQuery(hql.toString());
		if (null != params && params.keySet().size() > 0) {
			query.setProperties(params);
		}
		return Long.valueOf(query.uniqueResult().toString());
	}


	

	
	/**
	 * 读取工具文件
	 * @return 
	 * @throws FileNotFoundException 
	 * @throws UnsupportedEncodingException,IOException 
	 * @throws IOException 
	 * @throws Exception 
	 */
	
	@Transactional
	public List<ToolBoxParamInfoVo> readToolBoxParamInfoVoFromFile(String username,String toolcode,String filenamwe) 
			throws UnsupportedEncodingException, FileNotFoundException,IOException ,NoSuchMessageException,DataException, Exception {
		String toolboxparaminfo=toolcode+"Param.dat";
		
		String filePath = System.getProperty("maop.root") +File.separator + messages.getMessage("systemServer.toolboxImpPath")+File.separator+username+File.separator+filenamwe+File.separator+toolboxparaminfo;
		String[] typicalCapaAnaArr = new String[Constants.TOOLBOXPARAMINFO_COLUMNS];
		 String typicalCapaAnaStr = "";
		InputStream in = null;
		BufferedReader reader = null;
		File file = new File(filePath);
		List<ToolBoxParamInfoVo> toolboxparaminfoList = new ArrayList<ToolBoxParamInfoVo>();
		ToolBoxParamInfoVo vo = null;
	
			in = new FileInputStream(file);
			reader = new BufferedReader(new InputStreamReader(in,"gbk"));
			while((typicalCapaAnaStr = reader.readLine()) != null){
				//拆分数据
				typicalCapaAnaArr = typicalCapaAnaStr.split(Constants.SPLIT_SEPARATEOR, -1);
				vo=new ToolBoxParamInfoVo();
			
				vo.setAppsys_code(typicalCapaAnaArr[0]); 
				vo.setTool_code(typicalCapaAnaArr[1]);
				
				vo.setParam_name(typicalCapaAnaArr[2]);
				vo.setParam_type(typicalCapaAnaArr[3]);
				vo.setParam_length("".equals(typicalCapaAnaArr[4])?null:Long.valueOf(typicalCapaAnaArr[4]));
				vo.setParam_format(typicalCapaAnaArr[5]);
				vo.setParam_default_value(typicalCapaAnaArr[6]);
				vo.setParam_desc(typicalCapaAnaArr[7]);
				toolboxparaminfoList.add(vo);
		}
		if(reader != null){
			reader.close();
		}
         	
        file.delete();
		return toolboxparaminfoList;
		
		
	}
	
	/**
	 * 导入工具箱工具
	 * @param toolboxparaminfoList 
	 * @param importtoolboxparaminfolist 
	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param params
	 * @return
	 */
	/*public void importtoolboxparaminfo(List<ToolBoxParamInfoVo> toolboxparaminfoList, List<ToolBoxParamInfoVo> importtoolboxparaminfolist) {
        
		List<ToolBoxParamInfoVo> toolboxparamList = new ArrayList<ToolBoxParamInfoVo>();
		for(int i=0;i<toolboxparaminfoList.size();i++){
			ToolBoxParamInfoVo svo=null;
			//文件中的系统代码
		String fileappsys_code = toolboxparaminfoList.get(i).getAppsys_code();
		String filetool_code = toolboxparaminfoList.get(i).getTool_code();
		String fileparam_name = toolboxparaminfoList.get(i).getParam_name();
			if(importtoolboxparaminfolist.size()==0){
				svo=new ToolBoxParamInfoVo();
				svo.setTool_code(filetool_code);
				svo.setAppsys_code(fileappsys_code);
				svo.setParam_name(fileparam_name);
			}else{
				for(int j=0;j<importtoolboxparaminfolist.size();j++){
					//数据库中的系统代码
					String appsys_code  = importtoolboxparaminfolist.get(j).getAppsys_code();
					String tool_code= importtoolboxparaminfolist.get(j).getTool_code();
					String param_name = importtoolboxparaminfolist.get(j).getParam_name();
						if(appsys_code.equals(fileappsys_code)&&tool_code.equals(filetool_code)&&param_name.equals(fileparam_name)){
							svo=importtoolboxparaminfolist.get(j);
						 	importtoolboxparaminfolist.remove(j);
							j--;
							break;
						}
						if(j==importtoolboxparaminfolist.size()-1){
							svo=new ToolBoxParamInfoVo();
							svo.setTool_code(filetool_code);
							svo.setAppsys_code(fileappsys_code);
							svo.setParam_name(fileparam_name);
							
						}
					}
				}
					
					svo.setParam_type(toolboxparaminfoList.get(i).getParam_type());
					svo.setParam_length(toolboxparaminfoList.get(i).getParam_length());
					svo.setParam_format(toolboxparaminfoList.get(i).getParam_format());
					svo.setParam_default_value(toolboxparaminfoList.get(i).getParam_default_value());
					svo.setParam_desc(toolboxparaminfoList.get(i).getParam_desc());
					toolboxparamList.add(svo);
		 
		}
		saveOrUpdatetoolboxinfo(toolboxparamList);
	}*/
	/**
	 * 处理系统信息
	 * @return
	 */
	public void saveOrUpdatetoolboxinfo(List<ToolBoxParamInfoVo> toolboxparamList) {
		for(int i=0;i<toolboxparamList.size();i++){
			saveOrUpdate(toolboxparamList.get(i));
		}
	}


	/**
	 * 批量导出
	 * @param tool_codes
	 * @param appsys_codes
	 * @throws SQLException 
	 */
	@Transactional
	public String exporttoolparams(String tool_code, String appsys_code) throws SQLException {
	
		StringBuilder sql = new StringBuilder();
		sql.append("select * from TOOL_BOX_PARAM_INFO tb where tb.tool_code = ?" );
		Query query = getSession().createSQLQuery(sql.toString()).setString(0, tool_code).setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP);;
		@SuppressWarnings("unchecked")
		List<Map<String, Object>> tools=query.list();
	
		StringBuilder toolparamfile = new StringBuilder();
		if(tools.size()>0){
		int paralng=tools.size()-1;
		for(int i = 0; i < tools.size()-1 ; i++){
			toolparamfile.append(tools.get(i).get("APPSYS_CODE"))
			.append(Constants.DATA_SEPARATOR)
			.append(tools.get(i).get("TOOL_CODE"))
			
			.append(Constants.DATA_SEPARATOR)
			.append(tools.get(i).get("PARAM_NAME"))
			.append(Constants.DATA_SEPARATOR)
			.append(null!=tools.get(i).get("PARAM_TYPE")?tools.get(i).get("PARAM_TYPE"):"")
			.append(Constants.DATA_SEPARATOR)
			.append(null!=tools.get(i).get("PARAM_LENGTH")?tools.get(i).get("PARAM_LENGTH"):"")
			.append(Constants.DATA_SEPARATOR)
			.append(null!=tools.get(i).get("PARAM_FORMAT")?tools.get(i).get("PARAM_FORMAT"):"")
			.append(Constants.DATA_SEPARATOR)
			.append(null!=tools.get(i).get("PARAM_DEFAULT_VALUE")?tools.get(i).get("PARAM_DEFAULT_VALUE"):"")
			.append(Constants.DATA_SEPARATOR)
			.append(null!=tools.get(i).get("PARAM_DESC")?tools.get(i).get("PARAM_DESC"):"")
			.append("\n");
		}
		
		toolparamfile.append(tools.get(paralng).get("APPSYS_CODE"))
		.append(Constants.DATA_SEPARATOR)
		.append(tools.get(paralng).get("TOOL_CODE"))
		.append(Constants.DATA_SEPARATOR)
		.append(tools.get(paralng).get("PARAM_NAME"))
		.append(Constants.DATA_SEPARATOR)
		.append(null!=tools.get(paralng).get("PARAM_TYPE")?tools.get(paralng).get("PARAM_TYPE"):"")
		.append(Constants.DATA_SEPARATOR)
		.append(null!=tools.get(paralng).get("PARAM_LENGTH")?tools.get(paralng).get("PARAM_LENGTH"):"")
		.append(Constants.DATA_SEPARATOR)
		.append(null!=tools.get(paralng).get("PARAM_FORMAT")?tools.get(paralng).get("PARAM_FORMAT"):"")
		.append(Constants.DATA_SEPARATOR)
		.append(null!=tools.get(paralng).get("PARAM_DEFAULT_VALUE")?tools.get(paralng).get("PARAM_DEFAULT_VALUE"):"")
		.append(Constants.DATA_SEPARATOR)
		.append(null!=tools.get(paralng).get("PARAM_DESC")?tools.get(paralng).get("PARAM_DESC"):"");
		}
		return toolparamfile.toString();
	}
	/**
	 * 数据写入到文件中.
	 * @param  String toolparamfile,String fileName,String appsys_code
	 * @throws UnsupportedEncodingException
	 * @throws FileNotFoundException 
	 */
	public void toolparamFile(String toolparamfile,String toolboxparaminfo,String username,String filename) throws UnsupportedEncodingException, FileNotFoundException{
		    String filepath = System.getProperty("maop.root")+File.separator+ messages.getMessage("systemServer.toolboxExpPath")+File.separator+username+File.separator+filename;
			File file = new File(filepath);
			if(!file.exists()){
				file.mkdirs();
			}
			PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(filepath+ File.separator +toolboxparaminfo+"Param.dat"),"GBK"));
			out.print(toolparamfile);
			out.flush();
			out.close();
	}


}
