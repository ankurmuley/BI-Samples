--Drop View TEST_AgentCommission_MH;
CREATE VIEW TEST_AgentCommission_MH AS  

WITH Policy AS (  
    SELECT   DISTINCT
        PV.PolicyNumber,  
        PT.PayPlan,
        AV.State   
    FROM   
        [TEST_DIEP2_EMBARK_MH].[dbo].[Policy_versions] PV  
    JOIN   
        [TEST_DIEP2_EMBARK_MH].[dbo].[PaymentTerms_versions] PT   
        ON PV.Policy_ref = PT.Policy_ref
    JOIN  [TEST_DIEP2_EMBARK_MH].[dbo].[Attributes_versions] AV
        ON PV.Policy_ref = AV.Policy_ref   
	)  
SELECT 
    'KGEMMHCA' as Product,
    Policy.State as State,
    PD.policy_number as [Policy Number],
    PD.policy_insured_fullname as [Insured Name],
    PD.policy_effective_date as [Eff Date],
    AD.agency_name as Agency,
--    AD.customer_name as Customer,
    CASE
        WHEN PD.policy_number like '%-02' THEN 'Renewals'
        ELSE 'New'
    END as [New/Renewals],
    Policy.PayPlan as PayPlan,
    C.created_on as [Transaction Date],
    CASE 
        WHEN C.policy_transaction_type= 1 THEN 'New Business'
        WHEN C.policy_transaction_type= 2 THEN 'Endorsement'
        WHEN C.policy_transaction_type= 3 THEN 'Cancellation'
        WHEN C.policy_transaction_type= 4 THEN 'Reinstatement'
        WHEN C.policy_transaction_type= 5 THEN 'Renewals'
        ELSE ''
    END as [Transaction Type],
    PD.policy_premium as Premium,
    PD.policy_agency_commission_nb as [Commission %],
    C.commission_amount as [Commission Amount]
FROM 
    Policy_Details PD 
LEFT JOIN 
    Commissions C on C.policy_number=PD.policy_number 
    AND C.paid_premium=PD.policy_premium
INNER JOIN 
    Policy on Policy.PolicyNumber=PD.policy_number
LEFT JOIN 
    Agency_Master AD ON AD.agency_broker_code=PD.policy_agency_brokercode 
where AD.customer_name = 'EMBARKMH' 
GROUP BY     
    Policy.State,
    PD.policy_number,
    PD.policy_insured_fullname,
    PD.policy_effective_date ,
    AD.agency_name ,
--    AD.customer_name,
    CASE  
        WHEN PD.policy_number like '%-02' THEN 'Renewals'  
        ELSE 'New'  
    END,
    Policy.PayPlan ,
    C.created_on ,
    CASE  
        WHEN C.policy_transaction_type = 1 THEN 'New Business'  
        WHEN C.policy_transaction_type = 2 THEN 'Endorsement'  
        WHEN C.policy_transaction_type = 3 THEN 'Cancellation'  
        WHEN C.policy_transaction_type = 4 THEN 'Reinstatement'  
        WHEN C.policy_transaction_type = 5 THEN 'Renewals'  
        ELSE ''  
    END,
    PD.policy_premium ,
    PD.policy_agency_commission_nb ,
    C.commission_amount 
    Having  
    PD.policy_premium !=0 and 
    C.created_on  <=  GETDATE()

--WHERE PD.policy_number='FLB00000504-01'    