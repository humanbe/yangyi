package com.nantian.component.com;

import java.io.Serializable;

/**
 * ���O�I������LIBSYS���[�U�̃��[�U����ێ�����N���X�ł��B
 * @author dong
 */
public class ComponentUina implements Serializable {


	/** �`�[��ID */
	private String kiban_operation_scope;

	/** ���[�UID */
	private String userID;
	
	/** ���[�U�� */
	private String usr_nm;

	/** �p�X���[�h */
	private String pass;

	/** �p�X���[�h�X�V�� */
	private String pass_upd_ymd;

	/** ��Б����敪 */
	private String kish_attr_kbn;

	/** ������� */
	private String shzk_info;

	/** �A����敪 */
	private String rnrksk_kbn;

	/** ��Гd�b�ԍ� */
	private String kish_tel;

	/** �g�ѓd�b�ԍ��P */
	private String kiti_tel_1;

	/** �g�ѓd�b�ԍ��Q */
	private String kiti_tel_2;

	/** �g�ѓd�b�ԍ��R */
	private String kiti_tel_3;

	/** ���ԍ� */
	private String nisnnum;

	/** ���[���A�h���X�P */
	private String mail_1;

	/** ���[���A�h���X�Q */
	private String mail_2;

	/** ���[���A�h���X�R */
	private String mail_3;

	/** �A����O���[�v */
	private String rnrksk_grp;

	/** �A���揇 */
	private String rnrksk_jun;

	/** ��s�Ҍ��t���O */
	private String dikoshkngn_flg;

	/** ���F�O���[�v���t���O */
	private String shonngrpkngn_flg;

	/** �k�c�`�o�s�t���O */
	private String ldap_fka_flg;

	/** �����P */
	private String memo_1;

	/** �����Q */
	private String memo_2;

	/** �����R */
	private String memo_3;

	/** �o�^�N���� */
	private String reg_ymd;
	
	/** ���񃍃O�C���N�����b */
	private String knki_login_ymdhms;

	/** �O�񃍃O�C���N�����b */
	private String znki_login_ymdhms;


	/**
	 * �R���X�g���N�^�ł��B
	 */
	public ComponentUina() {
	}

	/**
	 * �`�[��ID��擾���܂��B
	 * @return �`�[��ID
	 */
	public String getKiban_operation_scope() {
		return this.kiban_operation_scope;
	}

	/**
	 * �`�[��ID��ݒ肵�܂��B
	 * @param kiban_operation_scope �`�[��ID
	 */
	public void setKiban_operation_scope(String kiban_operation_scope) {
		this.kiban_operation_scope = kiban_operation_scope;
	}


	/**
	 * ���[�UID��擾���܂��B
	 * @return ���[�UID
	 */
	public String getUserID() {
		return this.userID;
	}

	/**
	 * ���[�UID��ݒ肵�܂��B
	 * @param userID ���[�UID
	 */
	public void setUserID(String userID) {
		this.userID = userID;
	}
	
	/**
	 * ���[�U����擾���܂��B
	 * @return ���[�U��
	 */
	public String getUsr_nm() {
		return this.usr_nm;
	}

	/**
	 * ���[�U����ݒ肵�܂��B
	 * @param usr_nm ���[�U��
	 */
	public void setUsr_nm(String usr_nm) {
		this.usr_nm = usr_nm;
	}

	/**
	 * �p�X���[�h��擾���܂��B
	 * @return �p�X���[�h
	 */
	public String getPass() {
		return this.pass;
	}

	/**
	 * �p�X���[�h��ݒ肵�܂��B
	 * @param pass �p�X���[�h
	 */
	public void setPass(String pass) {
		this.pass = pass;
	}

	/**
	 * �p�X���[�h�X�V���擾���܂��B
	 * @return �p�X���[�h�X�V��
	 */
	public String getPass_upd_ymd() {
		return this.pass_upd_ymd;
	}

	/**
	 * �p�X���[�h�X�V���ݒ肵�܂��B
	 * @param pass_upd_ymd �p�X���[�h�X�V��
	 */
	public void setPass_upd_ymd(String pass_upd_ymd) {
		this.pass_upd_ymd = pass_upd_ymd;
	}

	/**
	 * ��Б����敪��擾���܂��B
	 * @return ��Б����敪
	 */
	public String getKish_attr_kbn() {
		return this.kish_attr_kbn;
	}

	/**
	 * ��Б����敪��ݒ肵�܂��B
	 * @param kish_attr_kbn ��Б����敪
	 */
	public void setKish_attr_kbn(String kish_attr_kbn) {
		this.kish_attr_kbn = kish_attr_kbn;
	}

