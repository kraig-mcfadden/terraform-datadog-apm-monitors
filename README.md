# terraform-datadog-apm-monitors
Opinionated set of monitors and SLOs for your Datadog trace metrics.

It creates a service time monitor and an error rate monitor per resource name 
for the given operation. There are default threshold values for the monitors but
those can be updated.

It also creates an SLO for the service time monitors (looking at all of them)
and an SLO for the error rate monitors (again, one SLO looking at all of the 
monitors). Note that there is a 20 monitor limit currently for an SLO, so if 
you've got more than 20 resources you may want to use this module more than once
(ceil(num_resources / 20) times in fact).

There are also monitors on the SLO error budgets, so if the error budget is
exhausted you can get an alert. SLOs span 3 time horizons (7 days, 30 days, 90 days)
and there are separate monitors for each time horizon.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_datadog"></a> [datadog](#provider\_datadog) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [datadog_monitor.error_rate_slo_monitors](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.high_error_rate_monitors](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.high_service_time_monitors](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_monitor.service_time_slo_monitors](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/monitor) | resource |
| [datadog_service_level_objective.error_rate_slo](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/service_level_objective) | resource |
| [datadog_service_level_objective.service_time_slo](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/service_level_objective) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_critical_error_rate"></a> [critical\_error\_rate](#input\_critical\_error\_rate) | Threshold error rate we want to alert at | `number` | `0.005` | no |
| <a name="input_critical_service_time"></a> [critical\_service\_time](#input\_critical\_service\_time) | Threshold service time (amount of time request takes on server) we want to alert at in seconds | `number` | `0.5` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment your traces are tagged with | `string` | n/a | yes |
| <a name="input_notify"></a> [notify](#input\_notify) | Notification handle for alerts. Must be of the form @pagerduty-{service} or @slack-{channel} etc. depending on the integration you're using | `string` | n/a | yes |
| <a name="input_operation"></a> [operation](#input\_operation) | Trace metric the queries will look at. Called 'operation' in the APM dashboard | `string` | n/a | yes |
| <a name="input_resource_names"></a> [resource\_names](#input\_resource\_names) | The resources you want to monitor by name. Check APM dashboard to see what your service has | `list(string)` | n/a | yes |
| <a name="input_service"></a> [service](#input\_service) | Service name your traces are tagged with | `string` | n/a | yes |
| <a name="input_team"></a> [team](#input\_team) | Team that owns these monitors | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->