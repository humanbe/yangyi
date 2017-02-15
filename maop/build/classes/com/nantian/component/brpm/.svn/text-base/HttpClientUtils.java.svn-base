package com.nantian.component.brpm;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;

import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.client.methods.HttpDelete;
import org.apache.http.client.methods.HttpEntityEnclosingRequestBase;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpPut;
import org.apache.http.client.methods.HttpRequestBase;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.springframework.stereotype.Component;

@Component
public class HttpClientUtils {
	//xml接收/响应类型
	public static String CONTEXT_TYPE_XML = "text/xml";
	//json接收/响应类型
	public static String CONTEXT_TYPE_JSON = "application/json";
	
	/**
	 * 调用http客户端请求	 * @param uri uri地址
	 * @param content 文本内容
	 * @param acceptType 服务器接收类型	 * @param contentType 文本类型
	 * @param methodType 枚举方法名	 * @return
	 * @throws URISyntaxException
	 * @throws IOException
	 * @throws BrpmInvocationException
	 */
	public static String invokeHttpClientMethod(String uri, String content,
			String acceptType, String contentType, MethodType methodType)
			throws URISyntaxException, IOException, BrpmInvocationException {
		CloseableHttpClient client = HttpClients.custom().setMaxConnPerRoute(20).build();
		HttpRequestBase method = null;
		StringEntity entity = null;
		
		switch(methodType){
			case PUT : 
				entity = new StringEntity(null == content ? "" : content.toString().trim(),"utf-8");
				method = new HttpPut(uri);
				((HttpPut)method).setEntity(entity);
				break;
			case GET :
				StringEntity filterEntity = new StringEntity(null == content ? "" : content.toString().trim(),"utf-8");
				method = new  HttpClientUtils.HttpGetWithEntity(uri);
				((HttpClientUtils.HttpGetWithEntity)method).setEntity(filterEntity);
				break;
			case  POST :
				entity = new StringEntity(null == content ? "" : content.toString().trim(),"utf-8");
				method = new HttpPost(uri);
				((HttpPost)method).setEntity(entity);
				break;
			case DELETE :
				method = new HttpDelete(uri);
				break;
		}
				
		method.addHeader("accept", acceptType);
		method.addHeader("Content-Type", contentType);
		
		HttpResponse response = null;
		String reponseString = null;
		try {
			response = client.execute(method);
			switch(methodType){
			case PUT : 
				if(response.getStatusLine().getStatusCode() != HttpStatus.SC_ACCEPTED){
					throw new BrpmInvocationException("update failed:" + response.getStatusLine().getReasonPhrase());
				}
				break;
			case GET :
				if(response.getStatusLine().getStatusCode() != HttpStatus.SC_OK
				&& response.getStatusLine().getStatusCode() != HttpStatus.SC_NOT_FOUND){
					throw new BrpmInvocationException("query failed:" + response.getStatusLine().getReasonPhrase());
				}
				break;
			case  POST :
				if(response.getStatusLine().getStatusCode() != HttpStatus.SC_CREATED){
					throw new BrpmInvocationException("create failed:" + response.getStatusLine().getReasonPhrase());
				}
				break;
			case DELETE :
				if(response.getStatusLine().getStatusCode() != HttpStatus.SC_ACCEPTED){
					throw new BrpmInvocationException("delete failed:" + response.getStatusLine().getReasonPhrase());
				}
				break;
			}
			reponseString = EntityUtils.toString(response.getEntity()).trim();
		} catch (IOException e) {
			throw e;
		}finally{
			method.releaseConnection();
			client.close();
		}
		
		return "".equals(reponseString)?null:reponseString;
	}
	
	/**
	 * httpclient请求更新
	 * @param uri 地址
	 * @param content 文本内容
	 * @param acceptType 服务器接收类型	 * @param contentType 文本类型
	 * @return
	 * @throws IOException
	 * @throws BrpmInvocationException
	 * @throws URISyntaxException 
	 */
	public static String putMethod(String uri, String content,
			String acceptType, String contentType) throws IOException,
			BrpmInvocationException, URISyntaxException {
		return invokeHttpClientMethod(uri, content, acceptType, contentType, MethodType.PUT);
	}
	
	/**
	 * XML格式的httpclient请求更新
	 * @param url 地址
	 * @param content 文本内容
	 * @return
	 * @throws IOException
	 * @throws BrpmInvocationException
	 * @throws URISyntaxException 
	 */
	public static String putMethod(String url, String content)
			throws IOException, BrpmInvocationException, URISyntaxException {
		return putMethod(url, content, CONTEXT_TYPE_XML, CONTEXT_TYPE_XML);
	}
	
