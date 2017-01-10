USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_v5_IQCohort_GetHiddenElements]    Script Date: 12/8/2016 11:47:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_v5_IQCohort_GetHiddenElements]
(
	@Report varchar(50)
)
as
begin
select
	HiddenElements
From IQMediaGroup.dbo.IQCohort_HiddenElements
WHERE Report = @Report
end

GO

