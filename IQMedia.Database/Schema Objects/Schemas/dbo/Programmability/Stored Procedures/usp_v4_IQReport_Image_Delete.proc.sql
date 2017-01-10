CREATE PROCEDURE [dbo].[usp_v4_IQClient_CustomImage_Delete]
(
	@ID bigint,
	@ClientGuid uniqueidentifier,
	@Output int output
)
AS
BEGIN

	UPDATE 
			IQClient_CustomImage 
	SET 
			IsActive = 0,
			ModifiedDate = GETDATE()
	WHERE 
			ID = @ID
			AND _ClientGUID = @ClientGuid
			AND IsDefault = 0 AND IsDefaultEmail = 0

	SET @Output = @@ROWCOUNT
END
