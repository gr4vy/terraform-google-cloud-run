Terraform Module: Google Cloud Run
==================================

A Terraform module for the [Google Cloud Platform](https://cloud.google.com) that simplifies the creation & configuration
of a Cloud Run (Fully Managed) service. This has been forked from [`garbetjie/terraform-google-cloud-run`](https://github.com/garbetjie/terraform-google-cloud-run)

# Introduction

This module is wrapper around the creation & configuration of [Google Cloud Run](https://cloud.google.com/run) (Fully
managed) services, and provides sensible defaults for many of the options. 

It attempts to be as complete as possible, and expose as much functionality as is available.
As a result, some functionality might only be provided as part of BETA releases. Google's SLA support for this level of
functionality is often not as solid as with Generally-Available releases. If you require absolute stability, this module
might not be the best for you.

# Secrets & Volumes

If your service requires the use of sensitive values, it is possible to store them in [Google Secret Manager](https://cloud.google.com/secret-manager)
and reference those secrets in your service. This will prevent the values of those secrets from being exposed to anyone
that might have access your service but not to the contents of the secrets.

Secrets can either be exposed as files through mounted volumes, or through environment variables. This can be configured
through the `volumes` and `env` input variables respectively.

> **Note:** Environment variables using the latest secret version will not be updated when a new version is added. Volumes
> using the latest version will have their contents automatically updated to reflect the latest secret version.

Refer to https://cloud.google.com/run/docs/configuring/secrets for further reading on secrets in Cloud Run.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1 |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 3.67.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 3.67.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 3.67.0 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | >= 3.67.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google-beta_google_cloud_run_service.default](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_cloud_run_service) | resource |
| [google_cloud_run_domain_mapping.domains](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_domain_mapping) | resource |
| [google_cloud_run_service_iam_member.public_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_public_access"></a> [allow\_public\_access](#input\_allow\_public\_access) | Allow unauthenticated access to the service. | `bool` | `true` | no |
| <a name="input_args"></a> [args](#input\_args) | Arguments to pass to the entrypoint. | `list(string)` | `[]` | no |
| <a name="input_cloudsql_connections"></a> [cloudsql\_connections](#input\_cloudsql\_connections) | Cloud SQL connections to attach to container instances. | `set(string)` | `[]` | no |
| <a name="input_concurrency"></a> [concurrency](#input\_concurrency) | Maximum allowed concurrent requests per container for this revision. | `number` | `null` | no |
| <a name="input_cpu_throttling"></a> [cpu\_throttling](#input\_cpu\_throttling) | Configure CPU throttling outside of request processing. | `bool` | `true` | no |
| <a name="input_cpus"></a> [cpus](#input\_cpus) | Number of CPUs to allocate per container. | `number` | `1` | no |
| <a name="input_entrypoint"></a> [entrypoint](#input\_entrypoint) | Entrypoint command. Defaults to the image's ENTRYPOINT if not provided. | `list(string)` | `[]` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment variables to inject into container instances. | <pre>set(<br>    object({<br>      key     = string,<br>      value   = optional(string),<br>      secret  = optional(string),<br>      version = optional(string),<br>    })<br>  )</pre> | `[]` | no |
| <a name="input_execution_environment"></a> [execution\_environment](#input\_execution\_environment) | Execution environment to run container instances under. | `string` | `"gen1"` | no |
| <a name="input_http2"></a> [http2](#input\_http2) | Enable use of HTTP/2 end-to-end. | `bool` | `false` | no |
| <a name="input_image"></a> [image](#input\_image) | Docker image name. | `string` | n/a | yes |
| <a name="input_ingress"></a> [ingress](#input\_ingress) | Ingress settings for the service. Allowed values: [`"all"`, `"internal"`, `"internal-and-cloud-load-balancing"`] | `string` | `"all"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to apply to the service. | `map(string)` | `{}` | no |
| <a name="input_liveness_probe"></a> [liveness\_probe](#input\_liveness\_probe) | Periodic probe of container liveness. Container will be restarted if the probe fails.<br>More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes | <pre>object({<br>    failure_threshold     = optional(number, null)<br>    initial_delay_seconds = optional(number, null)<br>    timeout_seconds       = optional(number, null)<br>    period_seconds        = optional(number, null)<br>    http_get = optional(object({<br>      path = optional(string)<br>      port = optional(number)<br>      http_headers = optional(list(object({<br>        name  = string<br>        value = string<br>      })), null)<br>    }), null)<br>    grpc = optional(object({<br>      port    = optional(number)<br>      service = optional(string)<br>    }), null)<br>  })</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Location of the service. | `string` | n/a | yes |
| <a name="input_map_domains"></a> [map\_domains](#input\_map\_domains) | Domain names to map to the service. | `set(string)` | `[]` | no |
| <a name="input_max_instances"></a> [max\_instances](#input\_max\_instances) | Maximum number of container instances allowed to start. | `number` | `1000` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory (in Mi) to allocate to containers. Minimum of 512Mi is required when `execution_environment` is `"gen2"`. | `number` | `256` | no |
| <a name="input_min_instances"></a> [min\_instances](#input\_min\_instances) | Minimum number of container instances to keep running. | `number` | `0` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the service. | `string` | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | Port on which the container is listening for incoming HTTP requests. | `number` | `8080` | no |
| <a name="input_project"></a> [project](#input\_project) | Google Cloud project in which to create resources. | `string` | `null` | no |
| <a name="input_revision"></a> [revision](#input\_revision) | Revision name to use. When `null`, revision names are automatically generated. | `string` | `null` | no |
| <a name="input_service_account_email"></a> [service\_account\_email](#input\_service\_account\_email) | IAM service account email to assign to container instances. | `string` | `null` | no |
| <a name="input_startup_cpu_boost"></a> [startup\_cpu\_boost](#input\_startup\_cpu\_boost) | Start containers faster by allocating more CPU during start-up time. | `bool` | `false` | no |
| <a name="input_startup_probe"></a> [startup\_probe](#input\_startup\_probe) | Startup probe of application within the container.<br>All other probes are disabled if a startup probe is provided, until it succeeds.<br>Container will not be added to service endpoints if the probe fails.<br>More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes | <pre>object({<br>    failure_threshold     = optional(number, null)<br>    initial_delay_seconds = optional(number, null)<br>    timeout_seconds       = optional(number, null)<br>    period_seconds        = optional(number, null)<br>    http_get = optional(object({<br>      path = optional(string)<br>      port = optional(number)<br>      http_headers = optional(list(object({<br>        name  = string<br>        value = string<br>      })), null)<br>    }), null)<br>    tcp_socket = optional(object({<br>      port = optional(number)<br>    }), null)<br>    grpc = optional(object({<br>      port    = optional(number)<br>      service = optional(string)<br>    }), null)<br>  })</pre> | `null` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Maximum duration (in seconds) allowed for responding to requests. | `number` | `60` | no |
| <a name="input_volumes"></a> [volumes](#input\_volumes) | Volumes to be mounted & populated from secrets or GCS. | <pre>set(<br>    object({<br>      path            = string,<br>      secret          = optional(string),<br>      versions        = optional(map(string)),<br>      gcs_bucket_name = optional(string),<br>      gcs_read_only   = optional(bool),<br>    })<br>  )</pre> | `[]` | no |
| <a name="input_vpc_access"></a> [vpc\_access](#input\_vpc\_access) | Control VPC access for the service. | `object({ connector = optional(string), egress = optional(string) })` | <pre>{<br>  "connector": null,<br>  "egress": null<br>}</pre> | no |
| <a name="input_vpc_access_egress"></a> [vpc\_access\_egress](#input\_vpc\_access\_egress) | Specify whether to divert all outbound traffic through the VPC, or private ranges only (Deprecated - use `var.vpc_access.egress` instead). | `string` | `"private-ranges-only"` | no |
| <a name="input_vpc_connector_name"></a> [vpc\_connector\_name](#input\_vpc\_connector\_name) | VPC connector to apply to this service (Deprecated - use `var.vpc_access.connector` instead). | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_allow_public_access"></a> [allow\_public\_access](#output\_allow\_public\_access) | Allow unauthenticated access to the service. |
| <a name="output_args"></a> [args](#output\_args) | Arguments passed to the entrypoint. |
| <a name="output_cloudsql_connections"></a> [cloudsql\_connections](#output\_cloudsql\_connections) | Cloud SQL connections attached to container instances. |
| <a name="output_concurrency"></a> [concurrency](#output\_concurrency) | Maximum allowed concurrent requests per container for the created revision. |
| <a name="output_cpu_throttling"></a> [cpu\_throttling](#output\_cpu\_throttling) | Configuration for CPU throttling outside of request processing. |
| <a name="output_cpus"></a> [cpus](#output\_cpus) | Number of CPUs allocated per container. |
| <a name="output_cpus_suffixed"></a> [cpus\_suffixed](#output\_cpus\_suffixed) | CPUs allocated per container, specified with the millicpu suffix (eg: "1000m" if `var.cpus` is 1). |
| <a name="output_dns"></a> [dns](#output\_dns) | DNS records to populate for mapped domains. Keys are the domains that are mapped. |
| <a name="output_entrypoint"></a> [entrypoint](#output\_entrypoint) | Entrypoint command used in the service. |
| <a name="output_env"></a> [env](#output\_env) | Environment variables injected into container instances. |
| <a name="output_execution_environment"></a> [execution\_environment](#output\_execution\_environment) | Execution environment container instances are running under. |
| <a name="output_http2"></a> [http2](#output\_http2) | Status of HTTP/2 end-to-end handling. |
| <a name="output_id"></a> [id](#output\_id) | ID of the created service. |
| <a name="output_image"></a> [image](#output\_image) | Docker image name. |
| <a name="output_ingress"></a> [ingress](#output\_ingress) | Ingress settings applied to the service. |
| <a name="output_labels"></a> [labels](#output\_labels) | Labels applied to the service. |
| <a name="output_latest_created_revision_name"></a> [latest\_created\_revision\_name](#output\_latest\_created\_revision\_name) | Last revision created. |
| <a name="output_latest_ready_revision_name"></a> [latest\_ready\_revision\_name](#output\_latest\_ready\_revision\_name) | Latest revision ready for use. |
| <a name="output_location"></a> [location](#output\_location) | Location of the service. |
| <a name="output_map_domains"></a> [map\_domains](#output\_map\_domains) | Domain names mapped to the service. |
| <a name="output_max_instances"></a> [max\_instances](#output\_max\_instances) | Maximum number of container instances allowed to start. |
| <a name="output_memory"></a> [memory](#output\_memory) | Memory (in Mi) allocated to container instances. |
| <a name="output_memory_suffixed"></a> [memory\_suffixed](#output\_memory\_suffixed) | Memory allocated to containers instances, with the relevant suffix (eg: "256Mi" if `var.memory` is 256). |
| <a name="output_min_instances"></a> [min\_instances](#output\_min\_instances) | Minimum number of container instances to keep running. |
| <a name="output_name"></a> [name](#output\_name) | Name of the service. |
| <a name="output_port"></a> [port](#output\_port) | Port on which the container is listening for incoming HTTP requests. |
| <a name="output_project"></a> [project](#output\_project) | Google Cloud project in which resources were created. |
| <a name="output_revision"></a> [revision](#output\_revision) | Revision name that was created. |
| <a name="output_service_account_email"></a> [service\_account\_email](#output\_service\_account\_email) | IAM service account email to assigned to container instances. |
| <a name="output_timeout"></a> [timeout](#output\_timeout) | Maximum duration (in seconds) allowed for responding to requests. |
| <a name="output_url"></a> [url](#output\_url) | URL at which the service is available. |
| <a name="output_volumes"></a> [volumes](#output\_volumes) | Secrets mounted as volumes into the service. |
| <a name="output_vpc_access"></a> [vpc\_access](#output\_vpc\_access) | VPC access configuration. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
