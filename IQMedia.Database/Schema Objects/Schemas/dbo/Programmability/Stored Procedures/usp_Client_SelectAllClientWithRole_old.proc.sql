﻿-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Client_SelectAllClientWithRole_old] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;


	SELECT	
		[ClientKey],
		[ClientName],
		CAST(isnull([IQBasic],0) as bit) as 'IQBasic',
		cast(isnull([AdvancedSearchAccess],0) as bit) as 'AdvancedSearchAccess',
		cast(isnull([GlobalAdminAccess],0) as bit) as 'GlobalAdminAccess',
		cast(isnull([IQAgentUser],0) as bit) as 'IQAgentUser',
		cast(isnull([IQAgentAdminAccess],0) as bit)as 'IQAgentAdminAccess',
		cast(isnull([myIQAccess],0) as bit) as 'myIQAccess',
		cast(isnull([IQAgentWebsiteAccess],0) as bit) as 'IQAgentWebsiteAccess',
		cast(isnull([DownloadClips],0) as bit) as 'DownloadClips',
		cast(isnull([IQCustomAccess],0) as bit) as 'IQCustomAccess',
		cast(isnull([UGCDownload],0) as bit) as 'UGCDownload',
		cast(isnull([IframeMicrosite],0) as bit) as 'IframeMicrosite',	
		cast(isnull([UGCUploadEdit],0) as bit) as 'UGCUploadEdit',			
		[IsActive]
		
FROM
(
	SELECT     
		dbo.Client.ClientName, 
		dbo.Client.ClientKey, 
		--dbo.ClientRole.RoleID, 
		dbo.Role.RoleName,
		Client.IsActive,
		CAST(ClientRole.IsAccess AS INT) AS 'IsAccess'
	FROM         
		dbo.Role INNER JOIN
        dbo.ClientRole ON dbo.Role.RoleKey = dbo.ClientRole.RoleID RIGHT OUTER JOIN
		dbo.Client ON dbo.ClientRole.ClientID = dbo.Client.ClientKey
		
	WHERE
		ClientKey !=0 
		--and
		--(@IsActive is null or Client.IsActive=@IsActive) and
		--Client.IsActive = 1	

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


