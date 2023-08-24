locals {
  slo_thresholds = [
    { timeframe = "30d", target = 99 },
    { timeframe = "7d", target = 99 },
    { timeframe = "90d", target = 99 },
  ]

  service_time_query    = "percentile(last_10m):p90:trace.${var.operation}{env:${var.env},service:${var.service},resource_name:resource_name_placeholder} > ${var.critical_service_time}"
  error_rate_query = "sum(last_10m):sum:trace.${var.operation}.errors{resource_name:resource_name_placeholder , env:${var.env} , service:${var.service}}.as_count() / sum:trace.${var.operation}.hits{resource_name:resource_name_placeholder , env:${var.env} , service:${var.service}}.as_count() > ${var.critical_error_rate}"

  tags = [
    "env:${var.env}",
    "team:${var.team}",
    "service:${var.service}",
    "managed_by:terraform"
  ]
}

/* -------- Service Time (colloquially called "latency" though that's technically not the same thing) -------- */
resource "datadog_monitor" "high_service_time_monitors" {
  for_each = toset(var.resource_names)

  name    = "${var.service} ${var.env} High Resource Service Time Alert - ${each.key}"
  message = "${each.key} (${var.env}) - high service time detected for this resource ${var.notify}"
  type    = "query alert"
  query   = replace(local.service_time_query, "resource_name_placeholder", each.key)

  monitor_thresholds {
    critical = var.critical_service_time
  }

  force_delete = true
  tags         = local.tags
}

// SLO against all service time monitors
resource "datadog_service_level_objective" "service_time_slo" {
  name        = "${title(var.service)} Resource Service Time"
  type        = "monitor"
  description = "Service time SLO for resources in ${title(var.service)}"
  monitor_ids = [for k, v in datadog_monitor.high_service_time_monitors : v.id]

  dynamic "thresholds" {
    for_each = toset(local.slo_thresholds)
    content {
      timeframe = thresholds.value.timeframe
      target    = thresholds.value.target
    }
  }

  tags = local.tags
}

// Alert on service time SLO
resource "datadog_monitor" "service_time_slo_monitors" {
  for_each = { for th in local.slo_thresholds : th.timeframe => th.target }
  message  = "${datadog_service_level_objective.service_time_slo.name} ${each.key} ${title(var.env)} SLO has expended error budget ${var.notify}"
  name     = "${each.key} Error Budget Alert on SLO: ${datadog_service_level_objective.service_time_slo.name}"
  type     = "slo alert"
  query    = "error_budget(\"${datadog_service_level_objective.service_time_slo.id}\").over(\"${each.key}\") > 100"

  monitor_thresholds {
    critical = 100
  }

  tags = local.tags
}

/* -------- Error Rate -------- */
resource "datadog_monitor" "high_error_rate_monitors" {
  for_each = toset(var.resource_names)

  name    = "${var.service} ${var.env} High Resource Error Rate Alert - ${each.key}"
  message = "${each.key} (${var.env}) - high error rate detected for this resource ${var.notify}"
  type    = "query alert"
  query   = replace(local.error_rate_query, "resource_name_placeholder", each.key)

  monitor_thresholds {
    critical = var.critical_error_rate
  }

  force_delete = true

  tags = local.tags
}

// SLO against all error rate monitors
resource "datadog_service_level_objective" "error_rate_slo" {
  name        = "${title(var.service)} Resource Error Rate"
  type        = "monitor"
  description = "Error rate SLO for resources in ${title(var.service)}"
  monitor_ids = [for k, v in datadog_monitor.high_error_rate_monitors : v.id]

  dynamic "thresholds" {
    for_each = toset(local.slo_thresholds)
    content {
      timeframe = thresholds.value.timeframe
      target    = thresholds.value.target
    }
  }

  tags = local.tags
}

// Alert on error rate SLO
resource "datadog_monitor" "error_rate_slo_monitors" {
  for_each = { for th in local.slo_thresholds : th.timeframe => th.target }
  message  = "${datadog_service_level_objective.error_rate_slo.name} ${each.key} ${title(var.env)} SLO has expended error budget ${var.notify}"
  name     = "${each.key} Error Budget Alert on SLO: ${datadog_service_level_objective.error_rate_slo.name}"
  type     = "slo alert"
  query    = "error_budget(\"${datadog_service_level_objective.error_rate_slo.id}\").over(\"${each.key}\") > 100"

  monitor_thresholds {
    critical = 100
  }

  tags = local.tags
}
