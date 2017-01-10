-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_MediaCategory_SelectAll] 
	-- Add the parameters for the stored procedure here
		
AS
BEGIN

	SET NOCOUNT ON;
    SELECT
		CategoryName,
		CategoryCode,
		MediaCategoryKey
		
	FROM
		MediaCategory
	WHERE
		IsActive=1
	order by CategoryCode ASC
END
