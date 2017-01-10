CREATE PROCEDURE [dbo].[usp_ArchiveTweets_Insert]
	@Title				varchar(250),
	@Keywords 			varchar(500),
	@Description 		varchar(1000),
	@CustomerGuid		uniqueidentifier,
	@ClientGuid			uniqueidentifier,
	@CategoryGuid		uniqueidentifier,
	@SubCategory1Guid	uniqueidentifier,
	@SubCategory2Guid	uniqueidentifier,
	@SubCategory3Guid	uniqueidentifier,
	@Tweet_ID			bigint,
	@Actor_DisplayName	nvarchar(20),
	@Actor_PreferredUserName		nvarchar(15),
	@Tweet_Body			nvarchar(max),
	@Actor_FollowersCount	bigint,
	@Actor_FriendsCount		bigint,
	@Actor_Image		varchar(max),
	@Actor_link			varchar(max),
	@gnip_Klout_Score	bigint,
	@Tweet_PostedDateTime	datetime,
	@Rating				tinyint,
	@ArchiveTweetKey	bigint output
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		IF NOT EXISTS(SELECT Tweet_ID FROM ArchiveTweets Where Tweet_ID = @Tweet_ID and CustomerGuid = @CustomerGuid AND IsActive=1)
		BEGIN
			INSERT INTO 
				ArchiveTweets
				(
					Title,
					Keywords,
					[Description],
					CustomerGUID,
					ClientGUID,
					CategoryGuid,
					SubCategory1Guid,
					SubCategory2Guid,
					SubCategory3Guid,
					Tweet_ID,
					Actor_DisplayName,
					Actor_PreferredUserName,
					Tweet_Body,
					Actor_FollowersCount,
					Actor_FriendsCount,
					Actor_Image,
					Actor_link,
					gnip_Klout_Score,
					Tweet_PostedDateTime,
					Rating,
					ModifiedDate
				)
				Values
				(
					@Title,
					@Keywords,
					@Description,
					@CustomerGuid,
					@ClientGuid,
					@CategoryGuid,
					@SubCategory1Guid,
					@SubCategory2Guid,
					@SubCategory3Guid,
					@Tweet_ID,
					@Actor_DisplayName,
					@Actor_PreferredUserName,
					@Tweet_Body,
					@Actor_FollowersCount,
					@Actor_FriendsCount,
					@Actor_Image,
					@Actor_link,
					@gnip_Klout_Score,
					@Tweet_PostedDateTime,
					@Rating,
					GETDATE()
				)

			SELECT @ArchiveTweetKey = SCOPE_IDENTITY()
			COMMIT TRANSACTION 
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION
			SELECT  @ArchiveTweetKey = -1
		END
		END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		
		DECLARE @IQMediaGroupExceptionKey bigint,
				@ExceptionStackTrace varchar(500),
				@ExceptionMessage varchar(500),
				@CreatedBy	varchar(50),
				@ModifiedBy	varchar(50),
				@CreatedDate	datetime,
				@ModifiedDate	datetime,
				@IsActive	bit
				
		
		SELECT 
				@ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(varchar(50),ERROR_LINE())),
				@ExceptionMessage=convert(varchar(50),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
				@CreatedBy='usp_ArchiveTweets_Insert',
				@ModifiedBy='usp_ArchiveTweets_Insert',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		SET @ArchiveTweetKey = 0
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@ModifiedBy,@CreatedDate,@ModifiedDate,@IsActive,@IQMediaGroupExceptionKey output
		
	END CATCH
END
