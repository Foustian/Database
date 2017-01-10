-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Customer_SelectByClientID]
	-- Add the parameters for the stored procedure here
	@ClientID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
	     CustomerKey,
	     FirstName,
	     LastName,
	     CustomerPassword,
	     Email,
	     --RedlassoUserName,
	     --RedlassoPassword,
	     CustomerGUID
    FROM
        Customer
    WHERE
		ClientID = @ClientID
END
