prompt
prompt Create Trigger TRG_ON_UPD_DFP_ENTROPY
prompt ======================================
prompt

create or replace trigger trg_on_upd_dfp_entropy AFTER UPDATE OR DELETE ON dfp_entropy
for each row
BEGIN
	insert into dfp_entropy_hist(
		column_name,
		pre_computed_entropy,
		calculated_entropy,
		insert_dt,
		update_dt,
		hist_insert_dt)
	values (
		:old.column_name,
		:old.pre_computed_entropy,
		:old.calculated_entropy,
		:old.insert_dt,
		:old.update_dt,
		sysdate);
end;
/


