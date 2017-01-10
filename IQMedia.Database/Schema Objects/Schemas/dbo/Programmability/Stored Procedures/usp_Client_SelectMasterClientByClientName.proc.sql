-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Client_SelectMasterClientByClientName] 
	-- Add the parameters for the stored procedure here
	(
		@ClientName varchar(100)
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    SELECT
		 ClientKey,
		 ClientName,
		 MasterClient
	FROM
		Client
	WHERE
		ClientName = @ClientName and
		IsActive = 1
		
END
