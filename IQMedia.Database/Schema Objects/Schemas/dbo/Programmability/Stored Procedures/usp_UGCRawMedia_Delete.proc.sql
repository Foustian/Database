
CREATE PROCEDURE [dbo].[usp_UGCRawMedia_Delete]
(
	@RawMediaIDs		Varchar(Max)
)
AS
BEGIN	
	SET NOCOUNT OFF;


	Begin transaction
	
	begin try

	Declare @Query	nvarchar(Max)

	Set @Query='Update
			IQCore_Recordfile
	Set
			[Status]=''WEBDELETED''
	Where
			CONVERT(Varchar(Max),[IQCore_Recordfile].[Guid]) in ('+@RawMediaIDs+')'
			
	Set @Query=@Query+' Update IQUGCArchive set IsActive=0,ModifiedDate=GetDate() Where CONVERT(Varchar(Max),UGCGUID) in ('+@RawMediaIDs+')'
			
	exec sp_executesql @Query
	
	commit transaction
	
	end try
	begin catch
	rollback transaction
	end catch
	
END
