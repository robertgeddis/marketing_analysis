with spend as (

----------SEM SPEND 
  select distinct
     d.year, d.month, d.week_start_date, d.date,  
     initcap(sem.campaign_type) as role, 
     case when source_type in ('Search','Audience') and vertical = 'ChildCare' then 'SEM CC' 
          when source_type in ('Search','Audience') and vertical = 'HomeCare' then 'SEM HK'
          when source_type in ('Search','Audience') and vertical = 'PetCare' then 'SEM PC'
          when source_type in ('Search','Audience') and (vertical not in ('ChildCare', 'HomeCare', 'PetCare') or vertical is null) then 'SEM OV'
          when source_type in ('Video', 'GDN') then 'Other'
        end as channel,    
     upper(country) as country, 
     sem.currency,
     ifnull(sum(sem.cost),0) as spend_domestic_currency
  from intl.dw_f_campaign_spend_intl sem
    join reporting.DW_D_DATE d on date(sem.date) = d.date
  where d.year >= year(now())-1 
    and d.date < date(current_date)
    and sem.country is not null
  group by 1,2,3,4,5,6,7,8
  
union
----------SOCIAL SPEND
  select distinct 
    year, month, week_start_date, date,
    role, 'Social' as channel, country, currency,
    sum(spend_domestic_currency) as spend_domestic_currency
  from (
  -- FACEBOOK
    select distinct
      d.year, d.month, d.week_start_date, d.date,
      initcap(campaign_Type) as role,  
      case when upper(country) = 'EN' then 'CA' 
           when upper(country) = '_'  then 'AU' 
           when upper(country) in ('VE', 'PO')  then 'DE' 
        else upper(country) end as country,    
      fb.currency,
      ifnull(sum(spend),0) as spend_domestic_currency
    from intl.DW_F_FACEBOOK_SPEND_INTL fb
      join reporting.DW_D_DATE d on date(date_start) = d.date
    where d.year >= year(now())-1
      and d.date < date(current_date)
    group by 1,2,3,4,5,6,7
   union
  -- TikTok (DE Seekers)
  select distinct d.year, d.month, d.week_start_date, d.date, 'Seeker' as role, 'DE' as country, 'EUR' as currency, ifnull(sum(DE_Seeker_Mibaby),0) as spend_domestic_currency 
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on spend_date = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7
  union   
  -- PINTEREST (DE, UK, CA + AU Seekers)
  select distinct d.year, d.month, d.week_start_date, d.date, 'Seeker' as role, 'DE' as country, 'EUR' as currency, ifnull(sum(DE_Seeker_Pinterest),0) as spend_domestic_currency 
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on spend_date = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7
  union
  select distinct d.year, d.month, d.week_start_date, d.date, 'Seeker' as role, 'UK' as country, 'EUR' as currency, ifnull(sum(UK_Seeker_Pinterest),0) as spend_domestic_currency 
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on spend_date = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7
  union
  select distinct d.year, d.month, d.week_start_date, d.date, 'Seeker' as role, 'CA' as country, 'EUR' as currency, ifnull(sum(CA_Seeker_Pinterest),0) as spend_domestic_currency 
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on spend_date = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7
  union
  select distinct d.year, d.month, d.week_start_date, d.date, 'Seeker' as role, 'AU' as country, 'EUR' as currency, ifnull(sum(AU_Seeker_Pinterest),0) as spend_domestic_currency 
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on spend_date = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7
  ) social_spend
group by 1,2,3,4,5,6,7,8
---------- SOCIAL SPEND

union 
---------- AFFILIATE SPEND
  select distinct 
    year, month, week_start_date, date,
    role, 'Affiliate' as channel, country, currency,
    sum(spend_domestic_currency) as spend_domestic_currency
  from (
     -- QUALITY CLICK (Seekers) + PUTZFRAU AGENTUR (DE Seekers HK - partnerid = '469')
    select distinct
        d.year, d.month, d.week_start_date, d.date,
       'Seeker' as role,      
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
        'EUR' as currency,
         sum(qc.commission) as spend_domestic_currency
      from intl.quality_click_spend qc
        join reporting.DW_D_DATE d on date(day) = d.date
      where partnerid <> '435'
        and (lower(product) not like '%alltagshelfer%' or lower(product) not like '%provider%') -- Assigned default to seekers as discussed with Fabian
        and d.year >= year(now())-1
        and d.date < date(current_date)
      group by 1,2,3,4,5,6,7
    union
  -- PUTZCHECKER (DE Seekers)
  select 
    d.year, d.month, d.week_start_date, d.date,
    'Seeker' as role,
    'DE' as country, 'EUR' as currency,
    ifnull((sum(clicks)*1.5),0) as spend_domestic_currency
  from intl.quality_click_cpc
    join reporting.DW_D_DATE d on date(day) = d.date
  where d.year >= year(now())-1
    and d.date < date(current_date)
  group by 1,2,3,4,5,6,7
  union
  
  -- AWIN--------------------------------------------------------------------------------------------------Issue with GBP currency. Setting to EUR temporarily
  select distinct
    d.year, d.month, d.week_start_date, d.date,
    case when aw.commission_group_code in ('REG_P','REGP') then 'Provider' else 'Seeker' end as role, 
    case when advertiser_id = '10557' then 'DE'
         when advertiser_id = '10709' then 'AT'   
         when advertiser_id = '45671' then 'UK' 
      end as country,   
  	--case when advertiser_id in ('10557', '10709') then 'EUR' else 'GBP' end as currency,	
  	'EUR' as currency,   
    ifnull((sum(aw.commission_amount)*1.3),0) as spend_domestic_currency
  from intl.awin_spend aw
    join reporting.DW_D_DATE d on date(aw.transaction_Date) = d.date
  where d.year >= year(now())-1
    and d.date < date(current_date)
    and lower(aw.commissionStatus) in ('approved', 'pending')
	group by 1,2,3,4,5,6,7
	
  union
  -- MEINESTADT (DE Seekers)
  select distinct
     d.year, d.month, d.week_start_date, d.date,
     'Seeker' as role, 'DE' as country, 'EUR' as currency,
     ifnull(sum(case when spend.year = spend.current_year and spend.month = spend.current_month then ((spend)/current_days) else ((spend)/days_in_month) end),0) as spend_domestic_currency
  from (
    select distinct
      year(sp.subscriptionDateCreated) as year,
      month(sp.subscriptionDateCreated) as month,
      date_part('day', last_day(sp.subscriptionDateCreated)) as days_in_month,
      date_part('day', current_date()-1) as current_days,
      month(current_date()-1) as current_month,
      year(current_date()-1) as current_year,
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
    group by 1,2,3,4,5,6
  ) spend
    join reporting.DW_D_DATE d on spend.year = d.year and spend.month = d.month and d.year >= year(now())-1 and d.date < date(current_date)
    group by 1,2,3,4,5,6,7 
    union
  -- SPOTIFY (DE SEEKERS ONLY)
  select distinct
    d.year, d.month, d.week_start_date, d.date,
    'Seeker' as role, 'DE' as country, 'EUR' as currency,
    ifnull(sum(spend),0) as spend_domestic_currency
  from intl.spotify_spend sy
  join reporting.DW_D_DATE d on date(sy.start_date) = d.date
  where d.year >= year(now())-1
    and d.date < date(current_date)
	group by 1,2,3,4,5,6,7
	union
  -- IMPACT (CA SEEKERS ONLY)
  select distinct d.year, d.month, d.week_start_date, d.date, 'Seeker' as role, 'CA' as country, 'EUR' as currency, ifnull(sum(CA_OTHER_ONLINE),0) as spend_domestic_currency 
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on spend_date = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7  
  union
  select distinct d.year, d.month, d.week_start_date, d.date, 'Seeker' as role, 'AU' as country, 'EUR' as currency, ifnull(sum(AU_OTHER_ONLINE),0) as spend_domestic_currency 
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on spend_date = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7   
  union
  -- KLEINANZEIGEN (DE Seeker) *** Using DE_Seeker_Nebenan column in intl.DW_MARKETING_SPEND_INTL
  select distinct d.year, d.month, d.week_start_date, d.date, 'Seeker' as role, 'DE' as country, 'EUR' as currency, ifnull(sum(DE_Seeker_Nebenan),0) as spend_domestic_currency
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on date(spend_date) = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7 
  union
  -- QUALITY CLICK (Providers)
    select distinct
        d.year, d.month, d.week_start_date, d.date,
       'Provider' as role,     
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
        'EUR' as currency,
         ( sum(qc.commission) + sum(qc.currency) ) as spend
      from intl.quality_click_spend qc
        join reporting.DW_D_DATE d on date(day) = d.date
      where partnerid <> 435
        and (lower(product) like '%alltagshelfer%' or lower(product) like '%provider%') 
        and d.year >= year(now())-1
        and d.date < date(current_date)
      group by 1,2,3,4,5,6,7
    union 
   -- RECRUITICS (Providers)
  select distinct
    d.year, d.month, d.week_start_date, d.date, 
    'Provider' as role,
    case when rc.country in ('DE','') then 'DE' 
         when rc.country = 'GB' then 'UK'
        else rc.country end as country,    
    'EUR' as currency,
    ifnull(sum(rc.spend),0) as spend_domestic_currency
  from intl.recruitics_spend_intl rc
    join reporting.DW_D_DATE d on date(rc.day) = d.date 
  where lower(rc.source) not in ('xxx','jobg8','jobg8auto','jobtome')
    and d.year >= year(now())-1 
    and d.date < date(current_date)
  group by 1,2,3,4,5,6,7
  union
  -- RECRUITICS FEE (DE Providers Only)
  select 
    d.year, d.month, d.week_start_date, d.date,
    'Provider' as role, 'DE' as country, currency,
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
  group by 1,2,3,4,5,6,7
  union
  -- STUDENT JOB (Providers)
  select distinct
    d.year, d.month, d.week_start_date, d.date,
    'Provider' as role, 
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
  group by 1,2,3,4,5,6,7
  union 
  -- APP JOBS (Providers)
  select distinct
    d.year, d.month, d.week_start_date, d.date,
    'Provider' as role,  
    case when country = 'Germany' then 'DE'
         when country = 'Canada' then 'CA' 
       end as country,   
    'EUR' as currency,
    ifnull(sum(total_spent_usd),0) as spend_domestic_currency           
  from intl.appjobs_spend aj
    join reporting.DW_D_DATE d on date(day) = d.date
  where d.year >= year(now())-1 
    and d.date < date(current_date)
  group by 1,2,3,4,5,6,7  
  union
  -- APPCAST (DE + UK Providers) 
  select distinct d.year, d.month, d.week_start_date, d.date, 'Provider' as role, 'DE' as country, 'EUR' as currency, ifnull(sum(de_provider_appcast),0) as spend_domestic_currency 
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on spend_date = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7
  union
  
  --------------------------------------------------------------------------------------------------Issue with GBP currency. Setting to EUR temporarily
  select distinct d.year, d.month, d.week_start_date, d.date, 'Provider' as role, 'UK' as country, /*'GBP' as currency*/ 'EUR' as currency, ifnull(sum(uk_provider_appcast),0) as spend_domestic_currency 
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on spend_date = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7 
  
  union 
  -- MY PERFECT JOB (DE Providers)
  select distinct d.year, d.month, d.week_start_date, d.date, 'Provider' as role, 'DE' as country, 'EUR' as currency, ifnull(sum(DE_Provider_Myperfectjob),0) as spend_domestic_currency
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on date(spend_date) = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7 
  union
  -- JOB LIFT (DE Providers)
  select distinct d.year, d.month, d.week_start_date, d.date, 'Provider' as role, 'DE' as country, 'EUR' as currency, ifnull(sum(DE_PROVIDER_JOBLIFT),0) as spend_domestic_currency
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on date(spend_date) = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7 
  union
  -- ALLESKRALLE (DACH Providers)
  select distinct d.year, d.month, d.week_start_date, d.date, 'Provider' as role, 'DE' as country, 'EUR' as currency, ifnull(sum(DE_PROVIDER_ALLESKRALLE),0) as spend_domestic_currency
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on date(spend_date) = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7
  union
  select distinct d.year, d.month, d.week_start_date, d.date, 'Provider' as role, 'AT' as country, 'EUR' as currency, ifnull(sum(AT_PROVIDER_ALLESKRALLE),0) as spend_domestic_currency
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on date(spend_date) = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7 
  union
  select distinct d.year, d.month, d.week_start_date, d.date, 'Provider' as role, 'CH' as country, 'EUR' as currency, ifnull(sum(CH_PROVIDER_ALLESKRALLE),0) as spend_domestic_currency
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on date(spend_date) = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7 
  union
  -- KLEINANZEIGEN (DE Providers) *** Using DE_Provider_Nebenan column in intl.DW_MARKETING_SPEND_INTL
  select distinct d.year, d.month, d.week_start_date, d.date, 'Provider' as role, 'DE' as country, 'EUR' as currency, ifnull(sum(DE_Provider_Nebenan),0) as spend_domestic_currency
  from intl.DW_MARKETING_SPEND_INTL join reporting.DW_D_DATE d on date(spend_date) = d.date where d.year >= year(now())-1 and d.date < date(current_date) group by 1,2,3,4,5,6,7
  ) affiliate_spend
group by 1,2,3,4,5,6,7,8

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

visits as (
    select 
      d.year, d.month, d.week_start_date, d.date,
      case when lower(v.rxaudience) = 'seeker' then 'Seeker'
           when lower(v.rxaudience) = 'provider' then 'Provider'
         else 'Seeker' end as role, 
      case when lower(v.rxcampaign) = 'sem' and (lower(rxservice) in ('cc', 'c', 'childcare', '') or lower(rxservice) like '%child%') then 'SEM CC' 
           when lower(v.rxcampaign) = 'sem' and (lower(rxservice) in ('hk', 'homecare', 'housekeeping', 'ho') or lower(rxservice) like '%homecare%') then 'SEM HK' 
           when lower(v.rxcampaign) = 'sem' and (lower(rxservice) in ('pc', 'petcare') or lower(rxservice) like '%petcare%') then 'SEM PC' 
           when lower(v.rxcampaign) = 'sem' and (lower(rxservice) not in ('cc','c','childcare','','hk','homecare','housekeeping','ho','pc', 'petcare') or 
                                                lower(rxservice) not like '%child%' or lower(rxservice) like '%homecare%' or lower(rxservice) like '%petcare%') then 'SEM OV' 
           when lower(v.rxcampaign) = 'online' and lower(v.rxsite) in ('gdn', 'youtube') then 'Other'
           when lower(v.rxcampaign) in ('online', 'affiliate', 'influencer') and lower(v.rxsite) in ('facebook', 'pinterest', 'tiktok') then 'Social'
           when lower(v.rxcampaign) in ('online', 'affiliate', 'influencer') and lower(v.rxsite) not in ('facebook', 'pinterest', 'tiktok') then 'Affiliate'
        end as channel,
      upper(v.countrycode) as country, 
      count(distinct visitorid) as visits                                                         
    from intl.hive_visit v 
    join reporting.DW_D_DATE d on date(startDate) = d.date and d.year >= year(now())-1 and d.date < date(current_date)
    where lower(v.rxcampaign) in ('sem', 'online', 'affiliate', 'influencer') 
      and (v.memberid is null or v.signup = true)
    group by 1,2,3,4,5,6,7
),

basics as (
    select
      d.year, d.month, d.week_start_date, d.date,
      case when m.role is null then 'Seeker' else initcap(m.role) end as role, 
      case when lower(m.campaign) = 'sem' and (m.vertical is null or m.vertical = '' or lower(m.vertical) = 'childcare') then 'SEM CC' 
           when lower(m.campaign) = 'sem' and lower(m.vertical) in ('homecare', 'housekeeping') then 'SEM HK' 
           when lower(m.campaign) = 'sem' and lower(m.vertical) = 'petcare' then 'SEM PC' 
           when lower(m.campaign) = 'sem' and (lower(m.vertical) not in ('childcare', 'homecare', 'housekeeping', 'petcare') or m.vertical is not null or m.vertical <> '') then 'SEM OV' 
           when lower(m.campaign) = 'online' and lower(m.site) in ('gdn', 'youtube') then 'Other'
           when lower(m.campaign) in ('online', 'affiliate', 'influencer') and lower(m.site) in ('facebook', 'pinterest', 'tiktok') then 'Social'
           when lower(m.campaign) in ('online', 'affiliate', 'influencer') and lower(m.site) not in ('facebook', 'pinterest', 'tiktok') then 'Affiliate'
        end as channel,
      upper(m.countrycode) as country,
      count(distinct m.memberid) as basics  
    from intl.hive_member m   
    join reporting.DW_D_DATE d on date(m.dateMemberSignup) = d.date and d.year >= year(now())-1 and d.date < date(current_date)
    where lower(m.campaign) in ('sem', 'online', 'affiliate', 'influencer')  
      and m.IsInternalAccount = 'false'
      and m.closedforfraud = 'false'
      and lower(m.audience) = lower(m.role)
    group by 1,2,3,4,5,6,7
),

premiums as (
    select
      d.year, d.month, d.week_start_date, d.date,
      case when m.role is null then 'Seeker' else initcap(m.role) end as role, 
      case when lower(m.campaign) = 'sem' and (m.vertical is null or m.vertical = '' or lower(m.vertical) = 'childcare') then 'SEM CC' 
           when lower(m.campaign) = 'sem' and lower(m.vertical) in ('homecare', 'housekeeping') then 'SEM HK' 
           when lower(m.campaign) = 'sem' and lower(m.vertical) = 'petcare' then 'SEM PC' 
           when lower(m.campaign) = 'sem' and (lower(m.vertical) not in ('childcare', 'homecare', 'housekeeping', 'petcare') or m.vertical is not null or m.vertical <> '') then 'SEM OV' 
           when lower(m.campaign) = 'online' and lower(m.site) in ('gdn', 'youtube') then 'Other'
           when lower(m.campaign) in ('online', 'affiliate', 'influencer') and lower(m.site) in ('facebook', 'pinterest', 'tiktok') then 'Social'
           when lower(m.campaign) in ('online', 'affiliate', 'influencer') and lower(m.site) not in ('facebook', 'pinterest', 'tiktok') then 'Affiliate'
        end as channel,
     upper(m.countrycode) as country,
     count(distinct sp.subscriptionId) as premiums,
     count(distinct case when date(sp.subscriptionDateCreated) = date(m.dateProfileComplete) then sp.subscriptionId end) as day1,
     count(distinct case when date(m.dateFirstPremiumSignup) = date(sp.subscriptionDateCreated) and datediff('day', m.dateMemberSignup, sp.subscriptionDateCreated)<=7 then sp.subscriptionId end) as day7,
     count(distinct case when date(m.dateFirstPremiumSignup) = date(sp.subscriptionDateCreated) and datediff('day', m.dateMemberSignup, sp.subscriptionDateCreated)<=30 then sp.subscriptionId end) as day30,
     count(distinct case when date(m.dateFirstPremiumSignup) != date(sp.subscriptionDateCreated) then sp.subscriptionId end) as reupgrades     
    from intl.transaction tt
      join intl.hive_subscription_plan sp on sp.subscriptionId = tt.subscription_plan_id and sp.countrycode = tt.country_code
      join reporting.DW_D_DATE d          on date(sp.subscriptionDateCreated) = d.date and d.year >= year(now())-1 and d.date < date(current_date)
      join intl.hive_member m             on tt.member_id = m.memberid and tt.country_code = m.countrycode
   where tt.type in ('PriorAuthCapture','AuthAndCapture')
      and tt.status = 'SUCCESS'
      and tt.amount > 0
      and m.IsInternalAccount = 'false'
      and m.closedforfraud = 'false'
      and lower(m.audience) = lower(m.role)
      and lower(m.campaign) in ('sem', 'online', 'affiliate', 'influencer')  
  group by 1,2,3,4,5,6,7
)

select
  t.year, t.month, t.week_start_date, t.date, current_date() as run_date, 
  cur.Yesterday, cur.WeekToDate, cur.LastWeekWTD, dty.date as 'Date_Current', cur.MonthToDate, cur.YearToDate,
  
  role, channel, country, currency, fx_rate, 
  spend_domestic_currency, spend_fixed_current_fx_usd,
  visits, basics, premiums, day1, day7, day30, reupgrades
  
from (
      select distinct
        coalesce(s.year, v.year, b.year, p.year) as year, 
        coalesce(s.month, v.month, b.month, p.month) as month, 
        coalesce(s.week_start_date, v.week_start_date, b.week_start_date, p.week_start_date) as week_start_date,  
        coalesce(s.date, v.date, b.date, p.date) as date,
  
        coalesce(s.role, v.role, b.role, p.role) as role,
        coalesce(s.channel, v.channel, b.channel, p.channel) as channel, 
        coalesce(s.country, v.country, b.country, p.country) as country,
  
        coalesce(s.currency, x.currency) as currency, 
        x.fx_rate,
        
        ifnull(sum(s.spend_domestic_currency),0) as spend_domestic_currency,
        ifnull(sum(case when s.currency = 'EUR' then s.spend_domestic_currency * x.fx_rate
                        when s.currency = 'GBP' then s.spend_domestic_currency * x.fx_rate
                        when s.currency = 'CAD' then s.spend_domestic_currency * x.fx_rate  
                        when s.currency = 'AUD' then s.spend_domestic_currency * x.fx_rate end),0) as spend_fixed_current_fx_usd,
                        
        ifnull(sum(v.visits),0) as visits,          
        ifnull(sum(b.basics),0) as basics,
        ifnull(sum(p.premiums),0) as premiums,
        ifnull(sum(p.day1),0) as day1,
        ifnull(sum(p.day7),0) as day7,
        ifnull(sum(p.day30),0) as day30,
        ifnull(sum(p.reupgrades),0) as reupgrades
                  
      from spend s
      left join fixed_current_fx x                  on s.currency = x.currency 
      full outer join visits v                      on s.year = v.year and s.month = v.month and s.week_start_date = v.week_start_date and s.date = v.date 
                                                    and s.role = v.role and s.country = v.country and s.channel = v.channel  
      full outer join basics b                      on s.year = b.year and s.month = b.month and s.week_start_date = b.week_start_date and s.date = b.date 
                                                    and s.role = b.role and s.country = b.country and s.channel = b.channel  
      full outer join premiums p                    on s.year = p.year and s.month = p.month and s.week_start_date = p.week_start_date and s.date = p.date 
                                                    and s.role = p.role and s.country = p.country and s.channel = p.channel  

      group by 1,2,3,4,5,6,7,8,9
      order by 1,2,3,4 desc
      ) t
  join analytics.dw_d_date_current cur on t.date = cur.date
  join reporting.DW_D_DATE dty on dty.date = cur.Current_Date_SameDay
  
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25
order by 1,2,3,4 desc
