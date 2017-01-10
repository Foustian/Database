USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_v5_Analytics_Secondaries]    Script Date: 5/4/2016 16:51:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[usp_v5_Analytics_Secondaries]
(
	@MainTab VARCHAR(50),
	@PageType VARCHAR(50)
)

AS
BEGIN
	SELECT
		GroupBy,
		ColumnHeaders,
		ColumnHeadersLR,
		ColumnHeadersAds,
		ColumnHeadersAdsLR,
		GroupByHeader,
		GroupByDisplay,
		TabDisplay,
		PageType
	FROM IQMediaGroup.dbo.IQ_Analytics_Secondaries WITH (NOLOCK)
	WHERE @PageType = PageType
	AND CHARINDEX(@MainTab, MainTabs) > 0
END
GO

