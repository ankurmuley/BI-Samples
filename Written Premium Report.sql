CREATE OR ALTER PROC [dbo].[sp_written_premium]

@FromDate DATE ,
@ToDate DATE,
@State NVARCHAR(MAX)

AS
BEGIN
    SET NOCOUNT ON;

DECLARE @ARU_CommissionRate DECIMAL(5,2) = 0.27;

WITH 
FT_Pivot as ( SELECT 
    Policy_ref,
    [Surplus Lines Tax],
  [Stamping Fee],
  [Florida Tax],
  [FSLSO Fee],
  [EMPA Tax],
  [Fire Marshal Tax],
  [Inspection Fee],
  [Admin Fee],
  [State Tax],
  [Premium Tax],
  [Surcharge],
  [Regulatory Fee],
  [NIMA Clearinghouse Fee],
  [Maintenance Assessment Fee],
  [Clearinghouse Fee],
  [Assessment],
  [MWUA Fee],
  [Surplus Lines Service Charge],
  [Citizens EA],
  [Wet Marine and Transportation Insurance],
  [WM&T Tax Due/Fire Marshal Tax],
  [SCMMA Assessment],
  [Fire Premium Tax],
  [WM&T Service Charge Due],
  [CT Healthy Home Assessment],
  [Municipal Tax],
  [County Fee],
  [Reinstatement Fee]
FROM (
    SELECT
        fv.Policy_ref,
        fv.Description,
        fv.Amount
    FROM
        dbo.FeesAndTaxes_versions fv
) AS SourceTable
PIVOT (
    Max(Amount)
    FOR Description IN (
        [Surplus Lines Tax],
        [Stamping Fee],
        [Florida Tax],
        [FSLSO Fee],
        [EMPA Tax],
        [Fire Marshal Tax],
        [Inspection Fee],
        [Admin Fee],
        [State Tax],
        [Premium Tax],
        [Surcharge],
        [Regulatory Fee],
        [NIMA Clearinghouse Fee],
        [Maintenance Assessment Fee],
        [Clearinghouse Fee],
        [Assessment],
        [MWUA Fee],
        [Surplus Lines Service Charge],
        [Citizens EA],
        [Wet Marine and Transportation Insurance],
        [WM&T Tax Due/Fire Marshal Tax],
        [SCMMA Assessment],
        [Fire Premium Tax],
        [WM&T Service Charge Due],
        [CT Healthy Home Assessment],
        [Municipal Tax],
        [County Fee],
        [Reinstatement Fee]
    )
) AS PivotTable)

SELECT 
    p.PolicyNumber AS [Policy Number],
    p.EffectiveDate AS [Policy Effective Date],
    CASE WHEN tr.Type = 'Policy' THEN 'New Business' ELSE tr.Type END as [Transaction Type],
    tr.EffectiveDate as [Transaction Date],
    'Sierra Specialty Insurance Company ' as [Company],
    att.State as [State Code],
    COALESCE(liabpf.EffectivePremium * ovrfact.Rate, 0) AS [Premium payable - Liability],
    COALESCE((prem.EffectivePremium  - (liabpf.EffectivePremium * ovrfact.Rate)), 0) AS [Premium payable - Property],
    COALESCE(agc.Value * liabpf.EffectivePremium * ovrfact.Rate, 0) as [Broker Commission Payable - Liability],
    COALESCE(agc.Value * (prem.EffectivePremium  - (liabpf.EffectivePremium * ovrfact.Rate)), 0) as [Broker Commission Payable - Property],
    COALESCE(@ARU_CommissionRate * liabpf.EffectivePremium * ovrfact.Rate, 0) as [Commission Income- Liability],
    COALESCE(@ARU_CommissionRate * (prem.EffectivePremium  - (liabpf.EffectivePremium * ovrfact.Rate)), 0) as [Commission Income- Property],
    
    ISNULL(ft.[Surplus Lines Tax],'') +  ISNULL(ft.[State Tax],'') + ISNULL(ft.[Florida Tax], '')+ ISNULL(ft.[Premium Tax],'')  as [State Surplus taxes payable],
    ISNULL(ft.[Stamping Fee], '') + ISNULL(ft.[NIMA Clearinghouse Fee],'') + ISNULL(ft.[Clearinghouse Fee],'') + ISNULL(ft.[Surcharge],'') + ISNULL(ft.[FSLSO Fee],'') as [Stamp fee Payable],
    ISNULL(ft.[Admin Fee],'')  as [Policy fees Payable],
    ISNULL(ft.[Inspection Fee],'') as [Inspection fees Payable],
    ISNULL(ft.[MWUA Fee],'') as [WindPool Fee Payable] ,
    ISNULL(0,'') as [Clearinghouse fee payable],
    ISNULL(0,'') as [FSLSO Fee Payable],
    ISNULL(ft.[EMPA Tax],'') as [EMPA Tax Payable],
    ISNULL(0, '') as [Florida Tax Payable],
    ISNULL(0,'') as [Premium Tax Payable],
    ISNULL(ft.[Municipal Tax],'') as [Municipal Tax Payable],
    ISNULL(ft.[Fire Marshal Tax],'') as [Fire Marshal Tax Payable],
    ISNULL(ft.[Fire Premium Tax],'') as [Fire Premium Tax],
    ISNULL(ft.[Surplus Lines Service Charge],'') as [Surplus Lines Service Charge]

FROM [dbo].[Policy_versions] p
INNER JOIN [dbo].[PremiumFactors_versions] proppf ON p.Policy_ref = proppf.Policy_ref AND proppf.Name = 'PropertyPremium'
INNER JOIN [dbo].[PremiumFactors_versions] liabpf ON p.Policy_ref = liabpf.Policy_ref AND liabpf.Name = 'LiabTotalPremium'
INNER JOIN [dbo].[PremiumFactors_versions] selfac ON p.Policy_ref = selfac.Policy_ref AND selfac.Name = 'SelectedPackage'
INNER JOIN [dbo].[PremiumFactors_versions] ovrfact ON p.Policy_ref = ovrfact.Policy_ref AND ovrfact.Name = 'PolicySubPremium'
INNER JOIN [dbo].[PremiumFactors_versions] minpre ON p.Policy_ref = minpre.Policy_ref AND minpre.Name = 'MinPre'
INNER JOIN [dbo].[TotalPremium_versions] prem ON p.Policy_ref = prem.Policy_ref
INNER JOIN [dbo].[Transaction_versions] tr ON p.Policy_ref = tr.Policy_ref
INNER JOIN [dbo].[Attributes_versions] att ON p.Policy_ref = att.Policy_ref
INNER JOIN [dbo].[Agency_Commissions_versions] agc ON p.Policy_ref = agc.Policy_ref
INNER join FT_Pivot as ft ON p.Policy_ref = ft.Policy_ref
WHERE 
    NULLIF(tr.Date, '') IS NOT NULL
    AND TRY_CAST(tr.Date AS DATE) BETWEEN @FromDate AND @ToDate
    AND prem.EffectivePremium != 0
    AND att.State in (SELECT TRIM(value) FROM STRING_SPLIT(@State, ','))
    ORDER BY p.PolicyNumber, tr.Number;
 
END