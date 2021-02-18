# DevOps and CI/CD with Jenkins, Nexus, Kubernetes and Kublr demo

## 1. Pre-requisites

* Kublr 1.20.1+
* Kubernetes 1.19+
* AWS and/or Azure account

You can follow this demo implementing steps manually based on the instructions below, or just by running
the scripts in the `hacks/` directory. The script may also provide useful insight and code templates for
your own automation implementations.

The scripts are written in bash and assume that you have `kubectl`, `jq`, and `curl` tools available on the
command path.

They all also assume that they will be run via bash `source` command, e.g. `source devops-demo/hacks/00-prep-env.sh`
or `. devops-demo/hacks/00-prep-env.sh`.

If you are planning to use the scripts, run `. devops-demo/hacks/00-prep-env.sh` first.
Check the script output for the instructions on adjusting it to your configuration, and re-run with correct
parameters and environment variables set.

## 2. Deploy cluster

This project includes 3 cluster specifications that can be used almost without modifications (see below
for the required changes in the specs) to deploy the environment in AWS `us-east-1` region, AWS `us-east-2`
region, and Azure `eastus` region.

Use Kublr to deploy cluster using one of the specs in `deovops-env` directory -
`devops-demo-us-east-1.yaml`, `devops-demo-us-east-2.yaml`, or `devops-demo-eastus.yaml`.

The first two specs are for clusters in AWS regions `us-east-1` and `us-east-2` correspondingly,
and the third one is for a cluster in Azure `eastus` region:

This text refers to 

1. Ceate a space `devops` in Kublr UI (you can use a different space, but then you will need to update it in the cluster spec
   you are using).

1. For AWS cluster: create an AWS secret named `aws` in the space.

1. For Azure cluster: create an Azure secret named `azure` and a public SSH key secret named `ssh-pub` in the space

1. Start creating a new cluster in Kublr UI, click "Customize specification" and replace yaml in the dialog that
   opens with one of the providedspecifications.

   You can use the provided scripts instead of copy-pasting the cluster spec in UI:

   -  if creating a cluster name different from the three clusters provided in this project, put the cluster specification
      in a file `devops-demo/devops-env/${KCP_CLUSTER}.yaml`

   -  run `. devops-demo/hacks/11-create-kublr-cluster.sh`

   -  after the cluster is created, download and configure the cluster kubeconfig file by running
      `. devops-demo/hacks/15-load-kubeconfig-from-kublr.sh`

### 2.1. Required changes in the cluster specs

You will need to use your own Route 53 domain and Letsencrypt identification for the demo to work correctly;
they **MUST** be changed in the cluster spec to adjust to your environment.

