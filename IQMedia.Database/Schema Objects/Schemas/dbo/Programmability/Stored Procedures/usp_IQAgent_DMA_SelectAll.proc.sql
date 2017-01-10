CREATE PROCEDURE [dbo].[usp_IQAgent_DMA_SelectAll]
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