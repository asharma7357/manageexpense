prompt
prompt Create View DFP_ATTRIB_VW
prompt =========================
prompt

create or replace view dfp_attrib_vw as
select	dam.column_id,
		dam.attrib_id,
		dam.column_name,
		dam.attrib_name,
		dam.attrib_disp_name,
		dam.attrib_desc,
		dam.browser_supp,
		de.pre_computed_entropy,
		dam.pass_app_flag,
		dam.active_flag
from	dfp_attrib_map dam
		join dfp_entropy de on (de.column_name = dam.column_name)
order by dam.column_id;
/

prompt
prompt Done.
