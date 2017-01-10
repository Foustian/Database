CREATE PROCEDURE [dbo].[usp_v4_IQCore_ClipMeta_SelectFilePathByClipGUID]
	@ClipGUID		uniqueidentifier,
	@ClientGuid		uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;
	
						SELECT
							CASE 
										When (([UGCFileLocation]+[UGCFileName]) IS NOT NULL and ([UGCFileLocation]+[UGCFileName])!='')
											Then	
												([UGCFileLocation]+[UGCFileName])
										ELSE
												([FileLocation] + [FileName] )
							END  as Filepath,FTPFileLocation
													
							FROM
							  (
								  SELECT
											[IQCore_ClipMeta]._ClipGuid,
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
									FOR Field IN ([UGCFileLocation],[UGCFileName],[FileLocation],[FileName],[FTPFileLocation],[iqClientid])
							  ) AS PivotTable
					WHERE [iqClientid] = @ClientGuid
		
	/*SELECT
				([FileLocation]+[FileName]) as FilePath
	FROM
		  (
			  SELECT
						[IQCore_ClipMeta]._ClipGuid,
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
				FOR Field IN ([FileLocation],[FileName])
		  ) AS PivotTable*/

END