	/**
	 * ��������擾���܂��B
	 * @return �������
	 */
	public String getShzk_info() {
		return this.shzk_info;
	}

	/**
	 * ��������ݒ肵�܂��B
	 * @param shzk_info �������
	 */
	public void setShzk_info(String shzk_info) {
		this.shzk_info = shzk_info;
	}

	/**
	 * �A����敪��擾���܂��B
	 * @return �A����敪
	 */
	public String getRnrksk_kbn() {
		return this.rnrksk_kbn;
	}

	/**
	 * �A����敪��ݒ肵�܂��B
	 * @param rnrksk_kbn �A����敪
	 */
	public void setRnrksk_kbn(String rnrksk_kbn) {
		this.rnrksk_kbn = rnrksk_kbn;
	}

	/**
	 * ��Гd�b�ԍ���擾���܂��B
	 * @return ��Гd�b�ԍ�
	 */
	public String getKish_tel() {
		return this.kish_tel;
	}

	/**
	 * ��Гd�b�ԍ���ݒ肵�܂��B
	 * @param kish_tel ��Гd�b�ԍ�
	 */
	public void setKish_tel(String kish_tel) {
		this.kish_tel = kish_tel;
	}

	/**
	 * �g�ѓd�b�ԍ��P��擾���܂��B
	 * @return �g�ѓd�b�ԍ��P
	 */
	public String getKiti_tel_1() {
		return this.kiti_tel_1;
	}

	/**
	 * �g�ѓd�b�ԍ��P��ݒ肵�܂��B
	 * @param kiti_tel_1 �g�ѓd�b�ԍ��P
	 */
	public void setKiti_tel_1(String kiti_tel_1) {
		this.kiti_tel_1 = kiti_tel_1;
	}

	/**
	 * �g�ѓd�b�ԍ��Q��擾���܂��B
	 * @return �g�ѓd�b�ԍ��Q
	 */
	public String getKiti_tel_2() {
		return this.kiti_tel_2;
	}

	/**
	 * �g�ѓd�b�ԍ��Q��ݒ肵�܂��B
	 * @param kiti_tel_2 �g�ѓd�b�ԍ��Q
	 */
	public void setKiti_tel_2(String kiti_tel_2) {
		this.kiti_tel_2 = kiti_tel_2;
	}

	/**
	 * �g�ѓd�b�ԍ��R��擾���܂��B
	 * @return �g�ѓd�b�ԍ��R
	 */
	public String getKiti_tel_3() {
		return this.kiti_tel_3;
	}

	/**
	 * �g�ѓd�b�ԍ��R��ݒ肵�܂��B
	 * @param kiti_tel_3 �g�ѓd�b�ԍ��R
	 */
	public void setKiti_tel_3(String kiti_tel_3) {
		this.kiti_tel_3 = kiti_tel_3;
	}

	/**
	 * ���ԍ���擾���܂��B
	 * @return ���ԍ�
	 */
	public String getNisnnum() {
		return this.nisnnum;
	}

	/**
	 * ���ԍ���ݒ肵�܂��B
	 * @param nisnnum ���ԍ�
	 */
	public void setNisnnum(String nisnnum) {
		this.nisnnum = nisnnum;
	}

	/**
	 * ���[���A�h���X�P��擾���܂��B
	 * @return ���[���A�h���X�P
	 */
	public String getMail_1() {
		return this.mail_1;
	}

	/**
	 * ���[���A�h���X�P��ݒ肵�܂��B
	 * @param mail_1 ���[���A�h���X�P
	 */
	public void setMail_1(String mail_1) {
		this.mail_1 = mail_1;
	}

	/**
	 * ���[���A�h���X�Q��擾���܂��B
	 * @return ���[���A�h���X�Q
	 */
	public String getMail_2() {
		return this.mail_2;
	}

	/**
	 * ���[���A�h���X�Q��ݒ肵�܂��B
	 * @param mail_2 ���[���A�h���X�Q
	 */
	public void setMail_2(String mail_2) {
		this.mail_2 = mail_2;
	}

	/**
	 * ���[���A�h���X�R��擾���܂��B
	 * @return ���[���A�h���X�R
	 */
	public String getMail_3() {
		return this.mail_3;
	}

	/**
	 * ���[���A�h���X�R��ݒ肵�܂��B
	 * @param mail_3 ���[���A�h���X�R
	 */
	public void setMail_3(String mail_3) {
		this.mail_3 = mail_3;
	}

	/**
	 * �A����O���[�v��擾���܂��B
	 * @return �A����O���[�v
	 */
	public String getRnrksk_grp() {
		return this.rnrksk_grp;
	}

