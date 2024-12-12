{{
  config(
    materialized = 'table',
    indexes = [
        {'columns': ['organisaatio_oid']},
        {'columns': ['tila']}
    ]
    )
}}

with organisaatio_raw as (
    select
        *,
        row_number() over (partition by organisaatio_oid order by muokattu desc) as rownr
    from {{ ref('dw_organisaatio_organisaatio') }}
),

organisaatio as not materialized (
    select * from organisaatio_raw where rownr = 1
),

ylempi_toimipiste as (
    select
        organisaatio_oid,
        nimi_fi,
        nimi_sv
    from organisaatio
    where organisaatiotyypit @> '["organisaatiotyyppi_03"]'
),


kunta as (
    select * from {{ ref('int_koodisto_kunta') }} where viimeisin_versio
),

organisaatiotyyppi as (
    select * from {{ ref('int_organisaatio_organisaatiotyyppi') }}
),

int as (
    select
        org1.organisaatio_oid,
        coalesce(org1.nimi_fi, org1.nimi_sv) as nimi_fi_new,
        coalesce(org1.nimi_sv, org1.nimi_fi) as nimi_sv_new,
        coalesce(org1.nimi_fi, org1.nimi_sv) as nimi_en_new,
        coalesce(ylto.nimi_fi, ylto.nimi_sv) as nimi_fi_new_ylempi,
        coalesce(ylto.nimi_sv, ylto.nimi_fi) as nimi_sv_new_ylempi,
        coalesce(ylto.nimi_fi, ylto.nimi_sv) as nimi_en_new_ylempi,
        org1.ylempi_organisaatio,
        org1.sijaintikunta,
        org1.tila,
        org1.opetuskielet,
        org1.organisaatiotyypit
    from organisaatio as org1
    left join ylempi_toimipiste as ylto on org1.ylempi_organisaatio = ylto.organisaatio_oid
),

final as (
    select
        raw1.organisaatio_oid,
        case
            when nimi_fi_new_ylempi is not null
                then
                    jsonb_build_object(
                        'en', nimi_en_new_ylempi || ', ' || nimi_en_new,
                        'sv', nimi_sv_new_ylempi || ', ' || nimi_sv_new,
                        'fi', nimi_fi_new_ylempi || ', ' || nimi_fi_new
                    )
            else
                jsonb_build_object(
                    'en', nimi_en_new,
                    'sv', nimi_sv_new,
                    'fi', nimi_fi_new
                )
        end as organisaatio_nimi,
        raw1.ylempi_organisaatio,
        raw1.sijaintikunta,
        kunt.koodinimi as sijaintikunta_nimi,
        raw1.opetuskielet,
        orgt.organisaatiotyypit,
        raw1.tila
    from int as raw1
    left join kunta as kunt on raw1.sijaintikunta = kunt.koodiuri
    left join organisaatiotyyppi as orgt on raw1.organisaatio_oid = orgt.organisaatio_oid
)

select * from final
