--- PHOTOS
select
  year, quarter, legal_entity, category, 
  (sum(case when cohort = 'has_photo' then AvgProfileViews end)/sum(case when cohort = 'no_photo' then AvgProfileViews end)) as noticed,
  (sum(case when cohort = 'has_photo' then AvgThreadCount end)/sum(case when cohort = 'no_photo' then AvgThreadCount end)) as contacted,
  null as every_second
from (
  select 
    year, quarter, legal_entity, cohort, 'Provider Photo' as category,
    sum(profileViewsMem)/count(distinct memberid) as AvgProfileViews,
    sum(threads)/count(distinct memberid) as AvgThreadCount
  from (
    select 
      d.year, d.quarter,
      case when m.countrycode in ('at','be','de','dk','es','fb','fi','fr','ie','nl','no','se') then 'GmbH'
           when m.countrycode in ('au','nz') then 'AU/NZ'
           when m.countrycode in ('uk','ca','ch') then upper(m.countrycode) 
         end as legal_entity,
      m.memberid, 
      case when p.member_id is not null then 'has_photo' else 'no_photo' end as cohort,
      count(distinct case when pv.memberid is not null then pv.rowid end) as profileViewsMem,
      count(distinct msg.message_thread_id) as threads
    from intl.hive_member m 
    join reporting.DW_D_DATE d on d.date = date(m.datemembersignup) and d.year >= year(now())-1 
      join intl.vertical_profile vp on vp.member_id = m.memberid and vp.country_code = m.countrycode and vp.date_created >= m.datemembersignup
        and vp.search_status = 'Approved' and year(vp.date_created) >= year(now())-1 
      left join intl.photo p on p.country_code = m.countrycode and p.member_id = m.memberid and p.when_uploaded >= m.datemembersignup
        and p.is_primary is true and year(p.when_uploaded) >= year(now())-1  and p.first_approval_date is not null
      left join intl.hive_event pv on pv.countrycode = vp.country_code and pv.datecreated >= vp.date_created 
        and pv.providerid = vp.member_id and pv.profileid = vp.id and pv.memberid <> pv.providerid
        and pv.name = 'ProfileView' and year(pv.datecreated) >= year(now())-1 
      left join intl.message msg on msg.other_member_id = vp.member_id and msg.country_code = vp.country_code and msg.date_created >= vp.date_created
        and msg.sent_received = 'SENT' and msg.first_message is true and year(msg.date_created) >= year(now())-1 
    where m.role = 'provider' 
      and m.isinternalaccount is not true and m.closedforfraud is not true
      and m.accountstatus = 'Open'
    group by 1,2,3,4,5
  ) t group by 1,2,3,4,5
) abc group by 1,2,3,4 

union

--- REVIEWS
select
  year, quarter, legal_entity, category, 
  (sum(case when cohort = 'has_review' then AvgProfileViews end)/sum(case when cohort = 'no_review' then AvgProfileViews end)) as noticed,
  (sum(case when cohort = 'has_review' then AvgThreadCount end)/sum(case when cohort = 'no_review' then AvgThreadCount end)) as contacted,
  null as every_second
from (
 select 
    year, quarter, legal_entity, cohort, 'Provider Review' as category,
    sum(profileViewsMem)/count(distinct memberid) as AvgProfileViews,
    sum(threads)/count(distinct memberid) as AvgThreadCount
  from (
    select 
      d.year, d.quarter,
      case when m.countrycode in ('at','be','de','dk','es','fb','fi','fr','ie','nl','no','se') then 'GmbH'
           when m.countrycode in ('au','nz') then 'AU/NZ'
           when m.countrycode in ('uk','ca','ch') then upper(m.countrycode) 
        end as legal_entity,        
       m.memberid,  
       case when r.reviewed_member_id is not null then 'has_review' else 'no_review' end as cohort,
       count(distinct case when pv.memberid is not null then pv.rowid end) as profileViewsMem,
       count(distinct msg.message_thread_id) as threads
    from intl.hive_member m 
    join reporting.DW_D_DATE d on d.date = date(m.datemembersignup) and d.year >= year(now())-1
      join intl.vertical_profile vp on vp.member_id = m.memberid and vp.country_code = m.countrycode and vp.date_created >= m.datemembersignup
        and year(vp.date_created) >= year(now())-1 and vp.search_status = 'Approved'
      left join intl.review r on r.country_code = m.countrycode and r.reviewed_member_id = m.memberid and r.date_created >= m.datemembersignup
        and year(r.date_created) >= year(now())-1 and r.search_status = 'Approved'
      left join intl.hive_event pv on pv.countrycode = vp.country_code and pv.datecreated >= vp.date_created 
        and pv.providerid = vp.member_id and pv.profileid = vp.id and pv.memberid <> pv.providerid
        and pv.name = 'ProfileView' and year(pv.datecreated) >= year(now())-1
      left join intl.message msg on msg.other_member_id = vp.member_id and msg.country_code = vp.country_code and msg.date_created >= vp.date_created
        and msg.sent_received = 'SENT' and msg.first_message is true and year(msg.date_created) >= year(now())-1
    where m.role = 'provider' 
      and m.isinternalaccount is not true and m.closedforfraud is not true
      and m.accountstatus = 'Open'
    group by 1,2,3,4,5
  ) t group by 1,2,3,4,5
) abc group by 1,2,3,4 

