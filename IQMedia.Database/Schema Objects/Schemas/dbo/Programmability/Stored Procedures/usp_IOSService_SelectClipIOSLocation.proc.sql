CREATE PROCEDURE [dbo].[usp_IOSService_SelectClipIOSLocation]
	@clipGUID uniqueidentifier
AS
BEGIN

	
	
	/* SELECT 
		IQCore_RootPath.StreamSuffixPath,
		IQCore_RootPath.AppName,
		IQCore_ClipMeta.Value AS 'IOSFileLocation'
		
	FROM
	
		IQCore_RootPath 
		
		INNER JOIN IQCore_Recordfile
		ON IQCore_RootPath.ID = IQCore_Recordfile._RootPathID

		INNER JOIN IQCore_Clip
		ON IQCore_Recordfile.Guid = IQCore_Clip._RecordfileGuid

		INNER JOIN IQCore_ClipMeta
		ON IQCore_Clip.Guid = IQCore_ClipMeta._ClipGuid

		Where IQCore_Clip.Guid = @ClipGUID
		AND IQCore_ClipMeta.Field = 'IOSFileLocation'*/
	
	
	SELECT
				IOSFileLocation,
				IQCore_RootPath.StreamSuffixPath,
				IQCore_RootPath.AppName
	FROM
		  (
			  SELECT						
						[IQCore_ClipMeta].[Field],
						[IQCore_ClipMeta].[Value]
			  FROM
						[IQCore_ClipMeta]
			 WHERE
						[IQCore_ClipMeta]._ClipGuid=@ClipGUID
		  ) AS SourceTable
		  PIVOT
		  (
				Max(Value)
				FOR Field IN ([IOSRootPathID],[IOSFileLocation])
		  ) AS PivotTable
					inner join IQCore_RootPath
						on PivotTable.IOSRootPathID=IQCore_RootPath.ID

	/*select 
	isnull((
		Select StreamSuffixPath
		from IQCore_RootPath
		where ID = (select Value
					from IQCore_ClipMeta
					where Field='IOSRootPathID' and _ClipGuid=@clipGUID)),'')
	+
	isnull((
			Select Value 
			from IQCore_ClipMeta
			where Field='IOSLocation' and _ClipGuid=@clipGUID),'')*/
END
