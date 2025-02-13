with source as (
    select * from {{ source('ovara', 'sure_arvosana') }}

    {% if is_incremental() %}

        where dw_metadata_dbt_copied_at > (
            select coalesce(max(dw_metadata_dbt_copied_at), '1899-12-31') from {{ this }}
        )

    {% endif %}
),

final as (
    select
        data ->> 'resourceId'::varchar as resourceid,
        data ->> 'suoritus'::varchar as suoritus,
        data ->> 'arvosana'::varchar as arvosana,
        data ->> 'asteikko'::varchar as asteikko,
        data ->> 'aine'::varchar as aine,
        data ->> 'lisatieto'::varchar as lisatieto,
        (data ->> 'valinnainen')::boolean as valinnainen,
        --to_timestamp((data ->> ('inserted')::varchar)::bigint /1000 ) as inserted, #Changed column name to muokattu
        --to_timestamp((data ->> ('inserted')::varchar)::bigint /1000 ) as muokattu,
        ((
            to_timestamp(((data ->> ('inserted')::varchar)::bigint / 1000)
            ) at time zone 'utc' at time zone 'europe/helsinki'
        )::timestamptz) as muokattu,
        (data ->> 'deleted')::boolean as deleted,
        data ->> 'pisteet'::varchar as pisteet,
        --data ->> 'myonnetty'::varchar as myonnetty,
        (data ->> 'myonnetty')::timestamptz as myonnetty,
        data ->> 'source'::varchar as source,
        data ->> 'jarjestys'::varchar as jarjestys,
        data -> 'lahdeArvot' ->> 'arvot'::varchar as arvot,
        {{ metadata_columns() }}

    from source

)

select * from final
