CREATE PROCEDURE [dbo].[usp_V5_Group_Customer_SelectByClient]
(
	@CID	BIGINT,
	@CustID	BIGINT	
)
AS
BEGIN

	SET NOCOUNT ON;
	
	IF(@CustID IS NULL)
		BEGIN
		
			SELECT	
					FirstName,
					LastName,
					CustomerKey
			FROM
					Customer
			WHERE
					Customer.ClientID = @CID
				AND	Customer.IsActive = 1
				AND	Customer.MasterCustomerID IS NULL					
		
		END
	ELSE
		BEGIN
		
			DECLARE @FN VARCHAR(50),
					@LN	VARCHAR(50)
		
			SELECT
					@FN = FirstName,
					@LN = LastName
			FROM
					Customer
			WHERE
					Customer.CustomerKey = @CustID
					
			SELECT	
					FirstName,
					LastName,
					CustomerKey
			FROM
					Customer
			WHERE
					Customer.ClientID = @CID				
				AND	Customer.IsActive = 1
				AND	Customer.MasterCustomerID IS NULL
				AND	Customer.FirstName = @FN
				AND	Customer.LastName = @LN
					
		
		END

END