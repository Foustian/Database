-- =============================================
-- Author:		<Author,,Name>
-- Create date: 16 July 2013
-- Description:	Update record CustomCategory
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_CustomCategory_Update]
	@CategoryKey			BIGINT,
	@ClientGuid				UNIQUEIDENTIFIER,
	@CategoryName			VARCHAR(150),
	@CategoryDescription	VARCHAR(2000),
	@Flag					INT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF NOT EXISTS ( SELECT 1 FROM CustomCategory 
					WHERE	ClientGuid = @ClientGuid 
					AND		CategoryName = @CategoryName
					AND		CategoryKey <> @CategoryKey
					AND		IsActive = 1 )
		BEGIN
		
			UPDATE CustomCategory
			SET		CategoryName = @CategoryName,
					CategoryDescription = @CategoryDescription,
					ModifiedDate = GETDATE()
			WHERE	CategoryKey = @CategoryKey
			AND		IsActive = 1
			AND		ClientGuid = @ClientGuid 
			
			SET @Flag = 1
		
		END
	ELSE
		BEGIN
			SET @Flag = -1
		END

END
