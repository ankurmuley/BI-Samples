-- Get Claim with Adjuster Details
SELECT
    c.clm_ser_nbr, 
    c.clm_policy,
    c.clm_ins_name1 + ' ' + c.clm_ins_name2 as clm_insured_name,
    c.clm_loss_date, 
    c.clm_state,
    c.clm_adj_name,
    ta.tmad_name AS AdjusterName, 
    ta.tmad_adj_phone,
    ta.tmad_email, 
    t.team_desc as clm_status
FROM claim c
LEFT JOIN teams_adjusters ta ON c.clm_adj_name = ta.tmad_id --clm_adj_name = tmad_name
LEFT JOIN teams t ON ta.tmad_team_code = t.team_code --tmad_team_code = team_code
Where c.clm_ser_nbr = 1 -- 1 to 12

-- Get Claim Financial Summary
