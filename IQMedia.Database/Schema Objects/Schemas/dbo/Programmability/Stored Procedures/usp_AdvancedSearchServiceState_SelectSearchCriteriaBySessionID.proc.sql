
CREATE PROCEDURE usp_AdvancedSearchServiceState_SelectSearchCriteriaBySessionID
(
	@SessionID		varchar(Max)
)

AS
BEGIN
	SET NOCOUNT ON;
	
	Select
			top(1) SearchCriteria
	From
			AdvancedSearchServiceState
	Where
			SessionID=@SessionID
	


END
