local k = import 'ksonnet/ksonnet.beta.3/k.libsonnet';
local secret = k.core.v1.secret;
local ingress = k.extensions.v1beta1.ingress;
local ingressTls = ingress.mixin.spec.tlsType;
local ingressRule = ingress.mixin.spec.rulesType;
local httpIngressPath = ingressRule.mixin.http.pathsType;

local kp =
  (import 'kube-prometheus/kube-prometheus.libsonnet') +
  {
    _config+:: {
      namespace: 'monitoring',
      prometheus+:: {
      namespaces+: ['ingress-nginx'],
    },
    },
    // Configure External URL's per application
    alertmanager+:: {
      alertmanager+: {
        spec+: {
          externalUrl: 'http://alertmanager.rfb.ovh',
        },
      },
    },
    grafana+:: {
      config+: {
        sections+: {
          server+: {
            root_url: 'http://grafana.rfb.ovh/',
          },
        },
      },
    },
    prometheus+:: {
      prometheus+: {
        spec+: {
          externalUrl: 'http://prometheus.rfb.ovh',
        },
      },
    },
    // Create ingress objects per application
    ingress+:: {
      'alertmanager-main':
        ingress.new() +
        ingress.mixin.metadata.withName('alertmanager-main') +
        ingress.mixin.metadata.withNamespace($._config.namespace) +
        ingress.mixin.metadata.withAnnotations({
        }) +
        ingress.mixin.spec.withRules(
          ingressRule.new() +
          ingressRule.withHost('alertmanager.rfb.ovh') +
          ingressRule.mixin.http.withPaths(
            httpIngressPath.new() +
            httpIngressPath.mixin.backend.withServiceName('alertmanager-main') +
            httpIngressPath.mixin.backend.withServicePort('web')
          ),
        ),
      grafana:
        ingress.new() +
        ingress.mixin.metadata.withName('grafana') +
        ingress.mixin.metadata.withNamespace($._config.namespace) +
        ingress.mixin.metadata.withAnnotations({
        }) +
        ingress.mixin.spec.withRules(
          ingressRule.new() +
          ingressRule.withHost('grafana.rfb.ovh') +
          ingressRule.mixin.http.withPaths(
            httpIngressPath.new() +
            httpIngressPath.mixin.backend.withServiceName('grafana') +
            httpIngressPath.mixin.backend.withServicePort('http')
          ),
        ),
      'prometheus-k8s':
        ingress.new() +
        ingress.mixin.metadata.withName('prometheus-k8s') +
        ingress.mixin.metadata.withNamespace($._config.namespace) +
        ingress.mixin.metadata.withAnnotations({
        }) +
        ingress.mixin.spec.withRules(
          ingressRule.new() +
          ingressRule.withHost('prometheus.rfb.ovh') +
          ingressRule.mixin.http.withPaths(
            httpIngressPath.new() +
            httpIngressPath.mixin.backend.withServiceName('prometheus-k8s') +
            httpIngressPath.mixin.backend.withServicePort('web')
          ),
        ),
    },
  } + {
    // Create basic auth secret - replace 'auth' file with your own
    ingress+:: {
    },
  };

{ ['00namespace-' + name]: kp.kubePrometheus[name] for name in std.objectFields(kp.kubePrometheus) } +
{ ['0prometheus-operator-' + name]: kp.prometheusOperator[name] for name in std.objectFields(kp.prometheusOperator) } +
{ ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
{ ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
{ ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
{ ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
{ ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) } +
{ [name + '-ingress']: kp.ingress[name] for name in std.objectFields(kp.ingress) }
