select s.*
from spots as s
inner join(
    select distinct (trim_domain), count(trim_domain)
    from (
             select (case
                         when LEFT(domain, 11) = 'http://www.' then
                             split_part(SUBSTRING(domain, 12, length(domain)), '/', 1)
                         when LEFT(domain, 12) = 'https://www.' then
                             split_part(SUBSTRING(domain, 13, length(domain)), '/', 1)
                         when LEFT(domain, 4) = 'www.' then
                             split_part(SUBSTRING(domain, 5, length(domain)), '/', 1)
                         when LEFT(domain, 7) = 'http://' then
                             split_part(domain, '/', 3)
                         when LEFT(domain, 8) = 'https://' then
                             split_part(domain, '/', 3)
                         else
                             split_part(domain, '/', 1)
                 end) as trim_domain
             from spots) as q
    group by trim_domain) as c
on s.domain like format('%%%s%%', c.trim_domain)
AND c.count > 1;