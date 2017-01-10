CREATE PROCEDURE [dbo].[usp_IOSService_IQService_IOSUGCUpload_Insert]
	@FileName varchar(250),
	@Title	varchar(500),
	@Description varchar(max),
	@Keywords varchar(max),
	@StartTime	varchar(10),
	@EndTime	varchar(10),
	@UDID		varchar(50)
AS
BEGIN
	INSERT INTO IQService_IOSUGCUpload 
	(
		[FileName],
		Title,
		Keywords,
		[Description],
		StartTime,
		EndTime,
		UDID,
		CreatedDate,
		ModifiedDate,
		[Status]
	)

	Values
	(
		@FileName,
		@Title,
		@Keywords,
		@Description,
		@StartTime,
		@EndTime,
		@UDID,
		GETDATE(),
		GETDATE(),
		0
	)

	SELECT SCOPE_IDENTITY() as 'ID'
END
