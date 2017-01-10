
CREATE PROCEDURE [dbo].[usp_ArchiveClip_SelectDataByClipID]
(
	@ClipID			uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON;	
	
	SELECT 
			 [IQCore_Clip].[Guid] AS ClipID, 
             [IQCore_Clip].[DateCreated] AS ClipCreationDate, 
             [IQCore_ClipInfo].[Category], 
             [IQCore_ClipInfo].[Description],  
             [IQCore_ClipInfo].[Title] AS ClipTitle,
             [IQCore_ClipInfo].[Keywords],             
             'http://media.iqmediacorp.com/logos/stations/small/' + [IQCore_Source].[Logo] AS ClipLogo, 
             [IQCore_Recording].[StartDate] AS ClipDate,
             REPLACE([IQCore_RootPath].[StreamSuffixPath] + [IQCore_AssetLocation].[Location],'\','/') AS ClipThumbnailImagePath,            
             [RL_STATION].gmt_adj,
             [RL_STATION].dst_adj,
             IQCore_Clip.StartOffset,
            (select Field,Value from IQCore_ClipMeta as Meta where Meta._ClipGuid=@ClipID for xml auto,root('MetaData')) as ClipMeta
                          
	FROM 
			[IQCore_Clip] 
				Inner Join [IQCore_ClipInfo]
					ON [IQCore_Clip].[Guid] = [IQCore_ClipInfo].[_ClipGuid]				
				Inner Join [IQCore_Recordfile]
					ON [IQCore_Recordfile].[Guid] = [IQCore_Clip].[_RecordfileGuid]
				Inner Join [IQCore_Recording]
					ON [IQCore_Recordfile].[_RecordingID] = [IQCore_Recording].[ID]
				Inner Join [IQCore_Source]
					ON [IQCore_Recording].[_SourceGuid] = [IQCore_Source].[Guid]
				left outer Join [IQCore_AssetLocation]
					ON [IQCore_Clip].[Guid] = [IQCore_AssetLocation].[_AssetGuid]
				left outer join [IQCore_RootPath]
					ON [IQCore_AssetLocation].[_RootPathID] = [IQCore_RootPath].ID				
				Inner Join RL_STATION
						ON [IQCore_Source].[SourceID]=RL_STATION.RL_Station_ID				
	where	[IQCore_Clip].[Guid]=@ClipID
	
	

END
