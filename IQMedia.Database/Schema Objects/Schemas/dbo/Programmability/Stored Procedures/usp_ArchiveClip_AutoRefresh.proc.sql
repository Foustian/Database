
CREATE PROCEDURE [dbo].[usp_ArchiveClip_AutoRefresh]
	@ClipGuid uniqueidentifier,
	@IsDayLightSaving bit
AS
BEGIN	
	SET NOCOUNT ON;
		begin transaction
	begin try
		INSERT INTO ArchiveClip(
			ClipID,
			ClipCreationDate,
			Category,
			Keywords,
			[Description],
			ClipTitle,
			ClipLogo,
			ClipDate,
			ThumbnailImagePath,
			CategoryGUID,
			ClientGUID,
			CustomerGUID,
			FirstName,
			SubCategory1GUID,
			SubCategory2GUID,
			SubCategory3GUID,
			CreatedDate,
			ModifiedDate,
			IsActive
		)	
	SELECT 
			 [IQCore_Clip].[Guid] AS ClipID, 
             [IQCore_Clip].[DateCreated] AS ClipCreationDate, 
             [IQCore_ClipInfo].[Category], 
             [IQCore_ClipInfo].[Keywords],
             [IQCore_ClipInfo].[Description],  
             [IQCore_ClipInfo].[Title] AS ClipTitle,
             'http://media.iqmediacorp.com/logos/stations/small/' + [IQCore_Source].[Logo] AS ClipLogo, 
             Case When @IsDayLightSaving = 1 THEN DATEADD(ss,IQCore_Clip.StartOffset,DATEADD(hh,[RL_STATION].gmt_adj,[IQCore_Recording].[StartDate])) ELSE  DATEADD(ss,IQCore_Clip.StartOffset,DATEADD(hh,RL_STATION.dst_adj,DATEADD(hh,[RL_STATION].gmt_adj,[IQCore_Recording].[StartDate]))) END AS ClipDate,
             REPLACE([IQCore_RootPath].[StreamSuffixPath] + [IQCore_AssetLocation].[Location],'\','/') AS ThumbnailImagePath,
             [iQCategory] as CategoryGUID,
             [iqClientid] as ClientGUID,
             [iQUser] as CustomerGUID,
             (SELECT  Customer.FirstName  From Customer Where Customer.CustomerGUID = [iQUser]),
             NULLIF(ClipMetaData.SubCategory1GUID,''),
             NULLIF(ClipMetaData.SubCategory2GUID,''),
             NULLIF(ClipMetaData.SubCategory3GUID,''),
             SYSDATETIME(),
             SYSDATETIME(),
             '1'
                          
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
								_ClipGuid, [iQCategory],[iqClientid], [iQUser],[SubCategory1GUID],[SubCategory2GUID],[SubCategory3GUID]
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
							FOR Field IN ([iQCategory],[iqClientid], [iQUser],[SubCategory1GUID],[SubCategory2GUID],[SubCategory3GUID])
						) AS PivotTable) as ClipMetaData
						ON [IQCore_Clip].[Guid]=ClipMetaData._ClipGuid				
				Inner Join RL_STATION
						ON [IQCore_Source].[SourceID]=RL_STATION.RL_Station_ID	
				left outer join ArchiveClip 
						ON [IQCore_Clip].Guid = ArchiveClip.ClipID	
							
	where [IQCore_Clip].[_UserGuid] = '07175c0e-2b70-4325-be6d-611910730968' and
		 CONVERT(date,[IQCore_Clip].[DateCreated])=convert(date,GETDATE())
		 and ArchiveClip.ClipID is null		
		AND [IQCore_Clip].Guid = @ClipGuid
		commit transaction
	end try
	begin catch
	
		rollback transaction
		
		declare @IQMediaGroupExceptionKey bigint,
				@ExceptionStackTrace varchar(500),
				@ExceptionMessage varchar(500),
				@CreatedBy	varchar(50),
				@ModifiedBy	varchar(50),
				@CreatedDate	datetime,
				@ModifiedDate	datetime,
				@IsActive	bit
				
		
		Select 
				@ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(varchar(50),ERROR_LINE())),
				@ExceptionMessage=convert(varchar(50),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
				@CreatedBy='usp_ArchiveClip_SelectData',
				@ModifiedBy='usp_ArchiveClip_SelectData',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		exec usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@ModifiedBy,@CreatedDate,@ModifiedDate,@IsActive,@IQMediaGroupExceptionKey output
	
	end catch
End
   