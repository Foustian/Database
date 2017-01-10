CREATE PROCEDURE [dbo].[usp_v4_fliQ_Customer_Insert]
	@CustomerKey		int out,
	@FirstName			varchar(50),
	@LastName			varchar(50),
	@Email				varchar(50),
	@LoginID			varchar(50),
	@CustomerPassword	varchar(60),
	@CustomerGUID		uniqueidentifier,
	@ContactNo			varchar(50),
	@ClientID			bigint,
	@Comments			varchar(300),
	@CreatedBy			varchar(50),
	@IsActive bit,
	@DefaultCategory	varchar(500)
AS
BEGIN 

	DECLARE @EmailCount INT
    -- Insert statements for procedure here
    SELECT
		@EmailCount = COUNT(*)
	FROM
		fliQ_Customer
	WHERE
		fliQ_Customer.LoginID = @LoginID

	IF @EmailCount=0
	BEGIN

		INSERT INTO fliQ_Customer
		(
			FirstName,
			LastName,
			LoginID,
			Email,
			CustomerPassword,
			ContactNo,
			CustomerComment,
			ClientID,
			CreatedDate,
			ModifiedDate,
			IsActive,
			CustomerGUID
		)
		Values
		(
			@FirstName,
			@LastName,
			@LoginID,
			@Email,
			@CustomerPassword,
			@ContactNo,
			@Comments,
			@ClientID,
			GETDATE(),
			GETDATE(),
			@IsActive,
			@CustomerGUID
		)

		SET @CustomerKey = SCOPE_IDENTITY()	
	END
	ELSE
	BEGIN
		SET @CustomerKey = 0
	END
END