Projekt na przedmiot Języki Formalne i Teoria Translacji.

Celem projektu było napisanie własnego kompilatora do podanego w specyfikacji języku z wykorzystaniem narzędzi poznanych w trakcie realizacji przedmiotu.

Specyfikacja kompilatora znajduje się w pliku spcyfikacja.pdf. Gramatyka języka jest folderze interpreter. 
Interpreter do kodu znajduje się w folderze interpreter.

Poprzednie dwa zadania znajdują się w folderze flex i bison, które były zadaniami w celu nauki obsługi tych narzędzi.

W celu uzyskania pliku z wykorzystaniem bisona i flexa należy wywołać makefile:
```
$make
```
Przykładowe wywołanie kompilatora dla pliku test.in i zinterpretowanie go interpreterem.
```
$./compiler < test.in > test.out && ./interpreter/interpreter test.out
```
