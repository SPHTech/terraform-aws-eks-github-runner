resource "kubectl_manifest" "github_repository_runners" {
  for_each  = { for repo in var.github_repositories : repo.name => repo }
  yaml_body = <<YAML
  apiVersion: actions.summerwind.dev/v1alpha1
  kind: RunnerDeployment
  metadata:
    name: ${replace(lower(each.value.name), "/", "-")}-runner-deployment
    namespace: ${var.namespace}
  spec:
    replicas: ${each.value.replicas}
    template:
      spec:
        repository: ${each.value.name}
        serviceAccountName: ${var.service_account_name}
        securityContext:
          fsGroup: 1000
        labels:
          - ${each.value.label}
YAML

  depends_on = [helm_release.github_runner]
}

resource "kubectl_manifest" "github_repository_runners_autoscaler" {
  for_each  = { for repo in var.github_repositories : repo.name => repo }
  yaml_body = <<YAML
  apiVersion: actions.summerwind.dev/v1alpha1
  kind: HorizontalRunnerAutoscaler
  metadata:
      name: ${replace(lower(each.value.name), "/", "-")}-runner-autoscaler
      namespace: ${var.namespace}
  spec:
      scaleTargetRef:
        name: ${replace(lower(each.value.name), "/", "-")}-runner-deployment
      scaleDownDelaySecondsAfterScaleOut: 300
      minReplicas: ${each.value.min_replicas}
      maxReplicas: ${each.value.max_replicas}
      metrics:
      - type: TotalNumberOfQueuedAndInProgressWorkflowRuns
        repositoryNames:
        - ${each.value.name}
YAML

  depends_on = [kubectl_manifest.github_repository_runners]
}
