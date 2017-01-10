CREATE PROCEDURE [dbo].[usp_v4_Gallery_Insert]
(
	@CustomerGUID UNIQUEIDENTIFIER,
	@Name VARCHAR(50),
	@Title VARCHAR(2048),
	@Description VARCHAR(255),
	@xml xml,
	@Output BIGINT output
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @IQGalleryMasterID INT

	IF(NOT EXISTS(
			SELECT Name
			FROM IQGallery_Master
				INNER JOIN Customer ON IQGallery_Master.CustomerGUID = Customer.CustomerGUID
				INNER JOIN Client ON Customer.ClientID = Client.ClientKey
			WHERE IQGallery_Master.CustomerGUID = @CustomerGUID AND Name = @Name AND IQGallery_Master.IsActive = 1
		))
    BEGIN

		

		INSERT INTO IQGallery_Master
		(
			Title,
			Name,
			[Description],
			CustomerGUID
		)
		VALUES
		(
			@Title,		
			@Name,
			@Description,
			@CustomerGUID
		)
		SET @IQGalleryMasterID = SCOPE_IDENTITY()
		
		INSERT INTO  [IQGallery_Detail](
			_ID,
			_ArchiveMediaID,
			[Col],
			[Row],
			_TypeID,
			[MetaData]
		)
		
		SELECT
		@IQGalleryMasterID as '_ID',
		CASE
			WHEN [Table].[Column].value('ID [1]', 'BIGINT') > 0
			THEN [Table].[Column].value('ID [1]', 'BIGINT')
			ELSE NULL
		END as '_ArchiveMediaID',
		[Table].[Column].value('Col[1]', 'INT') as 'Col',
		[Table].[Column].value(' Row[1]', 'INT') as 'Row',
		(SELECT ID FROM IQGallery_ItemType WHERE Name = [Table].[Column].value('Type[1]', 'VARCHAR(50)')) as _TypeID,
		CASE
			WHEN len([Table].[Column].value('MetaData[1]', 'VARCHAR(MAX)')) > 0
			THEN [Table].[Column].value('MetaData[1]', 'VARCHAR(MAX)')
			ELSE NULL
		END as 'MetaData'
		FROM @xml.nodes('/ ArrayOfIQGallery / IQGallery') as [Table]([Column])
	END
	ELSE
	BEGIN
		SET @Output = -1
	END
END