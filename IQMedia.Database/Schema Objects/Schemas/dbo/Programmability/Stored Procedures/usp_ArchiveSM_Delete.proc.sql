CREATE PROCEDURE [dbo].[usp_ArchiveSM_Delete]
	@ArchiveSMKeys varchar(MAX)
AS
BEGIN

	DECLARE @Query as nvarchar(1000)
	
	SET @Query = 'UPDATE ArchiveSM SET ArchiveSM.IsActive = 0 WHERE ArchiveSMKey IN (' + @ArchiveSMKeys + ')'

	EXEC sp_executesql @Query
	
END