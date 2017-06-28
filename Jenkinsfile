pipeline {
  agent any

  stages {
    stage ('Checkout Code') {
      steps {
        checkout scm
      }
    }
    stage ('Verify Tools'){
      steps {
        parallel (
          docker: { sh "docker -v" }
        )
      }
    }

    stage ('Build container') {
      steps {
        sh "docker build --pull --rm -t dr.haak.co/debian-stretch-php7-apache-jk ."
        sh "docker tag dr.haak.co/debian-stretch-php7-apache-jk:latest dr.haak.co/debian-stretch-php7-apache-jk:${env.GIT_COMMIT}"
      }
    }
    stage ('Deploy') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'bamboo_dr_haak_co', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
          sh "docker login --username ${USERNAME} --password ${PASSWORD} https://dr.haak.co"
          sh "docker push dr.haak.co/debian-stretch-php7-apache-jk:latest"
          sh "docker push dr.haak.co/debian-stretch-php7-apache-jk:${env.GIT_COMMIT}"
        }
      }
    }
  }
}
