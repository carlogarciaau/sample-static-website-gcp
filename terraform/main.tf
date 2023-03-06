# Enable compute API
resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

# Bucket to host static files
resource "google_storage_bucket" "static_files" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = true

   website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

resource "google_storage_bucket_iam_member" "backend_bucket" {
  bucket = google_storage_bucket.static_files.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
  depends_on = [google_storage_bucket.static_files]
}

resource "google_compute_backend_bucket" "backend_bucket" {
  name        = "website-backend-bucket"
  description = "Backend bucket which contains the website static files"
  bucket_name = google_storage_bucket.static_files.name
  enable_cdn  = true
}

resource "google_compute_url_map" "url_map" {
  name            = "url-map"
  default_service = google_compute_backend_bucket.backend_bucket.self_link
}

resource "google_compute_managed_ssl_certificate" "managed_ssl_cert" {
  name = "managed-ssl-certificate"
  managed {
    domains = var.my_domains
  }
}

resource "google_compute_target_https_proxy" "https_proxy" {
  name             = "https-proxy"
  url_map          = google_compute_url_map.url_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.managed_ssl_cert.id]
}

resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  name        = "forwarding-rule-https"
  target      = google_compute_target_https_proxy.https_proxy.self_link
  port_range  = "443"
  ip_address  = google_compute_global_address.frontend_ip.id
  ip_protocol = "TCP"
}

resource "google_compute_global_address" "frontend_ip" {
  name = "frontend"
  purpose = "GLOBAL"
}

output "load_balancer_ip_addr" {
  value = google_compute_global_address.frontend_ip.address
}