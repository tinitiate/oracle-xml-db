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
     ,"Property"         Property_T
   );
/
create or replace type RMQ_CommandConfig_T as table of RMQ_CommandConfig;
/

create or replace type RMQ_Commands as object
   (
      "CommandConfig"    CommandConfig_T
   );
/
create or replace type RMQ_Commands_T as table of RMQ_Commands;
/
create or replace type RMQ_MessageConfig as object
   (
      "MessageType"                    varchar2(1000)
     ,"CommunicationDirection"         varchar2(1000)
     ,"Commands"                       Commands_T
   );
/
create or replace type RMQ_MessageConfig_T as table of RMQ_MessageConfig;
/

create or replace type RMQ_MessageConfigs as object
   (
      "MessageConfig"    MessageConfig_T
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
     ,"AppInfo"          AppInfo_T
     ,"MessageConfigs"   MessageConfigs_T
   )
/
create or replace type RMQ_ConfigResponse_T as table of RMQ_ConfigResponse;
/
