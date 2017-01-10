-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Customer_SelectByFirstName]
	-- Add the parameters for the stored procedure here
	@Email varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
	     CustomerKey,
	     FirstName,
	     ClientName,
	     Email
    FROM
		 Customer
			INNER JOIN
		 Client 
	ON
		Client.ClientKey = Customer.ClientID  
	
	WHERE Customer.Email =@Email and Client.IsActive=1 and Customer.IsActive=1 
		
	ORDER BY Email
END
