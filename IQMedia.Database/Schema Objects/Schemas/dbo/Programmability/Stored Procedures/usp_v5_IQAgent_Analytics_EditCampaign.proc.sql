USE [IQMediaGroup]
GO
/****** Object:  StoredProcedure [dbo].[usp_v5_IQAgent_Analytics_EditCampaign]    Script Date: 5/24/2016 13:43:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_v5_IQAgent_Analytics_EditCampaign]
(
	@CampaignID bigint,
	@CampaignName varchar(250),
	@SearchRequestID bigint,
	@StartDateTime DateTime,
	@EndDateTime DateTime,
	@StartDateTimeGMT DateTime,
	@EndDateTimeGMT DateTime,
	@ModifiedDate DateTime output
)
AS
BEGIN
	
	IF @CampaignName IS NOT NULL
		UPDATE IQMediaGroup.dbo.IQAgent_Campaign
		SET
			Name = @CampaignName
		WHERE
			ID = @CampaignID

	IF @SearchRequestID IS NOT NULL
		UPDATE IQMediaGroup.dbo.IQAgent_Campaign
		SET
			_SearchRequestID = @SearchRequestID
		WHERE
			ID = @CampaignID

	IF @StartDateTime IS NOT NULL AND @StartDateTimeGMT IS NOT NULL
		UPDATE IQMediaGroup.dbo.IQAgent_Campaign
		SET
			StartDatetime = @StartDateTime,
			StartDatetimeGMT = @StartDateTimeGMT
		WHERE
			ID = @CampaignID

	IF @EndDateTime IS NOT NULL AND @EndDateTimeGMT IS NOT NULL
		UPDATE IQMediaGroup.dbo.IQAgent_Campaign
		SET
			EndDatetime = @EndDateTime,
			EndDatetimeGMT = @EndDateTimeGMT
		WHERE
			ID = @CampaignID

	UPDATE IQMediaGroup.dbo.IQAgent_Campaign
	SET 
		ModifiedDate = GETDATE(),
		@ModifiedDate = GETDATE()
	WHERE 
		ID = @CampaignID
END