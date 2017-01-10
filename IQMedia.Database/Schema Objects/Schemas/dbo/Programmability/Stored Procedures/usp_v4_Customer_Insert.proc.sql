CREATE PROCEDURE [dbo].[usp_v4_Customer_Insert]
	-- Add the parameters for the stored procedure here
	@CustomerKey		int out,
	@FirstName			varchar(50),
	@LastName			varchar(50),
	@Email				varchar(50),
	@LoginID			varchar(50),
	--@MasterCustomerID	bigint,
	@CustomerPassword	varchar(60),
	@CustomerGUID		uniqueidentifier,
	@ContactNo			varchar(50),
	@IsMultiLogin		bit,
	@ClientID			bigint,
	@DefaultPage varchar(50),
	@Comments			varchar(300),
	@CreatedBy			varchar(50),
	@CustomerRoles		Xml,
	@IsActive bit,
	@IsFliqCustomer		bit,
	@DefaultCategory	varchar(500)
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
		Customer.LoginID = @LoginID

	DECLARE @IsFliqAllowed bit
	SET @IsFliqAllowed	 = 1
		
	IF @EmailCount=0
	BEGIN
		IF (@IsFliqCustomer = 1 AND NOT EXISTS(SELECT 1 from Client Where ClientKey = @ClientID and IsActive = 1 and IsFliq = 1))
		BEGIN
			SET @IsFliqAllowed = 0
		END

		IF(@IsFliqAllowed = 1)
		BEGIN
			INSERT INTO Customer 
				(
					FirstName,
					LastName,
					Email,
					LoginID,
					--MasterCustomerID,
					CustomerPassword,
					ContactNo,
					MultiLogin,
					CustomerComment,
					CustomerGUID,
					ClientID,
					DefaultPage,
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
					@LoginID,
					--@MasterCustomerID,
					@CustomerPassword,
					@ContactNo,
					@IsMultiLogin,
					@Comments,
					@CustomerGUID,
					@ClientID,
					@DefaultPage,
					@CreatedBy,
					@CreatedBy,
					SYSDATETIME(),
					SYSDATETIME(),
					@IsActive
				)
			SELECT @CustomerKey = SCOPE_IDENTITY()	

			IF(@IsFliqCustomer = 1)
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
					CustomerGUID,
					_CustomerID
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
					@CustomerGUID,
					@CustomerKey
				)
			END

			if(@CustomerRoles is not null)
			BEGIN
				INSERT INTO	
					CustomerRole
					(
						CustomerID,
						RoleID,
						IsAccess,
						CreatedBy,
						ModifiedBy,
						CreatedDate,
						ModifiedDate
					)
				SELECT 
						@CustomerKey,
						tblXml.c.value('.','bigint'),
						1,
						'System',
						'System',
						SYSDATETIME(),
						SYSDATETIME()
				FROM 
					@CustomerRoles.nodes('/Roles/Role') as tblXml(c)
			END
		END
		ELSE
		BEGIN
			SET @CustomerKey = -1
		END
	END
	ELSE 
	BEGIN
		SET @CustomerKey = 0
	END
END
