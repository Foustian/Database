-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_PromotionalVideo_SelectByPageName]
	-- Add the parameters for the stored procedure here
	@PageName varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    SELECT	
			PromotionalVideoKey
			FilePath,
			DisplayPageName,
			IsDisplay,
			IsActive,
			SrcPath,
			MoviePath,
			Position
	FROM
		PromotionalVideo 
	WHERE
		DisplayPageName = @PageName
END
