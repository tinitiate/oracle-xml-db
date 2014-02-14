select  mq_msg_app_id
       ,APP_NAME
       ,XMLSerialize( DOCUMENT 
        xmltype.createxml
          (
             xmlData =>  RMQ_configresponse(
                           mq_msg_app_id
                          ,start_timestamp
                          ,end_timestamp
                          ,cast(multiset(select RMQ_appinfo(app_name, enviroment, node)
                                         from   mq_msg_ribbon_config aio
                                         where  aio.mq_msg_app_id = mmr.mq_msg_app_id) as RMQ_appinfo_t )
                          --
                          ,cast(multiset(select RMQ_messageconfigs(cast(multiset(select RMQ_messageconfig( message_type
                                                                                                  ,communication_type
                                                                                                  ,cast(multiset(select RMQ_commands( cast(multiset(select  RMQ_commandconfig
                                                                                                                                                               ( i2dc.command_type
                                                                                                                                                                ,cast(multiset(select RMQ_property(property_name,property_value)
                                                                                                                                                                               from   mq_msg_ribbon_cmd_config i3dc
                                                                                                                                                                               where  i3dc.command_type  = i2dc.command_type
                                                                                                                                                                               and    i3dc.mq_msg_app_id = i2dc.mq_msg_app_id
                                                                                                                                                                               and    i3dc.MQ_MSG_DTL_ID = i2dc.MQ_MSG_DTL_ID
                                                                                                                                                                               ) as RMQ_property_t )
                                                                                                                                                                     )
                                                                                                                                                    from   mq_msg_ribbon_cmd_config i2dc
                                                                                                                                                    where  i2dc.mq_msg_app_id           =  irc.mq_msg_app_id
                                                                                                                                                    and    i2dc.MQ_MSG_DTL_ID           =  irc.MQ_MSG_DTL_ID
                                                                                                                                                    --group  by  i2dc.mq_msg_app_id, i2dc.MQ_MSG_DTL_ID
                                                                                                                                                 ) as RMQ_commandconfig_t ))
                                                                                                                 from dual ) as RMQ_commands_t ) )
                                                                             from   mq_msg_ribbon_dtl_config     irc
                                                                             where  irc.mq_msg_app_id = mmr.mq_msg_app_id ) as RMQ_messageconfig_t
                                                                   )
                                                              )
                                         from  dual
                                        ) as RMQ_messageconfigs_t )
                          )
            ,schema  =>  'http://bn_vfill.com/ribbon_mq12.xsd'
            ,element =>  'RMQ_CONFIGRESPONSE'
        ) as clob )
FROM   mq_msg_ribbon_config mmr
where  mq_msg_app_id = 1
