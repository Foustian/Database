-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Client_SelectUGCFtpUploadLocationByClientID] 	
	(
		@ClientID bigint
	)
AS
BEGIN	
	SET NOCOUNT ON;
    
    SELECT
		 UGCFtpUploadLocation
	FROM
		Client
	WHERE
		ClientKey = @ClientID and
		IsActive = 1
		
END
