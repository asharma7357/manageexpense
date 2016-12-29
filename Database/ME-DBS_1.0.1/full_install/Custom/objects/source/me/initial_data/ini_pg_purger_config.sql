prompt
prompt Loading PG_PURGER_CONFIG...
prompt ========================
prompt

begin
	Insert into PG_PURGER_CONFIG (CF_TABLE_GROUP,CF_TABLE_ID,CF_TABLE_NAME,CF_PRG_CLAUSE,CF_PRG_BKP_TABLE,CF_PRG_FREQ,CF_PRG_INTVL,CF_PRG_LAST_RUN,CF_PRG_NEXT_RUN,CF_PRG_BKP_FILE)
	values (1,1,'DFP_IDX_PAD_HIST','rec_dt <= add_months(trunc(sysdate),-pkg_util.get_setting(''DFP_HIST_PAD_RETENTION''))
	and		to_number(to_char(sysdate,''hh24'')) between pkg_util.get_setting(''DFP_PAD_PURGE_START_TIME'') and pkg_util.get_setting(''DFP_PAD_PURGE_END_TIME'')',null,'H',1,sysdate-1,sysdate-1,null);

	Insert into PG_PURGER_CONFIG (CF_TABLE_GROUP,CF_TABLE_ID,CF_TABLE_NAME,CF_PRG_CLAUSE,CF_PRG_BKP_TABLE,CF_PRG_FREQ,CF_PRG_INTVL,CF_PRG_LAST_RUN,CF_PRG_NEXT_RUN,CF_PRG_BKP_FILE)
	values (1,2,'DFP_IDX_PAD_T1','exists (	select	tmp.master_device_id,tmp.rec_dt
						from	(	select	/*+ user_hash(pad mdi) */
											pad.master_device_id,pad.rec_dt,
											row_number() over (partition by pad.master_device_id order by pad.rec_dt desc) as seq_id
									from	(	select	master_device_id,
														rec_dt
												from	dfp_idx_pad_t1
												group by master_device_id,rec_dt
											) pad
											join (	select	master_device_id
													from	dfp_idx_pad_t1
													group by master_device_id
													having count(1)>1
												) mdi on (mdi.master_device_id = pad.master_device_id)
								) tmp
						where	tmp.seq_id > 1
						and		tmp.master_device_id = DFP_IDX_PAD_T1.master_device_id
						and		tmp.rec_dt = DFP_IDX_PAD_T1.rec_dt
					)
	and	to_number(to_char(sysdate,''hh24'')) between pkg_util.get_setting(''DFP_PAD_PURGE_START_TIME'') and pkg_util.get_setting(''DFP_PAD_PURGE_END_TIME'')','DFP_IDX_PAD_HIST','H',1,sysdate-1,sysdate-1,null);

	Insert into PG_PURGER_CONFIG (CF_TABLE_GROUP,CF_TABLE_ID,CF_TABLE_NAME,CF_PRG_CLAUSE,CF_PRG_BKP_TABLE,CF_PRG_FREQ,CF_PRG_INTVL,CF_PRG_LAST_RUN,CF_PRG_NEXT_RUN,CF_PRG_BKP_FILE)
	values (1,3,'DFP_IDX_REQ_T1','trunc(rec_dt) < add_months(trunc(sysdate),-12)',null,'D',1,sysdate-1,sysdate-1,null);

	Insert into PG_PURGER_CONFIG (CF_TABLE_GROUP,CF_TABLE_ID,CF_TABLE_NAME,CF_PRG_CLAUSE,CF_PRG_BKP_TABLE,CF_PRG_FREQ,CF_PRG_INTVL,CF_PRG_LAST_RUN,CF_PRG_NEXT_RUN,CF_PRG_BKP_FILE)
	values (1,4,'STG_DFP_API','trunc(session_ts) <= sysdate-7',null,'D',1,sysdate-1,sysdate-1,null);

	commit;
end;
/


prompt Done.
