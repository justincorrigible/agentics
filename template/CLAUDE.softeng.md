# softeng team conventions

This file is an addendum to `CLAUDE.md`, applied when project memory confirms the user is part of the softeng team. Do not include credentials, private cluster endpoints, or secrets here: ever.

## How this file is used

The initialization block in `CLAUDE.md` records team membership in project memory on the first session. Subsequent sessions read the flag and load this file at session start.

---

## Spelling convention

Use Canadian English spelling across all work: in comments, documentation, string literals, and (when renaming) identifiers.

Key rules:
- `-our` suffixes: "colour", "behaviour", "neighbour", "favour"
- `-re` suffixes: "centre", "fibre", "theatre"
- `-ue` suffixes: "catalogue", "dialogue", "analogue"
- `-ize` (not `-ise`): "organize", "prioritize", "recognize": Canadian uses -ize
- `-yze`: "analyze", "paralyze" (despite the -ise/-ize split above, Canadian does not diverge here; both use -yze)

For new text: apply from the start. For existing identifiers: flag the inconsistency and note it as a rename task; renames deserve a dedicated commit.

---

## Tooling preferences

<!-- Keep this free of private URLs, credentials, or access tokens -->

### Kubernetes infrastructure: operator-first and VSO-everywhere

These conventions apply to all softeng Kubernetes-based infrastructure work.

**Operator-first for stateful services:** prefer Kubernetes operators over standalone Helm charts for stateful services wherever an operator exists. Examples: CNPG for PostgreSQL, MongoDB Community Operator for MongoDB, opensearch-k8s-operator for OpenSearch, Strimzi for Kafka. Deviations require explicit justification.

**Exception: Keycloak.** Use the codecentric/keycloakx Helm chart, not the Keycloak Operator. The Keycloak Operator is namespace-scoped by default and does not fit the shared cluster-wide installation model used for all other operators. keycloakx is the established chart across all softeng environments.

**Prefer project-owned and community operators** over vendor-bundled chart collections. When an existing service uses a vendor-bundled chart, flag migration to the appropriate operator as tech-debt.

- Dev environments must use the same operator-based pattern as production: consistent tooling is the point
- If an operator is not yet installed in the target cluster, open a PINNED item for the platform team rather than falling back to a standalone chart
- Log PINNED items in `.dev/roadmap.md` using this format:

```
**PINNED: [needs DevOps | in progress | done]** (installing "operator-name"; [what is ready / what is waiting])
```

**VSO for all secret injection:** use Vault Secrets Operator (VSO) for all secret injection in Kubernetes workloads. Two patterns are incorrect and must not be introduced:

1. Services reaching out to Vault at runtime directly (without VSO)
2. Terraform fetching secrets via `data.vault_kv_secret` and passing them as Helm values at apply time

VSO injects secrets at runtime as native Kubernetes secrets, decoupling secret rotation from Terraform apply cycles.

- Every stateful service that needs secrets gets a `-vso` companion Helm release deployed before the service itself (`depends_on`)
- When touching stateless services that use the incorrect patterns, log a VSO migration item as tech-debt if not fixing it in scope

### Terraform root structure: stateless and stateful only

Each environment has exactly two Terraform roots: `stateless/` and `stateful/`. Do not introduce a third root unless there is a strong, explicit justification.

- **Stateful:** databases, message brokers, their VSO companions: anything with persistent storage
- **Stateless:** everything else, including Helm releases, TF provider-based service configuration (e.g. `mrparkers/keycloak` realm config), and management-plane resources that call external APIs

When a new tool requires a Terraform provider (e.g. the Keycloak admin provider), add it as a second provider in the stateless root alongside `hashicorp/helm`. Use `depends_on` to sequence it after the service it configures.

### CI and deployment

- CI: Jenkins; Terraform deploys run via `tfDeploy.groovy`; all cluster operations go through Jenkins (never `tf apply` locally)
- Container registry: `ghcr.io` (GitHub Container Registry)
- Shared Helm charts: `oci://ghcr.io/oicr-softeng/helm-charts` for softeng-maintained charts (stateless-svc, etc.)

### Stateful service operator choices

| Service | Operator | Chart / CR |
|---|---|---|
| PostgreSQL | CloudNative-PG | `cluster` chart from `cloudnative-pg.github.io/charts` |
| MongoDB | MongoDB Community Operator | `MongoDBCommunity` CR |
| OpenSearch | opensearch-k8s-operator | `opensearch-cluster` chart from the operator Helm repo |
| Kafka | Strimzi | project-specific resources |
| Auth | Keycloak - codecentric/keycloakx chart | Ego is discontinued; any Ego references are tech-debt |

---

## Deploying stateful services

When adding a stateful service to an environment for the first time, three things must be in order before the Jenkins deploy job will succeed.

### 1. Jenkins CRD access

Jenkins holds an `admin` RoleBinding per application namespace. Kubernetes `admin` covers standard API groups but does NOT automatically cover custom CRDs.

