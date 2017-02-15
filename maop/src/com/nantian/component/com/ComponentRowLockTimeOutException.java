package com.nantian.component.com;

/**
 * ��Օ��i�̍s���b�N�^�C���A�E�g��O�N���X�ł��B
 * <P>DB���i�ɂčs���b�N�̃^�C���A�E�g�������������Ƃ�ʒm���܂��B
 * @author dong
 */
public class ComponentRowLockTimeOutException extends ComponentTimeOutException{

	/** serialVersionUID */
	private static final long serialVersionUID = 1L;

	/**
	 * �R���X�g���N�^
	 * @param message �G���[���b�Z�[�W
	 * @param errorCode �G���[�R�[�h
	 * @param throwable Throwable
	 */
	public ComponentRowLockTimeOutException(String message, int errorCode, Throwable throwable) {
		super(message, errorCode, throwable);
	}
}
