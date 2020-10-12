--return all spots which its domains also appears in other spots
select * from spots
    where domain in (
        select domain from spots
        group by domain
        having count(domain) >1
        );

--count different domains
select count(distinct(domain)) as different_domains
    from spots;
-- trimm all domains
update spots
set domain = case
        when LEFT(domain, 11) = 'http://www.' then
            split_part(SUBSTRING(domain,12,length(domain)), '/', 1)
        when LEFT(domain, 12) = 'https://www.' then
            split_part(SUBSTRING(domain,13,length(domain)), '/', 1)
        when LEFT(domain, 4) = 'www.' then
            split_part(SUBSTRING(domain,5,length(domain)), '/', 1)
        when LEFT(domain, 7) = 'http://' then
            split_part(domain, '/', 3)
        when LEFT(domain, 8) = 'https://' then
            split_part(domain, '/', 3)
        else
            split_part(domain, '/', 1)
        end
where id >0;