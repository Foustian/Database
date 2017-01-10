CREATE PROCEDURE [dbo].[usp_v4_IQ_KantorData_SelectIQCCKeyByStationIDAndDateTime]
	@StationID varchar(50),
	@DateTime	date,
	@DataType smallint
AS
BEGIN
		SELECT Distinct
				IQ_CC_Key
		FROM 
				IQ_KantorData
		WHERE
				Station_ID = @StationID
				AND CONVERT(date,GMT_air_datetime) = @DateTime
				and DataType =  @DataType
				AND IsActive = 1
END