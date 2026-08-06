CI/CD Integration Tutorial
==========================

Integrate GDSentry testing into your automated pipelines for continuous quality assurance. This tutorial covers setup, configuration, and best practices for all major CI/CD platforms.

.. note::
   **Prerequisites**: GDSentry installed and configured in your Godot project. Complete the :doc:`../getting-started` guide first.

Why CI/CD Integration?
======================

CI/CD integration ensures:
- **Automated Testing**: Tests run on every code change
- **Early Bug Detection**: Catch issues before they reach production
- **Quality Gates**: Prevent merging code that breaks tests
- **Regression Prevention**: Ensure new features don't break existing functionality
- **Performance Monitoring**: Track performance trends over time

GDSentry supports **6 major CI/CD platforms** with comprehensive reporting and analysis features.

Platform Setup Guides
=====================

GitHub Actions
--------------

**1. Create Workflow File**

Create ``.github/workflows/gdsentry-tests.yml``:

.. code-block:: yaml

    name: GDSentry Tests

    on:
      push:
        branches: [ main, develop ]
      pull_request:
        branches: [ main ]

    jobs:
      test:
        runs-on: ubuntu-latest

        steps:
        - name: Checkout code
          uses: actions/checkout@v4

        - name: Setup Python
          uses: actions/setup-python@v4
          with:
            python-version: '3.9'

        - name: Setup Godot
          uses: chickensoft-games/setup-godot@v1
          with:
            version: 4.2.1
            use-dotnet: false

        - name: Install GDSentry
          run: |
            pip install gdsentry

        - name: Build test containers (optional)
          run: |
            gdsentry build all

        - name: Run GDSentry Tests
          run: |
            gdsentry test run --report junit --output test-results/

        - name: Upload test results
          uses: actions/upload-artifact@v4
          if: always()
          with:
            name: test-results
            path: test-results/

        - name: Publish Test Results
          uses: dorny/test-reporter@v1
          if: always()
          with:
            name: GDSentry Tests
            path: test-results/junit.xml
            reporter: java-junit

**2. Environment Variables**

GDSentry automatically detects GitHub Actions and sets:

- ``CI_PLATFORM=github_actions``
- ``BUILD_NUMBER=$GITHUB_RUN_NUMBER``
- ``BRANCH_NAME=$GITHUB_REF_NAME``
- ``COMMIT_HASH=$GITHUB_SHA``

GitLab CI
---------

**1. Create .gitlab-ci.yml**

.. code-block:: yaml

    stages:
      - test

    gdsentry_tests:
      stage: test
      image: python:3.9
      only:
        - merge_requests
        - main

      before_script:
        - pip install gdsentry
        - apt-get update && apt-get install -y wget unzip
        - wget https://downloads.tuxfamily.org/godotengine/4.2.1/Godot_v4.2.1-stable_linux.x86_64.zip
        - unzip Godot_v4.2.1-stable_linux.x86_64.zip
        - mv Godot_v4.2.1-stable_linux.x86_64/Godot /usr/local/bin/godot
        - chmod +x /usr/local/bin/godot
        - mkdir -p test-results

      script:
        - gdsentry test run --report junit --output test-results/

      artifacts:
        reports:
          junit: test-results/junit.xml
        paths:
          - test-results/
        expire_in: 1 week

**2. GitLab-Specific Configuration**

GDSentry detects:
- ``CI_PLATFORM=gitlab_ci``
- ``BUILD_NUMBER=$CI_JOB_ID``
- ``BRANCH_NAME=$CI_COMMIT_REF_NAME``

Jenkins
-------

**1. Create Jenkins Pipeline**

.. code-block:: groovy

    pipeline {
        agent any

        stages {
            stage('Setup') {
                steps {
                    sh '''
                        pip install gdsentry
                        wget https://downloads.tuxfamily.org/godotengine/4.2.1/Godot_v4.2.1-stable_linux.x86_64.zip
                        unzip Godot_v4.2.1-stable_linux.x86_64.zip
                        sudo mv Godot_v4.2.1-stable_linux.x86_64/Godot /usr/local/bin/godot
                        sudo chmod +x /usr/local/bin/godot
                        mkdir -p test-results
                    '''
                }
            }

            stage('Test') {
                steps {
                    sh 'gdsentry test run --report junit --output test-results/'
                }
            }

            stage('Report') {
                steps {
                    junit 'test-results/junit.xml'
                    publishHTML(target: [
                        allowMissing: true,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'test-results',
                        reportFiles: 'report.html',
                        reportName: 'GDSentry Test Report'
                    ])
                }
            }
        }

        post {
            always {
                archiveArtifacts artifacts: 'test-results/**/*', allowEmptyArchive: true
            }
        }
    }

