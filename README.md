# Kompilator - Analizator Składniowy i Semantyczny

Projekt kompilatora realizujący analizę leksykalną, analizę składniową oraz weryfikację typów. Projekt został napisany z wykorzystaniem narzędzi **Flex** i **Bison** oraz języka **C++**.

## Główne funkcjonalności (Zrealizowane założenia)

- **Analiza leksykalna (Flex)**
- **Analiza składniowa (Bison)**
- **Weryfikacja Semantyczna**
- **Tabela Symboli:** Śledzenie historii życia każdej zmiennej wraz z zapisywaniem wszystkich numerów linii, w których wystąpiła

## Struktura Projektu

- `lexer.l` - Reguły analizatora leksykalnego (Flex).
- `parser.y` - Definicja gramatyki (Bison).
- `checker.h` - Klasy C++ odpowiadające za weryfikację typów.

## Przykładowy wynik działania

```
Parsing has ended successfully
VARIABLE SUMMARY
Variable: licznik | Type: INTEGER | Lines used: 3 11 13 34 39
Variable: limit | Type: INTEGER | Lines used: 4 8 13 18 37
Variable: powitanie | Type: STRING | Lines used: 1 7 11 13 15 20 27
Variable: szukana_pozycja | Type: INTEGER | Lines used: 5 20 21
Variable: wynik | Type: STRING | Lines used: 2 9 15 16 29 37 38
```
