
CREATE PROCEDURE [dbo].[usp_UGCRawMedia_Update_Old]
(
	@Title			Varchar(Max),
	@Keywords		Varchar(Max),
	@Description	Varchar(Max),
	@CustomerGUID	uniqueidentifier,
	@CategoryGUID	uniqueidentifier,
	@SubCategory1Guid uniqueidentifier,
	@SubCategory2Guid uniqueidentifier,
	@SubCategory3Guid uniqueidentifier,
	@RawMediaID		uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT OFF;
	
Begin Transaction
begin try
	
	Update	IQCore_RecordfileMeta
	Set
			Value=@Title
	Where
			Field='UGC-Title' and
			_RecordfileGuid=@RawMediaID
			
	Update	IQCore_RecordfileMeta
	Set
			Value=@Keywords
	Where
			Field='UGC-Kwords' and
			_RecordfileGuid=@RawMediaID
			
	Update	IQCore_RecordfileMeta
	Set
			Value=@Description
	Where
			Field='UGC-Desc' and
			_RecordfileGuid=@RawMediaID
			
	Update	IQCore_RecordfileMeta
	Set
			Value=@CategoryGUID
	Where
			Field='UGC-Category' and
			_RecordfileGuid=@RawMediaID
			
	Update	IQCore_RecordfileMeta
	Set
			Value=@SubCategory1Guid
	Where
			Field='UGC-SubCategory1' and
			_RecordfileGuid=@RawMediaID
	
	Update	IQCore_RecordfileMeta
	Set
			Value=@SubCategory2Guid
	Where
			Field='UGC-SubCategory2' and
			_RecordfileGuid=@RawMediaID
			
	Update	IQCore_RecordfileMeta
	Set
			Value=@SubCategory3Guid
	Where
			Field='UGC-SubCategory3' and
			_RecordfileGuid=@RawMediaID
			
			
	Update	IQCore_RecordfileMeta
	Set
			Value=@CustomerGUID
	Where
			Field='iQUser' and
			_RecordfileGuid=@RawMediaID
			
	Update
			IQUGCArchive
	Set
			Title=@Title,
			Keywords =@Keywords,
			[Description] =@Description,
			CustomerGUID=@CustomerGUID,
			CategoryGUID=@CategoryGUID,
			SubCategory1GUID = @SubCategory1Guid,
			SubCategory2GUID = @SubCategory2Guid,
			SubCategory3GUID = @SubCategory3Guid,
			ModifiedDate=GETDATE()
	Where
			UGCGUID=@RawMediaID
			
	commit transaction
	end try
	begin catch
	rollback transaction
	end catch			
	


END
