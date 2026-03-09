select 
  dd.year,
  to_char(year(dd.date)),
  dd.date,
  dc.current_date_sameDay as same_day,
  dc.current_date_samedate as same_date,
  dc.WeekToDate,
  dc.LastWeekWTD,
  dc.MonthToDate,
  upper(comb.country) as country,
  comb.member_type,
  comb.halo_member_type,
  comb.device,
  comb.vertical,
  comb.remarketing,
  comb.spend,
  comb.impressions,
  comb.clicks,
  comb.basics,
  comb.day1s,
  comb.nths,
  comb.reupgrades
from
(
      with spend as (
            select
              date(fbs.date_start) as date,
              case when campaign_type = 'seeker' then 'Seeker'
                   when campaign_type = 'provider' then 'Provider'
                 else 'Unspecified' end as member_type,  
              case when (lower(account_name) not like '%provider%' and lower(campaign_type) = 'provider') then 'Seeker Halo' 
          	       when (lower(account_name) not like '%seeker%' and lower(campaign_type) = 'seeker') then 'Provider Halo' 
          	      else 'Unspecified' end as halo_member_type,
               case when device in ('ipad','android_tablet') then 'Tablet'
                    when device in ('iphone','android_smartphone') then 'Mobile'
                    when device = 'desktop' then 'Desktop'
                    when device = 'other' then 'Other' 
                  else 'Other' end as device,
               case when lower(country) = 'en' then 'ca' 
                    when lower(country) = '_'  then 'au' 
                    when lower(country) = 've'  then 'de' 
                  else lower(country) end as country,  
               case when vertical = 'other' and ad_name like '%CC%' then 'CC'
                    when vertical = 'other' and ad_name like '%HK%' then 'HK'
                    when vertical = 'other' and ad_name like '%PC%' then 'PC' 
                    when vertical = 'HouseKeeping' then 'HK'
                    when vertical = 'PetCare' then 'PC'  
                    when vertical = 'Child Care' then 'CC' 
                  else 'Other' end as vertical, 
               case when campaign_name like '%Remarketing' then 'Yes' else 'No' end as remarketing,
               sum(case when fbs.currency='EUR' then fbs.spend*fx.currency_rate end) as spend,
               sum(fbs.impressions) as impressions,
               ceiling(sum(case when date(fbs.date_start) < '2023-08-23' then clicks else link_clicks end)) as clicks     
               from intl.DW_F_FACEBOOK_SPEND_INTL fbs
                   join reporting.DW_CARE_FX_RATES fx   on fbs.currency=fx.source_currency and fx.source_currency = 'EUR' and fx.target_currency='USD' and fx.currency_rate_type='Current'
               where year(fbs.date_start) >= year(current_date())-2
                     and date(fbs.date_start) < date(current_date)
               group by 1,2,3,4,5,6,7 order by 1 desc
      ),

      basics as (
          select 
            date(m.dateMemberSignup) as date,
            lower(m.countryCode) as country,
            case when lower(m.role)='provider' then 'Provider'
          			 when lower(m.role)='seeker' then 'Seeker'
          		else 'Unspecified' end as member_type,
            case when (lower(m.audience) <> 'provider' and lower(m.role) = 'provider') then 'Seeker Halo' 
              	 when (lower(m.audience) <> 'seeker' and lower(m.role) = 'seeker') then 'Provider Halo' 
              else 'Unspecified' end as halo_member_type,
            case when lower(m.device) = 'smartphone' then 'Mobile' when (m.device = '' or m.device is null) then 'Mobile' else initcap(lower(m.device)) end as device,
            case when (lower(m.vertical) = 'childcare' or lower(m.service) like '%cc%') then 'CC'
                 when (lower(m.vertical) in ('homecare','housekeeping') or lower(m.service) like '%hk%') then 'HK'
                 when (lower(m.vertical) = 'petcare' or lower(m.service) like '%pc%') then 'PC' 
             end as vertical,
            case when lower(m.campaignName) like '%remarketing' then 'Yes' else 'No' end as remarketing,
            count(distinct memberid) as basics
          from intl.hive_member m
          where m.IsInternalAccount = 'false'
            and lower(m.campaign) = 'online' 
            and lower(m.site) = 'facebook' 
            and (lower(m.vertical) in ('childcare','homecare','petcare','housekeeping') or lower(m.service) like '%cc%' or lower(m.service) like '%hk%' or lower(m.service) like '%pc%')
            and year(m.dateMemberSignup) >= year(current_date())-2
            and date(m.dateMemberSignup) < date(current_date)
          group by 1,2,3,4,5,6,7 order by 1 desc
      ),

      premiums as (
            select
               date(sp.subscriptionDateCreated) as date,
               lower(m.countryCode) as country,
               case when lower(m.role)='provider' then 'Provider'
      			        when lower(m.role)='seeker' then 'Seeker'
      			      else 'Unspecified' end as member_type,
               case when (lower(m.audience) <> 'provider' and lower(m.role) = 'provider') then 'Seeker Halo' 
          	        when (lower(m.audience) <> 'seeker' and lower(m.role) = 'seeker') then 'Provider Halo' 
          	     else 'Unspecified' end as halo_member_type,
              case when lower(m.device) = 'smartphone' then 'Mobile' when (m.device = '' or m.device is null) then 'Mobile' else initcap(lower(m.device)) end as device,
              case when (lower(m.vertical) = 'childcare' or lower(m.service) like '%cc%') then 'CC'
                   when (lower(m.vertical) in ('homecare','housekeeping') or lower(m.service) like '%hk%') then 'HK'
                   when (lower(m.vertical) = 'petcare' or lower(m.service) like '%pc%') then 'PC' 
               end as vertical,
            case when lower(m.campaignName) like '%remarketing' then 'Yes' else 'No' end as remarketing,   
            count(distinct case when date(sp.subscriptionDateCreated) = date(dateProfileComplete) then sp.subscriptionId end) as day1s,
      	    count(distinct case when date(m.dateFirstPremiumSignup) = date(sp.subscriptionDateCreated) and date(sp.subscriptionDateCreated) != date(dateProfileComplete) then sp.subscriptionId end) as nths,
      	    count(distinct case when date(m.dateFirstPremiumSignup) != date(sp.subscriptionDateCreated) then sp.subscriptionId end) as reupgrades
        from intl.transaction t
      		left join intl.hive_subscription_plan sp  on sp.subscriptionId = t.subscription_plan_id and sp.countrycode = t.country_code
      		left join intl.hive_member m              on t.member_id = m.memberid and t.country_code = m.countrycode
      		where t.type in ('PriorAuthCapture','AuthAndCapture')
      		  and t.status = 'SUCCESS' 
        		and t.amount > 0 
        		and m.IsInternalAccount = 'false'
        		and lower(m.campaign) = 'online' 
            and lower(m.site) = 'facebook' 
        		and year(sp.subscriptionDateCreated) >= year(current_date())-2
        		and date(sp.subscriptionDateCreated) < date(current_date)
            and (lower(m.vertical) in ('childcare','homecare','petcare','housekeeping') or lower(m.service) like '%cc%' or lower(m.service) like '%hk%' or lower(m.service) like '%pc%')
        group by 1,2,3,4,5,6,7 order by 1 desc
      )

      select
          coalesce(s.date, b.date, p.date) as date,
          coalesce(s.country, b.country, p.country) as country,
          coalesce(s.member_type, b.member_type, p.member_type) as member_type,
          coalesce(s.halo_member_type, b.halo_member_type, p.halo_member_type) as halo_member_type,
          coalesce(s.device, b.device, p.device) as device,
          coalesce(s.vertical, b.vertical, p.vertical) as vertical,
          coalesce(s.remarketing, b.remarketing, p.remarketing) as remarketing,
    
          ifnull(sum(s.spend ),0) as spend,
          ifnull(sum(s.impressions),0) as impressions,
          ifnull(sum(s.clicks),0) as clicks,
          ifnull(sum(b.basics),0) as basics,
          ifnull(sum(p.day1s),0) as day1s,
          ifnull(sum(p.nths),0) as nths,
          ifnull(sum(p.reupgrades),0) as reupgrades
    
      from spend s
        full outer join basics b    on  s.date = b.date and s.country = b.country and s.member_type = b.member_type
                                    and s.halo_member_type = b.halo_member_type and s.vertical = b.vertical and s.remarketing = b.remarketing and s.device = b.device     
  
        full outer join premiums p  on  s.date = p.date and s.country = p.country and s.member_type = p.member_type
                                    and s.halo_member_type = p.halo_member_type and s.vertical = p.vertical and s.remarketing = p.remarketing and s.device = p.device  
                              
      group by 1,2,3,4,5,6,7 order by 1 desc
) comb

join reporting.DW_D_DATE dd           on comb.date = dd.date
join analytics.dw_d_date_current dc   on dc.date = dd.date

group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21 order by 1,2,3,4 desc
