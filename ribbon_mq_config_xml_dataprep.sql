create table bkp_mq_msg_ribbon_config
as
select * from mq_msg_ribbon_config;

create table bkp_mq_msg_ribbon_dtl_config
as
select * from mq_msg_ribbon_dtl_config;

create table bkp_mq_msg_ribbon_cmd_config
as
select * from mq_msg_ribbon_cmd_config;


-- Volume data loader

-- 100000 Rows for mq_msg_ribbon_config
insert into mq_msg_ribbon_config
select   mq_msg_seq.nextval,    --mq_msg_app_id
         start_timestamp, 
         end_timestamp, 
         app_name, 
         enviroment, 
         node, 
         add_dtime, 
         add_user_id, 
         upd_dtime, 
         upd_user_id
from     bkp_mq_msg_ribbon_config
connect  by level < 100001


begin
   for c1 in (select * from mq_msg_ribbon_config)
   loop
       for c2 in (select * from bkp_mq_msg_ribbon_dtl_config)
       loop
           insert into mq_msg_ribbon_dtl_config
              values (
                        mq_msg_seq.nextval,  -- mq_msg_dtl_id, 
                        c1.mq_msg_app_id,
                        c2.message_type, 
                        c2.communication_type, 
                        c2.add_dtime, 
                        c2.add_user_id,
                        c2.upd_dtime, 
                        c2.upd_user_id
              );
       end loop;
   end loop;
   commit;   
end;

select count(1) from mq_msg_ribbon_config;
select count(1) from mq_msg_ribbon_dtl_config;

select count(1) from bkp_mq_msg_ribbon_cmd_config


begin
   for c1 in (select * from mq_msg_ribbon_config)
   loop
       for c2 in (select * from bkp_mq_msg_ribbon_dtl_config)
       loop
           insert into mq_msg_ribbon_dtl_config
              values (
                        mq_msg_seq.nextval,  -- mq_msg_dtl_id, 
                        c1.mq_msg_app_id,
                        c2.message_type, 
                        c2.communication_type, 
                        c2.add_dtime, 
                        c2.add_user_id,
                        c2.upd_dtime, 
                        c2.upd_user_id
              );
       end loop;
   end loop;
   commit;
end;

declare
   v_ctr int := 0;
begin
   for c1 in (select * from mq_msg_ribbon_dtl_config)
   loop
       v_ctr := v_ctr +1;
       if v_ctr > 5000 then
          exit;
       end if;   
       for c2 in (select * from bkp_mq_msg_ribbon_cmd_config)
       loop
           insert into mq_msg_ribbon_cmd_config
              values (
                        mq_msg_seq.nextval,  -- mq_msg_cmd_id, 
                        c1.mq_msg_dtl_id,
                        c1.mq_msg_app_id, 
                        c2.command_type, 
                        c2.property_name, 
                        c2.property_value, 
                        c2.add_dtime, 
                        c2.add_user_id, 
                        c2.upd_dtime, 
                        c2.upd_user_id
              );
       end loop;
       commit;
   end loop;
   commit;
end;

select count(*) from mq_msg_ribbon_cmd_config;
