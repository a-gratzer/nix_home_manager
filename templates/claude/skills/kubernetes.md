---
description: Kubernetes workflows — resource authoring, Helm chart development, debugging, scaling, and cluster operations.
---

# Kubernetes Skills

## Skill: Create a Deployment Manifest

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  namespace: default
  labels:
    app.kubernetes.io/name: myapp
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: myapp
  template:
    metadata:
      labels:
        app.kubernetes.io/name: myapp
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 1000
      containers:
        - name: myapp
          image: registry.example.com/myapp:1.2.3
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8080
              protocol: TCP
          resources:
            requests:
              memory: "256Mi"
              cpu: "250m"
            limits:
              memory: "512Mi"
              cpu: "500m"
          livenessProbe:
            httpGet:
              path: /healthz
              port: 8080
            initialDelaySeconds: 15
            periodSeconds: 20
          readinessProbe:
            httpGet:
              path: /ready
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 10
          env:
            - name: APP_ENV
              value: "production"
          envFrom:
            - secretRef:
                name: myapp-secrets
          volumeMounts:
            - name: config
              mountPath: /app/config
              readOnly: true
      volumes:
        - name: config
          configMap:
            name: myapp-config
```

## Skill: Debug a Failing Pod

1. **Check pod status**:
```bash
kubectl get pods -n <ns> | grep <pod>
kubectl describe pod <pod> -n <ns>
```

2. **Check events** — look for image pull errors, OOMKilled, CrashLoopBackOff:
```bash
kubectl get events -n <ns> --sort-by='.lastTimestamp' | grep <pod>
```

3. **Check logs**:
```bash
kubectl logs <pod> -n <ns> --tail=100
kubectl logs <pod> -n <ns> --previous  # Previous crashed container
```

4. **Check resources**:
```bash
kubectl top pod <pod> -n <ns>
kubectl describe pod <pod> -n <ns> | grep -A5 "State\|Last State"
```

5. **Exec into pod for debugging**:
```bash
kubectl exec -it <pod> -n <ns> -- /bin/sh
# Inside: check processes, files, network
ps aux; df -h; netstat -tlnp; curl localhost:8080/health
```

6. **Debug with ephemeral container** (for distroless images):
```bash
kubectl debug -it <pod> -n <ns> --image=nicolaka/netshoot --target=<container>
```

7. **Network debugging**:
```bash
kubectl run netshoot --rm -it --image=nicolaka/netshoot -- /bin/bash
# From inside: nslookup, curl, tcpdump, etc.
```

## Skill: Scale a Deployment

```bash
# Manual scaling
kubectl scale deployment <name> -n <ns> --replicas=5

# Edit and apply
kubectl edit deployment <name> -n <ns>  # Change replicas: 5

# Check rollout status
kubectl rollout status deployment/<name> -n <ns>

# Rollback if needed
kubectl rollout undo deployment/<name> -n <ns>
kubectl rollout history deployment/<name> -n <ns>
```

## Skill: Create a Helm Chart

```bash
helm create mychart
```

Edit `values.yaml`:
```yaml
replicaCount: 3

image:
  repository: registry.example.com/myapp
  tag: "1.2.3"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 8080

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80

ingress:
  enabled: true
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix
```

Lint and test:
```bash
helm lint ./mychart
helm template myapp ./mychart --debug
helm install myapp ./mychart --dry-run
```

## Skill: Troubleshoot Network Issues

```bash
# 1. Check service endpoints
kubectl get endpoints <svc> -n <ns>
kubectl describe svc <svc> -n <ns>

# 2. Check NetworkPolicy (deny-all is common culprit)
kubectl get networkpolicy -n <ns>
kubectl describe networkpolicy <policy> -n <ns>

# 3. DNS check from debug pod
kubectl run dnsdebug --rm -it --image=busybox:1.28 -- nslookup <svc>.<ns>.svc.cluster.local

# 4. Port-forward for direct access test
kubectl port-forward svc/<svc> 8080:8080 -n <ns>
curl localhost:8080/health

# 5. Check CNI status (Cilium example)
kubectl -n kube-system exec ds/cilium -- cilium status
kubectl -n kube-system exec ds/cilium -- cilium endpoint list
```

## Skill: Manage Secrets with External Secrets Operator

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: myapp-secrets
  namespace: default
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: myapp-secrets
  data:
    - secretKey: DB_PASSWORD
      remoteRef:
        key: secret/myapp
        property: db_password
    - secretKey: API_KEY
      remoteRef:
        key: secret/myapp
        property: api_key
```

## Skill: Backup & Restore (Velero)

```bash
# Create backup
velero backup create myapp-backup --include-namespaces default

# List backups
velero backup get

# Describe backup
velero backup describe myapp-backup

# Schedule regular backups
velero schedule create daily-backup --schedule="0 2 * * *" --include-namespaces default

# Restore
velero restore create --from-backup myapp-backup
```
