CREATE PROCEDURE usp_v4_Customer_SelectForAuthentication
(
	@LoginID	varchar(300)
)
AS
BEGIN	
	SET NOCOUNT ON;

    Select
			CustomerPassword,
			PasswordAttempts
	From
			[Customer]
				INNER JOIN	[Client]
					ON	[Customer].ClientID=[Client].ClientKey
	Where
			LoginID=@LoginID AND DATALENGTH(Customer.LoginID)=DATALENGTH(@LoginID)
		AND	Customer.IsActive = 1
		AND	Customer.MasterCustomerID IS NULL
		AND	Client.IsActive=1

END
