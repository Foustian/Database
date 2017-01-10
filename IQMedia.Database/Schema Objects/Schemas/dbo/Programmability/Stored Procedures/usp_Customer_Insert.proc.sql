-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Customer_Insert]
	-- Add the parameters for the stored procedure here
	@CustomerKey		int out,
	@FirstName			varchar(50),
	@LastName			varchar(50),
	@Email				varchar(50),
	@CustomerPassword	varchar(30),
	@CustomerGUID		uniqueidentifier,
	@ContactNo			varchar(50),
	@Comments			varchar(300),
	@CreatedBy			varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @EmailCount INT
    -- Insert statements for procedure here
    SELECT
		@EmailCount = COUNT(*)
	FROM
		Customer
	WHERE
		Customer.Email = @Email
		
		
	IF @EmailCount=0
	BEGIN
		INSERT INTO Customer 
				(
					FirstName,
					LastName,
					Email,
					CustomerPassword,
					ContactNo,
					CustomerComment,
					CustomerGUID,
					CreatedBy,
					ModifiedBy,
					CreatedDate,
					ModifiedDate,
					IsActive
				)
				VALUES 
				(
					@FirstName,
					@LastName,
					@Email,
					@CustomerPassword,
					@ContactNo,
					@Comments,
					@CustomerGUID,
					@CreatedBy,
					@CreatedBy,
					SYSDATETIME(),
					SYSDATETIME(),
					1
				)
		SELECT @CustomerKey = SCOPE_IDENTITY()
			END
		
		

    
END
