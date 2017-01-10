USE [IQMediaGroup]
GO
/****** Object:  StoredProcedure [dbo].[usp_v4_IQClient_UGCMap_Update]    Script Date: 10/28/2016 2:03:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_v4_IQClient_UGCMap_Update]
	@ClientGuid UNIQUEIDENTIFIER,
	@TimeZoneID BIGINT,
	@AutoClip_Status BIT,
	@SourceID VARCHAR(20),
	@SourceGuid UNIQUEIDENTIFIER,
	@BroadcastType VARCHAR(50),
	@Logo VARCHAR(150),
	@Title VARCHAR(255),
	@URL VARCHAR(255),
	@IQClient_UGCMapKey BIGINT,
	@Output INT OUTPUT
AS
BEGIN
	
	SET NOCOUNT ON;

	IF NOT EXISTS(SELECT IQClient_UGCMapKey FROM IQClient_UGCMap INNER JOIN IQCore_Source ON  IQClient_UGCMap.SourceGUID = IQCore_Source.Guid AND  IQCore_Source.IsActive = 1 WHERE IQClient_UGCMap.ClientGUID = @ClientGuid AND IQClient_UGCMapKey != @IQClient_UGCMapKey)
	BEGIN
		IF NOT EXISTS(SELECT SourceID FROM IQCore_Source WHERE SourceID = @SourceID AND IsActive = 1 AND [Guid] != @SourceGuid)
		BEGIN		
			if(@TimeZoneID IS NULL OR @TimeZoneID=0)
			BEGIN
			SELECT @TimeZoneID = ID FROM IQCore_Timezone INNER JOIN Client ON Client.TimeZone =  IQCore_Timezone.Code AND ClientGUID = @ClientGuid
			END
			DECLARE @TimeZoneName varchar(20), @GMTAdjustment int, @DSTAdjustment int
			SELECT @TimeZoneName = Code FROM IQCore_Timezone WHERE ID = @TimeZoneID
			SELECT @GMTAdjustment = gmt_adj from IQCore_Timezone where ID = @TimeZoneID
			SELECT @DSTAdjustment = dst_adj from IQCore_Timezone where ID = @TimeZoneID

			UPDATE 
					IQCore_Source 
			SET
					BroadcastType = @BroadcastType,
					Title = @Title,
					URL = @URL,
					_TimezoneID = @TimeZoneID
			WHERE
					[Guid] = @SourceGuid


			UPDATE
					IQClient_UGCMap
			SET
					AutoClip_Status = @AutoClip_Status,
					ModifiedDate = GETDATE()
			WHERE
					ClientGUID = @ClientGuid
					AND IQClient_UGCMapKey = @IQClient_UGCMapKey

			SET @Output = @@ROWCOUNT

			UPDATE
					RL_STATION
			SET
					time_zone =@TimeZoneName,
					gmt_adj =@GMTAdjustment,
					dst_adj=@DSTAdjustment,
					rl_icon =@Logo
			WHERE 
					RL_Station_ID=@SourceID
			UPDATE
					IQ_Station
			SET 
					gmt_adj=@GMTAdjustment,
					dst_adj=@DSTAdjustment,
					TimeZone=@TimeZoneName
			WHERE
					IQ_Station_ID=@SourceID
		END
		ELSE
		BEGIN
			SET @Output = -1
		END
	END
	ELSE
	BEGIN
		SET @Output = -2
	END
END
