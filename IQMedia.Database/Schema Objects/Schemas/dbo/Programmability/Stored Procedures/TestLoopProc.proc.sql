
CREATE PROCEDURE TestLoopProc
AS
BEGIN

select
                RL_GUIDS.RL_GUID as guid,
                RL_GUIDS.IQ_CC_Key as iq_cc_key,
                '/opt/solr/RL_CC_Text_Files/' + RL_CC_TEXT.RL_CC_FileName AS CCTxtFile,
                RL_CC_TEXT.RL_Station_ID as stationid,
                RL_CC_TEXT.RL_Station_Time as hour,
                Convert(varchar, RL_CC_TEXT.RL_Station_Date) as ClipDate,
                (Convert(varchar,RL_CC_TEXT.RL_Station_Date)+'T'+ RIGHT('0'+Convert(varchar,(RL_CC_TEXT.RL_Station_Time/100)),2)+':00:00') as RL_Station_DateTime,
                RL_STATION.time_zone as timezone,
                RL_STATION.dma_name as market,
                RL_STATION.station_affil as affiliate,
                RL_STATION.gmt_adj as gmtadj,
                RL_STATION.dst_adj as dstadj,
                (SELECT
                                                        REPLACE(LTRIM(RTRIM((SELECT  LTRIM(RTRIM(ISNULL(tf_title,'')+' '+
                            ISNULL(tf_host,'') + ' ' +
                            ISNULL(tf_cast1,'') + ' '+
                            ISNULL(tf_cast2,'') + ' '+
                            ISNULL(tf_cast3,'') + ' '+
                            ISNULL(tf_cast4,'') + ' '+
                            ISNULL(tf_cast5,'') + ' '+
                            ISNULL(tf_cast6,'')+' '+
                            ISNULL(tf_description,'') + ' '+
                            ISNULL(tf_description2,'') + ' '+
                            ISNULL(tf_description3,'') + ' ')) AS [data()]
                        FROM ssp_appearing
                        where  ssp_appearing.IQ_CC_KEY = RL_GUIDS.iq_cc_key
                        FOR XML PATH('')))),'  ',' ')) as appearing,
               ISNULL((SELECT distinct title120 = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/title120') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_title120,
            ISNULL((SELECT distinct desc100 = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/desc100') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_desc100,
                ISNULL((SELECT distinct iq_class_num = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_class_num') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_class_num,
                ISNULL((SELECT distinct iq_class = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_class') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_class,
                ISNULL((SELECT distinct iq_start_point = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_start_point') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_start_point,
                RL_Station.dma_num as IQ_Dma_Num,
                RL_STATION.station_affil_num
               

from
                RL_CC_TEXT
                        inner join RL_GUIDS
                                on RL_GUIDS.iq_cc_key = RL_CC_TEXT.iq_cc_key
                                  inner join RL_STATION
                                on RL_STATION.RL_STATION_ID = RL_CC_TEXT.RL_STATION_ID

                        left outer join
                                (
                                        select IQ_CC_KEY,
                                                   XML_DATA = CONVERT(xml,LTRIM(' '+ (select LTRIM(RTRIM(ISNULL(title120,'')+' ')) as 'title120',
                                                        LTRIM(RTRIM(ISNULL(desc100,'')+' '))  as 'desc100',
                                                        LTRIM(RTRIM(ISNULL(iq_class_num,'')+' '))  as 'iq_class_num',
                                                        LTRIM(RTRIM(ISNULL(iq_class,'')+' '))  as 'iq_class',
                                                        LTRIM(RTRIM(ISNULL(IQ_Dma_Num,'')+' '))  as 'IQ_Dma_Num',
                                                        LTRIM(RTRIM(ISNULL(IQ_Dma_Name,'')+' '))  as 'IQ_Dma_Name',
                                                        LTRIM(RTRIM(ISNULL(station_affil_num,'')+' '))  as 'station_affil_num',
                                                        LTRIM(RTRIM(ISNULL(station_affil,'')+' '))  as 'station_affil',
                                                        LTRIM(RTRIM(ISNULL(iq_start_point,'')+' '))  as 'iq_start_point'
                                                                from STATSKEDPROG STATSKEDPROG2
                                                where STATSKEDPROG2.IQ_CC_Key =STATSKEDPROG1.IQ_CC_Key
                                                For XML PATH('list'))))
                                from STATSKEDPROG STATSKEDPROG1 GROUP BY IQ_CC_KEY ) as custom_STATSKEDPROG
                                        on RL_GUIDS.iq_cc_key = custom_STATSKEDPROG.IQ_CC_KEY
where
                CC_Ingest_Date is null

union all
select
                RL_GUIDS.RL_GUID as guid,
                RL_GUIDS.IQ_CC_Key as iq_cc_key,
                '/opt/solr/RL_CC_Text_Files/' + RL_CC_TEXT.RL_CC_FileName AS CCTxtFile,
                RL_CC_TEXT.RL_Station_ID as stationid,
                RL_CC_TEXT.RL_Station_Time as hour,
                Convert(varchar, RL_CC_TEXT.RL_Station_Date) as ClipDate,
                (Convert(varchar,RL_CC_TEXT.RL_Station_Date)+'T'+ RIGHT('0'+Convert(varchar,(RL_CC_TEXT.RL_Station_Time/100)),2)+':00:00') as RL_Station_DateTime,
                RL_STATION.time_zone as timezone,
                RL_STATION.dma_name as market,
                RL_STATION.station_affil as affiliate,
                RL_STATION.gmt_adj as gmtadj,
                RL_STATION.dst_adj as dstadj,
                (SELECT
                                                        REPLACE(LTRIM(RTRIM((SELECT  LTRIM(RTRIM(ISNULL(tf_title,'')+' '+
                            ISNULL(tf_host,'') + ' ' +
                            ISNULL(tf_cast1,'') + ' '+
                            ISNULL(tf_cast2,'') + ' '+
                            ISNULL(tf_cast3,'') + ' '+
                            ISNULL(tf_cast4,'') + ' '+
                            ISNULL(tf_cast5,'') + ' '+
                            ISNULL(tf_cast6,'')+' '+
                            ISNULL(tf_description,'') + ' '+
                            ISNULL(tf_description2,'') + ' '+
                            ISNULL(tf_description3,'') + ' ')) AS [data()]
                        FROM ssp_appearing
                        where  ssp_appearing.IQ_CC_KEY = RL_GUIDS.iq_cc_key
                        FOR XML PATH('')))),'  ',' ')) as appearing,
               ISNULL((SELECT distinct title120 = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/title120') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_title120,
            ISNULL((SELECT distinct desc100 = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/desc100') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_desc100,
                ISNULL((SELECT distinct iq_class_num = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_class_num') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_class_num,
                ISNULL((SELECT distinct iq_class = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_class') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_class,
                ISNULL((SELECT distinct iq_start_point = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_start_point') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_start_point,
                RL_Station.dma_num as IQ_Dma_Num,
                RL_STATION.station_affil_num
               

from
                RL_CC_TEXT
                        inner join RL_GUIDS
                                on RL_GUIDS.iq_cc_key = RL_CC_TEXT.iq_cc_key
                                  inner join RL_STATION
                                on RL_STATION.RL_STATION_ID = RL_CC_TEXT.RL_STATION_ID

                        left outer join
                                (
                                        select IQ_CC_KEY,
                                                   XML_DATA = CONVERT(xml,LTRIM(' '+ (select LTRIM(RTRIM(ISNULL(title120,'')+' ')) as 'title120',
                                                        LTRIM(RTRIM(ISNULL(desc100,'')+' '))  as 'desc100',
                                                        LTRIM(RTRIM(ISNULL(iq_class_num,'')+' '))  as 'iq_class_num',
                                                        LTRIM(RTRIM(ISNULL(iq_class,'')+' '))  as 'iq_class',
                                                        LTRIM(RTRIM(ISNULL(IQ_Dma_Num,'')+' '))  as 'IQ_Dma_Num',
                                                        LTRIM(RTRIM(ISNULL(IQ_Dma_Name,'')+' '))  as 'IQ_Dma_Name',
                                                        LTRIM(RTRIM(ISNULL(station_affil_num,'')+' '))  as 'station_affil_num',
                                                        LTRIM(RTRIM(ISNULL(station_affil,'')+' '))  as 'station_affil',
                                                        LTRIM(RTRIM(ISNULL(iq_start_point,'')+' '))  as 'iq_start_point'
                                                                from STATSKEDPROG STATSKEDPROG2
                                                where STATSKEDPROG2.IQ_CC_Key =STATSKEDPROG1.IQ_CC_Key
                                                For XML PATH('list'))))
                                from STATSKEDPROG STATSKEDPROG1 GROUP BY IQ_CC_KEY ) as custom_STATSKEDPROG
                                        on RL_GUIDS.iq_cc_key = custom_STATSKEDPROG.IQ_CC_KEY
where
                CC_Ingest_Date is null

union all
select
                RL_GUIDS.RL_GUID as guid,
                RL_GUIDS.IQ_CC_Key as iq_cc_key,
                '/opt/solr/RL_CC_Text_Files/' + RL_CC_TEXT.RL_CC_FileName AS CCTxtFile,
                RL_CC_TEXT.RL_Station_ID as stationid,
                RL_CC_TEXT.RL_Station_Time as hour,
                Convert(varchar, RL_CC_TEXT.RL_Station_Date) as ClipDate,
                (Convert(varchar,RL_CC_TEXT.RL_Station_Date)+'T'+ RIGHT('0'+Convert(varchar,(RL_CC_TEXT.RL_Station_Time/100)),2)+':00:00') as RL_Station_DateTime,
                RL_STATION.time_zone as timezone,
                RL_STATION.dma_name as market,
                RL_STATION.station_affil as affiliate,
                RL_STATION.gmt_adj as gmtadj,
                RL_STATION.dst_adj as dstadj,
                (SELECT
                                                        REPLACE(LTRIM(RTRIM((SELECT  LTRIM(RTRIM(ISNULL(tf_title,'')+' '+
                            ISNULL(tf_host,'') + ' ' +
                            ISNULL(tf_cast1,'') + ' '+
                            ISNULL(tf_cast2,'') + ' '+
                            ISNULL(tf_cast3,'') + ' '+
                            ISNULL(tf_cast4,'') + ' '+
                            ISNULL(tf_cast5,'') + ' '+
                            ISNULL(tf_cast6,'')+' '+
                            ISNULL(tf_description,'') + ' '+
                            ISNULL(tf_description2,'') + ' '+
                            ISNULL(tf_description3,'') + ' ')) AS [data()]
                        FROM ssp_appearing
                        where  ssp_appearing.IQ_CC_KEY = RL_GUIDS.iq_cc_key
                        FOR XML PATH('')))),'  ',' ')) as appearing,
               ISNULL((SELECT distinct title120 = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/title120') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_title120,
            ISNULL((SELECT distinct desc100 = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/desc100') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_desc100,
                ISNULL((SELECT distinct iq_class_num = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_class_num') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_class_num,
                ISNULL((SELECT distinct iq_class = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_class') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_class,
                ISNULL((SELECT distinct iq_start_point = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_start_point') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_start_point,
                RL_Station.dma_num as IQ_Dma_Num,
                RL_STATION.station_affil_num
               

from
                RL_CC_TEXT
                        inner join RL_GUIDS
                                on RL_GUIDS.iq_cc_key = RL_CC_TEXT.iq_cc_key
                                  inner join RL_STATION
                                on RL_STATION.RL_STATION_ID = RL_CC_TEXT.RL_STATION_ID

                        left outer join
                                (
                                        select IQ_CC_KEY,
                                                   XML_DATA = CONVERT(xml,LTRIM(' '+ (select LTRIM(RTRIM(ISNULL(title120,'')+' ')) as 'title120',
                                                        LTRIM(RTRIM(ISNULL(desc100,'')+' '))  as 'desc100',
                                                        LTRIM(RTRIM(ISNULL(iq_class_num,'')+' '))  as 'iq_class_num',
                                                        LTRIM(RTRIM(ISNULL(iq_class,'')+' '))  as 'iq_class',
                                                        LTRIM(RTRIM(ISNULL(IQ_Dma_Num,'')+' '))  as 'IQ_Dma_Num',
                                                        LTRIM(RTRIM(ISNULL(IQ_Dma_Name,'')+' '))  as 'IQ_Dma_Name',
                                                        LTRIM(RTRIM(ISNULL(station_affil_num,'')+' '))  as 'station_affil_num',
                                                        LTRIM(RTRIM(ISNULL(station_affil,'')+' '))  as 'station_affil',
                                                        LTRIM(RTRIM(ISNULL(iq_start_point,'')+' '))  as 'iq_start_point'
                                                                from STATSKEDPROG STATSKEDPROG2
                                                where STATSKEDPROG2.IQ_CC_Key =STATSKEDPROG1.IQ_CC_Key
                                                For XML PATH('list'))))
                                from STATSKEDPROG STATSKEDPROG1 GROUP BY IQ_CC_KEY ) as custom_STATSKEDPROG
                                        on RL_GUIDS.iq_cc_key = custom_STATSKEDPROG.IQ_CC_KEY
where
                CC_Ingest_Date is null
union all
select
                RL_GUIDS.RL_GUID as guid,
                RL_GUIDS.IQ_CC_Key as iq_cc_key,
                '/opt/solr/RL_CC_Text_Files/' + RL_CC_TEXT.RL_CC_FileName AS CCTxtFile,
                RL_CC_TEXT.RL_Station_ID as stationid,
                RL_CC_TEXT.RL_Station_Time as hour,
                Convert(varchar, RL_CC_TEXT.RL_Station_Date) as ClipDate,
                (Convert(varchar,RL_CC_TEXT.RL_Station_Date)+'T'+ RIGHT('0'+Convert(varchar,(RL_CC_TEXT.RL_Station_Time/100)),2)+':00:00') as RL_Station_DateTime,
                RL_STATION.time_zone as timezone,
                RL_STATION.dma_name as market,
                RL_STATION.station_affil as affiliate,
                RL_STATION.gmt_adj as gmtadj,
                RL_STATION.dst_adj as dstadj,
                (SELECT
                                                        REPLACE(LTRIM(RTRIM((SELECT  LTRIM(RTRIM(ISNULL(tf_title,'')+' '+
                            ISNULL(tf_host,'') + ' ' +
                            ISNULL(tf_cast1,'') + ' '+
                            ISNULL(tf_cast2,'') + ' '+
                            ISNULL(tf_cast3,'') + ' '+
                            ISNULL(tf_cast4,'') + ' '+
                            ISNULL(tf_cast5,'') + ' '+
                            ISNULL(tf_cast6,'')+' '+
                            ISNULL(tf_description,'') + ' '+
                            ISNULL(tf_description2,'') + ' '+
                            ISNULL(tf_description3,'') + ' ')) AS [data()]
                        FROM ssp_appearing
                        where  ssp_appearing.IQ_CC_KEY = RL_GUIDS.iq_cc_key
                        FOR XML PATH('')))),'  ',' ')) as appearing,
               ISNULL((SELECT distinct title120 = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/title120') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_title120,
            ISNULL((SELECT distinct desc100 = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/desc100') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_desc100,
                ISNULL((SELECT distinct iq_class_num = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_class_num') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_class_num,
                ISNULL((SELECT distinct iq_class = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_class') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_class,
                ISNULL((SELECT distinct iq_start_point = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_start_point') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_start_point,
                RL_Station.dma_num as IQ_Dma_Num,
                RL_STATION.station_affil_num
               

from
                RL_CC_TEXT
                        inner join RL_GUIDS
                                on RL_GUIDS.iq_cc_key = RL_CC_TEXT.iq_cc_key
                                  inner join RL_STATION
                                on RL_STATION.RL_STATION_ID = RL_CC_TEXT.RL_STATION_ID

                        left outer join
                                (
                                        select IQ_CC_KEY,
                                                   XML_DATA = CONVERT(xml,LTRIM(' '+ (select LTRIM(RTRIM(ISNULL(title120,'')+' ')) as 'title120',
                                                        LTRIM(RTRIM(ISNULL(desc100,'')+' '))  as 'desc100',
                                                        LTRIM(RTRIM(ISNULL(iq_class_num,'')+' '))  as 'iq_class_num',
                                                        LTRIM(RTRIM(ISNULL(iq_class,'')+' '))  as 'iq_class',
                                                        LTRIM(RTRIM(ISNULL(IQ_Dma_Num,'')+' '))  as 'IQ_Dma_Num',
                                                        LTRIM(RTRIM(ISNULL(IQ_Dma_Name,'')+' '))  as 'IQ_Dma_Name',
                                                        LTRIM(RTRIM(ISNULL(station_affil_num,'')+' '))  as 'station_affil_num',
                                                        LTRIM(RTRIM(ISNULL(station_affil,'')+' '))  as 'station_affil',
                                                        LTRIM(RTRIM(ISNULL(iq_start_point,'')+' '))  as 'iq_start_point'
                                                                from STATSKEDPROG STATSKEDPROG2
                                                where STATSKEDPROG2.IQ_CC_Key =STATSKEDPROG1.IQ_CC_Key
                                                For XML PATH('list'))))
                                from STATSKEDPROG STATSKEDPROG1 GROUP BY IQ_CC_KEY ) as custom_STATSKEDPROG
                                        on RL_GUIDS.iq_cc_key = custom_STATSKEDPROG.IQ_CC_KEY
where
                CC_Ingest_Date is null
union all
select
                RL_GUIDS.RL_GUID as guid,
                RL_GUIDS.IQ_CC_Key as iq_cc_key,
                '/opt/solr/RL_CC_Text_Files/' + RL_CC_TEXT.RL_CC_FileName AS CCTxtFile,
                RL_CC_TEXT.RL_Station_ID as stationid,
                RL_CC_TEXT.RL_Station_Time as hour,
                Convert(varchar, RL_CC_TEXT.RL_Station_Date) as ClipDate,
                (Convert(varchar,RL_CC_TEXT.RL_Station_Date)+'T'+ RIGHT('0'+Convert(varchar,(RL_CC_TEXT.RL_Station_Time/100)),2)+':00:00') as RL_Station_DateTime,
                RL_STATION.time_zone as timezone,
                RL_STATION.dma_name as market,
                RL_STATION.station_affil as affiliate,
                RL_STATION.gmt_adj as gmtadj,
                RL_STATION.dst_adj as dstadj,
                (SELECT
                                                        REPLACE(LTRIM(RTRIM((SELECT  LTRIM(RTRIM(ISNULL(tf_title,'')+' '+
                            ISNULL(tf_host,'') + ' ' +
                            ISNULL(tf_cast1,'') + ' '+
                            ISNULL(tf_cast2,'') + ' '+
                            ISNULL(tf_cast3,'') + ' '+
                            ISNULL(tf_cast4,'') + ' '+
                            ISNULL(tf_cast5,'') + ' '+
                            ISNULL(tf_cast6,'')+' '+
                            ISNULL(tf_description,'') + ' '+
                            ISNULL(tf_description2,'') + ' '+
                            ISNULL(tf_description3,'') + ' ')) AS [data()]
                        FROM ssp_appearing
                        where  ssp_appearing.IQ_CC_KEY = RL_GUIDS.iq_cc_key
                        FOR XML PATH('')))),'  ',' ')) as appearing,
               ISNULL((SELECT distinct title120 = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/title120') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_title120,
            ISNULL((SELECT distinct desc100 = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/desc100') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_desc100,
                ISNULL((SELECT distinct iq_class_num = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_class_num') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_class_num,
                ISNULL((SELECT distinct iq_class = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_class') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_class,
                ISNULL((SELECT distinct iq_start_point = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_start_point') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_start_point,
                RL_Station.dma_num as IQ_Dma_Num,
                RL_STATION.station_affil_num
               

from
                RL_CC_TEXT
                        inner join RL_GUIDS
                                on RL_GUIDS.iq_cc_key = RL_CC_TEXT.iq_cc_key
                                  inner join RL_STATION
                                on RL_STATION.RL_STATION_ID = RL_CC_TEXT.RL_STATION_ID

                        left outer join
                                (
                                        select IQ_CC_KEY,
                                                   XML_DATA = CONVERT(xml,LTRIM(' '+ (select LTRIM(RTRIM(ISNULL(title120,'')+' ')) as 'title120',
                                                        LTRIM(RTRIM(ISNULL(desc100,'')+' '))  as 'desc100',
                                                        LTRIM(RTRIM(ISNULL(iq_class_num,'')+' '))  as 'iq_class_num',
                                                        LTRIM(RTRIM(ISNULL(iq_class,'')+' '))  as 'iq_class',
                                                        LTRIM(RTRIM(ISNULL(IQ_Dma_Num,'')+' '))  as 'IQ_Dma_Num',
                                                        LTRIM(RTRIM(ISNULL(IQ_Dma_Name,'')+' '))  as 'IQ_Dma_Name',
                                                        LTRIM(RTRIM(ISNULL(station_affil_num,'')+' '))  as 'station_affil_num',
                                                        LTRIM(RTRIM(ISNULL(station_affil,'')+' '))  as 'station_affil',
                                                        LTRIM(RTRIM(ISNULL(iq_start_point,'')+' '))  as 'iq_start_point'
                                                                from STATSKEDPROG STATSKEDPROG2
                                                where STATSKEDPROG2.IQ_CC_Key =STATSKEDPROG1.IQ_CC_Key
                                                For XML PATH('list'))))
                                from STATSKEDPROG STATSKEDPROG1 GROUP BY IQ_CC_KEY ) as custom_STATSKEDPROG
                                        on RL_GUIDS.iq_cc_key = custom_STATSKEDPROG.IQ_CC_KEY
where
                CC_Ingest_Date is null
union all
select
                RL_GUIDS.RL_GUID as guid,
                RL_GUIDS.IQ_CC_Key as iq_cc_key,
                '/opt/solr/RL_CC_Text_Files/' + RL_CC_TEXT.RL_CC_FileName AS CCTxtFile,
                RL_CC_TEXT.RL_Station_ID as stationid,
                RL_CC_TEXT.RL_Station_Time as hour,
                Convert(varchar, RL_CC_TEXT.RL_Station_Date) as ClipDate,
                (Convert(varchar,RL_CC_TEXT.RL_Station_Date)+'T'+ RIGHT('0'+Convert(varchar,(RL_CC_TEXT.RL_Station_Time/100)),2)+':00:00') as RL_Station_DateTime,
                RL_STATION.time_zone as timezone,
                RL_STATION.dma_name as market,
                RL_STATION.station_affil as affiliate,
                RL_STATION.gmt_adj as gmtadj,
                RL_STATION.dst_adj as dstadj,
                (SELECT
                                                        REPLACE(LTRIM(RTRIM((SELECT  LTRIM(RTRIM(ISNULL(tf_title,'')+' '+
                            ISNULL(tf_host,'') + ' ' +
                            ISNULL(tf_cast1,'') + ' '+
                            ISNULL(tf_cast2,'') + ' '+
                            ISNULL(tf_cast3,'') + ' '+
                            ISNULL(tf_cast4,'') + ' '+
                            ISNULL(tf_cast5,'') + ' '+
                            ISNULL(tf_cast6,'')+' '+
                            ISNULL(tf_description,'') + ' '+
                            ISNULL(tf_description2,'') + ' '+
                            ISNULL(tf_description3,'') + ' ')) AS [data()]
                        FROM ssp_appearing
                        where  ssp_appearing.IQ_CC_KEY = RL_GUIDS.iq_cc_key
                        FOR XML PATH('')))),'  ',' ')) as appearing,
               ISNULL((SELECT distinct title120 = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/title120') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_title120,
            ISNULL((SELECT distinct desc100 = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/desc100') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_desc100,
                ISNULL((SELECT distinct iq_class_num = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_class_num') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_class_num,
                ISNULL((SELECT distinct iq_class = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_class') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_class,
                ISNULL((SELECT distinct iq_start_point = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_start_point') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_start_point,
                RL_Station.dma_num as IQ_Dma_Num,
                RL_STATION.station_affil_num
               

from
                RL_CC_TEXT
                        inner join RL_GUIDS
                                on RL_GUIDS.iq_cc_key = RL_CC_TEXT.iq_cc_key
                                  inner join RL_STATION
                                on RL_STATION.RL_STATION_ID = RL_CC_TEXT.RL_STATION_ID

                        left outer join
                                (
                                        select IQ_CC_KEY,
                                                   XML_DATA = CONVERT(xml,LTRIM(' '+ (select LTRIM(RTRIM(ISNULL(title120,'')+' ')) as 'title120',
                                                        LTRIM(RTRIM(ISNULL(desc100,'')+' '))  as 'desc100',
                                                        LTRIM(RTRIM(ISNULL(iq_class_num,'')+' '))  as 'iq_class_num',
                                                        LTRIM(RTRIM(ISNULL(iq_class,'')+' '))  as 'iq_class',
                                                        LTRIM(RTRIM(ISNULL(IQ_Dma_Num,'')+' '))  as 'IQ_Dma_Num',
                                                        LTRIM(RTRIM(ISNULL(IQ_Dma_Name,'')+' '))  as 'IQ_Dma_Name',
                                                        LTRIM(RTRIM(ISNULL(station_affil_num,'')+' '))  as 'station_affil_num',
                                                        LTRIM(RTRIM(ISNULL(station_affil,'')+' '))  as 'station_affil',
                                                        LTRIM(RTRIM(ISNULL(iq_start_point,'')+' '))  as 'iq_start_point'
                                                                from STATSKEDPROG STATSKEDPROG2
                                                where STATSKEDPROG2.IQ_CC_Key =STATSKEDPROG1.IQ_CC_Key
                                                For XML PATH('list'))))
                                from STATSKEDPROG STATSKEDPROG1 GROUP BY IQ_CC_KEY ) as custom_STATSKEDPROG
                                        on RL_GUIDS.iq_cc_key = custom_STATSKEDPROG.IQ_CC_KEY
where
                CC_Ingest_Date is null
union all
select
                RL_GUIDS.RL_GUID as guid,
                RL_GUIDS.IQ_CC_Key as iq_cc_key,
                '/opt/solr/RL_CC_Text_Files/' + RL_CC_TEXT.RL_CC_FileName AS CCTxtFile,
                RL_CC_TEXT.RL_Station_ID as stationid,
                RL_CC_TEXT.RL_Station_Time as hour,
                Convert(varchar, RL_CC_TEXT.RL_Station_Date) as ClipDate,
                (Convert(varchar,RL_CC_TEXT.RL_Station_Date)+'T'+ RIGHT('0'+Convert(varchar,(RL_CC_TEXT.RL_Station_Time/100)),2)+':00:00') as RL_Station_DateTime,
                RL_STATION.time_zone as timezone,
                RL_STATION.dma_name as market,
                RL_STATION.station_affil as affiliate,
                RL_STATION.gmt_adj as gmtadj,
                RL_STATION.dst_adj as dstadj,
                (SELECT
                                                        REPLACE(LTRIM(RTRIM((SELECT  LTRIM(RTRIM(ISNULL(tf_title,'')+' '+
                            ISNULL(tf_host,'') + ' ' +
                            ISNULL(tf_cast1,'') + ' '+
                            ISNULL(tf_cast2,'') + ' '+
                            ISNULL(tf_cast3,'') + ' '+
                            ISNULL(tf_cast4,'') + ' '+
                            ISNULL(tf_cast5,'') + ' '+
                            ISNULL(tf_cast6,'')+' '+
                            ISNULL(tf_description,'') + ' '+
                            ISNULL(tf_description2,'') + ' '+
                            ISNULL(tf_description3,'') + ' ')) AS [data()]
                        FROM ssp_appearing
                        where  ssp_appearing.IQ_CC_KEY = RL_GUIDS.iq_cc_key
                        FOR XML PATH('')))),'  ',' ')) as appearing,
               ISNULL((SELECT distinct title120 = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/title120') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_title120,
            ISNULL((SELECT distinct desc100 = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/desc100') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_desc100,
                ISNULL((SELECT distinct iq_class_num = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_class_num') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_class_num,
                ISNULL((SELECT distinct iq_class = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_class') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_class,
                ISNULL((SELECT distinct iq_start_point = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_start_point') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_start_point,
                RL_Station.dma_num as IQ_Dma_Num,
                RL_STATION.station_affil_num
               

from
                RL_CC_TEXT
                        inner join RL_GUIDS
                                on RL_GUIDS.iq_cc_key = RL_CC_TEXT.iq_cc_key
                                  inner join RL_STATION
                                on RL_STATION.RL_STATION_ID = RL_CC_TEXT.RL_STATION_ID

                        left outer join
                                (
                                        select IQ_CC_KEY,
                                                   XML_DATA = CONVERT(xml,LTRIM(' '+ (select LTRIM(RTRIM(ISNULL(title120,'')+' ')) as 'title120',
                                                        LTRIM(RTRIM(ISNULL(desc100,'')+' '))  as 'desc100',
                                                        LTRIM(RTRIM(ISNULL(iq_class_num,'')+' '))  as 'iq_class_num',
                                                        LTRIM(RTRIM(ISNULL(iq_class,'')+' '))  as 'iq_class',
                                                        LTRIM(RTRIM(ISNULL(IQ_Dma_Num,'')+' '))  as 'IQ_Dma_Num',
                                                        LTRIM(RTRIM(ISNULL(IQ_Dma_Name,'')+' '))  as 'IQ_Dma_Name',
                                                        LTRIM(RTRIM(ISNULL(station_affil_num,'')+' '))  as 'station_affil_num',
                                                        LTRIM(RTRIM(ISNULL(station_affil,'')+' '))  as 'station_affil',
                                                        LTRIM(RTRIM(ISNULL(iq_start_point,'')+' '))  as 'iq_start_point'
                                                                from STATSKEDPROG STATSKEDPROG2
                                                where STATSKEDPROG2.IQ_CC_Key =STATSKEDPROG1.IQ_CC_Key
                                                For XML PATH('list'))))
                                from STATSKEDPROG STATSKEDPROG1 GROUP BY IQ_CC_KEY ) as custom_STATSKEDPROG
                                        on RL_GUIDS.iq_cc_key = custom_STATSKEDPROG.IQ_CC_KEY
where
                CC_Ingest_Date is null
union all
select
                RL_GUIDS.RL_GUID as guid,
                RL_GUIDS.IQ_CC_Key as iq_cc_key,
                '/opt/solr/RL_CC_Text_Files/' + RL_CC_TEXT.RL_CC_FileName AS CCTxtFile,
                RL_CC_TEXT.RL_Station_ID as stationid,
                RL_CC_TEXT.RL_Station_Time as hour,
                Convert(varchar, RL_CC_TEXT.RL_Station_Date) as ClipDate,
                (Convert(varchar,RL_CC_TEXT.RL_Station_Date)+'T'+ RIGHT('0'+Convert(varchar,(RL_CC_TEXT.RL_Station_Time/100)),2)+':00:00') as RL_Station_DateTime,
                RL_STATION.time_zone as timezone,
                RL_STATION.dma_name as market,
                RL_STATION.station_affil as affiliate,
                RL_STATION.gmt_adj as gmtadj,
                RL_STATION.dst_adj as dstadj,
                (SELECT
                                                        REPLACE(LTRIM(RTRIM((SELECT  LTRIM(RTRIM(ISNULL(tf_title,'')+' '+
                            ISNULL(tf_host,'') + ' ' +
                            ISNULL(tf_cast1,'') + ' '+
                            ISNULL(tf_cast2,'') + ' '+
                            ISNULL(tf_cast3,'') + ' '+
                            ISNULL(tf_cast4,'') + ' '+
                            ISNULL(tf_cast5,'') + ' '+
                            ISNULL(tf_cast6,'')+' '+
                            ISNULL(tf_description,'') + ' '+
                            ISNULL(tf_description2,'') + ' '+
                            ISNULL(tf_description3,'') + ' ')) AS [data()]
                        FROM ssp_appearing
                        where  ssp_appearing.IQ_CC_KEY = RL_GUIDS.iq_cc_key
                        FOR XML PATH('')))),'  ',' ')) as appearing,
               ISNULL((SELECT distinct title120 = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/title120') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_title120,
            ISNULL((SELECT distinct desc100 = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/desc100') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_desc100,
                ISNULL((SELECT distinct iq_class_num = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_class_num') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_class_num,
                ISNULL((SELECT distinct iq_class = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_class') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_class,
                ISNULL((SELECT distinct iq_start_point = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_start_point') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_start_point,
                RL_Station.dma_num as IQ_Dma_Num,
                RL_STATION.station_affil_num
               

from
                RL_CC_TEXT
                        inner join RL_GUIDS
                                on RL_GUIDS.iq_cc_key = RL_CC_TEXT.iq_cc_key
                                  inner join RL_STATION
                                on RL_STATION.RL_STATION_ID = RL_CC_TEXT.RL_STATION_ID

                        left outer join
                                (
                                        select IQ_CC_KEY,
                                                   XML_DATA = CONVERT(xml,LTRIM(' '+ (select LTRIM(RTRIM(ISNULL(title120,'')+' ')) as 'title120',
                                                        LTRIM(RTRIM(ISNULL(desc100,'')+' '))  as 'desc100',
                                                        LTRIM(RTRIM(ISNULL(iq_class_num,'')+' '))  as 'iq_class_num',
                                                        LTRIM(RTRIM(ISNULL(iq_class,'')+' '))  as 'iq_class',
                                                        LTRIM(RTRIM(ISNULL(IQ_Dma_Num,'')+' '))  as 'IQ_Dma_Num',
                                                        LTRIM(RTRIM(ISNULL(IQ_Dma_Name,'')+' '))  as 'IQ_Dma_Name',
                                                        LTRIM(RTRIM(ISNULL(station_affil_num,'')+' '))  as 'station_affil_num',
                                                        LTRIM(RTRIM(ISNULL(station_affil,'')+' '))  as 'station_affil',
                                                        LTRIM(RTRIM(ISNULL(iq_start_point,'')+' '))  as 'iq_start_point'
                                                                from STATSKEDPROG STATSKEDPROG2
                                                where STATSKEDPROG2.IQ_CC_Key =STATSKEDPROG1.IQ_CC_Key
                                                For XML PATH('list'))))
                                from STATSKEDPROG STATSKEDPROG1 GROUP BY IQ_CC_KEY ) as custom_STATSKEDPROG
                                        on RL_GUIDS.iq_cc_key = custom_STATSKEDPROG.IQ_CC_KEY
where
                CC_Ingest_Date is null
union all
select
                RL_GUIDS.RL_GUID as guid,
                RL_GUIDS.IQ_CC_Key as iq_cc_key,
                '/opt/solr/RL_CC_Text_Files/' + RL_CC_TEXT.RL_CC_FileName AS CCTxtFile,
                RL_CC_TEXT.RL_Station_ID as stationid,
                RL_CC_TEXT.RL_Station_Time as hour,
                Convert(varchar, RL_CC_TEXT.RL_Station_Date) as ClipDate,
                (Convert(varchar,RL_CC_TEXT.RL_Station_Date)+'T'+ RIGHT('0'+Convert(varchar,(RL_CC_TEXT.RL_Station_Time/100)),2)+':00:00') as RL_Station_DateTime,
                RL_STATION.time_zone as timezone,
                RL_STATION.dma_name as market,
                RL_STATION.station_affil as affiliate,
                RL_STATION.gmt_adj as gmtadj,
                RL_STATION.dst_adj as dstadj,
                (SELECT
                                                        REPLACE(LTRIM(RTRIM((SELECT  LTRIM(RTRIM(ISNULL(tf_title,'')+' '+
                            ISNULL(tf_host,'') + ' ' +
                            ISNULL(tf_cast1,'') + ' '+
                            ISNULL(tf_cast2,'') + ' '+
                            ISNULL(tf_cast3,'') + ' '+
                            ISNULL(tf_cast4,'') + ' '+
                            ISNULL(tf_cast5,'') + ' '+
                            ISNULL(tf_cast6,'')+' '+
                            ISNULL(tf_description,'') + ' '+
                            ISNULL(tf_description2,'') + ' '+
                            ISNULL(tf_description3,'') + ' ')) AS [data()]
                        FROM ssp_appearing
                        where  ssp_appearing.IQ_CC_KEY = RL_GUIDS.iq_cc_key
                        FOR XML PATH('')))),'  ',' ')) as appearing,
               ISNULL((SELECT distinct title120 = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/title120') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_title120,
            ISNULL((SELECT distinct desc100 = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/desc100') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_desc100,
                ISNULL((SELECT distinct iq_class_num = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_class_num') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_class_num,
                ISNULL((SELECT distinct iq_class = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_class') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_class,
                ISNULL((SELECT distinct iq_start_point = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_start_point') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_start_point,
                RL_Station.dma_num as IQ_Dma_Num,
                RL_STATION.station_affil_num
               

from
                RL_CC_TEXT
                        inner join RL_GUIDS
                                on RL_GUIDS.iq_cc_key = RL_CC_TEXT.iq_cc_key
                                  inner join RL_STATION
                                on RL_STATION.RL_STATION_ID = RL_CC_TEXT.RL_STATION_ID

                        left outer join
                                (
                                        select IQ_CC_KEY,
                                                   XML_DATA = CONVERT(xml,LTRIM(' '+ (select LTRIM(RTRIM(ISNULL(title120,'')+' ')) as 'title120',
                                                        LTRIM(RTRIM(ISNULL(desc100,'')+' '))  as 'desc100',
                                                        LTRIM(RTRIM(ISNULL(iq_class_num,'')+' '))  as 'iq_class_num',
                                                        LTRIM(RTRIM(ISNULL(iq_class,'')+' '))  as 'iq_class',
                                                        LTRIM(RTRIM(ISNULL(IQ_Dma_Num,'')+' '))  as 'IQ_Dma_Num',
                                                        LTRIM(RTRIM(ISNULL(IQ_Dma_Name,'')+' '))  as 'IQ_Dma_Name',
                                                        LTRIM(RTRIM(ISNULL(station_affil_num,'')+' '))  as 'station_affil_num',
                                                        LTRIM(RTRIM(ISNULL(station_affil,'')+' '))  as 'station_affil',
                                                        LTRIM(RTRIM(ISNULL(iq_start_point,'')+' '))  as 'iq_start_point'
                                                                from STATSKEDPROG STATSKEDPROG2
                                                where STATSKEDPROG2.IQ_CC_Key =STATSKEDPROG1.IQ_CC_Key
                                                For XML PATH('list'))))
                                from STATSKEDPROG STATSKEDPROG1 GROUP BY IQ_CC_KEY ) as custom_STATSKEDPROG
                                        on RL_GUIDS.iq_cc_key = custom_STATSKEDPROG.IQ_CC_KEY
where
                CC_Ingest_Date is null
union all
select
                RL_GUIDS.RL_GUID as guid,
                RL_GUIDS.IQ_CC_Key as iq_cc_key,
                '/opt/solr/RL_CC_Text_Files/' + RL_CC_TEXT.RL_CC_FileName AS CCTxtFile,
                RL_CC_TEXT.RL_Station_ID as stationid,
                RL_CC_TEXT.RL_Station_Time as hour,
                Convert(varchar, RL_CC_TEXT.RL_Station_Date) as ClipDate,
                (Convert(varchar,RL_CC_TEXT.RL_Station_Date)+'T'+ RIGHT('0'+Convert(varchar,(RL_CC_TEXT.RL_Station_Time/100)),2)+':00:00') as RL_Station_DateTime,
                RL_STATION.time_zone as timezone,
                RL_STATION.dma_name as market,
                RL_STATION.station_affil as affiliate,
                RL_STATION.gmt_adj as gmtadj,
                RL_STATION.dst_adj as dstadj,
                (SELECT
                                                        REPLACE(LTRIM(RTRIM((SELECT  LTRIM(RTRIM(ISNULL(tf_title,'')+' '+
                            ISNULL(tf_host,'') + ' ' +
                            ISNULL(tf_cast1,'') + ' '+
                            ISNULL(tf_cast2,'') + ' '+
                            ISNULL(tf_cast3,'') + ' '+
                            ISNULL(tf_cast4,'') + ' '+
                            ISNULL(tf_cast5,'') + ' '+
                            ISNULL(tf_cast6,'')+' '+
                            ISNULL(tf_description,'') + ' '+
                            ISNULL(tf_description2,'') + ' '+
                            ISNULL(tf_description3,'') + ' ')) AS [data()]
                        FROM ssp_appearing
                        where  ssp_appearing.IQ_CC_KEY = RL_GUIDS.iq_cc_key
                        FOR XML PATH('')))),'  ',' ')) as appearing,
               ISNULL((SELECT distinct title120 = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/title120') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_title120,
            ISNULL((SELECT distinct desc100 = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/desc100') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_desc100,
                ISNULL((SELECT distinct iq_class_num = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_class_num') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_class_num,
                ISNULL((SELECT distinct iq_class = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_class') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_class,
                ISNULL((SELECT distinct iq_start_point = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_start_point') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_start_point,
                RL_Station.dma_num as IQ_Dma_Num,
                RL_STATION.station_affil_num
               

from
                RL_CC_TEXT
                        inner join RL_GUIDS
                                on RL_GUIDS.iq_cc_key = RL_CC_TEXT.iq_cc_key
                                  inner join RL_STATION
                                on RL_STATION.RL_STATION_ID = RL_CC_TEXT.RL_STATION_ID

                        left outer join
                                (
                                        select IQ_CC_KEY,
                                                   XML_DATA = CONVERT(xml,LTRIM(' '+ (select LTRIM(RTRIM(ISNULL(title120,'')+' ')) as 'title120',
                                                        LTRIM(RTRIM(ISNULL(desc100,'')+' '))  as 'desc100',
                                                        LTRIM(RTRIM(ISNULL(iq_class_num,'')+' '))  as 'iq_class_num',
                                                        LTRIM(RTRIM(ISNULL(iq_class,'')+' '))  as 'iq_class',
                                                        LTRIM(RTRIM(ISNULL(IQ_Dma_Num,'')+' '))  as 'IQ_Dma_Num',
                                                        LTRIM(RTRIM(ISNULL(IQ_Dma_Name,'')+' '))  as 'IQ_Dma_Name',
                                                        LTRIM(RTRIM(ISNULL(station_affil_num,'')+' '))  as 'station_affil_num',
                                                        LTRIM(RTRIM(ISNULL(station_affil,'')+' '))  as 'station_affil',
                                                        LTRIM(RTRIM(ISNULL(iq_start_point,'')+' '))  as 'iq_start_point'
                                                                from STATSKEDPROG STATSKEDPROG2
                                                where STATSKEDPROG2.IQ_CC_Key =STATSKEDPROG1.IQ_CC_Key
                                                For XML PATH('list'))))
                                from STATSKEDPROG STATSKEDPROG1 GROUP BY IQ_CC_KEY ) as custom_STATSKEDPROG
                                        on RL_GUIDS.iq_cc_key = custom_STATSKEDPROG.IQ_CC_KEY
where
                CC_Ingest_Date is null
union all
select
                RL_GUIDS.RL_GUID as guid,
                RL_GUIDS.IQ_CC_Key as iq_cc_key,
                '/opt/solr/RL_CC_Text_Files/' + RL_CC_TEXT.RL_CC_FileName AS CCTxtFile,
                RL_CC_TEXT.RL_Station_ID as stationid,
                RL_CC_TEXT.RL_Station_Time as hour,
                Convert(varchar, RL_CC_TEXT.RL_Station_Date) as ClipDate,
                (Convert(varchar,RL_CC_TEXT.RL_Station_Date)+'T'+ RIGHT('0'+Convert(varchar,(RL_CC_TEXT.RL_Station_Time/100)),2)+':00:00') as RL_Station_DateTime,
                RL_STATION.time_zone as timezone,
                RL_STATION.dma_name as market,
                RL_STATION.station_affil as affiliate,
                RL_STATION.gmt_adj as gmtadj,
                RL_STATION.dst_adj as dstadj,
                (SELECT
                                                        REPLACE(LTRIM(RTRIM((SELECT  LTRIM(RTRIM(ISNULL(tf_title,'')+' '+
                            ISNULL(tf_host,'') + ' ' +
                            ISNULL(tf_cast1,'') + ' '+
                            ISNULL(tf_cast2,'') + ' '+
                            ISNULL(tf_cast3,'') + ' '+
                            ISNULL(tf_cast4,'') + ' '+
                            ISNULL(tf_cast5,'') + ' '+
                            ISNULL(tf_cast6,'')+' '+
                            ISNULL(tf_description,'') + ' '+
                            ISNULL(tf_description2,'') + ' '+
                            ISNULL(tf_description3,'') + ' ')) AS [data()]
                        FROM ssp_appearing
                        where  ssp_appearing.IQ_CC_KEY = RL_GUIDS.iq_cc_key
                        FOR XML PATH('')))),'  ',' ')) as appearing,
               ISNULL((SELECT distinct title120 = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/title120') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_title120,
            ISNULL((SELECT distinct desc100 = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/desc100') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_desc100,
                ISNULL((SELECT distinct iq_class_num = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_class_num') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_class_num,
                ISNULL((SELECT distinct iq_class = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_class') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_class,
                ISNULL((SELECT distinct iq_start_point = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_start_point') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_start_point,
                RL_Station.dma_num as IQ_Dma_Num,
                RL_STATION.station_affil_num
               

from
                RL_CC_TEXT
                        inner join RL_GUIDS
                                on RL_GUIDS.iq_cc_key = RL_CC_TEXT.iq_cc_key
                                  inner join RL_STATION
                                on RL_STATION.RL_STATION_ID = RL_CC_TEXT.RL_STATION_ID

                        left outer join
                                (
                                        select IQ_CC_KEY,
                                                   XML_DATA = CONVERT(xml,LTRIM(' '+ (select LTRIM(RTRIM(ISNULL(title120,'')+' ')) as 'title120',
                                                        LTRIM(RTRIM(ISNULL(desc100,'')+' '))  as 'desc100',
                                                        LTRIM(RTRIM(ISNULL(iq_class_num,'')+' '))  as 'iq_class_num',
                                                        LTRIM(RTRIM(ISNULL(iq_class,'')+' '))  as 'iq_class',
                                                        LTRIM(RTRIM(ISNULL(IQ_Dma_Num,'')+' '))  as 'IQ_Dma_Num',
                                                        LTRIM(RTRIM(ISNULL(IQ_Dma_Name,'')+' '))  as 'IQ_Dma_Name',
                                                        LTRIM(RTRIM(ISNULL(station_affil_num,'')+' '))  as 'station_affil_num',
                                                        LTRIM(RTRIM(ISNULL(station_affil,'')+' '))  as 'station_affil',
                                                        LTRIM(RTRIM(ISNULL(iq_start_point,'')+' '))  as 'iq_start_point'
                                                                from STATSKEDPROG STATSKEDPROG2
                                                where STATSKEDPROG2.IQ_CC_Key =STATSKEDPROG1.IQ_CC_Key
                                                For XML PATH('list'))))
                                from STATSKEDPROG STATSKEDPROG1 GROUP BY IQ_CC_KEY ) as custom_STATSKEDPROG
                                        on RL_GUIDS.iq_cc_key = custom_STATSKEDPROG.IQ_CC_KEY
where
                CC_Ingest_Date is null
union all
select
                RL_GUIDS.RL_GUID as guid,
                RL_GUIDS.IQ_CC_Key as iq_cc_key,
                '/opt/solr/RL_CC_Text_Files/' + RL_CC_TEXT.RL_CC_FileName AS CCTxtFile,
                RL_CC_TEXT.RL_Station_ID as stationid,
                RL_CC_TEXT.RL_Station_Time as hour,
                Convert(varchar, RL_CC_TEXT.RL_Station_Date) as ClipDate,
                (Convert(varchar,RL_CC_TEXT.RL_Station_Date)+'T'+ RIGHT('0'+Convert(varchar,(RL_CC_TEXT.RL_Station_Time/100)),2)+':00:00') as RL_Station_DateTime,
                RL_STATION.time_zone as timezone,
                RL_STATION.dma_name as market,
                RL_STATION.station_affil as affiliate,
                RL_STATION.gmt_adj as gmtadj,
                RL_STATION.dst_adj as dstadj,
                (SELECT
                                                        REPLACE(LTRIM(RTRIM((SELECT  LTRIM(RTRIM(ISNULL(tf_title,'')+' '+
                            ISNULL(tf_host,'') + ' ' +
                            ISNULL(tf_cast1,'') + ' '+
                            ISNULL(tf_cast2,'') + ' '+
                            ISNULL(tf_cast3,'') + ' '+
                            ISNULL(tf_cast4,'') + ' '+
                            ISNULL(tf_cast5,'') + ' '+
                            ISNULL(tf_cast6,'')+' '+
                            ISNULL(tf_description,'') + ' '+
                            ISNULL(tf_description2,'') + ' '+
                            ISNULL(tf_description3,'') + ' ')) AS [data()]
                        FROM ssp_appearing
                        where  ssp_appearing.IQ_CC_KEY = RL_GUIDS.iq_cc_key
                        FOR XML PATH('')))),'  ',' ')) as appearing,
               ISNULL((SELECT distinct title120 = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/title120') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_title120,
            ISNULL((SELECT distinct desc100 = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/desc100') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_desc100,
                ISNULL((SELECT distinct iq_class_num = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_class_num') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_class_num,
                ISNULL((SELECT distinct iq_class = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_class') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_class,
                ISNULL((SELECT distinct iq_start_point = T.Item.value('.' , 'varchar(MAX)')
                                FROM XML_DATA.nodes('/list/iq_start_point') AS T(Item) FOR XML PATH(''),Root('list')),'<list />') as xml_iq_start_point,
                RL_Station.dma_num as IQ_Dma_Num,
                RL_STATION.station_affil_num
               

from
                RL_CC_TEXT
                        inner join RL_GUIDS
                                on RL_GUIDS.iq_cc_key = RL_CC_TEXT.iq_cc_key
                                  inner join RL_STATION
                                on RL_STATION.RL_STATION_ID = RL_CC_TEXT.RL_STATION_ID

                        left outer join
                                (
                                        select IQ_CC_KEY,
                                                   XML_DATA = CONVERT(xml,LTRIM(' '+ (select LTRIM(RTRIM(ISNULL(title120,'')+' ')) as 'title120',
                                                        LTRIM(RTRIM(ISNULL(desc100,'')+' '))  as 'desc100',
                                                        LTRIM(RTRIM(ISNULL(iq_class_num,'')+' '))  as 'iq_class_num',
                                                        LTRIM(RTRIM(ISNULL(iq_class,'')+' '))  as 'iq_class',
                                                        LTRIM(RTRIM(ISNULL(IQ_Dma_Num,'')+' '))  as 'IQ_Dma_Num',
                                                        LTRIM(RTRIM(ISNULL(IQ_Dma_Name,'')+' '))  as 'IQ_Dma_Name',
                                                        LTRIM(RTRIM(ISNULL(station_affil_num,'')+' '))  as 'station_affil_num',
                                                        LTRIM(RTRIM(ISNULL(station_affil,'')+' '))  as 'station_affil',
                                                        LTRIM(RTRIM(ISNULL(iq_start_point,'')+' '))  as 'iq_start_point'
                                                                from STATSKEDPROG STATSKEDPROG2
                                                where STATSKEDPROG2.IQ_CC_Key =STATSKEDPROG1.IQ_CC_Key
                                                For XML PATH('list'))))
                                from STATSKEDPROG STATSKEDPROG1 GROUP BY IQ_CC_KEY ) as custom_STATSKEDPROG
                                        on RL_GUIDS.iq_cc_key = custom_STATSKEDPROG.IQ_CC_KEY
where
                CC_Ingest_Date is null

	
END
