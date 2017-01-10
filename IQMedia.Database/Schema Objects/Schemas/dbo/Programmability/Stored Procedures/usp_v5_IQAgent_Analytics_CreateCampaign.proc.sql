USE [IQMediaGroup]
GO
/****** Object:  StoredProcedure [dbo].[usp_v5_IQAgent_Analytics_CreateCampaign]    Script Date: 5/24/2016 13:42:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_v5_IQAgent_Analytics_CreateCampaign]
(
	@CampaignName varchar(250),
	@_SearchRequestID bigint,
	@StartDateTime DateTime,
	@EndDateTime DateTime,
	@StartDateTimeGMT DateTime,
	@EndDateTimeGMT DateTime,
	@CampaignID bigint output
)
AS
BEGIN
	INSERT INTO dbo.IQAgent_Campaign
	(
		Name,
		_SearchRequestID,
		StartDatetime,
		EndDatetime,
		CreatedDate,
		ModifiedDate,
		IsActive,
		StartDatetimeGMT,
		EndDatetimeGMT
	)
	VALUES
	(
		@CampaignName,
		@_SearchRequestID,
		@StartDateTime,
		@EndDateTime,
		GETDATE(),
		GETDATE(),
		1,
		@StartDateTimeGMT,
		@EndDateTimeGMT
	)

	SET @CampaignID = @@IDENTITY
END