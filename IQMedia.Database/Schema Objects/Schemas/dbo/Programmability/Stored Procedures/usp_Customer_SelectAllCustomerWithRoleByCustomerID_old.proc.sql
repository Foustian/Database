-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Customer_SelectAllCustomerWithRoleByCustomerID_old] 
	-- Add the parameters for the stored procedure here
	
	(
		@CustomerID varchar(100)
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
		isnull([IQAgentUser],0)as 'IQAgentUser',
		isnull([IQAgentAdminAccess],0)as 'IQAgentAdminAccess',
		isnull([myIQAccess],0)as 'myIQAccess',
		isnull([IQAgentWebsiteAccess],0)as 'IQAgentWebsiteAccess',
		isnull([DownloadClips],0)as 'DownloadClips',
		isnull([IQCustomAccess],0)as 'IQCustomAccess',
		isnull([UGCDownload],0)as 'UGCDownload',
		cast(isnull([UGCUploadEdit],0) as bit) as 'UGCUploadEdit',
		[IsActive],
		CreatedDate,
		ClientName,
		MasterClient,
		DefaultPage,
		MultiLogin
		
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
		 Customer.CreatedDate,
		 dbo.Role.RoleName,
		Customer.IsActive,
		Client.ClientName,
		Client.MasterClient,
		CAST(CustomerRole.IsAccess AS INT) AS 'IsAccess',
		DefaultPage,
		MultiLogin
	FROM         
		dbo.Role INNER JOIN
        dbo.CustomerRole ON dbo.Role.RoleKey = dbo.CustomerRole.RoleID RIGHT OUTER JOIN
		dbo.Customer ON dbo.CustomerRole.CustomerID = dbo.Customer.CustomerKey inner join
		dbo.Client on dbo.Customer.ClientID = dbo.Client.ClientKey
		
	WHERE
		CustomerKey !=0 and
		--(@IsActive is null or Client.IsActive=@IsActive) and
		--Customer.IsActive = 1 and
		Customer.CustomerKey = @CustomerID	
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
