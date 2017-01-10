CREATE PROCEDURE [dbo].[usp_iqsvc_IQTimeSync_Data_SelectByClipGuid]
	@ClipGuid uniqueidentifier
AS
BEGIN

	DECLARE @IQ_CC_Key varchar(50)
	SELECT 
		  @IQ_CC_Key = LTRIM(RTRIM(IQCore_Source.SourceID)) + '_' +
		  SUBSTRING(CONVERT(VARCHAR(13),IQCore_Recording.Startdate,112),1,13) +
		  '_' + SUBSTRING(CONVERT(VARCHAR(13),IQCore_Recording.Startdate,108),1,2) + '00' 
	FROM 
		IQCore_Clip WITH (NOLOCK)
			INNER JOIN IQCore_Recordfile WITH (NOLOCK)
				ON IQCore_Clip._RecordfileGuid = IQCore_Recordfile.Guid
			Inner Join IQCore_Recording WITH (NOLOCK)
			ON IQCore_Recordfile._RecordingID  = IQCore_Recording.ID
		  Inner Join IQCore_Source WITH (NOLOCK)
			ON IQCore_Recording._SourceGuid = IQCore_Source.Guid
			and IQCore_Recordfile.Guid = CASE WHEN IQCore_Recordfile._ParentGuid is null then IQCore_Recordfile.[Guid] END
	WHERE		
			IQCore_Clip.[Guid] = @ClipGuid

		
	SELECT 
			IQTimeSync_Data.Data,
			IQTimeSync_Data._TypeID
		FROM 
			IQTimeSync_Data
				inner join IQTimeSync_Type 
					on IQTimeSync_Data._TypeID = IQTimeSync_Type.ID
					and IQTimeSync_Data.IsActive = 1
					and IQTimeSync_Type.IsActive = 1
		WHERE
			IQ_CC_Key = @IQ_CC_Key
END