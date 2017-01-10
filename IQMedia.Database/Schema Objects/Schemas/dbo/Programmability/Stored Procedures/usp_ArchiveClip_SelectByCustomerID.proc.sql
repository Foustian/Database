-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ArchiveClip_SelectByCustomerID]
	-- Add the parameters for the stored procedure here
	@CustomerID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    SELECT
		ArchiveClip.ArchiveClipKey,
		ArchiveClip.ClipID,
		ArchiveClip.ClipLogo,
		ArchiveClip.ClipTitle,
		ArchiveClip.ClipDate,
		ArchiveClip.FirstName,
		ArchiveClip.CustomerID,
		ArchiveClip.Category,
		ArchiveClip.[Description],
		ArchiveClip.ClosedCaption,
		ArchiveClip.ClipCreationDate,
		ArchiveClip.ThumbnailImagePath,
		ArchiveClip.CategoryGUID,
		ArchiveClip.ClientGUID,
		ArchiveClip.CustomerGUID,
		CustomCategory.CategoryName
		
	FROM
		ArchiveClip
		
		INNER JOIN CustomCategory ON ArchiveClip.CategoryGUID = CustomCategory.CategoryGUID
		 
	WHERE
		ArchiveClip.CustomerID=@CustomerID AND ArchiveClip.IsActive = 1
		
		
END
