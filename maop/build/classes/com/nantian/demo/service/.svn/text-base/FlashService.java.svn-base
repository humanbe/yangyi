package com.nantian.demo.service;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nantian.jeda.security.util.SecurityUtils;

@Service
@Repository
@Transactional
public class FlashService {

	/**
	 * HIBERNATE Session Factory.
	 */
	@Autowired
	private SessionFactory sessionFactory;

	@Autowired
	private SecurityUtils securityUtils;

	public Session getSession() {
		return sessionFactory.getCurrentSession();
	}

	/**
	 * 根据系统代码、渠道号查询记录.
	 * 
	 * @param appSystemId
	 *            系统代码
	 * @param outtrancode
	 *            外部交易码
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object find(String appsystemid, String outtrancode) {
		System.out.println("appsystemid:" + appsystemid);
		System.out.println("outtrancode:" + outtrancode);
		String hql = "select new map(t.appsystemid as appsystemid, t.outtrancode as outtrancode) "
				+ "from TranInfo t where 1=1 ";

		if (null != appsystemid && !"".equals(appsystemid)) {
			hql = hql + " and t.appsystemid = :appsystemid";
		}

		if (null != outtrancode && !"".equals(outtrancode)) {
			hql = hql + " and t.outtrancode = :outtrancode";
		}

		return getSession().createQuery(hql).setString("appsystemid",
				appsystemid).setString("outtrancode", outtrancode).list();

	}
	
	@Transactional(readOnly = true)
	public Object findEnter(String tranid) {
		System.out.println("tranid:" + tranid);
		String hql = "select new map(t.tranid as tranId, c.callId as serviceName, t.appsystemid as appSystemID, t.chnlno as chnlNo, t.outtrancode as outTrancode, t.trancode as trancode, t.trantime as tranTime, t.tranname as tranName, t.busimoduelname as busiModuelName, t.higouttrancode as higOutTrancode, t.serviceid as serviceId, c.callId as callId, c.calledId as calledId, c.headNode as headNode, c.calledFlag as calledFlag, c.commprotocol as commprotocol, c.callway as callway, c.condition as condition, c.callnum as callnum) "
				+ "from TranInfo t, CallInfoVo c where t.tranid = c.callId and c.callId = :tranid";
		return getSession().createQuery(hql).setString("tranid",
				tranid).list();

	}

	public Object findOhterNode(String callId, String reqServiceName) {
		System.out.println("reqServiceName:"+reqServiceName);
		System.out.println("callId:"+callId);
			String sql = "select :reqServiceName as \"reqServiceName\",  c.called_id as \"serviceName\",  c.called_id as \"tranId\", t.trancode as \"trancode\", t.trantime as \"trantime\",  substr(c.called_id,1,instr(c.called_id, '_', 1, 1)-1) as \"appSystemID\",   substr(c.called_id,1,instr(c.called_id, '_', 1, 1)-1) as \"outAppSystemId\", t.CHNLNO as \"chnlNo\", t.outtrancode as \"touttrancode\", nvl(t.outtrancode, '') as \"routTrancode\", t.TRANNAME as \"tranName\", t.BUSIMODUELNAME as \"busiModuelName\", t.HIGOUTTRANCODE as \"higOutTrancode\", c.COMMPROTOCOL as \"commProtocol\", c.CALLWAY as \"callWay\", c.CALLNUM as \"callNum\",c.CONDITION as \"condition\", t.serviceid as \"serviceId\" , c.call_id  as \"callId\", c.called_id as \"calledId\", c.head_node as \"headNode\", c.called_flag    as \"calledFlag\"  " 
				+ " from T_TRAN_INFO t, t_call_info c   where t.tranid = c.call_id and t.tranid=:callId order by c.callnum"; 
			return getSession().createSQLQuery(sql)
					.setString("callId", callId)
					.setString("reqServiceName", reqServiceName)
					.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();
	}
	public Object findSecondNode(String callId, String reqServiceName) {
		System.out.println("reqServiceName:"+reqServiceName);
		System.out.println("callId:"+callId);
			String sql = "select :reqServiceName as \"reqServiceName\", t.TRANID as \"serviceName\", t.TRANID as \"tranId\", t.trancode as \"trancode\", t.trantime as \"trantime\",  substr(c.called_id,1,instr(c.called_id, '_', 1, 1)-1) as \"appSystemID\",   substr(c.called_id,1,instr(c.called_id, '_', 1, 1)-1) as \"outAppSystemId\", t.CHNLNO as \"chnlNo\", t.outtrancode as \"outTrancode\",  t.TRANNAME as \"tranName\", t.BUSIMODUELNAME as \"busiModuelName\", t.HIGOUTTRANCODE as \"higOutTrancode\", c.COMMPROTOCOL as \"commProtocol\", c.CALLWAY as \"callWay\", c.CALLNUM as \"callNum\",c.CONDITION as \"condition\", t.serviceid as \"serviceId\" , c.call_id  as \"callId\", c.called_id as \"calledId\", c.head_node as \"headNode\", c.called_flag    as \"calledFlag\"  " 
				+ " from T_TRAN_INFO t, t_call_info c   where t.tranid = c.called_id and t.tranid=:callId order by c.callnum"; 
			return getSession().createSQLQuery(sql)
					.setString("callId", callId)
					.setString("reqServiceName", reqServiceName)
					.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();
	}


	@Transactional(readOnly = true)
	public Long count(String tranId) {
		Query query = null;
		System.out.println("tranId:" + tranId);
		String hql = "select count(*) from TranInfo t where t.tranid = :tranId ";

		query = getSession().createQuery(hql).setString("tranId",
				tranId);

		return Long.valueOf(query.uniqueResult().toString());
	}

	/**
	 * 根据交易ID查看是否是内部交易.
	 * 
	 * @param tranId
	 *            交易ID
	 * @return
	 */
	@Transactional(readOnly = true)
	public Long countTranid(String tranId) {
		Query query = null;
		System.out.println("tranId:" + tranId);
		String sql = "select count(*) from T_TRAN_INFO t where t.HIGOUTTRANCODE = :tranId";

		query = getSession().createSQLQuery(sql).setString("tranId", tranId);

		return Long.valueOf(query.uniqueResult().toString());
	}

