-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ArchiveClip_SelectAll] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    
    
    
	SELECT
			ArchiveClip.ClipTitle,
			ArchiveClip.ClipID,
			ArchiveClip.ThumbnailImagePath,
			ArchiveClip.ArchiveClipKey
	FROM
			ArchiveClip
	WHERE
			IsActive=1
			
END
