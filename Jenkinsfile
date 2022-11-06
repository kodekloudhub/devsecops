@Library('slack') _


/////// ******************************* Code for fectching Failed Stage Name ******************************* ///////
import io.jenkins.blueocean.rest.impl.pipeline.PipelineNodeGraphVisitor
import io.jenkins.blueocean.rest.impl.pipeline.FlowNodeWrapper
import org.jenkinsci.plugins.workflow.support.steps.build.RunWrapper
import org.jenkinsci.plugins.workflow.actions.ErrorAction

// Get information about all stages, including the failure cases
// Returns a list of maps: [[id, failedStageName, result, errors]]
@NonCPS
List<Map> getStageResults( RunWrapper build ) {

    // Get all pipeline nodes that represent stages
    def visitor = new PipelineNodeGraphVisitor( build.rawBuild )
    def stages = visitor.pipelineNodes.findAll{ it.type == FlowNodeWrapper.NodeType.STAGE }

    return stages.collect{ stage ->

        // Get all the errors from the stage
        def errorActions = stage.getPipelineActions( ErrorAction )
        def errors = errorActions?.collect{ it.error }.unique()

        return [ 
            id: stage.id, 
            failedStageName: stage.displayName, 
            result: "${stage.status.result}",
            errors: errors
        ]
    }
}

// Get information of all failed stages
@NonCPS
List<Map> getFailedStages( RunWrapper build ) {
    return getStageResults( build ).findAll{ it.result == 'FAILURE' }
}

/////// ******************************* Code for fectching Failed Stage Name ******************************* ///////

