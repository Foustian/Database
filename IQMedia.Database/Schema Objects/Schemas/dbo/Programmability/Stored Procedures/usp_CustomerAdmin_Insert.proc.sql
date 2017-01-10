-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_CustomerAdmin_Insert]
	-- Add the parameters for the stored procedure here
	@CustomerKey int out,
	@FirstName varchar(50),
	@LastName varchar(50),
	@Email varchar(50),
	@CustomerPassword varchar(30),
	@ContactNo varchar(50),
	@Comments varchar(300),
	@ClientID int,
	--@RedlassoUserName varchar(50),
	--@RedlassoPassword varchar(50),
	--@RedlassoGUID varchar(50),
	@CustomerGUID uniqueidentifier,
	@DefaultPage varchar(50),
	@MultiLogin	bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @EmailCount INT
	
	 SELECT
		@EmailCount = COUNT(*)
	FROM
		Customer
	WHERE
		Customer.Email = @Email
		
	IF @EmailCount=0
	BEGIN
	
	--DECLARE @ClientKey INT
	--EXEC usp_Client_Insert @ClientName,@ClientKey output
	
	INSERT INTO Customer 
				(
					FirstName,
					LastName,
					Email,
					CustomerPassword,
					ContactNo,
					CustomerComment,
					CreatedDate,
					ModifiedDate,
					IsActive,
					--RedlassoUserName,
					--RedlassoPassword,
					--RedlassoUserGUID,
					ClientID,
					CustomerGUID,
					DefaultPage,
					MultiLogin
				)
				VALUES 
				(
					@FirstName,
					@LastName,
					@Email,
					@CustomerPassword,
					@ContactNo,
					@Comments,
					SYSDATETIME(),
					SYSDATETIME(),
					1,
					--@RedlassoUserName,
					--@RedlassoPassword,
					--@RedlassoGUID,
					@ClientID,
					@CustomerGUID,
					@DefaultPage,
					@MultiLogin
				)
		SELECT @CustomerKey = SCOPE_IDENTITY()
		END
		ELSE
			SET	@CustomerKey = 0
    -- Insert statements for procedure here
    
END
