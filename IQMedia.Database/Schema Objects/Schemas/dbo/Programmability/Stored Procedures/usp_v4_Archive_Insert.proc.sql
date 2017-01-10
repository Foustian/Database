-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_Archive_Insert]
	@Title				varchar(250),
	@Keywords 			varchar(500),
	@Description 		varchar(1000),
	@CustomerGuid		uniqueidentifier,
	@ClientGuid			uniqueidentifier,
	@CategoryGuid		uniqueidentifier,
	@SubCategory1Guid	uniqueidentifier,
	@SubCategory2Guid	uniqueidentifier,
	@SubCategory3Guid	uniqueidentifier,
	@MediaResultID		varchar(50),	
	@Rating				tinyint,
	@ArchiveKey		bigint output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;
	
	BEGIN TRANSACTION
	BEGIN TRY
	
	DECLARE @ArticleUri			varchar(MAX)
	DECLARE @Harvest_Time		datetime	
	DECLARE @Content			varchar(MAX)
	DECLARE @MediaType varchar(2)
	DECLARE @ArticleID varchar(max)
	declare @rpID int
	Declare @ArchiveKeyBkp bigint
	
	
	
	Select
		@MediaType = MediaType
	From
		IQAgent_MediaResults
	Where 
		ID = @MediaResultID
		AND IsActive = 1
		
		IF(@MediaType = 'NM')
			BEGIN
				Select
					@ArticleUri = IQAgent_NMResults.Url,
					@Harvest_Time = IQAgent_MediaResults.MediaDate,
					@Content = IQAgent_MediaResults.highlightingText,
					@ArticleID = IQAgent_NMResults.ArticleID,
					@Title = IQAgent_MediaResults.Title
				From
					IQAgent_MediaResults
					INNER JOIN IQAgent_NMResults
					ON IQAgent_MediaResults._MediaID = IQAgent_NMResults.ID
					AND IQAgent_MediaResults.MediaType = 'NM'
				Where
					IQAgent_MediaResults.ID = @MediaResultID
					AND IQAgent_MediaResults.Isactive = 1
					AND IQAgent_NMResults.IsActive = 1
					
					
					
					Select
							@rpID=IQCore_RootPath.ID
					From
							IQCore_RootPath
								inner join IQCore_RootPathType
									on IQCore_RootPath._RootPathTypeID=IQCore_RootPathType.ID
					Where
							IQCore_RootPathType.Name='NM'
					Order by
							NEWID()
	
					IF NOT EXISTS(SELECT ArticleID FROM IQCore_Nm Where ArticleID = @ArticleID)
						BEGIN
							INSERT INTO 
								IQCore_Nm
								(
									ArticleID,
									Url,
									harvest_time,
									[Status],
									_RootPathID
								)
							VALUES
								(
									@ArticleID,
									@ArticleUri,
									@Harvest_Time,
									'QUEUED',
									@rpID
								)	
						END
		
		
						IF NOT EXISTS(SELECT ArticleID FROM ArchiveNM Where ArticleID = @ArticleID and CustomerGuid = @CustomerGuid AND IsActive=1)
						BEGIN
							INSERT INTO 
								ArchiveNM
								(
									Title,
									Keywords,
									[Description],
									FirstName,
									LastName,
									CustomerGuid,
									ClientGuid,
									CategoryGuid,
									SubCategory1Guid,
									SubCategory2Guid,
									SubCategory3Guid,
									ArticleID,
									ArticleContent,
									Url,
									Rating,
									IsActive,
									CreatedDate,
									ModifiedDate
								)
							SELECT  
									@Title,
									@Keywords,
									@Description,
									Customer.FirstName,
									Customer.LastName,
									@CustomerGuid,
									@ClientGuid,
									@CategoryGuid,
									@SubCategory1Guid,
									@SubCategory2Guid,
									@SubCategory3Guid,
									@ArticleID,
									@Content,
									@ArticleUri,
									@Rating,
									1,
									GETDATE(),
									GETDATE()
							FROM  Customer Where CustomerGuid = @CustomerGuid
							
							SELECT @ArchiveKeyBkp = SCOPE_IDENTITY()
							
							
							--COMMIT TRANSACTION
						END
						ELSE
							BEGIN
									--ROLLBACK TRANSACTION
									SELECT  @ArchiveKeyBkp = -1
							END
			END
		
			ELSE IF(@MediaType = 'SM')
					BEGIN
							Select
								@ArticleUri = IQAgent_SMResults.link,
								@Harvest_Time = IQAgent_MediaResults.MediaDate,
								@Content = IQAgent_MediaResults.highlightingText,
								@ArticleID =  IQAgent_SMResults.SeqID,
								@Title = IQAgent_MediaResults.Title
							From
								IQAgent_MediaResults
								INNER JOIN IQAgent_SMResults
								ON IQAgent_MediaResults._MediaID = IQAgent_SMResults.ID
								AND IQAgent_MediaResults.MediaType = 'SM'
							Where
								IQAgent_MediaResults.ID = @MediaResultID
								AND IQAgent_MediaResults.Isactive = 1
								AND IQAgent_SMResults.IsActive = 1
								
								
							Select
											@rpID=IQCore_RootPath.ID
									From
											IQCore_RootPath
												inner join IQCore_RootPathType
													on IQCore_RootPath._RootPathTypeID=IQCore_RootPathType.ID
									Where
											IQCore_RootPathType.Name='SM'
									Order by
											NEWID()
								
									IF NOT EXISTS(SELECT ArticleID FROM IQCore_SM Where ArticleID = @ArticleID)
									BEGIN
										INSERT INTO 
											IQCore_SM
											(
												ArticleID,
												Url,
												harvest_time,
												[Status],
												_RootPathID
											)
										VALUES
											(
												@ArticleID,
												@ArticleUri,
												@Harvest_Time,
												'QUEUED',
												@rpID
											)	
									END
									
									IF NOT EXISTS(SELECT ArticleID FROM ArchiveSM Where ArticleID = @ArticleID and CustomerGuid = @CustomerGuid AND IsActive=1)
									BEGIN
										INSERT INTO 
											ArchiveSM
											(
												Title,
												Keywords,
												[Description],
												FirstName,
												LastName,
												CustomerGuid,
												ClientGuid,
												CategoryGuid,
												SubCategory1Guid,
												SubCategory2Guid,
												SubCategory3Guid,
												ArticleID,
												ArticleContent,
												Url,
												Rating,
												IsActive,
												CreatedDate,
												ModifiedDate
											)
										SELECT  
												@Title,
												@Keywords,
												@Description,
												Customer.FirstName,
												Customer.LastName,
												@CustomerGuid,
												@ClientGuid,
												@CategoryGuid,
												@SubCategory1Guid,
												@SubCategory2Guid,
												@SubCategory3Guid,
												@ArticleID,
												@Content,
												@ArticleUri,
												@Rating,
												1,
												GETDATE(),
												GETDATE()
										FROM  Customer Where CustomerGuid = @CustomerGuid
										SELECT @ArchiveKeyBkp = SCOPE_IDENTITY()
										
										--COMMIT TRANSACTION
										
									END
									ELSE
									BEGIN
										--ROLLBACK TRANSACTION
										SELECT  @ArchiveKeyBkp = -1
									END
									
							
					END -- END  of MediaType = SM
					
				ELSE IF(@MediaType = 'TW')
					BEGIN
						
							DECLARE @Actor_PreferredUserName		nvarchar(15),
									@Tweet_Body			nvarchar(max),
									@Actor_FollowersCount	bigint,
									@Actor_FriendsCount		bigint,
									@Actor_Image		varchar(max),
									@Actor_link			varchar(max),
									@gnip_Klout_Score	bigint,
									@Tweet_PostedDateTime	datetime,
									@Tweet_ID varchar(max),
									@Actor_DisplayName varchar(max)
							
							Select
								@Tweet_ID = IQAgent_TwitterResults.TweetID,
								
								@Content = IQAgent_MediaResults.highlightingText,
								@Actor_DisplayName = IQAgent_TwitterResults.Actor_DisplayName,
								@Actor_PreferredUserName = IQAgent_TwitterResults.Actor_PreferredName,
								@Tweet_Body = IQAgent_TwitterResults.Summary,
								@Actor_FollowersCount = IQAgent_TwitterResults.Actor_FollowersCount,
								@Actor_FriendsCount = IQAgent_TwitterResults.Actor_FriendsCount,
								@Actor_Image = IQAgent_TwitterResults.Actor_Image,
								@Actor_link = IQAgent_TwitterResults.Actor_link,
								@gnip_Klout_Score = IQAgent_TwitterResults.gnip_Klout_Score,
								@Tweet_PostedDateTime = IQAgent_MediaResults.MediaDate
								
							From
								IQAgent_MediaResults
								INNER JOIN IQAgent_TwitterResults
								ON IQAgent_MediaResults._MediaID = IQAgent_TwitterResults.ID
								AND IQAgent_MediaResults.MediaType = 'TW'
							Where
								IQAgent_MediaResults.ID = @MediaResultID
								AND IQAgent_MediaResults.Isactive = 1
								AND IQAgent_TwitterResults.IsActive = 1
								
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

										SELECT @ArchiveKeyBkp = SCOPE_IDENTITY()
										
										
										
										--COMMIT TRANSACTION 
									END
									ELSE
										BEGIN
											--ROLLBACK TRANSACTION
											SELECT  @ArchiveKeyBkp = -1
										END
					END
	
		Set @ArchiveKey = @ArchiveKeyBkp		
		COMMIT TRANSACTION
		
	
		--COMMIT TRANSACTION 
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
				@CreatedBy='usp_ArchiveNM_Insert',
				@ModifiedBy='usp_ArchiveNM_Insert',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		SET @ArchiveKey = 0
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@ModifiedBy,@CreatedDate,@ModifiedDate,@IsActive,@IQMediaGroupExceptionKey output
		
	END CATCH

    
END
