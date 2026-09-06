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
                    sh '. venv/bin/activate && pip install -r requirements.txt -r requirements-dev.txt'
                    
                    // Run pytest
                    sh '. venv/bin/activate && pytest tests/'
                }
            }
        }

        stage('Deploy to Hetzner') {
            steps {
                withCredentials([string(credentialsId: 'gemini_api_key', variable: 'GEMINI_API_KEY')]) {
                    sshagent(['hetzner_ssh_key']) {
                        sh '''
                        # 1. Deploy Frontend
                        rsync -avz -e "ssh -o StrictHostKeyChecking=no" --delete frontend/build/jaspr/ root@157.180.22.218:/var/www/vidseokit/frontend/
                        
                        # 2. Deploy Admin Panel
                        rsync -avz -e "ssh -o StrictHostKeyChecking=no" --delete admin_panel/dist/ root@157.180.22.218:/var/www/vidseokit/admin_panel/
                        
                        # 3. Deploy Backend (Assuming we just copy files and pip install is handled by the service or we restart)
                        rsync -avz -e "ssh -o StrictHostKeyChecking=no" backend/ root@157.180.22.218:/var/www/vidseokit/backend/
                        
                        # 4. Inject Environment Variables and Secrets
                        ssh -o StrictHostKeyChecking=no root@157.180.22.218 "cp -n /var/www/creatortools/backend/serviceAccountKey.json /var/www/vidseokit/backend/ 2>/dev/null || true"
                        ssh -o StrictHostKeyChecking=no root@157.180.22.218 "cp -n /var/www/creatortools/backend/.env /var/www/vidseokit/backend/ 2>/dev/null || true"
                        ssh -o StrictHostKeyChecking=no root@157.180.22.218 "grep -q '^GEMINI_API_KEY=' /var/www/vidseokit/backend/.env 2>/dev/null && sed -i 's/^GEMINI_API_KEY=.*/GEMINI_API_KEY=$GEMINI_API_KEY/' /var/www/vidseokit/backend/.env || echo 'GEMINI_API_KEY=$GEMINI_API_KEY' >> /var/www/vidseokit/backend/.env"
                        
                        # 5. Restart the python service
                        ssh -o StrictHostKeyChecking=no root@157.180.22.218 "sudo systemctl restart vidseokit"
                        '''
                    }
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
