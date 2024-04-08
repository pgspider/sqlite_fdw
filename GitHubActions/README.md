# CI environment of sqlite_fdw.

Tests will be executed automatically when commited to main/master branch and when a pull request was opened/updated.
It is realized by using GitHub actions.

The CI process is defined in .github/workflows/CI.yml file.
Scripts in this directory (GitHubActions/*.sh) are referred by CI.yml. 

The regression test will be executed for multi-versions of PostgreSQL.
Target versions are determined automatically based on directory names in "sql" directory.
