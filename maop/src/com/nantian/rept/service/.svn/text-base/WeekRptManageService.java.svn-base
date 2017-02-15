package com.nantian.rept.service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringReader;
import java.io.Writer;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.batik.transcoder.Transcoder;
import org.apache.batik.transcoder.TranscoderException;
import org.apache.batik.transcoder.TranscoderInput;
import org.apache.batik.transcoder.TranscoderOutput;
import org.apache.batik.transcoder.image.JPEGTranscoder;
import org.apache.batik.transcoder.image.PNGTranscoder;
import org.apache.fop.svg.PDFTranscoder;
import org.hibernate.Criteria;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.rept.vo.RptChartConfVo;
import com.nantian.rept.vo.RptItemConfVo;
import com.nantian.rept.vo.WeekResourceVo;

/**
 * 周报处理服务层

 * @author <a href="mailto:fujunze@nantian.com.cn">LJay</a>
 *
 */
@Service
@Transactional
public class WeekRptManageService {
	/**hibernate session factory*/
	@Resource(name = "sessionFactoryMaopRpt")
	@Autowired
	private SessionFactory sessionFactory;
	
	private Session getSession(){
		return sessionFactory.getCurrentSession();
	}
	
	/**
	 * 查询交易量和系统资源统计的合成数据

	 * @param start
	 * @param limit
	 * @param sort
	 * @param dir
	 * @param aplCode
	 * @param startDate
	 * @param srvCode
	 * @return
	 */
	@SuppressWarnings("unchecked")
	@Transactional(value = "maoprpt", readOnly = true)
	public List<Map<String, Object>> findRptWeekTranAndResource(
			Integer start, Integer limit, String sort, String dir, String aplCode, String startDate, String srvCode){
		StringBuilder sql = new StringBuilder();
		sql.append("select ")
			.append("	t.apl_code as \"aplCode\", ")
			.append("	rank() over(order by to_date(t.count_week,'yymmdd'))||'('||to_char(to_date(t.count_week,'yymmdd'),'mm.dd')||'-'||to_char(to_date(t.count_week,'yymmdd')+6,'mm.dd')||')' as \"countWeek\", ")
			.append(" 	to_char(to_date(t.count_week,'yyyymmdd'),'yyyymmdd') as \"countWeekValue\", ")
			.append("	t.week_total_trans as \"weekTotalTrans\", ")
			.append("	t.week_peak_trans as \"weekPeakTrans\", ")
			.append("	:srvCode as \"srvCode\", ")
			.append("	r.cpu_peak as \"cpuPeak\", ")
			.append("	r.cpu_online_peak_avg as \"cpuOnlinePeakAvg\", ")
			.append("	r.cpu_batch_peak_avg as \"cpuBatchPeakAvg\", ")
			.append("	r.mem_peak as \"memPeak\", ")
			.append("	r.mem_online_peak_avg as \"memOnlinePeakAvg\", ")
			.append("	r.mem_batch_peak_avg as \"memBatchPeakAvg\", ")
			.append("	r.io_peak as \"ioPeak\", ")
			.append("	r.io_online_peak_avg as \"ioOnlinePeakAvg\", ")
			.append("	r.io_batch_peak_avg as \"ioBatchPeakAvg\", ")
			.append("	r.revise_flag as \"reviseFlag\" ")
			.append("from week_tran t ")
			.append("left join week_resource r ")
			.append("on t.apl_code = r.apl_code and t.count_week = r.count_week and r.srv_code = :srvCode ")
			.append("where t.apl_code = :aplCode ")
			.append("	and to_date(t.count_week, 'yymmdd') >= to_date(:countWeek, 'yymmdd') ")
			.append("order by to_date(t.count_week,'yymmdd') ");
		
		return getSession().createSQLQuery(sql.toString())
									 .setString("aplCode", aplCode)
									 .setString("countWeek", startDate)
									 .setString("srvCode", srvCode)
									 .setFirstResult(start)
									 .setMaxResults(limit)
									 .setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP)
									 .list();
	}

	/**
	 * 将数据转换成HightChart图像数据
	 * @param itemConfList 报表科目配置信息
	 * @param chartConfList 报表图表配置信息
	 * @param list 待转换的数据
	 * @param xAxisMap x坐标轴科目名和字段标识的映射集合
	 * @param yAxisMap y坐标轴科目名和字段标识的映射集合
	 * @return
	 */
	public String getChartData(List<RptItemConfVo> itemConfList, List<RptChartConfVo> chartConfList, List<Map<String, Object>> list, 
			Map<String, String> xAxisMap, Map<String, String> yAxisMap) {
		StringBuilder chartData = new StringBuilder();
		
		chartData.append("{");
		chartData.append("srvCode:");
		chartData.append("'" + list.get(0).get("srvCode") + "'");
		//图表标题
		chartData.append(", titleData:");
		chartData.append("'" + chartConfList.get(0).getChartName() + "'");
		//图表X轴标签

		chartData.append(", xCategories:'");
		for(String key : xAxisMap.keySet()){
			for(int i = 0; i < list.size(); i++){
				chartData.append(list.get(i).get(key));
				if(i != list.size() - 1){
					chartData.append(",");
				}
			}
		}
		chartData.append("'");
		
		//图标Y轴标签

		/*chartData.append(", yAxisData : [");
		for(int i = 0; i < chartConfList.size(); i++){
			chartData.append("{text:").append()
		}
		chartData.append("]");*/
		
		//坐标tip提示信息数组
		chartData.append(", toolTipUnit :'{");
		int count = 0;
		for(int i = 0; i < itemConfList.size(); i++){
			RptItemConfVo vo = itemConfList.get(i);
			if(vo.getExpressionUnit() != null){
				count ++;
				chartData.append("\\'" + vo.getItemName() + "\\':\\'" + vo.getExpressionUnit() + "\\',");
			}
			
			if(count > 0 && i == itemConfList.size() - 1){
				chartData.deleteCharAt(chartData.length() - 1);
			}
		}
		chartData.append("}'");
		
		
		//图表的数据

		chartData.append(", seriesData :[");
		for(String key : yAxisMap.keySet()){
			chartData.append("{name :'").append(yAxisMap.get(key)).append("'");
			for(RptChartConfVo vo : chartConfList){
				if(vo.getItemList().indexOf(yAxisMap.get(key)) != -1){
					switch(vo.getChartType().charAt(0)){
						case '1' : chartData.append(", type : 'spline', yAxis : 0");break;
						case '2' : chartData.append(", type : 'column', yAxis : 1");break;
					}
					break;
				}
			}
			chartData.append(", data:[");
			for(int i = 0; i < list.size(); i++){
				chartData.append(list.get(i).get(key));
				if(i != list.size() - 1){
					chartData.append(",");
				}
			}
			chartData.append("]},");
		}
		chartData.deleteCharAt(chartData.length() - 1);
		chartData.append("]}");
		
		return chartData.toString();
	}
	
	/**
	 * 图像数据转换成二进制数据
	 * @param svg 图像数据
	 * @param imgType 图像类型
	 * @return 转换后的字节数组
	 * @throws IOException
	 */
	public byte[] transformChart2ByteArray(String svg, String imgType) throws IOException{
		ByteArrayOutputStream bout = new ByteArrayOutputStream();
		svg = svg.replaceAll(":rect", "rect");
		String ext = "";
		Transcoder t = null;
		
		if(imgType.equalsIgnoreCase("image/png")){
			ext = "png";
			t = new PNGTranscoder();
		}else if(imgType.equalsIgnoreCase("image/jpeg")){
			ext = "jpg";
			t = new JPEGTranscoder();
		}else if(imgType.equalsIgnoreCase("application/pdf")){
			ext = "pdf";
			t = new PDFTranscoder();
		}else if(imgType.equalsIgnoreCase("image/svg+xml")){
			ext = "svg";
		}
		
		if(null != t){
			TranscoderInput input = new TranscoderInput(new StringReader(svg));
			TranscoderOutput output = new TranscoderOutput(bout);
			try{
				t.transcode(input, output);
			}catch(TranscoderException e){
				bout.write("Problem transcoding stream. See the web logs for more details.".getBytes());
				e.printStackTrace();
			}
			if("svg".equalsIgnoreCase(ext)){
				Writer writer = new PrintWriter(bout);
				writer.append(svg);
				writer.close();
			}
		}
		bout.close();
		return bout.toByteArray();
	}

	/**
	 * 批量更新系统资源统计数据
	 * @param resrcList 系统资源实体集合
	 * @return 0 : 更新失败; 1 : 更新成功
	 */
	@Transactional
	public int update(List<WeekResourceVo> resrcList) {
		int results = 0;
		for(WeekResourceVo vo : resrcList){
			results =+ update(vo);
		}
		return results;
	}
	
	/**
	 * 更新系统资源统计数据
	 * @param vo 系统资源实体
	 * @return 0 : 更新失败; 1 : 更新成功
	 */
	@Transactional
	public int update(WeekResourceVo vo){
		StringBuilder sql = new StringBuilder();
		sql.append("update WeekResourceVo w ")
			.append("set w.cpuPeak = :cpuPeak, ")
			.append("	   w.cpuOnlinePeakAvg = :cpuOnlinePeakAvg, ")
			.append("	   w.cpuBatchPeakAvg = :cpuBatchPeakAvg, ")
			.append("	   w.memPeak = :memPeak, ")
			.append("	   w.memOnlinePeakAvg = :memOnlinePeakAvg, ")
			.append("	   w.memBatchPeakAvg = :memBatchPeakAvg, ")
			.append("	   w.ioPeak = :ioPeak, ")
			.append("	   w.ioOnlinePeakAvg = :ioOnlinePeakAvg, ")
			.append("	   w.ioBatchPeakAvg = :ioBatchPeakAvg, ")
			.append("	   w.reviseFlag = 1 ")
			.append("where w.aplCode = :aplCode ")
			.append("and w.countWeek = :countWeek ")
			.append("and w.srvCode = :srvCode ");
		
		return getSession().createQuery(sql.toString())
				.setString("cpuPeak", vo.getCpuPeak())
				.setString("cpuOnlinePeakAvg", vo.getCpuOnlinePeakAvg())
				.setString("cpuBatchPeakAvg", vo.getCpuBatchPeakAvg())
				.setString("memPeak", vo.getMemPeak())
				.setString("memOnlinePeakAvg", vo.getMemOnlinePeakAvg())
				.setString("memBatchPeakAvg", vo.getMemBatchPeakAvg())
				.setString("ioPeak", vo.getIoPeak())
				.setString("ioOnlinePeakAvg", vo.getIoOnlinePeakAvg())
				.setString("ioBatchPeakAvg", vo.getIoBatchPeakAvg())
				.setString("aplCode", vo.getAplCode())
				.setString("countWeek", vo.getCountWeek())
				.setString("srvCode", vo.getSrvCode())
				.executeUpdate();				
	}
	
}
