podTemplate(
    name: 'simple-api-build-pod',
    label: 'simple-api-build-pod',
    containers: [
        containerTemplate(name: 'shell', image: 'ubuntu', command: 'sleep', args: 'infinity'),
        containerTemplate(name: 'helm', image: 'alpine/helm:3.3.0', ttyEnabled: true, command: 'cat'),
        containerTemplate(name: 'kubectl', image: 'bitnami/kubectl:1.18.8-debian-10-r5', command: 'sleep', args: 'infinity', runAsUser: "1000"),
        containerTemplate(name: 'docker', image: 'docker:19.03.12', command: 'sleep', args: 'infinity'),
    ],
    volumes: [hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock')],
    {
        node('simple-api-build-pod'){
            withCredentials([
                usernamePassword(
                    credentialsId: 'docker-registry-cred',
                    usernameVariable: 'DOCKER_REGISTRY_USER',
                    passwordVariable: 'DOCKER_REGISTRY_PASSWORD',
                ),
                string(credentialsId: 'docker-registry-address', variable: 'DOCKER_REGISTRY'),
                string(credentialsId: 'cluster-domain', variable: 'CLUSTER_DOMAIN'),
            ]) {
                stage('Checkout') {
                    checkout scm
                }
                stage('Build') {
                    sh '''
                        mkdir -p builder/target
                        builder/tag.sh > builder/target/tag.sh
                    '''
                    container('docker') {
                        sh '''
                            . builder/target/tag.sh
                            docker build -t "${DOCKER_REGISTRY}/kublr/simple-api:${TAG}" simple-api
                        '''
                    }
                }
                stage('Release') {
                    container('shell') {
                        sh 'hostname'
                        sh 'uname -a'
                    }
                    container('kubectl') {
                        sh 'kubectl get nodes'
                    }
                    container('helm') {
                        sh 'helm version'
                    }
                    container('docker') {
                        sh '''
                            . builder/target/tag.sh
                            docker login "${DOCKER_REGISTRY}" -u "${DOCKER_REGISTRY_USER}" -p "${DOCKER_REGISTRY_PASSWORD}"
                            docker push  "${DOCKER_REGISTRY}/kublr/simple-api:${TAG}"
                        '''
                    }
                }
                stage('Deploy') {
                    container('helm') {
                        sh '''
                            . builder/target/tag.sh
                            helm upgrade -i --create-namespace -n ${GIT_BRANCH_ID} simple-api simple-api/helm/simple-api \
                                --set image.repository="${DOCKER_REGISTRY}/kublr/simple-api" \
                                --set image.tag="${TAG}" \
                                --set ingress.enabled=true \
                                --set ingress.hosts[0].host=simple-api.${GIT_BRANCH_ID}.${CLUSTER_DOMAIN} \
                                --set ingress.hosts[0].paths[0]=/ \
                                --set ingress.hosts[0].paths[1]=/${GIT_BRANCH_ID}
                        '''
                    }
                }
            }
        }
    }
)
