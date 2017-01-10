CREATE PROCEDURE [dbo].[usp_V5_Group_Customer_AddSubCustomer]
(
	@GroupID	BIGINT,
	@MCID		BIGINT,
	@MasterCustomerID	BIGINT,
	@SCID		BIGINT,
	@SubCustomerID	BIGINT,
	@CustomerGUID	UNIQUEIDENTIFIER,
	@Output		BIT OUTPUT
)
AS
BEGIN

	SET NOCOUNT ON;

	SET @Output = 0

	IF EXISTS(SELECT ClientKey FROM Client WHERE Client.ClientKey = @GroupID AND Client.MCID = @GroupID AND Client.IsActive=1)
		BEGIN
			IF EXISTS(SELECT ClientKey FROM Client WHERE Client.ClientKey = @MCID AND Client.MCID = @GroupID AND Client.IsActive=1)
				BEGIN
					IF EXISTS(SELECT ClientKey FROM Client WHERE Client.ClientKey = @SCID AND Client.MCID = @GroupID AND Client.IsActive=1)
						BEGIN
							IF EXISTS(SELECT CustomerKey FROM Customer WHERE Customer.CustomerKey = @MasterCustomerID AND Customer.ClientID = @MCID AND IsActive=1)
								BEGIN
									IF EXISTS(SELECT CustomerKey FROM Customer WHERE Customer.CustomerKey = @SubCustomerID AND Customer.ClientID = @SCID AND IsActive=1)
										BEGIN
											UPDATE
													Customer
											SET
													MasterCustomerID = @MasterCustomerID,
													ModifiedDate = GETDATE(),
													ModifiedBy = @CustomerGUID
											WHERE
													CustomerKey = @SubCustomerID

											SET @Output = 1
										END
								END
						END
				END
		END

END