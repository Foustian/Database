-- =============================================
-- Author:		<Author,,Name>
-- Create date: 15 July 2013
-- Description:	Select paged records based on parameters
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_Radio_SelectRadioResults]
	@FromDate		DATETIME,
	@ToDate			DATETIME,
	@Market			VARCHAR(50),
	@IsAsc			BIT,
	@PageNo			INT,
	@PageSize		INT,
	@SinceID		BIGINT OUTPUT,
	@TotalResults	BIGINT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @StartRowNo AS BIGINT,@EndRowNo AS BIGINT
	
	SET @StartRowNo = ((@PageNo-1) * @PageSize) + 1
	SET @EndRowNo = (@PageNo * @PageSize)
	
	
	-- Select total records count
	
	SELECT	@SinceID = CASE WHEN (@SinceID IS NULL OR @SinceID=0) THEN MAX(RL_GUIDSKey) ELSE @SinceID END,
			@TotalResults = COUNT(*) 
	FROM	RL_GUIDS
	
	INNER JOIN IQ_Station
	ON		RL_GUIDS.RL_Station_ID = IQ_Station.IQ_Station_ID
	AND Format = 'RADIO'	
	AND		(@Market Is NULL OR IQ_Station.Dma_Name = @Market)	
	WHERE	RL_GUIDS.IsActive = 1
	AND		IQ_Station.IsActive = 1
	AND		((@SinceID IS NULL OR @SinceID = 0) OR RL_GUIDSKey <= @SinceID)
	AND		((@FromDate IS NULL OR @ToDate Is NULL) OR RL_Station_Date BETWEEN @FromDate AND @ToDate) 
	AND		(@Market Is NULL OR IQ_Station.Dma_Name = @Market)
	
	
	;WITH CTE_Radio AS
	(
		SELECT 
				--ROW_NUMBER() OVER (ORDER BY 
				--						(CASE @IsAsc WHEN 1 THEN  RL_Station_Date,RL_Station_Time END	),(
				--						 Case @IsAsc WHEN 0 THEN  RL_Station_Date,RL_Station_Time END )  DESC
				--									) AS RowNo,
				CASE @IsAsc
					WHEN	1 THEN	ROW_NUMBER() OVER (ORDER BY RL_Station_Date,RL_Station_Time)
					ELSE	ROW_NUMBER() OVER (ORDER BY RL_Station_Date DESC,RL_Station_Time DESC)
				END
				AS RowNo,						
				RL_GUIDSKey,
				RL_Station_ID,
				IQ_Station.Dma_Name,
				RL_GUID,
				CAST(CAST(RL_Station_Date AS VARCHAR) + ' ' + CAST((RL_Station_Time / 100) AS VARCHAR(2)) + ':00:00' AS DATETIME) AS RL_StationDateTime
		FROM	RL_GUIDS
		
		INNER JOIN IQ_Station
		ON		RL_GUIDS.RL_Station_ID = IQ_Station.IQ_Station_ID
		AND		(@Market Is NULL OR IQ_Station.Dma_Name = @Market)	
		AND Format = 'RADIO'
		
		WHERE	RL_GUIDS.IsActive = 1
		AND		IQ_Station.IsActive = 1
		AND		((@SinceID IS NULL OR @SinceID = 0) OR RL_GUIDSKey <= @SinceID)
		AND		((@FromDate IS NULL OR @ToDate Is NULL) OR RL_Station_Date BETWEEN @FromDate AND @ToDate) 
		AND		(@Market Is NULL OR IQ_Station.Dma_Name = @Market)	
	)
	SELECT * FROM CTE_Radio
	WHERE RowNo BETWEEN @StartRowNo AND @EndRowNo
    AND	RL_GUIDSKey <= @SinceID
    ORDER BY RowNo
    
	
END
