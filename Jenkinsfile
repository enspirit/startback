pipeline {

  agent any

  triggers {
    issueCommentTrigger('.*test this please.*')
  }

  environment {
    VERSION = get_docker_tag()
    DOCKER_REGISTRY = 'q8s.dev/enspirit'
    SLACK_CHANNEL = 'opensource-cicd'
  }

  stages {

    stage ('Start') {
      steps {
        sendNotifications('STARTED', SLACK_CHANNEL)
      }
    }

    stage ('Clean') {
      steps {
        container('builder') {
          script { sh 'make clean' }
        }
      }
    }

    stage ('Building Docker Images') {
      steps {
        container('builder') {
          sh 'make -j images'
        }
      }
    }

    stage ('Running tests') {
      steps {
        container('builder') {
          sh 'make ci'
        }
      }
    }

    stage ('Building and Publishing Gems') {
      environment {
        GEM_HOST_API_KEY = credentials('jenkins-rubygems-api-key')
      }      
      when {
        buildingTag()
      }
      steps {
        container ('builder') {
          sh 'make base.gem'
          sh 'make api.gem'
          sh 'make web.gem'
          sh 'make engine.gem'
          sh 'make base.push-gem'
          sh 'make api.push-gem'
          sh 'make web.push-gem'
          sh 'make engine.push-gem'
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
            docker.withRegistry('https://q8s.dev', 'jenkins-startback-builds') {
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
