CREATE PROCEDURE [dbo].[usp_v4_IQAgent_SearchRequest_GetDMAsByZipCode]
	@ZipCodes xml
AS
BEGIN
	SET NOCOUNT ON;

    select	distinct iq_dma_name, zip_code
    from	IQ_NielsenDMAZip 
    inner	join @ZipCodes.nodes('list/item') as zc(item) on IQ_NielsenDMAZip.zip_code = zc.item.value('@zipcode', 'int')
	
	select	zc.item.value('@zipcode', 'int') as zip_code
	from	@ZipCodes.nodes('list/item') as zc(item)
	where	not exists (select  null
						from	IQ_NielsenDMAZip
						where	zc.item.value('@zipcode', 'int') = IQ_NielsenDMAZip.zip_code)
    
END
