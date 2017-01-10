CREATE PROCEDURE [dbo].[usp_v4_IQ_KantorData_SelectAudienceByIQCCKey]
	@IQCCKEY varchar(28),
	@DataType smallint
as
BEGIN 
		SELECT 
				audience_data
		FROM 
				IQ_KantorData
		WHERe
				IQ_CC_Key = @IQCCKEY
				and DataType =  @DataType
				and IsActive = 1
END