	/**
	 * httpclient请求按过滤字符串获取
	 * @param uri 地址
	 * @param filterString 过滤字符串	 * @param acceptType 服务器接收类型	 * @param contentType 文本类型
	 * @return
	 * @throws IOException 
	 * @throws BrpmInvocationException 
	 * @throws URISyntaxException 
	 */
	public static String getMethod(String uri, String filterString,
			String acceptType, String contentType) throws IOException,
			BrpmInvocationException, URISyntaxException {
		return invokeHttpClientMethod(uri, filterString, acceptType, contentType, MethodType.GET);
	}
	
	/**
	 * 服务器接收类型为XML，文本类型为JSON的httpclient请求按过滤字符串获取
	 * @param url 地址
	 * @param filterString 过滤字符串	 * @return
	 * @throws BrpmInvocationException 
	 * @throws IOException 
	 * @throws URISyntaxException 
	 */
	public static String getMethod(String url, String filterString)
			throws IOException, BrpmInvocationException, URISyntaxException {
		return getMethod(url, filterString, CONTEXT_TYPE_XML, CONTEXT_TYPE_JSON);
	}
	
	/**
	 * 服务器接收类型为XML，文本类型为XML的httpclient请求获取
	 * @param url 地址
	 * @return
	 * @throws BrpmInvocationException 
	 * @throws IOException 
	 * @throws URISyntaxException 
	 */
	public static String getMethod(String url)
			throws IOException, BrpmInvocationException, URISyntaxException {
		return getMethod(url, null, CONTEXT_TYPE_XML, CONTEXT_TYPE_XML);
	}
	
	/**
	 * httpclient请求新建
	 * @param uri 地址
	 * @param content 文本内容
	 * @param acceptType 服务器接收类型	 * @param contentType 文本类型
	 * @return
	 * @throws IOException
	 * @throws BrpmInvocationException
	 * @throws URISyntaxException 
	 */
	public static String postMethod(String uri, String content,
			String acceptType, String contentType) throws IOException,
			BrpmInvocationException, URISyntaxException {
		return invokeHttpClientMethod(uri, content, acceptType, contentType, MethodType.POST);
	}
	
	/**
	 * XML格式的httpclient请求新建
	 * @param url 地址
	 * @param content 文本内容
	 * @return
	 * @throws IOException
	 * @throws BrpmInvocationException
	 * @throws URISyntaxException 
	 */
	public static String postMethod(String url, String content)
			throws IOException, BrpmInvocationException, URISyntaxException {
		return postMethod(url, content, CONTEXT_TYPE_XML, CONTEXT_TYPE_XML);
	}
	
	/**
	 * httpclient请求删除
	 * @param uri 地址
	 * @param acceptType 服务器接收类型
	 * @param contentType 文本类型
	 * @return
	 * @throws IOException
	 * @throws BrpmInvocationException
	 * @throws URISyntaxException 
	 */
	public static String deleteMethod(String uri, String acceptType,
			String contentType) throws IOException, BrpmInvocationException,
			URISyntaxException {
		return invokeHttpClientMethod(uri, null, acceptType, contentType, MethodType.DELETE);
	}
	
	/**
	 * XML格式的httpclient请求删除
	 * @param url 地址
	 * @return
	 * @throws IOException
	 * @throws BrpmInvocationException
	 * @throws URISyntaxException 
	 */
	public static String deleteMethod(String url)
			throws IOException, BrpmInvocationException, URISyntaxException {
		return deleteMethod(url, CONTEXT_TYPE_XML, CONTEXT_TYPE_XML);
	}
	
	/**
	 * 能设置body文本的使用GET方式发送请求的请求类.
	 * @author LJay
	 *
	 */
	public static class HttpGetWithEntity extends HttpEntityEnclosingRequestBase {
		public final static String METHOD_NAME = "GET";
		
		public HttpGetWithEntity(){}
		
		public HttpGetWithEntity(String url) throws URISyntaxException{
			this();
			this.setURI(new URI(url));
			
		}
		
		public HttpGetWithEntity(URI uri){
			this();
			this.setURI(uri);
		}
		
		@Override
		public String getMethod(){
			return METHOD_NAME;
		}
	}
	
	static enum MethodType{
		PUT, GET, POST, DELETE
	}
}
