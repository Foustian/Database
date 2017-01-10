CREATE PROCEDURE [dbo].[usp_v5_IQ3rdP_GoogleSummary_Select]  
	@FromDate DATE,
	@ToDate DATE,
	@ClientGUID UNIQUEIDENTIFIER,
	@DateIntervalType TINYINT,
	@DataTypeID INT
AS  
BEGIN  

	DECLARE @gmtAdjustment int
	DECLARE	@dstAdjustment int
	DECLARE @DataType varchar(100)

	SELECT	@gmtAdjustment = gmt,
			@dstAdjustment = dst
	FROM	IQMediaGroup.dbo.Client
	WHERE	ClientGUID = @ClientGUID

	SELECT	@DataType = DataType
	FROM	IQMediaGroup.dbo.IQ3rdP_DataTypes
	WHERE	ID = @DataTypeID

	-- Show IQ Media for demo accounts
	IF @ClientGUID IN ('61877EA3-0C57-4BA8-813F-63F8FB5B9325','43E4329E-9C07-4374-9C50-5725190D9D54','FF0C709E-BFBC-405C-8CD2-CB2F70707BC9','357896ED-0502-48B6-A650-42F2A002FA3B','6FE80725-411C-4F6B-ABF4-970F2AD52F3C')
	  BEGIN
		SET @ClientGUID = '7722A116-C3BC-40AE-8070-8C59EE9E3D2A'
	  END
	
	IF @DateIntervalType = 0
	  BEGIN
		SELECT  IQMediaGroup.dbo.fnGetClipAdjustedDateTime(GoogleLocalDateTime, @gmtAdjustment, @dstAdjustment, 0) AS GMTDateTime,
				SUM(CASE @DataType
						WHEN 'GoogleSessions' THEN [Sessions]
						WHEN 'GoogleUsers' THEN Users
					END) AS TotalValue
		FROM	IQMediaGroup.dbo.IQ3rdP_GoogleResults WITH (NOLOCK)
		WHERE	_ClientGUID = @ClientGUID
				AND (@FromDate IS NULL OR @ToDate IS NULL OR GoogleLocalDateTime BETWEEN @FromDate AND @ToDate)
		GROUP	BY GoogleLocalDateTime
	  END
	ELSE
	  BEGIN
		SELECT	CAST(MAX(GoogleLocalDateTime) AS DATE) AS GMTDateTime,
				SUM(CASE @DataType
						WHEN 'GoogleSessions' THEN [Sessions]
						WHEN 'GoogleUsers' THEN Users
					END) AS TotalValue
		FROM	IQMediaGroup.dbo.IQ3rdP_GoogleResults WITH (NOLOCK)
		WHERE	_ClientGUID = @ClientGUID
				AND (@FromDate IS NULL OR @ToDate IS NULL OR GoogleLocalDateTime BETWEEN @FromDate AND @ToDate)
		GROUP	BY DATEPART(YEAR, GoogleLocalDateTime), DATEPART(MONTH, GoogleLocalDateTime), CASE @DateIntervalType WHEN 1 THEN DATEPART(DAY, GoogleLocalDateTime) END
	  END
END