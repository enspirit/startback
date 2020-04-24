pipeline {

  agent any

  triggers {
    issueCommentTrigger('.*test this please.*')
  }

  environment {
    DOCKER_TAG = get_docker_tag()
  }

  stages {

    stage ('Start') {
      steps {
        sendNotifications('STARTED', SLACK_CHANNEL)
      }
    }

    stage ('Building Docker Images') {
      steps {
        container('builder') {
          sh 'make -j images'
        }
      }
    }

    stage ('Pushing Docker Images') {
      when {
        anyOf {
          branch 'master'
          buildingTag()
        }
      }
      steps {
        container('builder') {
          script {
            docker.withRegistry('https://q8s.quadrabee.com', 'q8s-deploy-enspirit-be') {
              sh 'make push-images'
            }
          }
        }
      }
    }
  }

  post {
    always {
      container('builder') {
        junit keepLongStdio: true,
          testResults: '**/rspec*.xml',
          allowEmptyResults: true
      }
    }
    success {
      sendNotifications('SUCCESS', SLACK_CHANNEL)
    }
    failure {
      sendNotifications('FAILED', SLACK_CHANNEL)
    }
  }
}

def get_docker_tag() {
  if (env.TAG_NAME != null) {
    return env.TAG_NAME
  }
  return 'latest'
}
