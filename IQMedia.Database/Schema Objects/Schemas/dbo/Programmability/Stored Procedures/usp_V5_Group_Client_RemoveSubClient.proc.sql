CREATE PROCEDURE [dbo].[usp_V5_Group_Client_RemoveSubClient]
(
	@MCID	BIGINT,
	@SCID	BIGINT,
	@CustomerGUID	UNIQUEIDENTIFIER
)
AS
BEGIN

	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	IF EXISTS(SELECT ClientKey FROM Client WHERE ClientKey = @MCID AND MCID = @MCID AND IsActive = 1)
		BEGIN
			
			IF EXISTS(SELECT ClientKey FROM Client WHERE ClientKey = @SCID AND MCID = @MCID AND IsActive = 1)
				BEGIN
					
						BEGIN TRANSACTION

							UPDATE
									Customer
							SET
									MasterCustomerID = NULL,
									ModifiedDate = GETDATE(),
									ModifiedBy = @CustomerGUID
							FROM
									Customer
											INNER JOIN	Client
													ON	Customer.ClientID = Client.ClientKey
													AND	Client.MCID = @SCID
													AND	Customer.IsActive = 1

							UPDATE
									Customer
							SET
									MasterCustomerID = NULL,
									ModifiedDate = GETDATE(),
									ModifiedBy = @CustomerGUID
							FROM
									Customer
											INNER JOIN	Client
													ON	Customer.ClientID = Client.ClientKey
													AND	Client.ClientKey = @SCID
													AND	Customer.IsActive = 1

							UPDATE 
									Client
							SET
									MCID = ClientKey,
									ModifiedDate = GETDATE(),
									ModifiedBy = @CustomerGUID
							WHERE
									ClientKey = @SCID																				

							

						COMMIT TRANSACTION						

				END

		END

END