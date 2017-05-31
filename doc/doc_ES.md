<!-- $theme: default -->

![](../img/1.png)

# Snorter
## Guía de Instalación

Instala `Snort` + `Barnyard2` + `PulledPork` automáticamente 

[@joan_bono](https://twitter.com/joan_bono)


---

## ¿Qué necesitas?


- Un ordenador con:
	- **Debian**
	- **Kali Linux** 
	- **Raspbian Jessie**
- Oinkcode:
	- Es **GRATIS**! :wink:
	- Muy recomendable
	- Obtén el tuyo [aquí](https://www.snort.org/oinkcodes).
- Interfaz de red identificada:
	- `ip link show `
- Dependencias previas:
	- `sudo apt-get install git` 
- Paciencia.

---

## Primeros pasos

- Clonar el repositorio:
~~~bash
git clone https://github.com/joanbono/Snorter.git` 
cd Snorter/src
bash Snorter.sh -h
~~~

- **Recomendado**: Ejecuta el programa usando un **oinkcode** 
~~~bash
bash Snorter.sh -o <oinkcode> -i <interface>
Ex: bash Snorter.sh -o XXXXXXXXXXXXX -i eth0
~~~

- **No Recomendado**: Ejecuta el programa sin un **oinkcode** 

~~~bash
bash Snorter.sh -i interface
bash Snorter.sh -i eth0
~~~

---

## Instalación de `Snort`

+ Contraseña de superusuario, y esperar...
 

![](../img/2.png)

---

+ `Snort` y `daq` se han instalado.

![](../img/3.png)

---

+ Ahora toca añadir la `HOME_NET` y la `EXTERNAL_NET`.

![](../img/4.png)

+ Pulsa `Intro` para continuar. Abrirá `vim`:
	+ Pulsa `A` para ir al final de la línea.
	+ Añade la dirección y la máscara de la red a proteger.
	+ Pulsa `Esc` y después `:wq!` para guardar cambios.

![](../img/5.png)

---

+ Haz lo mismo para la `EXTERNAL_NET`:

![](../img/6.png)

+ Pulsa `Intro` para continuar. Abrirá `vim`:
	+ Pulsa `A` para ir al final de la línea.
	+ Añade la dirección *atacante*. **Recomendado**: `!$HOME_NET`.
	+ Pulsa `Esc` y después `:wq!` para guardar cambios.

![](../img/7.png)

---

+ Ahora la **salida**. Por defecto, se habilita el formato de salida `unified2`, pero puedes habilitar más de una salida. Voy a habilitar la salida en **CSV** y formato **TCPdump**.

![](../img/8.png)

---

+ Ahora `SNORT` arrancará en modo `consola`. Manda un `PING` desde otra máquina para comprobar el funcionamiento. 

![](../img/9.png)

+ Mostrará una alerta de `PING`. Pulsa `Ctrl+C` **una vez**, y continua la instalación.

---

## Instalación de `Barnyard2`

+ Ahora toca instalar `BARNYARD2` si quieres.
+ Se pide insertar una contraseña para la base de datos de `SNORT` que se va a crear. En el ejemplo uso `SNORTSQL`.

![](../img/10.png)

---

+ Ahora el programa instalará algunas dependencias.
+ Instalará `MySQL`, si no está instalado previamente, tendrás que introducir una contraseña de `root`. En el ejemplo, yo uso `ROOTSQL`.

![](../img/11.png)

---

+ Y la contraseña del servicio `MySQL`.

![](../img/12.png)

---

+ Ahora el programa pregunta la contraseña de `MySQL` **3 veces**
+ Téngalo en cuenta: contraseña **`root`** de **`MySQL` 3 veces**.

![](../img/13.png)

---

## Instalación de `PulledPork`

+ Ahora toca instalar `PulledPork` si quieres.

![](../img/14.png)

![](../img/15.png)

---

## Crear un `servicio`

+ Crear un `servicio` del sistema:

![](../img/17.png)

---

## Descargar e instalar nuevas reglas

+ Puedes descargar e instalar nuevas reglas cuando todo esté instalado y configurado.

![](../img/18.png)

---

## Habilitar reglas `Emerging Threats` y `Community` 

+ Habilitar automáticamente en `snort.conf` las reglas de `Emerging Threats` y `Community`

![](../img/24.png)

---

## WebSnort

+ Instalar WebSnort para análisis de `PCAPs`

![](../img/23.png)

---

## Reiniciar

+ Reiniciar el sistema.

![](../img/19.png)