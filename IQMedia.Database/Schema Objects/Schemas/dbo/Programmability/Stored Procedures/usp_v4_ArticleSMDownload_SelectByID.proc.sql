-- =============================================
-- Author:		<Author,,Name>
-- Create date: 14 June 2013
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_ArticleSMDownload_SelectByID] 
	@ID		BIGINT,
	@CustomerGuid uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT * FROM ArticleSMDownload WHERE ID = @ID AND IsActive = 1 AND CustomerGuid = @CustomerGuid
END
