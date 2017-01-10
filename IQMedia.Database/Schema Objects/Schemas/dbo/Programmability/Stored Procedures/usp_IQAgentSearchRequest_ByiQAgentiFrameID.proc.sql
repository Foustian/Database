-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQAgentSearchRequest_ByiQAgentiFrameID]
	@iQAgentiFrameID uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @RawMediaGuid uniqueidentifier
	DECLARE @ExpiryDate		datetime
	DECLARE @SearchTerm		varchar(1000)
	
	
	Select
		  @SearchTerm = IQAgent_SearchRequest.SearchTerm.value('(/SearchRequest//SearchTerm/node())[1]', 'VARCHAR(max)'),
				@RawMediaGuid =
							(CASE	
								WHEN								
									IQagentIFrame.IQAgentResultID IS NOT NULL
								THEN
									IQAgent_TVResults.RL_VideoGUID
							END
							),
		@ExpiryDate = IQAgentiFrame.[Expiry_Date]		
		
	From
		IQAgentiFrame
		--LEFT OUTER JOIN IQAgentResults
		LEFT OUTER JOIN IQAgent_TVResults
		ON IQAgentiFrame.IQAgentResultID = IQAgent_TVResults.ID
		
		LEFT OUTER JOIN IQAgent_SearchRequest
		ON IQAgent_TVResults.SearchRequestID = IQAgent_SearchRequest.ID
		
		--CROSS APPLY IQAgentSearchRequest.SearchTerm.nodes('/IQAgentRequest') t(p)
		
		Where IQAgentiFrame.[Guid]= @iQAgentiFrameID
	
	
	Select	@ExpiryDate as Expiry_Date,@SearchTerm as SearchTerm,@RawMediaGuid as RawMediaGuid		
    
END
