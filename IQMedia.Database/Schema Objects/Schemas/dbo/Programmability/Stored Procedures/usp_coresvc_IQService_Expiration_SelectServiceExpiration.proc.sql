-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_coresvc_IQService_Expiration_SelectServiceExpiration]
	@NumRecord bigint,
	@RPSiteID varchar(250),
	@IsRemoteLocation bit
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @Query nvarchar(max)
	
    If(@IsRemoteLocation = 1)
		BEGIN
			Set @Query = 'SELECT TOP ' + cast(@NumRecord  as varchar(50)) + '
							T1.[RecordfileGuid] as GUID,
							T1.[IQ_CC_Key] as IQCCKey
						FROM 
							[IQMediaGroup].[dbo].[IQService_Expiration] AS T1
							Inner Join IQMediaGroup.dbo.IQCore_Recordfile as T2
							on T1.RecordfileGuid = T2.Guid
							Inner Join IQMediaGroup.dbo.IQRootpath_Location as T3
							on T2._RootPathID = T3._RootPathID
							WHERE ExpirationStatus is Null
							and T3.RPSiteID = ''' + @RPSiteID + ''''
		END
    ELSE	
		BEGIN
				Set @Query = 'SELECT TOP ' + cast(@NumRecord as varchar(50)) +' 
									T1.[RecordfileGuid] as GUID,
									T1.[IQ_CC_Key] as IQCCKey
								  FROM 
									[IQMediaGroup].[dbo].[IQService_Expiration]AS T1
									Inner Join IQMediaGroup.dbo.IQCore_Recordfile as T2
									on T1.RecordfileGuid = T2.Guid
									Inner Join IQMediaGroup.dbo.IQCore_Rootpath as T3
									on T2._RootPathID = T3.ID
									where ExpirationStatus is Null
									and T3.StoragePath like ''%10.100.1.%'''
		
		END
	
	Print @Query
	EXEC sp_executesql @Query
END
