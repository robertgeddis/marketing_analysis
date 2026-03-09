/* 
--- NOTES ---
:: Excludes halo from results with logic 'lower(m.audience) = lower(m.role)' on lines 508 + 579
:: Excludes accounts closed for fraud in lines 552 + 624
:: If spend is manually assigned a vertical this is also done for basics and premiums
:: Recruitics fee included for DE providers with vertical as 'Other' - see line 306
*/

with spend as (

-- SEM 
  select distinct
     d.year, d.month, d.week_start_date, d.date,  
     initcap(sem.campaign_type) as role, 
     case when source_type <> 'GDN' and source <> 'YT' then 'SEM' 
          when source_type = 'GDN' then 'GDN'
          when source = 'YT' then 'YouTube'
      end as channel,   
     upper(country) as country, 
     case when source = 'YT' then 'Brand'
          when source_type = 'GDN' then 'Brand'
          when vertical is null then 'Brand' 
          when vertical = 'HomeCare' then 'Housekeeping'     
        else initcap(vertical) end as vertical,
     sem.currency,
     ifnull(sum(sem.cost),0) as spend_domestic_currency
  from intl.dw_f_campaign_spend_intl sem
    join reporting.DW_D_DATE d on date(sem.date) = d.date
  where d.year >= year(now())-1 
    and d.date < date(current_date)
    and sem.country is not null
  group by 1,2,3,4,5,6,7,8,9 
  
union

-- FACEBOOK
  select distinct
    d.year, d.month, d.week_start_date, d.date,
    initcap(campaign_Type) as role, 'Facebook' as channel,  
    case when upper(country) = 'EN' then 'CA' 
         when upper(country) = '_'  then 'AU' 
         when upper(country) = 'VE'  then 'DE' 
      else upper(country) end as country, 
    case when vertical = 'Child Care' then 'Childcare'
         when vertical = 'PetCare' then 'Petcare'
         when vertical = 'HouseKeeping' then 'Housekeeping'
         when vertical = 'Turtoring' then 'Tutoring'
         when vertical = 'other' then 'Brand' end as vertical,   
    fb.currency,
    ifnull(sum(spend),0) as spend_domestic_currency
  from intl.DW_F_FACEBOOK_SPEND_INTL fb
    join reporting.DW_D_DATE d on date(date_start) = d.date
  where d.year >= year(now())-1
    and d.date < date(current_date)
  group by 1,2,3,4,5,6,7,8,9 
  
union

-- QUALITY CLICK (Seekers)
  select distinct
    year, month, week_start_date, date,
    role, channel, country, vertical, currency,
    ifnull(sum(spend),0) as spend_domestic_currency
  from 
      (select distinct
        d.year, d.month, d.week_start_date, d.date,
       'Seeker' as role, 'Quality Click' as channel,     
        case when program in ('DE', 'AT', 'CH') then program
              when product like '%FR%' then 'FR'
              when product like '%BE_nl%' then 'BE'  
              when product like '%BE_fr%' then 'FB'  
              when product like '%DK%' then 'DK'  
              when product like '%FI%' then 'FI'  
              when product like '%NL%' then 'NL'  
              when product like '%SE%' then 'SE'  
              when product like '%IE%' then 'IE'  
              when product like '%ES%' then 'ES'  
              when product like '%AU%' then 'AU'  
              when product like '%NO%' then 'NO'
              when product like '%NZ%' then 'NZ'
              when product like '%UK%' then 'UK'
              when product like '%CA%' then 'CA'
         end as country, 
         case when partnerid = '372' then 'Childcare'
              when partnerid = '468' then 'Housekeeping'
              when partnerid = '472' then 'Housekeeping'
              when partnerid = '17' then 'Petcare'
              when partnerid = '480' then 'Petcare'
            else 'Other' end as vertical,
        'EUR' as currency,
         sum(qc.commission) as spend
      from intl.quality_click_spend qc
        join reporting.DW_D_DATE d on date(day) = d.date
      where partnerid not in ('435', '469')
        and (lower(product) not like '%alltagshelfer%' or lower(product) not like '%provider%') -- Assigned default to seekers as discussed with Fabian
        and d.year >= year(now())-1
        and d.date < date(current_date)
      group by 1,2,3,4,5,6,7,8,9) qc
  group by 1,2,3,4,5,6,7,8,9 
  
union

-- PUTZFRAU AGENTUR (DE Seekers HK)
  select distinct
    year, month, week_start_date, date,
    role, channel, country, vertical, currency,
    ifnull(sum(spend),0) as spend_domestic_currency
  from 
      (select distinct
        d.year, d.month, d.week_start_date, d.date,
       'Seeker' as role, 'Putzfrau Agentur' as channel,     
        case when program in ('DE', 'AT', 'CH') then program
              when product like '%FR%' then 'FR'
              when product like '%BE_nl%' then 'BE'  
              when product like '%BE_fr%' then 'FB'  
              when product like '%DK%' then 'DK'  
              when product like '%FI%' then 'FI'  
              when product like '%NL%' then 'NL'  
              when product like '%SE%' then 'SE'  
              when product like '%IE%' then 'IE'  
              when product like '%ES%' then 'ES'  
              when product like '%AU%' then 'AU'  
              when product like '%NO%' then 'NO'
              when product like '%NZ%' then 'NZ'
              when product like '%UK%' then 'UK'
              when product like '%CA%' then 'CA'
         end as country, 
         'Housekeeping' as vertical,
        'EUR' as currency,
         sum(qc.commission) as spend
      from intl.quality_click_spend qc
        join reporting.DW_D_DATE d on date(day) = d.date
      where partnerid = '469'
        and (lower(product) not like '%alltagshelfer%' or lower(product) not like '%provider%') -- Assigned default to seekers as discussed with Fabian
        and d.year >= year(now())-1
        and d.date < date(current_date)
      group by 1,2,3,4,5,6,7,8,9) qc
  group by 1,2,3,4,5,6,7,8,9 

union

-- PUTZCHECKER (DE Seekers)
  select 
    d.year, d.month, d.week_start_date, d.date,
    'Seeker' as role, 'Putzchecker' as channel,
    'DE' as country, 'Housekeeping' as vertical, 'EUR' as currency,
    ifnull((sum(clicks)*1.5),0) as spend_domestic_currency
  from intl.quality_click_cpc
    join reporting.DW_D_DATE d on date(day) = d.date
  where d.year >= year(now())-1
    and d.date < date(current_date)
  group by 1,2,3,4,5,6,7,8,9 
  
union

-- MIBABY (DE Seekers)
  select distinct d.year, d.month, d.week_start_date, d.date, 'Seeker' as role, 'MiBaby' as channel, 'DE' as country, 'Childcare' as vertical, 'EUR' as currency, ifnull(sum(DE_Seeker_Mibaby),0) as spend_domestic_currency 
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on spend_date = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7,8,9

union

-- AWIN
  select distinct
    d.year, d.month, d.week_start_date, d.date,
    case when aw.commission_group_code in ('REG_P','REGP') then 'Provider' else 'Seeker' end as role, 'Awin' as channel, 
    case when advertiser_id = '10557' then 'DE'
         when advertiser_id = '10709' then 'AT'   
         when advertiser_id = '45671' then 'UK' 
      end as country,  
    'Other' as vertical,  
  	case when advertiser_id in ('10557', '10709') then 'EUR' else 'GBP' end as currency,	   
    ifnull((sum(aw.commission_amount)*1.3),0) as spend_domestic_currency
  from intl.awin_spend aw
    join reporting.DW_D_DATE d on date(aw.transaction_Date) = d.date
  where d.year >= year(now())-1
    and d.date < date(current_date)
    and lower(aw.commissionStatus) in ('approved', 'pending')
	group by 1,2,3,4,5,6,7,8,9 
	
union

-- MEINESTADT (DE Seekers)
  select distinct
     d.year, d.month, d.week_start_date, d.date,
     'Seeker' as role, 'Meinestadt' as channel, 'DE' as country, vertical, 'EUR' as currency,
     ifnull(sum(case when spend.year = spend.current_year and spend.month = spend.current_month then ((spend)/current_days) else ((spend)/days_in_month) end),0) as spend_domestic_currency
  from (
    select distinct
      year(sp.subscriptionDateCreated) as year,
      month(sp.subscriptionDateCreated) as month,
      date_part('day', last_day(sp.subscriptionDateCreated)) as days_in_month,
      date_part('day', current_date()-1) as current_days,
      month(current_date()-1) as current_month,
      year(current_date()-1) as current_year,
       case when lower(m.service) in ('br', 'all') then 'Brand'
           when (lower(m.service) not in ('br', 'all') and m.vertical = 'homeCare') then 'Housekeeping' 
           when (lower(m.service) not in ('br', 'all') and (m.vertical is null or m.vertical = '')) then 'Childcare' 
        else initcap(lower(m.vertical)) end as vertical,
      count(distinct sp.subscriptionId) as premiums,
      case when count(distinct sp.subscriptionId)<=150 then (count(distinct sp.subscriptionId)*80) 
        when count(distinct sp.subscriptionId)>150 then (150*80)+((count(distinct sp.subscriptionId)-150)*120) end as 'Spend' 
    from intl.transaction t
      join intl.hive_subscription_plan sp on sp.subscriptionId = t.subscription_plan_id and sp.countrycode = t.country_code
        and year(sp.subscriptionDateCreated) >= year(now())-1 and date(sp.subscriptionDateCreated) < date(current_date)
      join intl.hive_member m on t.member_id = m.memberid and t.country_code = sp.countrycode and date(m.dateFirstPremiumSignup) = date(sp.subscriptionDateCreated)
        and m.IsInternalAccount is not true
        and lower(m.role) = 'seeker' and lower(m.audience) = 'seeker'
        and lower(m.campaign) = 'online' and lower(m.site) = 'meinestadt.de' 
    where t.type in ('PriorAuthCapture','AuthAndCapture') and t.status = 'SUCCESS' and t.amount > 0
      and t.country_code = 'de'      
      and year(t.date_created) >= year(now())-1 and date(t.date_created) < date(current_date)
    group by 1,2,3,4,5,6,7
  ) spend
    join reporting.DW_D_DATE d on spend.year = d.year and spend.month = d.month and d.year >= year(now())-1 and d.date < date(current_date)
    group by 1,2,3,4,5,6,7,8,9 
      
union   

-- PINTEREST (DE, UK, CA + AU Seekers)
  select distinct d.year, d.month, d.week_start_date, d.date, 'Seeker' as role, 'Pinterest' as channel, 'DE' as country, 'Brand' as vertical, 'EUR' as currency, ifnull(sum(DE_Seeker_Pinterest),0) as spend_domestic_currency 
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on spend_date = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7,8,9
  union
  select distinct d.year, d.month, d.week_start_date, d.date, 'Seeker' as role, 'Pinterest' as channel, 'UK' as country, 'Brand' as vertical, 'EUR' as currency, ifnull(sum(UK_Seeker_Pinterest),0) as spend_domestic_currency 
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on spend_date = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7,8,9
  union
  select distinct d.year, d.month, d.week_start_date, d.date, 'Seeker' as role, 'Pinterest' as channel, 'CA' as country, 'Brand' as vertical, 'EUR' as currency, ifnull(sum(CA_Seeker_Pinterest),0) as spend_domestic_currency 
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on spend_date = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7,8,9
  union
  select distinct d.year, d.month, d.week_start_date, d.date, 'Seeker' as role, 'Pinterest' as channel, 'AU' as country, 'Brand' as vertical, 'EUR' as currency, ifnull(sum(AU_Seeker_Pinterest),0) as spend_domestic_currency 
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on spend_date = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7,8,9

union

-- TV (DE Seekers)
  select distinct
    d.year, d.month, d.week_start_date, d.date, 
    'Seeker' as role, 'TV' as channel, 'DE' as country, 'Housekeeping' as vertical, 'EUR' as currency,
    ifnull(sum(DE_TV),0) as spend_domestic_currency
  from intl.DW_MARKETING_SPEND_INTL
    join reporting.DW_D_DATE d on date(spend_date) = d.date
  where d.year >= year(now())-1
    and d.date < date(current_date)
  group by 1,2,3,4,5,6,7,8,9 
  
union

-- SPOTIFY (DE SEEKERS ONLY)
  select distinct
    d.year, d.month, d.week_start_date, d.date,
    'Seeker' as role, 'Spotify' as channel, 'DE' as country, 'Brand' as vertical, 'EUR' as currency,
    ifnull(sum(spend),0) as spend_domestic_currency
  from intl.spotify_spend sy
  join reporting.DW_D_DATE d on date(sy.start_date) = d.date
  where d.year >= year(now())-1
    and d.date < date(current_date)
	group by 1,2,3,4,5,6,7,8,9 

union

-- IMPACT (CA SEEKERS ONLY)
  select distinct d.year, d.month, d.week_start_date, d.date, 'Seeker' as role, 'Impact' as channel, 'CA' as country, 'Other' as vertical, 'EUR' as currency, ifnull(sum(CA_OTHER_ONLINE),0) as spend_domestic_currency 
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on spend_date = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7,8,9  
  union
  select distinct d.year, d.month, d.week_start_date, d.date, 'Seeker' as role, 'Impact' as channel, 'AU' as country, 'Other' as vertical, 'EUR' as currency, ifnull(sum(AU_OTHER_ONLINE),0) as spend_domestic_currency 
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on spend_date = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7,8,9  
  
union

-- KLEINANZEIGEN (DE Seeker) *** Using DE_Seeker_Nebenan column in intl.DW_MARKETING_SPEND_INTL
  select distinct d.year, d.month, d.week_start_date, d.date, 'Seeker' as role, 'Kleinanzeigen' as channel, 'DE' as country, 'Other' as vertical, 'EUR' as currency, ifnull(sum(DE_Seeker_Nebenan),0) as spend_domestic_currency
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on date(spend_date) = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7,8,9 
  
union

-- QUALITY CLICK (Providers)
  select distinct
    year, month, week_start_date, date,
    role, channel, country, vertical, currency,
    ifnull(sum(spend),0) as spend_domestic_currency
  from 
      (select distinct
        d.year, d.month, d.week_start_date, d.date,
       'Provider' as role, 'Quality Click' as channel,      
        case when program in ('DE', 'AT', 'CH') then program
             when product like '%FR%' then 'FR'
             when product like '%BE_nl%' then 'BE'  
             when product like '%BE_fr%' then 'FB'  
             when product like '%DK%' then 'DK'  
             when product like '%FI%' then 'FI'  
             when product like '%NL%' then 'NL'  
             when product like '%SE%' then 'SE'  
             when product like '%IE%' then 'IE'  
             when product like '%ES%' then 'ES'  
             when product like '%AU%' then 'AU'  
             when product like '%NO%' then 'NO'
             when product like '%NZ%' then 'NZ'
             when product like '%UK%' then 'UK'
             when product like '%CA%' then 'CA'
         end as country, 
         case when partnerid = '372' then 'Childcare'
              when partnerid = '468' then 'Housekeeping'
              when partnerid = '472' then 'Housekeeping'
              when partnerid = '17' then 'Petcare'
              when partnerid = '480' then 'Petcare'
            else 'Other' end as vertical,
        'EUR' as currency,
         ( sum(qc.commission) + sum(qc.currency) ) as spend
      from intl.quality_click_spend qc
        join reporting.DW_D_DATE d on date(day) = d.date
      where partnerid <> 435
        and (lower(product) like '%alltagshelfer%' or lower(product) like '%provider%') 
        and d.year >= year(now())-1
        and d.date < date(current_date)
      group by 1,2,3,4,5,6,7,8,9) qc 
  group by 1,2,3,4,5,6,7,8,9

union 

-- RECRUITICS (Providers)
  select distinct
    d.year, d.month, d.week_start_date, d.date, 
    'Provider' as role, 'Recruitics' as channel,
    case when rc.country in ('DE','') then 'DE' 
         when rc.country = 'GB' then 'UK'
        else rc.country end as country, 
    case when lower(categories)='childcare' then 'Childcare'
         when lower(categories)='homecare' then 'Housekeeping'
         when lower(categories)='petcare' then 'Petcare'
         when lower(categories)='seniorcare' then 'Seniorcare'
         when lower(categories)='tutoring' then 'Tutoring'
         when lower(categories)='specialneeds' then 'Specialneeds'
         when lower(categories)='aupair' then 'Aupair'
        else 'Other' end as Vertical,    
    'EUR' as currency,
    ifnull(sum(rc.spend),0) as spend_domestic_currency
  from intl.recruitics_spend_intl rc
    join reporting.DW_D_DATE d on date(rc.day) = d.date 
  where lower(rc.source) not in ('xxx','jobg8','jobg8auto','jobtome')
    and d.year >= year(now())-1 
    and d.date < date(current_date)
  group by 1,2,3,4,5,6,7,8,9  
  
union

-- RECRUITICS FEE (DE Providers Only)
select 
  d.year, d.month, d.week_start_date, d.date,
  'Provider' as role, 'Recruitics' as channel, 'DE' as country, 'Other' as vertical, currency,
  ifnull(sum(case when rc_fee.year = rc_fee.current_year and rc_fee.month = rc_fee.current_month then ((commission)/current_days) else ((commission)/days_in_month) end),0) as spend_domestic_currency
from
    (select 
      year(rc.day) as year,
      month(rc.day) as month,
      month(current_date()-1) as current_month,
      year(current_date()-1) as current_year,
      date_part('day', last_day(rc.day)) as days_in_month,
      date_part('day', current_date()-1) as current_days,
      currency,
      case when sum(spend) < '20000' then '2500'
           when sum(spend) between '20000' and '30000' then '3000'
           when sum(spend) between '30000' and '50000' then '3600'
           when sum(spend) between '50000' and '80000' then '5000'
           when sum(spend) > '80000' then '8000'
        else '3500' end as commission 
    from intl.recruitics_spend_intl rc
    where year(rc.day) >= year(now())-1 
      and date(rc.day) < date(current_date)
      and lower(source) not in ('xxx','jobg8','jobg8auto','jobtome')
    group by 1,2,3,4,5,6,7) rc_fee
join reporting.DW_D_DATE d on rc_fee.year = d.year and rc_fee.month = d.month and d.year >= year(now())-1 and d.date < date(current_date)
group by 1,2,3,4,5,6,7,8,9 

union

-- STUDENT JOB (Providers)
  select distinct
    d.year, d.month, d.week_start_date, d.date,
    'Provider' as role, 'StudentJob' as channel, 
    case when program in ('DE', 'AT', 'CH') then program
         when product like '%FR%' then 'FR'
         when product like '%BE_nl%' then 'BE'  
         when product like '%BE_fr%' then 'FB'  
         when product like '%DK%' then 'DK'  
         when product like '%FI%' then 'FI'  
         when product like '%NL%' then 'NL'  
         when product like '%SE%' then 'SE'  
         when product like '%IE%' then 'IE'  
         when product like '%ES%' then 'ES'  
         when product like '%AU%' then 'AU'  
         when product like '%NO%' then 'NO'
         when product like '%NZ%' then 'NZ'
         when product like '%UK%' then 'UK'
         when product like '%CA%' then 'CA'
       end as country,
    'Other' as vertical,   
    'EUR' as currency,                 
    ifnull(sum(case when qc.program='DE' and d.year <= 2022 then qc.count*2 
             when qc.program='DE' and d.year > 2022 then qc.count*3.5 
             when qc.product like '%SE%' and d.year <= 2022 then qc.count*2 
             when qc.product like '%SE%' and d.year > 2022 then qc.count*4
             when qc.product like '%UK%' and d.year <= 2022 then qc.count*1.5
             when qc.product like '%UK%' and d.year > 2022 then qc.count*3
             when qc.product like '%NL%' then qc.count*3.5 
             when qc.product like '%BE_nl%' and d.date < '2022-05-01' then qc.count*1.5
             when qc.product like '%BE_nl%' and d.date >= '2022-05-01' then  qc.count*3.5
         else qc.count*1 end),0) as spend_domestic_currency        
  from intl.quality_click_spend qc
    join reporting.DW_D_DATE d on date(day) = d.date     
  where partnerid = 435
    and (product like '%Alltagshelfer%' or product like '%Provider%')
    and d.year >= year(now())-1  
    and d.date < date(current_date)
  group by 1,2,3,4,5,6,7,8,9 

union 

-- APP JOBS (Providers)
  select distinct
    d.year, d.month, d.week_start_date, d.date,
    'Provider' as role, 'AppJobs' as channel, 
    case when country = 'Germany' then 'DE'
         when country = 'Canada' then 'CA' 
       end as country, 
    case when lower(category) like '%senior%' then 'Seniorcare'
         when lower(category) like '%babysitting%' then 'Childcare'
         when lower(category) like '%cleaning%' then 'Housekeeping'
         when lower(category) like '%pet%' then 'Petcare'
      else 'Other' end as vertical,   
    'EUR' as currency,
    ifnull(sum(total_spent_usd),0) as spend_domestic_currency           
  from intl.appjobs_spend aj
    join reporting.DW_D_DATE d on date(day) = d.date
  where d.year >= year(now())-1 
    and d.date < date(current_date)
  group by 1,2,3,4,5,6,7,8,9
  
union

-- APPCAST (DE + UK Providers) 
  select distinct d.year, d.month, d.week_start_date, d.date, 'Provider' as role, 'AppCast' as channel, 'DE' as country, 'Other' as veritcal, 'EUR' as currency, ifnull(sum(de_provider_appcast),0) as spend_domestic_currency 
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on spend_date = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7,8,9 
  union
  select distinct d.year, d.month, d.week_start_date, d.date, 'Provider' as role, 'AppCast' as channel, 'UK' as country, 'Other' as veritcal, 'GBP' as currency, ifnull(sum(uk_provider_appcast),0) as spend_domestic_currency 
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on spend_date = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7,8,9 

union 

-- MY PERFECT JOB (DE Providers)
  select distinct d.year, d.month, d.week_start_date, d.date, 'Provider' as role, 'MyPerfectJob' as channel, 'DE' as country, 'Other' as veritcal, 'EUR' as currency, ifnull(sum(DE_Provider_Myperfectjob),0) as spend_domestic_currency
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on date(spend_date) = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7,8,9 
  
union

-- JOB LIFT (DE Providers)
  select distinct d.year, d.month, d.week_start_date, d.date, 'Provider' as role, 'JobLift' as channel, 'DE' as country, 'Other' as veritcal, 'EUR' as currency, ifnull(sum(DE_PROVIDER_JOBLIFT),0) as spend_domestic_currency
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on date(spend_date) = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7,8,9 
  
union

-- ALLESKRALLE (DACH Providers)
  select distinct d.year, d.month, d.week_start_date, d.date, 'Provider' as role, 'AllesKralle' as channel, 'DE' as country, 'Other' as veritcal, 'EUR' as currency, ifnull(sum(DE_PROVIDER_ALLESKRALLE),0) as spend_domestic_currency
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on date(spend_date) = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7,8,9 
  union
  select distinct d.year, d.month, d.week_start_date, d.date, 'Provider' as role, 'AllesKralle' as channel, 'AT' as country, 'Other' as veritcal, 'EUR' as currency, ifnull(sum(AT_PROVIDER_ALLESKRALLE),0) as spend_domestic_currency
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on date(spend_date) = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7,8,9 
  union
  select distinct d.year, d.month, d.week_start_date, d.date, 'Provider' as role, 'AllesKralle' as channel, 'CH' as country, 'Other' as veritcal, 'EUR' as currency, ifnull(sum(CH_PROVIDER_ALLESKRALLE),0) as spend_domestic_currency
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on date(spend_date) = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7,8,9 
  
union

-- KLEINANZEIGEN (DE Providers) *** Using DE_Provider_Nebenan column in intl.DW_MARKETING_SPEND_INTL
  select distinct d.year, d.month, d.week_start_date, d.date, 'Provider' as role, 'Kleinanzeigen' as channel, 'DE' as country, 'Other' as veritcal, 'EUR' as currency, ifnull(sum(DE_Provider_Nebenan),0) as spend_domestic_currency
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on date(spend_date) = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7,8,9 
),

