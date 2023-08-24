variable "service" {
  type = string
  description = "Service name your traces are tagged with"
}

variable "env" {
  type = string
  description = "Environment your traces are tagged with"
}

variable "team" {
  type = string
  description = "Team that owns these monitors"
}

variable "notify" {
  type = string
  description = "Notification handle for alerts. Must be of the form @pagerduty-{service} or @slack-{channel} etc. depending on the integration you're using"
}

variable "resource_names" {
  type = list(string)
  description = "The resources you want to monitor by name. Check APM dashboard to see what your service has"
}

variable "operation" {
  type = string
  description = "Trace metric the queries will look at. Called 'operation' in the APM dashboard"
}

variable "critical_service_time" {
  type = number
  description = "Threshold service time (amount of time request takes on server) we want to alert at in seconds"
  default = 0.5
}

variable "critical_error_rate" {
  type = number
  description = "Threshold error rate we want to alert at"
  default = 0.005
}
