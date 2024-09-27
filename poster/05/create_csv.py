import csv
import argparse
from sympy import primerange

def prime_count(max_value):
    # Erstelle eine Liste der Primzahlen bis max_value
    primes = list(primerange(0, max_value + 1))
    
    # Zähle die Primzahlen bis zu jedem x
    prime_counts = []
    for x in range(max_value + 1):
        count = sum(1 for p in primes if p <= x)
        prime_counts.append((x, count))

    return prime_counts

def save_to_csv(data, filename):
    # Speichere die Daten in einer CSV-Datei
    with open(filename, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(['x', 'pix'])  # Kopfzeile
        writer.writerows(data)

def main():
    # Argumente einlesen
    parser = argparse.ArgumentParser(description='Berechne die Primzahlzählfunktion bis zu max_value.')
    parser.add_argument('--max', type=int, default=100000, help='Der maximale Wert für die Primzahlzählfunktion (default: 100000).')
    args = parser.parse_args()

    # Berechne die Primzahlen und speichere sie in CSV
    prime_counts = prime_count(args.max)
    save_to_csv(prime_counts, 'prime_counts.csv')

if __name__ == '__main__':
    main()
