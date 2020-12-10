pipeline {
  agent {
    kubernetes {
      label 'ruby-2.7'
      containerTemplate {
          name 'ruby'
          image 'ruby:2.7'
          ttyEnabled true
          command 'cat'
      }
    }
  }
  
  triggers {
    issueCommentTrigger('.*test this please.*')
  }

  environment {
    VERSION = get_docker_tag()
    DOCKER_REGISTRY = 'q8s.quadrabee.com'
    SLACK_CHANNEL = 'opensource-cicd'
  }

  stages {

    stage ('Bundle install') {
      steps {
        container('ruby') {
          script {
            sh 'bundle install'
          }
        }
      }
    }
    stage ('Rake test') {
      steps {
        container('ruby') {
          script {
            sh 'bundle exec rake test'
          }
        }
      }
    }
  }
}

def get_docker_tag() {
  if (env.TAG_NAME != null) {
    return env.TAG_NAME
  }
  return 'latest'
}
