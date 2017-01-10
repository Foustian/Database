
CREATE PROCEDURE [dbo].[usp_IQAgentResults_Insert]
(
	@IQAgentResultKey	bigint Output,
	@SearchRequestID	bigint,
	@RL_VideoGUID		uniqueidentifier,
	@Rl_Station			varchar(150),
	@RL_Date			date,
	@RL_Time			int,
	@RL_Market			varchar(150),
	@Number_Hits		int,
	@Communication_flag	bit,
	@CreatedBy	    	varchar(150),
	@ModifiedBy		    varchar(150),
	@CreatedDate		datetime,
	@ModifiedDate		datetime,
	@IsActive			bit
)
AS
BEGIN

	SET NOCOUNT ON;
	
	declare @Count int
	
	Select
			@Count=COUNT(*)
	From
			IQAgent_TVResults
	Where
			IQAgent_TVResults.RL_VideoGUID=@RL_VideoGUID and
			IQAgent_TVResults.SearchRequestID=@SearchRequestID and
			IQAgent_TVResults.IsActive=1
			
	if (@Count=0)
		begin
		
				insert into IQAgent_TVResults
				(
					SearchRequestID,
					RL_VideoGUID,
					Rl_Station,
					RL_Date,
					RL_Time,
					RL_Market,
					Number_Hits,
					Communication_flag,
					CreatedDate,
					ModifiedDate,
					CreatedBy,
					ModifiedBy,
					IsActive
				)
				Values
				(
					@SearchRequestID,
					@RL_VideoGUID,
					@Rl_Station,
					@RL_Date,
					@RL_Time,
					@RL_Market,
					@Number_Hits,
					@Communication_flag,
					ISNULL(@CreatedDate,GetDate()),
					ISNULL(@ModifiedDate,GetDate()),
					ISNULL(@CreatedBy,'System'),
					ISNULL(@ModifiedBy,'System'),
					ISNULL(@IsActive,1)
				)
				
				Select @IQAgentResultKey=SCOPE_IDENTITY()
		
		end
	


END
