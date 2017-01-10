-- =============================================
-- Author:		<Author,,Name>
-- Create date: 11 July 2013
-- Description:	Gets Role information for Customer
-- =============================================

CREATE PROCEDURE [dbo].[usp_v4_Role_SelectRoleByCustomerGUID]
	@CustomerGuid	UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
			[Role].RoleName,
			[Role].RoleKey,
			Customer.CustomerKey
	
	FROM Customer
	
	INNER JOIN CustomerRole
	ON	CustomerRole.CustomerID = Customer.CustomerKey
	AND	Customer.CustomerGUID =@CustomerGuid
	
	INNER JOIN [Role]
	ON	[Role].RoleKey = CustomerRole.RoleID
	
	INNER JOIN ClientRole
	ON	Customer.ClientID = ClientRole.ClientID
	AND	ClientRole.RoleID = CustomerRole.RoleID
    
    WHERE	Customer.CustomerGUID =@CustomerGuid
    AND		CustomerRole.IsAccess=1
    AND		ClientRole.IsAccess=1
    AND		[Role].IsActive = 1
    AND		[Role].RoleName IN ('v4Feeds','v4Discovery','v4Library','v4Timeshift','v4Dashboard',
								'v4Radio','v4Setup','v5LR','GlobalAdminAccess','v4UGC','v4IQAgentSetup',
								'v4TV','v4SM','v4NM','v4TW','v4TM','UGCAutoClip','UGCDownload',
								'UGCUploadEdit','v4Group','v4CustomImage','CompeteData','NielsenData',
								'v4BLPM','NewsRight','v4CustomSettings','v4DiscoveryLite','fliQAdmin','v4PQ',
								'MediaRoomContributor','MediaRoomEditor','v4Google','v4LibraryDashboard','TimeshiftFacet',
								'ShareTV','v4TAds', 'v5Analytics','v5Ads','ThirdPartyData','ClientSpecificData','SMOther',
								'BL','FO','IG','LN','PR','FB','ConnectAccess','ExternalRuleEditor')
    
END
