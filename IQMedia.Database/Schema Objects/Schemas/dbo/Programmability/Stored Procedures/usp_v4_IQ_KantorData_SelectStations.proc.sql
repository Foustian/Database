CREATE PROCEDURE [dbo].[usp_v4_IQ_KantorData_SelectStations]
	@DataType smallint
AS
BEGIN
	SELECT distinct 
			Station_ID
	FROM
			IQ_KantorData

	WHERE
			DataType = @DataType
			and IsActive = 1
END