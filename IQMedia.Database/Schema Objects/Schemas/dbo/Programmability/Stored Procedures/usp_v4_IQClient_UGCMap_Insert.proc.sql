USE [IQMediaGroup]
GO
/****** Object:  StoredProcedure [dbo].[usp_v4_IQClient_UGCMap_Insert]    Script Date: 10/31/2016 4:41:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_v4_IQClient_UGCMap_Insert]
	@ClientGuid UNIQUEIDENTIFIER,
	@TimeZoneID BIGINT,
	@AutoClip_Status BIT,
	@SourceID VARCHAR(20),
	@BroadcastType VARCHAR(50),
	@Logo VARCHAR(150),
	@Title VARCHAR(255),
	@URL VARCHAR(255),
	@IQClient_UGCMapKey BIGINT OUTPUT
	
AS
BEGIN

	SET NOCOUNT ON;

	IF NOT EXISTS(SELECT IQClient_UGCMapKey FROM IQClient_UGCMap INNER JOIN IQCore_Source ON  IQClient_UGCMap.SourceGUID = IQCore_Source.Guid AND  IQCore_Source.IsActive = 1 WHERE IQClient_UGCMap.ClientGUID = @ClientGuid)
	BEGIN
		IF NOT EXISTS(SELECT SourceID FROM IQCore_Source WHERE SourceID = @SourceID AND IsActive = 1)
		BEGIN
		
			DECLARE @SourceGuid UNIQUEIDENTIFIER
			DECLARE @TimeZoneName varchar(20)
			DECLARE @GMTAdjustment int
			DECLARE @DSTAdjustment int
		
			SET @SourceGuid =NEWID()

				if(@TimeZoneID is null OR @TimeZoneID = 0)
				BEGIN
				SELECT @TimeZoneID = ID FROM IQCore_Timezone INNER JOIN Client ON Client.TimeZone =  IQCore_Timezone.Code AND ClientGUID = @ClientGuid
				END

			SELECT @TimeZoneName = Code FROM IQCore_Timezone WHERE ID = @TimeZoneID
			SELECT @GMTAdjustment = gmt_adj from IQCore_Timezone where ID = @TimeZoneID
			SELECT @DSTAdjustment = dst_adj from IQCore_Timezone where ID = @TimeZoneID

			INSERT INTO IQCore_Source
			(
				[Guid],
				SourceID,
				Title,
				Logo,
				URL,
				BroadcastLocation,
				BroadcastType,
				RetentionDays,
				IsActive,
				_TimezoneID
			)
			VALUES
			(
				@SourceGuid,
				@SourceID,
				@Title,
				@Logo,
				@URL,
				'UGC-Upload',
				@BroadcastType,
				1825,
				1,
				@TimeZoneID
			)

			IF(@@ROWCOUNT > 0)
			BEGIN
				INSERT INTO IQClient_UGCMap
				(
					ClientGUID,
					SourceGUID,
					AutoClip_Status,
					CreatedBy,
					ModifiedBy,
					CreatedDate,
					ModifiedDate,
					IsActive 
				)
				VALUES
				(
					@ClientGuid,
					@SourceGuid,
					@AutoClip_Status,
					'System',
					'System',
					GETDATE(),
					GETDATE(),
					1
				)

				SET @IQClient_UGCMapKey = @@IDENTITY

				INSERT INTO dbo.RL_STATION
				(
					RL_Station_ID,
					rl_format,
					station_call_sign,
					rl_station_active,
					time_zone,
					dma_name,
					dma_num,
					gmt_adj,
					dst_adj,
					iq_cluster,
					station_affil,
					station_affil_num,
					rl_icon,
					Colocation
				)
				VALUES
				(
				@SourceID,
				'OTHER',
				@SourceID,
				1,
				@TimeZoneName,
				'UGCUpload',
				'000',
				@GMTAdjustment,
				@DSTAdjustment,
				9,
				'UGCUpload',
				99,
				@Logo,
				'UGC'
				)
				INSERT INTO IQMediaGroup.dbo.IQ_Station
				(
				IQ_Station_ID,
				[Format],
				Station_Call_Sign,
				Dma_Name,
				Dma_Num,
				Station_Affil,
				Station_Affil_Num,
				gmt_adj,
				dst_adj,
				IsActive,
				TimeZone
				)
				VALUES
				(
				@SourceID,
				'OTHER',
				@SourceID,
				'UGCUpload',
				'000',
				'UGCUpload',
				99,
				@GMTAdjustment,
				@DSTAdjustment,
				1,
				@TimeZoneName
				)
			END
			ELSE 
			BEGIN
				SET @IQClient_UGCMapKey = -2
			END
		END
		ELSE 
		BEGIN
			SET @IQClient_UGCMapKey = -1
		END
	END
	ELSE
	BEGIN
		SET @IQClient_UGCMapKey = -3
	END
END
