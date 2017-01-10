CREATE PROCEDURE [dbo].[usp_v4_Gallery_Update]
(
	@ID BIGINT,
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

	IF(NOT EXISTS(
			SELECT Name
			FROM IQGallery_Master
				INNER JOIN Customer ON IQGallery_Master.CustomerGUID = Customer.CustomerGUID
				INNER JOIN Client ON Customer.ClientID = Client.ClientKey
			WHERE IQGallery_Master.CustomerGUID = @CustomerGUID AND Name = @Name AND IQGallery_Master.ID <> @ID AND IQGallery_Master.IsActive = 1
		))
    BEGIN

		UPDATE IQGallery_Master
			SET Name = @Name, Title = @Title, [Description] = @Description
		WHERE IQGallery_Master.CustomerGUID = @CustomerGUID AND IQGallery_Master.ID = @ID

		DELETE FROM IQGallery_Detail WHERE _ID = @ID

		INSERT INTO  [IQGallery_Detail](
			_ID,
			_ArchiveMediaID,
			[Col],
			[Row],
			_TypeID,
			[MetaData]
		)
		
		SELECT
		@ID as '_ID',
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

		SET @Output = SCOPE_IDENTITY()

	END
	ELSE
	BEGIN
		SET @Output = -1
	END
END