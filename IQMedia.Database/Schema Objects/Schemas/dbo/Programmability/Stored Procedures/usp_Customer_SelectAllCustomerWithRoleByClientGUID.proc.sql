-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Customer_SelectAllCustomerWithRoleByClientGUID] 
	-- Add the parameters for the stored procedure here
	
	(
		@ClientGUID uniqueidentifier
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
		isnull([IQBasic],0)as 'IQBasic',
		isnull([AdvancedSearchAccess],0)as 'AdvancedSearchAccess',
		isnull([GlobalAdminAccess],0)as 'GlobalAdminAccess',
		isnull([myIQAccess],0)as 'myIQAccess',
		isnull([IQAgentWebsiteAccess],0)as 'IQAgentWebsiteAccess',
		isnull([DownloadClips],0)as 'DownloadClips',
		isnull([IQCustomAccess],0)as 'IQCustomAccess',
		isnull([UGCDownload],0)as 'UGCDownload',
		isnull([UGCUploadEdit],0)as 'UGCUploadEdit',
		DefaultPage,
		[IsActive]
		
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
		DefaultPage
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
		Client.ClientGUID = @ClientGUID
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
	-- [IQAgentUser],
	-- [IQAgentAdminAccess],
	 [myIQAccess],
	 [IQAgentWebsiteAccess],
	 [DownloadClips],
	 [IQCustomAccess],
	 [UGCDownload],
	 [UGCUploadEdit]
    )
)AS B
	
END

