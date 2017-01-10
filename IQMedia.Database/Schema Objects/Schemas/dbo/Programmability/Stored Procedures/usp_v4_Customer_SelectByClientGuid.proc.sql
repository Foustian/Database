-- =============================================
-- Author:		<Author,,Name>
-- Create date: 29 July 2013
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_Customer_SelectByClientGuid]
	@ClientGuid		UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

     SELECT
			CustomerKey,
			CustomerGUID,
			FirstName,
			LastName,
			Email,
			MultiLogin,
			DefaultPage,
			ContactNo
	FROM	Customer
		
	INNER JOIN  Client 
	ON Client.ClientKey = Customer.ClientID
	
	WHERE	Client.ClientGuid = @ClientGuid
	AND		Customer.IsActive = 1
	AND		Client.IsActive = 1	

END