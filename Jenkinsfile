def NODE_NAME = 'AWS_Instance_CentOS'
def MAIL_TO = '$DEFAULT_RECIPIENTS'
def BRANCH_NAME = 'Branch [' + env.BRANCH_NAME + ']'
def BUILD_INFO = 'Jenkins job: ' + env.BUILD_URL + '\n'

def POSTGRES_DOCKER_PATH = '/home/jenkins/Docker_ExistedMulti/Server/Postgres'

def TEST_TYPE = 'SQLITE'

def make_check_test(String target, String version) {
    def prefix = ""
    script {
        if (version != "") {
            version = "-" + version
        }
        if (target == "PGSpider") {
            prefix = "REGRESS_PREFIX=PGSpider"
        }
    }
    catchError() {
        sh """
            rm -rf make_check_existed_test.out || true
            docker exec postgresserver_multi_for_sqlite_existed_test /bin/bash -c 'su -c "/tmp/sqlite_existed_test.sh ${env.GIT_BRANCH} ${target}${version}" postgres'
            docker exec -w /home/postgres/${target}${version}/contrib/sqlite_fdw postgresserver_multi_for_sqlite_existed_test /bin/bash -c 'su -c "make clean && make ${prefix} && export LANGUAGE="en_US.UTF-8" && export LANG="en_US.UTF-8" && export LC_ALL="en_US.UTF-8" && make check ${prefix} | tee make_check_existed_test.out" postgres'
            docker cp postgresserver_multi_for_sqlite_existed_test:/home/postgres/${target}${version}/contrib/sqlite_fdw/results/ results_${target}${version}
            docker cp postgresserver_multi_for_sqlite_existed_test:/home/postgres/${target}${version}/contrib/sqlite_fdw/make_check_existed_test.out make_check_existed_test.out
        """
    }
    script {
        status = sh(returnStatus: true, script: "grep -q 'All [0-9]* tests passed' 'make_check_existed_test.out'")
        if (status != 0) {
            unstable(message: "Set UNSTABLE result")
            sh "docker cp postgresserver_multi_for_sqlite_existed_test:/home/postgres/${target}${version}/contrib/sqlite_fdw/regression.diffs regression.diffs"
            sh 'cat regression.diffs || true'
            emailext subject: '[CI SQLITE_FDW] EXISTED_TEST: Result make check on ${target}${version} FAILED ' + BRANCH_NAME, body: BUILD_INFO  + '${FILE,path="make_check_existed_test.out"}', to: "${MAIL_TO}", attachLog: false
            updateGitlabCommitStatus name: 'make_check', state: 'failed'
        } else {
            updateGitlabCommitStatus name: 'make_check', state: 'success'
        }
    }
}

pipeline {
    agent {
        node {
            label NODE_NAME
        }
    }
    options {
        gitLabConnection('GitLabConnection')
    }
    triggers { 
        gitlab(
            triggerOnPush: true,
            triggerOnMergeRequest: false,
            triggerOnClosedMergeRequest: false,
            triggerOnAcceptedMergeRequest: true,
            triggerOnNoteRequest: false,
            setBuildDescription: true,
            branchFilterType: 'All',
            secretToken: "14edd1f2fc244d9f6dfc41f093db270a"
        )
    }
    stages {
        stage('Start_containers_Existed_Test') {
            steps {
                script {
                    if (env.GIT_URL != null) {
                        BUILD_INFO = BUILD_INFO + "Git commit: " + env.GIT_URL.replace(".git", "/commit/") + env.GIT_COMMIT + "\n"
                    }
                    sh 'rm -rf results_* || true'
                }
                catchError() {
                    sh """
                        cd ${POSTGRES_DOCKER_PATH}
                        docker build -t postgresserver_multi .
                        docker run -d --name postgresserver_multi_for_sqlite_existed_test postgresserver_multi
                    """
                }
            }
            post {
                failure {
                    emailext subject: '[CI SQLITE_FDW] EXISTED_TEST: Start Containers FAILED ' + BRANCH_NAME, body: BUILD_INFO + '${BUILD_LOG, maxLines=200, escapeHtml=false}', to: "${MAIL_TO}", attachLog: false
                    updateGitlabCommitStatus name: 'Build', state: 'failed'
                }
                success { 
                    updateGitlabCommitStatus name: 'Build', state: 'success'
                }
            }
        }
        stage('make_check_FDW_Test_With_Postgres_9_6_19') {
            steps {
                catchError() {
                    make_check_test("postgresql", "9.6.19")
                }
            }
        }
        stage('make_check_FDW_Test_With_Postgres_10_14') {
            steps {
                catchError() {
                   make_check_test("postgresql","10.14")
                }
            }
        }
        stage('make_check_FDW_Test_With_Postgres_11_9') {
            steps {
                catchError() {
                   make_check_test("postgresql","11.9")
                }
            }
        }
        stage('make_check_FDW_Test_With_Postgres_12_4') {
            steps {
                catchError() {
                   make_check_test("postgresql","12.4")
                }
            }
        }
        stage('make_check_FDW_Test_With_Postgres_13_0') {
            steps {
                catchError() {
                   make_check_test("postgresql","13.0")
                }
            }
        }
        stage('Build_PGSpider_For_FDW_Test') {
            steps {
                catchError() {
                    sh """
                        docker exec postgresserver_multi_for_sqlite_existed_test /bin/bash -c 'su -c "/tmp/initialize_pgspider_existed_test.sh" postgres'
                    """
                }
            }
            post {
                failure {
                    emailext subject: '[CI SQLITE_FDW] EXISTED_TEST: Build PGSpider FAILED ' + BRANCH_NAME, body: BUILD_INFO + '${BUILD_LOG, maxLines=200, escapeHtml=false}', to: "${MAIL_TO}", attachLog: false
                    updateGitlabCommitStatus name: 'Build_PGSPider', state: 'failed'
                }
                success {
                    updateGitlabCommitStatus name: 'Build_PGSPider', state: 'success'
                }
            }
        }
        stage('make_check_FDW_Test_With_PGSpider') {
            steps {
                catchError() {
                   make_check_test("PGSpider","")
                }
            }
        }
    }
    post {
        success  {
            script {
                prevResult = 'SUCCESS'
                if (currentBuild.previousBuild != null) {
                    prevResult = currentBuild.previousBuild.result.toString()
                }
                if (prevResult != 'SUCCESS') {
                    emailext subject: '[CI SQLITE_FDW] SQLITE_Test BACK TO NORMAL on ' + BRANCH_NAME, body: BUILD_INFO  + '${FILE,path="make_check_existed_test.out"}', to: "${MAIL_TO}", attachLog: false
                }
            }
        }
        always {
            sh """
                docker stop postgresserver_multi_for_sqlite_existed_test
                docker rm postgresserver_multi_for_sqlite_existed_test
            """
        }
    }
}
