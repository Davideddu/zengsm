#!/bin/bash
zenity="zenity --window-icon phone --title ZenGSM"

while true; do
    yes | $zenity --progress --no-cancel --pulsate --text "Ricerca dispositivi in corso..." &
    pidd="$!"
    modems=$(./list_modems)
    kill $pidd
    if [ "${modems}" == "" ]; then
        $zenity --question --text "Non è stato trovato alcun dispositivo." --ok-label "Ricontrolla" --cancel-label "Esci"
        if [ $? == 1 ]; then
            exit 0
        fi
        continue
    else    
        modems="${modems}'FALSE' 'ricontrolla' '' 'Ripeti la ricerca dei dispositivi...'"
        modem=$(echo "${modems}" | xargs $zenity --list --height 500 --width 450 --text "Scegli la chiavetta/telefono" --radiolist --hide-column 2 --column "" --column "DBus path" --column "Marca" --column "Modello")
        if [ "${modem}" == "" ]; then
            exit 0
        elif [ "${modem}" != "ricontrolla" ]; then
            break
        fi
    fi
done

yes | $zenity --progress --no-cancel --pulsate --text "Attivazione della rete cellulare..." &
pid0="$!"
./enable "${modem}"
kill $pid0

while true; do
    yes | $zenity --progress --no-cancel --pulsate --text "Lettura informazioni in corso..." &
    pid="$!"
    info=$(./get_info "${modem}")
    kill $pid
    action=$($zenity --list --text "Cosa vuoi fare?" --height 500 --width 450 --hide-column 1 --column "" --column "Azione" --hide-header --print-column 1 "stato" "${info}" "credito" "Controlla il credito residuo" "ricarica" "Effettua una ricarica" "sms" "Invia un SMS" "ussd" "Invia un codice di servizio" "esci" "Esci")
    case $action in
        "credito")
            yes | $zenity --progress --no-cancel --pulsate --text "Richiesta in corso..." &
            pid1="$!"
            credito=$(./ussd "${modem}" "*123#")
            kill $pid1
            $zenity --info --text "${credito}"
        ;;
        "stato")
            ./detailed_info "${modem}" | $zenity --text-info --height 600 --width 600
        ;;
        "ricarica")
            op=$(./get_operator "${modem}")
            operator=()
            while read -r line; do
                operator+=("$line")
            done <<< "${op}"
            to_use_op="${operator[1]}"
            while true
                case "${to_use_op}" in
                    "Wind")
                        taglio=$($zenity --list --text "Operatore rilevato: ${operator[1]} ${operator[0]}\nSeleziona il taglio della ricarica WIND" --hide-column 2 --column "" --column "Taglio" --column "Taglio" --hide-header --height 250 --radiolist 0 "5" "5€" 0 "10" "10€" 0 "15" "15€" 0 "25" "25€" 0 "50" "50€")

                        if [ "${taglio}" != "" ]; then
                        codice=$($zenity --entry --text "Operatore rilevato: ${operator[1]} ${operator[0]}\nInserisci il codice della ricarica WIND senza spazi")
                        if [ "${codice}" != "" ]; then
                        yes | $zenity --progress --no-cancel --pulsate --text "Richiesta in corso..." &
                        pid2="$!"
                        ./sms_send "${modem}" --number "4155" --modem "${modem}" "RICARICA ${taglio} ${codice}"
                        kill "$pid2"
                        fi
                        fi
                        yes | $zenity --progress --no-cancel --pulsate --text "Richiesta credito in corso..." &
                        pid3="$!"
                        credito=$(./ussd "${modem}" "*123#")
                        kill $pid3
                        $zenity --info --text "${credito}"
                        break
                    ;;
                    "TIM")
                        codice=$($zenity --entry --text "Operatore rilevato: ${operator[1]} ${operator[0]}\nInserisci il codice segreto della RICARICard TIM senza spazi")
                        if [ "${codice}" != "" ]; then
                        yes | $zenity --progress --no-cancel --pulsate --text "Richiesta in corso..." &
                        pid2="$!"
                        ./sms_send "${modem}" --number "40916" --modem "${modem}" "RIC ${codice}"
                        kill "$pid2"
                        fi
                        yes | $zenity --progress --no-cancel --pulsate --text "Richiesta credito in corso..." &
                        pid3="$!"
                        credito=$(./ussd "${modem}" "*123#")
                        kill $pid3
                        $zenity --info --text "${credito}"
                        break
                    ;;
                    "Vodafone")
                        codice=$($zenity --entry --text "Operatore rilevato: ${operator[1]} ${operator[0]}\nInserisci il codice segreto della ricarica Vodafone senza spazi")
                        if [ "${codice}" != "" ]; then
                        yes | $zenity --progress --no-cancel --pulsate --text "Richiesta in corso..." &
                        pid2="$!"
                        ./sms_send "${modem}" --number "42010" --modem "${modem}" "${codice}"
                        kill "$pid2"
                        fi
                        yes | $zenity --progress --no-cancel --pulsate --text "Richiesta credito in corso..." &
                        pid3="$!"
                        credito=$(./ussd "${modem}" "*123#")
                        kill $pid3
                        $zenity --info --text "${credito}"
                        break
                    ;;
                    *)
                        to_use_op=$($zenity --list --text "L'operatore rilevato non è supportato.\nQuesto può essere dovuto al fatto che si è in roaming\nnella rete di un altro operatore.\nÈ possibile selezionare un operatore dalla lista in basso.\n(Operatore rilevato: ${operator[1]} ${operator[0]})" --column "Operatori disponibili" --height 500 --width 450 "Wind" "Vodafone" "TIM")
                        if [ "${taglio}" == "" ]; then
                            break
                        fi
                    ;;
                esac
        ;;
        "sms")
            numero=$($zenity --entry --text "Inserisci il numero di telefono del destinatario")
            if [ "${numero}" != "" ]; then
            testo=$($zenity --text-info --editable --text "Inserisci il testo del messaggio")
            if [ "${testo}" != "" ]; then
            yes | $zenity --progress --pulsate --no-cancel --text "Invio in corso..." &
            pid4="$!"
            ./sms_send --number "${numero}" --modem "${modem}" "${testo}"
            kill "$pid4"
            $zenity --info --text "Messaggio inviato" --title "ZenGSM"
            fi
            fi
        ;;
        "ussd")
            ussd=$($zenity --entry --text "Inserisci il codice di servizio" --entry-text "*123#")
            if [ "${ussd}" != "" ]; then
            yes | $zenity --progress --no-cancel --pulsate --text "Richiesta in corso..." &
            pid5="$!"
            risposta=$(./ussd "${modem}" "${ussd}" 2>&1)
            kill $pid5
            echo "${risposta}" | $zenity --text-info --title "ZenGSM"
            fi
        ;;
        *)
            exit 0
        ;;
    esac
done