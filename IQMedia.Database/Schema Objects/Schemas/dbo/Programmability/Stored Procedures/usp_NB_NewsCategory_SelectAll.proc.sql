-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_NB_NewsCategory_SelectAll] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    
	SELECT
			NM_NewsCategory.ID,
			NM_NewsCategory.Name
	FROM
			NM_NewsCategory
	WHERE
			IsActive=1
END