	/**
	 * 根据交易ID和调用方式查看是否是条件节点.
	 * 
	 * @param tranId
	 *            交易ID
	 * @return
	 */
	@Transactional(readOnly = true)
	public Object countCondition(String tranId) {
		System.out.println("tranId:" + tranId);
		String sql = "select t.AppSystemId as appSystemId, t.HigOutTrancode as serviceName, t.HigOutTrancode as tranId, t.Condition as condition  "
				+ "from T_TRAN_INFO t where t.HIGOUTTRANCODE = :tranId and t.CallWay='T'";

		return getSession().createSQLQuery(sql).setString("tranId", tranId)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();

	}

	/**
	 * 查询内部节点记录.
	 * 
	 * @param tranId
	 *            交易ID
	 * @return
	 */
	@Transactional(readOnly = true)
	@SuppressWarnings("unchecked")
	public Object findInside(String tranId) {
		System.out.println("tranId:" + tranId);
		String sql = "select  r.TranId as tranId, r.TranId as serviceName, r.APPSYSTEMID as appsystemid,t.trancode as trancode, t.trantime as trantime, r.OUTAPPSYSTEMID as outAppSystemId, r.OUTTRANCODE as outTrancode, r.OUTSERIVCESID as lastoutSerivcesId, t.CHNLNO as chnlNo, t.TRANNAME as tranName, t.BUSIMODUELNAME as busiModuelName, t.HIGOUTTRANCODE as higOutTrancode, r.COMMPROTOCOL as commProtocol, r.CALLWAY as callWay, r.CALLNUM as callNum, r.reserve as reserve, r.reserve1 as reserve1, r.isnode as isnode, t.condition as Tcondition, r.condition as Rcondition, t.serviceid as serviceId, (select v.SERVENAME from T_SERVE_INFO v where v.appsystemid =r.outappsystemid and r.outserivcesid = v.serveid ) as servename "
				+ "from T_TRAN_INFO t, T_REL_SERVICE_INFO r where t.HIGOUTTRANCODE = :tranId  and t.TRANID=r.TRANID order by r.CallWay, r.CallNum";

		return getSession().createSQLQuery(sql).setString("tranId", tranId)
				.setResultTransformer(Criteria.ALIAS_TO_ENTITY_MAP).list();
	}
}