**2. Jenkins Environment Variables**

GDSentry detects:
- ``CI_PLATFORM=jenkins``
- ``BUILD_NUMBER=$BUILD_NUMBER``
- ``BUILD_URL=$BUILD_URL``

Azure DevOps
------------

**1. Create azure-pipelines.yml**

.. code-block:: yaml

    trigger:
    - main

    pool:
      vmImage: 'ubuntu-latest'

    steps:
    - script: |
        wget https://downloads.tuxfamily.org/godotengine/4.2.1/Godot_v4.2.1-stable_linux.x86_64.zip
        unzip Godot_v4.2.1-stable_linux.x86_64.zip
        sudo mv Godot_v4.2.1-stable_linux.x86_64/Godot /usr/local/bin/godot
        sudo chmod +x /usr/local/bin/godot
      displayName: 'Setup Godot'

    - script: |
        cp -r gdsentry/ project/
        mkdir -p test_results
      displayName: 'Setup GDSentry'

    - script: |
        godot --headless --script gdsentry/core/test_runner.gd --discover --report junit --report-path test_results/
      displayName: 'Run GDSentry Tests'

    - task: PublishTestResults@2
      condition: always()
      inputs:
        testResultsFormat: 'JUnit'
        testResultsFiles: 'test_results/junit.xml'
        testRunTitle: 'GDSentry Test Results'

    - task: PublishBuildArtifacts@1
      condition: always()
      inputs:
        pathToPublish: 'test_results'
        artifactName: 'test-results'

**2. Azure DevOps Variables**

GDSentry detects:
- ``CI_PLATFORM=azure_devops``
- ``BUILD_NUMBER=$BUILD_BUILDNUMBER``

CircleCI
--------

**1. Create .circleci/config.yml**

.. code-block:: yaml

    version: 2.1

    orbs:
      godot: chickensoft-games/godot@1

    workflows:
      test:
        jobs:
          - test

    jobs:
      test:
        docker:
          - image: barichello/godot-ci:4.2.1
        steps:
          - checkout
          - run:
              name: Setup GDSentry
              command: cp -r gdsentry/ project/
          - run:
              name: Create results directory
              command: mkdir -p test_results
          - run:
              name: Run GDSentry Tests
              command: godot --headless --script gdsentry/core/test_runner.gd --discover --report junit --report-path test_results/
          - store_test_results:
              path: test_results/junit.xml
          - store_artifacts:
              path: test_results/

**2. CircleCI Environment**

GDSentry detects:
- ``CI_PLATFORM=circleci``
- ``BUILD_NUMBER=$CIRCLE_BUILD_NUM``

Travis CI
---------

**1. Create .travis.yml**

.. code-block:: yaml

    language: generic

    before_script:
      - wget https://downloads.tuxfamily.org/godotengine/4.2.1/Godot_v4.2.1-stable_linux.x86_64.zip
      - unzip Godot_v4.2.1-stable_linux.x86_64.zip
      - sudo mv Godot_v4.2.1-stable_linux.x86_64/Godot /usr/local/bin/godot
      - sudo chmod +x /usr/local/bin/godot
      - cp -r gdsentry/ project/
      - mkdir -p test_results

    script:
      - godot --headless --script gdsentry/core/test_runner.gd --discover --report junit --report-path test_results/

    after_script:
      - cat test_results/junit.xml

**2. Travis CI Variables**

GDSentry detects:
- ``CI_PLATFORM=travis_ci``
- ``BUILD_NUMBER=$TRAVIS_BUILD_NUMBER``

Workflow Templates
==================

Basic Testing Workflow
----------------------

For simple projects with unit tests only:

.. code-block:: yaml

    # GitHub Actions Example
    name: GDSentry Tests
    on: [push, pull_request]

    jobs:
      test:
        runs-on: ubuntu-latest
        steps:
        - uses: actions/checkout@v4
        - uses: actions/setup-python@v4
          with:
            python-version: '3.9'
        - uses: chickensoft-games/setup-godot@v1
          with:
            version: 4.2.1
        - run: pip install gdsentry
        - run: gdsentry test run --report junit --output test-results/
        - uses: dorny/test-reporter@v1
          if: always()
          with:
            name: GDSentry Tests
            path: test-results/junit.xml
            reporter: java-junit

