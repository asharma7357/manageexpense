create or replace PROCEDURE PRC_CALC_ENTROPY
as
	lv_sql			varchar2(4000);
	lv_col_name		varchar2(100);
	lv_col_count	number;
	lv_tot_cnt		number;
	lv_p			number;
	lv_col_ent		number;
	lv_tot_ent		number;
	--
	cursor c_attr_name is 
	select column_name 	from DFP_ATTRIB_MAP
	where active_flag = 1;
	--
begin
	FOR cv_attr_name IN c_attr_name 
	LOOP
		LV_SQL :=	'select distinct col_name,round(TOTAL_ENTROPY,4) from (SELECT '''||cv_attr_name.column_name||
					''' col_name ,IP_CNT col_count,TOT_CNT TOTAL_RECORDS,P PROBABILITY, P*LOG(2,P) col_ENTROPY,round(SUM(P*LOG(2,P))OVER(),4)  TOTAL_ENTROPY FROM ( SELECT '|| cv_attr_name.column_name||
					',COUNT(1) OVER (PARTITION BY '||cv_attr_name.column_name ||') IP_CNT , COUNT(1) OVER() TOT_CNT,ROW_NUMBER() OVER(PARTITION BY '||cv_attr_name.column_name||
					' ORDER BY '||cv_attr_name.column_name||') RNO, COUNT(1) OVER (PARTITION BY '||cv_attr_name.column_name||')/COUNT(1) OVER() P '||
					' FROM dfp_idx_pad_t1)     WHERE RNO = 1 )';

		/*LV_SQL := 'select distinct col_name, '||
		'round(TOTAL_ENTROPY,4) '|| 
		'from (SELECT '''||cv_attr_name.column_name||''''||
		' col_name , '||
		'round(SUM(Prob*LOG(2,Prob))OVER(),4)  TOTAL_ENTROPY '||
		'FROM ( SELECT  ROW_NUMBER() OVER(PARTITION BY :1 ORDER BY :2) RNO,  '||
		'COUNT(distinct :3) OVER ()/COUNT(1) OVER() Prob '||
		' FROM dfp_idx_pad_t1)     '|| 
		' WHERE RNO = 1 )';
		*/
		
		execute immediate lv_sql into lv_col_name,lv_tot_ent 
		/*using cv_attr_name.column_name,
		cv_attr_name.column_name,
		--cv_attr_name.column_name,
		cv_attr_name.column_name
		*/;

		--DBMS_OUTPUT.PUT_LINE(lv_sql);
		--DBMS_OUTPUT.PUT_LINE(lv_col_name||'--'||lv_tot_ent);
		--
		merge into dfp_entropy den
		using	(	select	lv_col_name 
							lv_col_name,-1*lv_tot_ent lv_tot_ent
					from	dual
				) src
		on	(den.column_name = src.lv_col_name)
		when matched then
			update set den.calculated_entropy = src.lv_tot_ent,den.update_dt = sysdate
		when not matched then 
			insert (den.column_name ,den.pre_computed_entropy,den.calculated_entropy,den.insert_dt,den.update_dt)
			values (src.LV_COL_NAME,null,src.lv_tot_ent,sysdate,sysdate);
		--

		end loop;
	commit;
exception
	when others then
	DBMS_OUTPUT.PUT_LINE('Error Encountered:'||substr(sqlerrm,1,200));
end prc_calc_entropy;

