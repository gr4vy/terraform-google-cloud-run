variable "name" {
  type        = string
  description = "Name of the service."
}

variable "image" {
  type        = string
  description = "Docker image name."
}

variable "location" {
  type        = string
  description = "Location of the service."
}

// --

variable "allow_public_access" {
  type        = bool
  default     = true
  description = "Allow unauthenticated access to the service."
}

variable "args" {
  type        = list(string)
  default     = []
  description = "Arguments to pass to the entrypoint."
}

variable "cloudsql_connections" {
  type        = set(string)
  default     = []
  description = "Cloud SQL connections to attach to container instances."
}

variable "concurrency" {
  type        = number
  default     = null
  description = "Maximum allowed concurrent requests per container for this revision."
}

variable "cpu_throttling" {
  type        = bool
  default     = true
  description = "Configure CPU throttling outside of request processing."
}

variable "cpus" {
  type        = number
  default     = 1
  description = "Number of CPUs to allocate per container."
}

variable "entrypoint" {
  type        = list(string)
  default     = []
  description = "Entrypoint command. Defaults to the image's ENTRYPOINT if not provided."
}

variable "env" {
  type = set(
    object({
      key     = string,
      value   = optional(string),
      secret  = optional(string),
      version = optional(string),
    })
  )

  default     = []
  description = "Environment variables to inject into container instances."

  validation {
    error_message = "Environment variables must have one of `value` or `secret` defined."
    condition = alltrue([
      length([for e in var.env : e if(e.value == null && e.secret == null)]) < 1,
      length([for e in var.env : e if(e.value != null && e.secret != null)]) < 1,
    ])
  }
}

variable "execution_environment" {
  type        = string
  default     = "gen1"
  description = "Execution environment to run container instances under."
}

variable "http2" {
  type        = bool
  default     = false
  description = "Enable use of HTTP/2 end-to-end."
}

variable "ingress" {
  type        = string
  default     = "all"
  description = "Ingress settings for the service. Allowed values: [`\"all\"`, `\"internal\"`, `\"internal-and-cloud-load-balancing\"`]"

  validation {
    error_message = "Ingress must be one of: [\"all\", \"internal\", \"internal-and-cloud-load-balancing\"]."
    condition     = contains(["all", "internal", "internal-and-cloud-load-balancing"], var.ingress)
  }
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "Labels to apply to the service."
}

variable "map_domains" {
  type        = set(string)
  default     = []
  description = "Domain names to map to the service."
}

variable "max_instances" {
  type        = number
  default     = 1000
  description = "Maximum number of container instances allowed to start."
}

variable "memory" {
  type        = number
  default     = 256
  description = "Memory (in Mi) to allocate to containers. Minimum of 512Mi is required when `execution_environment` is `\"gen2\"`."
}

variable "min_instances" {
  type        = number
  default     = 0
  description = "Minimum number of container instances to keep running."
}

variable "port" {
  type        = number
  default     = 8080
  description = "Port on which the container is listening for incoming HTTP requests."
}

variable "project" {
  type        = string
  default     = null
  description = "Google Cloud project in which to create resources."
}

variable "revision" {
  type        = string
  default     = null
  description = "Revision name to use. When `null`, revision names are automatically generated."
}

variable "service_account_email" {
  type        = string
  default     = null
  description = "IAM service account email to assign to container instances."
}

variable "startup_cpu_boost" {
  type        = bool
  default     = false
  description = "Start containers faster by allocating more CPU during start-up time."
}

variable "timeout" {
  type        = number
  default     = 60
  description = "Maximum duration (in seconds) allowed for responding to requests."
}

variable "volumes" {
  type = set(
    object({
      path            = string,
      secret          = optional(string),
      versions        = optional(map(string)),
      gcs_bucket_name = optional(string),
      gcs_read_only   = optional(bool),
    })
  )
  default     = []
  description = "Volumes to be mounted & populated from secrets or GCS."

  validation {
    error_message = "Multiple volumes for the same path can't be defined."
    condition     = length(tolist(var.volumes.*.path)) == length(toset(var.volumes.*.path))
  }

  validation {
    error_message = "Volumes must have one of `gcs_bucket_name` or `secret` defined."
    condition = alltrue([
      length([for e in var.env : e if(e.gcs_bucket_name == null && e.secret == null)]) < 1,
      length([for e in var.env : e if(e.gcs_bucket_name != null && e.secret != null)]) < 1,
    ])
  }
}

variable "vpc_access" {
  type        = object({ connector = optional(string), egress = optional(string) })
  default     = { connector = null, egress = null }
  description = "Control VPC access for the service."

  validation {
    error_message = "VPC access egress must be one of the following values: [\"all-traffic\", \"private-ranges-only\"]."
    condition     = var.vpc_access.connector == null || var.vpc_access.egress == null || contains(["all-traffic", "private-ranges-only"], coalesce(var.vpc_access.egress, "private-ranges-only"))
  }
}

variable "vpc_connector_name" {
  type        = string
  default     = null
  description = "VPC connector to apply to this service (Deprecated - use `var.vpc_access.connector` instead)."
}

variable "vpc_access_egress" {
  type        = string
  default     = "private-ranges-only"
  description = "Specify whether to divert all outbound traffic through the VPC, or private ranges only (Deprecated - use `var.vpc_access.egress` instead)."
}

variable "startup_probe" {
  type = object({
    failure_threshold     = optional(number, null)
    initial_delay_seconds = optional(number, null)
    timeout_seconds       = optional(number, null)
    period_seconds        = optional(number, null)
    http_get = optional(object({
      path = optional(string)
      port = optional(number)
      http_headers = optional(list(object({
        name  = string
        value = string
      })), null)
    }), null)
    tcp_socket = optional(object({
      port = optional(number)
    }), null)
    grpc = optional(object({
      port    = optional(number)
      service = optional(string)
    }), null)
  })
  default     = null
  description = <<-EOF
    Startup probe of application within the container.
    All other probes are disabled if a startup probe is provided, until it succeeds.
    Container will not be added to service endpoints if the probe fails.
    More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes
  EOF
}

variable "liveness_probe" {
  type = object({
    failure_threshold     = optional(number, null)
    initial_delay_seconds = optional(number, null)
    timeout_seconds       = optional(number, null)
    period_seconds        = optional(number, null)
    http_get = optional(object({
      path = optional(string)
      port = optional(number)
      http_headers = optional(list(object({
        name  = string
        value = string
      })), null)
    }), null)
    grpc = optional(object({
      port    = optional(number)
      service = optional(string)
    }), null)
  })
  default     = null
  description = <<-EOF
    Periodic probe of container liveness. Container will be restarted if the probe fails.
    More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes
  EOF
}
