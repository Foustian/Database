-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_NB_PublicationCategory_SelectAll] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    
	SELECT
			NM_PublicationCategory.ID,
			NM_PublicationCategory.Name
	FROM
			NM_PublicationCategory
	WHERE
			IsActive=1
END
