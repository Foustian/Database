-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

-- EXEC [dbo].[usp_CustomCategory_Update] 20,'a','aaaaaaaaaaaaaaaaa'

CREATE PROCEDURE [dbo].[usp_CustomCategory_Update]
	
	@CategoryKey			BIGINT,
	@CategoryName			VARCHAR(150),
	@CategoryDescription	VARCHAR(2000),
	@ClientGUID				UniqueIdentifier,
	@Status					INT OUTPUT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

	DECLARE @Count AS INT
	
	SELECT @Count = COUNT(*) FROM CustomCategory WHERE CategoryName = @CategoryName AND ClientGUID = @ClientGUID AND IsActive = 1 AND CategoryKey <> @CategoryKey
	
	IF @Count > 0 
		BEGIN
			SET @Status = -1
		END
	ELSE
		BEGIN

			UPDATE CustomCategory
			SET
				CategoryName = @CategoryName,
				CategoryDescription = @CategoryDescription,
				ModifiedDate = SYSDATETIME()
			WHERE
				CategoryKey = @CategoryKey

			SET @Status = 0

		END

END
