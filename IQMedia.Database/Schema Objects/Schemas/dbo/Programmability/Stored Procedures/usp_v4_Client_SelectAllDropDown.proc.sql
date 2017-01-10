
CREATE PROCEDURE [dbo].[usp_v4_Client_SelectAllDropDown]
AS
BEGIN
	 SELECT
		Distinct MasterClient
	FROM
		Client
	WHERE
		IsActive = 1
		
		And MasterClient <> ''

	SELECT
		[State].StateKey,
		[State].StateName
	FROM
		[State]
	WHERE
		[State].IsActive = 1
	ORDER BY StateName

	SELECT
		Industry.IndustryKey,
		Industry.IndustryCode
	FROM
		Industry
	WHERE
		Industry.IsActive = 1
	ORDER BY IndustryCode

	SELECT
		BillType.BillTypeKey,
		BillType.Bill_Type
	FROM
		BillType
	WHERE
		BillType.IsActive = 1
	ORDER BY BillType.Bill_Type

	SELECT
		BillFrequency.BillFrequencyKey,
		BillFrequency.Bill_Frequency
	FROM
		BillFrequency
	WHERE
		BillFrequency.IsActive = 1
	ORDER BY BillFrequency.Bill_Frequency

	SELECT
		PricingCode.PricingCodeKey,
		PricingCode.Pricing_Code
	FROM
		PricingCode
	WHERE
		PricingCode.IsActive = 1
	ORDER BY PricingCode.Pricing_Code

	SELECT
		RoleKey,
		RoleName,
		UIName,
		Description,
		IsEnabledInSetup,
		GroupName,
		EnabledCustomerIDs,
		HasDefaultAccess
	FROM
		[Role]
	WHERE
		[Role].IsActive = 1
		AND [Role].RoleKey != 3
	ORDER BY RoleName

	SELECT
		Client.ClientKey,
		Client.ClientName
	FROM
		[Client]
	WHERE
		[Client].IsActive=1 and Client.MCID = Client.ClientKey
	ORDER BY Client.ClientName

	SELECT	
		ID,
		Name
	FROM
		IQ_ReportType
	WHERE
		IsActive = 1 and MasterReportType = 'MCMediaTemplate'
	ORDER BY IsDefault DESC, Name

	SELECT	
		ID,
		Name
	FROM
		IQ_ReportType
	WHERE
		IsActive = 1 and MasterReportType = 'EmailTemplate'
	ORDER BY IsDefault DESC, Name	

    SELECT DISTINCT 
	ID AS 'ID', 
	Industry AS 'Name'
	FROM 
	[IQMediaGroup].[dbo].[IQ_LR_Industry]
	WHERE 
	IsActive = 1
	ORDER BY 
	Industry	
	
END