Some operators use RBAC aggregation: they label their ClusterRoles with `rbac.authorization.k8s.io/aggregate-to-admin: "true"`, which merges their rules into `admin` automatically. **CNPG does this** - no extra config is needed for CNPG clusters.

Operators that do not use aggregation require a manual entry in the Jenkins ClusterRole. The file to edit is:

`config-jenkins-instances/jenkins-instances/<cluster>_jenkins1/manifests.yaml`

Add a rule to the `ClusterRole jenkins-agent-cluster-resources`:

```yaml
- apiGroups:
    - <operator-api-group>   # e.g. mongodbcommunity.mongodb.com
  resources:
    - <crd-resource-name>    # e.g. mongodbcommunity
  verbs:
    - create
    - delete
    - get
    - list
    - patch
    - update
    - watch
```

Open a PR to `config-jenkins-instances` and get it merged before attempting the Jenkins deploy job. You will get a `forbidden` error on the CRD get if this is missing.

**How to check if an operator uses aggregation:** `kubectl get clusterrole -l rbac.authorization.k8s.io/aggregate-to-admin=true` - if the operator's ClusterRole appears here, no manual entry is needed.

### 2. Credential bootstrapping: direction depends on the operator

The direction of the credential flow differs by operator type. Get this wrong and VSO or the operator will fail to start.

**CNPG (PostgreSQL): operator generates - you copy to Vault afterward**

1. Deploy the CNPG cluster via Jenkins. CNPG auto-generates credentials and writes K8s secrets named `<cluster-name>-app` and `<cluster-name>-superuser`.
2. Read the generated password: `kubectl get secret <cluster-name>-app -n <namespace> -o jsonpath='{.data.password}' | base64 -d`
3. Write to Vault: `vault kv put kv2/<env>/<path> username=<user> password=<pass>`
4. VSO then keeps the K8s secret synced from Vault on rotation.

**MongoDB Community Operator: you seed Vault first - operator reads from VSO**

The operator requires a `passwordSecretRef` pointing to an existing K8s secret. It does not generate credentials.

1. Generate a password: `openssl rand -base64 32`
2. Write to Vault first: `vault kv put kv2/<env>/<path> mongodb_root_password=<pass>`
3. Deploy the VSO companion via Jenkins - VSO creates the K8s secret from Vault.
4. Deploy the MongoDB CR via Jenkins - the operator reads from that K8s secret.

The VSO-managed K8s secret and the operator's `passwordSecretRef` point to the same secret name.

**OpenSearch (opensearch-k8s-operator): operator generates**

The operator creates an `<cluster-name>-admin-password` secret automatically. Same post-deploy copy-to-Vault pattern as CNPG.

### 3. NetworkPolicy: always check client ingress

Operators (Strimzi, CNPG, opensearch-k8s-operator, MongoDB Community) generate NetworkPolicies for their own internal component traffic: broker-to-broker, operator-to-pod, controller-to-api. They do not generate NPs allowing application clients to reach the service port.

**Always verify:** when deploying or debugging a stateful service, confirm that a NetworkPolicy exists allowing ingress from client pods to the service's main listener port. This is separate from any egress the operator pods may need (e.g. broker → K8s API for secret reads).

**How to apply:** use the kustomize postrender pattern (supplemental manifests in `kustomize/manifests/np.yaml`) to add client ingress NPs without modifying the operator chart. A NP ingress rule with no `from:` selector allows all pods in the namespace - appropriate for internal cluster services. Tighter scoping by `app.kubernetes.io/name` is a follow-up once the service is confirmed working.

Common ports to check: Kafka plain 9092 / TLS 9093, PostgreSQL 5432, OpenSearch 9200 / 9300, MongoDB 27017.

### 4. Deployment order within a stateful root

Always deploy VSO companion before the stateful service that depends on it. If using TF `depends_on`, a single Jenkins apply handles ordering. If targeting resources individually, apply the `-vso` release first.

For services whose operator requires a pre-seeded credential (MongoDB), ensure the Vault write and VSO deploy complete before attempting the operator CR deploy.

---

## Team workflow practices

<!-- TODO: fill in team workflow conventions (e.g. PR review expectations, branching strategy, release process) -->

---

## Naming conventions

- CNPG clusters: `<service>-psql-db` (e.g. `keycloak-psql-db`)
- MongoDB clusters: `<service>-mongo-db` (e.g. `lectern-mongo-db`)
- VSO companions: `<service>-<db>-vso` (e.g. `keycloak-psql-db-vso`)
- Helm release names match the `helm/` subdirectory name within each environment layer
- Terraform resource names match Helm release names (hyphens preserved: `resource "helm_release" "keycloak-psql-db"`)

---

## Known projects and cross-project relationships

<!-- TODO: fill in project names and relationships relevant to onboarding: no private URLs or access tokens -->