-- THIS IS FOR THE FIXED CURRENT USD FX RATES
fixed_current_fx as (
   select distinct
    d.year, d.month, d.week_start_date, d.date,
    source_currency as currency,
    currency_rate as fx_rate
  from reporting.DW_CARE_FX_RATES fx 
  join reporting.DW_D_DATE d on current_rate_date = d.date 
  where target_currency = 'USD'
    and currency_rate_type = 'Current'
    and source_currency in ('EUR','GBP','CAD','AUD')
  group by 1,2,3,4,5,6 
),

basics as (
   select
      d.year, d.month, d.week_start_date, d.date,
      case when m.role is null then 'Seeker' else initcap(m.role) end as role, 
      case when lower(m.campaign) = 'sem' then 'SEM' 
           when lower(m.site) = 'gdn' then 'GDN'
           when lower(m.site) = 'youtube' then 'YouTube'
           when lower(m.site) = 'facebook' then 'Facebook'
           when ( m.creativeversion not in ('472', '469') and lower(m.site) in ('absolventen','babysitter.de','blog','careerjet','criteo','erdbeerlounge','erdbeerlounge2','gelegenheitsjobs','generic','generictotal','glassdoor',
           'jobrobot','mapmeo','marktde','marktplaats','metajob','mitula','nannytax','njobs','palkkausfi','provider','qualityclick','quoka','rabathelten','recrudo','rubrikk','savethestudent','so.dk','stadtlist',
           'stellenwerk','studiumratgeber','aktuellejobs','jobkicks','ortsdienst','4everglen','snautz','jobrapido') ) then 'Quality Click' 
           when m.creativeversion = '472' then 'Putzchecker'
           when m.creativeversion = '469' then 'Putzfrau Agentur'
           when lower(m.site) = 'mibaby' then 'MiBaby'
           when lower(m.site) in ('awin', 'zanox') then 'Awin'
           when lower(m.site) in ('meinestadt.de', 'meinestadt', 'meinestadtp') then 'Meinestadt'
           when lower(m.site) = 'pinterest' then 'Pinterest'
           when lower(m.site) = 'spotify' then 'Spotify'
           when lower(m.site) = 'impact' then 'Impact'
           when lower(m.site) = 'kleinanzeigen' then 'Kleinanzeigen'
           when lower(m.site) in ('adzuna','adzunaauto','allthetopbananas','indeed','indeedauto','jobisj','jobisjob','jobisjobauto','jobisjobde','jobisjobdeauto','jobrapido',
           'jobrapidoauto','jobrapidoleads','jooble','joobleauto','jorapaid','neuvoo','trovit','trovitde','trovitdeauto','trovituk','trovituksauto','ziprecruiter','reach','monster') then 'Recruitics'
           when lower(m.site) = 'studentjob' then 'StudentJob'
           when lower(m.site) = 'appjobs' then 'AppJobs'
           when lower(m.site) = 'appcast' then 'AppCast'
           when lower(m.site) = 'myperfectjob' then 'MyPerfectJob'
           when lower(m.site) = 'joblift' then 'JobLift'
           when lower(m.site) = 'alleskralle' then 'AllesKralle'
        end as channel, 
      upper(m.countrycode) as country,
      case when lower(m.service) in ('br', 'all') then 'Brand'
           when (lower(m.service) not in ('br', 'all') and m.vertical = 'homeCare') then 'Housekeeping' 
           when (lower(m.service) not in ('br', 'all') and (m.vertical is null or m.vertical = '')) then 'Childcare'
           when m.creativeversion = '472' then 'Housekeeping'
           when m.creativeversion = '469' then 'Housekeeping'
           when m.creativeversion = '372' then 'Childcare'
           when m.creativeversion = '468' then 'Housekeeping'
           when m.creativeversion = '17' then 'Petcare'
           when m.creativeversion = '480' then 'Petcare'
           when lower(m.site) in ('absolventen','babysitter.de','blog','careerjet','criteo','erdbeerlounge','erdbeerlounge2','gelegenheitsjobs','generic','generictotal','glassdoor',
           'jobrobot','mapmeo','marktde','marktplaats','metajob','mitula','nannytax','njobs','palkkausfi','provider','quoka','rabathelten','recrudo','rubrikk','savethestudent','so.dk','stadtlist',
           'stellenwerk','studiumratgeber','aktuellejobs','jobkicks','ortsdienst','4everglen','jobrapido') then 'Other'
           when lower(m.site) = 'mibaby' then 'Childcare'
           when lower(m.site) in ('awin', 'zanox') then 'Other'
           when lower(m.site) = 'pinterest' then 'Brand'
           when lower(m.site) = 'spotify' then 'Brand'
           when lower(m.site) = 'impact' then 'Other'
           when lower(m.site) = 'kleinanzeigen' then 'Other'
           when lower(m.site) = 'studentjob' then 'Other'
           when lower(m.site) = 'appcast' then 'Other'
           when lower(m.site) = 'myperfectjob' then 'Other'
           when lower(m.site) = 'joblift' then 'Other'
           when lower(m.site) = 'alleskralle' then 'Other'
        else initcap(m.vertical) end as vertical, 
      count(distinct m.memberid) as basics  
    from intl.hive_member m   
    join reporting.DW_D_DATE d on date(m.dateMemberSignup) = d.date 
    where (
            lower(m.campaign) = 'sem' or 
            m.creativeversion = '472' or
            m.creativeversion = '469' or
            lower(m.site) in ('gdn','youtube','facebook','absolventen','babysitter.de','blog','careerjet','criteo','erdbeerlounge','erdbeerlounge2','gelegenheitsjobs','generic','generictotal','glassdoor',
            'jobrobot','mapmeo','marktde','marktplaats','metajob','mitula','nannytax','njobs','palkkausfi','provider','qualityclick','quoka','rabathelten','recrudo','rubrikk','savethestudent','so.dk','stadtlist',
            'stellenwerk','studiumratgeber','meinestadt','aktuellejobs','jobkicks','ortsdienst','4everglen','snautz','jobrapido','mibaby','awin','zanox','pinterest','spotify','impact','kleinanzeigen',
            'adzuna','adzunaauto','allthetopbananas','indeed','indeedauto','jobisj','jobisjob','jobisjobauto','jobisjobde','jobisjobdeauto','jobrapido','jobrapidoauto','jobrapidoleads','jooble','joobleauto','jorapaid',
            'neuvoo','trovit','trovitde','trovitdeauto','trovituk','trovituksauto','ziprecruiter','reach','monster','studentjob','appjobs','myperfectjob','joblift','alleskralle') or
            ( lower(m.site) in ('meinestadt.de', 'meinestadt', 'meinestadtp') and lower(m.role) = 'seeker')
           )
      and m.IsInternalAccount = 'false'
      and m.closedforfraud = 'false'
      and lower(m.audience) = lower(m.role)
      and d.year >= year(now())-1 
      and d.date < date(current_date)
    group by 1,2,3,4,5,6,7,8 
    
    union
    
    select
      d.year, d.month, d.week_start_date, d.date,
      'Seeker' as role, 'TV' as channel, 'DE' as country, 'Housekeeping' as vertical, 
      count(distinct m.memberid) as basics  
    from intl.hive_member m   
    join reporting.DW_D_DATE d on date(m.dateMemberSignup) = d.date 
    where m.howdidyouhear = 'tv'
      and m.countrycode = 'de'
      and lower(m.role) = 'seeker'
      and m.IsInternalAccount = 'false'
      and m.closedforfraud = 'false'
      and lower(m.audience) = lower(m.role)
      and d.year >= year(now())-1 
      and d.date < date(current_date)
    group by 1,2,3,4,5,6,7,8  
),

