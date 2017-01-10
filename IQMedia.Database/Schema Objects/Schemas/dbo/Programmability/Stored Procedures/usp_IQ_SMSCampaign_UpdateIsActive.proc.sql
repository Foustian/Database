CREATE PROCEDURE [dbo].[usp_IQ_SMSCampaign_UpdateIsActive]
	@SearchRequestID bigint,
	@HubSpotID	int,
	@IsActivated bit,
	@AffectedResults int output
AS
BEGIN
	SET NOCOUNT ON

	
		UPDATE 
				[IQ_SMSCampaign]
		SET 
				[IsActivated] = @IsActivated, 
				[ActivationAcceptDate] = case when @IsActivated=1 then GETDATE() ELSE [ActivationAcceptDate] end,
				[UnSubscribeDate]=case when @IsActivated=0 then GETDATE() ELSE [UnSubscribeDate] end
				
		WHERE 
				[HubSpotID] = @HubSpotID
				AND [SearchRequestID] = @SearchRequestID
	
		select @AffectedResults= @@ROWCOUNT		

END