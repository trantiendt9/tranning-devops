pipeline {

    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: node
      image: node:18
      command:
        - cat
      tty: true
    - name: docker
      image: docker:25.0.3-dind
      securityContext:
        privileged: true
      command:
      - sh
      - -c
      - |
        git config --global --add safe.directory /home/jenkins/agent/workspace/dev-frontend
        tail -f /dev/null
      tty: true
      volumeMounts:
        - name: dind-storage
          mountPath: /var/lib/docker
      volumes:
        - name: dind-storage
          emptyDir: {}

    - name: awscli
      image: amazon/aws-cli:2.15.0
      command:
        - cat
      tty: true

  volumes:
    - name: dind-storage
      emptyDir: {}
"""
        }
    }

    environment {
        AWS_REGION = "ap-southeast-1"
        ECR_ACCOUNT = "372836560690"
        ECR_REPO = "do2506/youtube-clone"
    }

    stages {

        stage('Checkout') {
            steps {
                container('node') {
                    git url: 'https://github.com/trantiendt9/vue-nodejs-youtube-clone.git',
                        branch: 'master',
                        credentialsId: 'github-to-jenkins'
                }
            }
        }

        stage('Build Source') {
            steps {
                container('node') {
                    sh '''
                        export NODE_OPTIONS=--openssl-legacy-provider
                        npm install
                        npm run build || true
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                container('docker') {
                    script {
                        // Khai báo local variable
                        def IMAGE_TAG = sh(
                            script: "git rev-parse --short HEAD",
                            returnStdout: true
                        ).trim()
        
                        echo "IMAGE_TAG=${IMAGE_TAG}"
                        sh """
                            dockerd-entrypoint.sh &
                            sleep 5
                            docker version
                            docker build -t ${ECR_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG} .
                        """
                    }
                }
            }
        }

        stage('Push ECR') {
            steps {
                container('awscli') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                        credentialsId: 'aws-cred'
                    ]]) {

                        sh """
                            aws ecr get-login-password --region ${AWS_REGION} \
                                | docker login --username AWS --password-stdin ${ECR_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com
                        """

                        sh """
                            docker push ${ECR_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}
                        """
                    }
                }
            }
        }

    }
}