	/**
	 * �A����O���[�v��ݒ肵�܂��B
	 * @param rnrksk_grp �A����O���[�v
	 */
	public void setRnrksk_grp(String rnrksk_grp) {
		this.rnrksk_grp = rnrksk_grp;
	}

	/**
	 * �A���揇��擾���܂��B
	 * @return �A���揇
	 */
	public String getRnrksk_jun() {
		return this.rnrksk_jun;
	}

	/**
	 * �A���揇��ݒ肵�܂��B
	 * @param rnrksk_jun �A���揇
	 */
	public void setRnrksk_jun(String rnrksk_jun) {
		this.rnrksk_jun = rnrksk_jun;
	}

	/**
	 * ��s�Ҍ��t���O��擾���܂��B
	 * @return ��s�Ҍ��t���O
	 */
	public String getDikoshkngn_flg() {
		return this.dikoshkngn_flg;
	}

	/**
	 * ��s�Ҍ��t���O��ݒ肵�܂��B
	 * @param dikoshkngn_flg ��s�Ҍ��t���O
	 */
	public void setDikoshkngn_flg(String dikoshkngn_flg) {
		this.dikoshkngn_flg = dikoshkngn_flg;
	}

	/**
	 * ���F�O���[�v���t���O��擾���܂��B
	 * @return ���F�O���[�v���t���O
	 */
	public String getShonngrpkngn_flg() {
		return this.shonngrpkngn_flg;
	}

	/**
	 * ���F�O���[�v���t���O��ݒ肵�܂��B
	 * @param shonngrpkngn_flg ���F�O���[�v���t���O
	 */
	public void setShonngrpkngn_flg(String shonngrpkngn_flg) {
		this.shonngrpkngn_flg = shonngrpkngn_flg;
	}

	/**
	 * �k�c�`�o�s�t���O��擾���܂��B
	 * @return �k�c�`�o�s�t���O
	 */
	public String getLdap_fka_flg() {
		return this.ldap_fka_flg;
	}

	/**
	 * �k�c�`�o�s�t���O��ݒ肵�܂��B
	 * @param ldap_fka_flg �k�c�`�o�s�t���O
	 */
	public void setLdap_fka_flg(String ldap_fka_flg) {
		this.ldap_fka_flg = ldap_fka_flg;
	}

	/**
	 * �����P��擾���܂��B
	 * @return �����P
	 */
	public String getMemo_1() {
		return this.memo_1;
	}

	/**
	 * �����P��ݒ肵�܂��B
	 * @param memo_1 �����P
	 */
	public void setMemo_1(String memo_1) {
		this.memo_1 = memo_1;
	}

	/**
	 * �����Q��擾���܂��B
	 * @return �����Q
	 */
	public String getMemo_2() {
		return this.memo_2;
	}

	/**
	 * �����Q��ݒ肵�܂��B
	 * @param memo_2 �����Q
	 */
	public void setMemo_2(String memo_2) {
		this.memo_2 = memo_2;
	}

	/**
	 * �����R��擾���܂��B
	 * @return �����R
	 */
	public String getMemo_3() {
		return this.memo_3;
	}

	/**
	 * �����R��ݒ肵�܂��B
	 * @param memo_3 �����R
	 */
	public void setMemo_3(String memo_3) {
		this.memo_3 = memo_3;
	}

	/**
	 * �o�^�N�����擾���܂��B
	 * @return �o�^�N����
	 */
	public String getReg_ymd() {
		return this.reg_ymd;
	}

	/**
	 * �o�^�N�����ݒ肵�܂��B
	 * @param reg_ymd �o�^�N����
	 */
	public void setReg_ymd(String reg_ymd) {
		this.reg_ymd = reg_ymd;
	}

	/**
	 * ���񃍃O�C���N�����b��擾���܂��B
	 * @return ���񃍃O�C���N�����b
	 */
	public String getKnki_login_ymdhms() {
		return knki_login_ymdhms;
	}

	/**
	 * ���񃍃O�C���N�����b��ݒ肵�܂��B
	 * @param knki_login_ymdhms�@���񃍃O�C���N�����b�@
	 */
	public void setKnki_login_ymdhms(String knki_login_ymdhms) {
		this.knki_login_ymdhms = knki_login_ymdhms;
	}

	/**
	 * �O�񃍃O�C���N�����b��擾���܂��B
	 * @return�@�O�񃍃O�C���N�����b
	 */
	public String getZnki_login_ymdhms() {
		return znki_login_ymdhms;
	}

	/**
	 * �O�񃍃O�C���N�����b��ݒ肵�܂��B
	 * @param znki_login_ymdhms�@�O�񃍃O�C���N�����b
	 */
	public void setZnki_login_ymdhms(String znki_login_ymdhms) {
		this.znki_login_ymdhms = znki_login_ymdhms;
	}
}
