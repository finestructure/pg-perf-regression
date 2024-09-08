REFRESH MATERIALIZED VIEW recent_packages;
REFRESH MATERIALIZED VIEW recent_releases;
REFRESH MATERIALIZED VIEW search;
REFRESH MATERIALIZED VIEW stats;
REFRESH MATERIALIZED VIEW weighted_keywords;

select count(*) from (
    select distinct p.url
    from packages p
    join versions v on v.package_id = p.id
    where
    v.spi_manifest::text like '%documentation_targets%'
    and v.latest is not null
) t;

select count(*) from (
    select d.updated_at, p.url, file_count, mb_size, v.latest,
        case
            when v.latest = 'release' then v.reference->'tag'->>'tagName'
            when v.latest = 'pre_release' then v.reference->'tag'->>'tagName'
            when v.latest = 'default_branch' then v.reference->>'branch'
        end as "reference",
        d.status,
        d.error,
        d.log_url,
        b.job_url,
        version_id,
        platform,
        swift_version,
        build_id
    from doc_uploads d
    join builds b on b.id = d.build_id
    join versions v on v.id = b.version_id
    join packages p on v.package_id = p.id
    where d.status != 'ok'
    order by d.updated_at desc
) t;

select owner, count(*)
from repositories r
join packages p on r.package_id = p.id
join versions v on v.package_id = p.id
where v.latest = 'default_branch'
and v.spi_manifest::text like '%documentation_targets%'
group by owner
order by count(*) desc
limit 10;

select 'linux' as "platform", count(t.*) as "total", round(count(t.*)*100 / (select count(*) from packages)::decimal, 1) as "fraction" from
(
select distinct p.url
from builds b
join versions v on b.version_id = v.id
join packages p on v.package_id = p.id 
where platform = 'linux'
and b.status = 'ok'
) t
union
select 'macos' as "platform", count(t.*) as "total", round(count(t.*)*100 / (select count(*) from packages)::decimal, 1) as "fraction" from
(
select distinct p.url
from builds b
join versions v on b.version_id = v.id
join packages p on v.package_id = p.id 
where (platform = 'macos-spm' or platform = 'macos-xcodebuild')
and b.status = 'ok'
) t
union
select 'ios' as "platform", count(t.*) as "total", round(count(t.*)*100 / (select count(*) from packages)::decimal, 1) as "fraction" from
(
select distinct p.url
from builds b
join versions v on b.version_id = v.id
join packages p on v.package_id = p.id 
where platform = 'ios'
and b.status = 'ok'
) t
union
select 'tvos' as "platform", count(t.*) as "total", round(count(t.*)*100 / (select count(*) from packages)::decimal, 1) as "fraction" from
(
select distinct p.url
from builds b
join versions v on b.version_id = v.id
join packages p on v.package_id = p.id 
where platform = 'tvos'
and b.status = 'ok'
) t
union
select 'watchos' as "platform", count(t.*) as "total", round(count(t.*)*100 / (select count(*) from packages)::decimal, 1) as "fraction" from
(
select distinct p.url
from builds b
join versions v on b.version_id = v.id
join packages p on v.package_id = p.id 
where platform = 'watchos'
and b.status = 'ok'
) t;

select url from packages
where url not in (
    select p.url
    from packages p
    join versions v on v.package_id = p.id
    join builds b on b.version_id = v.id
    where 
    b.status = 'failed'
    group by p.url
)
limit 20;

select dependency, count(*) from (
    select p.url, unnest(resolved_dependencies)->>'repositoryURL' as dependency
    from versions v
    join packages p on v.package_id = p.id
    where 
    --package_id = 'ba6a7c68-3563-4783-bd88-24e209af7f0d' and
    latest = 'release'
) t
group by dependency
order by count(*) desc
limit 20;

select '6.0' as swift_version, count(t.*) as "total", round(count(t.*)*100 / (select count(*) from packages)::decimal, 1) as "fraction" from
(
select distinct p.id
from builds b
join versions v on b.version_id = v.id
join packages p on v.package_id = p.id 
where swift_version->>'major' = '6' and swift_version->>'minor' = '0'
and b.status = 'ok'
) t
union
select '5.10' as swift_version, count(t.*) as "total", round(count(t.*)*100 / (select count(*) from packages)::decimal, 1) as "fraction" from
(
select distinct p.id
from builds b
join versions v on b.version_id = v.id
join packages p on v.package_id = p.id 
where swift_version->>'major' = '5' and swift_version->>'minor' = '10'
and b.status = 'ok'
) t
union
select '5.9' as swift_version, count(t.*) as "total", round(count(t.*)*100 / (select count(*) from packages)::decimal, 1) as "fraction" from
(
select distinct p.id
from builds b
join versions v on b.version_id = v.id
join packages p on v.package_id = p.id 
where swift_version->>'major' = '5' and swift_version->>'minor' = '9'
and b.status = 'ok'
) t
union
select '5.8' as swift_version, count(t.*) as "total", round(count(t.*)*100 / (select count(*) from packages)::decimal, 1) as "fraction" from
(
select distinct p.id
from builds b
join versions v on b.version_id = v.id
join packages p on v.package_id = p.id 
where swift_version->>'major' = '5' and swift_version->>'minor' = '8'
and b.status = 'ok'
) t;

select '5.8' as swift_version, count(*) as "total", round(count(*)*100 / (select count(*) from builds where swift_version->>'major' = '5' and swift_version->>'minor' = '8')::decimal, 1) as "fraction"
from builds b
where swift_version->>'major' = '5' and swift_version->>'minor' = '8'
and b.status = 'ok'
union
select '5.9' as swift_version, count(*) as "total", round(count(*)*100 / (select count(*) from builds where swift_version->>'major' = '5' and swift_version->>'minor' = '9')::decimal, 1) as "fraction"
from builds b
where swift_version->>'major' = '5' and swift_version->>'minor' = '9'
and b.status = 'ok'
union
select '5.10' as swift_version, count(*) as "total", round(count(*)*100 / (select count(*) from builds where swift_version->>'major' = '5' and swift_version->>'minor' = '10')::decimal, 1) as "fraction"
from builds b
where swift_version->>'major' = '5' and swift_version->>'minor' = '10'
and b.status = 'ok'
union
select '6.0' as swift_version, count(*) as "total", round(count(*)*100 / (select count(*) from builds where swift_version->>'major' = '6' and swift_version->>'minor' = '0')::decimal, 1) as "fraction"
from builds b
where swift_version->>'major' = '6' and swift_version->>'minor' = '0'
and b.status = 'ok';