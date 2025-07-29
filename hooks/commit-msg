#!/bin/sh

# regex pour valider un message de commit préfixé par un ID de ticket (ex: SOD-1010: Mon message)
ticket_commit_regex="^[A-Z]{2,}-[0-9]+: .+$"

# récupère le message de commit (le chemin du fichier est passé en argument $1)
commit_message=$(cat "$1")

# vérifie si le message de commit correspond à la regex
if echo "$commit_message" | grep -Eq "$ticket_commit_regex"; then
  echo "Format du commit valide (Ticket ID trouvé)."
  exit 0
else
  # le format n'est pas bon.
  echo "\033[31mERREUR : Le format de votre message de commit est invalide.\033[0m"
  echo "Il doit obligatoirement commencer par un ID de ticket suivi de ':', d'un espace, puis de votre message."
  echo ""
  echo "\033[32mExemple valide : SOD-1010: Ajout de la fonctionnalité de connexion\033[0m"
  echo ""
  exit 1
fi
