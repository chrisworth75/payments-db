// Jenkinsfile in payments-db repository
pipeline {
    agent any

    environment {
        TEST_DB_CONTAINER = 'postgres-payments-test'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'echo "Checked out payments database successfully"'
            }
        }

        stage('Setup Test Environment') {
            steps {
                script {
                    sh """
                        docker stop ${TEST_DB_CONTAINER} || true
                        docker rm ${TEST_DB_CONTAINER} || true
                        docker run -d \\
                        --name ${TEST_DB_CONTAINER} \\
                        --platform=linux/arm64 \\
                        -e POSTGRES_PASSWORD=postgres \\
                        -e POSTGRES_DB=payments_test \\
                        -p 5445:5432 \\
                        postgres:15-alpine
                    """
                    sleep 10
                    sh 'docker exec ${TEST_DB_CONTAINER} pg_isready -U postgres || echo "Database not ready yet"'
                }
            }
        }

        stage('Validate SQL') {
            steps {
                sh '''
                    echo "Validating SQL files..."
                    if [ -d "db-init" ]; then
                        find db-init -name "*.sql" | wc -l | xargs echo "Found SQL files:"
                        echo "Files:"
                        ls -la db-init/*.sql
                    else
                        echo "No db-init directory found"
                        exit 1
                    fi
                '''
            }
        }

        stage('Test Schema') {
            steps {
                script {
                    sh """
                        echo "Testing schema creation..."
                        docker exec -i ${TEST_DB_CONTAINER} psql -U postgres -d payments_test < db-init/01-schema.sql

                        echo "Verifying tables created..."
                        docker exec ${TEST_DB_CONTAINER} psql -U postgres -d payments_test -c "\\dt"

                        echo "Testing sample data..."
                        docker exec -i ${TEST_DB_CONTAINER} psql -U postgres -d payments_test < db-init/02-data.sql

                        echo "Verifying data loaded..."
                        docker exec ${TEST_DB_CONTAINER} psql -U postgres -d payments_test -c "SELECT COUNT(*) as payment_count FROM payment;"
                    """
                }
            }
        }

        stage('Deploy Database') {
            when {
                branch 'main'
            }
            steps {
                script {
                    sh '''
                        echo "📦 Deploying payments database..."

                        # Check if payments-network exists, create if not
                        docker network inspect payments-network >/dev/null 2>&1 || docker network create payments-network

                        # Stop and remove existing container
                        docker stop payments-db || true
                        docker rm payments-db || true

                        # Run new database container with initialization scripts
                        docker run -d \\
                          --name payments-db \\
                          --network payments-network \\
                          --restart unless-stopped \\
                          -e POSTGRES_USER=postgres \\
                          -e POSTGRES_PASSWORD=postgres \\
                          -e POSTGRES_DB=payments \\
                          -v "$(pwd)/db-init:/docker-entrypoint-initdb.d:ro" \\
                          -p 5446:5432 \\
                          postgres:15-alpine

                        echo "⏳ Waiting for database to be ready..."
                        sleep 10

                        # Wait for database to be ready
                        for i in {1..30}; do
                            if docker exec payments-db pg_isready -U postgres >/dev/null 2>&1; then
                                echo "✅ Database is ready!"
                                break
                            fi
                            echo "Waiting for database... ($i/30)"
                            sleep 2
                        done

                        # Verify data loaded
                        echo "📊 Checking database..."
                        docker exec payments-db psql -U postgres -d payments -c "\\dt"
                        docker exec payments-db psql -U postgres -d payments -c "SELECT COUNT(*) as payment_count FROM payment;"
                        docker exec payments-db psql -U postgres -d payments -c "SELECT COUNT(*) as fee_count FROM fee;"
                    '''
                }
            }
        }
    }

    post {
        always {
            script {
                sh """
                    docker stop ${TEST_DB_CONTAINER} || true
                    docker rm ${TEST_DB_CONTAINER} || true
                """
            }
        }
        success {
            echo '✅ Payments database pipeline completed successfully!'
        }
        failure {
            echo '❌ Payments database pipeline failed!'
        }
    }
}
