-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_CustomCategory_SelectByClientID]
	
	@ClientID		BIGINT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @ClientGUID AS VARCHAR(50)
	
	SELECT @ClientGUID = ClientGUID FROM Client WHERE ClientKey = @ClientID

	SELECT 
			CategoryKey,
			CategoryName,
			CategoryDescription,
			CategoryGUID,
			ClientGUID
	FROM
			CustomCategory
	WHERE
			ClientGUID = @ClientGUID
    AND		IsActive = 1
    order by CategoryName 
END
