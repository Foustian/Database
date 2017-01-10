
CREATE PROCEDURE [dbo].[usp_Statskedprog_SelectPlayerDataForIQUGCArchive]
(
	@UGCGUID	uniqueidentifier
)
AS
BEGIN

	SET NOCOUNT ON;
	
	Select
			Title,
			AirDate,
			Keywords,
			[Description]
	From
			IQUGCArchive
	Where
			IQUGCArchive.[UGCGUID]=@UGCGUID


END