Performance Testing Pipeline
----------------------------

Include performance benchmarks in CI:

.. code-block:: yaml

    name: Performance Tests
    on:
      schedule:
        - cron: '0 2 * * 1'  # Weekly on Monday
      workflow_dispatch:

    jobs:
      performance:
        runs-on: ubuntu-latest
        steps:
        - uses: actions/checkout@v4
        - uses: chickensoft-games/setup-godot@v1
          with:
            version: 4.2.1
        - run: |
            cp -r gdsentry/ project/
            mkdir -p performance_results
            godot --headless --script gdsentry/core/test_runner.gd --performance --output performance_results/
        - uses: actions/upload-artifact@v4
          with:
            name: performance-results
            path: performance_results/

Matrix Testing (Multiple Godot Versions)
----------------------------------------

Test across different Godot versions:

.. code-block:: yaml

    name: Matrix Tests
    on: [push, pull_request]

    jobs:
      test:
        runs-on: ubuntu-latest
        strategy:
          matrix:
            godot-version: ['4.1.3', '4.2.1', '4.3-dev']
        steps:
        - uses: actions/checkout@v4
        - uses: chickensoft-games/setup-godot@v1
          with:
            version: ${{ matrix.godot-version }}
        - run: |
            cp -r gdsentry/ project/
            mkdir -p test_results
            godot --headless --script gdsentry/core/test_runner.gd --discover --report junit --report-path test_results/
        - uses: actions/upload-artifact@v4
          with:
            name: test-results-${{ matrix.godot-version }}
            path: test_results/

Integration Patterns
====================

Pull Request Validation
-----------------------

Ensure code quality before merging:

.. code-block:: yaml

    name: PR Validation
    on:
      pull_request:
        types: [opened, synchronize, reopened]

    jobs:
      validate:
        runs-on: ubuntu-latest
        steps:
        - uses: actions/checkout@v4
        - uses: chickensoft-games/setup-godot@v1
          with:
            version: 4.2.1
        - run: |
            cp -r gdsentry/ project/
            mkdir -p test_results
            godot --headless --script gdsentry/core/test_runner.gd --discover --report junit --report-path test_results/ --fail-on-error
        - run: |
            # Additional validation
            if [ $(grep -c "<failure>" test_results/junit.xml) -gt 0 ]; then
              echo "Tests failed - blocking merge"
              exit 1
            fi

Release Testing
---------------

Comprehensive testing before releases:

.. code-block:: yaml

    name: Release Tests
    on:
      release:
        types: [published]

    jobs:
      release-test:
        runs-on: ubuntu-latest
        strategy:
          matrix:
            os: [ubuntu-latest, windows-latest, macos-latest]
        steps:
        - uses: actions/checkout@v4
        - uses: chickensoft-games/setup-godot@v1
          with:
            version: 4.2.1
        - run: |
            cp -r gdsentry/ project/
            mkdir -p release_test_results
            godot --headless --script gdsentry/core/test_runner.gd --comprehensive --report junit --report-path release_test_results/
        - uses: actions/upload-artifact@v4
          with:
            name: release-test-results-${{ matrix.os }}
            path: release_test_results/

Nightly Regression Testing
--------------------------

Catch regressions with nightly runs:

.. code-block:: yaml

    name: Nightly Regression Tests
    on:
      schedule:
        - cron: '0 2 * * *'  # Daily at 2 AM
      workflow_dispatch:

    jobs:
      regression:
        runs-on: ubuntu-latest
        steps:
        - uses: actions/checkout@v4
        - uses: chickensoft-games/setup-godot@v1
          with:
            version: 4.2.1
        - run: |
            cp -r gdsentry/ project/
            mkdir -p regression_results
            # Run with baseline comparison
            godot --headless --script gdsentry/core/test_runner.gd --regression-test --baseline main --output regression_results/
        - uses: actions/upload-artifact@v4
          if: always()
          with:
            name: regression-results
            path: regression_results/

Parallel Test Execution
-----------------------

Speed up large test suites:

.. code-block:: yaml

    name: Parallel Tests
    on: [push]

    jobs:
      test:
        runs-on: ubuntu-latest
        strategy:
          matrix:
            test-group: [1, 2, 3, 4]
        steps:
        - uses: actions/checkout@v4
        - uses: chickensoft-games/setup-godot@v1
          with:
            version: 4.2.1
        - run: |
            cp -r gdsentry/ project/
            mkdir -p parallel_results
            godot --headless --script gdsentry/core/test_runner.gd --group ${{ matrix.test-group }} --total-groups 4 --report junit --report-path parallel_results/

