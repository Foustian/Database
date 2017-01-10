-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Client_SelectAlClientWithRoleByClientID_old] 
	-- Add the parameters for the stored procedure here
	(
		@ClientID bigint
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;

 --   -- Insert statements for procedure here
 --   SELECT
	--	ClientKey,
	--	ClientName,
	--	IsActive
	--FROM
	--	Client
	--WHERE
	--	ClientKey !=0 and
	--	(@IsActive is null or Client.IsActive=@IsActive)
	
	--ORDER BY ClientName
	
	SELECT	
		[ClientKey],
		[ClientName],
		isnull([IQBasic],0)as 'IQBasic',
		isnull([AdvancedSearchAccess],0)as 'AdvancedSearchAccess',
		isnull([GlobalAdminAccess],0)as 'GlobalAdminAccess',
		isnull([IQAgentUser],0)as 'IQAgentUser',
		isnull([IQAgentAdminAccess],0)as 'IQAgentAdminAccess',
		isnull([myIQAccess],0)as 'myIQAccess',
		isnull([IQAgentWebsiteAccess],0)as 'IQAgentWebsiteAccess',
		isnull([DownloadClips],0)as 'DownloadClips',
		isnull([IQCustomAccess],0)as 'IQCustomAccess',
		isnull([UGCDownload],0)as 'UGCDownload',
		isnull([IframeMicrosite],0)as 'IframeMicrosite',
		isnull([UGCUploadEdit],0)as 'UGCUploadEdit',
		[IsActive],
		Address1,
		Address2,
		Attention,
		City,
		MasterClient,
		NoOfUser,
		Phone,
		Zip,
		BillFrequencyID,
		BillTypeID,
		IndustryID,
		PricingCodeID,
		StateID,
		CreatedDate
		
FROM
(
	SELECT     
		dbo.Client.ClientName, 
		dbo.Client.ClientKey, 
		--dbo.ClientRole.RoleID, 
		dbo.Role.RoleName,
		Client.IsActive,
		Client.Address1,
		Client.Address2,
		Client.Attention,
		Client.City,
		Client.MasterClient,
		Client.NoOfUser,
		Client.Phone,
		Client.Zip,
		Client.BillFrequencyID,
		Client.BillTypeID,
		Client.IndustryID,
		Client.PricingCodeID,
		Client.StateID,
		Client.CreatedDate,
		CAST(ClientRole.IsAccess AS INT) AS 'IsAccess'
	FROM         
		dbo.Role INNER JOIN
        dbo.ClientRole ON dbo.Role.RoleKey = dbo.ClientRole.RoleID RIGHT OUTER JOIN
		dbo.Client ON dbo.ClientRole.ClientID = dbo.Client.ClientKey
		--BillFrequency on dbo.Client.BillFrequencyID = BillFrequency.BillFrequencyKey inner join
		--BillType on dbo.Client.BillTypeID = BillType.BillTypeKey inner join  
		--Industry on dbo.Client.IndustryID = Industry.IndustryKey inner join 
		--PricingCode on dbo.Client.PricingCodeID = PricingCode.PricingCodeKey inner join
		--[State] on dbo.Client.StateID = [State].StateKey
		
	WHERE
		ClientKey !=0 and
		--(@IsActive is null or Client.IsActive=@IsActive) and
		--Client.IsActive = 1	
		ClientKey = @ClientID
		----ClientRole.IsActive = 1 and
) as a
pivot
(
max([IsAccess])
FOR [RoleName] IN 
	(
	 [IQBasic],
	 [AdvancedSearchAccess],
	 [GlobalAdminAccess],
	 [IQAgentUser],
	 [IQAgentAdminAccess],
	 [myIQAccess],
	 [IQAgentWebsiteAccess],
	 [DownloadClips],
	 [IQCustomAccess],
	 [UGCDownload],
	 [IframeMicrosite],
	 [UGCUploadEdit]
    )
)AS B
	
END

