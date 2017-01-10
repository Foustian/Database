-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_CustomCategory_Insert]
	
	@CategoryKey			BIGINT OUTPUT,
	@ClientGUID				UNIQUEIDENTIFIER,
	@CategoryName			VARCHAR(150),
	@CategoryDescription	VARCHAR(2000)

	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	

	DECLARE @Count AS INT
	
	SELECT @Count = COUNT(*) FROM CustomCategory WHERE CategoryName = @CategoryName AND ClientGUID = @ClientGUID AND IsActive = 1
	
	IF @Count > 0 
		BEGIN
		
			SET @CategoryKey = -1
		
		END
	ELSE
		BEGIN
	
			INSERT INTO CustomCategory
			(
				ClientGUID,
				CategoryName,
				CategoryDescription,
				CreatedDate,
				ModifiedDate,
				IsActive
			)
			VALUES
			(
				@ClientGUID,
				@CategoryName,
				@CategoryDescription,
				SYSDATETIME(),
				SYSDATETIME(),
				1
			)
			
			SET @CategoryKey = SCOPE_IDENTITY()
	
	END

END
