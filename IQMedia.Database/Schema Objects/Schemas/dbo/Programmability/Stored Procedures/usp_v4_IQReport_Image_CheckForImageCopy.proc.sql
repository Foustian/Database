CREATE PROCEDURE [dbo].[usp_v4_IQClient_CustomImage_CheckForImageCopy]
	@Image varchar(255),
	@ClientGuid uniqueidentifier
AS
BEGIN
	DECLARE @FileNameWithoutExt varchar(255)
	DECLARE @FileExt varchar(5)

	SET @FileExt = right(@Image, charindex('.', reverse(@Image))) 
	SET @FileNameWithoutExt = REPLACE(@Image,@FileExt,'')

	DECLARE @MaxImageCopyCount int = NULL

	IF EXISTS(SELECT [Location] From IQClient_CustomImage Where _ClientGUID = @ClientGuid and LOWER([Location]) = LOWER(@Image) AND IsActive = 1)
	BEGIN
		SELECT 
			
			@MaxImageCopyCount = CASE WHEN MAX([Location]) IS NULL THEN 
									0 
								ELSE 
									MAX(Convert(int,REPLACE(REPLACE([Location],lower(right([Location], charindex('.', reverse([Location])))),''),@FileNameWithoutExt + '_','')))
								END
	FROM 
			IQClient_CustomImage 
	Where 
			lower(right([Location], charindex('.', reverse([Location])))) = @FileExt
			AND 
			(	
				REPLACE([Location],lower(right([Location], charindex('.', reverse([Location])))),'') like ''+ @FileNameWithoutExt +'[_][0-9]'
				OR REPLACE([Location],lower(right([Location], charindex('.', reverse([Location])))),'') like ''+ @FileNameWithoutExt +'[_][0-9][0-9]'
				OR REPLACE([Location],lower(right([Location], charindex('.', reverse([Location])))),'') like ''+ @FileNameWithoutExt +'[_][0-9][0-9][0-9]'
			)
			AND _ClientGUID = @ClientGuid 
	END

	SELECT @MaxImageCopyCount as MaxCount
END