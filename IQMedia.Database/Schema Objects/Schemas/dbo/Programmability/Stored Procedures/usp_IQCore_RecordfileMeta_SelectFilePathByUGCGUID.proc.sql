
CREATE PROCEDURE usp_IQCore_RecordfileMeta_SelectFilePathByUGCGUID
(
	@UGCGUID		uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
				([UGC-FileLocation]+[UGC-FileName]) as FilePath
	FROM
		  (
			  SELECT
						[IQCore_RecordfileMeta].[_RecordfileGuid],
						[IQCore_RecordfileMeta].[Field],
						[IQCore_RecordfileMeta].[Value]
			  FROM
						[IQCore_RecordfileMeta]
			 WHERE
						[IQCore_RecordfileMeta].[_RecordfileGuid]=@UGCGUID
		  ) AS SourceTable
		  PIVOT
		  (
				Max(Value)
				FOR Field IN ([UGC-FileLocation],[UGC-FileName])
		  ) AS PivotTable

END
