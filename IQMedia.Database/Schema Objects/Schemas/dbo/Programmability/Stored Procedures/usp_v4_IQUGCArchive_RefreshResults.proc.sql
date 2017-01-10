CREATE PROCEDURE [dbo].[usp_v4_IQUGCArchive_RefreshResults]
	@ClientGuid		UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		INSERT INTO IQUGCArchive 
		( 
			UGCGUID, 
			Title, 
			CategoryGUID, 
			SubCategory1GUID, 
			SubCategory2GUID, 
			SubCategory3GUID, 
			Keywords, 
			[Description], 
			CreateDT, 
			CreateDTTimeZone, 
			AirDate, 
			DateUploaded,
			CustomerGUID, 
			ClientGUID, 
			SourceID, 
			_FileTypeID,
			CreatedDate, 
			ModifiedDate, 
			CreatedBy, 
			ModifiedBy, 
			IsActive 
		)
    
		SELECT 
			[IQCore_Recordfile].[Guid] AS UGCGUID, 
			[RecordMetaData].[UGCTitle], 
			CASE WHEN LEN([RecordMetaData].[UGCCategory]) > 0 THEN CAST([RecordMetaData].[UGCCategory] AS UNIQUEIDENTIFIER) ELSE NULL END AS [UGCCategory], 
			CASE WHEN LEN([RecordMetaData].[UGCSubCategory1]) > 0 THEN CAST([RecordMetaData].[UGCSubCategory1] AS UNIQUEIDENTIFIER) ELSE NULL END AS [UGCSubCategory1], 
			CASE WHEN LEN([RecordMetaData].[UGCSubCategory2]) > 0 THEN CAST([RecordMetaData].[UGCSubCategory2] AS UNIQUEIDENTIFIER) ELSE NULL END AS [UGCSubCategory2], 
			CASE WHEN LEN([RecordMetaData].[UGCSubCategory3]) > 0 THEN CAST([RecordMetaData].[UGCSubCategory3] AS UNIQUEIDENTIFIER) ELSE NULL END AS [UGCSubCategory3], 
			[RecordMetaData].[UGCKwords], 
			[RecordMetaData].[UGCDesc], 
			[RecordMetaData].[UGCCreateDT], 
			[RecordMetaData].[UGCCreateDTTimeZone], 
			[IQCore_Recording].[StartDate] AS AirDate, 
			[RecordMetaData].[UGCUploadDT], 
			[RecordMetaData].[iQUser] AS CustomerGUID, 
			[IQClient_UGCMap].[ClientGUID], 
			[IQCore_Source].[Guid] AS SourceID, 
			[IQUGC_FileTypes].ID AS _FileTypeID,
			GETDATE(), 
			GETDATE(), 
			'IQUGC_Process', 
			'IQUGC_Process', 
			1 

			FROM [IQCore_Recordfile] 
			
			INNER JOIN [IQCore_Recording] 
			ON [IQCore_Recordfile].[_RecordingID] = [IQCore_Recording].[ID] 
			
			INNER JOIN [IQCore_Source] 
			ON [IQCore_Recording].[_SourceGuid] = [IQCore_Source].[Guid] 
			
			INNER JOIN [IQClient_UGCMap] 
			ON [IQCore_Source].[Guid] = [IQClient_UGCMap].[SourceGUID] 			
			
			INNER JOIN IQCore_RecordfileType
			ON IQCore_Recordfile._RecordfileTypeID=IQCore_RecordfileType.ID
			
			INNER JOIN IQUGC_FileTypes
			ON IQCore_RecordfileType.Extension=IQUGC_FileTypes.FileTypeExt

			INNER JOIN 
			( 
				SELECT 
					[_RecordfileGuid], 
					[UGC-Title] AS UGCTitle, 
					[UGC-Category] AS UGCCategory, 
					[UGC-SubCategory1] AS UGCSubCategory1, 
					[UGC-SubCategory2] AS UGCSubCategory2, 
					[UGC-SubCategory3] AS UGCSubCategory3, 
					[UGC-Kwords] AS UGCKwords, 
					SUBSTRING([UGC-CreateDT],0,LEN([UGC-CreateDT])-3) AS UGCCreateDT, 
					RIGHT([UGC-CreateDT],3) AS UGCCreateDTTimeZone, 
					[UGC-UploadDT] AS UGCUploadDT,
					[iQUser], 
					[UGC-DESC] AS UGCDesc 
				FROM 
				( 
					SELECT 
						[IQCore_RecordfileMeta].[_RecordfileGuid], 
						[IQCore_RecordfileMeta].[Field], 
						[IQCore_RecordfileMeta].[Value] 
					FROM [IQCore_RecordfileMeta] 
					
				) AS SourceTable 
				PIVOT 
				( 
					MAX(VALUE) 
					FOR Field IN ([UGC-Title],[UGC-Category], [UGC-Kwords],[UGC-CreateDT],[iQUser],[UGC-DESC],[UGC-SubCategory1],[UGC-SubCategory2],[UGC-SubCategory3],[UGC-UploadDT])
				) AS PivotTable 
			) AS RecordMetaData 
				
			ON [IQCore_Recordfile].[Guid]=[RecordMetaData].[_RecordfileGuid] 
			
			LEFT OUTER JOIN [IQUGCArchive]
			ON	[IQUGCArchive].UGCGUID = [IQCore_Recordfile].[Guid]

			WHERE	[IQClient_UGCMap].[ClientGUID]=@ClientGuid
			AND		[IQUGCArchive].UGCGUID IS NULL
			AND UPPER([IQCore_Recordfile].[Status])='READY' 
    
END