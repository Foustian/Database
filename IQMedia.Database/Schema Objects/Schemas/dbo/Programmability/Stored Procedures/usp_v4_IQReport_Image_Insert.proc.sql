CREATE PROCEDURE [dbo].[usp_v4_IQClient_CustomImage_Insert]
	@ClientGUID		uniqueidentifier,
	@Image			varchar(255),
	@IsDefault		bit,
	@IsDefaultEmail	bit,
	@IsReplace		bit,
	@Output			BIGINT OUTPUT
AS
BEGIN
	
	DECLARE @UpdateID bit

	SET @UpdateID = 0

	IF(@IsReplace = 1)
	BEGIN
		SELECT @UpdateID = ID FROM IQClient_CustomImage Where LOWER([Location]) = LOWER(@Image) And _ClientGUID = @ClientGUID And IsActive = 1
	END

	IF(@IsDefault = 1)
	BEGIN
		UPDATE 
			IQClient_CustomImage
		SET
			IsDefault = 0,
			ModifiedDate = GETDATE() 
		WHERE
			_ClientGUID = @ClientGUID
			AND IsDefault = 1
	END

	IF(@IsDefaultEmail = 1)
	BEGIN
		UPDATE 
			IQClient_CustomImage
		SET
			IsDefaultEmail = 0 ,
			ModifiedDate = GETDATE()
		WHERE
			_ClientGUID = @ClientGUID
			AND IsDefaultEmail = 1
	END

	IF(@UpdateID = 0)
	BEGIN
		INSERT INTO IQClient_CustomImage
		(
			_ClientGUID,
			[Location],
			IsDefault,
			IsDefaultEmail,
			IsActive,
			ModifiedDate
		)
		VALUES
		(
			@ClientGUID,
			@Image,
			@IsDefault,
			@IsDefaultEmail,
			1,
			SYSDATETIME()
		)

		SET @Output = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		
		UPDATE 
				IQClient_CustomImage
		SET
				ModifiedDate = SYSDATETIME(),
				IsDefault = @IsDefault,
				IsDefaultEmail = @IsDefaultEmail
				
		WHERE ID = @UpdateID AND _ClientGUID = @ClientGUID

		SET @Output = @UpdateID
	END
END