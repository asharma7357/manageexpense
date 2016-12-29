prompt
prompt Create trigger TRG_DFP_STG_PAD_LOAD_LOG
prompt =======================================
prompt
CREATE OR REPLACE TRIGGER trg_dfp_stg_pad_load_log AFTER delete ON dfp_stg_pad_load_log for each row
BEGIN
	insert into dfp_stg_pad_load_log_hist (
		min_update_dt,
		max_update_dt,
		start_ts,
		end_ts,
		tot_time_taken,
		pad_load_cnt,
		pad_supp_load_cnt,
		status_cd,
		status_msg,
		insert_ts)
	values (
		:old.min_update_dt,
		:old.max_update_dt,
		:old.start_ts,
		:old.end_ts,
		:old.tot_time_taken,
		:old.pad_load_cnt,
		:old.pad_supp_load_cnt,
		:old.status_cd,
		:old.status_msg,
		systimestamp
	);
	
end;
/


