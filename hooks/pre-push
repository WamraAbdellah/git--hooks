#!/bin/sh

echo "Lancement des vérifications Maven avant le push..."

# nettoyage et compilation
echo "Compilation du projet..."
mvn clean compile
if [ $? -ne 0 ]; then
  echo "Échec de la compilation."
  exit 1
fi

# exécution des tests
echo "Exécution des tests..."
mvn test
if [ $? -ne 0 ]; then
  echo "Échec des tests."
  exit 1
fi

# analyse avec SpotBugs
echo "Analyse SpotBugs..."
mvn spotbugs:check
if [ $? -ne 0 ]; then
  echo "Échec de l'analyse SpotBugs."
  exit 1
fi

# analyse de dépendances OWASP
echo "Vérification des vulnérabilités de dépendances..."
mvn org.owasp:dependency-check-maven:check
if [ $? -ne 0 ]; then
  echo "Vulnérabilités détectées par OWASP Dependency-Check."
  exit 1
fi

echo "Toutes les vérifications sont passées avec succès. Push autorisé."
exit 0
