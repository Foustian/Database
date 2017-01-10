CREATE PROCEDURE [dbo].[usp_v4_IQAgent_MediaResults_SelectTVEyesUrlByMediaID]
	@MediaID bigint
AS
BEGIN
	select 
		TranscriptURL
	FROM
			IQAgent_MediaResults 
				inner join IQAGent_TVEyesResults
					on IQAgent_MediaResults.MediaType = 'TM'
					AND IQAgent_MediaResults._MediaID = IQAGent_TVEyesResults.ID
	WHERE
			IQAgent_MediaResults .ID = @MediaID
				
END