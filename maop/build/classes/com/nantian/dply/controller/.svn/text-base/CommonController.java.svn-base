package com.nantian.dply.controller;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.security.core.session.SessionRegistry;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.support.DefaultMultipartHttpServletRequest;

import com.nantian.jeda.Constants;
import com.nantian.jeda.JEDAException;
/**
 * @author <a href="mailto:fujunze@nantian.com.cn">LJay</a>
 * 
 */
@Controller
@RequestMapping("/" + Constants.MANAGE_PATH + "/common")
public class CommonController {
	
	/** 日志输出 */
	final Logger logger = LoggerFactory.getLogger(CommonController.class);
	
	/** 国际化资源 */
	@Autowired
	private MessageSourceAccessor messages;
	
	@Autowired
	private SessionRegistry sessionRegistry;
	
	/**
	 * 上传文件
	 * @param request
	 * @param response
	 * @throws JEDAException
	 * @throws IOException
	 * @throws Exception
	 */
	@RequestMapping(value = "/upload", method = RequestMethod.POST)
	public void upload(HttpServletRequest request, 
			HttpServletResponse response) throws JEDAException, IOException , Exception{
		ServletContext  servletContext  = request.getSession().getServletContext();    
		String uploadPath = servletContext.getRealPath(File.separatorChar + Constants.UPLOAD_DIR) +  File.separatorChar;
		PrintWriter out = null;
		InputStream in = null;
		OutputStream os = null;
		String fileNmWithExtension = "";
		String fileNm = "";
		String extend = "";
		JSONObject json = new JSONObject();
		long currentTime = System.currentTimeMillis();//时间戳		
		out = response.getWriter();
		DefaultMultipartHttpServletRequest multipartRequest = (DefaultMultipartHttpServletRequest) request;
		// 获得文件对象
		Iterator<?> fileNames = multipartRequest.getFileNames();
		
		if (fileNames.hasNext()) {
			// 单个文件对象
			String fileName = (String) fileNames.next();
			MultipartFile multiFile = multipartRequest.getFile(fileName);
			// 获得文件名
			fileNmWithExtension = multiFile.getOriginalFilename();
			// 文件大小
			long size = (long) multiFile.getSize();
			File dir = new File(uploadPath);
			logger.info(messages.getMessage("parameter.file.upload.path") + " : " + dir.getAbsolutePath());
			if ("".equals(fileNmWithExtension)) {
				json.put("success", false);
				json.put("error", messages.getMessage("file.not.found"));
			} else if (!dir.exists() && !dir.mkdirs()) {
				json.put("success", false);
				json.put("error", messages.getMessage("directory.create.not.power", new Object[] {dir.getAbsolutePath()}));
			}else if(size > Constants.UPLOAD_MAX_SIZE){
				json.put("success", false);
				json.put("error", messages.getMessage("file.maxsize.beyond"));
			}else{
				//文件扩展名				extend = fileNmWithExtension.substring(fileNmWithExtension.lastIndexOf("."));
				//文件名				fileNm = fileNmWithExtension.substring(0, fileNmWithExtension.lastIndexOf("."));
				//保存的文件名
				fileNmWithExtension = fileNm.concat(String.valueOf(currentTime)).concat(extend);
				int len = 0;
				byte[] keyByte = new byte[1024];
				// 上传文件的字节				byte[] buf = new byte[(int)size];
				/** ***上传文件处理**** */
				// 获得上传文件的输入流
				in = multiFile.getInputStream();
				//加上时间戳, 防止文件被覆盖				os = new FileOutputStream(uploadPath.concat(fileNmWithExtension));
				
				while ((len = in.read(buf)) != -1) {
					for (int i = 0; i < len; i++) {
						buf[i] ^= keyByte[i % keyByte.length];
					}
					os.write(buf, 0, len);
				}
				
				os.flush();
				
				if (os != null) {
					os.close();
				}
				
				if (in != null) {
					in.close();
				}
				
				json.put("success", true);
				json.put("filePath", uploadPath.concat(fileNmWithExtension));
			}
			out.print(json);
			out.close();
		}
	}
	
	/**
	 * 取得在线人数
	 * 
	 * @param modelMap
	 * @return
	 */
	@RequestMapping(value = "/getOnlineUserNum", method = RequestMethod.POST)
	public @ResponseBody
	ModelMap getOnlieUserNum(ModelMap modelMap) throws JEDAException {
		try {
			modelMap.addAttribute("success", Boolean.TRUE);
			modelMap.addAttribute("onlineUserNum", sessionRegistry.getAllPrincipals().size());
		} catch (Exception e) {
			e.printStackTrace();
			modelMap.addAttribute("success", Boolean.FALSE);
			modelMap.addAttribute("onlineUserNum", "1");
		}
		return modelMap;
	}
	
	/**
	 * 取得在线人数
	 * @param response 
	 */
	@RequestMapping(value = "/getOnlineUserNum", method = RequestMethod.GET)
	public @ResponseBody void browseCodeMap(
			HttpServletResponse response){
		JSONArray json = new JSONArray();
		PrintWriter out = null;
		
		List<Map<String, String>> list = new ArrayList<Map<String,String>>();
		Map<String, String> map = new HashMap<String, String>();
		try{
			map.put("onlineUserNum", String.valueOf(sessionRegistry.getAllPrincipals().size()));
			list.add(map);
			json = JSONArray.fromObject(list);
			out = response.getWriter();
			out.print(json);
		}catch(IOException e){
			e.printStackTrace();
		}finally{
			out.close();
		}	
	}
	
}
