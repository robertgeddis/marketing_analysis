
--- WITH UTM

select distinct 
  lower(rxcampaign) as campaign,
  lower(rxsite) as site,
  split_part(entryurl, '?', 1) as url,
  regexp_substr(entryurl, 'rx=([^&]+)', 1, 1, '', 1) as rx_tracking,
  regexp_substr(entryurl, 'utm_source=([^&]+)', 1, 1, '', 1) as utm_source,
  regexp_substr(entryurl, 'utm_medium=([^&]+)', 1, 1, '', 1) as utm_medium,
  regexp_substr(entryurl, 'utm_campaign=([^&]+)', 1, 1, '', 1) as utm_campaign,
  regexp_substr(entryurl, 'utm_content=([^&]+)', 1, 1, '', 1) as utm_content,
  regexp_substr(entryurl, 'utm_term=([^&]+)', 1, 1, '', 1) as utm_term  
from intl.hive_visit
where year = year(now())
  and month = month(now())
  and regexp_like(lower(rxcampaign), 'sem|online|affiliate|email')
  and lower(rxsite) not like 'careus%'
  and entryurl like '%rx=%'
  and entryurl like '%utm%' 
;

--- TRACKING UTM COMPLETION

select distinct 
  case when lower(rxcampaign) like '%sem%' then 'SEM'
       when lower(rxcampaign) like '%online%' then 'Online'
       when lower(rxcampaign) like '%affiliate%' then 'Affiliate'
       when lower(rxcampaign) like '%email%' then 'Email'
    else initcap(rxcampaign) end as campaign,
  count(distinct entryurl) as urls,
  count(distinct case when entryurl like '%utm%' then entryurl end) as url_utm,
  (count(distinct entryurl)-count(distinct case when entryurl like '%utm%' then entryurl end)) as url_no_utm,
  ((count(distinct case when entryurl like '%utm%' then entryurl end)/count(distinct entryurl))*100) as '% utm'
from intl.hive_visit
where year = year(now())
  and month = month(now())
  and regexp_like(lower(rxcampaign), 'sem|online|affiliate|email')
  and lower(rxsite) not like 'careus%'
  and entryurl like '%rx=%'
group by 1
;

--- WITHOUT UTM TRACKING

select distinct 
  case when lower(rxcampaign) like '%sem%' then 'SEM'
       when lower(rxcampaign) like '%online%' then 'Online'
       when lower(rxcampaign) like '%affiliate%' then 'Affiliate'
       when lower(rxcampaign) like '%email%' then 'Email'
    else initcap(rxcampaign) end as campaign,
  rxsite,  
  entryurl as urls
from intl.hive_visit
where year = year(now())
  and month = month(now())
  and regexp_like(lower(rxcampaign), 'sem|online|affiliate|email')
  and lower(rxsite) not like 'careus%'
  and entryurl like '%rx=%'
  and entryurl not like '%utm%'