1. Change the email Letsencrypt identification in the spec line
   [L168](https://github.com/kublr/devops-demo-v2/blob/main/devops-env/devops-demo-us-east-1.yaml#L168)

1. Change the cluster domain in the spec lines 
   [L208](https://github.com/kublr/devops-demo-v2/blob/main/devops-env/devops-demo-us-east-1.yaml#L208),
   [L210](https://github.com/kublr/devops-demo-v2/blob/main/devops-env/devops-demo-us-east-1.yaml#L210),
   [L212](https://github.com/kublr/devops-demo-v2/blob/main/devops-env/devops-demo-us-east-1.yaml#L212),
   [L225](https://github.com/kublr/devops-demo-v2/blob/main/devops-env/devops-demo-us-east-1.yaml#L225),
   [L226](https://github.com/kublr/devops-demo-v2/blob/main/devops-env/devops-demo-us-east-1.yaml#L226),
   [L232](https://github.com/kublr/devops-demo-v2/blob/main/devops-env/devops-demo-us-east-1.yaml#L232),
   [L238](https://github.com/kublr/devops-demo-v2/blob/main/devops-env/devops-demo-us-east-1.yaml#L238).

### 2.1. Optional changes

Some of the other parameters that **MAY** be changed:

1. If you want to use a different space in Kublr rather than `devops`, change the space in
   [L4](https://github.com/kublr/devops-demo-v2/blob/main/devops-env/devops-demo-us-east-1.yaml#L4)

1. If you want to use a different AWS region and availability zones:

   1. Change the region in
      [L10](https://github.com/kublr/devops-demo-v2/blob/main/devops-env/devops-demo-us-east-1.yaml#L10)

   1. Change AZs in
      [L14-L16](https://github.com/kublr/devops-demo-v2/blob/main/devops-env/devops-demo-us-east-1.yaml#L14-L16),
      [L62-L64](https://github.com/kublr/devops-demo-v2/blob/main/devops-env/devops-demo-us-east-1.yaml#L62-L64),
      [L97-L99](https://github.com/kublr/devops-demo-v2/blob/main/devops-env/devops-demo-us-east-1.yaml#L62-L64),

   1. Change EFS Mount Targets in
      [L21-L38](https://github.com/kublr/devops-demo-v2/blob/main/devops-env/devops-demo-us-east-1.yaml#L21-L38)

      Here most importantly the designations of target subnets must be changed according to the AZs used.

      Kublr uses AZ numbering convention where AZs ending with `a` (e.g. `us-east-1a`) are numbered `0`, `b` - `1`, `c` - `2` etc.
      Therefore if you want to use, for example, AZs `us-west-2c`, `us-west-2d`, and `us-west-2f`, then the Mount Target
      names should be changed to `DevOpsDemoEFSMT2`, `DevOpsDemoEFSMT3` and `DevOpsDemoEFSMT5` in the spec lines
      [L21](https://github.com/kublr/devops-demo-v2/blob/main/devops-env/devops-demo-us-east-1.yaml#L21),
      [L27](https://github.com/kublr/devops-demo-v2/blob/main/devops-env/devops-demo-us-east-1.yaml#L27),
      [L33](https://github.com/kublr/devops-demo-v2/blob/main/devops-env/devops-demo-us-east-1.yaml#L33)
      correspondingly, and the subnet names should be `SubnetNodePublic2`, `SubnetNodePublic3`, and `SubnetNodePublic5`
      in the spec lines
      [L26](https://github.com/kublr/devops-demo-v2/blob/main/devops-env/devops-demo-us-east-1.yaml#L26),
      [L32](https://github.com/kublr/devops-demo-v2/blob/main/devops-env/devops-demo-us-east-1.yaml#L32),
      [L38](https://github.com/kublr/devops-demo-v2/blob/main/devops-env/devops-demo-us-east-1.yaml#L38)
      correspondingly.

Other possible variation points that you may or may not want to modify or experiment with:
- AMIs or Azure images used
- instance types
- the size of the cluster
- jenkins and nexus configuration

## 3. Setting up DNS

**NB!** Before configuring DNS restore saved TLS/HTTPS certificates if necessary; see the section
"[7. Backup and restore Letsencrypt certificates](#7-backup-and-restore-letsencrypt-certificates)" for more details.

As soon as the cluster is started, open the Kubernetes dashboard and check the name or address of the load balancer
allocated for the cluster's ingress controller, namely the service `kublr-ingress-nginx-ingress-controller` in the
`kube-system` or use the following CLI console command for that:

```
kubectl get svc -n kube-system kublr-ingress-nginx-ingress-controller
```

Create an Route 53 (or another DNS service of your choice) alias wildcard record for
`*.devops-demo-us-east-1.workshop.kublr.com` (or the domain of your choice that you configured in the cluster spec)
and point it at the corresponding ELB created for the cluster ingress.

Almost immediately the Jenkins and Nexus URLs will become available, although it may take several minutes until
valid Letsencrypt certificates are issued; initially the browser may show that the connection is insecure.

Make sure that at least Nexus certificates are valid before procedeing to the next steps.

## 4. Setting up Nexus docker registry

After the cluster is started, Nexus and Jenkins helm packages will be deployed as they are included
in the cluster specification.

At the same time both Nexus and Jenkins will be "bare" - with no repositories or build jobs. They need
to be configuered to build the example project from this repository.

### 4.1. Configuring Nexus manually via UI

1. Open Nexus UI at https://nexus.devops-demo-us-east-1.workshop.kublr.com
1. Login with the default nexus admin account `admin` / `admin123`
1. In the setup wizard that opens on the first login enable anonymous repository browsing
1. Go to the Settings screen
   1. Add DockerBearerToken realm in the "Configure Security" > "Realms"
   1. Create a new hosted docker registry, with the following settings:
      - Name: docker-hosted
      - HTTP port: 5003
      - Allow anonymous pull: yes

### 4.2. ... or Scripted via CLI

You can either run pre-packaged scripts or follow the insctructions below step by step.

Prepackaged scripts:

```bash
. devops-demo/hacks/21-setup-nexus.sh
```

Step by step instructions:

1. Prepare environment for scripting:

   ```bash
   DOMAIN=devops-demo-us-east-1.workshop.kublr.com

   NURL=https://nexus.$DOMAIN

   NPASWD=admin123
   ```

1. Enable anonymous repository browsing

   ```bash
   curl -X PUT -H 'content-type:application/json' -u "admin:$NPASWD" -w '\n%{http_code}\n' -d '@-' \
      $NURL/service/rest/v1/security/anonymous <<EOF
   {"enabled":true,"userId":"anonymous","realmName":"NexusAuthorizingRealm"}
   EOF
   ```

1. Add DockerBearerToken realm in the "Configure Security" > "Realms"

   ```bash
   curl -X GET -H 'content-type:application/json' -s -u "admin:$NPASWD" \
      $NURL/service/rest/v1/security/realms/active | \
   \
   jq 'map(select(. != "DockerToken")) + ["DockerToken"]' | \
   \
   curl -X PUT -H 'content-type:application/json' -u "admin:$NPASWD" -w '\n%{http_code}\n' -d '@-' \
      $NURL/service/rest/v1/security/realms/active
   ```

1. Create a new hosted docker registry:

   ```bash
   curl -X POST -H 'content-type:application/json' -u "admin:$NPASWD" -w '\n%{http_code}\n' -d '@-' \
      $NURL/service/rest/v1/repositories/docker/hosted <<EOF
   {
     "name" : "docker-hosted",
     "online" : true,
     "storage" : {
       "blobStoreName" : "default",
       "strictContentTypeValidation" : true,
       "writePolicy" : "ALLOW"
     },
     "docker" : {
       "v1Enabled" : false,
       "forceBasicAuth" : false,
       "httpPort" : 5003
     }
   }
   EOF
   ```

### 4.3. Check the docker registry

The registry will be available at the address `registry.devops-demo-us-east-1.workshop.kublr.com`

You can test that it works by running the following commands:

```bash
DOMAIN=devops-demo-us-east-1.workshop.kublr.com
NPASWD=admin123

docker pull alpine
docker tag alpine registry.$DOMAIN/alpine/alpine
docker login      registry.$DOMAIN -u admin -p "$NPASWD"
docker push       registry.$DOMAIN/alpine/alpine
docker logout     registry.$DOMAIN
docker rmi        registry.$DOMAIN/alpine/alpine
docker pull       registry.$DOMAIN/alpine/alpine
```

... or running a prepackaged script:

```bash
. devops-demo/hacks/25-test-docker-registry.sh
```

## 5. Setting up Jenkins

### 5.1. Get Jenkins password

You can either run pre-packaged scripts or follow the insctructions below step by step.

Prepackaged scripts:

```bash
# configure Jenkins scripted token and load Jenkins password
. devops-demo/hacks/31-setup-jenkins-password.sh

# Print Jenkins pasword
cat jenkins-pwd-${DOMAIN}.sh
```

Step by step instructions:

1. Prepare environment for follow-up scripts:

   ```bash
   DOMAIN=devops-demo-us-east-1.workshop.kublr.com

   JURL=https://jenkins.$DOMAIN
   ```

1. Get your Jenkins `admin` user password by running:
   ```bash
   JPWD="$(kubectl get secret --namespace devops jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode)"

   echo $JPWD
   ```

### 5.2. Configure Jenkins CI Job manually via CLI and UI

1. Use Kublr UI or Kubernetes CLI to assign `cluster-admin` Cluster Role to Jenkins service account and the default service
   account in the `devops` namespace

   ```
   kubectl create clusterrolebinding cluster-admin:devops:jenkins --clusterrole=cluster-admin --serviceaccount=devops:jenkins
   kubectl create clusterrolebinding cluster-admin:devops:default --clusterrole=cluster-admin --serviceaccount=devops:default
   ```

1. Open UI at https://jenkins.devops-demo-us-east-1.workshop.kublr.com

1. Login with the password from step 1 and the username: `admin`

1. Register pipeline parameters: in 'Manage Jenkins' > 'Manage Credentials' create new records in '(Global)' domain:
   - `docker-registry-cred` of type "username/password" with values `admin` / `admin123`
   - `docker-registry-address` of type "secret text" with value `registry.devops-demo-us-east-1.workshop.kublr.com`
   - `cluster-domain` of type "secret text" with value `devops-demo-us-east-1.workshop.kublr.com`

1. Create a new multi-branch pipeline project

   - Add a new 'Branch Source' of type 'Git'

     Use https git link (to avoid the need to provide and register SSH keys as the project is public anyway)
     `https://github.com/kublr/devops-demo-v2.git` for the project source

   - Add 'Checkout to matching local branch' behaviour for the Git Source

   - Set 'Scan Multibranch Pipeline Triggers' to periodic checking

### 5.3. ... or configure Jenkins CI Job using scripts via Jenkins API

You can either run pre-packaged scripts or follow the insctructions below step by step.

Prepackaged scripts:

```bash
. devops-demo/hacks/35-setup-jenkins.sh
```

Step by step instructions:

1. Use Kublr UI or Kubernetes CLI to assign `cluster-admin` Cluster Role to Jenkins service account and the default service
   account in the `devops` namespace

   ```
   kubectl create clusterrolebinding cluster-admin:devops:jenkins --clusterrole=cluster-admin --serviceaccount=devops:jenkins
   kubectl create clusterrolebinding cluster-admin:devops:default --clusterrole=cluster-admin --serviceaccount=devops:default
   ```

1. Generate Jenkins token for scripting:

   ```bash
   JCRUMB=$(curl --silent --show-error --fail -X GET  -c cookies.txt -u "admin:$JPWD" \
       $JURL/crumbIssuer/api/json | jq -r .crumb)

   JTOKEN=$(curl --silent --show-error --fail -X POST -b cookies.txt -u "admin:$JPWD" \
       -H "Jenkins-Crumb: $JCRUMB" \
       $JURL/me/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken?newTokenName=\devops-demo | jq -r .data.tokenValue)
   ```

1. Register pipeline parameters

   ```bash
   # delete creds

   curl -X DELETE -H 'content-type:application/xml' -u "admin:$JTOKEN" -w '\n%{http_code}\n' \
       $JURL/credentials/store/system/domain/_/credentials/docker-registry-cred/config.xml

   curl -X DELETE -H 'content-type:application/xml' -u "admin:$JTOKEN" -w '\n%{http_code}\n' \
       $JURL/credentials/store/system/domain/_/credentials/cluster-domain/config.xml

   curl -X DELETE -H 'content-type:application/xml' -u "admin:$JTOKEN" -w '\n%{http_code}\n' \
       $JURL/credentials/store/system/domain/_/credentials/docker-registry-address/config.xml

   # create creds

   curl -X POST -H 'content-type:application/xml' -u "admin:$JTOKEN" -w '\n%{http_code}\n' -d '@-' \
       $JURL/credentials/store/system/domain/_/createCredentials <<EOF
   <com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
     <scope>GLOBAL</scope>
     <id>docker-registry-cred</id>
     <username>admin</username>
     <password>$NPASWD</password>
   </com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
   EOF

   curl -X POST -H 'content-type:application/xml' -u "admin:$JTOKEN" -w '\n%{http_code}\n' -d '@-' \
       $JURL/credentials/store/system/domain/_/createCredentials <<EOF
   <org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl>
     <scope>GLOBAL</scope>
     <id>cluster-domain</id>
     <description>$DOMAIN</description>
     <secret>$DOMAIN</secret>
   </org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl>
   EOF

   curl -X POST -H 'content-type:application/xml' -u "admin:$JTOKEN" -w '\n%{http_code}\n' -d '@-' \
       $JURL/credentials/store/system/domain/_/createCredentials <<EOF
   <org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl>
     <scope>GLOBAL</scope>
     <id>docker-registry-address</id>
     <description>registry.$DOMAIN</description>
     <secret>registry.$DOMAIN</secret>
   </org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl>
   EOF
   ```

1. Create a new multi-branch pipeline project

   ```bash
   curl -X POST -H 'content-type:application/xml' -u "admin:$JTOKEN" -w '\n%{http_code}\n' -d '@-' \
       $JURL/createItem?name=devops-demo <<EOF
   <?xml version='1.1' encoding='UTF-8'?>
   <org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject>
     <actions/>
     <description></description>
     <properties>
       <org.csanchez.jenkins.plugins.kubernetes.KubernetesFolderProperty>
         <permittedClouds/>
       </org.csanchez.jenkins.plugins.kubernetes.KubernetesFolderProperty>
     </properties>
     <folderViews class="jenkins.branch.MultiBranchProjectViewHolder">
       <owner class="org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject" reference="../.."/>
     </folderViews>
     <healthMetrics/>
     <icon class="jenkins.branch.MetadataActionFolderIcon">
       <owner class="org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject" reference="../.."/>
     </icon>
     <orphanedItemStrategy class="com.cloudbees.hudson.plugins.folder.computed.DefaultOrphanedItemStrategy">
       <pruneDeadBranches>true</pruneDeadBranches>
       <daysToKeep>-1</daysToKeep>
       <numToKeep>-1</numToKeep>
     </orphanedItemStrategy>
     <triggers>
       <com.cloudbees.hudson.plugins.folder.computed.PeriodicFolderTrigger>
         <spec>* * * * *</spec>
         <interval>60000</interval>
       </com.cloudbees.hudson.plugins.folder.computed.PeriodicFolderTrigger>
     </triggers>
     <disabled>false</disabled>
     <sources class="jenkins.branch.MultiBranchProject\$BranchSourceList">
       <data>
         <jenkins.branch.BranchSource>
           <source class="jenkins.plugins.git.GitSCMSource">
             <remote>https://github.com/kublr/devops-demo-v2.git</remote>
             <credentialsId></credentialsId>
             <traits>
               <jenkins.plugins.git.traits.BranchDiscoveryTrait/>
               <jenkins.plugins.git.traits.LocalBranchTrait>
                 <extension class="hudson.plugins.git.extensions.impl.LocalBranch">
                   <localBranch>**</localBranch>
                 </extension>
               </jenkins.plugins.git.traits.LocalBranchTrait>
             </traits>
           </source>
           <strategy class="jenkins.branch.DefaultBranchPropertyStrategy">
             <properties class="empty-list"/>
           </strategy>
         </jenkins.branch.BranchSource>
       </data>
       <owner class="org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject" reference="../.."/>
     </sources>
     <factory class="org.jenkinsci.plugins.workflow.multibranch.WorkflowBranchProjectFactory">
       <owner class="org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject" reference="../.."/>
       <scriptPath>Jenkinsfile</scriptPath>
     </factory>
   </org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject>
   EOF
   ```

## 6. Check automatically deployed applications

As soon as you save this project, the build process for `main` and `feature/blue` branch (or any other branches
available in the repository at the time) should start, run and deploy the application to the `main` and
`featureblue` namespaces (and potentially other namespaces corresponding to the branches) in the Kubernetes cluster.

The applications will be available on individual URLs such as http://simple-api.main.devops-demo-us-east-1.workshop.kublr.com
(for `main` branch) or http://simple-api.featureblue.devops-demo-us-east-1.workshop.kublr.com (for `feature/blue` branch).

## 7. Backup and restore Letsencrypt certificates

This demo relies on Letsencrypt to issue valid TLS/HTTPS certificates.

Letsencrypt may rate-limit the certificate requests for the same domain name to 5 requests per week. As a result
the demo may fail if it is re-run from scratch more than 5 times per week.

If this is the case, it is recommended to backup the certificates and keys and restore them instead of re-running
the demo.

Backup certificates:

```bash
kubectl get secrets -n devops --field-selector type=kubernetes.io/tls -o json | jq '
  del(.items[].metadata.managedFields)|
  del(.items[].metadata.resourceVersion)|
  del(.items[].metadata.selfLink)|
  del(.items[].metadata.uid)|
  del(.items[].metadata.creationTimestamp)|
  del(.items[].metadata.annotations["kubectl.kubernetes.io/last-applied-configuration"])' > "certificates-${DOMAIN}.json"
```

or run the script:

```bash
. devops-demo/hacks/99-save-tls-certs.sh
```

It is recommended to cleanup the output certificates backup file removing unnecessary fields from the exported secrets,
such as `metadata.managedFields`, `metadata.resourceVersion`, `metadata.selfLink`, `metadata.uid`, `metadata.creationTimestamp`
(it is done with `jq` processing in the script above).

Importing the backed-up certificates:

```bash
kubectl apply -f "certificates-${DOMAIN}.json"
kubectl -n devops delete --all certificaterequests,certificates,challenges,orders
```

or run the script:

```bash
. devops-demo/hacks/17-load-saved-tls-certs-to-cluster.sh
```
