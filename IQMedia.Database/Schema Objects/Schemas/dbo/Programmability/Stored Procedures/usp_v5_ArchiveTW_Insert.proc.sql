-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_v5_ArchiveTW_Insert]	
	@CustomerGuid		uniqueidentifier,
	@ClientGuid			uniqueidentifier,
	@Actor_PreferredUserName		nvarchar(15),
	@Tweet_Body			nvarchar(max),
	@Actor_FollowersCount	bigint,
	@Actor_FriendsCount		bigint,
	@Actor_Image		varchar(max),
	@Actor_link			varchar(max),
	@gnip_Klout_Score	bigint,
	@Tweet_PostedDateTime	datetime,
	@Tweet_ID varchar(max),
	@Actor_DisplayName varchar(max),
	@CategoryGuid		uniqueidentifier,
	@PositiveSentiment tinyint,
	@NegativeSentiment tinyint,
	@MediaID bigint,
	@HighLightText nvarchar(max),
	@SearchTerm varchar(500),
	@Number_Hits tinyint,
	@Keywords varchar(2048),
	@Description varchar(2048),
	@MediaType varchar(2),
	@SubMediaType varchar(50),
	@ArchiveKey			bigint output
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	declare @rpID int
	Declare @ArchiveKeyBkp bigint
	
	BEGIN TRANSACTION
	BEGIN TRY

		DECLARE @SearchRequestID bigint
	
	
								IF NOT EXISTS(SELECT Tweet_ID FROM ArchiveTweets Where Tweet_ID = @Tweet_ID and CustomerGuid = @CustomerGuid AND IsActive=1)
									BEGIN

										IF(@MediaID IS NOT NULL)
											SELECT
												@SearchRequestID = IQAgent_MediaResults._SearchRequestID,
												@SearchTerm = SearchTerm.query('SearchRequest/SearchTerm').value('.','varchar(500)'),
												@HighLightText = convert(nvarchar(max), IQAgent_TwitterResults.HighlightingText),
												@Number_Hits = IQAgent_TwitterResults.Number_Hits
											FROM	
												IQAgent_MediaResults WITH(NOLOCK)
													Inner join IQAgent_SearchRequest  WITH(NOLOCK)
														ON IQAgent_MediaResults._SearchRequestID =IQAgent_SearchRequest .ID
													inner join IQAgent_TwitterResults WITH(NOLOCK)
														on IQAgent_MediaResults.v5Category = @SubMediaType
														and IQAgent_MediaResults._MediaID = IQAgent_TwitterResults.ID
											WHERE
												IQAgent_MediaResults.ID = @MediaID
										ELSE
										BEGIN
											SET @SearchRequestID = -1
										END
										
										INSERT INTO 
											ArchiveTweets
											(
												CustomerGUID,
												ClientGUID,
												CategoryGuid,												
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
												ModifiedDate,
												PositiveSentiment,
												NegativeSentiment,
												Number_Hits,
												HighlightingText,
												Keywords,
												Description,
												v5SubMediaType
											)
											Values
											(
												@CustomerGuid,
												@ClientGuid,
												@CategoryGuid,												
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
												GETDATE(),
												@PositiveSentiment,
												@NegativeSentiment,
												@Number_Hits,
												@HighLightText,
												@Keywords,
												@Description,
												@SubMediaType
											)

										SELECT @ArchiveKeyBkp = SCOPE_IDENTITY()
										
										INSERT INTO IQArchive_Media
										(
											_ArchiveMediaID,
											MediaType,
											Title,
											SubMediaType,
											HighlightingText,
											MediaDate,
											CategoryGUID,
											ClientGUID,
											CustomerGUID,
											IsActive,
											CreatedDate,
											PositiveSentiment,
											NegativeSentiment,
											_SearchRequestID,
											_MediaID,
											SearchTerm,
											Content,
											v5MediaType,
											v5SubMediaType
										)
										VALUES
										(
											@ArchiveKeyBkp,
											'TW',
											NULL,
											'TW',
											@HighLightText,
											@Tweet_PostedDateTime,
											@CategoryGuid,
											@ClientGuid,
											@CustomerGuid,
											1,
											GETDATE(),
											@PositiveSentiment,
											@NegativeSentiment,
											@SearchRequestID,
											@MediaID,
											@SearchTerm,
											@Tweet_Body,
											@MediaType,
											@SubMediaType
										)
										
										--COMMIT TRANSACTION 
									END
									ELSE
										BEGIN
											--ROLLBACK TRANSACTION
											SELECT  @ArchiveKeyBkp = -1
										END
							
							
		Set @ArchiveKey = @ArchiveKeyBkp		
		COMMIT TRANSACTION
		
	
		
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
				@CreatedBy='usp_v5_ArchiveTW_Insert',
				@ModifiedBy='usp_v5_ArchiveTW_Insert',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		SET @ArchiveKey = 0
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey output
		
	END CATCH
END
