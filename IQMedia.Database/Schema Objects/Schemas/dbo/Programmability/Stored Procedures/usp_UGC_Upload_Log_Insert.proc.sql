
CREATE PROCEDURE [dbo].[usp_UGC_Upload_Log_Insert]
(
	@CustomerGUID		uniqueidentifier,
	@UGCContentXml		xml,
	@FileName			varchar(100),
	@UploadedDateTime	datetime	
)
AS
BEGIN
	SET NOCOUNT ON;
	
	insert into UGC_Upload_Log
	(
		CustomerGUID,
		UGCContentXml,
		UploadedDateTime,
		[FileName],
		CreatedBy,
		ModifiedBy,
		CreatedDate,
		ModifiedDate,
		IsActive
	)
	values
	(
		@CustomerGUID,
		@UGCContentXml,		
		@UploadedDateTime,
		@FileName,
		'System',
		'System',
		GETDATE(),
		GETDATE(),
		1
	)


END
