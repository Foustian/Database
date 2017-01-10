-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Client_Insert] 
	
	@ClientName			varchar(50),
	@ClientKey			int out,
	@ClientGUID			uniqueidentifier,
	@DefaultCategory	varchar(500),
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
	@CustomHeader       varchar(max),
	@PlayerLogo			varchar(max),
	@IsCustomHeader		bit,
	@IsActivePlayerLogo		bit,
	@NoOfIQNotification		tinyint,
	@NoOfIQAgnet			tinyint,
	@CompeteMultiplier		decimal(18,2),
	@OnlineNewsAdRate		decimal(18,2),
	@OtherOnlineAdRate	decimal(18,2),
	@UrlPercentRead		decimal(18,2),
	@Status				bit output
	
	
AS
BEGIN
	
	SET NOCOUNT ON;
  
   EXEC usp_Client_ImageCheck @CustomHeader,@PlayerLogo,@ClientKey,@Status output
 
	IF(@Status = 0)
	BEGIN
							DECLARE @ClientCount int
							SELECT @ClientCount = COUNT(*) FROM Client WHERE ClientName=@ClientName
							IF @ClientCount = 0 
							BEGIN 
							INSERT INTO	
									Client
										(
											ClientName,
											ClientGUID,
											CreatedDate,
											ModifiedDate,
											IsActive,
											PricingCodeID,
											BillFrequencyID,
											BillTypeID,
											IndustryID,
											StateID,
											Address1,
											Address2,
											City,
											Zip,
											Attention,
											Phone,
											MasterClient,
											NoOfUser,
											CustomHeaderImage,
											IsCustomHeader,
											PlayerLogo,
											IsActivePlayerLogo
										)
									VALUES
										(
											@ClientName,
											@ClientGUID,
											SYSDATETIME(),
											SYSDATETIME(),
											1,
											@PricingCodeID,
											@BillFrequencyID,
											@BillTypeID,
											@IndustryID,
											@StateID,
											@Address1,
											@Address2,
											@City,
											@Zip,
											@Attention,
											@Phone,
											@MasterClient,
											@NoOfUser,
											@CustomHeader,
											@IsCustomHeader,
											@PlayerLogo,					
											@IsActivePlayerLogo
										)
									SELECT @ClientKey=SCOPE_IDENTITY()
									
								
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
										@DefaultCategory,
										@DefaultCategory,
										SYSDATETIME(),
										SYSDATETIME(),
										1
									)
									
									IF(@CompeteMultiplier is not Null)
									BEGIN
										INSERT INTO IQClient_CustomSettings
											Values
											(@ClientGUID,'CompeteMultiplier',@CompeteMultiplier)
									END 

									IF(@OtherOnlineAdRate is not Null)
									BEGIN
										INSERT INTO IQClient_CustomSettings
											Values
											(@ClientGUID,'OtherOnlineAdRate',@OtherOnlineAdRate)
									END

									IF(@OnlineNewsAdRate is not Null)
									BEGIN
										INSERT INTO IQClient_CustomSettings
											Values
											(@ClientGUID,'OnlineNewsAdRate',@OnlineNewsAdRate)
									END
									
									IF(@UrlPercentRead is not Null)
									BEGIN
										INSERT INTO IQClient_CustomSettings
											Values
											(@ClientGUID,'URLPercentRead',@UrlPercentRead)
									END
									
									
									If(@NoOfIQNotification is not null)
									BEGIN
										INSERT INTO IQClient_CustomSettings
										Values
										(@ClientGUID,'TotalNoOfIQNotification',@NoOfIQNotification)
									END


									If(@NoOfIQAgnet is not null)
									BEGIN
										INSERT INTO IQClient_CustomSettings
										Values
										(@ClientGUID,'TotalNoOfIQAgent',@NoOfIQAgnet)
									END
								
									
							END
							ELSE
								SET @ClientKey=0
	END
		ELSE
	BEGIN
				SET @ClientKey=0
	END
	

	
    
END
