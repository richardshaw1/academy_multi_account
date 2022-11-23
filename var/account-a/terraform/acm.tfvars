# ----------------------------------------------------------------------------------------------------------------------
# Amazon Public certificates
# ----------------------------------------------------------------------------------------------------------------------

us_east_1_certs_to_create = {
  "mobilise_academy_rs_cert" = {
    create_certificate = true
    domain_name        = "www.mobiliseacademyrs.mobilise.academy"
    validation_method  = "DNS"
    sans               = ["mobiliseacademyrs.mobilise.academy"]
    tag_cert_name      = "mobilise-academy-cert"
  }
}