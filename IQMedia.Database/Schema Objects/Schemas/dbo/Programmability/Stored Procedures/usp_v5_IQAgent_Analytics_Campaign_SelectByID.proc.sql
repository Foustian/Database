USE [IQMediaGroup]
GO
/****** Object:  StoredProcedure [dbo].[usp_v5_IQAgent_Analytics_Campaign_SelectByID]    Script Date: 5/24/2016 13:55:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_v5_IQAgent_Analytics_Campaign_SelectByID]
(
	@CampaignID bigint
)
AS
BEGIN
	SELECT
		Campaign.ID,
		Campaign.Name,
		_SearchRequestID AS 'SearchRequestID',
		SearchRequest.Query_Name,
		StartDatetime,
		EndDatetime,
		SearchRequest.Query_Version,
		Campaign.ModifiedDate,
		Campaign.IsActive
	FROM IQMediaGroup.dbo.IQAgent_Campaign Campaign WITH (NOLOCK)
	INNER JOIN IQMediaGroup.dbo.IQAgent_SearchRequest SearchRequest WITH (NOLOCK)
		ON Campaign._SearchRequestID = SearchRequest.ID
	WHERE Campaign.ID = @CampaignID
END