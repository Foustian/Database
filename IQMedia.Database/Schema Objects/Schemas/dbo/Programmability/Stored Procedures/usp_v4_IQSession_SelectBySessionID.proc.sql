CREATE PROCEDURE [dbo].[usp_v4_IQSession_SelectBySessionID]
(
	@SessionID	VARCHAR(255)
)
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS (SELECT SessionID FROM IQSession WHERE SessionID = @SessionID AND SYSDATETIME() > SessionTimeOut)
	BEGIN
		SELECT
			CustomerKey,		
			ClientID,
			ClientName,
			FirstName,
			LastName,
			Email,
			Customer.LoginID,
			Customer.MultiLogin,
			Customer.CustomerGUID,
			Client.MCID,
			Customer.MasterCustomerID,
			Client.ClientGUID,
			Client.PlayerLogo,
			Client.IsActivePlayerLogo,
			DefaultPage,
			Client.AuthorizedVersion,
			Client.TimeZone,
			ISNULL(Client.dst,0) AS dst,
			ISNULL(Client.gmt,0) AS gmt,
			SessionID,
			SessionTimeOut,
			LastAccessTime,
			[IQSession].[Server]
	FROM
			IQSession
				INNER JOIN Customer
					ON IQSession.LoginID = Customer.LoginID
				INNER JOIN Client
					ON Customer.ClientID = Client.ClientKey
	WHERE
			SessionID = @SessionID
		AND	Customer.IsActive = 1
		AND	Client.IsActive = 1

		SELECT
			[Role].RoleName,
			[Role].RoleKey,
			Customer.CustomerKey
	
	FROM 
			IQSession
				INNER JOIN	Customer	
					ON IQSession.LoginID = Customer.LoginID
				INNER JOIN CustomerRole
					ON	CustomerRole.CustomerID = Customer.CustomerKey
				INNER JOIN [Role]
					ON	[Role].RoleKey = CustomerRole.RoleID	
				INNER JOIN ClientRole
					ON	Customer.ClientID = ClientRole.ClientID
					AND	ClientRole.RoleID = CustomerRole.RoleID
    
    WHERE	
			SessionID = @SessionID
		AND Customer.IsActive = 1	
		AND	CustomerRole.IsAccess=1
		AND	ClientRole.IsAccess=1
		AND	[Role].IsActive = 1
		AND	[Role].RoleName IN ('v4Feeds','v4Discovery','v4Library','v4Timeshift','v4Dashboard',
								'v4Radio','v4Setup','v5LR','GlobalAdminAccess','v4UGC','v4IQAgentSetup',
								'v4TV','v4SM','v4NM','v4TW','v4TM','UGCAutoClip','UGCDownload',
								'UGCUploadEdit','v4Group','v4CustomImage','CompeteData','NielsenData',
								'v4BLPM','NewsRight','v4CustomSettings','v4DiscoveryLite','fliQAdmin','v4PQ',
								'MediaRoomContributor','MediaRoomEditor','v4Google','v4LibraryDashboard','TimeshiftFacet',
								'ShareTV','v4TAds', 'v5Analytics','v5Ads','ThirdPartyData','ClientSpecificData','SMOther',
								'BL','FO','IG','LN','PR','FB','ConnectAccess','ExternalRuleEditor')
	END
END
