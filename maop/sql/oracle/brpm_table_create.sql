export ORACLE_SID=MAOP
sqlplus / as sysdba

grant select on BRPMDBA.v_request_step_detail to maop;
grant select on BRPMDBA.v_request_detail to maop;

CREATE OR REPLACE VIEW V_REQUEST_DETAIL AS
select REQUEST_ID as request_id,/*请求编号*/
       NAME as request_name,/*请求名称*/
       max(request_state) as request_state,/*请求状态*/
       APP as appsyscd,/*应用编号*/
       planned_at as request_planned_at,/*排期授权时间*/
       min(scheduled_at) scheduled_at,/*排期计划开始时间*/
       min(target_completion_at) target_completion_at,/*排期计划结束时间*/
       max(Position) - sum(notExecuteNUM) as request_allstep_num,/*请求步骤数*/
       sum(ExecuteNUM) as step_executed_num,/*完成步骤数*/
       max(Position) - sum(ExecuteNUM) - sum(notExecuteNUM) as not_complete_step_num,/*剩余步骤数*/
       min(startTime) as first_step_started_at,/*首步骤开始时间*/
       max(endTime) as last_step_completed_at,/*最后一步完成时间*/
       (Max(endTime) - min(startTime)) * 24 * 60 * 60 as request_executed_time/*请求执行时长*/
  from (SELECT T1.REQUEST_ID REQUEST_ID,
               T2.NAME,
               T2.AASM_STATE as request_state,
               T3.NAME APP,
               T.ID,
               T.NAME REQUERE_NAME,
               T.Position,
               t2.planned_at + numtodsinterval(8, 'hour') planned_at,
               t2.scheduled_at + numtodsinterval(8, 'hour') scheduled_at,
               t2.target_completion_at + numtodsinterval(8, 'hour') target_completion_at,
               case
                 when t.work_started_at is null or
                      T.WORK_FINISHED_AT is null or t.aasm_state <> 'complete' then
                  0
                 else
                  1
               end ExecuteNUM,
               case
                 when t.should_execute = '1' then
                  0
                 else
                  1
               end notExecuteNUM,
               T.DIFFERENT_LEVEL_FROM_PREVIOUS TB, /*1代表顺序步骤，0代表与前步骤并发执行*/
               case
                 when T.MANUAL = '1' then
                  '手工'
                 else
                  '自动'
               end MANUAL,
               T.AASM_STATE as step_state,
               T.WORK_STARTED_AT + numtodsinterval(8, 'hour') startTime,
               T.WORK_FINISHED_AT + numtodsinterval(8, 'hour') endTime,
               to_char(T.WORK_STARTED_AT + numtodsinterval(8, 'hour'),
                       'yyyy/mm/dd') exeDate,
               to_char(T.WORK_STARTED_AT + numtodsinterval(8, 'hour') +
                       numtodsinterval(1, 'minute'),
                       'HH24:mi') exeTime

          FROM BRPMDBA.STEPS T
         INNER JOIN BRPMDBA.APPS_REQUESTS T1 ON T.REQUEST_ID = T1.REQUEST_ID
         INNER JOIN BRPMDBA.REQUESTS T2 ON T1.REQUEST_ID = T2.ID
          left JOIN BRPMDBA.APPS T3 ON T1.APP_ID = T3.ID
         where T3.NAME is not null
           and t2.aasm_state != 'deleted'
           and t2.request_template_id is null
         order by t3.name, t1.request_id, t.position)
 group by REQUEST_ID, NAME, APP, planned_at
 order by planned_at;




CREATE OR REPLACE VIEW V_REQUEST_STEP_DETAIL AS
SELECT T1.REQUEST_ID REQUEST_ID,
               T2.NAME as REQUEST_NAME,
               T2.AASM_STATE as request_state,
               T3.NAME APP,
               T.ID,
               T.NAME as NAME,
               T.Position,
               t2.planned_at + numtodsinterval(8, 'hour') planned_at,
               t2.scheduled_at + numtodsinterval(8, 'hour') scheduled_at,
               t2.target_completion_at + numtodsinterval(8, 'hour') target_completion_at,
               case
                 when t.work_started_at is null or
                      T.WORK_FINISHED_AT is null then
                  0
                 else
                  1
               end ExecuteNUM,
               case
                 when t.should_execute = '1' then
                  0
                 else
                  1
               end notExecuteNUM,
               T.DIFFERENT_LEVEL_FROM_PREVIOUS TB, /*1代表顺序步骤，0代表与前步骤并发执行*/
               case
                 when T.MANUAL = '1' then
                  '手工'
                 else
                  '自动'
               end MANUAL,
               T.AASM_STATE as step_state,
               T.WORK_STARTED_AT + numtodsinterval(8, 'hour') startTime,
               T.WORK_FINISHED_AT + numtodsinterval(8, 'hour') endTime,
               to_char(T.WORK_STARTED_AT + numtodsinterval(8, 'hour'),
                       'yyyy/mm/dd') exeDate,
               to_char(T.WORK_STARTED_AT + numtodsinterval(8, 'hour') +
                       numtodsinterval(1, 'minute'),
                       'HH24:mi') exeTime

          FROM BRPMDBA.STEPS T
         INNER JOIN BRPMDBA.APPS_REQUESTS T1 ON T.REQUEST_ID = T1.REQUEST_ID
         INNER JOIN BRPMDBA.REQUESTS T2 ON T1.REQUEST_ID = T2.ID
          left JOIN BRPMDBA.APPS T3 ON T1.APP_ID = T3.ID
         where T3.NAME is not null
           and t2.aasm_state != 'deleted'
           and t2.request_template_id is null
         order by t3.name, t1.request_id, t.position;