premiums as (
    select
      d.year, d.month, d.week_start_date, d.date,
      case when m.role is null then 'Seeker' else initcap(m.role) end as role, 
      case when lower(m.campaign) = 'sem' then 'SEM' 
           when lower(m.site) = 'gdn' then 'GDN'
           when lower(m.site) = 'youtube' then 'YouTube'
           when lower(m.site) = 'facebook' then 'Facebook'
           when ( m.creativeversion <> '472' and lower(m.site) in ('absolventen','babysitter.de','blog','careerjet','criteo','erdbeerlounge','erdbeerlounge2','gelegenheitsjobs','generic','generictotal','glassdoor',
           'jobrobot','mapmeo','marktde','marktplaats','metajob','mitula','nannytax','njobs','palkkausfi','provider','qualityclick','quoka','rabathelten','recrudo','rubrikk','savethestudent','so.dk','stadtlist',
           'stellenwerk','studiumratgeber','aktuellejobs','jobkicks','ortsdienst','4everglen','snautz','jobrapido') ) then 'Quality Click' 
           when m.creativeversion = '472' then 'Putzchecker'
           when m.creativeversion = '469' then 'Putzfrau Agentur'
           when lower(m.site) = 'mibaby' then 'MiBaby'
           when lower(m.site) in ('awin', 'zanox') then 'Awin'
           when lower(m.site) in ('meinestadt.de', 'meinestadt', 'meinestadtp') then 'Meinestadt'
           when lower(m.site) = 'pinterest' then 'Pinterest'
           when lower(m.site) = 'spotify' then 'Spotify'
           when lower(m.site) = 'impact' then 'Impact'
           when lower(m.site) = 'kleinanzeigen' then 'Kleinanzeigen'
           when lower(m.site) in ('adzuna','adzunaauto','allthetopbananas','indeed','indeedauto','jobisj','jobisjob','jobisjobauto','jobisjobde','jobisjobdeauto','jobrapido',
           'jobrapidoauto','jobrapidoleads','jooble','joobleauto','jorapaid','neuvoo','trovit','trovitde','trovitdeauto','trovituk','trovituksauto','ziprecruiter','reach','monster') then 'Recruitics'
           when lower(m.site) = 'studentjob' then 'StudentJob'
           when lower(m.site) = 'appjobs' then 'AppJobs'
           when lower(m.site) = 'appcast' then 'AppCast'
           when lower(m.site) = 'myperfectjob' then 'MyPerfectJob'
           when lower(m.site) = 'joblift' then 'JobLift'
           when lower(m.site) = 'alleskralle' then 'AllesKralle'
        end as channel, 
      upper(m.countrycode) as country,
      case when lower(m.service) in ('br', 'all') then 'Brand'
           when (lower(m.service) not in ('br', 'all') and m.vertical = 'homeCare') then 'Housekeeping' 
           when (lower(m.service) not in ('br', 'all') and (m.vertical is null or m.vertical = '')) then 'Childcare'
           when m.creativeversion = '472' then 'Housekeeping'
           when m.creativeversion = '469' then 'Housekeeping'
           when m.creativeversion = '372' then 'Childcare'
           when m.creativeversion = '468' then 'Housekeeping'
           when m.creativeversion = '17' then 'Petcare'
           when m.creativeversion = '480' then 'Petcare'
           when lower(m.site) in ('absolventen','babysitter.de','blog','careerjet','criteo','erdbeerlounge','erdbeerlounge2','gelegenheitsjobs','generic','generictotal','glassdoor',
           'jobrobot','mapmeo','marktde','marktplaats','metajob','mitula','nannytax','njobs','palkkausfi','provider','quoka','rabathelten','recrudo','rubrikk','savethestudent','so.dk','stadtlist',
           'stellenwerk','studiumratgeber','aktuellejobs','jobkicks','ortsdienst','4everglen','jobrapido') then 'Other'
           when lower(m.site) = 'mibaby' then 'Childcare'
           when lower(m.site) in ('awin', 'zanox') then 'Other'
           when lower(m.site) = 'pinterest' then 'Brand'
           when lower(m.site) = 'spotify' then 'Brand'
           when lower(m.site) = 'impact' then 'Other'
           when lower(m.site) = 'kleinanzeigen' then 'Other'
           when lower(m.site) = 'studentjob' then 'Other'
           when lower(m.site) = 'appcast' then 'Other'
           when lower(m.site) = 'myperfectjob' then 'Other'
           when lower(m.site) = 'joblift' then 'Other'
           when lower(m.site) = 'alleskralle' then 'Other'
        else initcap(m.vertical) end as vertical, 
     count(distinct sp.subscriptionId) as premiums,
     count(distinct case when date(sp.subscriptionDateCreated) = date(m.dateProfileComplete) then sp.subscriptionId end) as day1s,
     count(distinct case when date(m.dateFirstPremiumSignup) = date(sp.subscriptionDateCreated) and date(sp.subscriptionDateCreated) != date(m.dateMemberSignup) then sp.subscriptionId end) as nths,
     count(distinct case when date(m.dateFirstPremiumSignup) = date(sp.subscriptionDateCreated) then sp.subscriptionId end) as new_premiums,
     count(distinct case when date(m.dateFirstPremiumSignup) != date(sp.subscriptionDateCreated) then sp.subscriptionId end) as reupgrades     
    from intl.transaction tt
      join intl.hive_subscription_plan sp on sp.subscriptionId = tt.subscription_plan_id and sp.countrycode = tt.country_code
      join reporting.DW_D_DATE d          on date(sp.subscriptionDateCreated) = d.date 
      join intl.hive_member m             on tt.member_id = m.memberid and tt.country_code = m.countrycode
   where tt.type in ('PriorAuthCapture','AuthAndCapture')
      and tt.status = 'SUCCESS'
      and tt.amount > 0
      and m.IsInternalAccount = 'false'
      and m.closedforfraud = 'false'
      and lower(m.audience) = lower(m.role)
      and 
         (
          lower(m.campaign) = 'sem' or 
          m.creativeversion = '472' or
          m.creativeversion = '469' or
          lower(m.site) in ('gdn','youtube','facebook','absolventen','babysitter.de','blog','careerjet','criteo','erdbeerlounge','erdbeerlounge2','gelegenheitsjobs','generic','generictotal','glassdoor',
          'jobrobot','mapmeo','marktde','marktplaats','metajob','mitula','nannytax','njobs','palkkausfi','provider','qualityclick','quoka','rabathelten','recrudo','rubrikk','savethestudent','so.dk','stadtlist',
          'stellenwerk','studiumratgeber','meinestadt','aktuellejobs','jobkicks','ortsdienst','4everglen','snautz','jobrapido','mibaby','awin','zanox','pinterest','spotify','impact','kleinanzeigen',
          'adzuna','adzunaauto','allthetopbananas','indeed','indeedauto','jobisj','jobisjob','jobisjobauto','jobisjobde','jobisjobdeauto','jobrapido','jobrapidoauto','jobrapidoleads','jooble','joobleauto','jorapaid',
          'neuvoo','trovit','trovitde','trovitdeauto','trovituk','trovituksauto','ziprecruiter','reach','monster','studentjob','appjobs','myperfectjob','joblift','alleskralle') or
          ( lower(m.site) in ('meinestadt.de', 'meinestadt', 'meinestadtp') and lower(m.role) = 'seeker')
         )
      and d.year >= year(now())-1
      and d.date < date(current_date)
  group by 1,2,3,4,5,6,7,8 
  
  union
  
  select
     d.year, d.month, d.week_start_date, d.date,
     'Seeker' as role, 'TV' as channel, 'DE' as country, 'Housekeeping' as vertical, 
     count(distinct sp.subscriptionId) as premiums,
     count(distinct case when date(sp.subscriptionDateCreated) = date(m.dateProfileComplete) then sp.subscriptionId end) as day1s,
     count(distinct case when date(m.dateFirstPremiumSignup) = date(sp.subscriptionDateCreated) and date(sp.subscriptionDateCreated) != date(m.dateMemberSignup) then sp.subscriptionId end) as nths,
     count(distinct case when date(m.dateFirstPremiumSignup) = date(sp.subscriptionDateCreated) then sp.subscriptionId end) as new_premiums,
     count(distinct case when date(m.dateFirstPremiumSignup) != date(sp.subscriptionDateCreated) then sp.subscriptionId end) as reupgrades     
   from intl.transaction tt
      join intl.hive_subscription_plan sp on sp.subscriptionId = tt.subscription_plan_id and sp.countrycode = tt.country_code
      join reporting.DW_D_DATE d          on date(sp.subscriptionDateCreated) = d.date 
      join intl.hive_member m             on tt.member_id = m.memberid and tt.country_code = m.countrycode
   where tt.type in ('PriorAuthCapture','AuthAndCapture')
      and tt.status = 'SUCCESS'
      and tt.amount > 0
      and m.IsInternalAccount = 'false'
      and m.closedforfraud = 'false'
      and lower(m.audience) = lower(m.role)
      and m.howdidyouhear = 'tv'
      and m.countrycode = 'de'
      and lower(m.role) = 'seeker'
      and d.year >= year(now())-1
      and d.date < date(current_date)
  group by 1,2,3,4,5,6,7,8 
)

