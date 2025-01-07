
resource "google_cloud_run_service" "default" {
  provider = google-beta

  name                       = var.name
  location                   = var.location
  autogenerate_revision_name = true
  project                    = local.project_id

  metadata {
    namespace = local.project_id
    labels    = var.labels
    annotations = {
      "run.googleapis.com/launch-stage" = local.launch_stage
      "run.googleapis.com/ingress"      = var.ingress
      "run.googleapis.com/client-name"  = "terraform"
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].metadata[0].annotations["client.knative.dev/user-image"],
      template[0].metadata[0].annotations["run.googleapis.com/client-name"],
      template[0].metadata[0].annotations["run.googleapis.com/client-version"],
      template[0].metadata[0].annotations["run.googleapis.com/sandbox"],
      template[0].spec[0].containers[0].image,
      metadata[0].annotations["serving.knative.dev/creator"],
      metadata[0].annotations["serving.knative.dev/lastModifier"],
      metadata[0].annotations["run.googleapis.com/ingress-status"],
      metadata[0].annotations["run.googleapis.com/launch-stage"],
      metadata[0].annotations["client.knative.dev/user-image"],
      metadata[0].labels["cloud.googleapis.com/location"],
    ]
  }

  template {
    spec {
      container_concurrency = var.concurrency
      timeout_seconds       = var.timeout
      service_account_name  = var.service_account_email

      containers {
        image   = var.image
        command = var.entrypoint
        args    = var.args

        ports {
          name           = var.http2 ? "h2c" : "http1"
          container_port = var.port
        }

        resources {
          limits = {
            cpu    = "${var.cpus * 1000}m"
            memory = "${var.memory}Mi"
          }
        }

        # Populate straight environment variables.
        dynamic "env" {
          for_each = { for i in [for e in local.env : e if e.value != null] : i.key => i }

          content {
            name  = env.value.key
            value = env.value.value
          }
        }

        # Populate environment variables from secrets.
        dynamic "env" {
          for_each = { for i in [for e in local.env : e if e.secret.name != null] : i.key => i }

          content {
            name = env.value.key
            value_from {
              secret_key_ref {
                name = coalesce(env.value.secret.alias, env.value.secret.name)
                key  = env.value.secret.version
              }
            }
          }
        }

        dynamic "volume_mounts" {
          for_each = local.volumes

          content {
            name       = volume_mounts.value.name
            mount_path = volume_mounts.value.path
          }
        }

        dynamic "startup_probe" {
          for_each = var.startup_probe != null ? [1] : []
          content {
            failure_threshold     = var.startup_probe.failure_threshold
            initial_delay_seconds = var.startup_probe.initial_delay_seconds
            timeout_seconds       = var.startup_probe.timeout_seconds
            period_seconds        = var.startup_probe.period_seconds
            dynamic "http_get" {
              for_each = var.startup_probe.http_get != null ? [1] : []
              content {
                path = var.startup_probe.http_get.path
                dynamic "http_headers" {
                  for_each = var.startup_probe.http_get.http_headers != null ? var.startup_probe.http_get.http_headers : []
                  content {
                    name  = http_headers.value["name"]
                    value = http_headers.value["value"]
                  }
                }
              }
            }
            dynamic "tcp_socket" {
              for_each = var.startup_probe.tcp_socket != null ? [1] : []
              content {
                port = var.startup_probe.tcp_socket.port
              }
            }
            dynamic "grpc" {
              for_each = var.startup_probe.grpc != null ? [1] : []
              content {
                port    = var.startup_probe.grpc.port
                service = var.startup_probe.grpc.service
              }
            }
          }
        }

        dynamic "liveness_probe" {
          for_each = var.liveness_probe != null ? [1] : []
          content {
            failure_threshold     = var.liveness_probe.failure_threshold
            initial_delay_seconds = var.liveness_probe.initial_delay_seconds
            timeout_seconds       = var.liveness_probe.timeout_seconds
            period_seconds        = var.liveness_probe.period_seconds
            dynamic "http_get" {
              for_each = var.liveness_probe.http_get != null ? [1] : []
              content {
                path = var.liveness_probe.http_get.path
                dynamic "http_headers" {
                  for_each = var.liveness_probe.http_get.http_headers != null ? var.liveness_probe.http_get.http_headers : []
                  content {
                    name  = http_headers.value["name"]
                    value = http_headers.value["value"]
                  }
                }
              }
            }
            dynamic "grpc" {
              for_each = var.liveness_probe.grpc != null ? [1] : []
              content {
                port    = var.liveness_probe.grpc.port
                service = var.liveness_probe.grpc.service
              }
            }
          }
        }
      }

      dynamic "volumes" {
        for_each = local.volumes

        content {
          name = volumes.value.name

          secret {
            secret_name = coalesce(volumes.value.secret.alias, volumes.value.secret.name)

            dynamic "items" {
              for_each = volumes.value.items

              content {
                key  = items.value.version
                path = items.value.filename
              }
            }
          }
        }
      }
    }

    metadata {
      labels = var.labels
      annotations = merge(
        {
          "run.googleapis.com/cpu-throttling"        = var.cpu_throttling
          "run.googleapis.com/cloudsql-instances"    = join(",", var.cloudsql_connections)
          "autoscaling.knative.dev/maxScale"         = var.max_instances
          "autoscaling.knative.dev/minScale"         = var.min_instances
          "run.googleapis.com/execution-environment" = var.execution_environment
          "run.googleapis.com/startup-cpu-boost"     = var.startup_cpu_boost
        },
        local.vpc_access.connector == null ? {} : {
          "run.googleapis.com/vpc-access-connector" = local.vpc_access.connector
          "run.googleapis.com/vpc-access-egress"    = local.vpc_access.egress
        },
        length(local.secrets_to_aliases) < 1 ? {} : {
          "run.googleapis.com/secrets" = join(",", [for secret, alias in local.secrets_to_aliases : "${alias}:${secret}"])
        },
      )
    }
  }

  traffic {
    percent         = 100
    latest_revision = var.revision == null
    revision_name   = var.revision != null ? "${var.name}-${var.revision}" : null
  }
}


resource "google_cloud_run_service_iam_member" "public_access" {
  count    = var.allow_public_access ? 1 : 0
  service  = google_cloud_run_service.default.name
  location = google_cloud_run_service.default.location
  project  = google_cloud_run_service.default.project
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_domain_mapping" "domains" {
  for_each = var.map_domains

  location = google_cloud_run_service.default.location
  project  = google_cloud_run_service.default.project
  name     = each.value

  metadata {
    namespace = google_cloud_run_service.default.project
    annotations = {
      "run.googleapis.com/launch-stage" = local.launch_stage
    }
  }

  spec {
    route_name = google_cloud_run_service.default.name
  }

  lifecycle {
    ignore_changes = [metadata[0]]
  }
}
