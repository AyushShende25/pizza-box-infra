# Pizzabox --- Commands Cheat Sheet

A practical reference for Terraform, AWS, EKS, kind, Kubernetes,
Docker/ECR, Helm, Argo CD, migrations, and troubleshooting.

## Terraform setup and workflow

``` bash
mkdir -p terraform
cd terraform
touch main.tf variables.tf outputs.tf backend.tf providers.tf \
  terraform.tfvars terraform.tfvars.example

mkdir -p modules/{vpc,eks,rds,elasticache,ecr,s3,cloudfront,route53,iam,secrets-manager,security-groups,acm,alb}
touch modules/iam/{main.tf,variables.tf,outputs.tf}

alias tf="terraform"
```

Persist the alias in zsh, if desired:

``` bash
echo 'alias tf="terraform"' >> ~/.zshrc
source ~/.zshrc
```

Format, initialize, validate, plan, apply and destroy:

``` bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan
terraform apply --auto-approve
terraform destroy --auto-approve
```


## AWS CLI and EKS access

``` bash
aws sts get-caller-identity
aws configure list
aws eks list-clusters --region ap-south-1

aws eks update-kubeconfig \
  --region ap-south-1 \
  --name pizzabox-eks

kubectl config get-contexts
kubectl config current-context
kubectl get nodes -o wide
kubectl config use-context <context-name>
```

## Local Kubernetes with kind

``` bash
kind create cluster --config kubernetes/local-cluster.yaml
kind get clusters
kubectl config get-contexts

kind load docker-image pizzabox:latest

kind delete cluster
```

## Kubernetes namespace and inspection

``` bash
kubectl apply -f kubernetes/namespace.yaml
kubectl config set-context --current --namespace=pizzabox-app-ns

kubectl get all -n pizzabox-app-ns
kubectl get pods -n pizzabox-app-ns -o wide
kubectl get deployments,services,ingresses,jobs,hpa -n pizzabox-app-ns
kubectl get events -n pizzabox-app-ns --sort-by=.metadata.creationTimestamp

kubectl describe pod <pod-name> -n pizzabox-app-ns
kubectl describe deployment <deployment-name> -n pizzabox-app-ns
kubectl logs <pod-name> -n pizzabox-app-ns
kubectl logs -f deployment/pizzabox-api -n pizzabox-app-ns
kubectl logs -f deployment/pizzabox-worker -n pizzabox-app-ns
```

Rollouts and temporary scaling:

``` bash
kubectl rollout status deployment/pizzabox-api -n pizzabox-app-ns
kubectl rollout history deployment/pizzabox-api -n pizzabox-app-ns
kubectl rollout restart deployment/pizzabox-api -n pizzabox-app-ns
kubectl scale deployment/pizzabox-api --replicas=1 -n pizzabox-app-ns
```

## Build and push the backend image to ECR

Run from the **backend repository**:

``` bash
aws ecr get-login-password --region ap-south-1 \
  | docker login --username AWS --password-stdin \
    651447471372.dkr.ecr.ap-south-1.amazonaws.com

docker build --platform linux/amd64 -t pizzabox-backend:latest .
# Optional clean rebuild:
docker build --no-cache --platform linux/amd64 -t pizzabox-backend:latest .

docker tag pizzabox-backend:latest \
  651447471372.dkr.ecr.ap-south-1.amazonaws.com/pizzabox-backend:latest

docker push \
  651447471372.dkr.ecr.ap-south-1.amazonaws.com/pizzabox-backend:latest
```

Inspect images and ECR:

``` bash
docker images
aws ecr describe-repositories --region ap-south-1
aws ecr describe-images --region ap-south-1 --repository-name pizzabox-backend
```


## Local secrets and raw manifests

For a local/test cluster only:

``` bash
kubectl create secret generic pizzabox-secret \
  --from-env-file=.env \
  -n pizzabox-app-ns
```

``` bash
kubectl apply -f kubernetes/worker/deployment.yaml -n pizzabox-app-ns
kubectl apply -f kubernetes/api/deployment.yaml -n pizzabox-app-ns
kubectl apply -f kubernetes/api/service.yaml -n pizzabox-app-ns

kubectl get configmaps,secrets -n pizzabox-app-ns
kubectl get serviceaccounts,roles,rolebindings -n pizzabox-app-ns
```

