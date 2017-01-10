
CREATE PROCEDURE [dbo].[usp_coresvc_IQCore_RootPath_SelectRoothPathByIPAddress]
	@ip_adress_mask varchar(max)
AS
BEGIN
	
	SET NOCOUNT ON;

  SELECT[ID] as id
      ,[StoragePath] as storagePath
      ,[_RootPathTypeID] as 'rootPathTypeID'
      ,[IsActive] as isActive
  FROM [IQMediaGroup].[dbo].[IQCore_RootPath]
  Where ID not in (19,24,49,51,52,105,138,139,146,147)  
  and StoragePath like '%'+ @ip_adress_mask +'%'


    
END
