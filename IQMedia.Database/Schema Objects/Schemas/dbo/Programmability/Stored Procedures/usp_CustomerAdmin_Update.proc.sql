-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_CustomerAdmin_Update] 
	-- Add the parameters for the stored procedure here
	@CustomerKey int,
	@FirstName varchar(50),
	@LastName varchar(50),
	@Email varchar(50),
	@CustomerPassword varchar(30),
	@ContactNo varchar(50),
	@CustomerComment varchar(300),
	@ModifiedDate datetime,
	--@ClientName varchar(50),
	--@RedlassoUserName varchar(50),
	--@RedlassoPassword varchar(50),
	--@RedlassoGUID varchar(50),
	--@ClientID int,
	@IsActive bit,
	@DefaultPage varchar(50),
	@MultiLogin	bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;

    -- Insert statements for procedure here
    SET NOCOUNT OFF;
	DECLARE @EmailCount INT
    -- Insert statements for procedure here
    SELECT
		@EmailCount = COUNT(*)
	FROM
		Customer
	WHERE
		Customer.Email = @Email and
		Customer.CustomerKey!=@CustomerKey
		
	IF @EmailCount=0
	BEGIN
    
    UPDATE Customer
    SET
		FirstName=@FirstName,
		LastName=@LastName,
		Email=@Email,
		CustomerPassword=@CustomerPassword,
		ContactNo=@ContactNo,
		CustomerComment = @CustomerComment,
		ModifiedDate = @ModifiedDate,
		--RedlassoUserName=@RedlassoUserName,
		--RedlassoPassword=@RedlassoPassword,
		--RedlassoUserGUID=@RedlassoGUID,
		IsActive = @IsActive,
		DefaultPage=@DefaultPage,
		MultiLogin=@MultiLogin
		--ClientID = @ClientID
	WHERE
		CustomerKey=@CustomerKey
		
	--UPDATE Client
	--SET
	--	ClientName=@ClientName
	--WHERE
	--	ClientKey= @ClientID
	
	END
	
	ELSE
		Begin
		SET @CustomerKey=0
		end
END
