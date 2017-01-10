-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ContactUS_Insert]
	-- Add the parameters for the stored procedure here
	@FirstName varchar(50),
	@LastName varchar(50),
	@Email varchar(300),
	@ContactNo varchar(50),
	@CompanyName varchar(50),
	@Title varchar(50),
	@Comments varchar(500),
	@ContactUsInfo xml,
	@ContactUsKey int out
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    INSERT INTO	
			ContactUs
			(
				FirstName,
				LastName,
				Email,
				TelephoneNo,
				CompanyName,
				Title,
				Comments,
				ModifiedBy,
				CreatedBy,
				ContactUsInfo
			)
		VALUES
			(
				@FirstName,
				@LastName,
				@Email,
				@ContactNo,
				@CompanyName,
				@Title,
				@Comments,
				'System',
				'System',
				@ContactUsInfo
			)
		SELECT @ContactUsKey=SCOPE_IDENTITY()
		
END
