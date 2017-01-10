USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_v5_IQCohort_GetCohortAgents]    Script Date: 12/8/2016 11:47:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_v5_IQCohort_GetCohortAgents]
(
	@CohortID bigint
)
AS
BEGIN
SELECT
	CA._SearchRequestID
	,SR.Query_Name
FROM IQMediaGroup.dbo.IQCohort_Agents AS CA
	INNER JOIN IQMediaGroup.dbo.IQAgent_SearchRequest AS SR
		ON CA._SearchRequestID = SR.ID
	WHERE CA._CohortID = @CohortID
	AND CA.IsActive = 1
	AND SR.IsActive = 1
END
GO

