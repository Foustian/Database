-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ArchiveBLPMDownload_Delete]
	
	@ID bigint
	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

    UPDATE 
		ArchiveBLPMDownload
	
	Set
		IsActive = 0
	
	Where ID = @ID
    
    
END