pipeline {
  agent any

  environment {
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-svc"
    imageName = "siddharth67/numeric-app:${GIT_COMMIT}"
    applicationURL="http://devsecops-demo.eastus.cloudapp.azure.com"
    applicationURI="/increment/99"
  }

  stages {

 //    stage('Build Artifact - Maven') {
 //      steps {
 //        sh "mvn clean package -DskipTests=true"
 //        archive 'target/*.jar'
 //      }
 //    }

 //    stage('Unit Tests - JUnit and JaCoCo') {
 //      steps {
 //        sh "mvn test"
 //      }
 //    }

 //    stage('Mutation Tests - PIT') {
 //      steps {
 //        sh "mvn org.pitest:pitest-maven:mutationCoverage"
 //      }
 //    }

 //    stage('SonarQube - SAST') {
 //      steps {
 //        withSonarQubeEnv('SonarQube') {
 //          sh "mvn sonar:sonar \
	// 	              -Dsonar.projectKey=numeric-application \
	// 	              -Dsonar.host.url=http://devsecops-demo.eastus.cloudapp.azure.com:9000"
 //        }
 //        timeout(time: 2, unit: 'MINUTES') {
 //          script {
 //            waitForQualityGate abortPipeline: true
 //          }
 //        }
 //      }
 //    }

	// stage('Vulnerability Scan - Docker') {
 //      steps {
 //        parallel(
 //        	"Dependency Scan": {
 //        		sh "mvn dependency-check:check"
	// 		},
	// 		"Trivy Scan":{
	// 			sh "bash trivy-docker-image-scan.sh"
	// 		},
	// 		"OPA Conftest":{
	// 			sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
	// 		}   	
 //      	)
 //      }
 //    }
    

 //    stage('Docker Build and Push') {
 //      steps {
 //        withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
 //          sh 'printenv'
 //          sh 'sudo docker build -t siddharth67/numeric-app:""$GIT_COMMIT"" .'
 //          sh 'docker push siddharth67/numeric-app:""$GIT_COMMIT""'
 //        }
 //      }
 //    }

 //    stage('Vulnerability Scan - Kubernetes') {
 //      steps {
 //        parallel(
 //          "OPA Scan": {
 //            sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
 //          },
 //          "Kubesec Scan": {
 //            sh "bash kubesec-scan.sh"
 //          },
 //          "Trivy Scan": {
 //            sh "bash trivy-k8s-scan.sh"
 //          }
 //        )
 //      }
 //    }

 //    stage('K8S Deployment - DEV') {
 //      steps {
 //        parallel(
 //          "Deployment": {
 //            withKubeConfig([credentialsId: 'kubeconfig']) {
 //              sh "bash k8s-deployment.sh"
 //            }
 //          },
 //          "Rollout Status": {
 //            withKubeConfig([credentialsId: 'kubeconfig']) {
 //              sh "bash k8s-deployment-rollout-status.sh"
 //            }
 //          }
 //        )
 //      }
 //    }

 //    stage('Integration Tests - DEV') {
 //      steps {
 //        script {
 //          try {
 //            withKubeConfig([credentialsId: 'kubeconfig']) {
 //              sh "bash integration-test.sh"
 //            }
 //          } catch (e) {
 //            withKubeConfig([credentialsId: 'kubeconfig']) {
 //              sh "kubectl -n default rollout undo deploy ${deploymentName}"
 //            }
 //            throw e
 //          }
 //        }
 //      }
 //    }

 //   stage('OWASP ZAP - DAST') {
 //      steps {
 //        withKubeConfig([credentialsId: 'kubeconfig']) {
 //          sh 'bash zap.sh'
 //        }
 //      }
 //    }

 //    stage('Prompte to PROD?') {
 //      steps {
 //        timeout(time: 2, unit: 'DAYS') {
 //          input 'Do you want to Approve the Deployment to Production Environment/Namespace?'
 //        }
 //      }
 //    }

 //    stage('K8S CIS Benchmark') {
 //      steps {
 //        script {

 //          parallel(
 //            "Master": {
 //              sh "bash cis-master.sh"
 //            },
 //            "Etcd": {
 //              sh "bash cis-etcd.sh"
 //            },
 //            "Kubelet": {
 //              sh "bash cis-kubelet.sh"
 //            }
 //          )

 //        }
 //      }
 //    }

 //    stage('K8S Deployment - PROD') {
 //      steps {
 //        parallel(
 //          "Deployment": {
 //            withKubeConfig([credentialsId: 'kubeconfig']) {
 //              sh "sed -i 's#replace#${imageName}#g' k8s_PROD-deployment_service.yaml"
 //              sh "kubectl -n prod apply -f k8s_PROD-deployment_service.yaml"
 //            }
 //          },
 //          "Rollout Status": {
 //            withKubeConfig([credentialsId: 'kubeconfig']) {
 //              sh "bash k8s-PROD-deployment-rollout-status.sh"
 //            }
 //          }
 //        )
 //      }
 //    }

 //    stage('Integration Tests - PROD') {
 //      steps {
 //        script {
 //          try {
 //            withKubeConfig([credentialsId: 'kubeconfig']) {
 //              sh "bash integration-test-PROD.sh"
 //            }
 //          } catch (e) {
 //            withKubeConfig([credentialsId: 'kubeconfig']) {
 //              sh "kubectl -n prod rollout undo deploy ${deploymentName}"
 //            }
 //            throw e
 //          }
 //        }
 //      }
 //    }   
   
      stage('Testing Slack - 1') {
      steps {
          sh 'exit 0'
      }
    }

   stage('Testing Slack - Error Stage') {
      steps {
          sh 'exit 0'
      }
    }

  }

  post { 
     //    always { 
     //      junit 'target/surefire-reports/*.xml'
     //      jacoco execPattern: 'target/jacoco.exec'
     //      pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
     //      dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
     //      publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'owasp-zap-report', reportFiles: 'zap_report.html', reportName: 'OWASP ZAP HTML Report', reportTitles: 'OWASP ZAP HTML Report'])
        
 		  // //Use sendNotifications.groovy from shared library and provide current build result as parameter 
     //      //sendNotification currentBuild.result
     //    }

        success {
        	script {
		        /* Use slackNotifier.groovy from shared library and provide current build result as parameter */  
		        env.failedStage = "none"
		        env.emoji = ":white_check_mark: :tada: :thumbsup_all:" 
		        sendNotification currentBuild.result
		      }
        }

	    failure {
	    	script {
			  //Fetch information about  failed stage
		      def failedStages = getFailedStages( currentBuild )
	          env.failedStage = failedStages.failedStageName
	          env.emoji = ":x: :red_circle: :sos:"
		      sendNotification currentBuild.result
		    }	
	    }
    }

}