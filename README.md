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
