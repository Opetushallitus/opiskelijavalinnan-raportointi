{%- set stage_model = ref('stg_sure_proxysuoritukset') -%}
{%- set key_columns_list = ['hakemusOid'] -%}

{{ generate_dw_model_muokattu(stage_model, key_columns_list) }}
