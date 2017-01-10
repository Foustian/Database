-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ArchiveTweets_Update]

	@ArchiveTweets_Key bigint,
	@Title varchar(250),
	@CategoryGuid uniqueidentifier,
	@SubCategory1Guid uniqueidentifier,
	@SubCategory2Guid uniqueidentifier,
	@SubCategory3Guid uniqueidentifier,
	@Description varchar(1000),
	@Keywords varchar(500),
	@Rating tinyint	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;

	UPDATE ArchiveTweets
	
	SET
		Title = @Title,
		CategoryGuid  = @CategoryGuid ,
		SubCategory1Guid = @SubCategory1Guid ,
		SubCategory2Guid = @SubCategory2Guid ,
		SubCategory3Guid = @SubCategory3Guid ,
		[Description] = @Description ,
		Keywords =@Keywords,
		Rating =@Rating,
		ModifiedDate = getdate()
	
	WHERE ArchiveTweets_Key = @ArchiveTweets_Key
    
    
    
END
