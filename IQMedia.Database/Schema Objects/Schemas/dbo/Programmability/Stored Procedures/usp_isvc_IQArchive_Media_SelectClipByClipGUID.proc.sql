CREATE PROCEDURE usp_isvc_IQArchive_Media_SelectClipByClipGUID
(
	@ClipGUID	UNIQUEIDENTIFIER,
	@ClientGUID	UNIQUEIDENTIFIER
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT   
				ID,
				MediaType,
				SubMediaType,
				CategoryName,
				_ParentID AS ParentID,
				ClipTitle AS Title,  
				IQArchive_Media.CategoryGUID,
				Keywords,
				[Description],
				ArchiveClip.PositiveSentiment,
				ArchiveClip.NegativeSentiment,
				CONVERT(NVARCHAR(MAX),ClosedCaption) AS CONTENT,  
				GMTDateTime AS MediaDate,  				
				ClipCreationDate AS CreatedDate,  
				ClipID,  
				CASE WHEN Nielsen_Audience >= 0 THEN Nielsen_Audience ELSE 0 END AS Audience,  
				Nielsen_Result AS AudienceResult,
				CASE WHEN IQAdShareValue >= 0 THEN IQAdShareValue ELSE 0 END AS IQAdShareValue,				
				(SELECT Dma_Name,Dma_Num,Station_Affil,IQ_Station_ID,TimeZone,Station_Call_Sign FROM IQ_Station WHERE IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key)) FOR XML PATH(''),ROOT('StationDetail')) AS StationDetail,								
				(SELECT  IQCore_ClipMeta.Field AS [KEY],IQCore_ClipMeta.Value FROM IQCore_ClipMeta WHERE _ClipGuid = ArchiveClip.ClipID   
					AND field NOT IN('FileLocation','FileName','IOSLocation','IOSRootPathID','iQCategory','iqClientid','iQUser','NoOfTimesDownloaded','UGCFileName','UGCFileLocation','SubCategory1GUID','SubCategory2GUID','SubCategory3GUID')  
					FOR XML PATH('Meta'),ROOT('ClipMeta')  
				) AS ClipMeta,
				[IQCore_Clip].[StartOffset],
				[IQCore_Clip].[EndOffset]
				
		FROM 
				IQArchive_Media WITH(NOLOCK)
					INNER JOIN ArchiveClip WITH(NOLOCK)  
						ON	IQArchive_Media._ArchiveMediaID = ArchiveClip.ArchiveClipKey  
						AND	ArchiveClip.ClipID=@ClipGUID
						AND IQArchive_Media.ClientGUID=@ClientGUID
						AND	IQArchive_Media.MediaType='TV'  		 
					INNER JOIN CustomCategory  
						ON IQArchive_Media.CategoryGUID = CustomCategory.CategoryGUID  
					INNER JOIN IQCore_Clip WITH(NOLOCK)
						ON ArchiveClip.ClipID = IQCore_Clip.[Guid]
		WHERE
				IQArchive_Media.IsActive=1
			AND	ArchiveClip.IsActive=1

END