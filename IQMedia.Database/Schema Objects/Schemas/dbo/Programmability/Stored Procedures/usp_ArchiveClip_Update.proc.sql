CREATE PROCEDURE [dbo].[usp_ArchiveClip_Update]
	
	@ClipID			uniqueidentifier,
	@ClipTitle			VARCHAR(150),
	@FirstName	VARCHAR(150),
	@CustomerGUID uniqueidentifier,
	@CategoryGUID uniqueidentifier,
	@SubCategory1GUID uniqueidentifier,
	@SubCategory2GUID uniqueidentifier,
	@SubCategory3GUID uniqueidentifier,
	@Keywords varchar(MAX),
	@Description varchar(MAX),
	@Rating tinyint
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;


	UPDATE ArchiveClip
			SET
				ClipTitle = @ClipTitle,
				CustomerGUID = @CustomerGUID,
				CategoryGUID = @CategoryGUID,
				FirstName = @FirstName,
				SubCategory1GUID = @SubCategory1GUID,
				SubCategory2GUID = @SubCategory2GUID,
				SubCategory3GUID = @SubCategory3GUID,
				[Keywords] = @Keywords,
				[Description] = @Description,
				Rating = @Rating
			--from ArchiveClip inner join Customer on ArchiveClip.CustomerGUID = Customer.CustomerGUID		
			WHERE
				ClipID = @ClipID
				
		UPDATE ArchiveClip 
		SET
				LastName = (SELECT Customer.LastName FROM Customer Where CustomerGuid = @CustomerGUID)
		WHERE 
				ClipID = @ClipID
			
END

