--- case when rxcreativeversion like '%&src3=%' then split_part(rxcreativeversion, '&src3=', 2) else rxcreativeversion end as rxcreativeversion_v2,

with visits as (
 select
       ddd.year
      ,ddd.date 
      ,v.countrycode
      ,v.rxcreativeversion as page 
      ,case when v.device = 'smartphone' then 'mobile' when v.device = '' or v.device is null then 'mobile' else lower(v.device) end as device
      ,lower(v.rxaudience) as role
      ,case 
          when v.rxservice = 'homeCare' then 'housekeeping' 
          when (v.rxservice is null or v.rxservice = '') then 'childcare'
          when lower(v.rxservice) = 'general' then 'childcare' 
       else lower(v.rxservice) end as vertical        
      ,v.rxcampaignname as page_type
      ,v.town as city
      ,case when v.rxcreativeversion like '%?refh%' then 'yes' else 'no' end as include_magazine       
      ,count(distinct v.visitorid) as visitors
        
    from intl.hive_visit v
      join reporting.dw_D_date ddd on date(v.startdate) = ddd.date
      join (
              select distinct
                year,
                rxcreativeversion,      
                count(distinct visitorid) as visitors

              from intl.hive_visit 
              where lower(rxcampaign) = 'seo' 
                and (memberid is null or signup = 'true') 
                and lower(rxaudience) in ('seeker', 'provider')
                and rxcampaignname not in ('Redirect', 'JobsByVerticalStateCity', 'ProfilesByVerticalStateCity')
                and year >= year(now())-2
              group by 1,2 
              having count(distinct visitorid) >= 100
           ) aa on v.year = aa.year and v.rxcreativeversion = aa.rxcreativeversion   
      
    where lower(v.rxcampaign) = 'seo' 
      and (v.memberid is null or v.signup=true) 
      and lower(rxaudience) in ('seeker','provider')
      and v.rxcampaignname not in ('Redirect','JobsByVerticalStateCity','ProfilesByVerticalStateCity')
      and ddd.year >= year(now())-2
    group by 1,2,3,4,5,6,7,8,9,10 
),

basics as (
   select
     ddd.year 
    ,ddd.date 
    ,m.countrycode 
    ,m.creativeversion as page     
    ,case when m.device = 'smartphone' then 'mobile' when m.device = '' or m.device is null then 'mobile' else lower(m.device) end as device
    ,lower(m.role) as role 
    ,case 
        when m.vertical = 'homeCare' then 'housekeeping' 
        when (m.vertical is null or m.vertical = '') then 'childcare' 
     else lower(m.vertical)  end as vertical   
    ,m.campaignname as page_type
    ,m.town as city
    ,case when m.creativeversion like '%?refh%' then 'yes' else 'no' end as include_magazine
    ,count(distinct m.memberid) as basics      
    
  from intl.hive_member m 
    join reporting.dw_d_date ddd on date(m.dateprofilecomplete) = ddd.date

  where lower(m.campaign) = 'seo'
    and ddd.year >= year(now())-2
    and m.IsInternalAccount = 'false'
    and m.role is not null    
    and m.campaignname not in ('Redirect','JobsByVerticalStateCity','ProfilesByVerticalStateCity')  
  group by 1,2,3,4,5,6,7,8,9,10
),

premiums as (
   select
     ddd.year 
    ,ddd.date  
    ,m.countrycode 
    ,m.creativeversion as page     
    ,case when m.device = 'smartphone' then 'mobile' when m.device = '' or m.device is null then 'mobile' else lower(m.device) end as device
    ,lower(m.role) as role
    ,case 
        when m.vertical = 'homeCare' then 'housekeeping' 
        when (m.vertical is null or m.vertical = '') then 'childcare' 
     else lower(m.vertical)  end as vertical   
    ,m.campaignname as page_type
    ,m.town as city 
    ,case when m.creativeversion like '%?refh%' then 'yes' else 'no' end as include_magazine
    ,count(distinct sp.subscriptionId) as premiums
    
  from intl.transaction tr
  join intl.hive_subscription_plan sp                                             on sp.subscriptionId = tr.subscription_plan_id and sp.countrycode = tr.country_code   
  join reporting.dw_d_date ddd                                                    on date(sp.subscriptionDateCreated) = ddd.date   
  join intl.hive_member m                                                         on tr.member_id = m.memberid and tr.country_code = m.countrycode

  where tr.type in ('PriorAuthCapture','AuthAndCapture')
    and tr.status = 'SUCCESS' 
    and tr.amount > 0 
    and lower(m.campaign) = 'seo'
    and ddd.year >= year(now())-2
    and m.IsInternalAccount = 'false'
    and m.role is not null      
    and m.campaignname not in ('Redirect','JobsByVerticalStateCity','ProfilesByVerticalStateCity') 
  group by 1,2,3,4,5,6,7,8,9,10 
)

select 
    coalesce(vi.year, ba.year, pr.year) as year
   ,coalesce(vi.date, ba.date, pr.date) as date 
   ,date(current_date) as run_date
   ,coalesce(vi.countrycode, ba.countrycode, pr.countrycode) as country
   ,coalesce(vi.page, ba.page, pr.page) as page
   ,coalesce(vi.device, ba.device, pr.device) as device
   ,coalesce(vi.role, ba.role, pr.role) as role
   ,coalesce(vi.vertical, ba.vertical, pr.vertical) as vertical
   ,coalesce(vi.page_type, ba.page_type, pr.page_type) as page_type
   ,coalesce(vi.city, ba.city, pr.city) as city
   ,coalesce(vi.include_magazine, ba.include_magazine, pr.include_magazine) as include_magazine

   ,ifnull(sum(visitors),0) as visitors
   ,ifnull(sum(basics),0) as basics
   ,ifnull(sum(premiums),0) as premiums

from visits vi   
 left join basics ba      on ba.year = vi.year and ba.date = vi.date and ba.countrycode = vi.countrycode and ba.page = vi.page and ba.device = vi.device and ba.role = vi.role
                              and ba.vertical = vi.vertical and ba.page_type = vi.page_type and ba.city = vi.city and ba.include_magazine = vi.include_magazine 
                              
  left join premiums pr   on pr.year = vi.year and pr.date = vi.date and pr.countrycode = vi.countrycode and pr.page = vi.page and pr.device = vi.device and pr.role = vi.role
                              and pr.vertical = vi.vertical and pr.page_type = vi.page_type and pr.city = vi.city and pr.include_magazine = vi.include_magazine 

group by 1,2,3,4,5,6,7,8,9,10,11
