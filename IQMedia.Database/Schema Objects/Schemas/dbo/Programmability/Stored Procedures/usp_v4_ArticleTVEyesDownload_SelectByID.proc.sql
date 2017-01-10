CREATE PROCEDURE [dbo].[usp_v4_ArticleTVEyesDownload_SelectByID]
	@ID		BIGINT,
	@CustomerGuid uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT * FROM ArticleTVEyesDownload WHERE ID = @ID AND IsActive = 1 AND CustomerGuid = @CustomerGuid
END
