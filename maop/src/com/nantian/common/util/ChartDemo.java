package com.nantian.common.util;

import java.awt.Font;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;

import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartFrame;
import org.jfree.chart.ChartPanel;
import org.jfree.chart.ChartRenderingInfo;
import org.jfree.chart.ChartUtilities;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.StandardChartTheme;
import org.jfree.chart.plot.PiePlot;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.title.LegendTitle;
import org.jfree.chart.title.TextTitle;
import org.jfree.data.category.DefaultCategoryDataset;
import org.jfree.data.general.DefaultPieDataset;
import org.jfree.ui.ApplicationFrame;
import org.jfree.ui.RefineryUtilities;

public class ChartDemo extends ApplicationFrame{

	public ChartDemo(String title) throws IOException {
		super(title);
	    // 1.创建饼图
		JFreeChart chart = ChartFactory.createPieChart(
				"系统交易量统计图",
				getDataSet(),
				true, // 是否显示图例
				false, // 是否显示工具提示
				false // 是否生成URL
		);
		// 重新设置图表标题，改变字体
		chart.setTitle(new TextTitle("系统交易量统计图", new Font("黑体", Font.ITALIC, 22)));
		// 取得统计图例的第一个图例
		LegendTitle legend = chart.getLegend(0);
		// 修改图例的字体
		legend.setItemFont(new Font("宋体", Font.BOLD, 14));
		// 获得饼图的plot对象
		PiePlot plot = (PiePlot) chart.getPlot();
		// 设定饼图部分的标签字体
		plot.setLabelFont(new Font("隶书", Font.BOLD, 18));
		// 设定背景透明度（0-1.0）
		plot.setBackgroundAlpha(0.9f);
		// 输出文件流
		FileOutputStream fosJpg = null;
		FileOutputStream fosCrl = null;
		PrintWriter w = null;
		fosJpg = new FileOutputStream("d:\\book.jpg");
		ChartRenderingInfo info = new ChartRenderingInfo();
		ChartUtilities.writeChartAsJPEG(
				fosJpg, 
				1, // 图片质量，0-1
				chart, 
				800, 
				600,
				info
		);
		fosCrl = new FileOutputStream("d:\\book.map");
		w = new PrintWriter(fosCrl);
		ChartUtilities.writeImageMap(w, "map name", info,true);
		w.flush();
		fosJpg.close();
		fosCrl.close();
		
		
	    // 2.创建类别图（Category）数据对象
		DefaultCategoryDataset dataset = new DefaultCategoryDataset();
        dataset.addValue(100, "北京", "苹果");
        dataset.addValue(100, "上海", "苹果");
        dataset.addValue(100, "广州", "苹果");
        
        dataset.addValue(200, "北京", "梨子");
        dataset.addValue(200, "上海", "梨子");
        dataset.addValue(200, "广州", "梨子");
        
        dataset.addValue(300, "北京", "葡萄");
        dataset.addValue(300, "上海", "葡萄");
        dataset.addValue(300, "广州", "葡萄");
        
        dataset.addValue(400, "北京", "香蕉");
        dataset.addValue(400, "上海", "香蕉");
        dataset.addValue(400, "广州", "香蕉");
        
        dataset.addValue(500, "北京", "荔枝");
        dataset.addValue(500, "上海", "荔枝");
        dataset.addValue(500, "广州", "荔枝");
     //创建主题样式         
       StandardChartTheme standardChartTheme=new StandardChartTheme("CN");
     //设置标题字体         
       standardChartTheme.setExtraLargeFont(new Font("隶书",Font.BOLD,20));
     //设置图例的字体         
       standardChartTheme.setRegularFont(new Font("宋书",Font.PLAIN,15));
     //设置轴向的字体         
       standardChartTheme.setLargeFont(new Font("宋书",Font.PLAIN,15));
     //应用主题样式         
       ChartFactory.setChartTheme(standardChartTheme);
      JFreeChart chart2=ChartFactory.createBarChart3D("水果产量图", "水果", "水果", dataset, PlotOrientation.VERTICAL, true, true, true);
//        TextTitle textTitle = chart.getTitle();
//      textTitle.setFont(new Font("宋体", Font.BOLD, 20));
//      LegendTitle legend = chart.getLegend();
//      if (legend != null) {  
//          legend.setItemFont(new Font("宋体", Font.BOLD, 20));
//      }         
     ChartFrame  frame=new ChartFrame ("水果产量图 ",chart2,true);
     frame.pack();
     frame.setVisible(true);
     
     ChartPanel chartPanel = new ChartPanel(chart);
     chartPanel.setPreferredSize(new java.awt.Dimension(500, 270));
     setContentPane(chartPanel);
     
	}

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * @param args
	 */
	public static void main(String[] args) throws IOException{
		ChartDemo chartDemo = new ChartDemo("chart demo test");
		chartDemo.pack();
		RefineryUtilities.centerFrameOnScreen(chartDemo);
		chartDemo.setVisible(true);

	}
	
	private static DefaultPieDataset getDataSet() {
		DefaultPieDataset dataset = new DefaultPieDataset();
		dataset.setValue("网银交易量",10);
		dataset.setValue("核心交易量", 20);
		dataset.setValue("前置交易量", 30);
		dataset.setValue("路书访问量", 40);
		return dataset;
	}

}
