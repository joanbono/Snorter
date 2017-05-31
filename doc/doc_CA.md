<!-- $theme: default -->

![](../img/1.png)

# Snorter
## Guia d'Instal·lació

Instal·la `Snort` + `Barnyard2` + `PulledPork` automàticament

[@joan_bono](https://twitter.com/joan_bono)


---

## Què necessites?


- Un ordinador amb:
	- **Debian**
	- **Kali Linux** 
	- **Raspbian Jessie**
- Oinkcode:
	- És **GRATUÏT**! :wink:
	- Molt recomanable
	- Obtenir el teu [aquí](https://www.snort.org/oinkcodes).
- Interfície de xarxa identificada:
	- `ip link show `
- Dependències prèvies:
	- `sudo apt-get install git` 
- Paciència.

---

## Primeres passes

- Clonar el repositori:
~~~bash
git clone https://github.com/joanbono/Snorter.git` 
cd Snorter/src
bash Snorter.sh -h
~~~

- **Recomanat**: Executa el programa fent servir un **oinkcode** 
~~~bash
bash Snorter.sh -o <oinkcode> -i <interface>
Ex: bash Snorter.sh -o XXXXXXXXXXXXX -i eth0
~~~

- **No Recomanat**: Executa el programa sense cap **oinkcode** 

~~~bash
bash Snorter.sh -i interface
bash Snorter.sh -i eth0
~~~

---

## Instal·lació de `Snort`

+ Contrassenya de superusuari, i esperar...
 

![](../img/2.png)

---

+ `Snort` i `daq` s'han instal·lat.

![](../img/3.png)

---

+ Ara toca afegir la `HOME_NET` i la `EXTERNAL_NET`.

![](../img/4.png)

+ Prémer `Intro` per continuar. Obrirà `vim`:
	+ Prémer `A` per anar al final de la línia.
	+ Afegeix l'adreça i la màscara de la xarxa a protegir.
	+ Prémer `Esc` i després `:wq!` per desar canvis.

![](../img/5.png)

---

+ Fes el mateix per a la `EXTERNAL_NET`:

![](../img/6.png)

+ Prémer `Intro` per continuar. Obrirà `vim`:
 	+ Prémer `A` per anar al final de la línia.
	+ Afegir l'adreça *atacant*. **Recomanat**: `!$HOME_NET`.
	+ Prémer `Esc` i després `:wq!` per desar canvis.

![](../img/7.png)

---

+ Ara la **sortida**. Per defecte, s'habilita el format de sortida `unified2`, però pots habilitar més d'una sortida. Vaig a habilitar la sortida en **CSV** i format **TCPdump**.

![](../img/8.png)

---

+ Ara `SNORT` arrancarà en mode `consola`. Mana un `PING` des d'altra màquina per comprovar el funcionament. 

![](../img/9.png)

+ Mostrarà una alerta de `PING`. Prémer `Ctrl+C` **una vegada**, i continua la instal·lació.

---

## Instalació de `Barnyard2`

+ Ara toca instal·lar `BARNYARD2` si vols.
+ Es demana inserir una contrassenya per la base de dades de `SNORT` que es va a crear. En l'exemple utilitzo `SNORTSQL`.

![](../img/10.png)

---

+ Ara el programa instal·larà algunes dependències.
+ Instal·larà `MySQL`, si no està instal·lat prèviament, hauràs d' introduïr una contrassenya de `root`. En l'ejemplo, poso `ROOTSQL`.

![](../img/11.png)

---

+ I la contrassenya del servei `MySQL`.

![](../img/12.png)

---

+ Ara el programa pregunta la contrassenya de `MySQL` **3 vegades**
+ Tenir en compte: contrassenya **`root`** de **`MySQL` 3 vegades**.

![](../img/13.png)

---

## Instal·lació de `PulledPork`

+ Ara toca instal·lar `PulledPork` si vols.

![](../img/14.png)

![](../img/15.png)

---

## Crear un `servei`

+ Crear un `servei` del sistema:

![](../img/17.png)

---

## Descarregar i instal·lar noves regles

+ Pots descarregar i instal·lar noves regles quan tot estiga instal·lat i configurat.

![](../img/18.png)

---

## Habilitar regles `Emerging Threats` i `Community` 

+ Habilitar automàticamente al `snort.conf` les regles d'`Emerging Threats` i `Community`

![](../img/24.png)

---

## WebSnort

+ Instal·lar WebSnort per analitzar `PCAPs`

![](../img/23.png)

---
## Reiniciar

+ Reiniciar el sistema.

![](../img/19.png)
