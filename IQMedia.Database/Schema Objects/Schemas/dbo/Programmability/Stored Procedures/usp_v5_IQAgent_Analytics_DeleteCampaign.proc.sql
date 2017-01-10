USE [IQMediaGroup]
GO
/****** Object:  StoredProcedure [dbo].[usp_v5_IQAgent_Analytics_DeleteCampaign]    Script Date: 5/24/2016 13:45:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_v5_IQAgent_Analytics_DeleteCampaign]
(
	@CampaignID bigint
)
AS
BEGIN
	UPDATE 
		IQMediaGroup.dbo.IQAgent_Campaign
	SET
		IsActive = 0,
		ModifiedDate = GETDATE()
	WHERE
		ID = @CampaignID
END