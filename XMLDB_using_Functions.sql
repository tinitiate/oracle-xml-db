----------------------------------------------------
-- Generation of XMLs from Oracle DB
-- Using Oracle XMLDB Functions
-- Venkata Bhattaram
----------------------------------------------------

------------------------------------------------------
-- Create raw XMLTYPE view (WITH ONE COLUMN)
------------------------------------------------------

create or replace view mq_msg_ribbonconfig_xmldb_vw
 AS
select xmlelement("ConfigResponse",XMLAttributes(mq_msg_app_id as "id")
       ,XMLConcat(
        xmlelement("TimeStamp",start_timestamp)
       ,xmlelement("ExpiresOn",end_timestamp)
       ,xmlelement("AppInfo",
                      XMLConcat(
                         xmlelement("AppName", APP_NAME)
                        ,xmlelement("Enviroment", ENVIROMENT)
                        ,xmlelement("Node", NODE)
                               )
                   )
       ,(select   xmlagg(xmlelement("MessgeConfig",
                     XMLConcat(
                        xmlelement("MessageType", message_type)
                       ,xmlelement("CommunicationType", communication_type)
                       ,xmlelement("Commands"
                                 ,(select  xmlagg(xmlelement( "CommandConfig"
                                                       ,( select  XMLConcat(
                                                                  xmlelement( "CommandType", command_type)
                                                                  ,xmlagg(xmlelement( "Property",XMLforest( property_name  as "Name"
                                                                                                            ,property_value as "Value")))
                                                                         )
                                                           from   mq_msg_ribbon_cmd_config mcc2
                                                           where  mcc1.mq_msg_dtl_id = mcc2.mq_msg_dtl_id
                                                           and    mcc1.mq_msg_app_id = mcc2.mq_msg_app_id
                                                           and    mcc1.command_type  = mcc2.command_type
                                                           group  by mcc2.command_type )
                                                       )
                                                  )
                                      from   (select distinct mq_msg_dtl_id,mq_msg_app_id,command_type
                                              from   mq_msg_ribbon_cmd_config
                                              ) mcc1
                                      where  mdc.mq_msg_dtl_id = mcc1.mq_msg_dtl_id
                                      and    mdc.mq_msg_app_id  = mcc1.mq_msg_app_id )
                                  )
                     )
                )
             )
       from   mq_msg_ribbon_dtl_config mdc
       where  mmr.mq_msg_app_id = mdc.mq_msg_app_id )
       )
     ) as config_xml
from mq_msg_ribbon_config mmr;


---------------------------------------------------------------------------
-- Final XML view that is exposed to services, with extra Identifier column
---------------------------------------------------------------------------

create or replace view mq_msg_ribbonconfig_xml_vw1
as
select  x.appname                                 as app_name
        ,XMLSerialize(DOCUMENT v.config_xml as clob)      as config_xml
from    mq_msg_ribbonconfig_xmldb_vw v
       ,xmltable('/ConfigResponse/AppInfo/AppName'
                  passing v.config_xml
                  columns         
                  AppName  varchar2(1000) path 'text()') x;
