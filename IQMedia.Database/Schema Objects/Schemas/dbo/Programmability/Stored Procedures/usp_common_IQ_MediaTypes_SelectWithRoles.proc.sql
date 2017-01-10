CREATE PROCEDURE [dbo].[usp_common_IQ_MediaTypes_SelectWithRoles]
	@CustomerGuid UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ClientID BIGINT,
			@CustomerID BIGINT

	SELECT	@CustomerID = CustomerKey,
			@ClientID = ClientID
	FROM	IQMediaGroup.dbo.Customer 
	WHERE	CustomerGUID = @CustomerGuid

	SELECT MediaType,
		   SubMediaType,
		   IQ_MediaTypes.DisplayName,
		   TypeLevel,
		   HasSubMediaTypes,
		   DataModelType,
		   AnalyticsDataType,
		   DiscChartSearchMethod,
		   DiscResultsSearchMethod,
		   DiscRptGenSearchMethod,
		   DiscExportSearchMethod,
		   FeedsResultView,
		   FeedsChildResultView,
		   DiscoveryResultView,
		   MediaIconPath,
		   EmailMediaIconPath,
		   UseAudience,
		   UseMediaValue,		   
		   SortOrder,
		   IsActiveDiscovery,
		   CASE 
			WHEN ClientRole.ClientRoleKey IS NOT NULL 
					AND CustomerRole.CustomerRoleKey IS NOT NULL 
					AND pClientRole.ClientRoleKey IS NOT NULL 
					AND pCustomerRole.CustomerRoleKey IS NOT NULL 
				THEN 1	
				ELSE 0
		   END AS HasAccess,
		   RequireNielsenAccess,
		   RequireCompeteAccess,		  
		   DashboardData,
		   UseHighlightingText,
		   AgentNodeName,
		   SourceTypes,
		   AgentType,
		   SolrMediaType,
		   IsArchiveOnly,
		   ExternalPlayerUrlSvc
	FROM IQMediaGroup.dbo.IQ_MediaTypes
	-- Check if the user has access to the submediatype
	LEFT JOIN IQMediaGroup.dbo.Role 
		ON Role.RoleKey = IQ_MediaTypes._RoleKey
		AND Role.IsActive = 1
	LEFT JOIN IQMediaGroup.dbo.ClientRole
		ON ClientRole.RoleID = Role.RoleKey
		AND ClientRole.ClientID = @ClientID
		AND ClientRole.IsAccess = 1
	LEFT JOIN IQMediaGroup.dbo.CustomerRole
		ON CustomerRole.RoleID = Role.RoleKey
		AND CustomerRole.CustomerID = @CustomerID
		AND CustomerRole.IsAccess = 1	
	-- Check if the user has access to the mediatype
	LEFT JOIN IQMediaGroup.dbo.Role pRole 
		ON pRole.RoleKey = IQ_MediaTypes._ParentRoleKey
		AND pRole.IsActive = 1
	LEFT JOIN IQMediaGroup.dbo.ClientRole pClientRole
		ON pClientRole.RoleID = pRole.RoleKey
		AND pClientRole.ClientID = @ClientID
		AND pClientRole.IsAccess = 1
	LEFT JOIN IQMediaGroup.dbo.CustomerRole pCustomerRole
		ON pCustomerRole.RoleID = pRole.RoleKey
		AND pCustomerRole.CustomerID = @CustomerID
		AND pCustomerRole.IsAccess = 1
	WHERE IQ_MediaTypes.IsActive = 1
    
END
