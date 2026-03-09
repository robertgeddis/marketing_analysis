select 
  dd.date, dc.Current_Date_SameDay,
  upper(ab.country) as country, initcap(ab.role) as role, initcap(ab.device) as device, initcap(ab.vertical) as vertical, initcap(ab.page_type) as page_type, 
  sum(ab.visits) as visits, 
  sum(ab.non_member_visits) as non_member_visits,
  sum(ab.bounces) as bounces, 
  sum(ab.reached_enrollment) as reached_enrollment,
  sum(ab.basics) as basics, 
  sum(ab.closed_account_sameday) as closed_account_sameday,
  sum(ab.day1s) as day1s, 
  sum(ab.nths) as nths, 
  sum(ab.reupgrades) as reupgrades
  
from
(with visits as (
      select
         date(v.startDate) as date, 
         v.countrycode,
         lower(v.rxaudience) as role,
         case when lower(v.device) = 'smartphone' then 'mobile' 
              when ( v.device = '' or v.device is null ) then 'empty' 
           else lower(v.device) end as device,
         case when lower(v.rxservice) = 'homecare' then 'housekeeping' else lower(v.rxservice) end as vertical,     
         case when lower(v.rxcreativeversion) like '%?refh%' then 'magazine-article' 
              when (lower(v.rxcampaignname) = '' or lower(v.rxcampaignname) is null) then 'Other' 
            else lower(v.rxcampaignname) end as page_type,     
         count(distinct v.visitorid) as visits, 
         count(distinct case when (v.memberid is null or v.signup = true) then v.visitorid end) as non_member_visits,
         count(distinct case when (v.memberid is null or v.signup = true) and v.pageViews = 1 then v.visitorid end) as bounces,
         count(distinct enr.visitorid) as reached_enrollment   
      from intl.hive_visit v
      left join intl.hive_event enr   on enr.countrycode = v.countrycode and enr.visitorid = v.visitorid and enr.datecreated > v.startDate
                                      and enr.name = 'PageView' and (enr.currentpageurl like '%join-now%' or enr.currentpageurl like '%register%') 
                                      and enr.year >= year(now())-2 and date(enr.datecreated) < date(current_date)
      where lower(v.rxcampaign) = 'seo'  
        and v.year >= year(now())-2
        and date(v.startDate) < date(current_date)
      group by 1,2,3,4,5,6 
  ),

  basics as (
      select 
         date(m.dateMemberSignup) as date,
         m.countrycode,
         case when (m.role = '' or m.role is null) then 'seeker' else lower(m.role) end as role,
         case when lower(m.device) = 'smartphone' then 'mobile' 
              when ( m.device = '' or m.device is null ) then 'empty' 
           else lower(m.device) end as device,
          case when m.vertical = 'homeCare' then 'Housekeeping' 
               when (m.vertical is null or m.vertical = '') then 'Childcare' 
            else initcap(lower(m.vertical)) end as vertical,
          case when lower(m.creativeversion) like '%?refh%' then 'magazine-article' 
              when (lower(m.campaignname) = '' or lower(m.campaignname) is null) then 'Other' 
            else lower(m.campaignname) end as page_type,  
         count(distinct m.memberid) as basics,
         count(distinct c.memberid) as closed_account_sameday
      from intl.hive_member m
        left join intl.hive_event c on c.countrycode = m.countrycode and c.memberid = m.memberid and date(c.datecreated) = date(m.dateMemberSignup)
                                    and c.name = 'AccountActionRequest' and c.accountAction = 'Close' and c.year >= year(now())-2
      where year(m.dateMemberSignup) >= year(now())-2
        and lower(m.campaign) = 'seo'
        and m.isinternalaccount = 'false'
      group by 1,2,3,4,5,6      
  ),

  premiums as (
      select
        date(s.subscriptionDateCreated) as date,
        m.countrycode,
        case when (m.role = '' or m.role is null) then 'seeker' else lower(m.role) end as role,
        case when lower(m.device) = 'smartphone' then 'mobile' 
             when ( m.device = '' or m.device is null ) then 'empty' 
           else lower(m.device) end as device,
        case when m.vertical = 'homeCare' then 'Housekeeping' 
             when (m.vertical is null or m.vertical = '') then 'Childcare' 
          else initcap(lower(m.vertical)) end as vertical, 
        case when lower(m.creativeversion) like '%?refh%' then 'magazine-article' 
             when (lower(m.campaignname) = '' or lower(m.campaignname) is null) then 'Other' 
          else lower(m.campaignname) end as page_type, 
        count(distinct case when date(m.dateFirstPremiumSignup)  = date(s.subscriptionDateCreated) and date(m.dateFirstPremiumSignup) = date(m.datemembersignup) then s.subscriptionId end) as day1s,
        count(distinct case when date(m.dateFirstPremiumSignup)  = date(s.subscriptionDateCreated) and date(m.dateFirstPremiumSignup) <> date(m.datemembersignup) then s.subscriptionId end) as nths,
        count(distinct case when date(m.dateFirstPremiumSignup) != date(s.subscriptionDateCreated) then s.subscriptionId end) as reupgrades   
      from intl.transaction t
        join intl.hive_subscription_plan s  on s.subscriptionId = t.subscription_plan_id and s.countrycode = t.country_code   
        join intl.hive_member m             on t.member_id = m.memberid and t.country_code = m.countrycode
      where t.type in ('PriorAuthCapture','AuthAndCapture')
        and t.status = 'SUCCESS' 
        and t.amount > 0 
        and year(s.subscriptionDateCreated) >= year(now())-2
        and lower(m.campaign) = 'seo'
        and m.IsInternalAccount = 'false'
      group by 1,2,3,4,5,6    
  )

  select 
    coalesce(v.date, b.date, p.date) as date,
    coalesce(v.countrycode, b.countrycode, p.countrycode) as country,
    coalesce(v.role, b.role, p.role) as role,
    coalesce(v.device, b.device, p.device) as device,
    coalesce(v.vertical, b.vertical, p.vertical) as vertical,
    coalesce(v.page_type, b.page_type, p.page_type) as page_type,
    ifnull(sum(v.visits),0) as visits,
    ifnull(sum(v.non_member_visits),0) as non_member_visits,
    ifnull(sum(v.bounces),0) as bounces,
    ifnull(sum(v.reached_enrollment),0) as reached_enrollment,
    ifnull(sum(b.basics),0) as basics,
    ifnull(sum(b.closed_account_sameday),0) as closed_account_sameday,
    ifnull(sum(p.day1s),0) as day1s,
    ifnull(sum(p.nths),0) as nths,
    ifnull(sum(p.reupgrades),0) as reupgrades
  from visits v
  full outer join basics b    on v.date = b.date and v.countrycode = b.countrycode and v.role = b.role and v.device = b.device and v.vertical = b.vertical and v.page_type = b.page_type
  full outer join premiums p  on v.date = p.date and v.countrycode = p.countrycode and v.role = p.role and v.device = p.device and v.vertical = p.vertical and v.page_type = p.page_type                            
  group by 1,2,3,4,5,6) ab

join reporting.DW_D_DATE dd         on ab.date = dd.date 
join analytics.dw_d_date_current dc on dd.date = dc.date

group by 1,2,3,4,5,6,7
