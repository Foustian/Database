-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_NB_Genre_SelectAll] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    
	SELECT
			NM_Genre.ID,
			NM_Genre.Name,
			NM_Genre.Label
	FROM
			NM_Genre
	WHERE
			IsActive=1
END
