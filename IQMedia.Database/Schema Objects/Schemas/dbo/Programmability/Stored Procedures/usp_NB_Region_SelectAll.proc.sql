-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_NB_Region_SelectAll] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    
	SELECT
			NM_Region.ID,
			NM_Region.Name,
			NM_Region.Label
	FROM
			NM_Region
	WHERE
			IsActive=1
			
	ORDER BY
			NM_Region.Order_Number
END
