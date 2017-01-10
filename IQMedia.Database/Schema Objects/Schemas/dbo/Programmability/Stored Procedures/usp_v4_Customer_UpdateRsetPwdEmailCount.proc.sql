CREATE PROCEDURE [dbo].[usp_v4_Customer_UpdateRsetPwdEmailCount]
(
	@LoginID	VARCHAR(300)	
)
AS
BEGIN

	SET NOCOUNT ON;

	UPDATE
			Customer
	SET
			RsetPwdEmailCount = RsetPwdEmailCount + 1
	WHERE
			LoginID = @LoginID
		AND	IsActive = 1

END