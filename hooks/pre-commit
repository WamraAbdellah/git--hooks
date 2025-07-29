#!/bin/sh


echo "Compiling"
mvn compile
if [ $? -ne 0 ]; then
  echo "Compilation failed"
  exit 1
fi

echo "Checkstyle"
mvn checkstyle:check
if [ $? -ne 0 ]; then
  echo "Checkstyle violations found"
  exit 1
fi

echo "Formatting with Spotless."
mvn spotless:apply
git add -u


echo " Running unit tests."
mvn test -Dtest=QuickTest*
if [ $? -ne 0 ]; then
  echo "Tests failed."
#  exit 1
fi

echo "SpotBugs analysis..."
mvn spotbugs:check
if [ $? -ne 0 ]; then
  echo "SpotBugs issues found."
  exit 1
fi

if command -v detect-secrets >/dev/null 2>&1; then
  echo "Scanning for secrets."
  detect-secrets-hook --baseline .secrets.baseline
  if [ $? -ne 0 ]; then
    echo "Secrets detected!"
    exit 1
  fi
fi
echo 
exit 0
