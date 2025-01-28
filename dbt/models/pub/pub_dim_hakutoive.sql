--{{ ref('pub_dim_hakukohde') }}
--{{ ref('pub_fct_hakemus') }}
{{
  config(
    materialized = 'table',
    indexes = [
        {'columns':['hakemus_oid']},
        {'columns':['hakukohde_oid']},
    ]
    )
}}

with hakutoive as not materialized (
    select * from {{ ref('int_hakutoive') }}
),

final as (
    select
        hakutoive_id,
        hakukohde_henkilo_id,
        hakemus_oid,
        henkilo_oid,
        hakukohde_oid,
        hakutoivenumero,
        viimeinen_vastaanottopaiva,
        vastaanottotieto
    from hakutoive
)

select * from final
