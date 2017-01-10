CREATE PROCEDURE [dbo].[usp_IQAgent_DMA_SelectByName]
	@DMAName varchar(47)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT TOP 1 [ID] as DmaID
    FROM [IQMediaGroup].[dbo].[IQDMA]
	WHERE [IQ_Dma_Name] = @DMAName
END