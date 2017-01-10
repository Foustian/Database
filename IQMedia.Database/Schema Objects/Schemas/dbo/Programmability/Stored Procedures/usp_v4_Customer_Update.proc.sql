CREATE PROCEDURE [dbo].[usp_v4_Customer_Update]
(
	@CustomerKey int,
	@FirstName varchar(50),
	@LastName varchar(50),
	@Email varchar(50),
	@LoginID			varchar(50),
	--@MasterCustomerID	bigint,
	@CustomerPassword varchar(60),
	@ContactNo varchar(50),
	@IsMultiLogin	bit,
	@DefaultPage varchar(50),
	@ModifiedDate datetime,
	@Comments		varchar(300),
	@ClientID int,
	@IsActive bit,
	@CustomerRoles		Xml,
	@IsFliqCustomer		bit,
	@DefaultCategory	varchar(500),
	@Status int output
)
AS
BEGIN
	
    SET NOCOUNT OFF;
	DECLARE @EmailCount INT
    -- Insert statements for procedure here
    SELECT
		@EmailCount = COUNT(*)
	FROM
		Customer
	WHERE
		Customer.LoginID = @LoginID and
		Customer.CustomerKey!=@CustomerKey

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
			UPDATE Customer
			SET
				FirstName=@FirstName,
				LastName=@LastName,
				Email=@Email,
				LoginID = @LoginID,
				--MasterCustomerID = @MasterCustomerID,
				CustomerPassword= CASE WHEN ISNULL(@CustomerPassword,'')='' THEN CustomerPassword ELSE @CustomerPassword END,
				ContactNo=@ContactNo,
				CustomerComment =  @Comments,
				ModifiedDate = @ModifiedDate,
				DefaultPage=@DefaultPage,
				MultiLogin = @IsMultiLogin,
				ClientID = @ClientID,
				IsActive = @IsActive
			WHERE
				CustomerKey=@CustomerKey

			IF(@IsFliqCustomer  = 1)
			BEGIN
				IF EXISTS(SELECT 1 from fliQ_Customer Where _CustomerID = @CustomerKey)
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
							_CustomerID = @CustomerKey
				END
				ELSE
				BEGIN
					DECLARE @CustomerGUID uniqueidentifier

					SELECT 
							@CustomerGUID = Customer.CustomerGUID,
							@CustomerPassword = Customer.CustomerPassword
					FROM 
							Customer		
					Where 
							Customer.CustomerKey = @CustomerKey

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
			END
			ELSE
			BEGIN
				UPDATE
						fliQ_Customer
				SET
						IsActive  = 0
				WHERE
						_CustomerID = @CustomerKey
						AND IsActive  = 1
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
					@CustomerRoles.nodes('/Roles/Role') as tblXml(c) Left Outer Join  
						CustomerRole
						ON tblXml.c.value('.','bigint')  = CustomerRole.RoleID 
						AND CustomerRole.CustomerID = @CustomerKey
				WHERE
					CustomerRole.RoleID IS NULL

				UPDATE
					CustomerRole
				SET
					IsAccess = 1 ,
					ModifiedDate = @ModifiedDate
				FROM
					@CustomerRoles.nodes('/Roles/Role') as tblXml(c) INNER Join  
						CustomerRole
						ON tblXml.c.value('.','bigint')  = CustomerRole.RoleID 
						AND CustomerRole.CustomerID = @CustomerKey

				UPDATE
					CustomerRole
				SET
					IsAccess = 0 ,
					ModifiedDate = @ModifiedDate
				FROM
					@CustomerRoles.nodes('/Roles/Role') as tblXml(c) RIGHT OUTER Join  
						CustomerRole
						ON tblXml.c.value('.','bigint')  = CustomerRole.RoleID 
			
				WHERE 
					tblXml.c.value('.','bigint') IS NULL
					AND CustomerRole.CustomerID = @CustomerKey
					AND CustomerRole.RoleID != 3
			END
		END
		ELSE
		BEGIN
			SET @Status=-1
		END
	
	END
	ELSE
	Begin
		SET @Status=0
	end
END
