--RecordLocations
Select SUM(Record_Count_Location) as Record_Count_location
FROM(
SELECT
        Record_Count_Location 
                =  Count(Distinct loc.UnitNumber), p.PolicyNumber
FROM [dbo].[Policy_versions] p
INNER JOIN [dbo].[Risks_FarmLocation_versions] loc on p.Policy_ref = loc.Policy_ref
INNER JOIN [dbo].[Attributes_versions] att ON p.Policy_ref = att.Policy_ref
INNER JOIN [dbo].[PolicyStatusHistory_versions] ps ON p.Policy_ref = ps.Policy_ref
WHERE att.Client = 'ARU'
    AND TRY_CAST(ps.ChangedDate AS DATE) BETWEEN  TRY_CAST('08/01/2025' AS DATE)  AND TRY_CAST('08/31/2025' AS DATE)
GROUP BY p.PolicyNumber
) S;

--RecordUnits
Select SUM(Record_Count_Unit) as Record_count_Units
FROM(
SELECT
        Record_Count_Unit 
                =  COUNT(Distinct dw.UnitNumber), p.PolicyNumber
FROM [dbo].[Policy_versions] p
INNER JOIN [dbo].[Risks_Dwelling_versions] dw on p.Policy_ref = dw.Policy_ref 
INNER JOIN [dbo].[Risks_FarmLocation_versions] loc on p.Policy_ref = loc.Policy_ref and loc.UnitNumber = dw.[RiskAttributes.LocationNumber]
INNER JOIN [dbo].[Attributes_versions] att ON p.Policy_ref = att.Policy_ref
INNER JOIN [dbo].[PolicyStatusHistory_versions] ps ON p.Policy_ref = ps.Policy_ref
WHERE att.Client = 'ARU'
    AND TRY_CAST(ps.ChangedDate AS DATE) BETWEEN  TRY_CAST('08/01/2025' AS DATE)  AND TRY_CAST('08/31/2025' AS DATE)
GROUP BY p.PolicyNumber

UNION

SELECT
        Record_Count_Unit 
                =  COUNT(Distinct hh.UnitNumber), p.PolicyNumber
FROM [dbo].[Policy_versions] p
INNER JOIN [dbo].[Risks_HogHouse_versions] hh on p.Policy_ref = hh.Policy_ref 
INNER JOIN [dbo].[Risks_FarmLocation_versions] loc on p.Policy_ref = loc.Policy_ref and loc.UnitNumber = hh.[RiskAttributes.LocationNumber]
INNER JOIN [dbo].[Attributes_versions] att ON p.Policy_ref = att.Policy_ref
INNER JOIN [dbo].[PolicyStatusHistory_versions] ps ON p.Policy_ref = ps.Policy_ref
WHERE att.Client = 'ARU'
    AND TRY_CAST(ps.ChangedDate AS DATE) BETWEEN  TRY_CAST('08/01/2025' AS DATE)  AND TRY_CAST('08/31/2025' AS DATE)
GROUP BY p.PolicyNumber

UNION

SELECT
        Record_Count_Unit 
                =  COUNT(Distinct me.UnitNumber), p.PolicyNumber
FROM [dbo].[Policy_versions] p
INNER JOIN [dbo].[Risks_MobileEquipment_versions] me on p.Policy_ref = me.Policy_ref 
INNER JOIN [dbo].[Risks_FarmLocation_versions] loc on p.Policy_ref = loc.Policy_ref and loc.UnitNumber = me.[MobileEquipmentRiskAttributes.LocationNumber]
INNER JOIN [dbo].[Attributes_versions] att ON p.Policy_ref = att.Policy_ref
INNER JOIN [dbo].[PolicyStatusHistory_versions] ps ON p.Policy_ref = ps.Policy_ref
WHERE att.Client = 'ARU'
    AND TRY_CAST(ps.ChangedDate AS DATE) BETWEEN  TRY_CAST('08/01/2025' AS DATE)  AND TRY_CAST('08/31/2025' AS DATE)
GROUP BY p.PolicyNumber

UNION

SELECT
        Record_Count_Unit 
                =  COUNT(Distinct os.UnitNumber), p.PolicyNumber
FROM [dbo].[Policy_versions] p
INNER JOIN [dbo].[Risks_OtherStructure_versions] os on p.Policy_ref = os.Policy_ref 
INNER JOIN [dbo].[Risks_FarmLocation_versions] loc on p.Policy_ref = loc.Policy_ref and loc.UnitNumber = os.[RiskAttributes.LocationNumber]
INNER JOIN [dbo].[Attributes_versions] att ON p.Policy_ref = att.Policy_ref
INNER JOIN [dbo].[PolicyStatusHistory_versions] ps ON p.Policy_ref = ps.Policy_ref
WHERE att.Client = 'ARU'
    AND TRY_CAST(ps.ChangedDate AS DATE) BETWEEN  TRY_CAST('08/01/2025' AS DATE)  AND TRY_CAST('08/31/2025' AS DATE)
GROUP BY p.PolicyNumber

UNION

SELECT
        Record_Count_Unit 
                =  COUNT(Distinct ph.UnitNumber), p.PolicyNumber
FROM [dbo].[Policy_versions] p
INNER JOIN [dbo].[Risks_PoultryHouse_versions] ph on p.Policy_ref = ph.Policy_ref 
INNER JOIN [dbo].[Risks_FarmLocation_versions] loc on p.Policy_ref = loc.Policy_ref and loc.UnitNumber = ph.[RiskAttributes.LocationNumber]
INNER JOIN [dbo].[Attributes_versions] att ON p.Policy_ref = att.Policy_ref
INNER JOIN [dbo].[PolicyStatusHistory_versions] ps ON p.Policy_ref = ps.Policy_ref
WHERE att.Client = 'ARU'
    AND TRY_CAST(ps.ChangedDate AS DATE) BETWEEN  TRY_CAST('08/01/2025' AS DATE)  AND TRY_CAST('08/31/2025' AS DATE)
GROUP BY p.PolicyNumber
) J;

