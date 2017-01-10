-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQNotificationSettings_SelectBySearchRequestID]
	
	@SearchRequestID int
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT
	     *
    FROM
    
        IQNotificationSettings
        
    WHERE
    
		SearchRequestID = @SearchRequestID
		and IsActive=1
END

