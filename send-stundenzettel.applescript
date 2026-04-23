-- Berechne aktuelle ISO-Kalenderwoche
set weekNum to do shell script "date +%V"

set theSubject to "Stundenzettel KW " & weekNum
set theRecipient to "britta.behrmann@codekeepers.de"
set attachPath to "/Users/ralfwirdemann/Documents/CodeKeepers/Stundenzettel/2026-Stundenzettel_Ralf-Wirdemann.xlsx"

-- Datei prüfen und als Alias auflösen (schlägt mit Fehler fehl wenn nicht vorhanden)
set theAlias to (POSIX file attachPath) as alias

set theBody to "Hallo Britta," & return & return & ¬
    "anbei findest du meinen Stundenzettel für KW " & weekNum & "." & ¬
    return & return & ¬
    "Viele Grüße und ein schönes Wochenende," & return & ¬
    "Ralf"

tell application "Mail"
    set newMsg to make new outgoing message with properties ¬
        {subject:theSubject, content:theBody, visible:true}

    tell newMsg
        make new to recipient at end of to recipients ¬
            with properties {address:theRecipient}
        make new attachment with properties {file name:theAlias} ¬
            at after last paragraph of content
    end tell

    activate
end tell