select
  t.year, t.month, t.week_start_date, t.date, current_date() as run_date, 
  cur.Yesterday, cur.WeekToDate, cur.LastWeekWTD, dty.date as 'Date_Current', cur.MonthToDate, cur.YearToDate,
  
  role, channel, country, vertical, currency, fx_rate, 
  spend_domestic_currency, spend_fixed_current_fx_usd,
  basics, premiums, day1s, nths, new_premiums, reupgrades
  
from (
      select distinct
        coalesce(sp.year, b.year, p.year) as year, 
        coalesce(sp.month, b.month, p.month) as month, 
        coalesce(sp.week_start_date, b.week_start_date, p.week_start_date) as week_start_date,  
        coalesce(sp.date, b.date, p.date) as date,
  
        coalesce(sp.role, b.role, p.role) as role,
        coalesce(sp.channel, b.channel, p.channel) as channel, 
        coalesce(sp.country, b.country, p.country) as country,
        coalesce(sp.vertical, b.vertical, p.vertical) as vertical,
  
        coalesce(sp.currency,fx.currency) as currency, 
        fx.fx_rate,
        
        ifnull(sum(sp.spend_domestic_currency),0) as spend_domestic_currency,
        ifnull(sum(case when sp.currency = 'EUR' then sp.spend_domestic_currency * fx.fx_rate
                        when sp.currency = 'GBP' then sp.spend_domestic_currency * fx.fx_rate
                        when sp.currency = 'CAD' then sp.spend_domestic_currency * fx.fx_rate  
                        when sp.currency = 'AUD' then sp.spend_domestic_currency * fx.fx_rate end),0) as spend_fixed_current_fx_usd,
                  
        ifnull(sum(b.basics),0) as basics,
        ifnull(sum(p.premiums),0) as premiums,
        ifnull(sum(p.day1s),0) as day1s,
        ifnull(sum(p.nths),0) as nths,
        ifnull(sum(p.new_premiums),0) as new_premiums,
        ifnull(sum(p.reupgrades),0) as reupgrades
                  
      from spend sp
      left join fixed_current_fx fx                 on sp.currency = fx.currency 
      full outer join basics b                      on sp.year = b.year and sp.month = b.month and sp.week_start_date = b.week_start_date and sp.date = b.date 
                                                    and sp.role = b.role and sp.country = b.country and sp.channel = b.channel and sp.vertical = b.vertical  
      full outer join premiums p                    on sp.year = p.year and sp.month = p.month and sp.week_start_date = p.week_start_date and sp.date = p.date 
                                                    and sp.role = p.role and sp.country = p.country and sp.channel = p.channel and sp.vertical = p.vertical 

      group by 1,2,3,4,5,6,7,8,9,10
      order by 1,2,3,4 desc
      ) t
  join analytics.dw_d_date_current cur on t.date = cur.date
  join reporting.DW_D_DATE dty on dty.date = cur.Current_Date_SameDay
  
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25
order by 1,2,3,4 desc
