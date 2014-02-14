----------------------------------------------------
-- Generation of XMLs from Oracle DB
-- Using Oracle Collections (With Annotations)
-- Venkata Bhattaram
----------------------------------------------------

--Types for Annotations
------------------------

-- Create Types with a prefix for every XSD
-- e.g: RIBBON MQ : RMQ_<Object Type Name>  and RMQ_<Object Type Table Name>_T

create or replace type RMQ_Property as object
   (
      "Name"          varchar2(1000)
     ,"Value"         varchar2(1000)
   );
/
create or replace type RMQ_Property_T as table of RMQ_Property;
/

create or replace type RMQ_CommandConfig as object
   (
      "CommandType"      varchar2(1000)
     ,"Property"         RMQ_Property_T
   );
/
create or replace type RMQ_CommandConfig_T as table of RMQ_CommandConfig;
/

create or replace type RMQ_Commands as object
   (
      "CommandConfig"    RMQ_CommandConfig_T
   );
/
create or replace type RMQ_Commands_T as table of RMQ_Commands;
/
create or replace type RMQ_MessageConfig as object
   (
      "MessageType"                    varchar2(1000)
     ,"CommunicationDirection"         varchar2(1000)
     ,"Commands"                       RMQ_Commands_T
   );
/
create or replace type RMQ_MessageConfig_T as table of RMQ_MessageConfig;
/

create or replace type RMQ_MessageConfigs as object
   (
      "MessageConfig"    RMQ_MessageConfig_T
   );
/
create or replace type RMQ_MessageConfigs_T as table of RMQ_MessageConfigs;
/

create or replace type RMQ_AppInfo as object
   (
      "AppName"            varchar2(1000)
     ,"Enviroment"         varchar2(1000)
     ,"Node"               varchar2(1000)
   );
/
create or replace type RMQ_AppInfo_T as table of RMQ_AppInfo;
/
create or replace type RMQ_ConfigResponse as object
   (
      "Id"               number(20)
     ,"TimeStamp"        TimeStamp(6)
     ,"ExpiresOn"        TimeStamp(6)
     ,"AppInfo"          RMQ_AppInfo_T
     ,"MessageConfigs"   RMQ_MessageConfigs_T
   )
/
create or replace type RMQ_ConfigResponse_T as table of RMQ_ConfigResponse;
/

-------------------------------------------------------
--  Generate the XML Schema Document using the 
--  DBMS_XMLSCHEMA.generateSchema pass schema name 
--  and ObjectType representing the root element name
-------------------------------------------------------

select DBMS_XMLSCHEMA.generateSchema('INV_STG', 'RMQ_CONFIGRESPONSE') as XSD
from   DUAL;

-------------------------------------------------------
-- Annotating the XSD to use the ELEMENT-NAME override
-- !! MANUAL STEP!! 
-- Edit all all XSD ELEMENTs to CamelCase and replace 
-- the `element name="RMQ_` with `element name="`
--  and rename all complex Type names to the needed name
-------------------------------------------------------

-------------------------
-- Register the schema
-------------------------
BEGIN
   DBMS_XMLSCHEMA.registerSchema(
                              SCHEMAURL   => 'http://bn_vfill.com/ribbon_mq11.xsd',
                              SCHEMADOC   => '---PASTE THE XSD FROM THE PREVIOUS STEP---',
                              LOCAL       => TRUE,
                              GENTYPES    => FALSE,
                              GENTABLES   => FALSE);
END;
/

-- OBJECT VIEW ANNOTATION VERSION
-----------------------------------

create or replace view mq_msg_ribbon_dbtype_anno_vw
of RMQ_configresponse with object oid ("Id")
as
select   RMQ_configresponse(
         mq_msg_app_id
        ,start_timestamp
        ,end_timestamp
        ,cast(multiset(select RMQ_appinfo(app_name, enviroment, node)
                       from   mq_msg_ribbon_config aio
                       where  aio.mq_msg_app_id = mmr.mq_msg_app_id) as RMQ_appinfo_t )
        --
        ,cast(multiset(select RMQ_messageconfigs(cast(multiset(select RMQ_messageconfig( message_type
                                                                                ,communication_type
                                                                                ,cast(multiset(select RMQ_commands( cast(multiset(select  RMQ_commandconfig( command_type
                                                                                                                                                    ,cast(multiset(select RMQ_property(property_name,property_value)
                                                                                                                                                                   from   mq_msg_ribbon_cmd_config i3dc
                                                                                                                                                                   where  i3dc.command_type  = i2dc.command_type
                                                                                                                                                                   and    i3dc.mq_msg_app_id = i2dc.mq_msg_app_id
                                                                                                                                                                   and    i3dc.MQ_MSG_DTL_ID = i2dc.MQ_MSG_DTL_ID
                                                                                                                                                                   ) as RMQ_property_t )
                                                                                                                                                   )
                                                                                                                               from   mq_msg_ribbon_cmd_config i2dc
                                                                                                                               where  i2dc.mq_msg_app_id  =  irc.mq_msg_app_id
                                                                                                                               and    i2dc.MQ_MSG_DTL_ID  =  irc.MQ_MSG_DTL_ID
                                                                                                                               ) as RMQ_commandconfig_t ))
                                                                                               from dual ) as RMQ_commands_t ) )
                                                           from   mq_msg_ribbon_dtl_config     irc
                                                           where  irc.mq_msg_app_id = mmr.mq_msg_app_id ) as RMQ_messageconfig_t
                                                 )
                                            )
                       from  dual
                      ) as RMQ_messageconfigs_t )
        )
        --
from    mq_msg_ribbon_config  mmr;

------------------------------------------------------
-- Create raw XMLTYPE view (WITH ONE COLUMN)
------------------------------------------------------

CREATE OR REPLACE VIEW mq_msg_ribbonxmlraw_anno_vw OF XMLType 
XMLSCHEMA "http://bn_vfill.com/ribbon_mq11.xsd" ELEMENT "ConfigResponse"
WITH OBJECT ID DEFAULT AS
SELECT VALUE(p) FROM mq_msg_ribbon_dbtype_anno_vw p;

---------------------------------------------------------------------------
-- Final XML view that is exposed to services, with extra Identifier column
-- This is the view generated based on the annotation raw view
---------------------------------------------------------------------------
create or replace view mq_msg_ribbon_xml_dbtype_a_vw
as
select  x.appname                                           as app_name
        ,XMLSerialize(DOCUMENT v.object_value as clob)      as config_xml
from    mq_msg_ribbonxmlraw_anno_vw v
       ,xmltable('/ConfigResponse/AppInfo/AppName'
                  passing v.object_value
                  columns         
                  AppName  varchar2(1000) path 'text()') x;


