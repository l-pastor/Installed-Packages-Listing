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
        echo "  -o <fichier>      Spécifie le fichier de sortie."                                                                                                                            
        echo                                                                                                                                                                                 
        echo "Exemple : $0 -o result.txt"                                                                                                                        
    else                                                                                                                                                                                     
        echo "Usage: $0 [options]"                                                                                                                                                           
        echo                                                                                                                                                                                 
        echo "Options:"                                                                                                                                                                      
        echo "  -h                Display this help message."                                                                                                                                
        echo "  -o <file>         Specify the output file."                                                                                                                                  
        echo                                                                                                                                                                                 
        echo "Example: $0 -o result.txt"                                                                                                                         
    fi                                                                                                                                                                                       
    exit 0                                                                                                                                                                                   
} 

# Analyse des arguments                                                                                                                                                                      
while getopts ":hf:o:" opt; do                                                                                                                                                               
    case ${opt} in                                                                                                                                                                           
        h )                                                                                                                                                                                  
            usage                                                                                                                                                                            
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

# Initialiser le compteur de packages                                                                                                                                                        
n=0

# Vérification de l'installation de Rust
version=$(rustc --version 2>/dev/null | cut -d ' ' -f2)

if [ $? -eq 0 ]; then # Vérifier si la commande a réussi

    # Récupérer la liste des packages installés
    rust_packages=$(cargo install --list)

    # Initialiser un tableau associatif pour stocker les correspondances package -> binaire
    declare -A package_binaries

    # Extraire les noms des packages et leurs binaires associés
    while IFS= read -r line; do
        if [[ $line =~ ^[[:space:]]+ ]]; then
            # Si la ligne commence par un espace, c'est un nom de binaire
            binary_name=$(echo $line | xargs) # xargs supprime les espaces superflus
            package_binaries[$package_name]+=" $binary_name"
        else
            # Sinon, c'est un nom de package
            package_name=$(echo $line | cut -d ' ' -f1)
        fi
    done <<< "$rust_packages"

    # Parcourir chaque package pour afficher les informations de date et version
    for package in "${!package_binaries[@]}"; do
        # Ignorer les packages liés à `cargo-update`
        if [[ "$package" == "cargo-update" ]]; then
            continue
        fi

        # Extraire la version correcte sans 'v' ni ':' à la fin
        version=$(echo "$rust_packages" | grep "^$package " | cut -d ' ' -f2 | sed 's/^v//' | sed 's/://')

        for binary in ${package_binaries[$package]}; do
            # Vérifier si le fichier binaire existe avant de récupérer les informations
            if [ -f "$HOME/.cargo/bin/$binary" ]; then

            	((n++))  # Incrémenter n de 1
            	
                date=$(stat "$HOME/.cargo/bin/$binary" 2>/dev/null | grep Birth | cut -d ' ' -f3)
                time=$(stat "$HOME/.cargo/bin/$binary" 2>/dev/null | grep Birth | cut -d ' ' -f4 | cut -d '.' -f1)

                # Formater la date selon la langue du système
                if [[ "$lang" == "fr" ]]; then
                    formatted_date=$(date -d "$date $time" "+%d/%m/%Y %H:%M:%S")
                else
                    formatted_date=$(date -d "$date $time" "+%m/%d/%Y %H:%M:%S")
                fi

                # Afficher le résultat avec ou sans le binaire entre parenthèses
                if [ "$package" != "$binary" ]; then
                    output="$formatted_date $package ($binary) $version"
                else
                    output="$formatted_date $package $version"
                fi

                if [[ -n "$output_file" ]]; then                                                                                                                                             
               		echo -e "$output" >> "$output_file"                                                                                                                                      
                else                                                                                                                                                                         
                	echo -e "$output"                                                                                                                                                        
                fi
            fi
        done
    done

    if [[ "$lang" == "fr" ]]; then                                                                                                                                                               
        echo -e "\nTotal de packages trouvés: $n\n"                                                                                                                                              
    else                                                                                                                                                                                         
        echo -e "\nTotal packages found: $n\n"                                                                                                                                                   
    fi
else
	if [[ "$lang" == "fr" ]]; then                                                                                                                                                               
	    echo -e "\nRust n'est pas installé !\n"                                                                                                                                              
	else                                                                                                                                                                                         
	    echo -e "\nRust ins't installed!\n"                                                                                                                                                   
	fi
fi
