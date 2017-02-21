delete from sym_trigger_router;
delete from sym_trigger;
delete from sym_router;
delete from sym_channel where channel_id in ('example');
delete from sym_node_group_link;
delete from sym_node_group;
delete from sym_node_host;
delete from sym_node_identity;
delete from sym_node_security;
delete from sym_node;

insert into sym_channel 
(channel_id, processing_order, max_batch_size, enabled, description)
values('example', 1, 100000, 1, 'an example table');

insert into sym_node_group (node_group_id) values ('master');
insert into sym_node_group (node_group_id) values ('slave');

insert into sym_node_group_link (source_node_group_id, target_node_group_id, data_event_action) values ('master', 'slave', 'W');
insert into sym_node_group_link (source_node_group_id, target_node_group_id, data_event_action) values ('slave', 'master', 'P');

insert into sym_trigger 
(trigger_id,source_table_name,channel_id,last_update_time,create_time)
values('example','example','example',current_timestamp,current_timestamp);

insert into sym_router 
(router_id,source_node_group_id,target_node_group_id,router_type,create_time,last_update_time)
values('master_2_slave', 'master', 'slave', 'default',current_timestamp, current_timestamp);

insert into sym_router 
(router_id,source_node_group_id,target_node_group_id,router_type,create_time,last_update_time)
values('slave_2_master', 'slave', 'master', 'default',current_timestamp, current_timestamp);

insert into sym_trigger_router 
(trigger_id,router_id,initial_load_order,last_update_time,create_time)
values('example','master_2_slave', 100, current_timestamp, current_timestamp);

insert into sym_node (node_id,node_group_id,external_id,sync_enabled,sync_url,schema_version,symmetric_version,database_type,database_version,heartbeat_time,timezone_offset,batch_to_send_count,batch_in_error_count,created_at_node_id) 
 values ('000','master','000',1,null,null,null,null,null,current_timestamp,null,0,0,'000');
insert into sym_node (node_id,node_group_id,external_id,sync_enabled,sync_url,schema_version,symmetric_version,database_type,database_version,heartbeat_time,timezone_offset,batch_to_send_count,batch_in_error_count,created_at_node_id) 
 values ('001','slave','001',1,null,null,null,null,null,current_timestamp,null,0,0,'000');

insert into sym_node_security (node_id,node_password,registration_enabled,registration_time,initial_load_enabled,initial_load_time,created_at_node_id) 
 values ('000','5d1c92bbacbe2edb9e1ca5dbb0e481',0,current_timestamp,0,current_timestamp,'000');
insert into sym_node_security (node_id,node_password,registration_enabled,registration_time,initial_load_enabled,initial_load_time,created_at_node_id) 
 values ('001','5d1c92bbacbe2edb9e1ca5dbb0e481',1,null,1,null,'000');

insert into sym_node_identity values ('000');