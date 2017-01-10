-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ArchiveNM_SelectByArchiveNMKey] 
	-- Add the parameters for the stored procedure here
	@ArchiveNMKey bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    
    SELECT
		ArchiveNMKey,
		Title,
		[Keywords],
		[Description],
		CategoryGUID,
		SubCategory1GUID,
		SubCategory2GUID,
		SubCategory3GUID,
		Rating
	
	FROM
		ArchiveNM
	WHERE
		ArchiveNM.ArchiveNMKey=@ArchiveNMKey and ArchiveNM.IsActive = 1
END
