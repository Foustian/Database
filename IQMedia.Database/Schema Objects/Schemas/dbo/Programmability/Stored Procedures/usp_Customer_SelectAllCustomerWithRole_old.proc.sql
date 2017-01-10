-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Customer_SelectAllCustomerWithRole_old] 
	-- Add the parameters for the stored procedure here
	
	(
		@ClientName varchar(100)
	)
AS
BEGIN

	
	SELECT	
		[CustomerKey],
		FirstName,
		LastName,
		Email,
		ContactNo,
		CustomerPassword,
		CustomerComment,
		ClientID,
		cast(isnull([IQBasic],0) as bit)as 'IQBasic',
		cast(isnull([AdvancedSearchAccess],0) as bit)as 'AdvancedSearchAccess',
		cast(isnull([GlobalAdminAccess],0) as bit) as 'GlobalAdminAccess',
		cast(isnull([IQAgentUser],0) as bit) as 'IQAgentUser',
		cast(isnull([IQAgentAdminAccess],0) as bit) as 'IQAgentAdminAccess',
		cast(isnull([myIQAccess],0) as bit) as 'myIQAccess',
		cast(isnull([IQAgentWebsiteAccess],0) as bit) as 'IQAgentWebsiteAccess',
		cast(isnull([DownloadClips],0) as bit) as 'DownloadClips',
		cast(isnull([IQCustomAccess],0) as bit) as 'IQCustomAccess',
		cast(isnull([UGCDownload],0) as bit) as 'UGCDownload',
		cast(isnull([UGCUploadEdit],0) as bit) as 'UGCUploadEdit',
		[IsActive],
		cast(isnull(MultiLogin,'False') as bit) as 'MultiLogin'
		
FROM
(
	SELECT     
		 dbo.Customer.CustomerKey,
		 FirstName,
		 LastName,
		 Email,
		 ContactNo,
		 CustomerPassword,
		 CustomerComment,
		 ClientID,
		dbo.Role.RoleName,
		Customer.IsActive,
		CAST(CustomerRole.IsAccess AS INT) AS 'IsAccess',
		MultiLogin
	FROM         
		dbo.Role INNER JOIN
        dbo.CustomerRole ON dbo.Role.RoleKey = dbo.CustomerRole.RoleID RIGHT OUTER JOIN
		dbo.Customer ON dbo.CustomerRole.CustomerID = dbo.Customer.CustomerKey Inner join
		dbo.Client on Customer.ClientID = Client.ClientKey
		
	WHERE
		CustomerKey !=0 
		and
		--(@IsActive is null or Client.IsActive=@IsActive) and
		--Customer.IsActive = 1 and
		Client.ClientName = @ClientName	
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
	 [UGCUploadEdit]
    )
)AS B
	
	
END


