# Allow Jenkins run jobs in the cluster

kubectl create clusterrolebinding cluster-admin:devops:jenkins --clusterrole=cluster-admin --serviceaccount=devops:jenkins
kubectl create clusterrolebinding cluster-admin:devops:default --clusterrole=cluster-admin --serviceaccount=devops:default

# Create a token for Jenkins API scription

JCRUMB=$(curl --silent --show-error --fail -X GET  -c cookies.txt -u "admin:$JPWD" \
    $JURL/crumbIssuer/api/json | jq -r .crumb)

JTOKEN=$(curl --silent --show-error --fail -X POST -b cookies.txt -u "admin:$JPWD" \
    -H "Jenkins-Crumb: $JCRUMB" \
    $JURL/me/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken?newTokenName=\devops-demo | jq -r .data.tokenValue)

# Save the token in a file

echo "JTOKEN='${JTOKEN}'" > jenkins-token-${DOMAIN}.sh

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

# create job

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