GDSentry CLI Options for CI/CD
===============================

Common CLI options for CI/CD pipelines:

.. code-block:: bash

    # Basic test discovery and execution
    gdsentry test run

    # Generate JUnit XML report
    gdsentry test run --report junit --output results/

    # Run specific test categories
    gdsentry test run --category unit

    # Enable verbose output
    gdsentry test run --verbose

    # Quick smoke tests
    gdsentry test quick

    # Fail immediately on first error
    gdsentry test run --fail-fast

    # Custom timeout
    gdsentry test run --timeout 300

Troubleshooting
===============

GitHub Actions Issues
---------------------

**Godot Setup Fails**
.. code-block::

    # Use specific Godot version
    - uses: chickensoft-games/setup-godot@v1
      with:
        version: 4.2.1
        use-dotnet: false

**Test Timeouts**
.. code-block:: yaml

    - run: timeout 300 godot --headless --script gdsentry/core/test_runner.gd --discover
      timeout-minutes: 5

**Artifact Upload Issues**
.. code-block:: yaml

   - uses: actions/upload-artifact@v4
     if: always()  # Upload even if tests fail
     with:
     name: test-results
     path: test_results/

GitLab CI Issues
----------------

**Docker Image Selection**
.. code-block:: yaml

   # Use Godot CI image
   image: barichello/godot-ci:4.2.1

   # Or build custom image
   image:
   name: barichello/godot-ci:4.2.1
   entrypoint: [""]

**Artifact Expiry**
   .. code-block:: none

      artifacts:
        paths:
          - test_results/
        expire_in: 1 week  # Adjust retention period
      }

Jenkins Issues
--------------

**Godot Installation**
   .. code-block:: groovy

       steps {
           sh '''
           wget https://downloads.tuxfamily.org/godotengine/4.2.1/Godot_v4.2.1-stable_linux.x86_64.zip
           unzip Godot_v4.2.1-stable_linux.x86_64.zip
           sudo mv Godot_v4.2.1-stable_linux.x86_64/Godot /usr/local/bin/godot
           sudo chmod +x /usr/local/bin/godot
           '''
       }


**Test Result Publishing**
   .. code-block:: groovy

      steps {
      junit 'test_results/junit.xml'
      publishHTML(target: [
      reportName: 'GDSentry Test Report',
      reportDir: 'test_results',
      reportFiles: 'report.html',
      keepAll: true
      ])
      }


Common Issues
=============

**Godot Headless Mode**
- Ensure all tests work in headless mode
- Remove visual dependencies from CI tests
- Use ``OS.is_headless()`` checks in test code

**File Path Issues**
- Use relative paths from project root
- Ensure GDSentry is copied to the correct location
- Check working directory in CI scripts

**Memory Issues**
- Large test suites may need more memory
- Split tests into smaller batches
- Use parallel execution to reduce individual job memory

**Timing Issues**
- CI environments may be slower than local machines
- Increase timeouts for complex tests
- Use retry logic for flaky tests

**Platform-Specific Failures**
- Test on multiple platforms if targeting different OS
- Account for different file systems and path separators
- Check platform-specific Godot behavior

Best Practices
==============

**CI/CD Setup**
- Run tests on every push and pull request
- Use matrix builds for multiple Godot versions
- Archive test artifacts for debugging
- Set up notifications for test failures

**Test Organization**
- Separate fast unit tests from slow integration tests
- Use tags to categorize tests for different CI stages
- Implement test quarantine for flaky tests
- Regular cleanup of old test artifacts

**Performance Monitoring**
- Track test execution times
- Set up performance regression alerts
- Regular performance testing on main branches
- Compare performance across releases

**Security Considerations**
- Don't commit sensitive data in CI scripts
- Use secret management for API keys and credentials
- Regular security audits of CI configurations
- Limit artifact retention to necessary periods

Next Steps
==========

Now that you have CI/CD integration set up:

1. **Customize**: Adapt the workflow templates to your project's needs
2. **Expand**: Add performance testing and coverage reporting
3. **Monitor**: Set up dashboards to track test trends over time
4. **Optimize**: Use parallel execution and test splitting for faster feedback

.. seealso::
   :doc:`../getting-started` - GDSentry setup basics
   :doc:`performance-testing` - Performance testing in CI/CD
   :doc:`../best-practices` - Testing best practices
