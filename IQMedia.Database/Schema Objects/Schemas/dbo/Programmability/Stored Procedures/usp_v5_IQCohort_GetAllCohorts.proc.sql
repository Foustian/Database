USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_v5_IQCohort_GetAllCohorts]    Script Date: 12/8/2016 11:47:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_v5_IQCohort_GetAllCohorts]
AS
BEGIN
SELECT
	ID
	,Name
FROM IQMediaGroup.dbo.IQCohort_Cohorts
WHERE IsActive = 1
END
GO

