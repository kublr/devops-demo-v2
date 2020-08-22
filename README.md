# DevOps and CI/CD on Kubernetes demo

## Pre-requisites

* Kublr 1.19.0+
* Kubernetes 1.18+
* AWS account

## Deploy cluster

Use Kublr to deploy cluster using one of the specs in `deovops-env` directory:
`kublr-cluster-us-east-1.yaml` or `kublr-cluster-us-east-2.yaml`

1. Ceate a space `devops` in Kublr UI (you can use a different space, but then you will need )
2. Create an AWS secret named `ws` in the space
3. Start creating a new cluster, click "Customize specification" and replace yaml in the dialog that
   opens with one of the providedspecifications.

What to change to adjust to your enviroment:

1. If you want to use a different space rather than `devops`, change the space in https://github.com/kublr/devops-demo/blob/master/devops-env/kublr-cluster-us-east-1.yaml#L4

2. If you want to use a different region and availability zones:
   1. Change the region in https://github.com/kublr/devops-demo/blob/master/devops-env/kublr-cluster-us-east-1.yaml#L11
   2. Change AZs in https://github.com/kublr/devops-demo/blob/master/devops-env/kublr-cluster-us-east-1.yaml#L15-L17
   3. Change EFS Mount Targets in https://github.com/kublr/devops-demo/blob/master/devops-env/kublr-cluster-us-east-1.yaml#L22-L39
      Here most importantly the designations of target subnets must be changed according to the AZs used.
      Kublr uses AZ numbering convention where AZs ending with `a` (e.g. `us-east-1a`) are numbered `0`, `b` - `1`, `c` - `2` etc.
      Therefore if you want to use, for example, AZs `us-west-2c`, `us-west-2d`, and `us-west-2f`, then the Mount Target
      names should be changed to `DevOpsDemoEFSMT2`, `DevOpsDemoEFSMT3` and `DevOpsDemoEFSMT5` in the spec
      lines 22, 28 and 34 correspondingly, and the subnet names should be `SubnetNodePublic2`, `SubnetNodePublic3`, and `SubnetNodePublic5` in the spec lines 27, 33, 39 correspondingly.

3. You will need to use your own Route 53 domain and Letsencrypt identification for the demo to work correctly;
   Change the domain and email in the spec lines 155, 181, 182, 216, 218, and 220

Other possible variation points that you may or may not want to modify or experiment with:
- AMI used
- instance types
- the size of the cluster
- jenkins and nexus configuration

## Setting up DNS

As soon as the cluster is started, open the Kubernetes dashboard and check the name of the load balancer
allocated for the cluster's ingress controller, namely the service `kublr-ingress-nginx-ingress-controller` in the
`kube-system` or use the following CLI console command for that:

```
kubectl get svc -n kube-system kublr-ingress-nginx-ingress-controller
```

Create an Route 53 alias wildcard record for `*.devops-demo-us-east-1.workshop.kublr.com` (or the domain of your
choice that you configured in the cluster spec) and point it at the corresponding ELB created for the cluster ingress.

Almost immediately the Jenkins and Nexus URLs will become available, although it may take several minutes until
valid Letsencrypt certificates are issued; initially the browser may show that the connection is insecure.

Make sure that at least Nexus certificates are valid before procedeing to the next steps.

## Setting up Nexus docker registry

1. Open Nexus UI at https://nexus.devops-demo-us-east-1.workshop.kublr.com
2. Login with the default nexus admin account `admin` / `admin123`
3. In the setup wizard that opens on the first login enable anonymous repository browsing
4. Go to the Settings screen
   1. Add DockerBearerToken realm in the "Configure Security" > "Realms"
   2. Create a new hosted docker registry, with the following settings:
      - Name: docker-hosted
      - HTTP port: 5003
      - Allow anonymous pull: yes

The registry will be available at the address `cr.devops-demo-us-east-1.workshop.kublr.com`

You can test that it works by running the following commands:

```bash
docker pull alpine
docker tag alpine cr.devops-demo-us-east-2.workshop.kublr.com/alpine/alpine
docker login      cr.devops-demo-us-east-2.workshop.kublr.com -u admin -p admin123
docker push       cr.devops-demo-us-east-2.workshop.kublr.com/alpine/alpine
docker logout     cr.devops-demo-us-east-2.workshop.kublr.com
docker rmi        cr.devops-demo-us-east-2.workshop.kublr.com/alpine/alpine
docker pull       cr.devops-demo-us-east-2.workshop.kublr.com/alpine/alpine
```

## Setting up Jenkins pipeline

1. Get your Jenkins `admin` user password by running:
   ```bash
   printf $(kubectl get secret --namespace devops jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
   ```
2. Open UI at https://jenkins.devops-demo.workshop.kublr.com
3. Login with the password from step 1 and the username: `admin`
4. Register pipeline parameters: in 'Manage Jenkins' > 'Manage Credentials' create new records in '(Global)' domain:
   - `docker-registry-cred` of type "username/password" with values `admin` / `admin123`
   - `docker-registry-address` of type "secret text" with value `cr.devops-demo-us-east-2.workshop.kublr.com`
   - `cluster-domain` of type "secret text" with value `devops-demo-us-east-2.workshop.kublr.com`
5. Use kublr UI or Kubernetes CLI to assign `cluster-admin` Cluster Role to Jenkins service
5. Create a new multi-branch pipeline project
   - Add a new 'Branch Source' of type 'Git'; use https git link (to avoid the need to provide and register
     SSH keys as the project is public anyway) `https://github.com/kublr/devops-demo.git` for the project source
   - add 'Checkout to matching local branch' behaviour for the Git Source

As soon as you save this project, the build process for `master` and `feature/blue` branch (or any other branches
available in the repository at the time) should start, run and deploy the application to the `master` and
`featureblue` namespaces (and potentially other namespaces corresponding to the branches) in the Kubernetes cluster.

The applications will be available on individual URLs such as https://simple-api.master.devops-demo-us-east-2.workshop.kublr.com
(for `master` branch) or https://simple-api.featureblue.devops-demo-us-east-2.workshop.kublr.com (for `feature/blue` branch).
