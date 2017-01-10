-- =============================================
-- Author:		<Author,,Name>
-- Create date: 16 July 2013
-- Description:	Insert new record into CustomCategory
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_CustomCategory_Insert]
	@ClientGuid				UNIQUEIDENTIFIER,
	@CategoryName			VARCHAR(150),
	@CategoryDescription	VARCHAR(2000),
	@CategoryKey			BIGINT	OUTPUT				
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @CategoryRanking INT
	
	IF NOT EXISTS ( SELECT 1 FROM dbo.CustomCategory 
					WHERE ClientGuid = @ClientGuid 
					AND CategoryName = @CategoryName
					AND IsActive = 1 )
		BEGIN

			SELECT	@CategoryRanking = ISNULL(MAX(CategoryRanking), -1) + 1
			FROM	CustomCategory
			WHERE	ClientGuid = @ClientGuid
					AND IsActive = 1
		
			INSERT INTO dbo.CustomCategory
			(
				ClientGUID,
				CategoryGUID,
				CategoryName,
				CategoryDescription,
				CreatedDate,
				ModifiedDate,
				IsActive,
				CategoryRanking
			)
			VALUES
			(
				@ClientGuid,
				NEWID(),
				@CategoryName,
				@CategoryDescription,
				GETDATE(),
				GETDATE(),
				1,
				@CategoryRanking
			)
			
			SET @CategoryKey = SCOPE_IDENTITY()
		
		END
	ELSE
		BEGIN
			SET @CategoryKey = -1
		END

END
