<script>
// Funktion zum Generieren von QR-Code-URLs (Beispiel für deinen PHP-QR-Code-Generator)
function generateQRCodeURL(url) {
    return `qr.php?url=${encodeURIComponent(url)}&size=5`;
}

// Funktion zum Suchen und Ersetzen des LaTeX-ähnlichen Textes und Erstellen einer Tabelle pro <p>-Tag
function parseQRText() {
	const textNodes = document.querySelectorAll('li');

	textNodes.forEach(node => {
	const text = node.textContent;
	const regex = /\\qr\[(.*?)\]\{(.*?)\}/g;
	let match;

	// Prüfen, ob der Text überhaupt dem QR-Code-Format entspricht
	if (regex.test(text)) {
		// Neue Tabelle erstellen
		const table = document.createElement('table');
		table.setAttribute('border', '0');
		table.style.marginBottom = '20px';  // Optional: Abstände zwischen Tabellen
		const thead = document.createElement('thead');
		const tbody = document.createElement('tbody');

		// Kopfzeile der Tabelle
		const headerRow = document.createElement('tr');
		thead.appendChild(headerRow);

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
			descriptionCell.textContent = description;

			row.appendChild(qrCell);
			row.appendChild(descriptionCell);
			tbody.appendChild(row);
		}

		table.appendChild(thead);
		table.appendChild(tbody);

		// Tabelle unter den jeweiligen <p>-Tag einfügen
		node.after(table);
	}
	});
}

// Ruft die Funktion auf, sobald die Seite geladen ist
window.onload = function() {
	parseQRText();
};
</script>
