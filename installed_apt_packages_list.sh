#!/bin/bash

# Vérification que le script est exécuté sous Bash
if [ -z "$BASH_VERSION" ]; then
    echo "This script must be run with bash. Please modify the shebang to #!/bin/bash and rerun."
    exit 1
fi

# Détection de la langue du système, utilisation de l'anglais par défaut si LANG n'est pas défini
lang=${LANG:-"en"}
lang=$(echo $lang | cut -d'_' -f1)

# Fonction pour afficher l'aide
usage() {
    if [[ "$lang" == "fr" ]]; then
        echo "Usage: $0 [options]"
        echo
        echo "Options:"
        echo "  -h                Affiche ce message d'aide."
        echo "  -f <fichier>      Spécifie le fichier log APT à analyser. Par défaut : /var/log/apt/history.log."
        echo "  -o <fichier>      Spécifie le fichier de sortie."
        echo
        echo "Exemple : $0 -f /var/log/apt/history.log -o result.txt"
        echo "  Analyse le fichier /var/log/apt/history.log et enregistre les résultats dans result.txt."
    else
        echo "Usage: $0 [options]"
        echo
        echo "Options:"
        echo "  -h                Display this help message."
        echo "  -f <file>         Specify the APT log file to analyze. Default: /var/log/apt/history.log."
        echo "  -o <file>         Specify the output file."
        echo
        echo "Example: $0 -f /var/log/apt/history.log -o result.txt"
        echo "  Analyzes the file /var/log/apt/history.log and saves the results to result.txt."
    fi
    exit 0
}

# Valeurs par défaut
log_file="/var/log/apt/history.log"
output_file=""

# Analyse des arguments
while getopts ":hf:o:" opt; do
    case ${opt} in
        h )
            usage
            ;;
        f )
            log_file=$OPTARG
            ;;
        o )
            output_file=$OPTARG
            ;;
        \? )
            if [[ "$lang" == "fr" ]]; then
                echo "Option invalide : -$OPTARG" >&2
            else
                echo "Invalid option: -$OPTARG" >&2
            fi
            usage
            ;;
        : )
            if [[ "$lang" == "fr" ]]; then
                echo "L'option -$OPTARG requiert un argument." >&2
            else
                echo "Option -$OPTARG requires an argument." >&2
            fi
            usage
            ;;
    esac
done

# Vérification que le fichier log existe
if [ ! -f "$log_file" ]; then
    if [[ "$lang" == "fr" ]]; then
        echo "Erreur : Le fichier $log_file n'a pas été trouvé."
    else
        echo "Error: The file $log_file was not found."
    fi
    exit 1
fi

# Initialiser le compteur de packages
n=0
formatted_date=""
installing_package=""

# Lire le fichier de log et traiter les lignes
while IFS= read -r line; do
    if [[ "$line" == Start-Date:* ]]; then
        # Extraire la date et l'heure du début
        date=$(echo "$line" | sed 's/Start-Date: //;s/  .*$//')
        time=$(echo "$line" | awk '{print $3}')
        
        # Formater la date selon la langue du système
        if [[ "$lang" == "fr" ]]; then
            formatted_date=$(date -d "$date $time" "+%d/%m/%Y %H:%M:%S")
        else
            formatted_date=$(date -d "$date $time" "+%m/%d/%Y %H:%M:%S")
        fi

    elif [[ "$line" == Commandline:* ]]; then
        # Extraire les paquets que nous voulons suivre
        packages=$(echo "$line" | sed 's/.* install //' | sed 's/-y//' | sed 's/^ *//;s/ *$//')

    elif [[ "$line" == Install:* ]]; then
        # Rechercher spécifiquement les paquets dans la ligne Install:
        for package in $packages; do
            # Extraire la version avec awk
            version=$(echo "$line" | awk -v package="$package" '
            {
                start = index($0, package)
                if (start > 0) {
                    rest = substr($0, start)
                    if (match(rest, /\(([0-9]+:[0-9.]+)|\(([0-9.]+)/)) {
                        version = substr(rest, RSTART+1, RLENGTH-1)
                        # Si la version contient un ":", prendre ce qui est après
                        if (index(version, ":") > 0) {
                            split(version, parts, ":")
                            print parts[2]
                        } else {
                            print version
                        }
                    }
                }
            }')

            # Afficher ou écrire le résultat
            if [[ -n "$version" ]]; then
                ((n++))  # Incrémenter n de 1
                echo -ne "Packages : $n\r"  # Afficher le compteur sur la même ligne
                output="$formatted_date\t$package\t$version"
                if [[ -n "$output_file" ]]; then
                    echo -e "$output" >> "$output_file"
                else
                    echo -e "$output"
                fi
            fi
        done
    fi
done < <(grep -E '^(Start-Date:|Commandline:|Install:)' "$log_file")

# Message de confirmation
if [[ "$lang" == "fr" ]]; then
    echo -e "\nTotal de packages trouvés: $n\n"
else
    echo -e "\nTotal packages found: $n\n"
fi
