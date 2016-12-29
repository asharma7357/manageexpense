prompt
prompt Create View DFP_PASSES_VW
prompt =========================
prompt

create or replace view dfp_passes_vw as
with dfp_pass_attribs as (select * from dfp_attrib_map where pass_app_flag = 1)
select	dpc.cf_pass_number,
		dpc.cf_sub_pass_number,
		dpc.cf_attrib_id,
		dpa.column_id,
		dpa.attrib_name,
		dpa.attrib_disp_name,
		dpa.attrib_desc,
		dpc.cf_match_degree,
		de.pre_computed_entropy
from	dfp_pq_config dpc
		join dfp_pass_attribs dpa on (dpc.cf_attrib_id = dpa.attrib_id)
		join dfp_entropy de on (de.column_name = dpa.column_name)
order by dpc.cf_pass_number,dpc.cf_sub_pass_number,dpa.column_id;

prompt Done.
