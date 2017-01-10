USE [IQMediaGroup]
GO
/****** Object:  StoredProcedure [dbo].[usp_v4_IQClient_UGCMap_SelectByUGCMapKey]    Script Date: 10/28/2016 2:05:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_v4_IQClient_UGCMap_SelectByUGCMapKey]
	@IQClient_UGCMapKey BIGINT
AS
BEGIN

	SET NOCOUNT ON;

	SELECT
			IQClient_UGCMap.AutoClip_Status,
			IQClient_UGCMap.IQClient_UGCMapKey,
			IQClient_UGCMap.SourceGUID,
			IQClient_UGCMap.ClientGUID,
			IQCore_Source._TimezoneID,
			IQCore_Source.BroadcastLocation,
			IQCore_Source.BroadcastType,
			IQCore_Source.Logo,
			IQCore_Source.RetentionDays,
			IQCore_Source.SourceID,
			IQCore_Source.Title,
			IQCore_Source.URL		
	FROM	
			IQClient_UGCMap
				INNER JOIN IQCore_Source
					ON IQClient_UGCMap.SourceGUID = IQCore_Source.[Guid]
					AND IQCore_Source.IsActive = 1
	WHERE
			IQClient_UGCMap.IQClient_UGCMapKey = @IQClient_UGCMapKey
END
