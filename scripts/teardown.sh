#!/usr/bin/env bash
set -euo pipefail # Exit on command failure, undefined variable, fail pipes if any step fails
kubectl scale statefulset argocd-application-controller -n argocd --replicas=0
kubectl delete ingress --all -A --wait=true --timeout=10m
sleep 60   # let external-dns remove the Route53 records
kubectl delete externalsecrets --all -A --timeout=60s || true
kubectl delete clustersecretstores --all --timeout=60s || true
terraform -chdir=terraform destroy --auto-approve