union

--- VERFICATIONS
select
  year, quarter, legal_entity, category, 
  (sum(case when cohort = 'has_verfication' then AvgProfileViews end)/sum(case when cohort = 'no_verification' then AvgProfileViews end)) as noticed,
  (sum(case when cohort = 'has_verfication' then AvgThreadCount end)/sum(case when cohort = 'no_verification' then AvgThreadCount end)) as contacted,
  null as every_second
from (
  select 
    year, quarter, legal_entity, cohort, 'Provider Verfication' as category,
    sum(profileViewsMem)/count(distinct memberid) as AvgProfileViews,
    sum(threads)/count(distinct memberid) as AvgThreadCount
  from (
    select 
       d.year, d.quarter,
       case when m.countrycode in ('at','be','de','dk','es','fb','fi','fr','ie','nl','no','se') then 'GmbH'
             when m.countrycode in ('au','nz') then 'AU/NZ'
             when m.countrycode in ('uk','ca','ch') then upper(m.countrycode) 
          end as legal_entity, 
       m.memberid, 
       case when r.member_id is not null then 'has_verfication' else 'no_verification' end as cohort,
       count(distinct case when pv.memberid is not null then pv.rowid end) as profileViewsMem,
       count(distinct msg.message_thread_id) as threads
    from intl.hive_member m 
    join reporting.DW_D_DATE d on d.date = date(m.datemembersignup) and d.year >= year(now())-1
      join intl.vertical_profile vp on vp.member_id = m.memberid and vp.country_code = m.countrycode and vp.date_created >= m.datemembersignup
        and year(vp.date_created) >= year(now())-1 and vp.search_status = 'Approved'      
      left join intl.member_verification r on r.country_code = m.countrycode and r.member_id = m.memberid and r.email_verified_date >= m.datemembersignup
        and year(r.email_verified_date) >= year(now())-1
      left join intl.hive_event pv on pv.countrycode = vp.country_code and pv.datecreated >= vp.date_created 
        and pv.providerid = vp.member_id and pv.profileid = vp.id and pv.memberid <> pv.providerid
        and pv.name = 'ProfileView' and year(pv.datecreated) >= year(now())-1
      left join intl.message msg on msg.other_member_id = vp.member_id and msg.country_code = vp.country_code and msg.date_created >= vp.date_created
        and msg.sent_received = 'SENT' and msg.first_message is true and year(msg.date_created) >= year(now())-1
    where m.role = 'provider' 
      and m.isinternalaccount is not true and m.closedforfraud is not true
      and m.accountstatus = 'Open'
    group by 1,2,3,4,5
  ) t group by 1,2,3,4,5
) abc group by 1,2,3,4


union

--- Apps
select
  year, quarter, legal_entity, 'Apps' as category,
  null as noticed,  
  null as contacted,
  avg(seconds_between_each) as every_second
from
  (select 
    d.year, d.quarter,
    case when j.country_code in ('at','be','de','dk','es','fb','fi','fr','ie','nl','no','se') then 'GmbH'
           when j.country_code in ('au','nz') then 'AU/NZ'
           when j.country_code in ('uk','ca','ch') then upper(j.country_code) 
         end as legal_entity,
    j.id as app, 
    datediff(second, lag(j.date_created) over (order by j.date_created), j.date_created) as seconds_between_each
  from intl.job_application j
  join reporting.DW_D_DATE d  on d.date = date(j.date_created) and d.year >= year(now())-1) abc
group by 1,2,3,4

union

--- Jobs
select
  year, quarter, legal_entity, 'Jobs' as category,
  null as noticed,  
  null as contacted,  
  avg(seconds_between_each) as every_second
from
  (select 
    d.year, d.quarter,
    case when j.country_code in ('at','be','de','dk','es','fb','fi','fr','ie','nl','no','se') then 'GmbH'
           when j.country_code in ('au','nz') then 'AU/NZ'
           when j.country_code in ('uk','ca','ch') then upper(j.country_code) 
         end as legal_entity,
    j.id as app, 
    datediff(second, lag(j.date_created) over (order by j.date_created), j.date_created) as seconds_between_each
  from intl.job j
  join reporting.DW_D_DATE d  on d.date = date(j.date_created) and d.year >= year(now())-1
  where search_status = 'Approved') abc
group by 1,2,3,4
