package com.nantian.toolbox.vo;

import java.io.Serializable;


/**
 * 工具箱图片 * @author daiJinyu
 *
 */
public class ToolBoxFilesVo implements Serializable{

	private static final long serialVersionUID = 1L;

	/**工具箱编号*/
	private String tool_code;
	/**文件编号*/
	private String file_id; 
	/**文件内容*/
	private byte[] file_content;
	
	/**文件类型*/
	private String file_type; 
	/**文件名称*/
	private String file_name;
	
	public String getTool_code() {
		return tool_code;
	}
	public void setTool_code(String tool_code) {
		this.tool_code = tool_code;
	}
	public String getFile_id() {
		return file_id;
	}
	public void setFile_id(String file_id) {
		this.file_id = file_id;
	}
	public byte[] getFile_content() {
		return file_content;
	}
	public void setFile_content(byte[] file_content) {
		this.file_content = file_content;
	}
	public String getFile_type() {
		return file_type;
	}
	public void setFile_type(String file_type) {
		this.file_type = file_type;
	}
	public String getFile_name() {
		return file_name;
	}
	public void setFile_name(String file_name) {
		this.file_name = file_name;
	} 
	
	
 
}
