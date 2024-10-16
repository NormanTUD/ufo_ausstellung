<script>
// Funktion zum Generieren von QR-Code-URLs (Beispiel für deinen PHP-QR-Code-Generator)
function generateQRCodeURL(url) {
    return `qr.php?url=${encodeURIComponent(url)}&size=5`;
}

function replaceKeywordsWithImages(input) {
    let output = input.replace(/\\wikipedia(\{\})?/g, '<img width=64 src="../wiki.png">');

    output = output.replace(/\\hoaxilla(\{\})?/g, '<img width=64 src="../hoaxilla.png">');

    output = output.replace(/\\youtube(\{\})?/g, '<img width=64 src="../youtube.png">');

    output = output.replace(/\\skeptoid(\{\})?/g, '<img width=64 src="../skeptoid.png">');

    output = output.replace(/\\frqq?(\{\})?\\*\s*/g, '&raquo;');
    output = output.replace(/\\flqq?(\{\})?\\*/g, '&laquo;');

    return output;
}

// Funktion zum Suchen und Ersetzen des LaTeX-ähnlichen Textes und Erstellen einer Tabelle pro <li>-Tag
function parseQRText() {
    const textNodes = document.querySelectorAll('li, p');

    textNodes.forEach(node => {
        const text = node.textContent;
        const regex = /\\qr\[(.*?)\]\{(.*?)\}/g;  // RegEx-Pattern, um die LaTeX-ähnlichen QR-Code-Texte zu finden
        let match;

        // Prüfen, ob der Text überhaupt dem QR-Code-Format entspricht
        if (regex.test(text)) {
            // Neue Tabelle erstellen
            const table = document.createElement('table');
            table.setAttribute('border', '0');
            table.style.marginBottom = '20px';  // Optional: Abstände zwischen Tabellen
            const tbody = document.createElement('tbody');

            // Zurücksetzen des regulären Ausdrucks
            regex.lastIndex = 0;  // Setze den RegEx zurück, damit alle Matches verarbeitet werden

            // QR-Code und Beschreibung für jede Übereinstimmung hinzufügen
            while ((match = regex.exec(text)) !== null) {
                const description = match[1];
                const url = match[2];

                const row = document.createElement('tr');
                const qrCell = document.createElement('td');
                const descriptionCell = document.createElement('td');

                // QR-Code-Bild
                const img = document.createElement('img');
                img.src = generateQRCodeURL(url);
                img.alt = `QR-Code für ${url}`;
                img.style.width = "100px";  // Größe des QR-Codes

                qrCell.appendChild(img);
                descriptionCell.innerHTML = replaceKeywordsWithImages(description);

                row.appendChild(qrCell);
                row.appendChild(descriptionCell);
                tbody.appendChild(row);
            }

            table.appendChild(tbody);
            
            node.innerHTML = node.innerHTML.replaceAll(/\\qr\[(.*?)\]\{(.*?)\}/g, '');

            // Tabelle unter das jeweilige <li>-Element einfügen
            node.after(table);
        }
    });
}

// Ruft die Funktion auf, sobald die Seite geladen ist
window.onload = function() {
    parseQRText();
};
</script>