## Helm

``` bash
helm lint ./helm/pizzabox
helm template pizzabox ./helm/pizzabox --namespace pizzabox-app-ns

helm install pizzabox ./helm/pizzabox \
  --namespace pizzabox-app-ns --create-namespace \
  --dry-run --debug

helm install pizzabox ./helm/pizzabox \
  --namespace pizzabox-app-ns --create-namespace

helm list -A
helm status pizzabox -n pizzabox-app-ns
helm get values pizzabox -n pizzabox-app-ns
helm get manifest pizzabox -n pizzabox-app-ns

helm upgrade pizzabox ./helm/pizzabox --namespace pizzabox-app-ns
helm uninstall pizzabox --namespace pizzabox-app-ns
```

## Argo CD

``` bash
kubectl port-forward svc/argocd-server -n argocd 8080:443

kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
echo

kubectl apply -f argocd/bootstrap/root-app.yaml

kubectl get applications -n argocd
kubectl get appprojects -n argocd
kubectl get pods -n argocd
kubectl logs deployment/argocd-application-controller -n argocd
kubectl logs deployment/argocd-repo-server -n argocd
```

If the Argo CD CLI is installed and authenticated:

``` bash
argocd app list
argocd app get <application-name>
argocd app diff <application-name>
argocd app history <application-name>
```

## Database migrations and seed data

Run the seed script in the deployed API pod:

``` bash
kubectl exec -n pizzabox-app-ns deploy/pizzabox-api -- \
  /app/.venv/bin/python -m app.utils.seed
```

Inspect migration Jobs:

``` bash
kubectl get jobs -n pizzabox-app-ns
kubectl describe jobs -n pizzabox-app-ns
kubectl logs job/<migration-job-name> -n pizzabox-app-ns
```

## Connectivity and health checks

``` bash
kubectl get svc -n pizzabox-app-ns
kubectl port-forward svc/pizzabox-api 8000:8000 -n pizzabox-app-ns
```

Local health checks:

``` bash
curl -i http://localhost:8000/health/live
curl -i http://localhost:8000/health/ready
```

Deployed API checks:

``` bash
curl -I https://api.pizzabox.fullstackprojects.dev/docs
curl -s https://api.pizzabox.fullstackprojects.dev/openapi.json | head
dig +short api.pizzabox.fullstackprojects.dev
curl -Iv https://api.pizzabox.fullstackprojects.dev/docs
```

## Troubleshooting

**Pods pending, crashing, or restarting**

``` bash
kubectl get pods -n pizzabox-app-ns -o wide
kubectl describe pod <pod-name> -n pizzabox-app-ns
kubectl get events -n pizzabox-app-ns --sort-by=.metadata.creationTimestamp
kubectl top nodes
kubectl top pods -n pizzabox-app-ns
```

**Ingress, services**

``` bash
kubectl get ingress -A
kubectl describe ingress <ingress-name> -n pizzabox-app-ns
kubectl get svc -n pizzabox-app-ns
```

**HPA and cluster autoscaling**

``` bash
kubectl get hpa -n pizzabox-app-ns
kubectl describe hpa <hpa-name> -n pizzabox-app-ns
kubectl get pods -n kube-system
kubectl logs deployment/cluster-autoscaler -n kube-system
```

**External Secrets Operator**

``` bash
kubectl get externalsecrets -A
kubectl describe externalsecret <external-secret-name> -n pizzabox-app-ns
kubectl get clustersecretstores
kubectl describe clustersecretstore <store-name>
kubectl get deployments,pods -A
```

**Argo CD app health**

``` bash
kubectl get applications -n argocd
kubectl describe application <application-name> -n argocd
argocd app diff <application-name>
argocd app get <application-name>
```

## Useful discovery commands

``` bash
kubectl get all -A
kubectl api-resources
kubectl explain deployment.spec
helm list -A
aws eks describe-cluster --region ap-south-1 --name pizzabox-eks
aws sts get-caller-identity
```
