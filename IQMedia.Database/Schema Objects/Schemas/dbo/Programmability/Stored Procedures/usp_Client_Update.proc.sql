-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Client_Update]
	-- Add the parameters for the stored procedure here
	
	@ClientName varchar(50),
	@ClientKey bigint, --Output,
	@Active bit,
	@PricingCodeID		bigint,
	@BillFrequencyID	bigint,
	@BillTypeID         bigint,
	@IndustryID			bigint,
	@StateID			bigint,
	@Address1			varchar(max),
	@Address2			varchar(max),
	@City				varchar(50),
	@Zip				varchar(5),
	@Attention			varchar(50),
	@Phone				varchar(15),
	@MasterClient		varchar(50),
	@NoOfUser			int,
	@ModifiedDate		Datetime,
	@CustomHeader     varchar(max),
	@PlayerLogo			varchar(max),
	@IsCustomHeader		bit,
	@IsActivePlayerLogo		bit,
	@NoOfIQNotification		tinyint,
	@NoOfIQAgnet			tinyint,
	@CompeteMultiplier		decimal(18,2),
	@OnlineNewsAdRate		decimal(18,2),
	@OtherOnlineAdRate		decimal(18,2),
	@UrlPercentRead		decimal(18,2),
	@NotificationStatus		int out,
	@IQAgentStatus			int out,
	@Status				bit out
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

    -- Insert statements for procedure here
     
   EXEC usp_Client_ImageCheck @CustomHeader,@PlayerLogo,@ClientKey,@Status output
   --EXEC usp_Client_ImageCheck @CustomHeader,@CustomHeader,@PlayerLogo,@Status output
   set @NotificationStatus = 0;
   Set @IQAgentStatus = 0;
   if(@Status = 0)
   begin
		DECLARE @ClientCount int
		SELECT @ClientCount = COUNT(*) FROM Client WHERE ClientName=@ClientName and ClientKey<>@ClientKey
		IF @ClientCount = 0 
		BEGIN 
			print @ClientKey
						
			Declare @ClientGUID uniqueidentifier
			Declare @TotalNotificationCount tinyint
			Declare @TotalIQAgentCount tinyint
							
			Select @ClientGUID =  ClientGUID from Client Where ClientKey = @ClientKey
						
			Select @TotalNotificationCount = 
				Max(TotalCount)
				From
					(
							Select COUNT(*) as 'TotalCount'
							From
								IQNotificationSettings
								Inner JOIN IQAgent_SearchRequest
								ON IQNotificationSettings.SearchRequestID = IQAgent_SearchRequest.ID
											
								Where IQNotificationSettings.IsActive = 1 AND IQAgent_SearchRequest.IsActive = 1
								AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
								Group By SearchRequestID
					)a

			 SELECT @TotalIQAgentCount = COUNT(*) FROM IQAgent_SearchRequest WHERE IQAgent_SearchRequest.ClientGUID = @ClientGUID AND IQAgent_SearchRequest.IsActive = 1;
		
		
			IF(ISNULL(@TotalNotificationCount,0) > @NoOfIQNotification)
			BEGIN
				SET @NotificationStatus = -2
			END					    
			ELSE IF (ISNULL(@TotalIQAgentCount,0) > @NoOfIQAgnet)
			BEGIN
				SET @IQAgentStatus = -2;
			END
			ELSE
			BEGIN
				UPDATE Client 
				SET
					ClientName=@ClientName,
					IsActive=@Active,
					PricingCodeID=@PricingCodeID,		
					BillFrequencyID=@BillFrequencyID,	
					BillTypeID=@BillTypeID,
					IndustryID=@IndustryID,			
					StateID=@StateID,			
					Address1=@Address1,			
					Address2=@Address2,			
					City=@City,				
					Zip=@Zip,				
					Attention=@Attention,			
					Phone=@Phone,		
					MasterClient=@MasterClient,		
					NoOfUser=@NoOfUser,	
					ModifiedDate = @ModifiedDate,
					CustomHeaderImage = @CustomHeader,
					IsCustomHeader = @IsCustomHeader,
					PlayerLogo = @PlayerLogo,
					IsActivePlayerLogo = @IsActivePlayerLogo	
										
				WHERE
									
					ClientKey=@ClientKey	

				IF(@CompeteMultiplier is not Null)
				BEGIN
					If(Exists(SELECT Value from IQClient_CustomSettings Where _ClientGUID = @ClientGUID and Field = 'CompeteMultiplier' ))
						BEGIN
							Update  IQClient_CustomSettings
							Set Value = @CompeteMultiplier
							Where _ClientGuid = @ClientGUID and Field = 'CompeteMultiplier'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
								Values
								(@ClientGUID,'CompeteMultiplier',@CompeteMultiplier)
						END		
				END

				IF(@OtherOnlineAdRate is not Null)
				BEGIN
					If(Exists(SELECT Value from IQClient_CustomSettings Where _ClientGUID = @ClientGUID and Field = 'OtherOnlineAdRate' ))
						BEGIN
							Update  IQClient_CustomSettings
							Set Value = @OtherOnlineAdRate
							Where _ClientGuid = @ClientGUID and Field = 'OtherOnlineAdRate'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
								Values
								(@ClientGUID,'OtherOnlineAdRate',@OtherOnlineAdRate)
						END		
				END

				IF(@OnlineNewsAdRate is not Null)
				BEGIN
					If(Exists(SELECT Value from IQClient_CustomSettings Where _ClientGUID = @ClientGUID and Field = 'OnlineNewsAdRate' ))
						BEGIN
							Update  IQClient_CustomSettings
							Set Value = @OnlineNewsAdRate
							Where _ClientGuid = @ClientGUID and Field = 'OnlineNewsAdRate'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
								Values
								(@ClientGUID,'OnlineNewsAdRate',@OnlineNewsAdRate)
						END		
				END
				
				IF(@UrlPercentRead is not Null)
				BEGIN
					If(Exists(SELECT Value from IQClient_CustomSettings Where _ClientGUID = @ClientGUID and Field = 'URLPercentRead' ))
						BEGIN
							Update  IQClient_CustomSettings
							Set Value = @UrlPercentRead
							Where _ClientGuid = @ClientGUID and Field = 'URLPercentRead'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
								Values
								(@ClientGUID,'URLPercentRead',@UrlPercentRead)
						END		
				END
				

				if(@NoOfIQAgnet is not null)
				BEGIN
					IF(EXISTS(SELECT Value FROM IQClient_CustomSettings Where _ClientGuid = @ClientGUID AND Field ='TotalNoOfIQAgent'))
					BEGIN
						UPDATE IQClient_CustomSettings
						SET Value = @NoOfIQAgnet
						WHERE _ClientGuid = @ClientGUID and Field = 'TotalNoOfIQAgent'
					END
					ELSE
					BEGIN
						INSERT INTO IQClient_CustomSettings(_ClientGuid,Field,Value) Values(@ClientGUID,'TotalNoOfIQAgent',@NoOfIQAgnet);
					END
				END

				IF(@NoOfIQNotification is not Null)
				BEGIN
					If(Exists(SELECT Value from IQClient_CustomSettings Where _ClientGUID = @ClientGUID and Field = 'TotalNoOfIQNotification' ))
						BEGIN
							Update  IQClient_CustomSettings
							Set Value = @NoOfIQNotification
							Where _ClientGuid = @ClientGUID and Field = 'TotalNoOfIQNotification'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
								Values
								(@ClientGUID,'TotalNoOfIQNotification',@NoOfIQNotification)
						END
					END		
				END
							
			END
			ELSE
			Begin
				SET @ClientKey=0
			end
		end
		else	
		begin
			set @ClientKey = 0
		end
END
