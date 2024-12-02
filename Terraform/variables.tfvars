provider_credentials = {
    subscription_id  = "{tmp_subscription_id}"
    tenant_id        = "{tmp_tenant_id}"
    sp_client_id     = "{tmp_sp_client_id}"
    sp_client_secret = "{tmp_sp_client_secret}"
}

resource_group_config = {
    name             = "{tmp_resource_group_name}"
    location         = "{tmp_resource_group_location}"
}

storage_account_config={
    name             = "{tmp_storage_account_name}"
}

function_config={
    name             ="{tmp_function_name}"
}

cosmos_config={
    name             ="{tmp_cosmos_name}"
    db_name          ="{tmp_cosmos_db_name}"
    collection1_name ="{tmp_cosmos_collection1_name}"
    collection2_name ="{tmp_cosmos_collection2_name}"
}

acr_config={
    name             ="{tmp_acr_name}"
}

aks_config={
    name             ="{tmp_aks_name}"
}

app_config={
    name_func        ="{tmp_app_name_func}"
    name_aks         ="{tmp_app_name_aks}"
}
