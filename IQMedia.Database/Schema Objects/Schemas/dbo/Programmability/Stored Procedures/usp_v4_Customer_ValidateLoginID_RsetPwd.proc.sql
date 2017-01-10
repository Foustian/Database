CREATE PROCEDURE [dbo].[usp_v4_Customer_ValidateLoginID_RsetPwd]
(
	@LoginID	VARCHAR(300)
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @ISValid BIT = 0,
			@RsetPwdEmailCount TINYINT = 0,
			@Email VARCHAR(300)

	SELECT @ISValid = CASE WHEN EXISTS(SELECT 
						1
			   FROM
						Customer
							INNER JOIN Client
								ON Customer.ClientID = Client.ClientKey
								AND Customer.LoginID = @LoginID
				WHERE
						Customer.IsActive = 1
					AND	Client.IsActive = 1
			) THEN 1 ELSE 0 END

	SELECT
			@RsetPwdEmailCount = RsetPwdEmailCount,
			@Email = Email
	FROM
			Customer
	WHERE
			LoginID = @LoginID

	SELECT @ISValid AS ISValid, ISNULL(@RsetPwdEmailCount,0) AS RsetPwdEmailCount, @Email AS Email

END