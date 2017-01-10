
CREATE PROCEDURE [dbo].[usp_ArchiveClip_SelectData_changerollbacked]

AS
BEGIN	
	SET NOCOUNT ON;
	declare @clipDate datetime
	Insert into ArchiveClip
		(
			ClipID,
			ClipLogo,
			ClipTitle,
			ClipDate,
			Category,
			Keywords,
			[Description],
			ClipCreationDate,
			CreatedDate,
			ModifiedDate,
			IsActive,
			ThumbnailImagePath,
			ClientGUID,
			CategoryGUID,
			CustomerGUID
		)
	
	SELECT 
			 [IQCore_Clip].[Guid] AS ClipID, 
			 'http://media.redlasso.com/logos/stations/small/' + [IQCore_Source].[Logo] AS ClipLogo, 
			 [IQCore_ClipInfo].[Title] AS ClipTitle,
			 case when ([IQCore_Recording].[StartDate] between convert(datetime,'2009-03-08 02:00:00.000') 
					and convert(datetime,'2009-11-01 00:00:00.000'))
				OR 
				([IQCore_Recording].[StartDate] between convert(datetime,'2010-03-14 02:00:00.000') 
					and convert(datetime,'2010-11-07 00:00:00.000'))
				OR 
				([IQCore_Recording].[StartDate] between convert(datetime,'2011-03-13 02:00:00.000') 
					and convert(datetime,'2011-11-06 00:00:00.000'))
				OR
				([IQCore_Recording].[StartDate] between convert(datetime,'2012-03-11 02:00:00.000') 
					and convert(datetime,'2012-11-04 00:00:00.000'))
				OR 
				([IQCore_Recording].[StartDate] between convert(datetime,'2013-03-11 02:00:00.000') 
					and convert(datetime,'2013-11-03 00:00:00.000'))
			then 
				 DateAdd(second,IQCore_Clip.StartOffset,DateAdd(hour,gmt_adj,DateAdd(hour,dst_adj,[IQCore_Recording].[StartDate])))
			else 
				DateAdd(second,IQCore_Clip.StartOffset,DateAdd(hour,gmt_adj,[IQCore_Recording].[StartDate]))
            END
             ,[IQCore_ClipInfo].[Category], 
             [IQCore_ClipInfo].[Keywords],
             [IQCore_ClipInfo].[Description],  
             [IQCore_Clip].[DateCreated] AS ClipCreationDate,
             GETDATE(),
             GETDATE(),
             1,
             REPLACE([IQCore_RootPath].[StreamSuffixPath] + [IQCore_AssetLocation].[Location],'\','/') AS ClipThumbnailImagePath,
             [iqClientid] as ClientGUID,
             [iQCategory] as CategoryGUID,
             [iQUser] as CustomerGUID
                          
	FROM 
			[IQCore_Clip] with(nolock)
				Inner Join [IQCore_ClipInfo] with(nolock)
					ON [IQCore_Clip].[Guid] = [IQCore_ClipInfo].[_ClipGuid]				
				Inner Join [IQCore_Recordfile] with(nolock)
					ON [IQCore_Recordfile].[Guid] = [IQCore_Clip].[_RecordfileGuid]
				Inner Join [IQCore_Recording] with(nolock)
					ON [IQCore_Recordfile].[_RecordingID] = [IQCore_Recording].[ID]
				Inner Join [IQCore_Source] with(nolock)
					ON [IQCore_Recording].[_SourceGuid] = [IQCore_Source].[Guid]
				left outer Join [IQCore_AssetLocation] with(nolock)
					ON [IQCore_Clip].[Guid] = [IQCore_AssetLocation].[_AssetGuid]
				left outer Join [IQCore_RootPath] with(nolock)
					ON [IQCore_AssetLocation].[_RootPathID] = [IQCore_RootPath].ID
				Inner Join 
					(
						SELECT 
								_ClipGuid, [iQCategory],[iqClientid], [iQUser]
						FROM
								(
									SELECT 
											IQCore_ClipMeta._ClipGuid, IQCore_ClipMeta.Field,IQCore_ClipMeta.Value
									FROM 
											IQCore_ClipMeta  with(nolock)									
								) AS SourceTable    
						PIVOT
						(
							Max(Value)
							FOR Field IN ([iQCategory],[iqClientid], [iQUser])
						) AS PivotTable) as ClipMetaData
						ON [IQCore_Clip].[Guid]=ClipMetaData._ClipGuid
				Inner Join RL_STATION
						ON [IQCore_Source].[SourceID]=RL_STATION.RL_Station_ID						
				left outer join ArchiveClip 
						ON [IQCore_Clip].Guid = ArchiveClip.ClipID
	where [IQCore_Clip].[_UserGuid] = '07175c0e-2b70-4325-be6d-611910730968' and
		 CONVERT(date,[IQCore_Clip].[DateCreated])=convert(date,GETDATE())
		 And ArchiveClip.ClipID IS Null

   
END
