select 
   d.year
  ,to_char(year(d.date))
  ,date(date_trunc('month', cur.current_date_sameday)) as month 
  ,date(date_trunc('week', cur.current_date_sameday)) as week
  ,d.fiscal_week_start_date  
  ,d.date
  ,d.day_of_week as weekday
  ,date(timestampadd('day',+7,d.date)) as day7_date
  ,cur.current_date_sameday as same_day
  ,cur.Yesterday
  ,cur.MonthToDate
  ,cur.WeekToDate
  ,cur.LastWeekWTD
  ,country
  ,member_type 
  ,halo_member_type 
  ,vertical 
  ,device
  ,source  
  ,campaign_name
  ,cost
  ,clicks
  ,impressions
  ,impression_share
  ,basics
  ,day1s
  ,nthdays
  ,reupgrades
  ,PayPal
  ,Credit_Card
  ,Debit
  ,Other_Payment

from

(
with spend as (
  select 
     date(sp.date) as date
    ,sp.country      
    ,case when campaign_type = 'Seeker' then 'Seeker'
          when campaign_type = 'Provider' then 'Provider'
      else 'Unspecified' end as member_type
    ,case when vertical='ChildCare' then 'CC'
          when vertical='HomeCare' then 'HK'
          when vertical='PetCare' then 'PC'
          when vertical='SeniorCare' then 'SC'
          when vertical='SpecialNeeds' then 'SN'
          when vertical='Tutoring' then 'TT'
          when vertical='AuPair' then 'AP'
          when vertical='Brand' then 'BR'
       else 'Other' end as vertical
    ,case when lower(device_type) in ('computer','computers','desktop') then 'Desktop'
          when lower(device_type) in ('mobile','mobile devices with full browsers','smartphone') then 'Mobile'
          when lower(device_type) in ('tablet','tablets with full browsers') then 'Tablet'
       end as device
    ,sp.source
    ,campaign_name
    ,sum(case when sp.currency = 'EUR' then sp.cost*fx.currency_rate 
              when sp.currency = 'AUD' then sp.cost*fx.currency_rate
              when sp.currency = 'CAD' then sp.cost*fx.currency_rate
              when sp.currency = 'GBP' then sp.cost*fx.currency_rate end) as cost
    ,sum(sp.clicks) as clicks
    ,sum(sp.impressions) as impressions
    ,avg(sp.impression_share) as impression_share

  from intl.dw_f_campaign_spend_intl sp
    join reporting.DW_CARE_FX_RATES fx on sp.currency=fx.source_currency and fx.target_currency = 'USD' and fx.currency_rate_type = 'Current' and fx.source_currency in ('EUR','GBP','CAD','AUD')

  where sp.source <> 'YT'
    and sp.source_type <> 'GDN'
    and sp.country is not null
    and year(sp.date) >= year(current_date)-2
    and date(sp.date) <> date(current_date)

  group by 1,2,3,4,5,6,7 order by 1 asc
),

basics as (
  select
     date(m.dateMemberSignup) as date
    ,m.countryCode as country
    ,case when lower(m.role) = 'provider' then 'Provider'
          when lower(m.role) = 'seeker' then 'Seeker'
       end as member_type
    ,case when (lower(m.audience) <> 'provider' and lower(m.role) = 'provider') then 'Seeker Halo' 
          when (lower(m.audience) <> 'seeker' and lower(m.role) = 'seeker') then 'Provider Halo' 
       end as halo_member_type 
    ,case when regexp_ilike(campaignName, '_BR_|BR_|_BR|Brand|brand') and not regexp_ilike(campaignName, 'PC|Aupair|aupair|Opermädchen|CC|Familienservice|HK|hjaelptilbolig|TT|SN|SC') then 'BR' 
          when campaignName like '%PC%' then 'PC' 
          when regexp_ilike(campaignName, 'Aupair|aupair|Opermädchen') then 'AP'
          when regexp_ilike(campaignName, 'CC|Familienservice') then 'CC'
          when regexp_ilike(campaignName, 'HK|hjaelptilbolig') then 'HK'
          when campaignName like '%TT%' then 'TT' 
          when campaignName like '%SN%' then 'SN' 
          when campaignName like '%SC%' then 'SC' 
       else 'Other' end as vertical
    ,case when device = 'tablet' then 'Tablet'
          when device in ('mobile','smartphone') then 'Mobile'
          when device in ('desktop') then 'Desktop'
        else 'Other' end as device      
    ,case when lower(campaign) = 'sem' and lower(site) = 'google' then 'Google' 
          when lower(campaign) = 'sem' and lower(site) = 'msn'  then 'MSN' 
       else 'Other' end as source
    ,case when regexp_ilike(SUBSTRING(campaignName, 0, 3), 'm_|c_|t_') then SUBSTRING(campaignName, 3) else campaignName end as campaign_name 
    ,count(distinct memberid) as basics

  from intl.hive_member m

  where IsInternalAccount = 'false'
    and campaign ilike 'sem'
    and lower(m.site) not in ('youtube','gdn')
    and year(m.dateMemberSignup) >= year(current_date)-2
    and date(m.dateMemberSignup) <> date(current_date)
    
  group by 1,2,3,4,5,6,7,8 order by 1 asc
),

premiums as (
  select
     date(sp.subscriptionDateCreated) as date
    ,m.countryCode as country
    ,case when lower(m.role) = 'provider' then 'Provider'
          when lower(m.role) = 'seeker' then 'Seeker'
       end as member_type
    ,case when (lower(m.audience) <> 'provider' and lower(m.role) = 'provider') then 'Seeker Halo' 
          when (lower(m.audience) <> 'seeker' and lower(m.role) = 'seeker') then 'Provider Halo' 
       end as halo_member_type          
    ,case when regexp_ilike(campaignName, '_BR_|BR_|_BR|Brand|brand') and not regexp_ilike(campaignName, 'PC|Aupair|aupair|Opermädchen|CC|Familienservice|HK|hjaelptilbolig|TT|SN|SC') then 'BR' 
          when campaignName like '%PC%' then 'PC' 
          when regexp_ilike(campaignName, 'Aupair|aupair|Opermädchen') then 'AP'
          when regexp_ilike(campaignName, 'CC|Familienservice') then 'CC'
          when regexp_ilike(campaignName, 'HK|hjaelptilbolig') then 'HK'
          when campaignName like '%TT%' then 'TT' 
          when campaignName like '%SN%' then 'SN' 
          when campaignName like '%SC%' then 'SC' 
       else 'Other' end as vertical 
    ,case when device = 'tablet' then 'Tablet'
          when device in ('mobile','smartphone') then 'Mobile'
          when device in ('desktop') then 'Desktop'
       else 'Other' end as device
    ,case when lower(campaign) = 'sem' and lower(site) = 'google' then 'Google' 
          when lower(campaign) = 'sem' and lower(site) = 'msn'  then 'MSN' 
       else 'Other' end as source
    ,case when regexp_ilike(SUBSTRING(campaignName, 0, 3), 'm_|c_|t_') then SUBSTRING(campaignName, 3) else campaignName end as campaign_name
    ,count(distinct case when date(sp.subscriptionDateCreated) = date(dateProfileComplete) then sp.subscriptionId end) as day1s
    ,count(distinct case when date(m.dateFirstPremiumSignup) = date(sp.subscriptionDateCreated) and date(sp.subscriptionDateCreated) != date(dateProfileComplete) then sp.subscriptionId end) as nthdays
    ,count(distinct case when date(m.dateFirstPremiumSignup) != date(sp.subscriptionDateCreated) then sp.subscriptionId end) as reupgrades
    ,count(distinct case when cc.payment_type='PAYPAL' then sp.subscriptionId end) as PayPal
    ,count(distinct case when cc.payment_type='CREDIT_CARD' then sp.subscriptionId end) as Credit_Card	  			  
    ,count(distinct case when cc.payment_type='DEBIT' then sp.subscriptionId end) as Debit
    ,count(distinct case when cc.payment_type not in ('PAYPAL','CREDIT_CARD','DEBIT') then sp.subscriptionId end) as Other_Payment

  from intl.transaction t
    join intl.hive_subscription_plan sp on sp.subscriptionId = t.subscription_plan_id and sp.countrycode = t.country_code
    join intl.hive_member m on t.member_id = m.memberid and t.country_code = m.countrycode
    left join intl.CREDIT_CARD cc on cc.id=t.credit_card_id and cc.country_code=t.country_code

  where t.type in ('PriorAuthCapture','AuthAndCapture')
    and t.status = 'SUCCESS' 
    and t.amount > 0 
    and m.IsInternalAccount = 'false' 
    and campaign ilike 'sem'
    and lower(m.site) not in ('youtube','gdn')
    and year(sp.subscriptionDateCreated) >= year(current_date)-2
    and date(sp.subscriptionDateCreated) <> date(current_date)

  group by 1,2,3,4,5,6,7,8 order by 1 asc
)

select  
   coalesce(s.date, b.date, p.date) as date   
  ,coalesce(upper(s.country), upper(b.country), upper(p.country)) as country
  ,coalesce(s.member_type, b.member_type, p.member_type) as member_type 
  ,coalesce(b.halo_member_type, p.halo_member_type) as halo_member_type 
  ,coalesce(upper(s.vertical), upper(b.vertical), upper(p.vertical)) as vertical 
  ,coalesce(initcap(s.device), initcap(b.device), initcap(p.device)) as device
  ,coalesce(s.source, b.source, p.source) as source  
  ,coalesce(s.campaign_name, b.campaign_name, p.campaign_name) as campaign_name
  
  ,ifnull(sum(s.cost),0) as cost
  ,ifnull(sum(s.clicks),0) as clicks
  ,ifnull(sum(s.impressions),0) as impressions
  ,ifnull(avg(s.impression_share),0) as impression_share
  
  ,ifnull(sum(b.basics),0) as basics
  ,ifnull(sum(p.day1s),0) as day1s
  ,ifnull(sum(p.nthdays),0) as nthdays
  ,ifnull(sum(p.reupgrades),0) as reupgrades
  
  ,ifnull(sum(p.PayPal),0) as PayPal
  ,ifnull(sum(p.Credit_Card),0) as Credit_Card
  ,ifnull(sum(p.Debit),0) as Debit
  ,ifnull(sum(p.Other_Payment),0) as Other_Payment
  
from spend s
  full outer join basics b      on s.date = b.date and s.country = b.country and s.device = b.device and s.vertical = b.vertical and s.member_type = b.member_type 
                                and s.source = b.source and s.campaign_name = b.campaign_name 
                                  
  full outer join premiums p    on b.date = p.date and b.country = p.country and b.device = p.device and b.vertical = p.vertical and b.member_type = p.member_type 
                                and b.source = p.source and b.campaign_name = p.campaign_name and b.halo_member_type = p.halo_member_type
         
group by 1,2,3,4,5,6,7,8 order by 1 asc
) comb

  join reporting.DW_D_DATE d on comb.date = d.date
  join analytics.dw_d_date_current cur on cur.date = d.date
  

group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28.29,30,31,32,comb.paypal,comb.credit_card,reupgrades
