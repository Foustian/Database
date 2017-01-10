-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ContactUs_Update]
	-- Add the parameters for the stored procedure here
	@ContactUsContent varchar(max),
	@ContactUsKey int output
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    UPDATE
		ContactUs
	SET
		ContactUsText = @ContactUsContent
	WHERE
		ContactUsKey = 1
	SELECT @ContactUsKey = ContactUsKey FROM ContactUs WHERE ContactUsKey = 1
	
END
