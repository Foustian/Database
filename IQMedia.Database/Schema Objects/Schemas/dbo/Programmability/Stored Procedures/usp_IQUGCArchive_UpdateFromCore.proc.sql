-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQUGCArchive_UpdateFromCore]
(
	@ClientGUID		uniqueidentifier
)
AS
BEGIN	
	SET NOCOUNT ON;
	
	/*MERGE IQUGCArchive as Target
	USING
	(
		Select
				[RecordMetaData].[UGCTitle],
				[RecordMetaData].[UGCKwords],
				[RecordMetaData].[UGCCreateDT],
				[RecordMetaData].[UGCDesc],
				[RecordMetaData].[UGCCategory],				
				[IQCore_Recording].[StartDate] AS AirDate,
				[IQCore_Recordfile].[Guid] as UGCGUID ,
				[IQCore_Source].[Guid] as SourceID,
				[RecordMetaData].[iQUser] as CustomerGUID
		  FROM  
				[IQCore_Recordfile]
					Inner Join [IQCore_Recording]
						ON [IQCore_Recordfile].[_RecordingID] = [IQCore_Recording].[ID]
					Inner Join [IQCore_Source]
						ON [IQCore_Recording].[_SourceGuid] = [IQCore_Source].[Guid]
					Inner Join [IQClient_UGCMap]
						ON [IQCore_Source].[Guid] = [IQClient_UGCMap].[SourceGUID]
					Inner Join
					(
						SELECT
									[_RecordfileGuid], 
									[UGC-Title] as UGCTitle,
									[UGC-Category] as UGCCategory, 
									[UGC-Kwords] as UGCKwords,
									[UGC-CreateDT] as UGCCreateDT,
									[iQUser],
									[UGC-Desc] as UGCDesc
						FROM
							  (
								  SELECT
											[IQCore_RecordfileMeta].[_RecordfileGuid],
											[IQCore_RecordfileMeta].[Field],
											[IQCore_RecordfileMeta].[Value]
								  FROM
											[IQCore_RecordfileMeta]
							  ) AS SourceTable
							  PIVOT
							  (
									Max(Value)
									FOR Field IN ([UGC-Title],[UGC-Category], [UGC-Kwords],[UGC-CreateDT],[iQUser],[UGC-Desc])
							  ) AS PivotTable
					) as RecordMetaData
						ON [IQCore_Recordfile].[Guid]=[RecordMetaData].[_RecordfileGuid]					
		  WHERE 
					[IQClient_UGCMap].[ClientGUID]=@ClientGUID
	 ) AS Source
	 ON (Target.UGCGUID=Source.UGCGUID)
	 WHEN NOT MATCHED BY TARGET THEN
    INSERT 
    (
		UGCGUID,
		Title,
		CategoryGUID,
		Keywords,
		[Description],
		CreateDT,
		AirDate,
		CustomerGUID,
		ClientGUID,
		SourceID,
		CreatedDate,
		ModifiedDate,
		CreatedBy,
		ModifiedBy,
		IsActive
    )
    VALUES 
    (
		Source.UGCGUID,
		Source.UGCTitle, 
		Source.[UGCCategory],
		Source.[UGCDesc],
		Source.[UGCCreateDT],
		Source.AirDate,
		Source.CustomerGUID,
		[IQClient_UGCMap].[ClientGUID],
		Source.SourceID,
		GetDate(),
		GetDate(),
		'IQUGC_Process',
		'IQUGC_Process',
		1
	);*/
	
	insert into IQUGCArchive
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
		CustomerGUID,
		ClientGUID,
		SourceID,
		CreatedDate,
		ModifiedDate,
		CreatedBy,
		ModifiedBy,
		IsActive
		
	)
	Select
			[IQCore_Recordfile].[Guid] as UGCGUID,
			[RecordMetaData].[UGCTitle],
			[RecordMetaData].[UGCCategory],	
			[RecordMetaData].[UGCSubCategory1],	
			[RecordMetaData].[UGCSubCategory2],	
			[RecordMetaData].[UGCSubCategory3],	
			[RecordMetaData].[UGCKwords],
			[RecordMetaData].[UGCDesc],
			[RecordMetaData].[UGCCreateDT],
			[RecordMetaData].[UGCCreateDTTimeZone],
			[IQCore_Recording].[StartDate] AS AirDate,
			[RecordMetaData].[iQUser] as CustomerGUID, 
			[IQClient_UGCMap].[ClientGUID],
			[IQCore_Source].[Guid] as SourceID,
			GETDATE(),
			GETDATE(),
			'IQUGC_Process',
			'IQUGC_Process',
			1
				
  FROM  
		[IQCore_Recordfile]
			Inner Join [IQCore_Recording]
				ON [IQCore_Recordfile].[_RecordingID] = [IQCore_Recording].[ID]
			Inner Join [IQCore_Source]
				ON [IQCore_Recording].[_SourceGuid] = [IQCore_Source].[Guid]
			Inner Join [IQClient_UGCMap]
				ON [IQCore_Source].[Guid] = [IQClient_UGCMap].[SourceGUID]
			Inner Join
			(
				SELECT
							[_RecordfileGuid], 
							[UGC-Title] as UGCTitle,
							[UGC-Category] as UGCCategory, 
							[UGC-SubCategory1] as UGCSubCategory1, 
							[UGC-SubCategory2] as UGCSubCategory2, 
							[UGC-SubCategory3] as UGCSubCategory3, 
							[UGC-Kwords] as UGCKwords,
							SUBSTRING([UGC-CreateDT],0,LEN([UGC-CreateDT])-3) as UGCCreateDT,
							RIGHT([UGC-CreateDT],3) as UGCCreateDTTimeZone,
							[iQUser],
							[UGC-Desc] as UGCDesc
				FROM
					  (
						  SELECT
									[IQCore_RecordfileMeta].[_RecordfileGuid],
									[IQCore_RecordfileMeta].[Field],
									[IQCore_RecordfileMeta].[Value]
						  FROM
									[IQCore_RecordfileMeta]
					  ) AS SourceTable
					  PIVOT
					  (
							Max(Value)
							FOR Field IN ([UGC-Title],[UGC-Category], [UGC-Kwords],[UGC-CreateDT],[iQUser],[UGC-Desc],[UGC-SubCategory1],[UGC-SubCategory2],[UGC-SubCategory3])
					  ) AS PivotTable
			) as RecordMetaData
				ON [IQCore_Recordfile].[Guid]=[RecordMetaData].[_RecordfileGuid]					
  WHERE 
			[IQClient_UGCMap].[ClientGUID]=@ClientGUID AND
not exists 
(
	Select * from IQUGCArchive where [IQCore_Recordfile].[Guid]=IQUGCArchive.UGCGUID			
)
	
END
