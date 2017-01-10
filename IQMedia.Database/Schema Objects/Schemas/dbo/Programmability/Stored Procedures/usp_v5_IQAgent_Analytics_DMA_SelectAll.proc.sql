USE [IQMediaGroup]
GO
/****** Object:  StoredProcedure [dbo].[usp_v5_IQAgent_Analytics_DMA_SelectAll]    Script Date: 5/24/2016 13:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_v5_IQAgent_Analytics_DMA_SelectAll]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [ID] as strDmaID, [IQ_Dma_Name] as strDmaName
    FROM [IQMediaGroup].[dbo].[IQDMA]
    ORDER by [IQ_DMA_NUM]
END