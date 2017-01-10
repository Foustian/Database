/*
	Created By 	: templage Generator ( An AmulTek product )
	Created On 	: 3/22/2010
	Purpose		: To Update data in RL_GUIDS
*/


-- EXEC [dbo].[usp_ArchiveNM_Delete] '14,15'

CREATE PROCEDURE [dbo].[usp_ArchiveNM_Delete]
(
	@ArchiveNMKeys varchar(MAX)
)
AS
BEGIN

	DECLARE @Query as nvarchar(1000)
	
	SET @Query = 'UPDATE ArchiveNM SET ArchiveNM.IsActive = 0 WHERE ArchiveNMKey IN (' + @ArchiveNMKeys + ')'

	EXEC sp_executesql @Query
	
END