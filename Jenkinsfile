
pipeline {
    agent any

    environment {
        // Set your tool environment variables
        //SONARQUBE_SERVER = 'SonarQube' // Jenkins SonarQube server name
        SNYK_TOKEN = credentials('snyk-api-token') // Store Snyk token in Jenkins Credentials
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Cloning source code...'
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installing project dependencies...'
                sh 'npm install' // or mvn install / pip install -r requirements.txt
            }
        }

        // stage('Static Code Analysis - SonarQube') {
        //     steps {
        //         echo 'Running SonarQube scan...'
        //         withSonarQubeEnv("${SONARQUBE_SERVER}") {
        //             sh 'sonar-scanner'
        //         }
        //     }
        // }

        stage('Secret Scanning - Gitleaks') {
            steps {
                echo 'Running Gitleaks secret scan...'
                sh '''
                if ! command -v gitleaks &> /dev/null
                then
                    echo "Installing Gitleaks..."
                    wget -q https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks-linux-amd64 -O /usr/local/bin/gitleaks
                    chmod +x /usr/local/bin/gitleaks
                fi
                gitleaks detect --source . --report-path gitleaks-report.json || true
                '''
            }
        }

        stage('Dependency Scanning Tool - Snyk') {
            steps {
                echo 'Running Snyk dependency scan...'
                sh '''
                if ! command -v snyk &> /dev/null
                then
                    npm install -g snyk
                fi
                snyk auth $SNYK_TOKEN
                snyk test --all-projects --severity-threshold=medium || true
                '''
            }
        }

        stage('Container Image Scanning - Trivy') {
            steps {
                echo 'Scanning Docker image with Trivy...'
                sh '''
                if ! command -v trivy &> /dev/null
                then
                    sudo apt-get update -qq && sudo apt-get install -y wget
                    wget -qO- https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
                    echo deb https://aquasecurity.github.io/trivy-repo/deb stable main | sudo tee /etc/apt/sources.list.d/trivy.list
                    sudo apt-get update && sudo apt-get install -y trivy
                fi
                trivy fs . --severity HIGH,CRITICAL --exit-code 0 --format table --output trivy-report.txt
                '''
            }
        }

        stage('Dependency Check (OWASP)') {
            steps {
                echo 'Running OWASP Dependency-Check...'
                sh '''
                if [ ! -d "dependency-check" ]; then
                    wget -q https://github.com/jeremylong/DependencyCheck/releases/latest/download/dependency-check.zip
                    unzip dependency-check.zip -d dependency-check
                fi
                ./dependency-check/bin/dependency-check.sh --project "MyProject" --scan . --format HTML --out dependency-check-report.html || true
                '''
            }
        }

        stage('Post Build Summary') {
            steps {
                echo 'All security scans completed. Reports generated:'
                sh 'ls -1 *.json *.html *.txt || true'
            }
        }
    }

    post {
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
        failure {
            echo 'Build failed — check reports and fix issues before retrying.'
        }
    }
}
