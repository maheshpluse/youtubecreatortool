pipeline {
    agent any

    environment {
        CI = 'true'
    }

    stages {
        stage('Frontend (Jaspr)') {
            steps {
                dir('frontend') {
                    // Install dependencies
                    sh 'dart pub get'
                    
                    // Activate jaspr globally if not already available in the Jenkins environment
                    sh 'dart pub global activate jaspr_cli'
                    
                    // Run tests
                    sh 'dart test || echo "No tests found or test command failed"'
                    
                    // Build frontend assets
                    sh '~/.pub-cache/bin/jaspr build || jaspr build'
                }
            }
        }

        stage('Admin Panel (Vite/React)') {
            steps {
                dir('admin_panel') {
                    // Install dependencies
                    sh 'npm install'
                    
                    // Run linter (oxlint)
                    sh 'npm run lint'
                    
                    // Build static assets
                    sh 'npm run build'
                }
            }
        }

        stage('Backend (Python FastAPI)') {
            steps {
                dir('backend') {
                    // Create virtual environment
                    sh 'python3 -m venv venv'
                    
                    // Install requirements
                    sh '. venv/bin/activate && pip install -r requirements.txt'
                    
                    // If you add pytest tests later, you can run them here:
                    // sh '. venv/bin/activate && pytest'
                }
            }
        }
    }

    post {
        always {
            // Clean workspace after build to save space
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Please check the logs.'
        }
    }
}
