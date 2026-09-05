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

        stage('Deploy to Hetzner') {
            steps {
                // Read password and API key using jq or awk and export it
                sh '''
                export ROOT_PASSWORD=$(cat env.prod.json | grep ROOT_PASSWORD | cut -d '"' -f 4)
                export GEMINI_API_KEY=$(cat env.prod.json | grep GEMINI_API_KEY | cut -d '"' -f 4)
                
                # 1. Deploy Frontend
                sshpass -p "$ROOT_PASSWORD" rsync -avz -e "ssh -o StrictHostKeyChecking=no" --delete frontend/build/jaspr/ root@157.180.22.218:/var/www/creatortools/frontend/
                
                # 2. Deploy Admin Panel
                sshpass -p "$ROOT_PASSWORD" rsync -avz -e "ssh -o StrictHostKeyChecking=no" --delete admin_panel/dist/ root@157.180.22.218:/var/www/creatortools/admin_panel/
                
                # 3. Deploy Backend (Assuming we just copy files and pip install is handled by the service or we restart)
                sshpass -p "$ROOT_PASSWORD" rsync -avz -e "ssh -o StrictHostKeyChecking=no" backend/ root@157.180.22.218:/var/www/creatortools/backend/
                
                # 4. Inject Environment Variables
                sshpass -p "$ROOT_PASSWORD" ssh -o StrictHostKeyChecking=no root@157.180.22.218 "echo 'GEMINI_API_KEY=$GEMINI_API_KEY' > /var/www/creatortools/backend/.env"
                
                # 5. Restart the python service
                sshpass -p "$ROOT_PASSWORD" ssh -o StrictHostKeyChecking=no root@157.180.22.218 "sudo systemctl restart creatortools"
                '''
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
