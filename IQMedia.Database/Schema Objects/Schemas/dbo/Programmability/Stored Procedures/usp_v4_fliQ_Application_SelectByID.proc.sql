CREATE PROCEDURE [dbo].[usp_v4_fliQ_Application_SelectByID]
	@ApplicationID bigint
AS
BEGIN

	SELECT
			ID,
			[Application],
			[Version],
			[Path],
			[Description],
			IsActive
	FROM
			fliQ_Application

	WHERE
			ID = @ApplicationID

END