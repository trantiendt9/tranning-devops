pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: node
      image: node:16
      command:
        - cat
      tty: true

    - name: kaniko
      image: gcr.io/kaniko-project/executor:latest
      command:
        - cat
      tty: true
      volumeMounts:
        - name: kaniko-secret
          mountPath: /kaniko/.aws

  volumes:
    - name: kaniko-secret
      secret:
        secretName: aws-secret  # chứa AWS_ACCESS_KEY_ID và AWS_SECRET_ACCESS_KEY
"""
        }
    }

    environment {
        AWS_REGION = "ap-southeast-1"
        ECR_ACCOUNT = "372836560690"
        ECR_REPO = "do2506/youtube-clone"
        IMAGE_TAG = ""
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

        stage('Set Image Tag') {
            steps {
                container('node') {
                    script {
                        // Fix dubious ownership + Groovy $ escape
                        def tag = sh(
                            script: "git config --global --add safe.directory \${pwd} && git rev-parse --short HEAD",
                            returnStdout: true
                        ).trim()
                        env.IMAGE_TAG = tag
                        echo "IMAGE_TAG=${tag}"
                    }
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                container('kaniko') {
                    sh """
                        /kaniko/executor \\
                            --context \$PWD \\
                            --dockerfile \$PWD/Dockerfile \\
                            --destination ${ECR_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:\$IMAGE_TAG \\
                            --cleanup
                    """
                }
            }
        }
    }
}
