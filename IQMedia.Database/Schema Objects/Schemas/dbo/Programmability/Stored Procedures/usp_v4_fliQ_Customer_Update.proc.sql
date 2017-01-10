CREATE PROCEDURE [dbo].[usp_v4_fliQ_Customer_Update]
	@CustomerKey int,
	@FirstName varchar(50),
	@LastName varchar(50),
	@Email varchar(50),
	@LoginID			varchar(50),
	@CustomerPassword varchar(60),
	@ContactNo varchar(50),
	@ModifiedDate datetime,
	@Comments		varchar(300),
	@ClientID int,
	@IsActive bit,
	@Status int output
AS
BEGIN
	DECLARE @EmailCount INT
    -- Insert statements for procedure here
    SELECT
		@EmailCount = COUNT(*)
	FROM
		fliQ_Customer
	WHERE
		fliQ_Customer.LoginID = @LoginID and
		fliQ_Customer.CustomerKey!=@CustomerKey

	IF @EmailCount=0
	BEGIN
		IF EXISTS(SELECT 1 from Client Where ClientKey = @ClientID and IsActive = 1 and IsFliq = 1)
		BEGIN
			UPDATE
					fliQ_Customer
			SET
					FirstName=@FirstName,
					LastName=@LastName,
					Email=@Email,
					LoginID = @LoginID,
					CustomerPassword=CASE WHEN ISNULL(@CustomerPassword,'')='' THEN CustomerPassword ELSE @CustomerPassword END,
					ContactNo=@ContactNo,
					CustomerComment =  @Comments,
					ModifiedDate = @ModifiedDate,
					ClientID = @ClientID,
					IsActive = @IsActive
			WHERE
					CustomerKey = @CustomerKey

			SET @Status= @@ROWCOUNT
		END
		ELSE 
		BEGIN
			SET @Status=-1
		END
	END
	ELSE
	BEGIN
		SET @Status=0
	END
END