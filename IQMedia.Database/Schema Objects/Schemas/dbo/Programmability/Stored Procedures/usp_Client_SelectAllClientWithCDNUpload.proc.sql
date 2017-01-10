-- =============================================
-- Create date: 20/Feb/2012
-- Description:	Get CDNUpload enebled client
-- =============================================
CREATE PROCEDURE [dbo].[usp_Client_SelectAllClientWithCDNUpload]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    Select 
		Clientkey,
		ClientName,
		ClientGUID,
		CDNUpload 
    from 
		Client 
    where 
		IsActive = 1
    
END
