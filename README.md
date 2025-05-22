# RNMRT_MobiiliProjekti
# 📝 Flutter ToDo-sovellus

Yksinkertainen tehtävienhallintasovellus Flutterilla.
Sovellus mahdollistaa tehtävien lisäämisen, muokkaamisen, poistamisen, hakemisen ja
suodattamisen prioriteetin ja tilan mukaan, sekä tehtävien kuittaamisen tehdyksi.
Tallennus tapahtuu paikallisesti laitteen muistissa käyttäen `SharedPreferences`.

## 🔧 Ominaisuudet

 - ✅ Tehtävien lisääminen, muokkaaminen, poistaminen ja kuittaaminen tehdyksi
 - 🎯 Tehtävien priorisointi: **Kiireelliset**, **Tärkeät**, **Ei kiireelliset**
 - 📅 Päivämäärän ja kellonajan näyttö ja muotoilu
 - 🌓 Tumma ja vaalea teema
 - 🔍 Hakutoiminto tehtävän nimellä tai päivämäärällä
 - 🧮 Suodatus tehtävien tilan ja prioriteetin mukaan
 - 💾 Paikallinen tallennus SharedPreferencesilla

 ## 🖼️ Käyttöliittymä

- **Etusivu:** Näyttää tehtävälistan, hakukentän, suodattimet ja tumman/vaalean teeman valinnan.
- **Tehtävän lisäys-/muokkausnäyttö:** Navigoidaan erilliseen näkymään uuden tehtävän luomista tai olemassa olevan muokkaamista varten.
- **Tehtävälista:** Lista näyttää tehtäväkortin jossa tehtävän nimi, päivämäärä, prioriteetti värillä sekä muokkaus- ja poistopainikkeet.
                  Tehtävät listautuvat automaattisesti tekemättömät ensin ja päivämäärän mukaan nousevassa järjestyksessä.

## 🧠 Tiedonhallinta

Kaikki tehtävät tallennetaan `SharedPreferences`-muotoon listana JSON-merkkijonoja.
Tallennettuja tehtäviä luetaan sovelluksen käynnistyessä ja päivitetään aina muutoksen jälkeen.

## ⚙️ Asennus

1. Klonaa projekti
2. Lataa riippuvuudet:
   flutter pub get
3. Käynnistä sovellus:
   flutter run

## 🧭 Käyttöohje

1. Käynnistä sovellus
    - Avaa sovellus laitteella tai emulaattorilla.

2. Lisää uusi tehtävä
    - Paina alareunan ➕ Lisää tehtävä-painiketta.
    - Valitse päivämäärä ja prioriteetti.
    - Syötä tehtävän nimi.
    - Tallenna tehtävä.

3. Muokkaa tehtävää
    - Paina tehtäväkortin kynäikonia.
    - Tee tarvittavat muutokset ja tallenna.

4. Poista tehtävä
    - Paina tehtäväkortin roskakorikuvaketta.

5. Merkitse tehtävä tehdyksi
    - Napauta tehtävää listassa.
    - Väri muuttuu vihreäksi ja teksti yliviivataan.

6. Käytä hakua
    - Kirjoita hakusana ylhäällä olevaan kenttään.
    - Lista suodattuu automaattisesti.

7. Käytä suodattimia
    - Avaa suodatinvalikko hakukentän alta.
    - Valitse prioriteetit ja tehtävän tila.

8. Vaihda teemaa (tumma / vaalea)
    - Paina oikean yläkulman auringon / kuun kuvaketta.






